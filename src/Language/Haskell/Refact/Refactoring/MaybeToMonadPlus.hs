{-# LANGUAGE ScopedTypeVariables, FlexibleContexts #-}
module Language.Haskell.Refact.Refactoring.MaybeToMonadPlus where

import Language.Haskell.Refact.API
import qualified Language.Haskell.GhcMod as GM
import qualified Language.Haskell.GhcMod.Internal as GM
import System.Directory
import qualified GHC as GHC
import Data.Generics as SYB
import GHC.SYB.Utils as SYB
import Data.Generics.Strafunski.StrategyLib.StrategyLib
import Language.Haskell.GHC.ExactPrint.Parsers
import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Utils
import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.GHC.ExactPrint.Transform
import qualified Outputable as GHC
import Control.Applicative
import qualified Data.Map as Map
import qualified OccName as GHC
import qualified RdrName as GHC
import qualified BasicTypes as GHC
import qualified ApiAnnotation as GHC
import qualified Type as GHC
import Data.Maybe
import FastString

maybeToMonadPlus :: RefactSettings -> GM.Options -> FilePath -> SimpPos -> String -> Int -> IO [FilePath]
maybeToMonadPlus settings cradle fileName pos funNm argNum = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings cradle (comp absFileName pos funNm argNum)

comp :: FilePath -> SimpPos -> String -> Int -> RefactGhc [ApplyRefacResult]
comp fileName (row,col) funNm argNum = do
  (refRes@((_fp,ismod), _),()) <- applyRefac (doMaybeToPlus fileName (row,col) funNm argNum) (RSFile fileName)
  case ismod of
    RefacUnmodifed -> error "Maybe to MonadPlus synonym failed"
    RefacModified -> return ()
  return [refRes]
      

doMaybeToPlus :: FilePath -> SimpPos -> String -> Int -> RefactGhc ()  
doMaybeToPlus fileName pos@(row,col) funNm argNum = do
  parsed <- getRefactParsed
  -- Add test that position defines function with name `funNm`
  let mBind = getHsBind pos funNm parsed
  case mBind of
    Nothing -> error "Function bind not found"
    Just funBind -> do
      canReplaceConstructors <- isOutputType funNm argNum pos funBind
      case canReplaceConstructors of
        True -> do
          logm $ "Can replace constructors"
          replaceConstructors pos funNm argNum
        False -> do
          hasNtoN <- containsNothingToNothing funNm argNum pos funBind
          logm $ "Result of searching for nothing to nothing: " ++ (show hasNtoN)
          case hasNtoN of
            False -> return ()
            True -> do
              doRewriteAsBind fileName pos funNm
          return ()

--This checks if the argument to be refactored is the output type
--If this is true then the refactoring will just consist of replacing all RHS calls to the Maybe type with their MPlus equivalents
--I need some way of checking if the type 
isOutputType :: String -> Int -> SimpPos -> GHC.HsBind GHC.RdrName -> RefactGhc Bool
isOutputType funNm argNum pos funBind = do
  renamed <- getRefactRenamed
  parsed <- getRefactParsed
  (Just name) <- locToNameRdr pos parsed
  (Just ty) <- getTypeForName name
  let depth = typeDepth ty
  return $ depth == argNum
    where typeDepth :: GHC.Type -> Int
          typeDepth ty = case (GHC.isFunTy ty) of
            True -> 1 + typeDepth (GHC.funResultTy ty)
            False -> 1

--This handles the case where only the output type of the function is being modified so calls to
--Nothing and Just can be replaced with mzero and return respectively in GRHSs
replaceConstructors :: SimpPos -> String -> Int -> RefactGhc ()
replaceConstructors pos funNm argNum = do
  parsed <- getRefactParsed
  let (Just bind) = getHsBind pos funNm parsed
  newBind <- applyInGRHSs bind replaceNothingAndJust
  replaceBind pos newBind
  fixType' funNm argNum
--  p <- getRefactParsed
 -- logm $ "Post type fix ast: \n" ++ (SYB.showData SYB.Parser 3 p)
    where applyInGRHSs :: (Data a) => UnlocParsedHsBind -> (a -> RefactGhc a) -> RefactGhc UnlocParsedHsBind
          applyInGRHSs parsed fun = applyTP (stop_tdTP (failTP `adhocTP` (runGRHSFun fun))) parsed
          runGRHSFun :: (Data a) => (a -> RefactGhc a) -> ParsedGRHSs -> RefactGhc ParsedGRHSs
          runGRHSFun fun grhss@(GHC.GRHSs _ _) = SYB.everywhereM (SYB.mkM fun) grhss
          mzeroOcc = GHC.mkVarOcc "mzero"
          nothingOcc = GHC.mkVarOcc "Nothing"
          returnOcc = GHC.mkVarOcc "return"
          justOcc = GHC.mkVarOcc "Just"
          replaceNothingAndJust :: GHC.OccName -> RefactGhc GHC.OccName
          replaceNothingAndJust nm
            | (GHC.occNameString nm) == "Nothing" = do
                logm "Replacing nothing"
                return mzeroOcc
            | (GHC.occNameString nm) == "Just" = do
                logm "Replace just"
                return returnOcc            
            | otherwise = return nm

replaceBind :: SimpPos -> UnlocParsedHsBind -> RefactGhc ()
replaceBind pos newBind = do
  oldParsed <- getRefactParsed
  let rdrNm = locToRdrName pos oldParsed
  case rdrNm of
    Nothing -> return ()
    (Just (GHC.L _ rNm)) -> do
      newParsed <- SYB.everywhereM (SYB.mkM (worker rNm)) oldParsed
      --logm $ SYB.showData SYB.Parser 3 newParsed
      (liftT getAnnsT) >>= putRefactParsed newParsed
      addMonadImport
  where worker rNm (funBnd@(GHC.FunBind (GHC.L _ name) _ matches _ _ _) :: GHC.HsBind GHC.RdrName)
          | name == rNm = return newBind
          | otherwise = return funBnd
        
type UnlocParsedHsBind = GHC.HsBindLR GHC.RdrName GHC.RdrName
type ParsedGRHSs = GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName)

