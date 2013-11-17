{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}

-- |

-- This module provides the primary interface to the combined
-- AST/Tokens, and the functions here will ensure that any changes are
-- properly synced and propagated.

module Language.Haskell.Refact.Utils.MonadFunctions
       (
       -- * Conveniences for state access

         fetchToksFinal
       , fetchPprFinal
       , fetchOrigToks
       , fetchToks -- Deprecated
       -- , putToks -- ^Deprecated, destroys token tree
       , getTypecheckedModule
       , getRefactStreamModified
       , getRefactInscopes
       , getRefactRenamed
       , putRefactRenamed
       , getRefactParsed
       , putParsedModule
       , clearParsedModule
       , getRefactFileName

       -- * TokenUtils API
       , replaceToken
       , putToksForSpan
       , getToksForSpan
       , getToksForSpanNoInv
       , getToksForSpanWithIntros
       , getToksBeforeSpan
       , putToksForPos
       , putToksAfterSpan
       , putToksAfterPos
       , putDeclToksAfterSpan
       , removeToksForSpan
       , removeToksForPos
       , syncDeclToLatestStash
       , indentDeclAndToks

       -- * LayoutUtils API
       -- , getLayoutForSpan
       -- , putDeclLayoutAfterSpan

       -- * For debugging
       , drawTokenTree
       , drawTokenTreeDetailed
       , getTokenTree

       -- * State flags for managing generic traversals
       , getRefactDone
       , setRefactDone
       , clearRefactDone

       , setStateStorage
       , getStateStorage

       , logm

       , updateToks
       , updateToksWithPos

       -- * For use by the tests only
       , initRefactModule
       ) where

import Control.Monad.State

import qualified FastString    as GHC
import qualified GHC           as GHC

import qualified Data.Data as SYB

import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Layout
import Language.Haskell.Refact.Utils.LayoutTypes
import Language.Haskell.Refact.Utils.LayoutUtils
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn

import Data.Time.Clock
import Data.Tree
import System.Log.Logger
import qualified Data.Map as Map

-- ---------------------------------------------------------------------

-- |fetch the possibly modified tokens. Deprecated
fetchToks :: RefactGhc [PosToken]
fetchToks = do
  Just tm <- gets rsModule
  let toks = retrieveTokensInterim $ (tkCache $ rsTokenCache tm) Map.! mainTid
  -- logm $ "fetchToks" ++ (showToks toks)
  logm $ "fetchToks (not showing toks"
  return toks

-- |fetch the final tokens
fetchToksFinal :: RefactGhc [PosToken]
fetchToksFinal = do
  Just tm <- gets rsModule
  let toks = retrieveTokensFinal $ (tkCache $ rsTokenCache tm) Map.! mainTid
  -- logm $ "fetchToks" ++ (showToks toks)
  logm $ "fetchToksFinal (not showing toks)"
  return toks

-- |fetch the final tokens in Ppr format
fetchPprFinal :: RefactGhc [Ppr]
fetchPprFinal = do
  Just tm <- gets rsModule
  let pprVal = retrieveTokensPpr $ (tkCache $ rsTokenCache tm) Map.! mainTid
  -- logm $ "fetchToks" ++ (showToks toks)
  logm $ "fetchPprFinal (not showing ppr)"
  return pprVal

-- |fetch the pristine token stream
fetchOrigToks :: RefactGhc [PosToken]
fetchOrigToks = do
  logm "fetchOrigToks"
  Just tm <- gets rsModule
  return $ rsOrigTokenStream tm

