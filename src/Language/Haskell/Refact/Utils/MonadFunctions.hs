{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE StandaloneDeriving #-}

-- |

-- This module provides the primary interface to the combined
-- AST/Tokens, and the functions here will ensure that any changes are
-- properly synced and propagated.

module Language.Haskell.Refact.Utils.MonadFunctions
       (
       -- * Conveniences for state access

       fetchAnnsFinal
       --  fetchLinesFinal
       , fetchOrigToks
       , fetchToks -- Deprecated
       , getTypecheckedModule
       , getRefactStreamModified
       , setRefactStreamModified
       , getRefactInscopes
       , getRefactRenamed
       , putRefactRenamed
       , getRefactParsed
       , putRefactParsed
       , addRefactAnns
       , setRefactAnns
       , getRefactAnns
       , putParsedModule
       , clearParsedModule
       , getRefactFileName
       , getRefactModule
       , getRefactNameMap

       -- * New ghc-exactprint interfacing
       , replaceRdrName

       -- * TokenUtils API
       , getToksForSpan

       -- * State flags for managing generic traversals
       , getRefactDone
       , setRefactDone
       , clearRefactDone

       , setStateStorage
       , getStateStorage

       -- * For use by the tests only
       , initRefactModule
       ) where

import Control.Monad.State
import Control.Exception
import Data.Maybe

import qualified FastString    as GHC
import qualified GHC           as GHC

import qualified Data.Generics as SYB
-- import qualified GHC.SYB.Utils as SYB

import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Utils

import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.Types
import Language.Haskell.Refact.Utils.ExactPrint

import qualified Data.Map as Map
import Control.Applicative

-- ---------------------------------------------------------------------

-- |fetch the possibly modified tokens. Deprecated
fetchToks :: RefactGhc [PosToken]
fetchToks = do
  Just _tm <- gets rsModule
  -- let toks = retrieveTokensInterim $ (tkCache $ rsTokenCache tm) Map.! mainTid
  -- logm $ "fetchToks" ++ (showToks toks)
  logm $ "fetchToks (not showing toks"
  -- return toks
  error $ "fetchToks no longer used"

-- |fetch the final annotations
fetchAnnsFinal :: RefactGhc Anns
fetchAnnsFinal = do
  Just tm <- gets rsModule
  let anns = (tkCache $ rsTokenCache tm) Map.! mainTid
  return anns

-- |fetch the pristine token stream
fetchOrigToks :: RefactGhc [PosToken]
fetchOrigToks = do
  logm "fetchOrigToks"
  Just tm <- gets rsModule
  return $ rsOrigTokenStream tm

-- |Get the current tokens for a given GHC.SrcSpan.
getToksForSpan ::  GHC.SrcSpan -> RefactGhc [PosToken]
getToksForSpan _sspan = do
  {-
  st <- get
  let checkInv = rsetCheckTokenUtilsInvariant $ rsSettings st
  let Just tm = rsModule st
  let (tk',toks) = getTokensNoIntrosFromCache checkInv (rsTokenCache tm) (gs2ss sspan)
  let rsModule' = Just (tm {rsTokenCache = tk'})
  put $ st { rsModule = rsModule' }
  logm $ "getToksForSpan " ++ (showGhc sspan) ++ ":" ++ (show (showSrcSpanF sspan,toks))
  return toks
  -}
  error $ "getToksForSpan no longer used"


-- ---------------------------------------------------------------------

getTypecheckedModule :: RefactGhc GHC.TypecheckedModule
getTypecheckedModule = do
  mtm <- gets rsModule
  case mtm of
    Just tm -> return $ rsTypecheckedMod tm
    Nothing -> error "HaRe: file not loaded for refactoring"

getRefactStreamModified :: RefactGhc RefacResult
getRefactStreamModified = do
  Just tm <- gets rsModule
  return $ rsStreamModified tm

-- |For testing
setRefactStreamModified :: RefacResult -> RefactGhc ()
setRefactStreamModified rr = do
  st <- get
  let (Just tm) = rsModule st
  put $ st { rsModule = Just (tm { rsStreamModified = rr })}
  return ()

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

putRefactParsed :: GHC.ParsedSource -> Anns -> RefactGhc ()
putRefactParsed parsed newAnns = do
  st <- get
  mrm <- gets rsModule
  let rm = gfromJust "putRefactParsed" mrm
  let tm = rsTypecheckedMod rm
  -- let tk' = modifyAnns (rsTokenCache rm) (const newAnns)
  let tk' = modifyAnns (rsTokenCache rm) (unionAnns newAnns)

  let pm = (GHC.tm_parsed_module tm) { GHC.pm_parsed_source = parsed }
  let tm' = tm { GHC.tm_parsed_module = pm }
  let rm' = rm { rsTypecheckedMod = tm', rsTokenCache = tk', rsStreamModified = RefacModified }
  put $ st {rsModule = Just rm'}

getRefactAnns :: RefactGhc Anns
getRefactAnns =
  (Map.! mainTid) . tkCache . rsTokenCache . gfromJust "getRefactAnns"
    <$> gets rsModule

setRefactAnns :: Anns -> RefactGhc ()
setRefactAnns anns = modifyRefactAnns (const anns)

addRefactAnns :: Anns -> RefactGhc ()
addRefactAnns newAnns = modifyRefactAnns (unionAnns newAnns)

-- | Combine the new with old, such that the new take priority
unionAnns :: Anns -> Anns -> Anns
unionAnns = mergeAnns

modifyRefactAnns :: (Anns -> Anns) -> RefactGhc ()
modifyRefactAnns f = do
  st <- get
  mrm <- gets rsModule
  let rm = gfromJust "modifyRefactAnns" mrm
  let tk' = modifyAnns (rsTokenCache rm) f
  let rm' = rm { rsTokenCache = tk', rsStreamModified = RefacModified }
  put $ st {rsModule = Just rm'}


modifyAnns :: TokenCache Anns -> (Anns -> Anns) -> TokenCache Anns
modifyAnns tk f = tk'
  where
    anns = (tkCache tk) Map.! mainTid
    tk' = tk {tkCache = Map.insert mainTid
                                   (f anns)
                                   (tkCache tk) }

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

-- |Replace the Located RdrName in the ParsedSource
replaceRdrName :: GHC.Located GHC.RdrName -> RefactGhc ()
replaceRdrName (GHC.L l newName) = do
  -- ++AZ++ TODO: move this body to somewhere appropriate
  logm $ "replaceRdrName:" ++ showGhcQual (l,newName)
  parsed <- getRefactParsed
  anns <- getRefactAnns
  logm $ "replaceRdrName:before:parsed=" ++ showGhc parsed
  let replaceRdr :: GHC.Located GHC.RdrName -> State Anns (GHC.Located GHC.RdrName)
      replaceRdr old@(GHC.L ln _)
        | l == ln = do
           an <- get
           let new = (GHC.L l newName)
           put $ replaceAnnKey an old new
           return new
      replaceRdr x = return x

      replaceHsVar :: GHC.LHsExpr GHC.RdrName -> State Anns (GHC.LHsExpr GHC.RdrName)
      replaceHsVar (GHC.L ln (GHC.HsVar _))
        | l == ln = return (GHC.L l (GHC.HsVar newName))
      replaceHsVar x = return x

      replaceHsTyVar (GHC.L ln (GHC.HsTyVar _))
        | l == ln = return (GHC.L l (GHC.HsTyVar newName))
      replaceHsTyVar x = return x

      replacePat (GHC.L ln (GHC.VarPat _))
        | l == ln = return (GHC.L l (GHC.VarPat newName))
      replacePat x = return x

      fn :: State Anns GHC.ParsedSource
      fn = do
             r <- SYB.everywhereM (SYB.mkM replaceRdr
                              `SYB.extM` replaceHsTyVar
                              `SYB.extM` replaceHsVar
                              `SYB.extM` replacePat) parsed
             return r
      (parsed',anns') = runState fn anns
  logm $ "replaceRdrName:after:parsed'=" ++ showGhc parsed'
  putRefactParsed parsed' mempty
  setRefactAnns anns'
  return ()

-- ---------------------------------------------------------------------

getRefactFileName :: RefactGhc (Maybe FilePath)
getRefactFileName = do
  mtm <- gets rsModule
  case mtm of
    Nothing  -> return Nothing
    Just _tm -> do toks <- fetchOrigToks
                   return $ Just (GHC.unpackFS $ fileNameFromTok $ ghead "getRefactFileName" toks)

-- ---------------------------------------------------------------------

getRefactModule :: RefactGhc GHC.Module
getRefactModule = do
  mtm <- gets rsModule
  case mtm of
    Nothing  -> error $ "Hare.MonadFunctions.getRefactModule:no module loaded"
    Just tm -> do
      let t  = rsTypecheckedMod tm
      let pm = GHC.tm_parsed_module t
      return (GHC.ms_mod $ GHC.pm_mod_summary pm)

-- ---------------------------------------------------------------------

getRefactNameMap :: RefactGhc NameMap
getRefactNameMap = do
  mtm <- gets rsModule
  case mtm of
    Nothing  -> error $ "Hare.MonadFunctions.getRefacNameMap:no module loaded"
    Just tm -> return (rsNameMap tm)

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

initRefactModule
  :: GHC.TypecheckedModule -> [PosToken] -> Maybe RefactModule
initRefactModule tm toks
  = Just (RefMod { rsTypecheckedMod = tm
                 , rsOrigTokenStream = toks
                 , rsNameMap = initRdrNameMap tm
                 , rsTokenCache = initTokenCacheLayout (annotateAST
                                    (GHC.pm_parsed_source $ GHC.tm_parsed_module tm)
                                    (GHC.pm_annotations $ GHC.tm_parsed_module tm))
                 , rsStreamModified = RefacUnmodifed
                 })


initTokenCacheLayout :: a -> TokenCache a
initTokenCacheLayout a = TK (Map.fromList [((TId 0),a)]) (TId 0)

initRdrNameMap :: GHC.TypecheckedModule -> NameMap
initRdrNameMap tm = r
  where
    parsed  = GHC.pm_parsed_source $ GHC.tm_parsed_module tm
    renamed = gfromJust "initRdrNameMap" $ GHC.tm_renamed_source tm
    isLocatedRdrName :: GHC.Located GHC.RdrName -> Bool
    isLocatedRdrName _ = True

    isLocatedName :: GHC.Located GHC.Name -> Bool
    isLocatedName _ = True

    rdrNames = SYB.listify isLocatedRdrName parsed
    names    = SYB.listify isLocatedName    renamed

    nameMap = Map.fromList $ map (\(GHC.L l n) -> (l,n)) names

    r1 = Map.fromList $ map (\lr@(GHC.L l r) -> (lr,Map.lookup l nameMap)) rdrNames
    r = Map.map (fromMaybe (error "initRdrNameMap:no val")) r1

-- ---------------------------------------------------------------------
{-
updateToks :: (SYB.Data t)
  => GHC.Located t -- ^ Old element
  -> GHC.Located t -- ^ New element
  -> (GHC.Located t -> [Char]) -- ^ pretty printer
  -> Bool         -- ^ Add trailing newline if required
  -> RefactGhc () -- ^ Updates the RefactState
updateToks (GHC.L sspan _) newAST printFun addTrailingNl
  = do
       logm $ "updateToks " ++ (showGhc sspan) ++ ":" ++ (show (showSrcSpanF sspan))
       let newToks = basicTokenise (printFun newAST)
       let newToks' = if addTrailingNl
                       then newToks ++ [newLnToken (last newToks)]
                       else newToks
       void $ putToksForSpan sspan  newToks'
       return ()
-}
-- ---------------------------------------------------------------------
{-
updateToksWithPos :: (SYB.Data t)
  => (SimpPos, SimpPos) -- ^Start and end pos of old element
  -> t             -- ^ New element
  -> (t -> [Char]) -- ^ pretty printer
  -> Bool          -- ^ Add trailing newline if required
  -> RefactGhc ()  -- ^ Updates the RefactState
updateToksWithPos (startPos,endPos) newAST printFun addTrailingNl
  = do
       -- newToks <- liftIO $ basicTokenise (printFun newAST)
       let newToks = basicTokenise (printFun newAST)
       let newToks' = if addTrailingNl
                       then newToks ++ [newLnToken (last newToks)]
                       else newToks
       void $ putToksForPos (startPos,endPos) newToks'

       return ()
-}
-- EOF