exactPrintParsed :: RefactGhc ()
exactPrintParsed = do
  parsed <- getRefactParsed
  anns <- fetchAnnsFinal
  let str = exactPrint parsed anns
  logm str

--Handles the case where the function can be rewritten with bind.
doRewriteAsBind :: FilePath -> SimpPos -> String -> RefactGhc ()
doRewriteAsBind fileName pos funNm = do
  parsed <- getRefactParsed
  let bind = gfromJust "doRewriteAsBind" $ getHsBind pos funNm parsed
      matches = GHC.mg_alts . GHC.fun_matches $ bind
  if (length matches) > 1
    then error "Multiple matches not supported"
    else do
    let (GHC.L _ match) = head matches
    (varPat, rhs) <- getVarAndRHS match
    (newPat, _) <- liftT $ cloneT varPat
    (newRhs, _) <- liftT $ cloneT rhs
    lam <- wrapInLambda funNm newPat newRhs
    lam_par <- locate $ GHC.HsPar lam
--    logm $ "New pat: " ++ (SYB.showData SYB.Parser 3 newPat)
    let (GHC.L _ (GHC.VarPat nm)) = newPat
        newNm = mkNewNm nm
    locate newNm
    new_rhs <- createBindGRHS newNm lam_par
    replaceGRHS funNm new_rhs newNm
    prsed <- getRefactParsed
    --logm $ "Final parsed: " ++ (SYB.showData SYB.Parser 3 prsed)
    currAnns <- fetchAnnsFinal
    --logm $ "Final anns: " ++ (show currAnns)
    fixType funNm
    addMonadImport
      where mkNewNm rdr = let str = GHC.occNameString $ GHC.rdrNameOcc rdr in
              GHC.Unqual $ GHC.mkVarOcc ("m_" ++ str)

addMonadImport :: RefactGhc ()
addMonadImport = do
  let monadModNm = GHC.mkModuleName "Control.Monad"
  finalParsed <- getRefactParsed
  newP <- addImportDecl finalParsed monadModNm Nothing False False False Nothing False []
  currAnns <- fetchAnnsFinal
  putRefactParsed newP currAnns

--This function finds the function binding and replaces the pattern match.
--The LHS is replaced with the provided name (3rd argument)
--The RHS is replaced with the provided GRHSs
--Asumptions made:
  --Only one LMatch in the match group
  --Only one variable in LHS