-- |Get the current tokens for a given GHC.SrcSpan.
getToksForSpan ::  GHC.SrcSpan -> RefactGhc [PosToken]
getToksForSpan sspan = do
  st <- get
  let checkInv = rsetCheckTokenUtilsInvariant $ rsSettings st
  let Just tm = rsModule st
  let forest = getTreeFromCache sspan (rsTokenCache tm)
  -- let (forest',toks) = getTokensFor checkInv forest sspan
  let (forest',toks) = getTokensForNoIntros checkInv forest sspan
  let tk' = replaceTreeInCache sspan forest' $ rsTokenCache tm
  let rsModule' = Just (tm {rsTokenCache = tk'})
  put $ st { rsModule = rsModule' }
  logm $ "getToksForSpan " ++ (showGhc sspan) ++ ":" ++ (show (showSrcSpanF sspan,toks))
  return toks

-- |Get the current tokens for a given GHC.SrcSpan, without checking
-- the invariant.
-- TODO: this should not be necessary
getToksForSpanNoInv ::  GHC.SrcSpan -> RefactGhc [PosToken]
getToksForSpanNoInv sspan = do
  st <- get
  let checkInv = False
  let Just tm = rsModule st
  let forest = getTreeFromCache sspan (rsTokenCache tm)
  let (forest',toks) = getTokensFor checkInv forest sspan
  -- let (forest',toks) = getTokensForNoIntros checkInv forest sspan
  let tk' = replaceTreeInCache sspan forest' $ rsTokenCache tm
  let rsModule' = Just (tm {rsTokenCache = tk'})
  put $ st { rsModule = rsModule' }
  logm $ "getToksForSpan " ++ (showGhc sspan) ++ ":" ++ (show (showSrcSpanF sspan,toks))
  return toks


-- |Get the current tokens for a given GHC.SrcSpan, leaving out any
-- leading 'then', 'else', 'of', 'do' or 'in' tokens
getToksForSpanWithIntros ::  GHC.SrcSpan -> RefactGhc [PosToken]
getToksForSpanWithIntros sspan = do
  st <- get
  let checkInv = rsetCheckTokenUtilsInvariant $ rsSettings st
  let Just tm = rsModule st
  let forest = getTreeFromCache sspan (rsTokenCache tm)
  let (forest',toks) = getTokensFor checkInv forest sspan
  let tk' = replaceTreeInCache sspan forest' $ rsTokenCache tm
  let rsModule' = Just (tm {rsTokenCache = tk'})
  put $ st { rsModule = rsModule' }
  logm $ "getToksForSpanNoIntros " ++ (showGhc sspan) ++ ":" ++ (show (showSrcSpanF sspan,toks))
  return toks

-- |Get the current tokens preceding a given GHC.SrcSpan.
getToksBeforeSpan ::  GHC.SrcSpan -> RefactGhc ReversedToks
getToksBeforeSpan sspan = do
  st <- get
  let Just tm = rsModule st
  let forest = getTreeFromCache sspan (rsTokenCache tm)
  let (forest',toks) = getTokensBefore forest sspan
  let tk' = replaceTreeInCache sspan forest' $ rsTokenCache tm
  let rsModule' = Just (tm {rsTokenCache = tk'})
  put $ st { rsModule = rsModule' }
  logm $ "getToksBeforeSpan " ++ (showGhc sspan) ++ ":" ++ (show (showSrcSpanF sspan,toks))
  return toks


-- |Replace a token occurring in a given GHC.SrcSpan
replaceToken ::  GHC.SrcSpan -> PosToken -> RefactGhc ()
replaceToken sspan tok = do
  logm $ "replaceToken " ++ (showGhc sspan) ++ ":" ++ (showSrcSpanF sspan) ++ (show tok)
  st <- get
  let Just tm = rsModule st

  let tk' = replaceTokenInCache (rsTokenCache tm) sspan tok
  let rsModule' = Just (tm {rsTokenCache = tk', rsStreamModified = True })
  put $ st { rsModule = rsModule' }
  return ()

-- |Replace the tokens for a given GHC.SrcSpan, return new GHC.SrcSpan
-- delimiting new tokens
putToksForSpan ::  GHC.SrcSpan -> [PosToken] -> RefactGhc GHC.SrcSpan
putToksForSpan sspan toks = do
  logm $ "putToksForSpan " ++ (showGhc sspan) ++ ":" ++ (showSrcSpanF sspan) ++ (show toks)
  st <- get
  let Just tm = rsModule st

  let (tk',newSpan) = putToksInCache (rsTokenCache tm) sspan toks
  let rsModule' = Just (tm {rsTokenCache = tk', rsStreamModified = True })
  put $ st { rsModule = rsModule' }
  return newSpan

-- |Replace the tokens for a given GHC.SrcSpan, return GHC.SrcSpan
-- they are placed in
putToksForPos ::  (SimpPos,SimpPos) -> [PosToken] -> RefactGhc GHC.SrcSpan
putToksForPos pos toks = do
  logm $ "putToksForPos " ++ (show pos) ++ (showToks toks)
  st <- get
  let Just tm = rsModule st
  let mainForest = (tkCache $ rsTokenCache tm) Map.! mainTid
  let sspan = posToSrcSpan mainForest pos
  let (tk',newSpan) = putToksInCache (rsTokenCache tm) sspan toks
  let rsModule' = Just (tm {rsTokenCache = tk', rsStreamModified = True })
  put $ st { rsModule = rsModule' }
  drawTokenTree ""
  return newSpan

-- |Add tokens after a designated GHC.SrcSpan
putToksAfterSpan :: GHC.SrcSpan -> Positioning -> [PosToken] -> RefactGhc GHC.SrcSpan
putToksAfterSpan oldSpan pos toks = do
  logm $ "putToksAfterSpan " ++ (showGhc oldSpan) ++ ":" ++ (showSrcSpanF oldSpan) ++ " at " ++ (show pos) ++ ":" ++ (showToks toks)
  st <- get
  let Just tm = rsModule st
  let forest = getTreeFromCache oldSpan (rsTokenCache tm)
  let (forest',newSpan) = addToksAfterSrcSpan forest oldSpan pos toks
  let tk' = replaceTreeInCache oldSpan forest' $ rsTokenCache tm
  let rsModule' = Just (tm {rsTokenCache = tk', rsStreamModified = True})
  put $ st { rsModule = rsModule' }
  return newSpan

-- |Add tokens after a designated position
putToksAfterPos :: (SimpPos,SimpPos) -> Positioning -> [PosToken] -> RefactGhc GHC.SrcSpan
putToksAfterPos pos position toks = do
  logm $ "putToksAfterPos " ++ (show pos) ++ " at "  ++ (show position) ++ ":" ++ (show toks)
  st <- get
  let Just tm = rsModule st
  let mainForest = (tkCache $ rsTokenCache tm) Map.! mainTid
  let sspan = posToSrcSpan mainForest pos
  let forest = getTreeFromCache sspan (rsTokenCache tm)
  let (forest',newSpan) = addToksAfterSrcSpan forest sspan position toks
  let tk' = replaceTreeInCache sspan forest' $ rsTokenCache tm
  let rsModule' = Just (tm {rsTokenCache = tk', rsStreamModified = True})
  put $ st { rsModule = rsModule' }
  logm $ "putToksAfterPos result:" ++ (show forest') ++ "\ntree:\n" ++ (drawTreeEntry forest')
  return newSpan

-- |Add tokens after a designated GHC.SrcSpan, and update the AST
-- fragment to reflect it
putDeclToksAfterSpan :: (SYB.Data t) => GHC.SrcSpan -> GHC.Located t -> Positioning -> [PosToken] -> RefactGhc (GHC.Located t)
putDeclToksAfterSpan oldSpan t pos toks = do
  logm $ "putDeclToksAfterSpan " ++ (showGhc oldSpan) ++ ":" ++ (show (showSrcSpanF oldSpan,pos,toks))
  st <- get
  let Just tm = rsModule st
  let forest = getTreeFromCache oldSpan (rsTokenCache tm)
  let (forest',_newSpan, t') = addDeclToksAfterSrcSpan forest oldSpan pos toks t
  let tk' = replaceTreeInCache oldSpan forest' (rsTokenCache tm)
  let rsModule' = Just (tm {rsTokenCache = tk', rsStreamModified = True})
  put $ st { rsModule = rsModule' }
  return t'

-- |Remove a GHC.SrcSpan and its associated tokens
removeToksForSpan :: GHC.SrcSpan -> RefactGhc ()
removeToksForSpan sspan = do
  logm $ "removeToksForSpan " ++ (showGhc sspan) ++ ":" ++ (showSrcSpanF sspan)
  st <- get
  let Just tm = rsModule st
  let tk' = removeToksFromCache (rsTokenCache tm) sspan
  let rsModule' = Just (tm {rsTokenCache = tk', rsStreamModified = True})
  put $ st { rsModule = rsModule' }
  return ()

-- |Remove a GHC.SrcSpan and its associated tokens
removeToksForPos :: (SimpPos,SimpPos) -> RefactGhc ()
removeToksForPos pos = do
  logm $ "removeToksForPos " ++ (show pos)
  st <- get
  let Just tm = rsModule st
  let mainForest = (tkCache $ rsTokenCache tm) Map.! mainTid
  let sspan = posToSrcSpan mainForest pos
  let tk' = removeToksFromCache (rsTokenCache tm) sspan
  let rsModule' = Just (tm {rsTokenCache = tk', rsStreamModified = True})
  put $ st { rsModule = rsModule' }
  drawTokenTree "removeToksForPos result"
  return ()

-- ---------------------------------------------------------------------

-- |Print the Token Tree for debug purposes
drawTokenTree :: String -> RefactGhc ()
drawTokenTree msg = do
  st <- get
  let Just tm = rsModule st
  -- let mainForest = (tkCache $ rsTokenCache tm) Map.! mainTid
  -- logm $ msg ++ "\ncurrent token tree:\n" ++ (drawTreeEntry mainForest)
  logm $ msg ++ "\ncurrent token tree:\n" ++ (drawTokenCache (rsTokenCache tm))
  return ()

-- ---------------------------------------------------------------------

-- |Print detailed Token Tree for debug purposes
drawTokenTreeDetailed :: String -> RefactGhc ()
drawTokenTreeDetailed msg = do
  st <- get
  let Just tm = rsModule st
  logm $ msg ++ "\ncurrent detailed token tree:\n" ++ (drawTokenCacheDetailed (rsTokenCache tm))
  return ()

-- ---------------------------------------------------------------------

-- |Get the Token Tree for debug purposes
getTokenTree :: RefactGhc (Tree Entry)
getTokenTree = do
  st <- get
  let Just tm = rsModule st
  let mainForest = (tkCache $ rsTokenCache tm) Map.! mainTid
  return mainForest

-- ---------------------------------------------------------------------

syncDeclToLatestStash :: (SYB.Data t) => (GHC.Located t) -> RefactGhc (GHC.Located t)
syncDeclToLatestStash t = do
  st <- get
  let Just tm = rsModule st
  let t' = syncAstToLatestCache (rsTokenCache tm) t
  return t'

-- ---------------------------------------------------------------------

-- | Indent an AST fragment and its associated tokens by a set amount
indentDeclAndToks :: (SYB.Data t) => (GHC.Located t) -> Int -> RefactGhc (GHC.Located t)
indentDeclAndToks t offset = do
  let (GHC.L sspan _) = t
  logm $ "indentDeclAndToks " ++ (showGhc sspan) ++ ":" ++ (showSrcSpanF sspan) ++ ",offset=" ++ show offset
  st <- get
  let Just tm = rsModule st
  let tk = rsTokenCache tm
  let forest = (tkCache tk) Map.! mainTid
  let (t',forest') = indentDeclToks t forest offset
  let tk' = tk {tkCache = Map.insert mainTid forest' (tkCache tk) }
  let rsModule' = Just (tm {rsTokenCache = tk', rsStreamModified = True})
  put $ st { rsModule = rsModule' }
  drawTokenTree "indentDeclToks result"
  return t'

-- =====================================================================
-- Layout Tree stuff
-- ---------------------------------------------------------------------
{-
getLayoutForSpan :: GHC.SrcSpan -> RefactGhc LayoutTree
getLayoutForSpan sspan = do
  st <- get
  let Just tm = rsModule st
  let lay = getLayoutFor sspan (rsTokenLayout tm)
  logm $ "getLayoutForSpan " ++ (showGhc sspan) ++ ":" ++ (showGhc lay)
  return lay
-}
{-
putDeclLayoutAfterSpan :: (SYB.Data t)
   => GHC.SrcSpan -> GHC.Located t -> Positioning -> LayoutTree
   -> RefactGhc (GHC.Located t)
putDeclLayoutAfterSpan oldSpan t pos lay = do
  logm $ "putDeclLayoutAfterSpan " ++ (showGhc oldSpan) ++ ":" ++ (show (showSrcSpanF oldSpan,pos,lay))
  st <- get
  let Just tm = rsModule st
  let (TL layoutTree) = rsTokenLayout tm
  let (tl',_newSpan, t') = addDeclLayoutAfterSrcSpan layoutTree oldSpan pos lay t
  let rsModule' = Just (tm {rsTokenLayout = tl', rsStreamModified = True})
  put $ st { rsModule = rsModule' }
  return t'
-}

