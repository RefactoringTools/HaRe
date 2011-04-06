-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module is part of 'StrategyLib', a library of functional strategy
-- combinators, including combinators for generic traversal. In this module, we
-- define path combinator to constrain selection and transformation of nodes or
-- subtrees by path conditions.
 
-----------------------------------------------------------------------------} 

module PathTheme where

import StrategyPrelude
import OverloadingTheme
import FlowTheme
import TraversalTheme
import Monad


------------------------------------------------------------------------------
-- * Below

-- ** Strictly below

-- | Select or transform a node below a node where a condition holds.
-- We find the top-most node which admits selection or transformation
-- below the top-most node which meets the condition. Thus, the
-- distance between guard and application node is minimized.
belowS           :: (MonadPlus m, Strategy s m, StrategyPlus s m)
                 => s m -> TU () m -> s m
s `belowS`   s'  =  (oneS s) `beloweqS` s'

-- ** Below or at the same height

-- | Select or transform a node below or at a node where a condition holds.
beloweqS         :: (MonadPlus m, Strategy s m, StrategyPlus s m)
                 => s m -> TU () m -> s m
s `beloweqS` s'  =  once_td (ifthenS s' (once_td s))

-- ** Type-specialised versions

-- | Apply a transformation strictly below a node where a condition holds.
belowTP		   :: MonadPlus m => TP m -> TU () m -> TP m
belowTP            =  belowS

-- | Apply a transformation below or at a node where a condition holds.
beloweqTP          :: MonadPlus m => TP m -> TU () m -> TP m
beloweqTP          =  beloweqS



------------------------------------------------------------------------------
-- * Above

-- ** Strictly above

-- | Select or transform a node above a node where a condition holds. The
--   distance between guard and application node is minimized.
aboveS           :: (MonadPlus m, Strategy s m, StrategyPlus s m)
                 => s m -> TU () m -> s m
s `aboveS`   s'  =  s `aboveeqS` (oneTU s')

-- ** Above or at the same height

-- | Select or transform a node above or at a node where a condition holds.
aboveeqS         :: (MonadPlus m, Strategy s m, StrategyPlus s m)
                 => s m -> TU () m -> s m
s `aboveeqS` s'  =  once_bu (ifthenS (once_tdTU s') s)

-- ** Type-specialised versions

-- | Apply a transformation strictly above a node where a condition holds.
aboveTP            :: MonadPlus m => TP m -> TU () m -> TP m
aboveTP            =  aboveS

-- | Apply a transformation above or at a node where a condition holds.
aboveeqTP          :: MonadPlus m => TP m -> TU () m -> TP m
aboveeqTP          =  aboveeqS

------------------------------------------------------------------------------

