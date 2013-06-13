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
import Control.Applicative
import Data.Data

import Unsafe.Coerce

import Data.Generics.Strafunski.StrategyLib.StrategyLib

import Data.Generics.Zipper

{-

From Data.Generics

-- | Summarise all nodes in top-down, left-to-right order
everything :: (r -> r -> r) -> GenericQ r -> GenericQ r

-- Apply f to x to summarise top-level node;
-- use gmapQ to recurse into immediate subterms;
-- use ordinary foldl to reduce list of intermediate results
--
everything k f x = foldl k (f x) (gmapQ (everything k f) x)

-- | A variation of 'everything', using a 'GenericQ Bool' to skip
--   parts of the input 'Data'.
everythingBut :: GenericQ Bool -> (r -> r -> r) -> r -> GenericQ r -> GenericQ r
everythingBut q k z f x
 | q x       = z
 | otherwise = foldl k (f x) (gmapQ (everythingBut q k z f) x)



-- From GHC SYB Utils
-- | Like 'everything', but avoid known potholes, based on the 'Stage' that
--   generated the Ast.
everythingStaged :: Stage -> (r -> r -> r) -> r -> GenericQ r -> GenericQ r
everythingStaged stage k z f x
  | (const False `extQ` postTcType `extQ` fixity `extQ` nameSet) x = z
  | otherwise = foldl k (f x) (gmapQ (everythingStaged stage k z f) x)
  where nameSet    = const (stage `elem` [Parser,TypeChecker]) :: NameSet -> Bool
        postTcType = const (stage<TypeChecker)                 :: PostTcType -> Bool
        fixity     = const (stage<Renamer)                     :: GHC.Fixity -> Bool


-}

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

{-
-- | Apply a transformation everywhere in bottom-up manner
everywhere :: (forall a. Data a => a -> a)
           -> (forall a. Data a => a -> a)

-- Use gmapT to recurse into immediate subterms;
-- recall: gmapT preserves the outermost constructor;
-- post-process recursively transformed result via f
--
everywhere f = f . gmapT (everywhere f)
-}

everywhereStaged ::  SYB.Stage -> (forall a. Data a => a -> a) -> forall a. Data a => a -> a
everywhereStaged stage f x
  | checkItemStage stage x = x
  | otherwise = (f . gmapT (everywhereStaged stage f)) x

-- | Top-down version of everywhereStaged
everywhereStaged' ::  SYB.Stage -> (forall a. Data a => a -> a) -> forall a. Data a => a -> a
everywhereStaged' stage f x
  | checkItemStage stage x = x
  | otherwise = (gmapT (everywhereStaged stage f) . f) x

{-
-- Arguments of (.) are flipped compared to everywhere
everywhere' f = gmapT (everywhere' f) . f
-}



-- ---------------------------------------------------------------------
{-
-- From SYB

-- | Monadic variation on everywhere
everywhereM :: Monad m => GenericM m -> GenericM m

-- Bottom-up order is also reflected in order of do-actions
everywhereM f x = do x' <- gmapM (everywhereM f) x
                     f x'
-}

-- ---------------------------------------------------------------------

{-
-- | Apply a transformation everywhere in top-down manner
everywhere' :: (forall a. Data a => a -> a)
            -> (forall a. Data a => a -> a)

-- Arguments of (.) are flipped compared to everywhere
everywhere' f = gmapT (everywhere' f) . f
-}
{-
-- | Apply a transformation everywhere in top-down manner
everywhere' :: (forall a. Data a => a -> a)
            -> (forall a. Data a => a -> a)

-- Arguments of (.) are flipped compared to everywhere
everywhere' f = gmapT (everywhere' f) . f
-}



-- ---------------------------------------------------------------------
-- Lens stuff

