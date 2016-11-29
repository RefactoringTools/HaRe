{-# LANGUAGE CPP #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StandaloneDeriving #-}

{-# OPTIONS_GHC -fno-warn-orphans #-} -- For HasTransform

-- |

-- This module provides the primary interface to the combined
-- AST/Tokens, and the functions here will ensure that any changes are
-- properly synced and propagated.

module Language.Haskell.Refact.Utils.MonadFunctions
       (
       -- * Conveniences for state access

         fetchAnnsFinal
       , getTypecheckedModule

       , getRefactStreamModified
       , setRefactStreamModified

       , getRefactInscopes

       , getRefactRenamed
       , putRefactRenamed

       , getRefactParsed
       , putRefactParsed

       -- * Annotations
       -- , addRefactAnns
       , setRefactAnns

       -- *
       , putParsedModule
       , clearParsedModule
       , getRefactFileName
       , getRefactTargetModule
       , getRefactModule
       , getRefactModuleName
       , getRefactNameMap
       , addToNameMap

       -- * New ghc-exactprint interfacing
       , liftT

       -- * State flags for managing generic traversals
       , getRefactDone
       , setRefactDone
       , clearRefactDone

       , setStateStorage
       , getStateStorage

       -- * Parsing source
       , parseDeclWithAnns

       -- * Utility
       , nameSybTransform, nameSybQuery
       , fileNameFromModSummary
       , mkNewGhcNamePure

       , logDataWithAnns
       , logAnns
       , logParsedSource
       , logExactprint
       , logAst

       -- * For use by the tests only
       , initRefactModule
       , initTokenCacheLayout
       , initRdrNameMap
       ) where

import Control.Monad.State
import Data.List

import qualified GHC           as GHC
import qualified GhcMonad      as GHC
import qualified Module        as GHC
import qualified Name          as GHC
import qualified Unique        as GHC
#if __GLASGOW_HASKELL__ > 710
import qualified Var
#endif

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Annotate
import Language.Haskell.GHC.ExactPrint.Parsers
import Language.Haskell.GHC.ExactPrint.Utils

import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.Types

import qualified Data.Map as Map

-- ---------------------------------------------------------------------

-- |fetch the final annotations
fetchAnnsFinal :: RefactGhc Anns
fetchAnnsFinal = do
  Just tm <- gets rsModule
  let anns = (tkCache $ rsTokenCache tm) Map.! mainTid
  return anns

-- ---------------------------------------------------------------------

getTypecheckedModule :: RefactGhc TypecheckedModule
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
  logm $ "setRefactStreamModified:rr=" ++ show rr
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
  return $ tmRenamedSource $ rsTypecheckedMod tm

putRefactRenamed :: GHC.RenamedSource -> RefactGhc ()
putRefactRenamed renamed = do
  st <- get
  mrm <- gets rsModule
  let rm = gfromJust "putRefactRenamed" mrm
  let tm = rsTypecheckedMod rm
  let tm' = tm { tmRenamedSource = renamed }
  let rm' = rm { rsTypecheckedMod = tm' }
  put $ st {rsModule = Just rm'}

getRefactParsed :: RefactGhc GHC.ParsedSource
getRefactParsed = do
  mtm <- gets rsModule
  let tm = gfromJust "getRefactParsed" mtm
  let t  = rsTypecheckedMod tm

  let pm = tmParsedModule t
  return $ GHC.pm_parsed_source pm

putRefactParsed :: GHC.ParsedSource -> Anns -> RefactGhc ()
putRefactParsed parsed newAnns = do
  logm $ "putRefactParsed:setting rsStreamModified"
  st <- get
  mrm <- gets rsModule
  let rm = gfromJust "putRefactParsed" mrm
  let tm = rsTypecheckedMod rm
  -- let tk' = modifyAnns (rsTokenCache rm) (const newAnns)
  let tk' = modifyAnns (rsTokenCache rm) (mergeAnns newAnns)

  let pm = (tmParsedModule tm) { GHC.pm_parsed_source = parsed }
  let tm' = tm { tmParsedModule = pm }
  let rm' = rm { rsTypecheckedMod = tm', rsTokenCache = tk', rsStreamModified = RefacModified }
  put $ st {rsModule = Just rm'}

-- ---------------------------------------------------------------------

-- |Internal low level interface to access the current annotations from the
-- RefactGhc state.
getRefactAnns :: RefactGhc Anns
getRefactAnns =
  (Map.! mainTid) . tkCache . rsTokenCache . gfromJust "getRefactAnns"
    <$> gets rsModule

-- |Internal low level interface to access the current annotations from the
-- RefactGhc state.
setRefactAnns :: Anns -> RefactGhc ()
setRefactAnns anns = modifyRefactAnns (const anns)

-- |Internal low level interface to access the current annotations from the
-- RefactGhc state.
modifyRefactAnns :: (Anns -> Anns) -> RefactGhc ()
modifyRefactAnns f = do
  -- logm $ "modifyRefactAnns:setting rsStreamModified"
  st <- get
  mrm <- gets rsModule
  let rm = gfromJust "modifyRefactAnns" mrm
  let tk' = modifyAnns (rsTokenCache rm) f
  let rm' = rm { rsTokenCache = tk', rsStreamModified = RefacModified }
  put $ st {rsModule = Just rm'}

-- |Internal low level interface to access the current annotations from the
-- RefactGhc state.
modifyAnns :: TokenCache Anns -> (Anns -> Anns) -> TokenCache Anns
modifyAnns tk f = tk'
  where
    anns = (tkCache tk) Map.! mainTid
    tk' = tk {tkCache = Map.insert mainTid
                                   (f anns)
                                   (tkCache tk) }

-- ----------------------------------------------------------------------

putParsedModule :: [Comment] -> TypecheckedModule -> RefactGhc ()
putParsedModule cppComments tm = do
  st <- get
  put $ st { rsModule = initRefactModule cppComments tm }

clearParsedModule :: RefactGhc ()
clearParsedModule = do
  st <- get
  put $ st { rsModule = Nothing }

-- ---------------------------------------------------------------------

{-
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
           put $ replaceAnnKey old new an
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
  putRefactParsed parsed' emptyAnns
  setRefactAnns anns'
  return ()
-}

-- ---------------------------------------------------------------------

refactRunTransformId :: Transform a -> RefactGhc a
refactRunTransformId transform = do
  u <- gets rsUniqState
  ans <- getRefactAnns
  let (a,(ans',u'),logLines) = runTransformFrom u ans transform
  putUnique u'
  setRefactAnns ans'
  when (not (null logLines)) $ do
    logm $ intercalate "\n" logLines
  return a

-- ---------------------------------------------------------------------

instance HasTransform RefactGhc where
  liftT = refactRunTransformId

-- ---------------------------------------------------------------------

putUnique :: Int -> RefactGhc ()
putUnique u = do
  s <- get
  put $ s { rsUniqState = u }

-- ---------------------------------------------------------------------

getRefactTargetModule :: RefactGhc TargetModule
getRefactTargetModule = do
  mt <- gets rsCurrentTarget
  case mt of
    Nothing -> error $ "HaRe:getRefactTargetModule:no module loaded"
    Just t -> return t

-- ---------------------------------------------------------------------

getRefactFileName :: RefactGhc (Maybe FilePath)
getRefactFileName = do
  mtm <- gets rsModule
  case mtm of
    Nothing  -> return Nothing
    Just tm -> return $ Just (fileNameFromModSummary $ GHC.pm_mod_summary
                              $ tmParsedModule $ rsTypecheckedMod tm)

-- ---------------------------------------------------------------------

fileNameFromModSummary :: GHC.ModSummary -> FilePath
fileNameFromModSummary modSummary = fileName
  where
    -- TODO: what if we are loading a compiled only client and do not
    -- have the original source?
    Just fileName = GHC.ml_hs_file (GHC.ms_location modSummary)

-- ---------------------------------------------------------------------

getRefactModule :: RefactGhc GHC.Module
getRefactModule = do
  mtm <- gets rsModule
  case mtm of
    Nothing  -> error $ "Hare.MonadFunctions.getRefactModule:no module loaded"
    Just tm -> do
      let t  = rsTypecheckedMod tm
      let pm = tmParsedModule t
      return (GHC.ms_mod $ GHC.pm_mod_summary pm)

-- ---------------------------------------------------------------------

getRefactModuleName :: RefactGhc GHC.ModuleName
getRefactModuleName = do
  modu <- getRefactModule
  return $ GHC.moduleName modu

-- ---------------------------------------------------------------------

getRefactNameMap :: RefactGhc NameMap
getRefactNameMap = do
  mtm <- gets rsModule
  case mtm of
    Nothing  -> error $ "Hare.MonadFunctions.getRefacNameMap:no module loaded"
    Just tm -> return (rsNameMap tm)

-- ---------------------------------------------------------------------

addToNameMap :: GHC.SrcSpan -> GHC.Name -> RefactGhc ()
addToNameMap ss n = do
  s <- get
  let mtm = rsModule s
  case mtm of
    Nothing  -> error $ "Hare.MonadFunctions.addToNameMap:no module loaded"
    Just tm -> do
      let nm = rsNameMap tm
          nm' = Map.insert ss n nm
          mtm' = Just tm { rsNameMap = nm'}
      put s { rsModule = mtm'}

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

logDataWithAnns :: (SYB.Data a) => String -> a -> RefactGhc ()
logDataWithAnns str ast = do
  anns <- getRefactAnns
  logm $ str ++ showAnnData anns 0 ast

-- ---------------------------------------------------------------------

logExactprint :: (Annotate a) => String -> GHC.Located a -> RefactGhc ()
logExactprint str ast = do
  anns <- getRefactAnns
  logm $ str ++ "\n[" ++ exactPrint ast anns ++ "]"

-- ---------------------------------------------------------------------

logAnns :: String -> RefactGhc ()
logAnns str = do
  anns <- getRefactAnns
  logm $ str ++ showGhc anns

-- ---------------------------------------------------------------------

logParsedSource :: String -> RefactGhc ()
logParsedSource str = do
  parsed <- getRefactParsed
  logDataWithAnns str parsed

-- ---------------------------------------------------------------------

logAst :: (SYB.Data a) => String -> a -> RefactGhc ()
logAst str a = logm $ str ++ "\n[" ++ (SYB.showData SYB.Parser 3 a) ++ "]"

-- ---------------------------------------------------------------------

initRefactModule :: [Comment] -> TypecheckedModule -> Maybe RefactModule
initRefactModule cppComments tm
  = Just (RefMod { rsTypecheckedMod = tm
                 , rsNameMap = initRdrNameMap tm
                 , rsTokenCache = initTokenCacheLayout (relativiseApiAnnsWithComments
                                     cppComments
                                    (GHC.pm_parsed_source $ tmParsedModule tm)
                                    (GHC.pm_annotations $ tmParsedModule tm))
                 , rsStreamModified = RefacUnmodifed
                 })


initTokenCacheLayout :: a -> TokenCache a
initTokenCacheLayout a = TK (Map.fromList [((TId 0),a)]) (TId 0)

-- ---------------------------------------------------------------------

-- |We need the ParsedSource because it more closely reflects the actual source
-- code, but must be able to work with the renamed representation of the names
-- involved. This function constructs a map from every Located RdrName in the
-- ParsedSource to its corresponding name in the RenamedSource. It also deals
-- with the wrinkle that we need to Location of the RdrName to make sure we have
-- the right Name, but not all RdrNames have a Location.
-- This function is called before the RefactGhc monad is active.
initRdrNameMap :: TypecheckedModule -> NameMap
initRdrNameMap tm = r
  where
    parsed  = GHC.pm_parsed_source $ tmParsedModule tm
    renamed = tmRenamedSource tm
#if __GLASGOW_HASKELL__ > 710
    typechecked = tmTypecheckedSource tm
#endif

    checkRdr :: GHC.Located GHC.RdrName -> Maybe [(GHC.SrcSpan,GHC.RdrName)]
    checkRdr (GHC.L l n@(GHC.Unqual _)) = Just [(l,n)]
    checkRdr (GHC.L l n@(GHC.Qual _ _)) = Just [(l,n)]
    checkRdr (GHC.L _ _)= Nothing

    checkName :: GHC.Located GHC.Name -> Maybe [GHC.Located GHC.Name]
    checkName ln = Just [ln]

    rdrNames = gfromJust "initRdrNameMap" $ SYB.everything mappend (nameSybQuery checkRdr ) parsed
#if __GLASGOW_HASKELL__ <= 710
    names    = gfromJust "initRdrNameMap" $ SYB.everything mappend (nameSybQuery checkName) renamed
#else
    names1   = gfromJust "initRdrNameMap" $ SYB.everything mappend (nameSybQuery checkName) renamed
    names2 = names1 ++ SYB.everything (++) ([] `SYB.mkQ` fieldOcc
                                              `SYB.extQ` hsRecFieldN) renamed
    names  = names2 ++ SYB.everything (++) ([] `SYB.mkQ` hsRecFieldT) typechecked

    fieldOcc :: GHC.FieldOcc GHC.Name -> [GHC.Located GHC.Name]
    fieldOcc (GHC.FieldOcc (GHC.L l _) n) = [(GHC.L l n)]

    hsRecFieldN :: GHC.LHsExpr GHC.Name -> [GHC.Located GHC.Name]
    hsRecFieldN (GHC.L _ (GHC.HsRecFld (GHC.Unambiguous (GHC.L l _) n) )) = [GHC.L l n]
    hsRecFieldN _ = []

    hsRecFieldT :: GHC.LHsExpr GHC.Id -> [GHC.Located GHC.Name]
    hsRecFieldT (GHC.L _ (GHC.HsRecFld (GHC.Ambiguous (GHC.L l _) n) )) = [GHC.L l (Var.varName n)]
    hsRecFieldT _ = []
#endif

    nameMap = Map.fromList $ map (\(GHC.L l n) -> (l,n)) names

    -- If the name does not exist (e.g. a TH Splice that has been expanded, make a new one)
    -- No attempt is made to make sure that equivalent ones have equivalent names.
    lookupName l n i = case Map.lookup l nameMap of
      Just v -> v
      Nothing -> case n of
                   GHC.Unqual u -> mkNewGhcNamePure 'h' i Nothing  (GHC.occNameString u)
#if __GLASGOW_HASKELL__ <= 710
                   GHC.Qual q u -> mkNewGhcNamePure 'h' i (Just (GHC.Module (GHC.stringToPackageKey "") q)) (GHC.occNameString u)
#else
                   GHC.Qual q u -> mkNewGhcNamePure 'h' i (Just (GHC.Module (GHC.stringToUnitId "") q)) (GHC.occNameString u)
#endif
                   _            -> error "initRdrNameMap:should not happen"

    r = Map.fromList $ map (\((l,n),i) -> (l,lookupName l n i)) $ zip rdrNames [1..]

-- ---------------------------------------------------------------------

mkNewGhcNamePure :: Char -> Int -> Maybe GHC.Module -> String -> GHC.Name
mkNewGhcNamePure c i maybeMod name =
  let un = GHC.mkUnique c i -- H for HaRe :)
      n = case maybeMod of
               Nothing   -> GHC.mkInternalName un      (GHC.mkVarOcc name) GHC.noSrcSpan
               Just modu -> GHC.mkExternalName un modu (GHC.mkVarOcc name) GHC.noSrcSpan
  in n

-- ---------------------------------------------------------------------

nameSybTransform :: (Monad m,SYB.Typeable t)
             => (GHC.Located GHC.RdrName -> m (GHC.Located GHC.RdrName)) -> t -> m t
nameSybTransform changer = q
  where
    q = SYB.mkM  worker
#if __GLASGOW_HASKELL__ <= 710
        `SYB.extM` workerBind
        `SYB.extM` workerExpr
        `SYB.extM` workerLIE
        `SYB.extM` workerHsTyVarBndr
        `SYB.extM` workerLHsType
#endif

    worker (pnt :: (GHC.Located GHC.RdrName))
      = changer pnt

#if __GLASGOW_HASKELL__ <= 710
    workerBind (GHC.L l (GHC.VarPat name))
      = do
        (GHC.L _ n) <- changer (GHC.L l name)
        return (GHC.L l (GHC.VarPat n))
    workerBind x = return x

    workerExpr ((GHC.L l (GHC.HsVar name)))
      = do
          (GHC.L _ n) <- changer (GHC.L l name)
          return (GHC.L l (GHC.HsVar n))
    workerExpr x = return x

    workerLIE ((GHC.L l (GHC.IEVar (GHC.L ln name))) :: (GHC.LIE GHC.RdrName))
      = do
          (GHC.L _ n) <- changer (GHC.L ln name)
          return (GHC.L l (GHC.IEVar (GHC.L ln n)))
    workerLIE x = return x

    workerHsTyVarBndr (GHC.L l (GHC.UserTyVar name))
      = do
          (GHC.L _ n) <- changer (GHC.L l name)
          return (GHC.L l (GHC.UserTyVar n))
    workerHsTyVarBndr x = return x

    workerLHsType (GHC.L l (GHC.HsTyVar name))
      = do
          (GHC.L _ n) <- changer (GHC.L l name)
          return (GHC.L l (GHC.HsTyVar n))
    workerLHsType x = return x
#endif

-- ---------------------------------------------------------------------

nameSybQuery :: (SYB.Typeable a, SYB.Typeable t)
             => (GHC.Located a -> Maybe r) -> t -> Maybe r
nameSybQuery checker = q
  where
    q = Nothing `SYB.mkQ`  worker
#if __GLASGOW_HASKELL__ <= 710
                `SYB.extQ` workerBind
                `SYB.extQ` workerExpr
                -- `SYB.extQ` workerLIE
                `SYB.extQ` workerHsTyVarBndr
                `SYB.extQ` workerLHsType
#endif

    worker (pnt :: (GHC.Located a))
      = checker pnt

#if __GLASGOW_HASKELL__ <= 710
    workerBind (GHC.L l (GHC.VarPat name))
      = checker (GHC.L l name)
    workerBind _ = Nothing

    workerExpr ((GHC.L l (GHC.HsVar name)))
      = checker (GHC.L l name)
    workerExpr _ = Nothing

    -- workerLIE ((GHC.L _l (GHC.IEVar (GHC.L ln name))) :: (GHC.LIE a))
    --   = checker (GHC.L ln name)
    -- workerLIE _ = Nothing

    workerHsTyVarBndr ((GHC.L l (GHC.UserTyVar name)))
      = checker (GHC.L l name)
    workerHsTyVarBndr _ = Nothing

    workerLHsType ((GHC.L l (GHC.HsTyVar name)))
      = checker (GHC.L l name)
    workerLHsType _ = Nothing
#endif

-- ---------------------------------------------------------------------

parseDeclWithAnns :: String -> RefactGhc (GHC.LHsDecl GHC.RdrName)
parseDeclWithAnns src = do
  u <- gets rsUniqState
  putUnique (u+1)
  let label = "HaRe-" ++ show (u + 1)
  r  <- GHC.liftIO $ withDynFlags (\df -> parseDecl df label src)
  case r of
    Left err -> error (show err)
    Right (anns,decl) -> do
      -- addRefactAnns anns
      liftT $ modifyAnnsT (mergeAnns anns)
      return decl

-- EOF

