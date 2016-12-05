{-# LANGUAGE CPP #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Language.Haskell.Refact.Utils.Query where
--This module contains functions that retrieve sections of the ast. It is fairly high level.

import qualified GHC as GHC
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.Synonyms
import Language.Haskell.Refact.Utils.Types
import Language.Haskell.Refact.Utils.TypeUtils
import Data.Generics as SYB
import GHC.SYB.Utils as SYB
import Control.Applicative
import FastString
import RdrName

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
    where
#if __GLASGOW_HASKELL__ <= 710
        isBind (bnd@(GHC.FunBind (GHC.L _ name) _ _ _ _ _) :: GHC.HsBind GHC.RdrName)
#else
        isBind (bnd@(GHC.FunBind (GHC.L _ name) _ _ _ _) :: GHC.HsBind GHC.RdrName)
#endif
            | name == rNm = (Just bnd)
        isBind _ = Nothing

--It's common to want to know if an expression is just a certain var
--This function takes a String of the var and returns true of the given expression represents that var
isHsVar :: String -> ParsedExpr -> Bool
#if __GLASGOW_HASKELL__ <= 710
isHsVar str (GHC.HsVar rNm) =
#else
isHsVar str (GHC.HsVar (GHC.L _ rNm)) =
#endif
  let nm = mkVarUnqual (fsLit str) in
    rNm == nm
isHsVar _ _ = False
