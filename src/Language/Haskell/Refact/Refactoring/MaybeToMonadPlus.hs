{-# LANGUAGE ScopedTypeVariables, RankNTypes, AllowAmbiguousTypes #-}
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
import Data.Maybe

maybeToMonadPlus :: RefactSettings -> GM.Options -> FilePath -> SimpPos -> String -> IO [FilePath]
maybeToMonadPlus settings cradle fileName pos funNm = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings cradle (comp absFileName pos funNm)

comp :: FilePath -> SimpPos -> String -> RefactGhc [ApplyRefacResult]
comp fileName (row,col) funNm = do
  (refRes@((_fp,ismod), _),()) <- applyRefac (doMaybeToPlus fileName (row,col) funNm) (RSFile fileName)
  case ismod of
    RefacUnmodifed -> error "Maybe to MonadPlus synonym failed"
    RefacModified -> return ()
  return [refRes]
      

doMaybeToPlus :: FilePath -> SimpPos -> String -> RefactGhc ()  
doMaybeToPlus fileName pos@(row,col) funNm = do
  parsed <- getRefactParsed
  -- Add test that position defines function with name `funNm`
  let mBind = getHsBind pos funNm parsed
  case mBind of
    Nothing -> error "Function bind not found"
    Just funBind -> do
      hasNtoN <- containsNothingToNothing funNm pos funBind
      case hasNtoN of
        False -> return ()
        True -> do
          doRewriteAsBind fileName pos funNm
      logm $ "Result of searching for nothing to nothing: " ++ (show hasNtoN)
      return ()

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
    new_rhs <- createGRHS newNm lam_par
    replaceGRHS funNm new_rhs newNm
    prsed <- getRefactParsed
    logm $ "Final parsed: " ++ (SYB.showData SYB.Parser 3 prsed)
    currAnns <- fetchAnnsFinal
    logm $ "Final anns: " ++ (show currAnns)
    fixType funNm
    let monadModNm = GHC.mkModuleName "Control.Monad"
    finalParsed <- getRefactParsed
    newP <- addImportDecl finalParsed monadModNm Nothing False False False Nothing False []
    currAnns <- fetchAnnsFinal
    putRefactParsed newP currAnns
      where mkNewNm rdr = let str = GHC.occNameString $ GHC.rdrNameOcc rdr in
              GHC.Unqual $ GHC.mkVarOcc ("m_" ++ str)
              
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
          worker' :: GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc (GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName)) 
          worker' (GHC.GRHSs _ _) = do
            logm "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! worker'!!!!!!!!!!!!!!!!!!!!!!"
            return new_rhs
          fix_lhs :: GHC.MatchGroup GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc (GHC.MatchGroup GHC.RdrName (GHC.LHsExpr GHC.RdrName))
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
                        

wrapInLambda :: String -> GHC.LPat GHC.RdrName -> GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc (GHC.LHsExpr GHC.RdrName)
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
  latest <- fetchAnnsFinal
  let ppr = exactPrint par_lam latest
  --logm $ "Lambda ast: " ++ (SYB.showData SYB.Parser 3 l_lam)
  --logm $ "=========== PPR ===========: " ++ ppr
--  synthesizeAnns par_lam
  return par_lam
  

wrapInPars :: GHC.LHsExpr GHC.RdrName -> RefactGhc (GHC.LHsExpr GHC.RdrName)
wrapInPars expr = do
  newAst <- locate (GHC.HsPar expr)
  let dp = [(G GHC.AnnOpenP, DP (0,1)), (G GHC.AnnCloseP, DP (0,0))]
      newAnn = annNone {annsDP = dp}
  addAnn newAst newAnn
  return newAst

createGRHS :: GHC.RdrName -> GHC.LHsExpr GHC.RdrName -> RefactGhc (GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName))
createGRHS name lam_par = do
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

addEmptyAnn :: (Data a) => GHC.Located a -> RefactGhc ()
addEmptyAnn a = addAnn a annNone

addAnnVal :: (Data a) => GHC.Located a -> RefactGhc ()
addAnnVal a = addAnn a valAnn
  where valAnn = annNone {annEntryDelta = DP (0,1), annsDP = [(G GHC.AnnVal, DP (0,0))]}

addAnn :: (Data a) => GHC.Located a -> Annotation -> RefactGhc ()
addAnn a ann = do
  currAnns <- fetchAnnsFinal
  let k = mkAnnKey a
  setRefactAnns $ Map.insert k ann currAnns

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

lookupAllAnns :: Anns -> [GHC.Located a] -> Anns
lookupAllAnns anns [] = emptyAnns
lookupAllAnns anns ((GHC.L l _):xs) = (lookupAnns anns l) `Map.union` (lookupAllAnns anns xs)

locate :: a -> RefactGhc (GHC.Located a)
locate ast = do
  loc <- liftT uniqueSrcSpanT
  return (GHC.L loc ast)