replaceGRHS :: String -> (GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName)) -> GHC.RdrName -> RefactGhc ()
replaceGRHS funNm new_rhs lhs_name = do
  parsed <- getRefactParsed
  newParsed <- SYB.everywhereM (SYB.mkM worker) parsed
  --logm $ "new_rhs: " ++ (SYB.showData SYB.Parser 3 new_rhs)
  --logm $ "The new parsed: " ++ (SYB.showData SYB.Parser 3 newParsed)
  (liftT getAnnsT) >>= putRefactParsed newParsed
 -- return ()
    where rdrName = GHC.Unqual $ GHC.mkDataOcc funNm
          worker :: GHC.HsBind GHC.RdrName -> RefactGhc (GHC.HsBind GHC.RdrName)
          worker fb@(GHC.FunBind (GHC.L _ nm) _ _ _ _ _) |
            (GHC.occNameString . GHC.rdrNameOcc) nm == funNm = do
              logm $ "=======Found funbind========"
              new_matches <- SYB.everywhereM (SYB.mkM worker') (GHC.fun_matches fb)
              final_matches <- fix_lhs new_matches
              return $ fb{GHC.fun_matches = final_matches}
          worker bind = return bind
          worker' :: ParsedGRHSs -> RefactGhc ParsedGRHSs
          worker' (GHC.GRHSs _ _) = do
            logm "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! worker'!!!!!!!!!!!!!!!!!!!!!!"
            return new_rhs
          fix_lhs :: ParsedMatchGroup -> RefactGhc ParsedMatchGroup
          fix_lhs mg = do
            let [(GHC.L _ match)] = GHC.mg_alts mg
                new_pat = GHC.VarPat lhs_name
            lPat <- locate new_pat
            addAnnVal lPat
            let newMatch = match {GHC.m_pats = [lPat]}
                mAnn = annNone {annsDP = [(G GHC.AnnEqual, (DP (0,1)))]}
            new_l_match <- locate newMatch
            addAnn new_l_match mAnn
            return $ mg {GHC.mg_alts = [new_l_match]}

type ParsedMatchGroup = GHC.MatchGroup GHC.RdrName (GHC.LHsExpr GHC.RdrName)
              
--Takes in a lhs pattern and a rhs. Wraps those in a lambda and adds the annotations associated with the lambda. Returns the new located lambda expression

wrapInLambda :: String -> GHC.LPat GHC.RdrName -> ParsedGRHSs -> RefactGhc (GHC.LHsExpr GHC.RdrName)
wrapInLambda funNm varPat rhs = do
  let gen_rhs = justToReturn rhs
  match@(GHC.L l match') <- mkMatch varPat gen_rhs
  --logm $ "Match: " ++ (SYB.showData SYB.Parser 3 match)
  let mg = GHC.MG [match] [] GHC.PlaceHolder GHC.Generated
  currAnns <- fetchAnnsFinal
  --logm $ "Anns :" ++ (show $ getAllAnns currAnns match)
  let l_lam = (GHC.L l (GHC.HsLam mg))
      key = mkAnnKey l_lam
      dp = [(G GHC.AnnLam, DP (0,0))]
      newAnn = annNone {annsDP = dp}
  setRefactAnns $ Map.insert key newAnn currAnns
  par_lam <- wrapInPars l_lam
  return par_lam
  
--Wraps a given expression in parenthesis and add the appropriate annotations, returns the modified ast chunk. 
wrapInPars :: GHC.LHsExpr GHC.RdrName -> RefactGhc (GHC.LHsExpr GHC.RdrName)
wrapInPars expr = do
  newAst <- locate (GHC.HsPar expr)
  let dp = [(G GHC.AnnOpenP, DP (0,1)), (G GHC.AnnCloseP, DP (0,0))]
      newAnn = annNone {annsDP = dp}
  addAnn newAst newAnn
  return newAst

--This creates a GRHS of the form "name >>= expr" and adds the appropriate annotations, returns the GRHSs. 
createBindGRHS :: GHC.RdrName -> GHC.LHsExpr GHC.RdrName -> RefactGhc (GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName))
createBindGRHS name lam_par = do
  bind_occ <- locate $ GHC.HsVar (GHC.Unqual (GHC.mkDataOcc ">>="))
  let occDp = [(G GHC.AnnVal, DP (0,1))]
      occAnn = annNone {annsDP = occDp}
  addAnn bind_occ occAnn
  l_name <- locate $ GHC.HsVar name
  let l_ann = annNone {annsDP = [(G GHC.AnnVal, DP (0,1))]}
  addAnn l_name l_ann 
  oppApp <- locate $ GHC.OpApp l_name bind_occ GHC.PlaceHolder lam_par
  addEmptyAnn oppApp
  lgrhs <- locate $ GHC.GRHS [] oppApp
  addEmptyAnn lgrhs
  return $ GHC.GRHSs [lgrhs] GHC.EmptyLocalBinds

--Adds an empty annotation at the provided location
addEmptyAnn :: (Data a) => GHC.Located a -> RefactGhc ()
addEmptyAnn a = addAnn a annNone

--Adds an "AnnVal" annotation at the provided location
addAnnVal :: (Data a) => GHC.Located a -> RefactGhc ()
addAnnVal a = addAnn a valAnn
  where valAnn = annNone {annEntryDelta = DP (0,1), annsDP = [(G GHC.AnnVal, DP (0,0))]}

--Adds the given annotation at the provided location
addAnn :: (Data a) => GHC.Located a -> Annotation -> RefactGhc ()
addAnn a ann = do
  currAnns <- fetchAnnsFinal
  let k = mkAnnKey a
  setRefactAnns $ Map.insert k ann currAnns

--This takes an AST chunk traverses it and changes any calls to the "Just" constructor to "return"
justToReturn :: (Data a) => a -> a
justToReturn ast = SYB.everywhere (SYB.mkT worker) ast
  where worker :: GHC.OccName -> GHC.OccName
        worker nm = let just = GHC.mkDataOcc "Just" in
          if nm == just
          then GHC.mkDataOcc "return"
          else nm

--This function makes a match suitable for use inside of a lambda expression. Should change name or define it elsewhere to show that this is not a general-use function. 
mkMatch :: GHC.LPat GHC.RdrName -> GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc (GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))
mkMatch varPat rhs = do
  lMatch@(GHC.L l m) <- locate (GHC.Match Nothing [varPat] Nothing rhs)
  let dp = [(G GHC.AnnRarrow, DP (0,1))]
      newAnn = annNone {annsDP = dp, annEntryDelta = DP (0,-1)}
  zeroDP varPat
  addAnn lMatch newAnn
  return lMatch


