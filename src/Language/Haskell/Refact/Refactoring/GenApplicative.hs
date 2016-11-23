{-# LANGUAGE DeriveDataTypeable #-}
module Language.Haskell.Refact.Refactoring.GenApplicative where

import Language.Haskell.Refact.API
import qualified Language.Haskell.GhcMod as GM
import qualified GHC as GHC
import qualified RdrName as GHC
import System.Directory
import FastString
import Data.Map as Map (union)
import Data.Generics as SYB
import GHC.SYB.Utils as SYB
import Data.List
import Control.Monad
import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.GHC.ExactPrint.Print
import Language.Haskell.GHC.ExactPrint.Parsers

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
      (Just retRhs) = getReturnRhs funBind
      (Just doStmts) = getDoStmts funBind
      boundVars = findBoundVars doStmts
  if checkPreconditions retRhs doStmts boundVars
    then do
    appChain <- constructAppChain retRhs doStmts
    replaceFunRhs funNm pos appChain
    else error "A precondition failed to pass."

checkPreconditions :: ParsedExpr -> [GHC.ExprLStmt GHC.RdrName] -> [GHC.RdrName] -> Bool
checkPreconditions retRhs doStmts boundVars = let boundVarsPrecon = checkBVars doStmts boundVars
                                                  orderingPrecon = True in
                                                boundVarsPrecon && orderingPrecon
  where checkBVars [] _ = True
        checkBVars (stmt:stmts) vars = case stmt of
          (GHC.L _ (GHC.BodyStmt body _ _ _)) -> not (lexprContainsNames vars body)
          (GHC.L _ (GHC.BindStmt _ body _ _)) -> not (lexprContainsNames vars body)
        lexprContainsNames :: [GHC.RdrName] -> ParsedLExpr -> Bool
        lexprContainsNames vars = SYB.everything (&&) (True `SYB.mkQ` (\nm -> elem nm vars))
                                                         
replaceFunRhs :: String -> SimpPos -> ParsedLExpr -> RefactGhc ()
replaceFunRhs funNm pos newRhs = do
  parsed <- getRefactParsed
  let rdrNm = locToRdrName pos parsed
  case rdrNm of
    Nothing -> error "replaceFunRhs: Position does not correspond to a binding."
    (Just (GHC.L _ rNm)) -> do
      newParsed <- everywhereMStaged SYB.Parser (SYB.mkM (worker rNm)) parsed
      fetchAnnsFinal >>= putRefactParsed newParsed
  where worker :: GHC.RdrName -> GHC.HsBind GHC.RdrName -> RefactGhc (GHC.HsBind GHC.RdrName)
        worker rNm fBind@(GHC.FunBind (GHC.L _ fNm) _ mg _ _ _)
          | fNm == rNm = do
              let newMg = replaceMG mg fBind
              return $ fBind{GHC.fun_matches = newMg}
          | otherwise = return fBind
        worker _ bind = return bind
        replaceMG mg newBind =
          let [(GHC.L l match)] = GHC.mg_alts mg
              oldGrhss = GHC.m_grhss match
              newGrhss = mkGrhss oldGrhss newRhs
              newLMatch = (GHC.L l (match{GHC.m_grhss = newGrhss})) in
            mg{GHC.mg_alts = [newLMatch]}
        mkGrhss old newExpr = let [(GHC.L l (GHC.GRHS lst _))] = GHC.grhssGRHSs old in
          old{GHC.grhssGRHSs = [(GHC.L l (GHC.GRHS lst newExpr))]}              
                                   
          

processReturnStatement :: ParsedExpr -> [GHC.RdrName] -> RefactGhc (Maybe ParsedLExpr)
processReturnStatement retExpr boundVars
  | isJustBoundVar retExpr boundVars = return Nothing
  | otherwise =
      case retExpr of
        (GHC.ExplicitTuple lst _) -> do
          dFlags <- GHC.getSessionDynFlags
          let commas = repeat ','
              constr = "(" ++ (take ((length lst)-1) commas) ++ ")"
              parseRes = parseExpr dFlags "hare" constr
          case parseRes of
            (Left (_, errMsg)) -> do
              logm "processReturnStatement: error parsing tuple constructor"
              return Nothing
            (Right (anns, expr)) -> do
              mergeAnns anns
              return (Just expr)
        _ -> do
          logm $ SYB.showData SYB.Parser 3 retExpr
          lRet <- locate retExpr
          stripBoundVars lRet boundVars
      where stripBoundVars :: ParsedLExpr -> [GHC.RdrName] -> RefactGhc (Maybe ParsedLExpr)
            stripBoundVars le@(GHC.L l (GHC.HsVar nm)) names =
              if (elem nm names)
              then return Nothing
              else return (Just le)
            stripBoundVars (GHC.L l (GHC.HsApp expr1 expr2)) names = do
              ne1 <- stripBoundVars expr1 names
              ne2 <- stripBoundVars expr2 names
              case ne2 of
                Nothing -> return ne1
                (Just e2) -> return (ne1 >>= (\e1 -> Just (GHC.L l (GHC.HsApp e1 e2))))

mergeAnns :: Anns -> RefactGhc ()
mergeAnns anns = do
  currAnns <- fetchAnnsFinal
  let newAnns = Map.union anns currAnns
  setRefactAnns newAnns

isJustBoundVar :: ParsedExpr -> [GHC.RdrName] -> Bool
isJustBoundVar (GHC.HsVar nm) names = elem nm names
isJustBoundVar _ _ = False

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
getReturnRhs funBind = SYB.something (Nothing `SYB.mkQ` retStmt `SYB.extQ` dollarRet) funBind
  where retStmt :: GHC.ExprLStmt GHC.RdrName -> Maybe ParsedExpr
        retStmt (GHC.L _ (GHC.BodyStmt (GHC.L _ body)  _ _ _)) = if isRet body
          then Just (retRHS body)
          else Nothing
        retStmt _ = Nothing
        dollarRet :: ParsedExpr -> Maybe ParsedExpr
        dollarRet (GHC.OpApp ret dollar _ expr) = if (isHsVar "return" $ GHC.unLoc ret) && (isHsVar "$" $ GHC.unLoc dollar)
          then Just (GHC.unLoc expr)
          else Nothing
        dollarRet _ = Nothing
        isRet :: ParsedExpr -> Bool
        isRet (GHC.HsApp (GHC.L _ mRet) _) = isHsVar "return" mRet
        isRet _ = False
        retRHS :: ParsedExpr -> ParsedExpr
        retRHS (GHC.HsApp _  (GHC.L _ rhs)) = rhs

removePars :: ParsedLExpr -> RefactGhc ParsedLExpr
removePars (GHC.L _ (GHC.HsPar expr)) = do
  setDP (DP (0,1)) expr
  return expr
removePars expr = return expr

constructAppChain :: ParsedExpr -> [GHC.ExprLStmt GHC.RdrName] -> RefactGhc ParsedLExpr
constructAppChain retRhs lst = do
  let clusters = clusterStmts lst
      boundVars = findBoundVars lst
  pars <- mapM buildSingleExpr clusters
  pars2 <- if length pars == 1
              then do newP <- (removePars (head pars))
                      return [newP]
              else return pars
  effects <- buildChain pars2
  mPure <- processReturnStatement retRhs boundVars
  case mPure of
    Nothing -> do
      return effects
    (Just pure) -> do
      setDP (DP (0,1)) pure
      lOp <- locate infixFmap
      addAnnVal lOp
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
    buildSingleExpr [st] = return $ getStmtExpr st
    buildSingleExpr lst@(st:stmts) = do
      let (before,(bindSt:after)) = break isBindStmt lst
      leftOfBnds <- buildApps rApp (map getStmtExpr before)
      rightOfBnds <- buildApps lApp (map getStmtExpr after)
      mapM_ (\ex -> (setDP (DP (0,1))) (getStmtExpr ex)) (tail lst)
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
