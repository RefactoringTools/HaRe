{-# LANGUAGE ScopedTypeVariables #-}
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
    new_rhs <- createGRHS lam_par
    replaceGRHS funNm new_rhs

replaceGRHS :: String -> (GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName)) -> RefactGhc ()
replaceGRHS funNm new_rhs = do
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
              return $ fb{GHC.fun_matches = new_matches}
          worker bind = return bind
          worker' :: GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc (GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName)) 
          worker' (GHC.GRHSs _ _) = do
            logm "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! worker'!!!!!!!!!!!!!!!!!!!!!!"
            return new_rhs
            

wrapInLambda :: String -> GHC.LPat GHC.RdrName -> GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc (GHC.LHsExpr GHC.RdrName)
wrapInLambda funNm varPat rhs = do
  let gen_rhs = justToReturn rhs
  match@(GHC.L l match') <- mkMatch varPat gen_rhs
  --logm $ "Match: " ++ (SYB.showData SYB.Parser 3 match) 
  let mg = GHC.MG [match] [] GHC.PlaceHolder GHC.Generated
  currAnns <- fetchAnnsFinal
  logm $ "Anns :" ++ (show $ getAllAnns currAnns match)
  let l_lam = (GHC.L l (GHC.HsLam mg))
  let ppr = exactPrint l_lam currAnns
  
  logm $ "=========== PPR ===========: " ++ ppr
  return l_lam
  

createGRHS :: GHC.LHsExpr GHC.RdrName -> RefactGhc (GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName))
createGRHS lam_par = do
  bind_occ <- locate $ GHC.HsVar (GHC.Unqual (GHC.mkDataOcc ">>="))
  l_section <- locate $ GHC.SectionR bind_occ lam_par
  l_par <- locate $ GHC.HsPar l_section
  lgrhs <- locate $ GHC.GRHS [] l_par
  return $ GHC.GRHSs [lgrhs] GHC.EmptyLocalBinds
  
justToReturn :: (Data a) => a -> a
justToReturn ast = SYB.everywhere (SYB.mkT worker) ast
  where worker :: GHC.OccName -> GHC.OccName
        worker nm = let just = GHC.mkDataOcc "Just" in
          if nm == just
          then GHC.mkDataOcc "return"
          else nm

mkMatch :: GHC.LPat GHC.RdrName -> GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc (GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))
mkMatch varPat rhs =  locate (GHC.Match Nothing [varPat] Nothing rhs)

lookupAllAnns :: Anns -> [GHC.Located a] -> Anns
lookupAllAnns anns [] = emptyAnns
lookupAllAnns anns ((GHC.L l _):xs) = (lookupAnns anns l) `Map.union` (lookupAllAnns anns xs)

locate :: a -> RefactGhc (GHC.Located a)
locate ast = do
  loc <- liftT uniqueSrcSpanT
  return (GHC.L loc ast)


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
          newMG = (GHC.fun_matches a) {GHC.mg_alts = newMatches}
          newBind = a{GHC.fun_matches = newMG}
      removeMatch pos newBind oldMatch
      return True
    where
      extractMatches :: (Data (a b)) => a b -> [(GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))]
      extractMatches = SYB.everything (++) ([] `SYB.mkQ` isMatch)
      isMatch :: (GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)) -> [(GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))]
      isMatch m@(GHC.L _ (GHC.Match _ _ _ _)) = [m]
      dropI i lst = let (xs,ys) = splitAt i lst in xs ++ (tail ys)


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
     