--This generates a unique location and wraps the given ast chunk with that location
--Also adds an empty annotation at that location
locate :: (Data a) => a -> RefactGhc (GHC.Located a)
locate ast = do
  loc <- liftT uniqueSrcSpanT
  anns <- fetchAnnsFinal
  let res = (GHC.L loc ast)
  addEmptyAnn res
  return res

--Resets the given AST chunk's delta position to zero.
zeroDP :: (Data a) => GHC.Located a -> RefactGhc ()
zeroDP ast = do
  currAnns <- fetchAnnsFinal
  let k = mkAnnKey ast
      mv = Map.lookup k currAnns
  case mv of
    Nothing -> return ()
    Just v -> addAnn ast (v {annEntryDelta = DP (0,0)})

--Takes a single match and returns a tuple containing the grhs and the pattern
--Assumptions:
  -- Only a single pattern will be returned. Which pattern is returned depends on the behaviour of SYB.something. 
getVarAndRHS :: GHC.Match GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc (GHC.LPat GHC.RdrName, ParsedGRHSs)
getVarAndRHS match = do
  let (Just pat) = SYB.something (Nothing `SYB.mkQ` varPat) (GHC.m_pats match)
  return (pat , GHC.m_grhss match)
    where varPat lPat@(GHC.L _ (GHC.VarPat _ )) = Just lPat
          varPat _ = Nothing

--Looks up the function binding at the given position. Returns nothing if the position does not contain a binding.
getHsBind :: (Data a) => SimpPos -> String -> a -> Maybe (GHC.HsBind GHC.RdrName)
getHsBind pos funNm a =
  let rdrNm = locToRdrName pos a in
  case rdrNm of
  Nothing -> Nothing
  (Just (GHC.L _ rNm)) -> SYB.everythingStaged SYB.Parser (<|>) Nothing (Nothing `SYB.mkQ` isBind) a
    where isBind (bnd@(GHC.FunBind (GHC.L _ name) _ _ _ _ _) :: GHC.HsBind GHC.RdrName)
            | name == rNm = (Just bnd)
          isBind _ = Nothing


