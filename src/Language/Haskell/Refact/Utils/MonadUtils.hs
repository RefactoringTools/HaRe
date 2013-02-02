{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
module Language.Haskell.Refact.Utils.MonadUtils
       ( 
          initRefactModule

       -- * Conveniences for state access
       , fetchToks
       , fetchOrigToks
       , putToks
       , getTypecheckedModule
       , getRefactStreamModified
       , getRefactInscopes
       , getRefactRenamed
       , putRefactRenamed
       , getRefactParsed
       , putParsedModule
       , clearParsedModule

       -- * State flags for managing generic traversals
       , getRefactDone
       , setRefactDone
       , clearRefactDone

       -- , Refact -- ^ TODO: Deprecated, use RefactGhc
       -- , runRefact -- ^ TODO: Deprecated, use runRefactGhc
       ) where

import Control.Monad.State
import Data.Maybe
import Exception
import qualified Control.Monad.IO.Class as MU

import qualified Bag           as GHC
import qualified BasicTypes    as GHC
import qualified DynFlags      as GHC
import qualified FastString    as GHC
import qualified GHC           as GHC
import qualified GhcMonad      as GHC
import qualified GHC.Paths     as GHC
import qualified HsSyn         as GHC
import qualified Module        as GHC
import qualified MonadUtils    as GHC
import qualified Outputable    as GHC
import qualified RdrName       as GHC
import qualified SrcLoc        as GHC
import qualified TcEvidence    as GHC
import qualified TcType        as GHC
import qualified TypeRep       as GHC
import qualified Var           as GHC
import qualified Lexer         as GHC
import qualified Coercion      as GHC
import qualified ForeignCall   as GHC
import qualified InstEnv       as GHC

import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn

import Data.Tree

-- ---------------------------------------------------------------------

fetchToks :: RefactGhc [PosToken]
fetchToks = do
  Just tm <- gets rsModule
  return $ retrieveTokens $ rsTokenCache tm

fetchOrigToks :: RefactGhc [PosToken]
fetchOrigToks = do
  Just tm <- gets rsModule
  return $ rsOrigTokenStream tm

putToks :: [PosToken] -> Bool -> RefactGhc ()
putToks toks isModified = do
  error "MonadUtils.putToks: need to put toks into rsTokenCache"
  {-
  st <- get
  let Just tm = rsModule st
  let rsModule' = Just (tm {rsTokenStream = toks, rsStreamModified = isModified})
  put $ st { rsModule = rsModule' }
  -}

-- ---------------------------------------------------------------------

getTypecheckedModule :: RefactGhc GHC.TypecheckedModule
getTypecheckedModule = do
  Just tm <- gets rsModule
  return $ rsTypecheckedMod tm

getRefactStreamModified :: RefactGhc Bool
getRefactStreamModified = do
  Just tm <- gets rsModule
  return $ rsStreamModified tm

getRefactInscopes :: RefactGhc InScopes
getRefactInscopes = GHC.getNamesInScope

getRefactRenamed :: RefactGhc GHC.RenamedSource
getRefactRenamed = do
  mtm <- gets rsModule
  let tm = gfromJust "getRefactRenamed" mtm
  return $ gfromJust "getRefactRenamed2" $ GHC.tm_renamed_source $ rsTypecheckedMod tm

putRefactRenamed :: GHC.RenamedSource -> RefactGhc ()
putRefactRenamed renamed = do
  st <- get
  mrm <- gets rsModule
  let rm = gfromJust "putRefactRenamed" mrm
  let tm = rsTypecheckedMod rm
  let tm' = tm { GHC.tm_renamed_source = Just renamed }
  let rm' = rm { rsTypecheckedMod = tm' }
  put $ st {rsModule = Just rm'}

getRefactParsed :: RefactGhc GHC.ParsedSource
getRefactParsed = do
  mtm <- gets rsModule
  let tm = gfromJust "getRefactParsed" mtm
  let t  = rsTypecheckedMod tm

  let pm = GHC.tm_parsed_module t
  return $ GHC.pm_parsed_source pm

putParsedModule
  :: GHC.TypecheckedModule -> [PosToken] -> RefactGhc ()
putParsedModule tm toks = do
  st <- get
  put $ st { rsModule = initRefactModule tm toks }

clearParsedModule :: RefactGhc ()
clearParsedModule = do
  st <- get
  put $ st { rsModule = Nothing }


-- ---------------------------------------------------------------------

getRefactDone :: RefactGhc Bool
getRefactDone = do
  flags <- gets rsFlags
  return (rsDone flags)

setRefactDone :: RefactGhc ()
setRefactDone = do
  st <- get
  put $ st { rsFlags = RefFlags True }

clearRefactDone :: RefactGhc ()
clearRefactDone = do
  st <- get
  put $ st { rsFlags = RefFlags False }

-- ---------------------------------------------------------------------

initRefactModule
  :: GHC.TypecheckedModule -> [PosToken] -> Maybe RefactModule
initRefactModule tm toks 
  = Just (RefMod { rsTypecheckedMod = tm
                 , rsOrigTokenStream = toks
                 , rsTokenCache = mkTreeFromTokens toks
                 , rsStreamModified = False
                 })


-- EOF