zeroDP :: (Data a) => GHC.Located a -> RefactGhc ()
zeroDP ast = do
  currAnns <- fetchAnnsFinal
  let k = mkAnnKey ast
      mv = Map.lookup k currAnns
  case mv of
    Nothing -> return ()
    Just v -> addAnn ast (v {annEntryDelta = DP (0,0)})

getVarAndRHS :: GHC.Match GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc (GHC.LPat GHC.RdrName, GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName))
getVarAndRHS match = do
  let (Just pat) = SYB.something (Nothing `mkQ` varPat) (GHC.m_pats match)
  return (pat , GHC.m_grhss match)
    where varPat lPat@(GHC.L _ (GHC.VarPat _ )) = Just lPat
          varPat _ = Nothing

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
--If the Nothing to Nothing case is found then it is removed from the parsed source
containsNothingToNothing :: String -> SimpPos -> GHC.HsBind GHC.RdrName -> RefactGhc Bool
containsNothingToNothing funNm pos a = do
  dFlags <- GHC.getSessionDynFlags
  let nToNStr = funNm ++ " Nothing = Nothing"
  (_, pRes) <- handleParseResult "containsNothingToNothing" $ parseDecl dFlags "MaybeToMonad.hs" nToNStr
  let [match] = extractMatches pRes
      c1 = constructComp match
      matches = extractMatches a
      comps = map constructComp matches
      zipped = zip [0..] comps
      filtered = filter (\(_,c2) -> c2 == c1) zipped
  case filtered of
    [] -> return False
    [(i,_)] -> do
      let newMatches = dropI i matches
          oldMatch = matches !! i          
      moveMatchesUp newMatches
      let newMG = (GHC.fun_matches a) {GHC.mg_alts = newMatches}
          newBind = a{GHC.fun_matches = newMG}
      removeMatch pos newBind oldMatch
      return True
    where
      extractMatches :: (Data (a b)) => a b -> [(GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))]
      extractMatches = SYB.everything (++) ([] `SYB.mkQ` isMatch)
      isMatch :: (GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)) -> [(GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))]
      isMatch m@(GHC.L _ (GHC.Match _ _ _ _)) = [m]
      dropI i lst = let (xs,ys) = splitAt i lst in xs ++ (tail ys)

moveMatchesUp :: (Data a) => [GHC.LMatch GHC.RdrName a] -> RefactGhc ()
moveMatchesUp = mapM_ moveMatchLine
  where moveMatchLine :: (Data a) => GHC.LMatch GHC.RdrName a -> RefactGhc ()
        moveMatchLine m = do
          currAnns <- fetchAnnsFinal
          let k = mkAnnKey m
              mAnn = Map.lookup k currAnns
          case mAnn of
            Nothing -> return ()
            Just ann -> do
              let (DP (row,col)) = annEntryDelta ann
              setRefactAnns $ Map.insert k (ann {annEntryDelta = DP (row-1,col)}) currAnns
              return ()
          return ()

-- Removes the given match from the given binding
removeMatch :: SimpPos -> GHC.HsBind GHC.RdrName -> GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc ()
removeMatch pos newBind old@(GHC.L l oldMatch) = do
  parsed <- getRefactParsed
  let rdrNm = gfromJust "Couldn't get rdrName in replaceBind" $ locToRdrName pos parsed
  newParsed <- SYB.everywhereMStaged SYB.Parser (SYB.mkM (replaceBind rdrNm)) parsed
  currAnns <- fetchAnnsFinal
  let oldKey = mkAnnKey old
      newAnns = Map.delete oldKey currAnns
  setRefactAnns newAnns
  (liftT getAnnsT) >>= putRefactParsed newParsed
  _ <- removeAnns old
  curr <- fetchAnnsFinal
  logm $ "Making sure anns are changed by remove: " ++ (show (curr == newAnns))
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

fixType :: String -> RefactGhc ()
fixType funNm = do
  parsed <- getRefactParsed
  currAnns <- fetchAnnsFinal
  dFlags <- GHC.getSessionDynFlags
  let m_sig = getSigD parsed
      (GHC.L sigL (GHC.SigD sig)) = fromJust m_sig
      iType = fromJust $ getInnerType sig
      strTy = exactPrint iType currAnns
      tyStr = funNm ++ " :: (MonadPlus m) => m" ++ strTy ++ " -> m" ++ strTy
      pRes = parseDecl dFlags "MaybeToMonadPlus.hs" tyStr
  logm $ "Type string: " ++ tyStr
  (anns, newSig) <- handleParseResult "MaybeToMonadPlus.fixType" pRes
  newParsed <- replaceAtLocation sigL newSig
  let newAnns = Map.union currAnns anns
  putRefactParsed newParsed newAnns
  addNewLines 2 newSig
    where getSigD :: (Data a) => a -> Maybe (GHC.LHsDecl GHC.RdrName)
          getSigD = SYB.everything (<|>) (Nothing `SYB.mkQ` isSigD)
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
         
            
replaceAtLocation :: (Data a) => GHC.SrcSpan -> GHC.Located a -> RefactGhc (GHC.ParsedSource)
replaceAtLocation span new = do
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