--This function takes in the name of a function and determines if the binding contains the case "Nothing = Nothing"
--If the Nothing to Nothing case is found then it is removed from the parsed source.
containsNothingToNothing :: String -> Int -> SimpPos -> GHC.HsBind GHC.RdrName -> RefactGhc Bool
containsNothingToNothing funNm argNum pos a = do
  dFlags <- GHC.getSessionDynFlags
  parsed <- getRefactParsed
  let nToNStr = funNm ++ " Nothing = Nothing"
      bind = gfromJust "containsNothingToNothing" $ getHsBind pos funNm parsed
      mg = GHC.fun_matches bind
      (GHC.L _ alt) = (GHC.mg_alts mg) !! 0
--  logm $ "mg_alts: " ++ (SYB.showData SYB.Parser 3 alt)
--  logm $ show $ length (GHC.m_pats alt)
  let oldMatches = SYB.everything (++) ([] `SYB.mkQ` isNtoNMatch) bind
  if (length oldMatches == 0)
    then return False
    else do
    let newMs = getNewMs oldMatches (GHC.mg_alts mg)
        newMg = mg {GHC.mg_alts = newMs}
        newBind = bind {GHC.fun_matches = newMg}
    removeMatches pos newBind oldMatches
    return True
  where
    isNtoNMatch :: ParsedLMatch -> [ParsedLMatch]
    isNtoNMatch lm@(GHC.L _ m) =
      let rhsCheck = checkGRHS $ GHC.m_grhss m
          lhsCheck = checkPats $ GHC.m_pats m in
      if (rhsCheck && lhsCheck)
        then [lm]
        else []
    checkGRHS :: ParsedGRHSs -> Bool
    checkGRHS (GHC.GRHSs [(GHC.L _ (GHC.GRHS _ (GHC.L _ body)))] _)  = isNothingVar body 
    checkGRHS _ = False
    checkPats :: [GHC.LPat GHC.RdrName] -> Bool
    checkPats patLst =
      if argNum <= length patLst
      then let (GHC.L _ pat) = patLst !! (argNum - 1) in
      isNothingPat pat
      else False
    filterMatch :: ParsedLMatch -> [ParsedLMatch] -> [ParsedLMatch]
    filterMatch (GHC.L l1 _) = filter (\(GHC.L l2 _) -> l1 /= l2)
    getNewMs :: [ParsedLMatch] -> [ParsedLMatch] -> [ParsedLMatch]
    getNewMs [] lst = lst
    getNewMs (m:ms) lst = let newLst = filterMatch m lst in
      getNewMs ms newLst
    isNothingPat :: GHC.Pat GHC.RdrName -> Bool
    isNothingPat (GHC.VarPat nm) = ((GHC.occNameString . GHC.rdrNameOcc) nm) == "Nothing"
    isNothingPat (GHC.ConPatIn (GHC.L l nm) _) = ((GHC.occNameString . GHC.rdrNameOcc) nm) == "Nothing"
    isNothingPat _ = False
    isNothingVar :: GHC.HsExpr GHC.RdrName -> Bool
    isNothingVar (GHC.HsVar nm) = ((GHC.occNameString . GHC.rdrNameOcc) nm) == "Nothing"
    isNothingVar _ = False

type ParsedLMatch = GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)

-- Removes the given matches from the given binding. Uses the position to retrieve the rdrName.
removeMatches :: SimpPos -> GHC.HsBind GHC.RdrName -> [GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)] -> RefactGhc ()
removeMatches pos newBind matches = do
  parsed <- getRefactParsed
  let rdrNm = gfromJust "Couldn't get rdrName in removeMatch" $ locToRdrName pos parsed
  newParsed <- SYB.everywhereMStaged SYB.Parser (SYB.mkM (replaceBind rdrNm)) parsed
  currAnns <- fetchAnnsFinal
  mapM removeAnns matches
  (liftT getAnnsT) >>= putRefactParsed newParsed
  return ()
    where replaceBind :: GHC.Located GHC.RdrName -> GHC.HsBind GHC.RdrName -> RefactGhc (GHC.HsBind GHC.RdrName)
          replaceBind rdrNm (bnd@(GHC.FunBind name _ _ _ _ _) :: GHC.HsBind GHC.RdrName)
            | name == rdrNm = return newBind
          replaceBind _ a = return a



