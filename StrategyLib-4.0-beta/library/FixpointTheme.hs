------------------------------------------------------------------------------
-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module is part of 'StrategyLib', a library of functional strategy
-- combinators, including combinators for generic traversal. This module 
-- defines combinators that iterate until some kind of fixpoint is reached.
--
------------------------------------------------------------------------------

module FixpointTheme where

import StrategyPrelude
import FlowTheme
import TraversalTheme
import Monad


------------------------------------------------------------------------------
-- * Fixpoint Iteration 


-- | Exhaustive repeated application at the root of the input term
repeatTP        :: MonadPlus m => TP m -> TP m
repeatTP s      =  tryTP (seqTP s (repeatTP s))



------------------------------------------------------------------------------
-- * Fixpoint Traversal 


-- | Exhaustive repeated application throughout the input term.
reduce 		:: MonadPlus m => TP m -> TP m
reduce s 	=  repeatTP (someTP (reduce s) `choiceTP` s)

-- | Exhaustive repeated application according to the left-most
--   outermost traversal strategy.
outermost  	:: MonadPlus m => TP m -> TP m
outermost s	=  repeatTP (once_tdTP s)

-- | Exhaustive repeated application according to the left-most
--   innermost traversal strategy, implemented in a naive way.
--   Use 'innermost' instead.
innermost'	:: MonadPlus m => TP m -> TP m
innermost' s	=  repeatTP (once_buTP s)

-- | Exhaustive repeated application according to the left-most
--   innermost traversal strategy, implemented in a more 
--   efficient way.
innermost	:: MonadPlus m => TP m -> TP m
innermost s	=  allTP (innermost s) 
                   `seqTP` 
                   (tryTP (s `seqTP` (innermost s)))

------------------------------------------------------------------------------

