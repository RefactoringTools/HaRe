------------------------------------------------------------------------------
-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module is part of 'StrategyLib', a library of functional strategy
-- combinators, including combinators for generic traversal. This module
-- defines auxilliary monadic functions, some of which serve as parametric
-- polymorphic prototypes for actual strategy combinators.

------------------------------------------------------------------------------

module MonadicFunctions where

import Monad


------------------------------------------------------------------------------
-- * The identity monad 

-- | Identity type constructor.
newtype Id a = Id a

-- | Unwrap identity type constructor
unId 		:: Id a -> a
unId (Id x) 	 = x

instance Monad Id where
 return = Id
 (Id x) >>= f = f x


------------------------------------------------------------------------------
-- * Recover from partiality

-- | Force success. If the argument value corresponds to failure, 
--   a run-time error will occur.
succeed :: Maybe x -> x
succeed (Just x) = x
succeed Nothing  = error "Didn't succeed!."
 
------------------------------------------------------------------------------
-- * Prototypes for strategy combinators seq, let, choice

-- | Sequential composition of monadic functions
mseq 		:: Monad m => (a -> m b) -> (b -> m c) -> a -> m c
f `mseq` g    	=  \x -> f x >>= g 

-- | Sequential composition with value passing; a kind of monadic let.
mlet 		:: Monad m => (a -> m b) -> (b -> a -> m c) -> a -> m c
f `mlet` g    	=  \x -> f x >>= \y -> g y x

-- | Choice combinator for monadic functions
mchoice 	:: MonadPlus m => (a -> m b) -> (a -> m b) -> a -> m b
f `mchoice` g 	=  \x -> (f x) `mplus` (g x)

------------------------------------------------------------------------------
-- * Guards and conditionals

-- | Type guard described by the argument type of a function.
argtype     :: MonadPlus m => (x -> y) -> x -> m ()
argtype _ _ =  return ()


-- | Type guard described by a type of a value.
valtype :: MonadPlus m => x -> x -> m ()
valtype _ _ = return ()

-- | A kind of monadic conditional.
ifM :: MonadPlus m => m a -> (a -> m c) -> (m c) -> (m c)
ifM ma f mc = ((ma >>= \a -> return (Just a))
               `mplus` (return Nothing)
              ) >>= maybe mc f

------------------------------------------------------------------------------
