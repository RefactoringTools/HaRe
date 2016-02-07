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

  , setAnnKeywordDP
  , clearPriorComments
  , balanceAllComments
  ) where

import qualified GHC           as GHC

import qualified Data.Generics as SYB

import Control.Monad

import Language.Haskell.GHC.ExactPrint.Transform
import Language.Haskell.GHC.ExactPrint.Types
-- import Language.Haskell.GHC.ExactPrint.Utils

import Language.Haskell.Refact.Utils.GhcUtils

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
    Just v  -> Map.insert (mkAnnKey new) v ans

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

-- |Change the @DeltaPos@ for a given @KeywordId@ if it appears in the
-- annotation for the given item.
setAnnKeywordDP :: (SYB.Data a) => GHC.Located a -> KeywordId -> DeltaPos -> Transform ()
setAnnKeywordDP la kw dp = modifyAnnsT changer
  where
    changer ans = case Map.lookup (mkAnnKey la) ans of
      Nothing -> ans
      Just an -> Map.insert (mkAnnKey la) (an {annsDP = map update (annsDP an)}) ans
    update (kw',dp')
      | kw == kw' = (kw',dp)
      | otherwise = (kw',dp')

-- ---------------------------------------------------------------------

-- |Remove any preceding comments from the given item
clearPriorComments :: (SYB.Data a) => GHC.Located a -> Transform ()
clearPriorComments la = do
  edp <- getEntryDPT la
  modifyAnnsT $ \ans ->
    case Map.lookup (mkAnnKey la) ans of
      Nothing -> ans
      Just an -> Map.insert (mkAnnKey la) (an {annPriorComments = [] }) ans
  setEntryDPT la edp

-- ---------------------------------------------------------------------

balanceAllComments :: SYB.Data a => GHC.Located a -> Transform (GHC.Located a)
balanceAllComments la
  -- Must be top-down
  = everywhereM' (SYB.mkM inMod
                     `SYB.extM` inExpr
                     `SYB.extM` inMatch
                     `SYB.extM` inStmt
                   ) la
  where
    inMod :: GHC.ParsedSource -> Transform (GHC.ParsedSource)
    inMod m = doBalance m

    inExpr :: GHC.LHsExpr GHC.RdrName -> Transform (GHC.LHsExpr GHC.RdrName)
    inExpr e = doBalance e

    inMatch :: (GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)) -> Transform (GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))
    inMatch m = doBalance m

    inStmt :: GHC.LStmt GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> Transform (GHC.LStmt GHC.RdrName (GHC.LHsExpr GHC.RdrName))
    inStmt s = doBalance s

    -- |Balance all comments between adjacent decls, as well as pushing all
    -- trailing comments to the right place.
    {-
    e.g., for

        foo = do
          return x
            where
               x = ['a'] -- do

        bar = undefined

    the "-- do" comment must end up in the trailing comments for "x = ['a']"
    -}
    doBalance t = do
      decls <- hsDecls t
      let
        go [] = return []
        go [x] = return [x]
        go (x1:x2:xs) = do
          balanceComments x1 x2
          go (x2:xs)
      _ <- go decls
      -- replaceDecls t decls'
      unless (null decls) $ moveTrailingComments t (last decls)
      return t

-- ---------------------------------------------------------------------
