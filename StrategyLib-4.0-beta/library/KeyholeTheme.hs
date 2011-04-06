------------------------------------------------------------------------------
-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module is part of 'StrategyLib', a library of functional strategy
-- combinators, including combinators for generic traversal. This module
-- defines a number combinators for keyhole operations, i.e. for operations
-- that have ordinary parametric or adhoc polymorhpic types, but employ
-- strategies inside.

------------------------------------------------------------------------------
 
module KeyholeTheme where

import Monad
import Control.Monad.Identity 
import MonadicFunctions
import StrategyPrelude
import OverloadingTheme
import PathTheme
import FlowTheme
import TraversalTheme


------------------------------------------------------------------------------
-- * Focus

-- | Select the identified focus.
--   Fails if no subterm can be selected.
selectFocus :: (Term f, Term t)
            => (f -> Maybe f)	-- ^ Identify focus
            -> t 		-- ^ Input term
            -> Maybe f		-- ^ Focused term
selectFocus unwrap = applyTU (once_tdTU (adhocTU failTU unwrap))

-- | Replace the identified focus.
--   Fails if no subterm can be replaced.
replaceFocus :: (Term t, Term t') 
             => (t -> Maybe t)		-- Transform focus
             -> t'			-- Input term
             -> Maybe t'		-- Output term
replaceFocus trafo = applyTP (once_tdTP (adhocTP failTP trafo))

-- | Delete the focus assuming it is an element in a list. 
--   Fails if no deletion can be performed.
deleteFocus :: (Term f, Term [f], Term t)
            => (f -> Maybe f)	-- ^ Identify focus
            -> t		-- ^ Input term
            -> Maybe t		-- ^ Output term without focused entity
deleteFocus unwrap = applyTP (once_tdTP (adhocTP failTP filterF))
  where 
    filterF xs = do { xs' <- filterM pred xs;
                      guard (length xs - 1 == length xs');
                      return xs'
                    }
    pred x = (unwrap x >>= \_ -> return False)
             `mplus`
             return True

-- | Find the host of the focused entity, i.e. a superterm of the
--   focussed subterm.
selectHost :: (Term f, Term h, Term t)
           => (f -> Maybe f)	-- ^ Get focus
           -> (h -> Maybe h)	-- ^ Get host
           -> t			-- ^ Input term
           -> Maybe h 		-- ^ Located host
selectHost getFocus getHost
  = applyTU ( adhocTU failTU getHost
              `aboveS`
              (adhocTU failTU (\f -> getFocus f >>= return . const ())) )

-- Mark a host of a focused entity.
markHost :: (Term f, Term h, Term t)
         => (f -> Bool)		-- ^ Test focus
         -> (h -> h)		-- ^ Wrap host
         -> t			-- ^ Input term
         -> Maybe t		-- ^ Output term
markHost testFocus wrapHost =
  applyTP (host `aboveS` focus)
 where
   host = adhocTP failTP (Just . wrapHost)
   focus = adhocTU failTU (guard . testFocus)



------------------------------------------------------------------------------
-- * Listification

-- | Put all nodes of a certain type into a list.
listify 	:: (Term x, Term y) => x -> [y]
listify 	=  runIdentity . applyTU worker  
  where
    worker  = op2TU (++) process recurse 
    process = adhocTU (constTU []) (\x -> return [x])
    recurse = allTU (++) [] worker

-- | Put all nodes of type 'String' into a list. This is a type-specialization
--   of 'listify'.
strings 	:: Term x => x -> [String]
strings 	=  listify

------------------------------------------------------------------------------ 
-- * Keyhole versions of basic strategy combinators.

-- | Apply the argument function to the unique subterm of the input term.
--   Fail if the input term has more subterms or if the subterm is not of
--   the appropriate type. This is a keyhole version of the traversal
--   combinator 'injTP'
inj 		:: (MonadPlus m, Term x, Term c) => (c -> m c) -> (x -> m x)
inj f 		=  applyTP (injTP (adhocTP failTP f))

------------------------------------------------------------------------------ 
