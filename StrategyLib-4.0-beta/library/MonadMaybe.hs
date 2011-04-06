------------------------------------------------------------------------------
-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module introduces the MaybeT monad transformer.
-- It is basically a simplification of the ErrorT monad transformer.

------------------------------------------------------------------------------

module MonadMaybe ( 

 MaybeT(..)

) where

import Monad
import Control.Monad.Fix
import Control.Monad.Trans
import Control.Monad.Reader
import Control.Monad.Writer
import Control.Monad.State
import Control.Monad.RWS
import Control.Monad.Cont
import IO
import Control.Monad.Error

------------------------------------------------------------------------------

-- | The monad transformer 'MaybeT'.
newtype MaybeT m a = MaybeT { runMaybeT :: m (Maybe a) }

instance (Monad m) => Functor (MaybeT m) where
	fmap f m = MaybeT $ do
		a <- runMaybeT m
		case a of
			Nothing -> return (Nothing)
			Just  r -> return (Just  (f r))

instance (Monad m) => Monad (MaybeT m) where
	return a = MaybeT $ return (Just  a)
	m >>= k  = MaybeT $ do
		a <- runMaybeT m
		case a of
			Nothing -> return (Nothing)
			Just  r -> runMaybeT (k r)
	fail msg = MaybeT $ return (Nothing)

instance (Monad m) => MonadPlus (MaybeT m) where
	mzero       = MaybeT $ return (Nothing)
	m `mplus` n = MaybeT $ do
		a <- runMaybeT m
		case a of
			Nothing -> runMaybeT n
			Just  r -> return (Just  r)

instance (MonadFix m) => MonadFix (MaybeT m) where
	mfix f = MaybeT $ mfix $ \a -> runMaybeT $ f $ case a of
		Just  r -> r
		_       -> error "empty mfix argument"

{-
instance (Monad m) => MonadError e (MaybeT m) where
	throwError l     = MaybeT $ return (Nothing)
	m `catchError` h = MaybeT $ do
		a <- runMaybeT m
		case a of
			Nothing -> runMaybeT (h l)
			Just  r -> return (Just  r)
-}

instance MonadTrans (MaybeT) where
	lift m = MaybeT $ do
		a <- m
		return (Just  a)

instance (MonadIO m) => MonadIO (MaybeT m) where
	liftIO = lift . liftIO

instance (MonadReader r m) => MonadReader r (MaybeT m) where
	ask       = lift ask
	local f m = MaybeT $ local f (runMaybeT m)

instance (MonadWriter w m) => MonadWriter w (MaybeT m) where
	tell     = lift . tell
	listen m = MaybeT $ do
		(a, w) <- listen (runMaybeT m)
		return $ case a of
			Nothing -> Nothing
			Just  r -> Just  (r, w)
	pass   m = MaybeT $ pass $ do
		a <- runMaybeT m
		return $ case a of
			Nothing      -> (Nothing, id)
			Just  (r, f) -> (Just  r, f)

instance (MonadState s m) => MonadState s (MaybeT m) where
	get = lift get
	put = lift . put

instance (MonadCont m) => MonadCont (MaybeT m) where
	callCC f = MaybeT $
		callCC $ \c ->
		runMaybeT (f (\a -> MaybeT $ c (Just  a)))

------------------------------------------------------------------------------
