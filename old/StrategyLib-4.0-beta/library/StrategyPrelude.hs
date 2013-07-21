------------------------------------------------------------------------------ 
-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module is part of 'StrategyLib', a library of functional strategy
-- combinators, including combinators for generic traversal. This module
-- is basically a wrapper for the strategy primitives plus some extra
-- basic strategy combinators that can be defined immediately in terms
-- of the primitive ones.

------------------------------------------------------------------------------

module StrategyPrelude (
  module StrategyPrimitives,
  module StrategyPrelude
) where

import StrategyPrimitives
import Control.Monad
import Data.Monoid


------------------------------------------------------------------------------ 
-- * Useful defaults for strategy update (see 'adhocTU' and 'adhocTP').

-- | Type-preserving identity. Returns the incoming term without change.
idTP		:: Monad m => TP m
idTP		=  paraTP return

-- | Type-preserving failure. Always fails, independent of the incoming
--   term. Uses 'MonadPlus' to model partiality.
failTP          :: MonadPlus m => TP m
failTP          =  paraTP (const mzero)

-- | Type-unifying failure. Always fails, independent of the incoming
--   term. Uses 'MonadPlus' to model partiality.
failTU          :: MonadPlus m => TU a m
failTU          =  paraTU (const mzero)

-- | Type-unifying constant strategy. Always returns the argument value 'a',
--   independent of the incoming term.
constTU         :: Monad m => a -> TU a m
constTU a       =  paraTU (const (return a))

-- | Type-unifying monadic constant strategy. Always performs the argument
--   computation 'a', independent of the incoming term. This is a monadic
--   variation of 'constTU'.
compTU         :: Monad m => m a -> TU a m
compTU a       =  paraTU (const a)


------------------------------------------------------------------------------ 
-- * Lift a function to a strategy type with failure as default 

-- | Apply the monomorphic, type-preserving argument function, if its 
--   input type matches the input term's type. Otherwise, fail.
monoTP          :: (Term a, MonadPlus m) => (a -> m a) -> TP m
monoTP          =  adhocTP failTP

-- | Apply the monomorphic, type-unifying argument function, if its 
--   input type matches the input term's type. Otherwise, fail.
monoTU 		:: (Term a, MonadPlus m) => (a -> m b) -> TU b m
monoTU  	=  adhocTU failTU


------------------------------------------------------------------------------ 
-- * Function composition

-- | Sequential ccomposition of monomorphic function and type-unifying strategy.
--   In other words, after the type-unifying strategy 's' has been applied, 
--   the monomorphic function 'f' is applied to the resulting value.
dotTU        :: Monad m => (a -> b) -> TU a m -> TU b m
dotTU f s    =  s `passTU` (constTU . f)


-- | Parallel combination of two type-unifying strategies with a binary
--   combinator. In other words, the values resulting from applying the
--   type-unifying strategies are combined to a final value by applying
--   the combinator 'o'.

op2TU :: Monad m => (a -> b -> c) -> TU a m -> TU b m -> TU c m
op2TU o s s' =  s  `passTU` \a ->
                s' `passTU` \b ->
                constTU (o a b)


------------------------------------------------------------------------------ 
-- * Reduce a strategy's performance to its effects

-- | Reduce a type-preserving strategy to a type-unifying one that
--   ignores its result term and returns void, but retains its 
--   monadic effects.
voidTP    :: Monad m => TP m -> TU () m
voidTP s  =  s `seqTU` constTU ()

-- | Reduce a type-unifying strategy to a type-unifying one that
--   ignores its result value and returns void, but retains its 
--   monadic effects.
voidTU    :: Monad m => TU u m -> TU () m
voidTU s  =  s `passTU` \_ -> constTU ()


------------------------------------------------------------------------------ 
-- * Shape test combinators

-- | Test for constant term, i.e.\ having no subterms.
con      :: MonadPlus m => TP m
con      =  allTP failTP	

-- | Test for compound term, i.e.\ having at least one subterm.
com 	 :: MonadPlus m => TP m
com      =  oneTP idTP


------------------------------------------------------------------------------