-- =====================================================================

getTypecheckedModule :: RefactGhc GHC.TypecheckedModule
getTypecheckedModule = do
  mtm <- gets rsModule
  case mtm of
    Just tm -> return $ rsTypecheckedMod tm
    Nothing -> error "HaRe: file not loaded for refactoring"

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

getRefactFileName :: RefactGhc (Maybe FilePath)
getRefactFileName = do
  mtm <- gets rsModule
  case mtm of
    Nothing  -> return Nothing
    Just _tm -> do toks <- fetchOrigToks
                   return $ Just (GHC.unpackFS $ fileNameFromTok $ ghead "getRefactFileName" toks)

-- ---------------------------------------------------------------------

getRefactDone :: RefactGhc Bool
getRefactDone = do
  flags <- gets rsFlags
  logm $ "getRefactDone: " ++ (show (rsDone flags))
  return (rsDone flags)

setRefactDone :: RefactGhc ()
setRefactDone = do
  logm $ "setRefactDone"
  st <- get
  put $ st { rsFlags = RefFlags True }

clearRefactDone :: RefactGhc ()
clearRefactDone = do
  logm $ "clearRefactDone"
  st <- get
  put $ st { rsFlags = RefFlags False }

-- ---------------------------------------------------------------------

setStateStorage :: StateStorage -> RefactGhc ()
setStateStorage storage = do
  st <- get
  put $ st { rsStorage = storage }

