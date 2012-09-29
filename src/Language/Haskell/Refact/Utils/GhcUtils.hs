{-# LANGUAGE RankNTypes #-}
module Language.Haskell.Refact.Utils.GhcUtils where


import Data.Generics
import GHC
import GHC.SYB.Utils
import NameSet
import Control.Monad

-- For Lens stuff
import Control.Lens
import Control.Applicative
import Control.Lens
import Control.Lens.Plated
import Data.Data
-- import Data.Data.Lens(uniplate,biplate,template,tinplate)
import Unsafe.Coerce

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
everythingButStaged :: Stage -> (r -> r -> r) -> r -> GenericQ (r,Bool) -> GenericQ r
everythingButStaged stage k z f x
  | (const False `extQ` postTcType `extQ` fixity `extQ` nameSet) x = z
  | stop == True = v
  | otherwise = foldl k v (gmapQ (everythingButStaged stage k z f) x)
  where (v, stop) = f x
        nameSet    = const (stage `elem` [Parser,TypeChecker]) :: NameSet -> Bool
        postTcType = const (stage<TypeChecker)                 :: PostTcType -> Bool
        fixity     = const (stage<Renamer)                     :: GHC.Fixity -> Bool



{-
-- | Look up a subterm by means of a maybe-typed filter
something :: GenericQ (Maybe u) -> GenericQ (Maybe u)

-- "something" can be defined in terms of "everything"
-- when a suitable "choice" operator is used for reduction
-- 
something = everything orElse
-}

-- | Look up a subterm by means of a maybe-typed filter
somethingStaged :: Stage -> (Maybe u) -> GenericQ (Maybe u) -> GenericQ (Maybe u)

-- "something" can be defined in terms of "everything"
-- when a suitable "choice" operator is used for reduction
-- 
somethingStaged stage z = everythingStaged stage orElse z

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
somewhereStaged :: MonadPlus m => Stage -> GenericM m -> GenericM m

-- We try "f" in top-down manner, but descent into "x" when we fail
-- at the root of the term. The transformation fails if "f" fails
-- everywhere, say succeeds nowhere.
-- 
somewhereStaged stage f x 
  | (const False `extQ` postTcType `extQ` fixity `extQ` nameSet) x = mzero
  | otherwise = f x `mplus` gmapMp (somewhereStaged stage f) x
  where nameSet    = const (stage `elem` [Parser,TypeChecker]) :: NameSet -> Bool
        postTcType = const (stage<TypeChecker)                 :: PostTcType -> Bool
        fixity     = const (stage<Renamer)                     :: GHC.Fixity -> Bool

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

{-
-- | Apply a transformation everywhere in bottom-up manner
-- Note type GenericT = forall a. Data a => a -> a
everywhereStaged :: Stage
                    -> (forall a. Data a => a -> a)
                    -> (forall a. Data a => a -> a)

-- Use gmapT to recurse into immediate subterms;
-- recall: gmapT preserves the outermost constructor;
-- post-process recursively transformed result via f
-- 
everywhereStaged stage f = f . gmapT (everywhere f)
  | (const False `extQ` postTcType `extQ` fixity `extQ` nameSet) = mzero
  | otherwise = f . gmapT (everywhere stage f)
  where nameSet    = const (stage `elem` [Parser,TypeChecker]) :: NameSet -> Bool
        postTcType = const (stage<TypeChecker)                 :: PostTcType -> Bool
        fixity     = const (stage<Renamer)                     :: GHC.Fixity -> Bool
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

-- | Monadic variation on everywhere
everywhereMStaged :: Monad m => Stage -> GenericM m -> GenericM m

-- Bottom-up order is also reflected in order of do-actions
everywhereMStaged stage f x
  | (const False `extQ` postTcType `extQ` fixity `extQ` nameSet) x = return x
  | otherwise = do x' <- gmapM (everywhereMStaged stage f) x
                   f x'
  where nameSet    = const (stage `elem` [Parser,TypeChecker]) :: NameSet -> Bool
        postTcType = const (stage<TypeChecker)                 :: PostTcType -> Bool
        fixity     = const (stage<Renamer)                     :: GHC.Fixity -> Bool
                   
{-
everywhereStaged stage f = f . gmapT (everywhere f)
  | (const False `extQ` postTcType `extQ` fixity `extQ` nameSet) = mzero
  | otherwise = f . gmapT (everywhere stage f)
  where nameSet    = const (stage `elem` [Parser,TypeChecker]) :: NameSet -> Bool
        postTcType = const (stage<TypeChecker)                 :: PostTcType -> Bool
        fixity     = const (stage<Renamer)                     :: GHC.Fixity -> Bool
-}

-- ---------------------------------------------------------------------
-- Lens stuff

-- | Naïve 'Traversal' using 'Data'. This does not attempt to optimize the traversal.
--
-- This is primarily useful when the children are immediately obvious, and for benchmarking.
--
-- @
-- 'tinplate' :: ('Data' a, 'Typeable' b) => 'Simple' 'Traversal' a b
-- @
tinplate :: (Data a, Typeable b) => Simple Traversal a b
tinplate f = gfoldl (step f) pure
{-# INLINE tinplate #-}

step :: (Applicative f, Typeable b, Data d) => (b -> f b) -> f (d -> e) -> d -> f e
step f w d = w <*> case cast d of
  Just b  -> unsafeCoerce <$> f b
  Nothing -> tinplate f d
{-# INLINE step #-}


-- | Naïve 'Traversal' using 'Data', avoiding GHC holes for
-- ParsedSource. This does not attempt to optimize the traversal.
--
--
-- @
-- 'ghcplate' :: ('Data' a, 'Typeable' b) => 'Simple' 'Traversal' a b
-- @

-- Simple Traversal a b ::: Traversal a a b b
-- type   Traversal a b c d =  forall f. Applicative f => (c -> f d) -> a -> f b
-- Simple Traversal a a b b :::forall f. Applicative f => (b -> f b) -> a -> f a

-- ghcplate :: (Data a, Typeable b) => c -> Simple Traversal a b
--ghcplate :: (Data a, Typeable b, Applicative f) =>
--
--                                                     c -> (b -> f b) -> a -> f a
{-
ghcplate :: (Data a, Typeable b, Applicative f) =>
   ((b -> f b) -> f (d -> a) -> a -> f a)
                                                         -> (b -> f b) -> a -> f a
-}
ghcplate ::
  (Data a, Typeable b, Applicative c) => c1 -> (b -> c b) -> a -> c a
ghcplate k f = gfoldl (stepghc' k f) pure
{-# INLINE ghcplate #-}

-- Need b ~ b2
{-
               ghcplate :: (Data a, Typeable b1, Applicative f) =>
                           ((b1 -> f a1) -> f (a -> b) -> a -> f b)
                           -> (b1 -> f a1) -> a -> f a
               stepghc' :: (Data a, Typeable b1, Applicative f) =>
                           ((b1 -> f a1) -> f (a -> b) -> a -> f b)
                           -> (b1 -> f a1) -> f (a -> b) -> a -> f b
-}

stepghc' ::
  (Data d, Typeable b, Applicative f) =>
  c -> (b -> f b) -> f (d -> e) -> d -> f e

{-
stepghc' ::
  (Data d, Typeable b, Applicative f) =>
  ((b -> f b) -> f (d -> e) -> d -> f e)
    -> (b -> f b) -> f (d -> e) -> d -> f e
-}
stepghc' k f w d 
  -- We need (f e) as the result. 
  -- | isGhcHole d = unhole k f w d  -- TODO: get a value for this, probably via a class
  | isGhcHole d = (unhole k f w d)  -- TODO: get a value for this, probably via a class
  | otherwise = w <*> case cast d of
  Just b  -> unsafeCoerce <$> f b
  Nothing -> ghcplate k f d

unhole ::
  (Data d, Typeable b, Applicative f) =>
  c -> (b -> f b) -> f (d -> e) -> d -> f e
unhole k f w d = undefined

{-
--                  forall d b. Data d =>                       c (d -> b) -> d -> c b
-- stepghc :: (Applicative f, Typeable b, Data d) => (b -> f b) -> f (d -> e) -> d -> f e
stepghc ::    (Applicative f, Typeable b, Data d) =>
                                                b -> (b -> f d) -> f (d -> e) -> d -> f e
stepghc k f w d 
  | isGhcHole d = w <*> f k  -- TODO: get a value for this, probably via a class
  | otherwise = w <*> case cast d of
  Just b  -> unsafeCoerce <$> f b
  Nothing -> ghcplate k f d
{-# INLINE stepghc #-}
-}

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


-- gfoldl :: Data a => 
-- (forall d b. Data d => c (d -> b) -> d -> c b) -- nonempty constructor (immediate subterm)
-- -> (forall g. g -> c g)                        -- empty constructor 
-- -> a                                           -- thing to be folded
-- -> c a
--
