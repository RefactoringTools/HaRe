{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE RankNTypes #-}
module Language.Haskell.Refact.Utils.ExactPrint
  (
    replace
  , replaceAnnKey
  , copyAnn
  ) where

import qualified GHC           as GHC

import qualified Data.Generics as SYB

import Language.Haskell.GHC.ExactPrint.Types

import qualified Data.Map as Map

-- ---------------------------------------------------------------------

-- ++AZ++:TODO: Move this to ghc-exactprint
-- |The annotations are keyed to the constructor, so if we replace a qualified
-- with an unqualified RdrName or vice versa we have to rebuild the key for the
-- appropriate annotation.
replaceAnnKey :: (SYB.Data old,SYB.Data new)
  => GHC.Located old -> GHC.Located new -> Anns -> Anns
replaceAnnKey old new ans =
  case Map.lookup (mkAnnKey old) ans of
    Nothing -> ans
    Just v ->  anns'
      where
        anns1 = Map.delete (mkAnnKey old) ans
        anns' = Map.insert (mkAnnKey new) v anns1


-- ---------------------------------------------------------------------

-- ++AZ++ TODO: migrate this to ghc-exactprint
copyAnn :: (SYB.Data old,SYB.Data new)
  => GHC.Located old -> GHC.Located new -> Anns -> Anns
copyAnn old new ans =
  case Map.lookup (mkAnnKey old) ans of
    Nothing -> ans
    Just v ->  anns'
      where
        anns' = Map.insert (mkAnnKey new) v ans

-- ---------------------------------------------------------------------

-- | Replaces an old expression with a new expression
replace :: AnnKey -> AnnKey -> Anns -> Maybe Anns
replace old new ans = do
  let as = ans
  oldan <- Map.lookup old as
  newan <- Map.lookup new as
  let newan' = Ann
                { annEntryDelta        = annEntryDelta oldan
                -- , annDelta             = annDelta oldan
                -- , annTrueEntryDelta    = annTrueEntryDelta oldan
                , annPriorComments     = annPriorComments oldan
                , annFollowingComments = annFollowingComments oldan
                , annsDP               = moveAnns (annsDP oldan) (annsDP newan)
                , annSortKey           = annSortKey oldan
                , annCapturedSpan      = annCapturedSpan oldan
                }
  return ((\anns -> Map.delete old . Map.insert new newan' $ anns) ans)

-- ---------------------------------------------------------------------

-- | Shift the first output annotation into the correct place
moveAnns :: [(KeywordId, DeltaPos)] -> [(KeywordId, DeltaPos)] -> [(KeywordId, DeltaPos)]
moveAnns [] xs        = xs
moveAnns ((_, dp): _) ((kw, _):xs) = (kw,dp) : xs
moveAnns _ []         = []

-- ---------------------------------------------------------------------
