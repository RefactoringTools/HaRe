------------------------------------------------------------------------------ 
-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module is part of 'StrategyLib', a library of functional strategy
-- combinators, including combinators for generic traversal. This module 
-- provides non-strategic functionality for running monads and unlifting
-- monad transformers. In a sense, this is dual to the 'return' and 'lift'
-- functionality of the 'Monad' and 'MonadTrans' classes.
--
------------------------------------------------------------------------------

module MonadRun where

import Control.Monad.Trans
import Control.Monad.Identity
import Control.Monad.State
import Control.Monad.List
import MonadMaybe
import Control.Monad.Error
import System.IO.Unsafe (unsafePerformIO) -- for running IO monads


------------------------------------------------------------------------------
-- * Monad algebras

-- | The algebra for the partiality effect of 'Maybe' and 'MaybeT'.
data MaybeAlg a b	= MaybeAlg { nothing :: b, just :: a -> b }

-- | The algebra for the error effect of 'Either' and 'ErrorT'.
data ErrorAlg e a b 	= ErrorAlg { left :: e -> b, right :: a -> b } 

-- | The algebra for the non-determinacy effect of '[]' and 'ListT'.
data ListAlg a b	= ListAlg { nil :: b, cons :: a -> b -> b }

-- | The algebra for the state effect of 'State' and 'StateT'.
data StateAlg s a b 	= StateAlg { first :: s,         -- ^ initial state
				     next :: (a,s) -> b  -- ^ state transformer
				   }

--evalStateAlg s = StateAlg (\f -> fst (f s)) 
--execStateAlg s = StateAlg (\f -> snd (f s)) 


------------------------------------------------------------------------------
-- * Running monads

-- | The class of monads for which a 'run' function is defined that
--   executes the computation of the monad.
class MonadRun s m | m -> s where
  -- | The overloaded function run takes as first argument an "algebra" which
  -- captures the ingredients necessary to run the particular monad at hand.
  -- This algebra is parameterized with the domain and co-domain of run.
  run :: s a b -> m a -> b

-- | Running the 'Identity' monad.
--   The algebra for the 'Identity' monad is a unary function.
instance MonadRun (->) Identity where
  run alg = alg . runIdentity

-- | Running the 'Maybe' monad.
instance MonadRun MaybeAlg Maybe where
  run alg = maybe (nothing alg) (just alg)

-- | Running the error monad.
instance MonadRun (ErrorAlg e) (Either e) where
  run alg = either (left alg) (right alg)

-- | Running the list monad.
instance MonadRun ListAlg [] where
  run alg = foldr (cons alg) (nil alg)

-- | Running the 'State' monad.
instance MonadRun (StateAlg s) (State s) where  
  run alg = \ma -> next alg (runState ma (first alg))

-- | Running the 'IO' monad. 
--   Note: uses 'unsafePerformIO'!
instance MonadRun (->) IO where
  run alg = alg . unsafePerformIO  

