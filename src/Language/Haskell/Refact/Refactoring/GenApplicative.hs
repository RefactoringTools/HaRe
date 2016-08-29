module Language.Haskell.Refact.Refactoring.GenApplicative where

import Language.Haskell.Refact.API
import qualified Language.Haskell.GhcMod as GM
import qualified GHC as GHC
import System.Directory

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


constructAppChain :: [GHC.ExprLStmt GHC.RdrName] -> RefactGhc ParsedExpr
constructAppChain (st:stmts) = do
  rest <- case length stmts of
            1 -> return $ getBody (head stmts)
            _ -> constructAppChain stmts
  case getStmtLR st of
    --If it is a bodystmt then this statement will not affect the output of the function so we can simply 
    (GHC.BodyStmt body _ _ _) -> do
      
  where
    getStmtLR :: GHC.ExprLStmt GHC.RdrName -> GHC.StmtLR GHC.RdrName GHC.RdrName ParsedLExpr
    getStmtLR (GHC.L _ stlr) = stlr
    getBody :: GHC.ExprLStmt GHC.RdrName -> ParsedLExpr
    getBody (GHC.BindStmt _ body _ _) = body
    getBody (GHC.BodyStmt body _ _ _) = body
{-constructPureStatement :: ParsedExpr -> RefactGhc (Maybe ([ParsedExpr] -> ParsedLExpr))
constructPureStatement pExpr =
  case pExpr of
    (GHC.HsVar _) -> return Nothing
    _ -> error "Other types of expressions are not supported yet."
-}