getStateStorage :: RefactGhc StateStorage
getStateStorage = do
  storage <- gets rsStorage
  return storage

-- ---------------------------------------------------------------------

logm :: String -> RefactGhc ()
logm string = do
  settings <- getRefacSettings
  let loggingOn = (rsetVerboseLevel settings == Debug)
             --     || (rsetVerboseLevel settings == Normal)
  when loggingOn $ do
     -- ts <- liftIO timeStamp
     -- liftIO $ warningM "HaRe" (ts ++ ":" ++ string)
     liftIO $ warningM "HaRe" (string)
  return ()

timeStamp :: IO String
timeStamp = do
  k <- getCurrentTime
  return (show k)

-- ---------------------------------------------------------------------

initRefactModule
  :: GHC.TypecheckedModule -> [PosToken] -> Maybe RefactModule
initRefactModule tm toks
  = Just (RefMod { rsTypecheckedMod = tm
                 , rsOrigTokenStream = toks
                 -- , rsTokenCache = initTokenCache toks
                 , rsTokenCache = initTokenCacheLayout (initTokenLayout
                                    (GHC.pm_parsed_source $ GHC.tm_parsed_module tm) 
                                    toks)
                 , rsStreamModified = False
                 })

-- ---------------------------------------------------------------------

updateToks :: (SYB.Data t)
  => GHC.Located t -- ^ Old element
  -> GHC.Located t -- ^ New element
  -> (GHC.Located t -> [Char]) -- ^ pretty printer
  -> Bool         -- ^ Add trailing newline if required
  -> RefactGhc () -- ^ Updates the RefactState
updateToks (GHC.L sspan _) newAST printFun addTrailingNl
  = do
       logm $ "updateToks " ++ (showGhc sspan) ++ ":" ++ (show (showSrcSpanF sspan))  
       newToks <- liftIO $ basicTokenise (printFun newAST)
       let newToks' = if addTrailingNl
                       then newToks ++ [newLnToken (last newToks)]
                       else newToks
       void $ putToksForSpan sspan  newToks'
       return ()

-- ---------------------------------------------------------------------

updateToksWithPos :: (SYB.Data t)
  => (SimpPos, SimpPos) -- ^Start and end pos of old element
  -> t             -- ^ New element
  -> (t -> [Char]) -- ^ pretty printer
  -> Bool          -- ^ Add trailing newline if required
  -> RefactGhc ()  -- ^ Updates the RefactState
updateToksWithPos (startPos,endPos) newAST printFun addTrailingNl
  = do
       -- newToks <- liftIO $ basicTokenise (printFun newAST)
       newToks <- liftIO $ basicTokenise (printFun newAST)
       let newToks' = if addTrailingNl
                       then newToks ++ [newLnToken (last newToks)]
                       else newToks
       putToksForPos (startPos,endPos) newToks'

       return ()

-- EOF

