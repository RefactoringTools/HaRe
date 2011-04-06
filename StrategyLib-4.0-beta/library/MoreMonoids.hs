------------------------------------------------------------------------------
-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module is part of 'StrategyLib', a library of functional strategy
-- combinators, including combinators for generic traversal. This module
-- defines additional instances of the Monoid class.

------------------------------------------------------------------------------

module MoreMonoids where

import Data.Monoid

------------------------------------------------------------------------------

-- | Any 'Num' is a 'Monoid'.
instance Num a => Monoid a where
 mempty = 0
 mappend = (+)

-----------------------------------------------------------------------------