--This just pulls out the successful result from an exact print parser or throws an error if the parse was unsuccessful.
handleParseResult :: String -> Either (GHC.SrcSpan, String) (Anns, a) -> RefactGhc (Anns, a)
handleParseResult msg e = case e of
  (Left (_, errStr)) -> error $ "The parse from: " ++ msg ++ " with error: " ++ errStr
  (Right res) -> return res

--This function is very specific to Maybe to MonadPlus refactoring. It rewrites the type signature so that the calls to maybe will be replaced with type variable "m"
--and adds the MonadPlus type class constraint to m
--Assumptions:
  --Assumes the function is of type Maybe a -> Maybe a
  --
  -- Should refactor to take in the argNum parameter and fix the type depending on that

fixType' :: String -> Int -> RefactGhc ()
fixType' funNm argPos = do
  logm "Fixing type"
  parsed <- getRefactParsed
  let m_sig = getSigD funNm parsed
      (GHC.L sigL (GHC.SigD sig)) = fromJust m_sig
  fixedClass <- fixTypeClass sig
  --This needs to be fixed to replace only the correct argument and output type
  replacedMaybe <- replaceMaybeWithVariable fixedClass
  newSig <- locate (GHC.SigD replacedMaybe)
  addNewDP ((G GHC.AnnDcolon), DP (0,1)) newSig
  logm $ "Span: " ++ show sigL
  newParsed <- replaceAtLocation sigL newSig
  synthesizeAnns newSig
  addNewLines 2 newSig
  anns <- liftT getAnnsT
  logm $ showAnnData anns 3 newParsed
  putRefactParsed newParsed anns
    where replaceMaybeWithVariable :: GHC.Sig GHC.RdrName -> RefactGhc (GHC.Sig GHC.RdrName)
          replaceMaybeWithVariable sig = SYB.everywhereM (SYB.mkM worker) sig
            where worker tyVar@(GHC.HsTyVar rdrName)
                    | compNames "Maybe" rdrName = let newRdr = (GHC.mkVarUnqual . fsLit) "m" in
                        return (GHC.HsTyVar newRdr)
                    | otherwise = return tyVar
                  worker var = return var
          fixTypeClass :: GHC.Sig GHC.RdrName -> RefactGhc (GHC.Sig GHC.RdrName)
          fixTypeClass sig@(GHC.TypeSig names (GHC.L _ hsType) p) =
            case hsType of
              (GHC.HsForAllTy f m b context ty) -> do
                newContext <- case context of
                                (GHC.L _ []) -> do
                                  tyCls <- genMonadPlusClass
                                  parTy <- locate (GHC.HsParTy tyCls)
                                  addNewDP ((G GHC.AnnCloseP),DP (0,0)) parTy
                                  liftT $ setPrecedingLinesT parTy 0 (-1)
                                  lList <- locate [parTy]
                                  addNewDPs [((G GHC.AnnOpenP), DP (0,0)),((G GHC.AnnCloseP), DP (0,-1)),((G GHC.AnnDarrow), DP (0,1))] lList
                                  return lList
                                (GHC.L _ [(GHC.L _ (GHC.HsParTy innerTy))]) -> do
                                  tyCls <- genMonadPlusClass
                                  lList <- locate [innerTy,tyCls]
                                  return lList                              
                                (GHC.L _ lst) -> do
                                  tyCls <- genMonadPlusClass
                                  lList <- locate (tyCls:lst)
                                  return lList
                newForAll <- locate (GHC.HsForAllTy f m b newContext ty)
                liftT $ setPrecedingLinesT ty 0 1
                liftT $ setPrecedingLinesT newForAll 0 1
                return (GHC.TypeSig names newForAll p)
              
          genMonadPlusClass :: RefactGhc (GHC.LHsType GHC.RdrName)
          genMonadPlusClass = do
            let mPlusNm = GHC.mkVarUnqual (fsLit "MonadPlus")
                mNm = GHC.mkVarUnqual (fsLit "m")
            lPlus <- locate (GHC.HsTyVar mPlusNm)
            addAnnVal lPlus
            liftT $ setPrecedingLinesT lPlus 0 0
            lM <- locate (GHC.HsTyVar mNm)
            addAnnVal lM
            lApp <- locate (GHC.HsAppTy lPlus lM)
            return lApp

  
