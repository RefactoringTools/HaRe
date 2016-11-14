{-# LANGUAGE DeriveDataTypeable #-}
module Language.Haskell.Refact.Refactoring.GenApplicative where

import Language.Haskell.Refact.API
import qualified Language.Haskell.GhcMod as GM
import qualified GHC as GHC
import qualified RdrName as GHC
import System.Directory
import FastString
import Data.Generics as SYB
import GHC.SYB.Utils as SYB
import Data.List
import Control.Monad

genApplicative :: RefactSettings -> GM.Options -> FilePath -> String -> SimpPos -> IO [FilePath]
genApplicative settings cradle fileName funNm pos = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings cradle (comp absFileName funNm pos)

comp :: FilePath -> String -> SimpPos -> RefactGhc [ApplyRefacResult]
comp fileName funNm pos = do
  (refRes@((_fp,ismod),_), ()f) <- applyRefac (doGenApplicative fileName funNm pos) (RSFile fileName)
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
      (Just retRhs) = getReturnRhs funBind
      (Just doStmts) = getDoStmts funBind
      retBVars = findBoundVars doStmts
  logm $ SYB.showData SYB.Parser 3 retRhs
  appChain <- constructAppChain retRhs doStmts
  return ()

processReturnStatement :: ParsedExpr -> [GHC.RdrName] -> RefactGhc (Maybe ParsedLExpr)
processReturnStatement retExpr boundVars = return Nothing

getDoStmts :: GHC.HsBind GHC.RdrName -> Maybe [GHC.ExprLStmt GHC.RdrName]
getDoStmts funBind = SYB.something (Nothing `SYB.mkQ` stmtLst) funBind
  where stmtLst :: GHC.HsExpr GHC.RdrName -> Maybe [GHC.ExprLStmt GHC.RdrName]
        stmtLst (GHC.HsDo _ stmtLst _) = Just (init stmtLst)
        stmtLst _ = Nothing

findBoundVars :: [GHC.ExprLStmt GHC.RdrName] -> [GHC.RdrName]
findBoundVars = SYB.everything (++) ([] `SYB.mkQ` findVarPats)
  where findVarPats :: GHC.Pat GHC.RdrName -> [GHC.RdrName]
        findVarPats (GHC.VarPat rdr) = [rdr]
        findVarPats _ = []

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

constructAppChain :: ParsedExpr -> [GHC.ExprLStmt GHC.RdrName] -> RefactGhc ParsedLExpr
constructAppChain retRhs lst = do
  let clusters = clusterStmts lst
      boundVars = findBoundVars lst
  pars <- mapM buildSingleExpr clusters
  effects <- buildChain pars
  mPure <- processReturnStatement retRhs boundVars
  lOp <- locate infixFmap
  addAnnVal lOp
  logm $ "PRINTING!!!!!!!!!!!!!!!!!!"
  exactPrintExpr effects
  case mPure of
    Nothing -> do
      return effects
    (Just pure) -> do
      locate (GHC.OpApp pure lOp GHC.PlaceHolder effects)
  where
    buildChain :: [ParsedLExpr] -> RefactGhc ParsedLExpr
    buildChain [e] = return e
    buildChain (e:es) = do
      rhs <- buildChain es
      lOp <- locate fApp
      addAnnVal lOp
      let opApp = (GHC.OpApp e lOp GHC.PlaceHolder rhs)
      locate opApp      
    getStmtExpr :: GHC.ExprLStmt GHC.RdrName -> GHC.LHsExpr GHC.RdrName
    getStmtExpr (GHC.L _ (GHC.BodyStmt body _ _ _)) = body
    getStmtExpr (GHC.L _ (GHC.BindStmt _ body _ _)) = body
    buildSingleExpr :: [GHC.ExprLStmt GHC.RdrName] -> RefactGhc ParsedLExpr
    buildSingleExpr lst@(st:stmts) = do
      let (before,(bindSt:after)) = break isBindStmt lst
      leftOfBnds <- buildApps rApp (map getStmtExpr before)
      rightOfBnds <- buildApps lApp (map getStmtExpr after)
      lROp <- locate rApp
      addAnnVal lROp
      lLOp <- locate lApp
      addAnnVal lLOp
      lOpApp <- locate (GHC.OpApp leftOfBnds lROp GHC.PlaceHolder (getStmtExpr bindSt))
      fullApp <- locate (GHC.OpApp lOpApp lLOp GHC.PlaceHolder rightOfBnds)
      wrapInPars fullApp
    buildApps :: ParsedExpr -> [ParsedLExpr] -> RefactGhc ParsedLExpr
    buildApps op [st] = return st
    buildApps op (st:stmts) = do
      rhs <- buildApps op stmts
      lOp <- locate op
      addAnnVal lOp
      locate (GHC.OpApp st lOp GHC.PlaceHolder rhs)
    clusterStmts :: [GHC.ExprLStmt GHC.RdrName] -> [[GHC.ExprLStmt GHC.RdrName]]
    clusterStmts lst = let indices = findIndices isBindStmt lst
                           clusters = cluster indices (length lst) 0 in
                       map (\is -> map (\i -> lst !! i) is) clusters
    cluster [i] l c = [[c..(l-1)]]
    cluster (i1:i2:is) l c = let b = i1 + ((i2-i1) `div` 2) in
      [c .. b]:(cluster (i2:is) l (b+1))
        

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
