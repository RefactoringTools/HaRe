------------------------------------------------------------------------------
-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module is part of 'StrategyLib', a library of functional strategy
-- combinators, including combinators for generic traversal. This module defines
-- traversal schemes. Such schemes have formed the core of StrategyLib
-- since its first release. The portfolio as it stands now captures part
-- of the design in the paper "... Polymorphic Symphony".

------------------------------------------------------------------------------

module TraversalTheme where

import StrategyPrelude
import OverloadingTheme
import FlowTheme
import Control.Monad
import Data.Monoid


------------------------------------------------------------------------------
-- * Recursive traversal

------------------------------------------------------------------------------
-- ** Full traversals
--
--    * td -- top-down
--    * bu -- bottom-up 

-- | Full type-preserving traversal in top-down order.
full_tdTP	:: Monad m => TP m -> TP m
full_tdTP s	=  s `seqTP` (allTP (full_tdTP s))

-- | Full type-preserving traversal in bottom-up order.
full_buTP 	:: Monad m => TP m -> TP m
full_buTP s	=  (allTP (full_buTP s)) `seqTP` s

-- | Full type-unifying traversal in top-down order.
full_tdTU 	:: (Monad m, Monoid a) => TU a m -> TU a m
full_tdTU s	=  op2TU mappend s (allTU' (full_tdTU s))



------------------------------------------------------------------------------
-- ** Traversals with stop conditions 

-- | Top-down type-preserving traversal that is cut of below nodes
--   where the argument strategy succeeds.
stop_tdTP 	:: MonadPlus m => TP m -> TP m
stop_tdTP s	=  s `choiceTP` (allTP (stop_tdTP s))

-- | Top-down type-unifying traversal that is cut of below nodes
--   where the argument strategy succeeds.
stop_tdTU 	:: (MonadPlus m, Monoid a) => TU a m -> TU a m
stop_tdTU s	=  s `choiceTU` (allTU' (stop_tdTU s))



------------------------------------------------------------------------------
-- ** Single hit traversal 

-- | Top-down type-preserving traversal that performs its argument
--   strategy at most once.
once_tdTP 	:: MonadPlus m => TP m -> TP m
once_tdTP s	=  s `choiceTP` (oneTP (once_tdTP s))

-- | Top-down type-unifying traversal that performs its argument
--   strategy at most once.
once_tdTU 	:: MonadPlus m => TU a m -> TU a m
once_tdTU s	=  s `choiceTU` (oneTU (once_tdTU s))

-- | Bottom-up type-preserving traversal that performs its argument
--   strategy at most once.
once_buTP 	:: MonadPlus m => TP m -> TP m
once_buTP s	=  (oneTP (once_buTP s)) `choiceTP` s

-- | Bottom-up type-unifying traversal that performs its argument
--   strategy at most once.
once_buTU 	:: MonadPlus m => TU a m -> TU a m
once_buTU s	=  (oneTU (once_buTU s)) `choiceTU` s



------------------------------------------------------------------------------
-- ** Traversal with environment propagation

-- | Top-down type-unifying traversal with propagation of an environment.
once_peTU :: MonadPlus m 
          => e 		     -- ^ initial environment
	  -> (e -> TU e m)   -- ^ environment modification at downward step
	  -> (e -> TU a m)   -- ^ extraction of value, dependent on environment
	  -> TU a m
once_peTU e s' s = s e
                   `choiceTU`
                   (s' e `passTU` \e' -> oneTU (once_peTU e' s' s))


------------------------------------------------------------------------------
-- * One-layer traversal

------------------------------------------------------------------------------
-- ** Defined versions of some primitive one-layer traversal combinators

-- For performance and uniformity reasons, anyTP and someTP are 
-- primitives, but they could have been defined as follows:

-- | Use 'anyTP' instead.
anyTP'		:: MonadPlus m => TP m -> TP m
anyTP' s	=  allTP (tryTP s)

-- | Use 'someTP' instead.
someTP'		:: MonadPlus m => TP m -> TP m
someTP' s	=  (testTP (notTP (allTP (notTP s)))) `seqTP` (anyTP s)



------------------------------------------------------------------------------
-- ** Recursive completion of one-layer traversal 

-- | Recursive completion of full type-preserving one-layer traverasal
all_recTU :: (Monoid a, Monad m) 
          => (t -> TU a m -> TU a m)      -- ^ binary strategy combinator
          -> t                            -- ^ argument strategy
	  -> TU a m                       -- ^ result strategy
all_recTU o s = s `o` allTU' (all_recTU o s)

-- | Recursive completion of type-preserving one-layer traversal that
--   succeeds exactly once.
one_recTU :: MonadPlus m 
          => (t -> TU a m -> TU a m)      -- ^ binary strategy combinator
          -> t                            -- ^ argument strategy
	  -> TU a m                       -- ^ result strategy
one_recTU o s = s `o` oneTU (one_recTU o s)


------------------------------------------------------------------------------
-- * Overloading and synonyms

------------------------------------------------------------------------------
-- ** Overloaded schemes for traversal 
--   See the paper "... Polymorphic symphony" for a discussion 

-- | Full top-down traversal (overloaded between 'TU' and 'TP').
full_td 	:: StrategyMonoid s m => s m -> s m
full_td s	=  s `combS` (allS (full_td s))

-- | One-hit top-down traversal (overloaded between 'TU' and 'TP').
once_td 	:: StrategyPlus s m => s m -> s m 
once_td s       =  s `choiceS` (oneS (once_td s))

-- | One-hit bottom-up traversal (overloaded between 'TU' and 'TP').
once_bu 	:: StrategyPlus s m => s m -> s m
once_bu s       =  (oneS (once_bu s)) `choiceS` s

-- | One-hit top-down traversal with environment propagation 
--   (overloaded between 'TU' and 'TP').
once_pe         :: StrategyPlus s m => (e -> s m) -> (e -> TU e m) -> e -> s m
once_pe s s' e  =  s e `choiceS` (s' e `passS` (\e' -> oneS (once_pe s s' e)))



------------------------------------------------------------------------------
-- ** Some synonyms for convenience 

-- | See 'full_tdTP'.
topdown   :: Monad m => TP m -> TP m
topdown   =  full_tdTP

-- | See 'full_tdTU'.
crush     :: (Monad m, Monoid u) => TU u m -> TU u m 
crush     =  full_tdTU

-- | Type-specialised version of 'crush', which works with lists instead of
--   any arbitrary monoid.
collect   :: Monad m => TU [a] m -> TU [a] m 
collect   =  crush

-- | See 'once_tdTU'.
select    :: MonadPlus m => TU u m -> TU u m 
select    =  once_tdTU

-- | See 'once_peTU'.
selectenv :: MonadPlus m => e -> (e -> TU e m) -> (e -> TU a m) -> TU a m
selectenv =  once_peTU


------------------------------------------------------------------------------
