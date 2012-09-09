------------------------------------------------------------------------------
-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module is part of 'StrategyLib', a library of functional strategy
-- combinators, including combinators for generic traversal. This module 
-- defines combinators to wire up control and data flow. Whenever possible,
-- we define the combinators in an overloaded fashion but we provide
-- type-specialised variants for TP and TU for convenience.

------------------------------------------------------------------------------

module FlowTheme where

import StrategyPrelude
import OverloadingTheme
import Control.Monad
import Data.Monoid


------------------------------------------------------------------------------
-- * Try: recover from failure

-- | Attempt a strategy 's', but recover if it fails.
tryS         :: (StrategyPlus s m, StrategyMonoid s m) => s m -> s m
tryS s       =  s `choiceS` skipS

-- | Attempt a type-preserving strategy 's', but if it fails, return the
--   input term unchanged.
tryTP        :: MonadPlus m => TP m -> TP m
tryTP        =  tryS

-- | Attempt a type-unifying strategy 's', but if it fails, return the
--   'mempty' element of a 'Monoid'.
tryTU        :: (MonadPlus m, Monoid u) => TU u m -> TU u m
tryTU  	     =  tryS


------------------------------------------------------------------------------
-- * Test: ignore result, but retain effects

-- | Test for a strategy's success in a type-preserving context.
testS           :: Strategy s m => s m -> TP m
testS s         =  voidS s `passS` const idTP

-- | Test for a type-preserving strategy's success in a
--   type-preserving context.
testTP 		:: Monad m => TP m -> TP m
testTP  	=  testS

-- | Test for a type-unifying strategy's success in a 
--   type-preserving context.
testTU 		:: Monad m => TU a m -> TP m
testTU  	=  testS


------------------------------------------------------------------------------
-- * If-then-else: pass value from condition to then-clause

-- | If 'c' succeeds, pass its value to the then-clause 't', 
--   otherwise revert to the else-clause 'e'.
ifS       :: StrategyPlus s m => TU u m -> (u -> s m) -> s m -> s m
ifS c t e =  ((c `passTU` (constTU . Just)) `choiceTU` constTU Nothing)
             `passS`
             maybe e t

-- | If 'c' succeeds, pass its value to the then-clause 't', 
--   otherwise revert to the else-clause 'e'.
ifTP      :: MonadPlus m => TU u m -> (u -> TP m) -> TP m -> TP m
ifTP      =  ifS

-- | If 'c' succeeds, pass its value to the then-clause 't', 
--   otherwise revert to the else-clause 'e'.
ifTU      :: MonadPlus m => TU u m -> (u -> TU u' m) -> TU u' m -> TU u' m
ifTU      =  ifS


------------------------------------------------------------------------------
-- * If-then: disciplined form of a guarding

-- | Guard then-clause 't' by the void-valued type-unifying
--   condition 'c'.
ifthenS     :: Strategy s m => TU () m -> s m -> s m
ifthenS c t =  c `passS` const t

-- | Guard type-preserving then-clause 't' by the void-valued type-unifying
--   condition 'c'.
ifthenTP    :: Monad m => TU () m -> TP m -> TP m
ifthenTP    =  ifthenS

-- | Guard type-unifying then-clause 't' by the void-valued type-unifying
--   condition 'c'.
ifthenTU    :: Monad m => TU () m -> TU u m -> TU u m
ifthenTU    =  ifthenS


------------------------------------------------------------------------------
-- * Not: negation by failure 

-- | Invert the success-value of strategy 's'.
notS    :: StrategyPlus s m => s m -> TP m
notS s  =  ifS (voidS s) (const failTP) idTP

-- | Invert the success-value of type-preserving strategy 's'. Its output
--   term (in case of success) will be ignored.
notTP   :: MonadPlus m => TP m -> TP m
notTP   =  notS

-- | Invert the success-value of type-unifying strategy 's'. Its output
--   value (in case of success) will be ignored.
notTU   :: MonadPlus m => TU u m -> TP m
notTU   = notS


------------------------------------------------------------------------------
-- * Exclusive choice

-- | Succeed if exactly one argument strategy succeeds.
xchoiceS        :: StrategyPlus s m => s m -> s m -> s m
s `xchoiceS` s' =  (notS s' `seqS` s) `choiceS` (notS s `seqS` s')

-- | Succeed if exactly one argument strategy succeeds.
xchoiceTP       :: MonadPlus m => TP m -> TP m -> TP m
xchoiceTP       =  choiceS

-- | Succeed if exactly one argument strategy succeeds.
xchoiceTU       :: MonadPlus m => TU u m -> TU u m -> TU u m
xchoiceTU       =  choiceS


------------------------------------------------------------------------------
-- * Generic filter, derived from monomorphic predicate

-- | If predicate 'g' holds for the input term, return it as output term,
--   otherwise fail.
filterTP        :: (Term t, MonadPlus m) => (t -> Bool) -> TP m
filterTP g      =  monoTP (\x -> if g x then return x else mzero)

-- | If predicate 'g' holds for the input term, return it as output value,
--   otherwise fail.
filterTU        :: (Term t, MonadPlus m) => (t -> Bool) -> TU t m
filterTU g      =  monoTU (\x -> if g x then return x else mzero)


------------------------------------------------------------------------------
-- * Generic ticker, derived from monomorphic predicate

-- | If predicate 'g' holds for the input term, 
--   return 1 otherwise return 0.
tickTU 	        :: (Monad m, Term t, Num n) => (t -> Bool) -> TU n m
tickTU g        =  adhocTU (constTU 0) (\t -> return (if g t then 1 else 0))


------------------------------------------------------------------------------
-- * Type guards

-- | Type guard (function type), i.e., guard that does not observe values
type TypeGuard a =  a -> ()

-- | Type guard (function). 
--   Typical usage:
--
-- @ 
--   full_tdTU (typeTickTU (typeGuard::TypeGuard MyType))
-- @
typeGuard	 :: TypeGuard a
typeGuard	 =  const ()

------------------------------------------------------------------------------
-- * Generic ticker, derived from type guard

-- | If type guard holds for the input term, 
--   return 1 otherwise return 0.
typeTickTU  	 :: (Term t, Monad m, Num n) => TypeGuard t -> TU n m
typeTickTU g	 =  adhocTU (constTU 0) ((\() -> return 1) . g)


------------------------------------------------------------------------------
-- * Generic filters,  derived from type guard

-- | If type guard holds for the input term, return it as output term,
--   otherwise fail. 
typeFilterTP     :: (Term t, MonadPlus m) => TypeGuard t -> TP m
typeFilterTP g   =  monoTP (\x -> ((\() -> return x) . g) x)

-- | If type guard holds for the input term, return it as output value,
--   otherwise fail. 
typeFilterTU     :: (Term t, MonadPlus m) => TypeGuard t -> TU t m
typeFilterTU g   =  monoTU (\x -> ((\() -> return x) . g) x)


------------------------------------------------------------------------------