-- | Exchange one monad by another.
--   This function runs one monad, and puts its value in another. This is
--   basically a monadic version of the 'run' function itself. Note that the two
--   monads are unrelated, so none of the effects of the incoming monad are
--   transferred to the result monad.
mrun 		:: (MonadRun s m ,Monad m') => s a b -> m a -> m' b
mrun alg ma 	=  return (run alg ma)


------------------------------------------------------------------------------
-- * Unlifting monad transformers 

-- | Just as a base monad can be run to remove the monad, so can a transformed
--   monad be unlifted to remove the transformer and obtain the original monad.
class MonadUnTrans s t | t -> s where
  -- | The overloaded function 'unlift' for monad transformers takes as first 
  --   argument an "algebra" just like the run function for base monads. For
  --   each monad transformer, the same algebra is used as for the base monad
  --   of which the transformer is the parameterized variant.
  unlift :: Monad m => s a b -> t m a -> m b

-- | Unlifting the list monad transformer.
instance MonadUnTrans ListAlg ListT where
  unlift alg ma = do as <- runListT ma 
                     return (foldr (cons alg) (nil alg) as)

-- | Unlifting the partiality monad transformer.
instance MonadUnTrans MaybeAlg MaybeT where
  unlift alg ma = do ea <- runMaybeT ma
                     return (maybe (nothing alg) (just alg) ea) 
		     
-- | Unlifting the error monad transformer.
instance MonadUnTrans (ErrorAlg e) (ErrorT e) where
  unlift alg ma = do ea <- runErrorT ma
                     return (either (left alg) (right alg) ea) 
		     	
-- | Unlifting the state monad transformer
instance MonadUnTrans (StateAlg s) (StateT s) where
  unlift alg ma = do as <- runStateT ma (first alg)
                     return (next alg as) 

-- * Monadic choice combinators that confine the partiality effect

-- Result of pair programming with Alberto Pardo

-- ** Monadic choice

-- | Monadic choice combinator that confines the partiality effect to
--   the first argument. This is a variation on 'mplus' which allows
--   the partiality effect to spread to both arguments and to the result.	  
mplus' 		:: (Monad m, MonadUnTrans MaybeAlg t) 
       		=> t m b -> m b -> m b
m1 `mplus'` m2 	=  unlift (MaybeAlg m2 return) m1 >>= id

-- | Monadic choice combinator. Generalization of 'mplus'' that takes a list
--   of choice arguments rather than a single one.
mswitch			:: (Monad m, MonadUnTrans MaybeAlg t) 
       			=> [t m b]   -- ^ choice branches
			-> m b       -- ^ otherwise
			-> m b       -- ^ result
mswitch [] m		=  m
mswitch (tm:tms) m	=  tm `mplus'` (mswitch tms m)	
	
-- | Specialization of 'mswitch' for MaybeT.
mayswitch		:: (Monad m) => [MaybeT m b] -> m b -> m b
mayswitch tms m		=  (foldr mplus mzero tms) `mplus'` m 


-- ** Monadic function choice

-- | Monadic function choice combinator that confines the partiality effect
--   to the first argument. This is a variation on 'mchoice' which
--   allows the partiality effect to spread to both arguments and to the
--   result.
mchoice' :: (Monad m, MonadUnTrans MaybeAlg t) 
         => (a -> t m b) -> (a -> m b) -> a -> m b
f `mchoice'` g = \a -> do ea <- unlift (MaybeAlg Nothing Just) (f a)
			  maybe (g a) (return) ea

-- | Monadic function choice combinator. Generalization of 'mchoice'' that
--   takes a list of choice arguments rather than a single one.
mchoices		:: (Monad m, MonadUnTrans MaybeAlg t, MonadPlus (t m))
                        => [a -> t m b] -> (a -> m b) -> a -> m b
mchoices fs f		=  \a -> mswitch' (map (\f -> f a) fs) (f a)


-- ** Implementation variants

-- | Implementation variant of 'mswitch' in terms of foldr.
mswitch0		:: (Monad m, MonadUnTrans MaybeAlg t) 
       			=> [t m b] -> m b -> m b
mswitch0 tms m          =  foldr mplus' m tms	

-- | Implementation variant of 'mswitch' with 'mplus'' expanded:
mswitch1		:: (Monad m, MonadUnTrans MaybeAlg t) 
       			=> [t m b] -> m b -> m b
mswitch1 [] m		=  m
mswitch1 (tm:tms) m	=  unlift (MaybeAlg (mswitch1 tms m) return) tm >>= id 		

-- | Implementation variant of 'mswitch' where the unlift is postponed
--   to the very end.
mswitch'		:: (Monad m, MonadUnTrans MaybeAlg t, 
                            MonadPlus (t m)) 
       			=> [t m b] -> m b -> m b
mswitch' tms m		=  (foldr mplus mzero tms) `mplus'` m 

------------------------------------------------------------------------------
