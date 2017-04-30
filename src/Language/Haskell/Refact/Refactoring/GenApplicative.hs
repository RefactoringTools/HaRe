{-# LANGUAGE CPP #-}
{-# LANGUAGE DeriveDataTypeable #-}
module Language.Haskell.Refact.Refactoring.GenApplicative
  (genApplicative, compGenApplicative) where

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
import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.GHC.ExactPrint.Print
import Language.Haskell.GHC.ExactPrint.Parsers

genApplicative :: RefactSettings -> GM.Options -> FilePath -> SimpPos -> IO [FilePath]
genApplicative settings cradle fileName pos = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings cradle (compGenApplicative absFileName pos)

compGenApplicative :: FilePath -> SimpPos -> RefactGhc [ApplyRefacResult]
compGenApplicative fileName pos = do
  (refRes@((_fp,ismod),_), ()) <- applyRefac (doGenApplicative fileName pos) (RSFile fileName)
  case ismod of
    RefacUnmodifed -> error "Generalise to Applicative failed"
    RefacModified -> return ()
  return [refRes]

--The general operation of this refactoring involves transposing the LHsExpr's from within the list of ExprLStmt's
-- to an (OpApp :: HsExpr)
-- The function begins by constructing the beginning of the applicative chain by looking at the construction of the return statement

doGenApplicative :: FilePath -> SimpPos -> RefactGhc ()
doGenApplicative fileName pos = do
  parsed <- getRefactParsed
  let funBind = case getHsBind pos parsed of
                  (Just fb) -> fb
                  Nothing -> error "That location is not the start of a function"
      (retRhs, doStmts) = case (getReturnRhs funBind, getDoStmts funBind) of
                            ((Just rets), (Just stmt)) -> (rets, stmt)
                            _ -> error "The function needs to consist of set of do statements with a return value."
      boundVars = findBoundVars doStmts
  checkPreconditions retRhs doStmts boundVars
  appChain <- constructAppChain retRhs doStmts
  replaceFunRhs pos appChain


checkPreconditions :: ParsedExpr -> [GHC.ExprLStmt GHC.RdrName] -> [GHC.RdrName] -> RefactGhc ()
checkPreconditions retRhs doStmts boundVars = do
  let boundVarsPrecon = checkBVars doStmts boundVars
      retVarsOrder = varOrdering boundVars retRhs
      orderingPrecon = checkOrdering retVarsOrder doStmts
  if (not boundVarsPrecon)
    then error "GenApplicative Precondition: The function given uses a bound variable in a RHS expression."
    else if (not orderingPrecon)
         then error "GenApplicative Precondition: Variables are not bound in the order that they appear in the return statement."
         else return ()
  where checkBVars [] _ = True
        checkBVars (stmt:stmts) vars = case stmt of
          (GHC.L _ (GHC.BodyStmt body _ _ _)) -> (not (lexprContainsVars vars body)) && (checkBVars stmts vars)
#if __GLASGOW_HASKELL__ <= 710
          (GHC.L _ (GHC.BindStmt _ body _ _)) -> (not (lexprContainsVars vars body)) && (checkBVars stmts vars)
#else
          (GHC.L _ (GHC.BindStmt _ body _ _ _)) -> (not (lexprContainsVars vars body)) && (checkBVars stmts vars)
#endif
        lexprContainsVars :: [GHC.RdrName] -> ParsedLExpr -> Bool
        lexprContainsVars vars = SYB.everything (||) (False `SYB.mkQ` (\nm -> elem nm vars))
        varOrdering :: [GHC.RdrName] -> ParsedExpr -> [GHC.RdrName]
        varOrdering boundVars = SYB.everything (++) ([] `SYB.mkQ` (\nm -> if (elem nm boundVars) then [nm] else []))
        checkOrdering :: [GHC.RdrName] -> [GHC.ExprLStmt GHC.RdrName] -> Bool
        checkOrdering [] [] = True
        checkOrdering [] ((GHC.L _ (GHC.BodyStmt _ _ _ _)):stmts) = checkOrdering [] stmts
        checkOrdering vars ((GHC.L _ (GHC.BodyStmt _ _ _ _)):stmts) = checkOrdering vars stmts
#if __GLASGOW_HASKELL__ <= 710
        checkOrdering (var:vars) ((GHC.L _ (GHC.BindStmt pat _ _ _)):stmts) =
#else
        checkOrdering (var:vars) ((GHC.L _ (GHC.BindStmt pat _ _ _ _)):stmts) =
#endif
          if (checkPat var pat)
          then (checkOrdering vars stmts)
          else False
        checkPat var pat = gContains var pat

gContains :: (Data t, Eq a, Data a) => a -> t -> Bool
gContains item t = SYB.everything (||) (False `SYB.mkQ` (\b -> item == b)) t

replaceFunRhs :: SimpPos -> ParsedLExpr -> RefactGhc ()
replaceFunRhs pos newRhs = do
  parsed <- getRefactParsed
  let rdrNm = locToRdrName pos parsed
  case rdrNm of
    Nothing -> error "replaceFunRhs: Position does not correspond to a binding."
    (Just (GHC.L _ rNm)) -> do
      newParsed <- everywhereMStaged SYB.Parser (SYB.mkM (worker rNm)) parsed
      putRefactParsed newParsed emptyAnns
      logParsedSource "GenApplicative.replaceFunRhs"
  where worker :: GHC.RdrName -> ParsedBind -> RefactGhc (GHC.HsBind GHC.RdrName)
#if __GLASGOW_HASKELL__ <= 710
        worker rNm fBind@(GHC.FunBind (GHC.L _ fNm) _ mg _ _ _)
#else
        worker rNm fBind@(GHC.FunBind (GHC.L _ fNm) mg _ _ _)
#endif
          | fNm == rNm = do
              newMg <- replaceMG mg
              return $ fBind{GHC.fun_matches = newMg}
          | otherwise = return fBind
        worker _ bind = return bind
        replaceMG :: ParsedMatchGroup -> RefactGhc ParsedMatchGroup
        replaceMG mg = do
#if __GLASGOW_HASKELL__ <= 710
          let [(GHC.L l match)] = GHC.mg_alts mg
#else
          let (GHC.L _ [(GHC.L l match)]) = GHC.mg_alts mg
#endif
              oldGrhss = GHC.m_grhss match
              newGrhss = mkGrhss oldGrhss newRhs
              newLMatch = (GHC.L l (match{GHC.m_grhss = newGrhss}))
#if __GLASGOW_HASKELL__ <= 710
          return mg{GHC.mg_alts = [newLMatch]}
#else
          lMatchLst <- locate [newLMatch]
          return mg{GHC.mg_alts = lMatchLst}
#endif
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
              mergeRefactAnns anns
              return (Just expr)
        _ -> do
          lRet <- locate retExpr
          stripBoundVars lRet boundVars
      where stripBoundVars :: ParsedLExpr -> [GHC.RdrName] -> RefactGhc (Maybe ParsedLExpr)
#if __GLASGOW_HASKELL__ <= 710
            stripBoundVars le@(GHC.L l (GHC.HsVar nm)) names =
#else
            stripBoundVars le@(GHC.L l (GHC.HsVar (GHC.L _ nm))) names =
#endif
              if (elem nm names)
              then return Nothing
              else return (Just le)
            stripBoundVars (GHC.L l (GHC.HsApp expr1 expr2)) names = do
              ne1 <- stripBoundVars expr1 names
              ne2 <- stripBoundVars expr2 names
              case ne2 of
                Nothing -> return ne1
                (Just e2) -> return (ne1 >>= (\e1 -> Just (GHC.L l (GHC.HsApp e1 e2))))

isJustBoundVar :: ParsedExpr -> [GHC.RdrName] -> Bool
#if __GLASGOW_HASKELL__ <= 710
isJustBoundVar (GHC.HsVar nm) names = elem nm names
#else
isJustBoundVar (GHC.HsVar (GHC.L _ nm)) names = elem nm names
#endif
isJustBoundVar _ _ = False

getDoStmts :: GHC.HsBind GHC.RdrName -> Maybe [GHC.ExprLStmt GHC.RdrName]
getDoStmts funBind = SYB.something (Nothing `SYB.mkQ` stmtLst) funBind
  where stmtLst :: GHC.HsExpr GHC.RdrName -> Maybe [GHC.ExprLStmt GHC.RdrName]
#if __GLASGOW_HASKELL__ <= 710
        stmtLst (GHC.HsDo _ stmtLst _) = Just (init stmtLst)
#else
        stmtLst (GHC.HsDo _ (GHC.L _ stmtLst) _) = Just (init stmtLst)
#endif
        stmtLst _ = Nothing

findBoundVars :: [GHC.ExprLStmt GHC.RdrName] -> [GHC.RdrName]
findBoundVars = SYB.everything (++) ([] `SYB.mkQ` findVarPats)
  where findVarPats :: GHC.Pat GHC.RdrName -> [GHC.RdrName]
#if __GLASGOW_HASKELL__ <= 710
        findVarPats (GHC.VarPat rdr) = [rdr]
#else
        findVarPats (GHC.VarPat (GHC.L _ rdr)) = [rdr]
#endif
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
      lOp <- lInfixFmap
      addAnnVal lOp
      locate (GHC.OpApp pure lOp GHC.PlaceHolder effects)
  where
    buildChain :: [ParsedLExpr] -> RefactGhc ParsedLExpr
    buildChain [e] = return e
    buildChain (e:es) = do
      rhs <- buildChain es
      lOp <- lFApp
      addAnnVal lOp
      let opApp = (GHC.OpApp e lOp GHC.PlaceHolder rhs)
      locate opApp
    getStmtExpr :: GHC.ExprLStmt GHC.RdrName -> ParsedLExpr
    getStmtExpr (GHC.L _ (GHC.BodyStmt body _ _ _)) = body
#if __GLASGOW_HASKELL__ <= 710
    getStmtExpr (GHC.L _ (GHC.BindStmt _ body _ _)) = body
#else
    getStmtExpr (GHC.L _ (GHC.BindStmt _ body _ _ _)) = body
#endif
    buildSingleExpr :: [GHC.ExprLStmt GHC.RdrName] -> RefactGhc ParsedLExpr
    buildSingleExpr [st] = return $ getStmtExpr st
    buildSingleExpr lst@(st:stmts) = do
      let (before,(bindSt:after)) = break isBindStmt lst
      rOp <- rApp
      lOp <- lApp
      mLeftOfBnds <- buildApps rOp (map getStmtExpr before)
      mRightOfBnds <- buildApps lOp (map getStmtExpr after)
      mapM_ (\ex -> (setDP (DP (0,1))) (getStmtExpr ex)) (tail lst)
      lROp <- lRApp
      addAnnVal lROp
      lLOp <- lLApp
      addAnnVal lLOp
      newBndStmt <- mkBind (getStmtExpr bindSt)
      case (mLeftOfBnds,mRightOfBnds) of
        (Nothing,Nothing) -> error "buildSingleExpr was passed an empty list."
        ((Just leftOfBnds),Nothing) -> do
          app <- locate (GHC.OpApp leftOfBnds lROp GHC.PlaceHolder newBndStmt)
          wrapInPars app
        (Nothing, (Just rightOfBnds)) -> do
          app <- locate (GHC.OpApp newBndStmt lLOp GHC.PlaceHolder rightOfBnds)
          wrapInPars app
        ((Just leftOfBnds),(Just rightOfBnds)) -> do
          setDP (DP (0,1)) newBndStmt
          lOpApp <- locate (GHC.OpApp leftOfBnds lROp GHC.PlaceHolder newBndStmt)
          fullApp <- locate (GHC.OpApp lOpApp lLOp GHC.PlaceHolder rightOfBnds)
          wrapInPars fullApp
    mkBind :: ParsedLExpr -> RefactGhc ParsedLExpr
    mkBind e@(GHC.L _ (GHC.HsVar _)) = return e
    mkBind expr = do
      zeroDP expr
      wrapInParsWithDPs (DP (0,0)) (DP (0,0)) expr
    buildApps :: ParsedExpr -> [ParsedLExpr] -> RefactGhc (Maybe ParsedLExpr)
    buildApps op [] = return Nothing
    buildApps op [st] = return (Just st)
    buildApps op (st:stmts) = do
      mRhs <- buildApps op stmts
      case mRhs of
        Nothing -> return (Just st)
        (Just rhs) -> do
          lOp <- locate op
          addAnnVal lOp
          lExpr <- locate (GHC.OpApp st lOp GHC.PlaceHolder rhs)
          return (Just lExpr)
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
#if __GLASGOW_HASKELL__ <= 710
isBindStmt (GHC.L _ (GHC.BindStmt _ _ _ _)) = True
#else
isBindStmt (GHC.L _ (GHC.BindStmt _ _ _ _ _)) = True
#endif
isBindStmt _ = False

lFApp :: RefactGhc ParsedLExpr
lFApp = fApp >>= locate

fApp :: RefactGhc ParsedExpr
fApp = hsVar "<*>"


isFApp :: ParsedLExpr -> Bool
#if __GLASGOW_HASKELL__ <= 710
isFApp (GHC.L _ (GHC.HsVar rdrNm)) = (GHC.mkVarUnqual (fsLit "<*>")) == rdrNm
#else
isFApp (GHC.L _ (GHC.HsVar (GHC.L _ rdrNm))) = (GHC.mkVarUnqual (fsLit "<*>")) == rdrNm
#endif
isFApp _ = False

lLApp :: RefactGhc ParsedLExpr
lLApp = lApp >>= locate

lApp :: RefactGhc ParsedExpr
lApp = hsVar "<*"

lRApp :: RefactGhc ParsedLExpr
lRApp = rApp >>= locate

rApp :: RefactGhc ParsedExpr
rApp = hsVar "*>"

lInfixFmap :: RefactGhc ParsedLExpr
lInfixFmap = infixFmap >>= locate

infixFmap :: RefactGhc ParsedExpr
infixFmap = hsVar "<$>"

-- TODO: Move this to Utils/Variables.hs, but make it lhsVar
hsVar :: String -> RefactGhc ParsedExpr
hsVar n = do
#if __GLASGOW_HASKELL__ <= 710
  return (GHC.HsVar (mkRdrName n))
#else
  lNm <- locate $ mkRdrName n
  liftT $ addSimpleAnnT lNm (DP (0,0)) [(G GHC.AnnVal,DP (0,0))]
  return (GHC.HsVar lNm)
#endif