fixType :: String -> RefactGhc ()
fixType funNm = do
  parsed <- getRefactParsed
  currAnns <- fetchAnnsFinal
  dFlags <- GHC.getSessionDynFlags
  let m_sig = getSigD funNm parsed
      (GHC.L sigL (GHC.SigD sig)) = fromJust m_sig
      iType = fromJust $ getInnerType sig
      strTy = exactPrint iType currAnns
      tyStr = funNm ++ " :: (MonadPlus m) => m" ++ strTy ++ " -> m" ++ strTy
      pRes = parseDecl dFlags "MaybeToMonadPlus.hs" tyStr
  logm $ "Parsed: " ++ (showData Parser 3 parsed)
  logm $ "Type string: " ++ tyStr
  (anns, newSig) <- handleParseResult "MaybeToMonadPlus.fixType" pRes
  newParsed <- replaceAtLocation sigL newSig
  let newAnns = Map.union currAnns anns
  putRefactParsed newParsed newAnns
  addNewLines 2 newSig

getSigD :: (Data a) => String -> a -> Maybe (GHC.LHsDecl GHC.RdrName)
getSigD funNm = SYB.something (Nothing `SYB.mkQ` isSigD)
  where
    isSigD :: GHC.LHsDecl GHC.RdrName -> Maybe (GHC.LHsDecl GHC.RdrName)
    isSigD s@(GHC.L _ (GHC.SigD sig)) = if isSig sig
                                        then Just s
                                        else Nothing
    isSigD _ = Nothing
    isSig :: GHC.Sig GHC.RdrName -> Bool
    isSig sig@(GHC.TypeSig [(GHC.L _ nm)] _ _) = (compNames funNm nm)
    isSig _ = False

compNames :: String -> GHC.RdrName -> Bool
compNames s rdr = let sRdr = (GHC.occNameString . GHC.rdrNameOcc) rdr in
  sRdr == s

getInnerType :: GHC.Sig GHC.RdrName -> Maybe (GHC.LHsType GHC.RdrName)
getInnerType = SYB.everything (<|>) (Nothing `SYB.mkQ` getTy)
  where getTy :: GHC.HsType GHC.RdrName -> Maybe (GHC.LHsType GHC.RdrName)
        getTy (GHC.HsAppTy mCon otherTy) = if isMaybeTy mCon
                                           then Just otherTy
                                           else Nothing
        getTy _ = Nothing
        isMaybeTy :: GHC.LHsType GHC.RdrName -> Bool
        isMaybeTy (GHC.L _ (GHC.HsTyVar (GHC.Unqual occNm))) = (GHC.occNameString occNm) == "Maybe"
        isMaybeTy _ = False

