{-# LANGUAGE  FlexibleContexts, ScopedTypeVariables #-}
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
import qualified Outputable as GHC
import Control.Applicative

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
      hasNtoN <- containsNothingToNothing funNm funBind
      return ()
  {-
  let (Right (_ , (GHC.L _ a))) :: (Either (GHC.SrcSpan, String) (Anns, GHC.LHsDecl GHC.RdrName))
        = parseDecl dFlags fileName nToNStr
      c1 :: [(Compare GHC.RdrName)] = constructCompare a
      (Right (_ , (GHC.L _ b))) :: (Either (GHC.SrcSpan, String) (Anns, GHC.LHsDecl GHC.RdrName))
        = parseDecl dFlags "OtherNm.hs" nToNStr
      c2 :: [(Compare GHC.RdrName)] = constructCompare b
  logm $ "Compare: " ++ (show (c1 == c2))  -}


getHsBind :: (Data a) => SimpPos -> String -> a -> Maybe (GHC.HsBind GHC.RdrName)
getHsBind pos funNm a =
  let rdrNm = locToRdrName pos a in
  case rdrNm of
  Nothing -> Nothing
  (Just (GHC.L _ rNm)) -> SYB.everythingStaged SYB.Parser (<|>) Nothing (Nothing `SYB.mkQ` isBind) a
    where isBind (bnd@(GHC.FunBind (GHC.L _ name) _ _ _ _ _) :: GHC.HsBind GHC.RdrName)
            | name == rNm = (Just bnd)
          isBind _ = Nothing

containsNothingToNothing :: String -> GHC.HsBind GHC.RdrName -> RefactGhc Bool
containsNothingToNothing funNm a = do
  dFlags <- GHC.getSessionDynFlags
  let nToNStr = funNm ++ " Nothing = Nothing"
  (_, pRes) <- handleParseResult "containsNothingToNothing" $ parseDecl dFlags "MaybeToMonad.hs" nToNStr
  let (Just match) = extractMatch pRes
      c1 = constructCompare match
      res = SYB.everythingStaged SYB.Parser (||) False (False `SYB.mkQ` (isNToNMatch c1)) a
  return res
    where
      extractMatch :: (Data (a b)) => a b -> Maybe (GHC.Match GHC.RdrName GHC.RdrName)
      extractMatch = SYB.everythingStaged SYB.Parser (<|>) Nothing (Nothing `SYB.mkQ` (\ m@(GHC.Match _ _ _ _)-> Just m))
      --isNToNMatch :: (Data (a b), Eq b, Data b) => [Compare GHC.RdrName] -> a b -> Bool
      isNToNMatch c1 (m2@(GHC.Match _ _ _ _)) =
        let c2 = constructCompare m2 in
        c1 == c2

handleParseResult :: String -> Either (GHC.SrcSpan, String) (Anns, a) -> RefactGhc (Anns, a)
handleParseResult msg e = case e of
  (Left (_, errStr)) -> error $ "The parse from: " ++ msg ++ " with error: " ++ errStr
  (Right res) -> return res
{-
containsNothingToNothing :: String -> GHC.HsBindLR GHC.RdrName GHC.RdrName -> RefactGhc Bool
containsNothingToNothing fname fBind@(GHC.FunBind _ _ _ _ _ _) = do
  
  let res = SYB.everythingStaged SYB.Parser (||) False (SYB.mkQ False findNothingToNothing) $ fBind
  --let res = filter isNothingMatch matches
  return False
  where
   findNothingToNothing :: (GHC.Match GHC.RdrName (GHC.LHsExpr GHC.RdrName)) -> Bool
   findNothingToNothing (GHC.Match _ [pat] _ grhs) =
     False
containsNothingToNothing _ _ = return False
 

isNothingMatch :: (Typeable id, Typeable body, DataId id, Data body) => GHC.LMatch id body -> Bool
isNothingMatch (GHC.L _ (GHC.Match _ [pat] _ grhs)) =
  nothingPat pat && nothingExpr grhs
  where
    nothingPat = SYB.everything (||) (SYB.mkQ False isNothingPat)
    isNothingPat 
    nothingExpr = SYB.everything (||) (SYB.mkQ False (\i -> False)) 
-}
