{-# LANGUAGE CPP #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE UndecidableInstances #-} -- for GHC.DataId

module Language.Haskell.Refact.Utils.Utils
       (
       -- * Managing the GHC / project environment
         getTargetGhc
       , parseSourceFileGhc

       -- * The bits that do the work
       , runRefacSession
       , applyRefac
       , applyRefac'
       , refactDone

       -- , Update(..)
       , fileNameFromModSummary
       , getModuleName
       , clientModsAndFiles
       , serverModsAndFiles
       , lookupAnns
       , runMultRefacSession

       , modifiedFiles
       , writeRefactoredFiles

       , stripCallStack

       ) where

-- import Control.Exception
import Control.Monad.Identity
import Control.Monad.State
import Data.List
import Data.Maybe
import Data.IORef

-- import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Preprocess
import Language.Haskell.GHC.ExactPrint.Print
import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.GHC.ExactPrint.Utils

import qualified Language.Haskell.GhcMod          as GM
import qualified Language.Haskell.GhcMod.Internal as GM

import Language.Haskell.Refact.Utils.GhcModuleGraph
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.Types
import System.Directory
import System.FilePath.Posix

import qualified Digraph       as GHC
import qualified DynFlags      as GHC
import qualified GHC           as GHC
import qualified SrcLoc        as GHC
import qualified Hooks         as GHC
import qualified HscMain       as GHC
import qualified HscTypes      as GHC
import qualified TcRnMonad     as GHC

-- import qualified GHC.SYB.Utils as SYB
-- import qualified Data.Generics as SYB

import qualified Data.Map      as Map
import qualified Data.Set      as Set

-- import Debug.Trace

-- ---------------------------------------------------------------------

-- | Extract the module name from the parsed source, if there is one
getModuleName :: GHC.ParsedSource -> Maybe (GHC.ModuleName,String)
getModuleName (GHC.L _ modn) =
  case (GHC.hsmodName modn) of
    Nothing -> Nothing
    Just (GHC.L _ modname) -> Just $ (modname,GHC.moduleNameString modname)

-- ---------------------------------------------------------------------

getTargetGhc :: TargetModule -> RefactGhc ()
getTargetGhc (GM.ModulePath _mn fp) = parseSourceFileGhc fp

-- ---------------------------------------------------------------------
{-
-- | Parse a single source file into a GHC session
parseSourceFileGhc' :: FilePath -> RefactGhc ()
parseSourceFileGhc' targetFile = do
  logm $ "parseSourceFileGhc:targetFile=" ++ show targetFile
  setTargetSession targetFile
  graph  <- GHC.getModuleGraph
  cgraph <- canonicalizeGraph graph
  cfileName <- liftIO $ canonicalizePath targetFile
  let mm = filter (\(mfn,_ms) -> mfn == Just cfileName) cgraph
  case mm of
    [(_,modSum)] -> loadFromModSummary Nothing modSum
    _ -> error $ "HaRe:unexpected error parsing " ++ targetFile
-}
-- ---------------------------------------------------------------------

-- | Parse a single source file into a GHC session
parseSourceFileGhc :: FilePath -> RefactGhc ()
parseSourceFileGhc targetFile = do
  logm $ "parseSourceFileGhc:targetFile=" ++ show targetFile
  cfileName <- liftIO $ canonicalizePath targetFile
  logm $ "parseSourceFileGhc:cfileName=" ++ show cfileName
  ref <- liftIO $ newIORef (cfileName,Nothing)
  let
    setTarget fileName = RefactGhc $ GM.runGmlT' [Left fileName] (installHooks ref) (return ())
  -- setTarget targetFile
  setTarget cfileName
  logm $ "parseSourceFileGhc:after setTarget"
  (_,mtm) <- liftIO $ readIORef ref
  logm $ "parseSourceFileGhc:isJust mtm:" ++ show (isJust mtm)
  graph  <- GHC.getModuleGraph
  cgraph <- canonicalizeGraph graph
  let mm = filter (\(mfn,_ms) -> mfn == Just cfileName) cgraph
  case mm of
    [(_,modSum)] -> loadFromModSummary mtm modSum
    -- [(_,modSum)] -> loadFromModSummary Nothing modSum
    _ -> error $ "HaRe:unexpected error parsing " ++ targetFile

-- ---------------------------------------------------------------------

installHooks :: (Monad m) => IORef (FilePath,Maybe TypecheckedModule) -> GHC.DynFlags -> m GHC.DynFlags
installHooks ref dflags = return $ dflags {
    GHC.hooks = (GHC.hooks dflags) {

#if __GLASGOW_HASKELL__ <= 710
        GHC.hscFrontendHook   = Just $ hscFrontend ref
#else
        GHC.hscFrontendHook   = Just $ runHscFrontend ref
#endif
      }
  }

#if __GLASGOW_HASKELL__ > 710
runHscFrontend :: IORef (FilePath,Maybe TypecheckedModule) -> GHC.ModSummary -> GHC.Hsc GHC.FrontendResult
runHscFrontend ref mod_summary
    = GHC.FrontendTypecheck `fmap` hscFrontend ref mod_summary
#endif

-- ---------------------------------------------------------------------
-- | Given a 'ModSummary', parses and typechecks it, returning the
-- 'TcGblEnv' resulting from type-checking.
-- Based on GHC.hscFileFrontend
--
-- This gets called on every module compiled when loading the wanted target.
-- When it is the wanted target, keep the ParsedSource and TypecheckedSource,
-- with API Annotations enabled.
hscFrontend :: IORef (FilePath,Maybe TypecheckedModule) -> GHC.ModSummary -> GHC.Hsc GHC.TcGblEnv
hscFrontend ref mod_summary = do
    -- liftIO $ putStrLn $ "hscFrontend:entered:" ++ fileNameFromModSummary mod_summary
    (mfn,_) <- canonicalizeModSummary mod_summary
    -- liftIO $ putStrLn $ "hscFrontend:mfn:" ++ show mfn
    (fn,_) <- liftIO $ readIORef ref
    let
      keepInfo = case mfn of
                   Just fileName -> fn == fileName
                   Nothing -> False
    if keepInfo
      then do
        -- liftIO $ putStrLn $ "hscFrontend:in keepInfo"
        let modSumWithRaw = tweakModSummaryDynFlags mod_summary

        hsc_env <- GHC.getHscEnv
        let hsc_env_tmp = hsc_env { GHC.hsc_dflags = GHC.ms_hspp_opts modSumWithRaw }
        hpm <- liftIO $ GHC.hscParse hsc_env_tmp modSumWithRaw
        let p = GHC.ParsedModule mod_summary
                                (GHC.hpm_module      hpm)
                                (GHC.hpm_src_files   hpm)
                                (GHC.hpm_annotations hpm)

        hsc_env' <- GHC.getHscEnv
        (tc_gbl_env,rn_info) <- liftIO $ GHC.hscTypecheckRename hsc_env' mod_summary hpm

        details <- liftIO $ GHC.makeSimpleDetails hsc_env' tc_gbl_env

        let
          tc =
            TypecheckedModule {
              tmParsedModule      = p,
              tmRenamedSource     = gfromJust "hscFrontend" rn_info,
              tmTypecheckedSource = GHC.tcg_binds tc_gbl_env,
              tmMinfExports       = GHC.md_exports details,
              tmMinfRdrEnv        = Just (GHC.tcg_rdr_env tc_gbl_env)
              }

        liftIO $ modifyIORef' ref (const (fn,Just tc))
        return tc_gbl_env
      else do
        hpm <- GHC.hscParse' mod_summary
        hsc_env <- GHC.getHscEnv
        tc_gbl_env <- GHC.tcRnModule' hsc_env mod_summary False hpm
        return tc_gbl_env

-- ---------------------------------------------------------------------
{-
setTargetSession :: FilePath -> RefactGhc ()
-- setTargetSession targetFile = RefactGhc $ GM.runGmlT' [Left targetFile] setDynFlags (return ())
setTargetSession targetFile = RefactGhc $ GM.runGmlT' [Left targetFile] return (return ())

-- setDynFlags :: GHC.DynFlags -> GHC.Ghc GHC.DynFlags
-- setDynFlags df = return (GHC.gopt_set df GHC.Opt_KeepRawTokenStream)
-}
-- ---------------------------------------------------------------------

-- |For GHC 7.10.2, setting 'GHC.Opt_KeepRawTokenStream' prevents the pragmas at
-- the top of a source file from being read if there is a comment mixed in them
-- anywhere. To work around this, we need to inject that setting into the cached
-- dynflags in the 'GHC.ModSummary' before parsing it for refactoring, otherwise
-- all comments will be discarded.
-- See https://ghc.haskell.org/trac/ghc/ticket/10942
tweakModSummaryDynFlags :: GHC.ModSummary -> GHC.ModSummary
tweakModSummaryDynFlags ms =
  let df = GHC.ms_hspp_opts ms
  in ms { GHC.ms_hspp_opts = GHC.gopt_set df GHC.Opt_KeepRawTokenStream }

-- ---------------------------------------------------------------------

-- | In the existing GHC session, put the requested TypeCheckedModule
-- into the RefactGhc monad
loadFromModSummary :: Maybe TypecheckedModule -> GHC.ModSummary -> RefactGhc ()
loadFromModSummary mtm modSum = do
  logm $ "loadFromModSummary:modSum=" ++ show modSum
  t <- case mtm of
    Nothing -> do
      let modSumWithRaw = tweakModSummaryDynFlags modSum
      p <- GHC.parseModule modSumWithRaw
      t' <- GHC.typecheckModule p
      let
        tm = TypecheckedModule
          { tmParsedModule = p
          , tmRenamedSource = gfromJust "loadFromModSummary" $ GHC.tm_renamed_source t'
          , tmTypecheckedSource = GHC.tm_typechecked_source t'
          , tmMinfExports  = error $ "loadFromModSummary:not visible in ModuleInfo 1"
          , tmMinfRdrEnv   = error $ "loadFromModSummary:not visible in ModuleInfo 2"
          }
      return tm
    Just tm -> return tm

  -- dflags <- GHC.getDynFlags
  -- cppComments <- if (GHC.xopt GHC.Opt_Cpp dflags)
  cppComments <- if True
                  then do
                       -- ++AZ++:TODO: enable the CPP option check some time
                       -- TODO: Set the approriate DynFlag to retain the source, so this can be done more cheaply
                       logm $ "loadFromModSummary:CPP flag set"
                       case GHC.ml_hs_file $ GHC.ms_location modSum of
                         Just fileName -> getCppTokensAsComments defaultCppOptions fileName
                         Nothing       -> return []
                  else do
                       logm $ "loadFromModSummary:no CPP"
                       return []

  -- required for inscope queries. Is there a better way to do those?
  setGhcContext modSum

  (mfp,_modSum) <- canonicalizeModSummary modSum
  newTargetModule <- case mfp of
    Nothing -> error $ "HaRe:no file path for module:" ++ showGhc modSum
    Just fp -> return $ GM.ModulePath (GHC.moduleName $ GHC.ms_mod modSum) fp

  oldTargetModule <- gets rsCurrentTarget
  let
    putModule = do
      putParsedModule cppComments t
      settings <- get
      put $ settings { rsCurrentTarget = Just newTargetModule }

  mtm' <- gets rsModule
  case mtm' of
    Just tm -> if ((rsStreamModified tm == RefacUnmodifed)
                  && oldTargetModule == Just newTargetModule)
                 then do
                   logm $ "loadFromModSummary:not calling putParsedModule for targetModule=" ++ show newTargetModule
                   return ()
                 else if rsStreamModified tm == RefacUnmodifed
                        then putModule
                        else error $ "loadFromModSummary: trying to load a module without finishing with active one."

    Nothing -> putModule

  return ()

-- ---------------------------------------------------------------------

-- | Manage a whole refactor session. Initialise the monad, load the
-- whole project if required, and then apply the individual
-- refactorings, and write out the resulting files.
--
-- It is intended that this forms the umbrella function, in which
-- applyRefac is called
--
runRefacSession ::
       RefactSettings
    -> GM.Options                   -- ^ ghc-mod options
    -> RefactGhc [ApplyRefacResult] -- ^ The computation doing the
                                    -- refactoring. Normally created
                                    -- via 'applyRefac'
    -> IO [FilePath]
runRefacSession settings opt comp = do
  let
    initialState = RefSt
        { rsSettings      = settings
        , rsUniqState     = 1
        , rsSrcSpanCol    = 1
        , rsFlags         = RefFlags False
        , rsStorage       = StorageNone
        , rsCurrentTarget = Nothing
        , rsModule        = Nothing
        }

  (refactoredMods,_s) <- runRefactGhc comp initialState opt

  let verbosity = rsetVerboseLevel (rsSettings initialState)
  writeRefactoredFiles verbosity refactoredMods
  return $ modifiedFiles refactoredMods

-- ---------------------------------------------------------------------


-- | Like runRefacSession but instead takes an ordered list of RefactGhc computations and runs all of them threading the state through all of the computations

runMultRefacSession :: RefactSettings -> GM.Options -> [RefactGhc [ApplyRefacResult]] -> IO [FilePath]
runMultRefacSession settings opt comps = do
  let
    initialState = RefSt
        { rsSettings      = settings
        , rsUniqState     = 1
        , rsSrcSpanCol    = 1
        , rsFlags         = RefFlags False
        , rsStorage       = StorageNone
        , rsCurrentTarget = Nothing
        , rsModule        = Nothing
        }
  results <- threadState opt initialState comps
  let (_, finState) = last results
      verbosity = rsetVerboseLevel (rsSettings finState)
      refResults = map fst results
      merged = mergeRefResults refResults
  writeRefactoredFiles verbosity merged
  return $ modifiedFiles merged

mergeRefResults :: [[ApplyRefacResult]] -> [ApplyRefacResult]
mergeRefResults lst = Map.elems $ mergeHelp lst Map.empty
  where mergeHelp []  mp = mp
        mergeHelp (x:xs) mp = mergeHelp xs (foldl insertRefRes mp x)
        insertRefRes mp res@((fp,RefacModified), _) = Map.insert fp res mp
        insertRefRes mp _ = mp

threadState :: GM.Options -> RefactState -> [RefactGhc [ApplyRefacResult]] -> IO [([ApplyRefacResult], RefactState)]
threadState _ _ [] = return []
threadState opt currState (rGhc : rst) = do
  res@(refMods, newState) <- runRefactGhc rGhc currState opt
  let (Just mod) = rsModule newState
      newMod = mod {rsStreamModified = RefacUnmodifed}
      nextState = newState {rsModule = Just newMod }
  rest <- threadState opt nextState rst
  return (res : rest)

-- ---------------------------------------------------------------------

cdAndDo :: FilePath -> IO a -> IO a
cdAndDo path fn = do
  old <- getCurrentDirectory
  r <- GHC.gbracket (setCurrentDirectory path) (\_ -> setCurrentDirectory old)
          $ const fn
  return r

-- ---------------------------------------------------------------------

{-
canonicalizeTargets :: Targets-> IO Targets
canonicalizeTargets tgts = do
  cur <- getCurrentDirectory
  let
    canonicalizeTarget (Left path)     = Left <$> canonicalizePath (cur </> path)
    canonicalizeTarget (Right modname) = return $ Right modname
  mapM canonicalizeTarget tgts
-}
-- ---------------------------------------------------------------------
-- TODO: the module should be stored in the state, and returned if it
-- has been modified in a prior refactoring, instead of being parsed
-- afresh each time.

-- | Apply a refactoring (or part of a refactoring) to a single module

applyRefac = applyRefac' True

applyRefac'
    ::
       Bool               -- ^ Boolean that determines if the state should be cleared
    -> RefactGhc a        -- ^ The refactoring
    -> RefacSource        -- ^ where to get the module and toks
    -> RefactGhc (ApplyRefacResult,a)

applyRefac' clearSt refac source = do

    -- TODO: currently a temporary, poor man's surrounding state
    -- management: store state now, set it to fresh, run refac, then
    -- restore the state. Fix this to store the modules in some kind of cache.

    fileName <- case source of
         RSFile fname    -> do parseSourceFileGhc fname
                               return fname
         RSTarget tgt    -> do getTargetGhc tgt
                               return (GM.mpPath tgt)
         RSMod  ms       -> do parseSourceFileGhc $ fileNameFromModSummary ms
                               return $ fileNameFromModSummary ms
         RSAlreadyLoaded -> do mfn <- getRefactFileName
                               case mfn of
                                 Just fname -> return fname
                                 Nothing -> error "applyRefac RSAlreadyLoaded: nothing loaded"

    res <- refac  -- Run the refactoring, updating the state as required

    mod' <- getRefactParsed
    anns <- fetchAnnsFinal
    m    <- getRefactStreamModified

    -- Clear the refactoring state
    if clearSt
      then clearParsedModule
      else return ()
    absFileName <- liftIO $ canonicalizePath fileName
    return (((absFileName,m),(anns, mod')),res)


-- ---------------------------------------------------------------------

-- |Returns True if any of the results has its modified flag set
refactDone :: [ApplyRefacResult] -> Bool
refactDone rs = any (\((_,d),_) -> d == RefacModified) rs

-- ---------------------------------------------------------------------

modifiedFiles :: [ApplyRefacResult] -> [String]
modifiedFiles refactResult = map (\((s,_),_) -> s)
                           $ filter (\((_,b),_) -> b == RefacModified) refactResult

-- ---------------------------------------------------------------------
{-
getEnabledTargets :: RefactSettings -> ([FilePath],[FilePath],[FilePath],[FilePath]) -> ([FilePath],[FilePath])
getEnabledTargets settings (libt,exet,testt,bencht) = (targetsLib,targetsExe)
  where
    (libEnabled, exeEnabled, testEnabled, benchEnabled) = rsetEnabledTargets settings
    targetsLib = on libEnabled libt
    targetsExe = on exeEnabled exet
              ++ on testEnabled testt
              ++ on benchEnabled bencht

    on flag xs = if flag then xs else []
-}
-- ---------------------------------------------------------------------

{-
-- ++AZ++ I think the intended function of this class has been superseded by
-- ghc-exactprint HasDecls.
class (SYB.Data t, SYB.Data t1) => Update t t1 where

  -- | Update the occurrence of one syntax phrase in a given scope by
  -- another syntax phrase of the same type
  update::  t     -- ^ The syntax phrase to be updated.
         -> t     -- ^ The new syntax phrase.
         -> t1    -- ^ The contex where the old syntax phrase occurs.
         -> RefactGhc t1  -- ^ The result.

instance (SYB.Data t, GHC.OutputableBndr n, GHC.DataId n)
  => Update (GHC.LHsExpr n) t where
    update oldExp newExp t
           = SYB.everywhereMStaged SYB.Parser (SYB.mkM inExp) t
       where
        inExp (e::GHC.LHsExpr n)
          | sameOccurrence e oldExp
               = return newExp
          | otherwise = return e

instance (SYB.Data t, GHC.OutputableBndr n, GHC.DataId n)
   => Update (GHC.LPat n) t where
    update oldPat newPat t
           = SYB.everywhereMStaged SYB.Parser (SYB.mkM inPat) t
        where
          inPat (p::GHC.LPat n)
            | sameOccurrence p oldPat
                = return newPat
            | otherwise = return p

instance (SYB.Data t, GHC.OutputableBndr n, GHC.DataId n)
  => Update (GHC.LHsType n) t where
     update oldTy newTy t
           = SYB.everywhereMStaged SYB.Parser (SYB.mkM inTyp) t
        where
          inTyp (t'::GHC.LHsType n)
            | sameOccurrence t' oldTy
                = return newTy
            | otherwise = return t'

instance (SYB.Data t, GHC.OutputableBndr n1, GHC.OutputableBndr n2, GHC.DataId n1, GHC.DataId n2)
   => Update (GHC.LHsBindLR n1 n2) t where
       update oldBind newBind t
             = SYB.everywhereMStaged SYB.Parser (SYB.mkM inBind) t
          where
            inBind (t'::GHC.LHsBindLR n1 n2)
              | sameOccurrence t' oldBind
                  = return newBind
              | otherwise = return t'
-}

-- ---------------------------------------------------------------------

-- | Write refactored program source to files.
writeRefactoredFiles ::
  VerboseLevel -> [ApplyRefacResult] -> IO ()
writeRefactoredFiles verbosity files
  = do let filesModified = filter (\((_f,m),_) -> m == RefacModified) files

       -- TODO: restore the history function
       -- ++AZ++ PFE0.addToHistory isSubRefactor (map (fst.fst) filesModified)
       sequence_ (map modifyFile filesModified)
       -- mapM_ writeTestDataForFile files   -- This should be removed for the release version.

     where
       modifyFile ((fileName,_),(ann,parsed)) = do

           let
               -- rigidOptions :: PrintOptions Identity String
               -- rigidOptions = printOptions (\_ b -> return b) return return RigidLayout

               -- exactPrintRigid  ast as = runIdentity (exactPrintWithOptions rigidOptions ast as)
               exactPrintNormal ast as = runIdentity (exactPrintWithOptions stringOptions ast as)

           -- let source = exactPrint parsed ann
           -- let source = exactPrintRigid parsed ann
           let source = exactPrintNormal parsed ann
           let (baseFileName,ext) = splitExtension fileName
           seq (length source) (writeFile (baseFileName ++ ".refactored" ++ ext) source)

           when (verbosity == Debug) $
             do
               writeFile (fileName ++ ".parsed_out") (showGhc parsed)
               writeFile (fileName ++ ".AST_out")   ((showGhc parsed) ++
                      "\n\n----------------------\n\n" ++
                      -- (SYB.showData SYB.Parser 0 parsed) ++
                      (showAnnData ann 0 parsed) ++
                      "\n\n----------------------\n\n" ++
                      (showGhc ann) ++
                      "\n\n----------------------\n\n"
--                      (showAnnData (organiseAnns ann) 0 parsed)
                      )
-- ---------------------------------------------------------------------

-- | Return the client modules and file names. The client modules of
-- module, say m, are those modules which directly or indirectly
-- import module m.

-- clientModsAndFiles :: GHC.ModuleName -> RefactGhc [TargetModule]
clientModsAndFiles :: GM.ModulePath -> RefactGhc [TargetModule]
-- TODO: Use ghc-mod cache if there is a cabal file, else normal GHC modulegraph
clientModsAndFiles m = do
  mgs <- cabalModuleGraphs
  -- logm $ "clientModsAndFiles:mgs=" ++ show mgs
  -- mgs is [Map ModulePath (Set ModulePath)]
  --  where eack key imports the corresponding set.
  -- There are no cycles

  -- We need the reverse of this, the transitive set of values where if the
  -- ModulePath is in the set, then the key is of interest.

  -- So
  --  Flatten the module graph, reverse the dependencies, then rebuild it
  let
    flattenSwap (GM.GmModuleGraph mg)
      = concatMap (\(k,vs) -> map (\v -> (v,Set.singleton k)) (Set.elems vs)) $ Map.toList mg
    transposed = mgs'
      where
        kvs = concatMap flattenSwap mgs
        mgs' = foldl' (\acc (k,v) -> Map.insertWith Set.union k v acc) Map.empty kvs

    -- transposed is a map from each module to those that import it. We need the
    -- transitive closure of all the importers of the given module.
    check acc k =
      case Map.lookup k transposed of
        Nothing -> (acc,[])
        Just s -> (Set.union acc s, Set.toList $ s Set.\\ acc)
    go (acc,[]) = acc
    go (acc,c:s) = go (acc',s')
      where
        (acc',q) = check acc c
        s' = nub (q ++ s)

    r = go (Set.empty, [m])
  return $ Set.toList r


-- TODO : find decent name and place for this.
mycomp :: GHC.ModSummary -> GHC.ModSummary -> Bool
mycomp ms1 ms2 = (GHC.ms_mod ms1) == (GHC.ms_mod ms2)


-- ---------------------------------------------------------------------

-- | Return the server module and file names. The server modules of
-- module, say m, are those modules which are directly or indirectly
-- imported by module m. This can only be called in a live GHC session
-- TODO: make sure this works with multiple targets. Is that needed?
serverModsAndFiles
  :: GHC.GhcMonad m => GHC.ModuleName -> m [GHC.ModSummary]
-- TODO: Use ghc-mod cache if there is a cabal file, else normal GHC modulegraph
serverModsAndFiles m = do
  ms <- GHC.getModuleGraph
  modsum <- GHC.getModSummary m
  let mg = getModulesAsGraph False ms Nothing
      modNode = gfromJust "serverModsAndFiles" $ find (\(msum',_,_) -> mycomp msum' modsum) (GHC.verticesG mg)
      serverMods = filter (\msum' -> not (mycomp msum' modsum))
                 $ map summaryNodeSummary $ GHC.reachableG mg modNode

  return serverMods

-- ---------------------------------------------------------------------

-- | Finds all anotations that are contained within the given source span
lookupAnns :: Anns -> GHC.SrcSpan -> Anns
lookupAnns anns (GHC.RealSrcSpan span) = Map.filterWithKey isInSpan anns
  where isInSpan k@(AnnKey (GHC.RealSrcSpan annSpan) conN) v = GHC.containsSpan span annSpan

-- ---------------------------------------------------------------------

-- | In GHC 8 an error has an attached callstack. This is not always what we
-- want, so this function strips it
stripCallStack :: String -> String
stripCallStack str = str'
  where
    s1 = init $ unlines $ takeWhile (\s -> s /= "CallStack (from HasCallStack):") $ lines str
    str' = if last str == '\n'
              then s1 ++ "\n"
              else s1
