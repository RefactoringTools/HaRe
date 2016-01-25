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

maybeToMonadPlus :: RefactSettings -> GM.Options -> FilePath -> SimpPos -> String -> IO [FilePath]
maybeToMonadPlus settings cradle fileName pos funNm = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings cradle (comp absFileName pos funNm)

comp :: FilePath -> SimpPos -> String -> RefactGhc [ApplyRefacResult]
comp fileName (row,col) funNm = do
  let nToNStr = funNm ++ " Nothing = Nothing"
  logm $ "The n to n string is: " ++ nToNStr
  dFlags <- GHC.getInteractiveDynFlags
  {-let (Right (_ , (GHC.L _ a))) :: (Either (GHC.SrcSpan, String)
                          (Anns, GHC.LHsDecl GHC.RdrName)) = parseDecl dFlags fileName nToNStr -}
  let pres =  parseDecl dFlags fileName nToNStr
  logm "After first parse"
  {-
  let c1 :: [(Compare GHC.RdrName)] = constructCompare a
      (Right (_ , (GHC.L _ b))) :: (Either (GHC.SrcSpan, String)
                                    (Anns, GHC.LHsDecl GHC.RdrName)) = parseDecl dFlags fileName nToNStr
      c2 :: [(Compare GHC.RdrName)] = constructCompare b
  logm $ "Compare: " ++ (show (c1 == c2))
    -}  
  return []
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
