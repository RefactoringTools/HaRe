{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Language.Haskell.Refact.Utils.GhcUtils where

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import GHC
import NameSet
import Control.Monad
import Data.Maybe

-- For Lens stuff
-- import Control.Lens
-- import Control.Applicative
import Data.Data

import Data.Generics.Strafunski.StrategyLib.StrategyLib

import qualified Data.Generics.Zipper as Z

-- TODO: pass this routine back to syb-utils (when it works properly)
-- Question: how to handle partial results in the otherwise step?
everythingButStaged :: SYB.Stage -> (r -> r -> r) -> r -> SYB.GenericQ (r,Bool) -> SYB.GenericQ r
everythingButStaged stage k z f x
  | checkItemStage stage x = z
  | stop == True = v
  | otherwise = foldl k v (gmapQ (everythingButStaged stage k z f) x)
  where (v, stop) = f x


{-
-- | Look up a subterm by means of a maybe-typed filter
something :: GenericQ (Maybe u) -> GenericQ (Maybe u)

-- "something" can be defined in terms of "everything"
-- when a suitable "choice" operator is used for reduction
--
something = everything orElse
-}

-- | Look up a subterm by means of a maybe-typed filter
somethingStaged :: SYB.Stage -> (Maybe u) -> SYB.GenericQ (Maybe u) -> SYB.GenericQ (Maybe u)

-- "something" can be defined in terms of "everything"
-- when a suitable "choice" operator is used for reduction
--
somethingStaged stage z = everythingStaged stage SYB.orElse z

-- ---------------------------------------------------------------------

{-
-- | Apply a monadic transformation at least somewhere
somewhere :: MonadPlus m => GenericM m -> GenericM m

-- We try "f" in top-down manner, but descent into "x" when we fail
-- at the root of the term. The transformation fails if "f" fails
-- everywhere, say succeeds nowhere.
--
somewhere f x = f x `mplus` gmapMp (somewhere f) x
-}

-- | Apply a monadic transformation at least somewhere
somewhereMStaged :: MonadPlus m => SYB.Stage -> SYB.GenericM m -> SYB.GenericM m

-- We try "f" in top-down manner, but descent into "x" when we fail
-- at the root of the term. The transformation fails if "f" fails
-- everywhere, say succeeds nowhere.
--
somewhereMStaged stage f x
  | checkItemStage stage x = mzero
  | otherwise = f x `mplus` gmapMp (somewhereMStaged stage f) x

-- ---------------------------------------------------------------------

-- | Monadic variation on everywhere
everywhereMStaged :: Monad m => SYB.Stage -> SYB.GenericM m -> SYB.GenericM m

-- Bottom-up order is also reflected in order of do-actions
everywhereMStaged stage f x
  | checkItemStage stage x = return x
  | otherwise = do x' <- gmapM (everywhereMStaged stage f) x
                   f x'


-- | Monadic variation on everywhere'
everywhereMStaged' :: Monad m => SYB.Stage -> SYB.GenericM m -> SYB.GenericM m

-- Top-down order is also reflected in order of do-actions
everywhereMStaged' stage f x
  | checkItemStage stage x = return x
  | otherwise = do x' <- f x
                   gmapM (everywhereMStaged' stage f) x'


-- ---------------------------------------------------------------------

everywhereStaged ::  SYB.Stage -> (forall a. Data a => a -> a) -> forall a. Data a => a -> a
everywhereStaged stage f x
  | checkItemStage stage x = x
  | otherwise = (f . gmapT (everywhereStaged stage f)) x

-- | Top-down version of everywhereStaged
everywhereStaged' ::  SYB.Stage -> (forall a. Data a => a -> a) -> forall a. Data a => a -> a
everywhereStaged' stage f x
  | checkItemStage stage x = x
  | otherwise = (gmapT (everywhereStaged stage f) . f) x

-- ---------------------------------------------------------------------

-- From @frsoares

-- | Checks whether the current item is undesirable for analysis in the current
-- AST Stage.
checkItemStage :: Typeable a => SYB.Stage -> a -> Bool
checkItemStage stage x = (const False `SYB.extQ` postTcType `SYB.extQ` fixity `SYB.extQ` nameSet) x
  where nameSet    = const (stage `elem` [SYB.Parser,SYB.TypeChecker]) :: NameSet        -> Bool
        postTcType = const (stage < SYB.TypeChecker                  ) :: GHC.PostTcType -> Bool
        fixity     = const (stage < SYB.Renamer                      ) :: GHC.Fixity     -> Bool

checkItemRenamer :: Typeable a => a -> Bool
checkItemRenamer x = checkItemStage SYB.Renamer x



-- | Staged variation of SYB.everything
-- The stage must be provided to avoid trying to modify elements which
-- may not be present at all stages of AST processing.
-- Note: Top-down order
everythingStaged :: SYB.Stage -> (r -> r -> r) -> r -> SYB.GenericQ r -> SYB.GenericQ r
everythingStaged stage k z f x
  | checkItemStage stage x = z
  | otherwise = foldl k (f x) (gmapQ (everythingStaged stage k z f) x)


-- | Staged variation of SYB.listify
-- The stage must be provided to avoid trying to modify elements which
-- may not be present at all stages of AST processing.
listifyStaged
  :: (Data a, Typeable a1) => SYB.Stage -> (a1 -> Bool) -> a -> [a1]
listifyStaged stage p = everythingStaged stage (++) [] ([] `SYB.mkQ` (\x -> [ x | p x ]))


-- ---------------------------------------------------------------------

-- Strafunski StrategyLib adaptations

-- ---------------------------------------------------------------------

-- | Full type-unifying traversal in top-down order.
full_tdTUGhc    :: (MonadPlus m, Monoid a) => TU a m -> TU a m
full_tdTUGhc s  =  op2TU mappend s (allTUGhc' (full_tdTUGhc s))

-- ---------------------------------------------------------------------
-- | Top-down type-unifying traversal that is cut of below nodes
--   where the argument strategy succeeds.
stop_tdTUGhc :: (MonadPlus m, Monoid a) => TU a m -> TU a m
-- stop_tdTUGhc s = ifTU checkItemRenamer' (const s) (s `choiceTU` (allTUGhc' (stop_tdTUGhc s)))
stop_tdTUGhc s = (s `choiceTU` (allTUGhc' (stop_tdTUGhc s)))




allTUGhc' :: (MonadPlus m, Monoid a) => TU a m -> TU a m
allTUGhc' = allTUGhc mappend mempty

-- | Top-down type-preserving traversal that performs its argument
--   strategy at most once.
once_tdTPGhc    :: MonadPlus m => TP m -> TP m
once_tdTPGhc s  =  s `choiceTP` (oneTPGhc (once_tdTPGhc s))

-- Succeed for one child; don't care about the other children
oneTPGhc          :: MonadPlus m => TP m -> TP m
-- oneTPGhc s      =  ifTP checkItemRenamer' (const s) (oneTP s)
oneTPGhc s         =  ifTP checkItemRenamer' (const failTP) (oneTP s)


------------------------------------------

-- This section courtesy of @jkoppel (James Koppel)
allTUGhc :: (MonadPlus m) => (a -> a -> a) -> a -> TU a m -> TU a m
allTUGhc op2 u s  = ifTU checkItemRenamer' (const $ constTU u) (allTU op2 u s)


checkItemStage' :: forall m. (MonadPlus m) => SYB.Stage -> TU () m
checkItemStage' stage = failTU `adhocTU` postTcType `adhocTU` fixity `adhocTU` nameSet
  where nameSet    = const (guard $ stage `elem` [SYB.Parser,SYB.TypeChecker]) :: NameSet -> m ()
        postTcType = const (guard $ stage<SYB.TypeChecker) :: GHC.PostTcType -> m ()
        fixity     = const (guard $ stage<SYB.Renamer) :: GHC.Fixity -> m ()

checkItemRenamer' :: (MonadPlus m) => TU () m
checkItemRenamer' = checkItemStage' SYB.Renamer

-- ---------------------------------------------------------------------

-- Scrap-your-zippers for ghc

-- | Apply a generic transformation everywhere in a bottom-up manner.
zeverywhereStaged :: (Typeable a) => SYB.Stage -> SYB.GenericT -> Z.Zipper a -> Z.Zipper a
zeverywhereStaged stage f z
  | checkZipperStaged stage z = z
  | otherwise = Z.trans f (Z.downT g z)
  where
    g z' = Z.leftT g (zeverywhereStaged stage f z')


-- | Open a zipper to the point where the Geneneric query passes.
-- returns the original zipper if the query does not pass (check this)
zopenStaged :: (Typeable a) => SYB.Stage -> SYB.GenericQ Bool -> Z.Zipper a -> [Z.Zipper a]
zopenStaged stage q z
  | checkZipperStaged stage z = []
  | Z.query q z = [z]
  | otherwise = reverse $ Z.downQ [] g z
  where
    g z' = (zopenStaged stage q z') ++ (Z.leftQ [] g z')

-- | Apply a generic monadic transformation once at the topmost
-- leftmost successful location, avoiding holes in the GHC structures
zsomewhereStaged :: (MonadPlus m) => SYB.Stage -> SYB.GenericM m -> Z.Zipper a -> m (Z.Zipper a)
zsomewhereStaged stage f z
  | checkZipperStaged stage z = return z
  | otherwise = Z.transM f z `mplus` Z.downM mzero (g . Z.leftmost) z
  where
    g z' = Z.transM f z `mplus` Z.rightM mzero (zsomewhereStaged stage f) z'


-- | Transform a zipper opened with a given generic query
transZ :: SYB.Stage -> SYB.GenericQ Bool -> (SYB.Stage -> Z.Zipper a -> Z.Zipper a) -> Z.Zipper a -> Z.Zipper a
transZ stage q t z
  | Z.query q z = t stage z
  | otherwise = z

-- | Monadic transform of a zipper opened with a given generic query
transZM :: Monad m
  => SYB.Stage
  -> SYB.GenericQ Bool
  -> (SYB.Stage -> Z.Zipper a -> m (Z.Zipper a))
  -> Z.Zipper a
  -> m (Z.Zipper a)
transZM stage q t z
  | Z.query q z = t stage z
  | otherwise = return z


checkZipperStaged :: SYB.Stage -> Z.Zipper a -> Bool
checkZipperStaged stage z
  | isJust maybeNameSet    = checkItemStage stage (fromJust maybeNameSet)
  | isJust maybePostTcType = checkItemStage stage (fromJust maybePostTcType)
  | isJust maybeFixity     = checkItemStage stage (fromJust maybeFixity)
  | otherwise = False
  where
    maybeNameSet ::  Maybe NameSet
    maybeNameSet = Z.getHole z

    maybePostTcType :: Maybe PostTcType
    maybePostTcType = Z.getHole z

    maybeFixity :: Maybe GHC.Fixity
    maybeFixity = Z.getHole z

-- ---------------------------------------------------------------------

-- | Climb the tree until a predicate holds
upUntil :: SYB.GenericQ Bool -> Z.Zipper a -> Maybe (Z.Zipper a)
upUntil q z
  | Z.query q z = Just z
  | otherwise = Z.upQ Nothing (upUntil q) z

-- ---------------------------------------------------------------------

-- | Up the zipper until a predicate holds, and then return the zipper
-- hole
findAbove :: (Data a) => (a -> Bool) -> Z.Zipper a -> Maybe a
findAbove cond z = do
    zu  <- upUntil (False `SYB.mkQ` cond) z
    res <- (Z.getHole zu)
    return res

-- ---------------------------------------------------------------------

-- | Open a zipper to the point where the Generic query passes,
-- returning the zipper and a value from the specific part of the
-- GenericQ that matched. This allows the components of the query to
-- return a specific transformation routine, to apply to the returned zipper
zopenStaged' :: (Typeable a)
  => SYB.Stage
  -> SYB.GenericQ (Maybe b)
  -> Z.Zipper a
  -> [(Z.Zipper a,b)]
zopenStaged' stage q z
  | checkZipperStaged stage z = []
  -- | Z.query q z = [z]
  | isJust zq = [(z,fromJust zq)]
  | otherwise = reverse $ Z.downQ [] g z
  where
    g z' = (zopenStaged' stage q z') ++ (Z.leftQ [] g z')

    zq = Z.query q z


-- | Open a zipper to the point where the Generic query passes,
-- and apply the transformation returned from the specific part of the
-- GenericQ that matched.
ztransformStagedM :: (Typeable a,Monad m)
  => SYB.Stage
  -> SYB.GenericQ (Maybe (SYB.Stage -> Z.Zipper a -> m (Z.Zipper a)))
  -> Z.Zipper a
  -> m (Z.Zipper a)
ztransformStagedM stage q z = do
    let zs = zopenStaged' stage q z
    z' <- case zs of
           [(zz,t)] -> t stage zz
           _        -> return z
    return z'



