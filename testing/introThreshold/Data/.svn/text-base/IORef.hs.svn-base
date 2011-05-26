-----------------------------------------------------------------------------
-- |
-- Module      :  Data.IORef
-- Copyright   :  (c) The University of Glasgow 2001
-- License     :  BSD-style (see the file libraries/base/LICENSE)
-- 
-- Maintainer  :  libraries@haskell.org
-- Stability   :  experimental
-- Portability :  portable
--
-- Mutable references in the IO monad.
--
-----------------------------------------------------------------------------

module Data.IORef
  ( 
	-- * IORefs
	modifyIORef,	      -- :: IORef a -> (a -> a) -> IO ()
	atomicModifyIORef,    -- :: IORef a -> (a -> (a,b)) -> IO b
	) where

import Prelude	-- Explicit dependency helps 'make depend' do the right thing

-- |Mutate the contents of an 'IORef'
modifyIORef :: IORef a -> (a -> a) -> IO ()
modifyIORef ref f = writeIORef ref . f =<< readIORef ref


-- |Atomically modifies the contents of an 'IORef'.
--
-- This function is useful for using 'IORef' in a safe way in a multithreaded
-- program.  If you only have one 'IORef', then using 'atomicModifyIORef' to
-- access and modify it will prevent race conditions.
--
-- Extending the atomicity to multiple 'IORef's is problematic, so it
-- is recommended that if you need to do anything more complicated
-- then using 'Control.Concurrent.MVar.MVar' instead is a good idea.
--
atomicModifyIORef :: IORef a -> (a -> (a,b)) -> IO b
atomicModifyIORef r f =
  excludeFinalisers $ do
    a <- readIORef r
    let (a',b) = f a
    writeIORef r a'
    return b
