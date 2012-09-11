{-# OPTIONS_GHC -fno-implicit-prelude #-}

-----------------------------------------------------------------------------
-- |
-- Module      :  System.IO.Error
-- Copyright   :  (c) The University of Glasgow 2001
-- License     :  BSD-style (see the file libraries/base/LICENSE)
-- 
-- Maintainer  :  libraries@haskell.org
-- Stability   :  provisional
-- Portability :  portable
--
-- Standard IO Errors.
--
-----------------------------------------------------------------------------

module System.IO.Error (

    -- * I\/O errors
    IOError,			-- = IOException

    userError,		       	-- :: String  -> IOError

				--    -> Maybe FilePath -> IOError

    annotateIOError,		-- :: IOError -> String -> Maybe Handle
				--    -> Maybe FilePath -> IOError

    -- ** Classifying I\/O errors

    -- ** Attributes of I\/O errors


    -- * Types of I\/O error

    alreadyExistsErrorType,	-- :: IOErrorType
    doesNotExistErrorType,
    alreadyInUseErrorType,
    fullErrorType,
    eofErrorType,
    illegalOperationErrorType, 
    permissionErrorType,
    userErrorType,

    -- ** 'IOErrorType' predicates

    -- * Throwing and catching I\/O errors

    ioError,		       	-- :: IOError -> IO a

    catch,			-- :: IO a -> (IOError -> IO a) -> IO a

  ) where

import Data.Either
import Data.Maybe

import IO
--import Data.Maybe (fromJust)
--import Control.Monad (MonadPlus(mplus))

-- | The construct 'try' @comp@ exposes IO errors which occur within a
-- computation, and which are not fully handled.
--
-- Non-I\/O exceptions are not caught by this variant; to catch all
-- exceptions, use 'Control.Exception.try' from "Control.Exception".

try            :: IO a -> IO (Either IOError a)
try f          =  catch (do r <- f
                            return (Right r))
                        (return . Left)

-- -----------------------------------------------------------------------------
-- IOErrorType

-- | An error indicating that an 'IO' operation failed because
-- one of its arguments already exists.
isAlreadyExistsError :: IOError -> Bool
isAlreadyExistsError = isAlreadyExistsErrorType    . ioeGetErrorType

-- | An error indicating that an 'IO' operation failed because
-- one of its arguments does not exist.
isDoesNotExistError :: IOError -> Bool
isDoesNotExistError  = isDoesNotExistErrorType     . ioeGetErrorType

-- | An error indicating that an 'IO' operation failed because
-- one of its arguments is a single-use resource, which is already
-- being used (for example, opening the same file twice for writing
-- might give this error).
isAlreadyInUseError :: IOError -> Bool
isAlreadyInUseError  = isAlreadyInUseErrorType     . ioeGetErrorType

-- | An error indicating that an 'IO' operation failed because
-- the device is full.
isFullError         :: IOError -> Bool
isFullError          = isFullErrorType             . ioeGetErrorType

-- | An error indicating that an 'IO' operation failed because
-- the end of file has been reached.
isEOFError          :: IOError -> Bool
isEOFError           = isEOFErrorType              . ioeGetErrorType

-- | An error indicating that an 'IO' operation failed because
-- the operation was not possible.
-- Any computation which returns an 'IO' result may fail with
-- 'isIllegalOperation'.  In some cases, an implementation will not be
-- able to distinguish between the possible error causes.  In this case
-- it should fail with 'isIllegalOperation'.
isIllegalOperation  :: IOError -> Bool
isIllegalOperation   = isIllegalOperationErrorType . ioeGetErrorType

-- | An error indicating that an 'IO' operation failed because
-- the user does not have sufficient operating system privilege
-- to perform that operation.
isPermissionError   :: IOError -> Bool
isPermissionError    = isPermissionErrorType       . ioeGetErrorType

-- | A programmer-defined error value constructed using 'userError'.
isUserError         :: IOError -> Bool
isUserError          = isUserErrorType             . ioeGetErrorType

-- -----------------------------------------------------------------------------
-- IOErrorTypes


-- | I\/O error where the operation failed because one of its arguments
-- already exists.
alreadyExistsErrorType   :: IOErrorType
alreadyExistsErrorType    = AlreadyExists

-- | I\/O error where the operation failed because one of its arguments
-- does not exist.
doesNotExistErrorType    :: IOErrorType
doesNotExistErrorType     = NoSuchThing

-- | I\/O error where the operation failed because one of its arguments
-- is a single-use resource, which is already being used.
alreadyInUseErrorType    :: IOErrorType
alreadyInUseErrorType     = ResourceBusy

-- | I\/O error where the operation failed because the device is full.
fullErrorType            :: IOErrorType
fullErrorType             = ResourceExhausted

-- | I\/O error where the operation failed because the end of file has
-- been reached.
eofErrorType             :: IOErrorType
eofErrorType              = EOF

-- | I\/O error where the operation is not possible.
illegalOperationErrorType :: IOErrorType
illegalOperationErrorType = IllegalOperation

-- | I\/O error where the operation failed because the user does not
-- have sufficient operating system privilege to perform that operation.
permissionErrorType      :: IOErrorType
permissionErrorType       = PermissionDenied

-- | I\/O error that is programmer-defined.
userErrorType		 :: IOErrorType
userErrorType		  = UserError

-- -----------------------------------------------------------------------------
-- IOErrorType predicates

-- | I\/O error where the operation failed because one of its arguments
-- already exists.
isAlreadyExistsErrorType :: IOErrorType -> Bool
isAlreadyExistsErrorType AlreadyExists = True
isAlreadyExistsErrorType _ = False

-- | I\/O error where the operation failed because one of its arguments
-- does not exist.
isDoesNotExistErrorType :: IOErrorType -> Bool
isDoesNotExistErrorType NoSuchThing = True
isDoesNotExistErrorType _ = False

-- | I\/O error where the operation failed because one of its arguments
-- is a single-use resource, which is already being used.
isAlreadyInUseErrorType :: IOErrorType -> Bool
isAlreadyInUseErrorType ResourceBusy = True
isAlreadyInUseErrorType _ = False

-- | I\/O error where the operation failed because the device is full.
isFullErrorType :: IOErrorType -> Bool
isFullErrorType ResourceExhausted = True
isFullErrorType _ = False

-- | I\/O error where the operation failed because the end of file has
-- been reached.
isEOFErrorType :: IOErrorType -> Bool
isEOFErrorType EOF = True
isEOFErrorType _ = False

-- | I\/O error where the operation is not possible.
isIllegalOperationErrorType :: IOErrorType -> Bool
isIllegalOperationErrorType IllegalOperation = True
isIllegalOperationErrorType _ = False

-- | I\/O error where the operation failed because the user does not
-- have sufficient operating system privilege to perform that operation.
isPermissionErrorType :: IOErrorType -> Bool
isPermissionErrorType PermissionDenied = True
isPermissionErrorType _ = False

-- | I\/O error that is programmer-defined.
isUserErrorType :: IOErrorType -> Bool
isUserErrorType UserError = True
isUserErrorType _ = False

-- -----------------------------------------------------------------------------
-- Miscellaneous

annotateIOError (IOError msg file hdl code) msg' file' hdl' =
    IOError (msg++'\n':msg') (file`mplus`file') (hdl`mplus`hdl') code
annotateIOError (EOFError msg hdl) msg' file' hdl' =
    EOFError (msg++'\n':msg') (hdl`mplus`hdl')
annotateIOError (UserError loc msg) msg' file' hdl' =
    UserError loc (msg++'\n':msg')
annotateIOError (PatternError loc) msg' file' hdl' =
    PatternError (loc++'\n':msg')
