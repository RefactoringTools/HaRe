-----------------------------------------------------------------------------
-- |
-- Module      :  Control.Concurrent.MVar
-- Copyright   :  (c) The University of Glasgow 2001
-- License     :  BSD-style (see the file libraries/base/LICENSE)
-- 
-- Maintainer  :  libraries@haskell.org
-- Stability   :  experimental
-- Portability :  non-portable (concurrency)
--
-- Synchronising variables
--
-----------------------------------------------------------------------------

module Control.Concurrent.MVar
	( 
	  -- * @MVar@s
	, readMVar 	-- :: MVar a -> IO a
	, swapMVar 	-- :: MVar a -> a -> IO a
	, withMVar	-- :: MVar a -> (a -> IO b) -> IO b
	, modifyMVar_ 	-- :: MVar a -> (a -> IO a) -> IO ()
	, modifyMVar 	-- :: MVar a -> (a -> IO (a,b)) -> IO b
    ) where


import Prelude
import Control.Exception as Exception

{-|
  This is a combination of 'takeMVar' and 'putMVar'; ie. it takes the value
  from the 'MVar', puts it back, and also returns it.
-}
readMVar :: MVar a -> IO a
readMVar m =
  block $ do
    a <- takeMVar m
    putMVar m a
    return a

-- |Swap the contents of an 'MVar' for a new value.
swapMVar :: MVar a -> a -> IO a
swapMVar mvar new =
  block $ do
    old <- takeMVar mvar
    putMVar mvar new
    return old

{-|
  'withMVar' is a safe wrapper for operating on the contents of an
  'MVar'.  This operation is exception-safe: it will replace the
  original contents of the 'MVar' if an exception is raised (see
  "Control.Exception").
-}
{-# INLINE withMVar #-}
-- inlining has been reported to have dramatic effects; see
-- http://www.haskell.org//pipermail/haskell/2006-May/017907.html
withMVar :: MVar a -> (a -> IO b) -> IO b
withMVar m io = 
  block $ do
    a <- takeMVar m
    b <- Exception.catch (unblock (io a))
      	    (\e -> do putMVar m a; throw e)
    putMVar m a
    return b

{-|
  A safe wrapper for modifying the contents of an 'MVar'.  Like 'withMVar', 
  'modifyMVar' will replace the original contents of the 'MVar' if an
  exception is raised during the operation.
-}
{-# INLINE modifyMVar_ #-}
modifyMVar_ :: MVar a -> (a -> IO a) -> IO ()
modifyMVar_ m io = 
  block $ do
    a  <- takeMVar m
    a' <- Exception.catch (unblock (io a))
      	    (\e -> do putMVar m a; throw e)
    putMVar m a'

{-|
  A slight variation on 'modifyMVar_' that allows a value to be
  returned (@b@) in addition to the modified value of the 'MVar'.
-}
{-# INLINE modifyMVar #-}
modifyMVar :: MVar a -> (a -> IO (a,b)) -> IO b
modifyMVar m io = 
  block $ do
    a      <- takeMVar m
    (a',b) <- Exception.catch (unblock (io a))
      	        (\e -> do putMVar m a; throw e)
    putMVar m a'
    return b
