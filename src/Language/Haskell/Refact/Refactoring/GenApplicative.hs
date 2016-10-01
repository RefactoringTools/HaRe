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
constructAppChain retRhs lst@(st:stmts) = do
  effects <- buildChain lst
  return undefined

  where
    getStmtExpr :: GHC.ExprLStmt GHC.RdrName -> GHC.LHsExpr GHC.RdrName
    getStmtExpr (GHC.L _ (GHC.BodyStmt body _ _ _)) = body
    getStmtExpr (GHC.L _ (GHC.BindStmt _ body _ _)) = body
    buildChain :: [GHC.ExprLStmt GHC.RdrName] -> RefactGhc ParsedExpr
    buildChain (st:stmts) = do           
      let (op, rst) = buildChain' stmts
          useApply = op && isBindStmt st
          stExpr = getStmtExpr st
      if useApply then do
        lap <- locate fApp
        return (GHC.OpApp rst lap (GHC.PlaceHolder) stExpr)
      else do
        return undefined
    buildChain' = undefined

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

lApp :: ParsedExpr
lApp = let nm = fsLit "<*" in
  (GHC.HsVar (GHC.mkVarUnqual nm))

rApp :: ParsedExpr
rApp = let nm = fsLit "*>" in
  (GHC.HsVar (GHC.mkVarUnqual nm))

