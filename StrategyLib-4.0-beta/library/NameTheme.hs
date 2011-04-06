------------------------------------------------------------------------------
-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module is part of 'StrategyLib', a library of functional strategy
-- combinators, including combinators for generic traversal. This module
-- provides algorithms to collect names and their types.

------------------------------------------------------------------------------ 

module NameTheme where

import Monad
import List
import StrategyPrelude
import OverloadingTheme
import FlowTheme
import TraversalTheme
import Control.Monad.Identity hiding (fail)


------------------------------------------------------------------------------ 
-- * Free name analysis

-- | Generic free name analysis algorithm (without types)
freeNames :: (Eq name, Term t)
          => TU [(name,tpe)] Identity	-- ^ Identify declarations
          -> TU [name] Identity		-- ^ Identify references
          -> t				-- ^ Input term
          -> [name]			-- ^ Free names
freeNames declared referenced =
   runIdentity .
   applyTU (all_recTU (op2TU combine)
                      (op2TU (,) declared referenced))
  where
   combine (decs,refs) recs =
    (refs `union` recs) \\ (map fst decs)

-- | Generic free name analysis algorithm with types
freeTypedNames :: (Eq name, Term t)
               => TU [(name,tpe)] Identity -- ^ Identify declarations
               -> TU [name] Identity	   -- ^ Identify references
               -> [(name,tpe)]		   -- ^ Derived declarations
               -> t			   -- ^ Input term
               -> [(name,tpe)]	   	   -- ^ Free names with types
freeTypedNames declared referenced types t =
   filter (\e -> elem (fst e) names) types
  where
    names = freeNames declared referenced t


------------------------------------------------------------------------------ 
-- * Bound name analysis

-- | Accumulate declarations for focus 
boundTypedNames :: (Term f, Term t, Eq name)
                => TU [(name,tpe)] Identity	-- Identify declarations
                -> (f -> Maybe f)		-- Get focus
                -> t				-- Input term
                -> Maybe ([(name,tpe)],f)	-- Derived declarations
boundTypedNames declared unwrap =
   applyTU (once_pe (adhocTU failTU . stop) bind [])
  where
    stop inh =
      (maybe Nothing (Just . (,) inh)) .
      unwrap
    bind inh =
      msubstTU (Just . runIdentity) declared `passTU` \decs ->
      constTU (unionBy byName decs inh)
    byName = \a -> \a' -> fst a == fst a'

------------------------------------------------------------------------------ 