-- Retrieves all annotations that correspond to all subtrees of the provided ast chunk
getAllAnns :: (Data a) => Anns -> a -> Anns
getAllAnns anns = generic `SYB.ext2Q` located
  where generic :: Data a => a -> Anns
        generic a = foldr Map.union Map.empty (gmapQ (getAllAnns anns) a) 
        located :: (Data b, Data loc) => GHC.GenLocated loc b -> Anns
        located a = case (located' a) of
          Nothing -> Map.empty
          Just as -> as
          where located' :: (Data b, Data loc) => GHC.GenLocated loc b -> Maybe Anns
                located' a@(GHC.L ss b) = do
                  s <- (cast ss) :: (Maybe GHC.SrcSpan)
                  let k = mkAnnKey (GHC.L s b)
                  v <- Map.lookup k anns
                  let rst = getAllAnns anns b
                  return $ Map.singleton k v `Map.union` rst
        
-- This creates an empty annotation for every located item where an annotation does not already exist in the given AST chunk
synthesizeAnns :: (Data a) => a -> RefactGhc a
synthesizeAnns = generic `SYB.ext2M` located
  where generic :: Data a => a -> RefactGhc a
        generic a = do
          _ <- gmapM synthesizeAnns a
          return a
        located :: (Data b, Data loc) => GHC.GenLocated loc b -> RefactGhc (GHC.GenLocated loc b)
        located b@(GHC.L ss a) = case cast ss of
          Just (s :: GHC.SrcSpan) -> do
            --logm $ "Located found: " ++ (show $ toConstr a)
            anns <- fetchAnnsFinal
            let castRes = (GHC.L s a)
                ann = getAnnotationEP castRes anns
            --logm $ "Found ann: " ++ show ann
            case ann of
              Nothing -> do
                --logm "No ann found for located item"
                let newKey = mkAnnKey castRes
                    newAnns = Map.insert newKey annNone anns
                setRefactAnns newAnns
                return ()
              _ -> return ()
            _ <- gmapM synthesizeAnns b
            return b
          Nothing ->
            return b

-- This removes all the annotations associated with the given AST chunk.
removeAnns :: (Data a) => a -> RefactGhc a
removeAnns = generic `SYB.ext2M` located
  where generic :: Data a => a -> RefactGhc a
        generic a = do
          _ <- gmapM synthesizeAnns a
          return a
        located :: (Data b, Data loc) => GHC.GenLocated loc b -> RefactGhc (GHC.GenLocated loc b)
        located b@(GHC.L ss a) = case cast ss of
          Just (s :: GHC.SrcSpan) -> do
            anns <- fetchAnnsFinal
            let k = mkAnnKey (GHC.L s a)
            logm $ "Deleting ann at: " ++ (show s)
            setRefactAnns $ Map.delete k anns
            _ <- gmapM removeAnns b
            return b
          Nothing -> return b
         
--This takes in a located ast chunk and adds the provided keyword and delta position into the annsDP list
--If there is not annotation associated with the chunk nothing happens
addNewDP :: (Data a) => (KeywordId, DeltaPos) -> GHC.Located a -> RefactGhc ()
addNewDP entry a = do
  anns <- liftT getAnnsT
  let key = mkAnnKey a
      mAnn = Map.lookup key anns
  case mAnn of
    Nothing -> return ()
    (Just ann) -> do
      let newAnn = ann{annsDP = (entry:(annsDP ann))}
      setRefactAnns $ Map.insert key newAnn anns

addNewDPs :: (Data a) => [(KeywordId, DeltaPos)] -> GHC.Located a -> RefactGhc ()
addNewDPs entries a = mapM_ ((flip addNewDP) a) entries
           
replaceAtLocation :: (Data a) => GHC.SrcSpan -> GHC.Located a -> RefactGhc (GHC.ParsedSource)
replaceAtLocation span new = do
  logm $ "Span: " ++ (show span)
  parsed <- getRefactParsed
  newParsed <- SYB.everywhereM (SYB.mkM findLoc) parsed
  return newParsed
    where --findLoc :: (forall b. (Data b) => GHC.Located b -> RefactGhc (GHC.Located b))
          findLoc a@(GHC.L l s) = if l == span
                                  then do
                                    removeAnns s
                                    return new
                                  else return a

--Takes a piece of AST and adds a one row offset
addNewLines :: (Data a) => Int -> GHC.Located a -> RefactGhc ()
addNewLines n ast = do
  currAnns <- fetchAnnsFinal
  let key = mkAnnKey ast
      mv = Map.lookup key currAnns
  case mv of
    Nothing -> return ()
    Just v -> do
      let (DP (row,col)) = annEntryDelta v
          newDP = (DP (row+n,col))
          newAnn = v {annEntryDelta = newDP}
          newAnns = Map.insert key newAnn currAnns
      setRefactAnns newAnns

addSimpleImportDecl :: String -> RefactGhc ()
addSimpleImportDecl modName = do
  (GHC.L l parsedS) <- getRefactParsed
  let newImport = GHC.simpleImportDecl (GHC.mkModuleName modName)
      imports = GHC.hsmodImports parsedS
  l_import <- locate newImport
  currAnns <- fetchAnnsFinal
  let newAnn = annNone {annsDP = [(G GHC.AnnImport, DP (0,0))], annEntryDelta = (DP (1,0))} 
  putRefactParsed (GHC.L l (parsedS {GHC.hsmodImports = (l_import : imports)})) (Map.insert (mkAnnKey l_import) newAnn currAnns)
