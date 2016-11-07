module Language.Haskell.Refact.Refactoring.GenApplicative where

import Language.Haskell.Refact.API
import qualified Language.Haskell.GhcMod as GM
import qualified GHC as GHC
import qualified RdrName as GHC
import System.Directory
import FastString
import Data.Generics as SYB
import GHC.SYB.Utils as SYB


genApplicative :: RefactSettings -> GM.Options -> FilePath -> String -> SimpPos -> IO [FilePath]
genApplicative settings cradle fileName funNm pos = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings cradle (comp absFileName funNm pos)

comp :: FilePath -> String -> SimpPos -> RefactGhc [ApplyRefacResult]
comp fileName funNm pos = do
  (refRes@((_fp,ismod),_), ()) <- applyRefac (doGenApplicative fileName funNm pos) (RSFile fileName)
  case ismod of
    RefacUnmodifed -> error "Generalise to Applicative failed"
    RefacModified -> return ()
  return [refRes]

--The general operation of this refactoring involves transposing the LHsExpr's from within the list of ExprLStmt's
-- to an (OpApp :: HsExpr)
-- The function begins by constructing the beginning of the applicative chain by looking at the construction of the return statement

doGenApplicative :: FilePath -> String -> SimpPos -> RefactGhc ()
doGenApplicative fileName funNm pos = do
  parsed <- getRefactParsed
  let Just funBind = getHsBind pos funNm parsed
      mRetRhs = getReturnRhs funBind
      doStmts = getDoStmts funBind
  return ()

getDoStmts :: GHC.HsBind GHC.RdrName -> Maybe [GHC.ExprLStmt GHC.RdrName]
getDoStmts funBind = SYB.something (Nothing `SYB.mkQ` stmtLst) funBind
  where stmtLst :: GHC.HsExpr GHC.RdrName -> Maybe [GHC.ExprLStmt GHC.RdrName]
        stmtLst (GHC.HsDo _ stmtLst _) = Just stmtLst
        stmtLst _ = Nothing

getReturnRhs :: UnlocParsedHsBind -> Maybe ParsedExpr
getReturnRhs funBind = SYB.something (Nothing `SYB.mkQ` retStmt) funBind
  where retStmt :: GHC.ExprLStmt GHC.RdrName -> Maybe ParsedExpr
        retStmt (GHC.L _ (GHC.BodyStmt (GHC.L _ body)  _ _ _)) = if isRet body
          then Just (retRHS body)
          else Nothing
        retStmt _ = Nothing
        isRet :: ParsedExpr -> Bool
        isRet (GHC.HsApp (GHC.L _ mRet) _) = isHsVar "return" mRet
        isRet _ = False
        retRHS :: ParsedExpr -> ParsedExpr
        retRHS (GHC.HsApp _  (GHC.L _ rhs)) = rhs


constructAppChain :: ParsedExpr -> [GHC.ExprLStmt GHC.RdrName] -> RefactGhc ParsedExpr
constructAppChain retRhs lst = do
  effects <- buildChain lst
  lRet <- locate retRhs
  lOp <- locate infixFmap
  rhs <- locate effects
  return (GHC.OpApp lRet lOp GHC.PlaceHolder rhs)
  where
    getStmtExpr :: GHC.ExprLStmt GHC.RdrName -> GHC.LHsExpr GHC.RdrName
    getStmtExpr (GHC.L _ (GHC.BodyStmt body _ _ _)) = body
    getStmtExpr (GHC.L _ (GHC.BindStmt _ body _ _)) = body
    buildChain :: [GHC.ExprLStmt GHC.RdrName] -> RefactGhc ParsedExpr
    buildChain lst@(st:stmts) = do
      case (length lst) of
        1 -> return $ GHC.unLoc (getStmtExpr st)
        _ -> do
          (GHC.OpApp _ op _ rhsExpr) <- buildChain' stmts
          return $ (GHC.OpApp (getStmtExpr st) op GHC.PlaceHolder rhsExpr)
    buildChain' lst@(st:stmts) =
      case (length lst) of
        1 -> do
          let op = if (isBindStmt st)
                   then fApp
                   else lApp
              expr = getStmtExpr st
          lOp <- locate op
          return (GHC.OpApp undefined lOp GHC.PlaceHolder expr)
        _ -> do
          (GHC.OpApp _ op1 _ rhsExpr) <- buildChain' stmts
          newOp <- if (not (isBindStmt st)) && (isFApp op1)
                   then (locate rApp)
                   else return op1
          newRHS <- locate (GHC.OpApp (getStmtExpr st) newOp GHC.PlaceHolder rhsExpr)
          let op2 = if (isBindStmt st)
                    then fApp
                    else lApp
          lOp <- locate op2
          return (GHC.OpApp undefined lOp GHC.PlaceHolder newRHS)
          
--Checks if a name occurs in the given ast chunk
nameOccurs :: Data a => GHC.RdrName -> a -> Bool
nameOccurs nm = SYB.everything (||) (False `SYB.mkQ` isName)
  where isName :: GHC.RdrName -> Bool
        isName mName = nm == mName

isBindStmt :: GHC.ExprLStmt GHC.RdrName -> Bool
isBindStmt (GHC.L _ (GHC.BindStmt _ _ _ _)) = True
isBindStmt _ = False

fApp :: ParsedExpr
fApp = let nm = fsLit "<*>" in
  (GHC.HsVar (GHC.mkVarUnqual nm))

isFApp :: ParsedLExpr -> Bool
isFApp (GHC.L _ (GHC.HsVar rdrNm)) = (GHC.mkVarUnqual (fsLit "<*>")) == rdrNm
isFApp _ = False

lApp :: ParsedExpr
lApp = let nm = fsLit "<*" in
  (GHC.HsVar (GHC.mkVarUnqual nm))

rApp :: ParsedExpr
rApp = let nm = fsLit "*>" in
  (GHC.HsVar (GHC.mkVarUnqual nm))

infixFmap :: ParsedExpr
infixFmap = let nm = fsLit "<$>" in
  (GHC.HsVar (GHC.mkVarUnqual nm))
