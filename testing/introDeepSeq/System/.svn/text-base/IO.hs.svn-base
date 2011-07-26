{-# OPTIONS_GHC -fno-implicit-prelude #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  System.IO
-- Copyright   :  (c) The University of Glasgow 2001
-- License     :  BSD-style (see the file libraries/base/LICENSE)
-- 
-- Maintainer  :  libraries@haskell.org
-- Stability   :  stable
-- Portability :  portable
--
-- The standard IO library.
--
-----------------------------------------------------------------------------

module System.IO (
    -- * The IO monad


  ) where

-- | Computation 'hReady' @hdl@ indicates whether at least one item is
-- available for input from handle @hdl@.
-- 
-- This operation may fail with:
--
--  * 'System.IO.Error.isEOFError' if the end of file has been reached.

hReady		:: Handle -> IO Bool
hReady h 	=  hWaitForInput h 0

-- | The same as 'hPutStr', but adds a newline character.

hPutStrLn	:: Handle -> String -> IO ()
hPutStrLn hndl str = do
 hPutStr  hndl str
 hPutChar hndl '\n'

-- | Computation 'hPrint' @hdl t@ writes the string representation of @t@
-- given by the 'shows' function to the file or channel managed by @hdl@
-- and appends a newline.
--
-- This operation may fail with:
--
--  * 'System.IO.Error.isFullError' if the device is full; or
--
--  * 'System.IO.Error.isPermissionError' if another system resource limit would be exceeded.

hPrint		:: Show a => Handle -> a -> IO ()
hPrint hdl 	=  hPutStrLn hdl . show

-- | @'withFile' name mode act@ opens a file using 'openFile' and passes
-- the resulting handle to the computation @act@.  The handle will be
-- closed on exit from 'withFile', whether by normal termination or by
-- raising an exception.
withFile :: FilePath -> IOMode -> (Handle -> IO r) -> IO r
withFile name mode = bracket (openFile name mode) hClose

-- | @'withBinaryFile' name mode act@ opens a file using 'openBinaryFile'
-- and passes the resulting handle to the computation @act@.  The handle
-- will be closed on exit from 'withBinaryFile', whether by normal
-- termination or by raising an exception.
withBinaryFile :: FilePath -> IOMode -> (Handle -> IO r) -> IO r
withBinaryFile name mode = bracket (openBinaryFile name mode) hClose

-- ---------------------------------------------------------------------------
-- fixIO


-- $locking
-- Implementations should enforce as far as possible, at least locally to the
-- Haskell process, multiple-reader single-writer locking on files.
-- That is, /there may either be many handles on the same file which manage
-- input, or just one handle on the file which manages output/.  If any
-- open or semi-closed handle is managing a file for output, no new
-- handle can be allocated for that file.  If any open or semi-closed
-- handle is managing a file for input, new handles can only be allocated
-- if they do not manage output.  Whether two files are the same is
-- implementation-dependent, but they should normally be the same if they
-- have the same absolute path name and neither has been renamed, for
-- example.
--
-- /Warning/: the 'readFile' operation holds a semi-closed handle on
-- the file until the entire contents of the file have been consumed.
-- It follows that an attempt to write to a file (using 'writeFile', for
-- example) that was earlier opened by 'readFile' will usually result in
-- failure with 'System.IO.Error.isAlreadyInUseError'.

-- -----------------------------------------------------------------------------
-- Utils