-- | Naïve 'Traversal' using 'Data', avoiding GHC holes for
-- ParsedSource. This does not attempt to optimize the traversal.
--
--
-- @
-- 'ghcplate' :: ('Data' a, 'Typeable' b) => 'Simple' 'Traversal' a b
-- @
--ghcplate ::
--  (Data a, Typeable b, Applicative c) => (b -> c b) -> a -> c a
{-
ghcplate :: (Data a, Typeable a, Typeable b) => Simple Traversal a b
ghcplate f = gfoldl (stepghc f) pure
{-# INLINE ghcplate #-}

stepghc ::
  (Data d, Typeable b, Applicative f) =>
  (b -> f b) -> f (d -> e) -> d -> f e
stepghc f w d
  | isGhcHole d = ($d) <$> w
  | otherwise = w <*> case cast d of
      Just b  -> unsafeCoerce <$> f b
      Nothing -> ghcplate f d

isGhcHole :: Typeable a => a -> Bool
isGhcHole t = (isNameSet t) || (isPostTcType t) || (isFixity t)
  where
    isNameSet n = case (cast n)::(Maybe NameSet) of
      Just _ -> True
      Nothing -> False

    isPostTcType n = case (cast n)::(Maybe PostTcType) of
      Just _ -> True
      Nothing -> False

    isFixity n = case (cast n)::(Maybe GHC.Fixity) of
      Just _ -> True
      Nothing -> False
-}

-- gfoldl :: Data a =>
-- (forall d b. Data d => c (d -> b) -> d -> c b) -- nonempty constructor (immediate subterm)
-- -> (forall g. g -> c g)                        -- empty constructor
-- -> a                                           -- thing to be folded
-- -> c a
--


-- From frsoares

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


-- listify :: Typeable r => (r -> Bool) -> GenericQ [r]
-- listify p = everything (++) ([] `mkQ` (\x -> if p x then [x] else []))

-- | Staged variation of SYB.listify
-- The stage must be provided to avoid trying to modify elements which
-- may not be present at all stages of AST processing.
listifyStaged
  :: (Data a, Typeable a1) => SYB.Stage -> (a1 -> Bool) -> a -> [a1]
listifyStaged stage p = everythingStaged stage (++) [] ([] `SYB.mkQ` (\x -> [ x | p x ]))


-- ---------------------------------------------------------------------

-- Strafunski StrategyLib adaptations

{- ++AZ++ James Koppel version, out for now -}
-- ---------------------------------------------------------------------

-- | Full type-unifying traversal in top-down order.
full_tdTUGhc 	:: (MonadPlus m, Monoid a) => TU a m -> TU a m
full_tdTUGhc s	=  op2TU mappend s (allTUGhc' (full_tdTUGhc s))


{- original
-- | Full type-unifying traversal in top-down order.
full_tdTU 	:: (Monad m, Monoid a) => TU a m -> TU a m
full_tdTU s	=  op2TU mappend s (allTU' (full_tdTU s))
-}

-- ---------------------------------------------------------------------
-- | Top-down type-unifying traversal that is cut of below nodes
--   where the argument strategy succeeds.
stop_tdTUGhc :: (MonadPlus m, Monoid a) => TU a m -> TU a m
-- stop_tdTUGhc s = ifTU checkItemRenamer' (const s) (s `choiceTU` (allTUGhc' (stop_tdTUGhc s)))
stop_tdTUGhc s = (s `choiceTU` (allTUGhc' (stop_tdTUGhc s)))




allTUGhc' :: (MonadPlus m, Monoid a) => TU a m -> TU a m
allTUGhc' = allTUGhc mappend mempty

{- original
-- | Top-down type-unifying traversal that is cut of below nodes
--   where the argument strategy succeeds.
stop_tdTU 	:: (MonadPlus m, Monoid a) => TU a m -> TU a m
stop_tdTU s	=  s `choiceTU` (allTU' (stop_tdTU s))

allTU' 		:: (Monad m, Monoid a) => TU a m -> TU a m
allTU'		=  allTU mappend mempty
-}

{- original
-- | Top-down type-preserving traversal that performs its argument
--   strategy at most once.
once_tdTP 	:: MonadPlus m => TP m -> TP m
once_tdTP s	=  s `choiceTP` (oneTP (once_tdTP s))

-- Succeed for one child; don't care about the other children
oneTP 	   :: MonadPlus m => TP m -> TP m
oneTP s	   =  MkTP (gmapMo (applyTP s))
-}

-- | Top-down type-preserving traversal that performs its argument
--   strategy at most once.
once_tdTPGhc 	:: MonadPlus m => TP m -> TP m
once_tdTPGhc s	=  s `choiceTP` (oneTPGhc (once_tdTPGhc s))

-- Succeed for one child; don't care about the other children
oneTPGhc 	   :: MonadPlus m => TP m -> TP m
-- oneTPGhc s	   =  ifTP checkItemRenamer' (const s) (oneTP s)
oneTPGhc s	   =  ifTP checkItemRenamer' (const failTP) (oneTP s)


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

{-  ++AZ++  -}


{-
-- ++AZ++ old version
-- ---------------------------------------------------------------------

-- Strafunski StrategyLib adaptations

-- Example being chased
-- hsFreeAndDeclared'= applyTU (stop_tdTU (failTU `adhocTU` expr) t

-- Starting point down the rabbit hole of checkItemStage
-- | Top-down type-unifying traversal that is cut of below nodes
-- where the argument strategy succeeds.
stop_tdTUGhc :: (MonadPlus m, Monoid a) => TU a m -> TU a m
stop_tdTUGhc s = s `choiceTU` (allTUGhc' (stop_tdTUGhc s))


allTUGhc :: (Monad m, Monoid a) => (a -> a -> a) -> a -> TU a m -> TU a m
allTUGhc op2 u s = MkTU (\x -> case (checkItemRenamer x) of
                                  True -> do return (u) -- `op2` s)
                                  False -> fold (gmapQ (applyTU s) x)
                          )
  where
    fold l = foldM op2' u l
    op2' x c = c >>= \y -> return (x `op2` y)


-- This is the one that needs checkItemStage
{- ++ Original (reamed to avoid clash)
allTUGhc :: Monad m => (a -> a -> a) -> a -> TU a m -> TU a m
allTUGhc op2 u s = MkTU (\x -> fold (gmapQ (applyTU s) x))
where
fold l = foldM op2' u l
op2' x c = c >>= \y -> return (x `op2` y)
-}

-- Hence this one too
allTUGhc' :: (Monad m, Monoid a) => TU a m -> TU a m
allTUGhc' = allTUGhc mappend mempty

-- hsVisiblePNs e t = applyTU (full_tdTU (constTU [] `adhocTU` top

-- | Full type-unifying traversal in top-down order.
full_tdTUGhc :: (Monad m, Monoid a) => TU a m -> TU a m
full_tdTUGhc s = op2TU mappend s (allTUGhc' (full_tdTUGhc s))


-}

-- ---------------------------------------------------------------------

-- Scrap-your-zippers for ghc

{-
Original versions

-- | Apply a generic transformation everywhere in a bottom-up manner.
zeverywhere :: GenericT -> Zipper a -> Zipper a
zeverywhere f z = trans f (downT g z) where
  g z' = leftT g (zeverywhere f z')
-}
-- | Apply a generic transformation everywhere in a bottom-up manner.
zeverywhereStaged :: (Typeable a) => SYB.Stage -> SYB.GenericT -> Zipper a -> Zipper a
zeverywhereStaged stage f z
  | checkZipperStaged stage z = z
  | otherwise = trans f (downT g z)
  where
    g z' = leftT g (zeverywhereStaged stage f z')

{-
-- | Apply a generic transformation everywhere in a top-down manner.
zeverywhere' :: GenericT -> Zipper a -> Zipper a
zeverywhere' f z =
  downQ (g x) (zeverywhere' f . leftmost) x where
    x = trans f z
    g z' = rightQ (upQ z' g z') (zeverywhere' f) z'

-- | Apply a generic monadic transformation once at the topmost leftmost successful location.
zsomewhere :: (MonadPlus m) => GenericM m -> Zipper a -> m (Zipper a)
zsomewhere f z = transM f z `mplus` downM mzero (g . leftmost) z where
  g z' = transM f z `mplus` rightM mzero (zsomewhere f) z'
-}

-- | Open a zipper to the point where the Geneneric query passes.
-- returns the original zipper if the query does not pass (check this)
zopenStaged :: (Typeable a) => SYB.Stage -> SYB.GenericQ Bool -> Zipper a -> Zipper a
zopenStaged stage t z
  | checkZipperStaged stage z = z
  | query t z  = z
  | otherwise = trans id (downT g z)
  where
    g z' = leftT g (zopenStaged stage t z')


-- | Apply a generic monadic transformation once at the topmost
-- leftmost successful location, avoiding holes in the GHC structures
zsomewhereStaged :: (MonadPlus m) => SYB.Stage -> SYB.GenericM m -> Zipper a -> m (Zipper a)
zsomewhereStaged stage f z
  | checkZipperStaged stage z = return z
  | otherwise = transM f z `mplus` downM mzero (g . leftmost) z
  where
    g z' = transM f z `mplus` rightM mzero (zsomewhereStaged stage f) z'



--  TODO: ++AZ++ : carry on here: use transMZ not transM
-- | Apply a generic monadic zipper transformation once at the topmost
-- leftmost successful location, avoiding holes in the GHC structures
zsomewhereStagedZ :: (MonadPlus m) => SYB.Stage -> SYB.GenericM m -> Zipper a -> m (Zipper a)
zsomewhereStagedZ stage f z
  | checkZipperStaged stage z = return z
  | otherwise = transM f z `mplus` downM mzero (g . leftmost) z
  where
    g z' = transM f z `mplus` rightM mzero (zsomewhereStaged stage f) z'

-- We need f to have type
-- f :: Zipper a -> (b -> m b) -> Zipper a
-- f z ff

{-
transMZ ::
  (Monad m,Data a) => SYB.GenericM m -> Zipper a -> m (Zipper a)
transMZ f z = do
  z' <- f z
  return z'
-}

{-
transMZ ::
  (Monad m, Typeable b) =>
  (Zipper a -> Maybe b -> m (Zipper a)) -> Zipper a -> m (Zipper a)
transMZ f z = do
  z' <- f z (getHole z)
  return z'
-}

{-
-- | Apply a generic monadic transformation to the hole
transM :: (Monad m) => GenericM m -> Zipper a -> m (Zipper a)
transM f (Zipper hole ctxt) = do
  hole' <- f hole
  return (Zipper hole' ctxt)

-- | Apply a generic query to the hole.
query :: GenericQ b -> Zipper a -> b
query  f (Zipper hole _ctxt) = f hole

type SYB.GenericM m = Data a => a -> m a

SYB.mkM ::
  (Monad m, Typeable a, Typeable b) => (b -> m b) -> a -> m a
mkM = extM return

-- | Extend a generic monadic transformation by a type-specific case
extM :: ( Monad m
        , Typeable a
        , Typeable b
        )
     => (a -> m a) -> (b -> m b) -> a -> m a
extM def ext = unM ((M def) `ext0` (M ext))

-- | Flexible type extension
ext0 :: (Typeable a, Typeable b) => c a -> c b -> c a
ext0 def ext = maybe def id (gcast ext)

-- | The type constructor for transformations
newtype M m x = M { unM :: x -> m x }

-}


checkZipperStaged :: SYB.Stage -> Zipper a -> Bool
checkZipperStaged stage z
  | isJust maybeNameSet    = checkItemStage stage (fromJust maybeNameSet)
  | isJust maybePostTcType = checkItemStage stage (fromJust maybePostTcType)
  | isJust maybeFixity     = checkItemStage stage (fromJust maybeFixity)
  | otherwise = False
  where
    maybeNameSet ::  Maybe NameSet
    maybeNameSet = getHole z

    maybePostTcType :: Maybe PostTcType
    maybePostTcType = getHole z

    maybeFixity :: Maybe GHC.Fixity
    maybeFixity = getHole z


{-
everywhereStaged ::  SYB.Stage -> (forall a. Data a => a -> a) -> forall a. Data a => a -> a
everywhereStaged stage f x
  | checkItemStage stage x = x
  | otherwise = (f . gmapT (everywhereStaged stage f)) x

-- From GHC SYB Utils
-- | Like 'everything', but avoid known potholes, based on the 'Stage' that
--   generated the Ast.
everythingStaged :: Stage -> (r -> r -> r) -> r -> GenericQ r -> GenericQ r
everythingStaged stage k z f x
  | (const False `extQ` postTcType `extQ` fixity `extQ` nameSet) x = z
  | otherwise = foldl k (f x) (gmapQ (everythingStaged stage k z f) x)
  where nameSet    = const (stage `elem` [Parser,TypeChecker]) :: NameSet -> Bool
        postTcType = const (stage<TypeChecker)                 :: PostTcType -> Bool
        fixity     = const (stage<Renamer)                     :: GHC.Fixity -> Bool

-}
