{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Language.Haskell.Refact.Utils.Monad
       (
         ParseResult
       , VerboseLevel(..)
       , RefactSettings(..)
       , RefactState(..)
       , RefactModule(..)
       , TargetModule
       , Targets
       , RefactStashId(..)
       , RefactFlags(..)
       , StateStorage(..)

       -- The GHC Monad
       , RefactGhc
       , runRefactGhc
       , getRefacSettings
       , defaultSettings
       , logSettings
       , initGhcSession

       , loadModuleGraphGhc
       , ensureTargetLoaded
       , canonicalizeGraph
       , canonicalizeModSummary

       , logm
       ) where


import qualified DynFlags      as GHC
import qualified GHC           as GHC
import qualified GHC.Paths     as GHC
import qualified GhcMonad      as GHC
import qualified HscTypes      as GHC

import Control.Arrow
import Control.Applicative
import Control.Monad.State
--import Data.Time.Clock
import Distribution.Helper
import Exception
import Language.Haskell.GhcMod
import qualified Language.Haskell.GhcMod.Internal as GM
import Language.Haskell.GhcMod.Internal hiding (MonadIO,liftIO)
-- import Language.Haskell.Refact.Utils.Cabal
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.Types
import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Types
import System.Directory
import System.FilePath.Posix
import System.Log.Logger

import qualified Data.Map as Map
import qualified Data.Set as Set

-- Monad transformer stuff
import Control.Monad.Trans.Control ( control, liftBaseOp, liftBaseOp_)

-- ---------------------------------------------------------------------

data VerboseLevel = Debug | Normal | Off
            deriving (Eq,Show)

data RefactSettings = RefSet
        { rsetGhcOpts      :: ![String]
        , rsetImportPaths :: ![FilePath]
        , rsetExpandSplice :: Bool
        , rsetLineSeparator :: LineSeparator
        , rsetMainFile     :: Maybe [FilePath]
        , rsetCheckTokenUtilsInvariant :: !Bool
        , rsetVerboseLevel :: !VerboseLevel
        , rsetEnabledTargets :: (Bool,Bool,Bool,Bool)
        } deriving (Show)

-- deriving instance Show LineSeparator

defaultSettings :: RefactSettings
defaultSettings = RefSet
    { rsetGhcOpts = []
    , rsetImportPaths = []
    , rsetExpandSplice = False
    , rsetLineSeparator = LineSeparator "\0"
    , rsetMainFile = Nothing
    , rsetCheckTokenUtilsInvariant = False
    , rsetVerboseLevel = Normal
    -- , rsetEnabledTargets = (True,False,True,False)
    , rsetEnabledTargets = (True,True,True,True)
    }

logSettings :: RefactSettings
logSettings = defaultSettings { rsetVerboseLevel = Debug }

-- ---------------------------------------------------------------------

data RefactStashId = Stash !String deriving (Show,Eq,Ord)

data RefactModule = RefMod
        { rsTypecheckedMod  :: !GHC.TypecheckedModule
        -- , rsOrigTokenStream :: ![PosToken]         -- ^Original Token stream for the current module
        , rsNameMap         :: NameMap
          -- ^ Mapping from the names in the ParsedSource to the renamed
          -- versions. Note: No strict mark, can be computed lazily.

          -- ++AZ++ TODO: Once HaRe can rename again, change rsTokenCache to something more approriate. Ditto rsStreamModified
        , rsTokenCache      :: !(TokenCache Anns)  -- ^Token stream for the current module, maybe modified, in SrcSpan tree form
        , rsStreamModified  :: !RefacResult        -- ^current module has updated the AST
        } deriving (Show)

instance Show GHC.Name where
  show n = showGhc n

deriving instance Show (GHC.Located GHC.Token)

instance Show GHC.TypecheckedModule where
  show t = showGhc (GHC.pm_parsed_source $ GHC.tm_parsed_module t)

data RefactFlags = RefFlags
       { rsDone :: !Bool -- ^Current traversal has already made a change
       } deriving (Show)

-- | State for refactoring a single file. Holds/hides the token
-- stream, which gets updated transparently at key points.
data RefactState = RefSt
        { rsSettings   :: !RefactSettings -- ^Session level settings
        , rsUniqState  :: !Int -- ^ Current Unique creator value, incremented every time it is used
        , rsSrcSpanCol :: !Int -- ^ Current SrcSpan creator value, incremented every time it is used
        , rsFlags      :: !RefactFlags -- ^ Flags for controlling generic traversals
        , rsStorage    :: !StateStorage -- ^Temporary storage of values
                                      -- while refactoring takes place
        , rsGraph         :: ![TargetGraph]
        , rsModuleGraph   :: ![([FilePath],GHC.ModuleGraph)]
        , rsCurrentTarget :: !(Maybe [FilePath])
        , rsModule        :: !(Maybe RefactModule) -- ^The current module being refactored
        } deriving (Show)
{-
Note [rsSrcSpanCol]
~~~~~~~~~~~~~~~~~~~

The ghc-exactprint annotations are tied to a SrcSpan, and provide
deltas for the spaces between the elements in the source.

As such, the SrcSpan itself is only used as an index into the
annotation database.

When HaRe needs a new SrcSpan, for this, it generates it from this
field, to ensure uniqueness.
-}

type TargetModule = ([FilePath], (Maybe FilePath,GHC.ModSummary))

type TargetGraph = ([FilePath],[(Maybe FilePath, GHC.ModSummary)])

type Targets = [Either FilePath GHC.ModuleName]

-- |Result of parsing a Haskell source file. It is simply the
-- TypeCheckedModule produced by GHC.
type ParseResult = GHC.TypecheckedModule

-- |Provide some temporary storage while the refactoring is taking
-- place
data StateStorage = StorageNone
                  | StorageBind (GHC.LHsBind GHC.Name)
                  | StorageSig  (GHC.LSig GHC.Name)
                  | StorageBindRdr (GHC.LHsBind GHC.RdrName)
                  | StorageSigRdr  (GHC.LSig GHC.RdrName)


instance Show StateStorage where
  show StorageNone         = "StorageNone"
  show (StorageBind _bind) = "(StorageBind " {- ++ (showGhc bind) -} ++ ")"
  show (StorageSig _sig)   = "(StorageSig " {- ++ (showGhc sig) -} ++ ")"
  show (StorageBindRdr _bind) = "(StorageBindRdr " {- ++ (showGhc bind) -} ++ ")"
  show (StorageSigRdr _sig)   = "(StorageSigRdr " {- ++ (showGhc sig) -} ++ ")"

-- ---------------------------------------------------------------------
-- StateT and GhcT stack

newtype RefactGhc a = RefactGhc
    { unRefactGhc :: GM.GmlT (StateT RefactState IO) a
    } deriving ( Functor
               , Applicative
               , Alternative
               , Monad
               , MonadPlus
               , MonadIO
               , GM.GmEnv
               , GM.MonadIO
               , ExceptionMonad
               )

-- type RefactGhc a = GHC.GhcT (GhcModT (StateT RefactState IO)) a

-- ---------------------------------------------------------------------

runRefactGhc ::
  RefactGhc a -> Targets -> RefactState -> Options -> IO (a, RefactState)
runRefactGhc comp targets initState opt = do
    ((merr,_log),s) <- runStateT (runGhcModT opt (GM.runGmlT' targets setDynFlags (unRefactGhc comp))) initState
    case merr of
      Left err -> error (show err)
      Right a  -> return (a,s)

setDynFlags :: GHC.DynFlags -> GHC.Ghc GHC.DynFlags
setDynFlags df = return (GHC.gopt_set df GHC.Opt_KeepRawTokenStream)

-- ---------------------------------------------------------------------

instance GM.GmLog RefactGhc where
    gmlJournal v = RefactGhc (GM.gmlJournal v)
    gmlHistory = RefactGhc GM.gmlHistory
    gmlClear   = RefactGhc GM.gmlClear

instance GM.MonadIO (StateT RefactState IO) where
  liftIO = liftIO

instance MonadState RefactState RefactGhc where
    get   = RefactGhc (lift get)
    put s = RefactGhc (lift (put s))

instance GHC.GhcMonad RefactGhc where
  getSession     = RefactGhc GM.gmlGetSession
  setSession env = RefactGhc (GM.gmlSetSession env)

instance GHC.HasDynFlags RefactGhc where
  getDynFlags = RefactGhc (GHC.hsc_dflags <$> gmlGetSession)


instance (MonadState RefactState (GHC.GhcT (StateT RefactState IO))) where
    get = lift get
    put = lift . put
    -- state = lift . state

instance (MonadTrans GHC.GhcT) where
   lift = GHC.liftGhcT

instance (Applicative m) => Alternative (GHC.GhcT m) where
  empty = empty
  (<|>) = (<|>)

instance (MonadPlus m,ExceptionMonad m) => MonadPlus (GHC.GhcT m) where
  mzero = GHC.GhcT $ \_s -> mzero
  x `mplus` y = GHC.GhcT $ \_s -> (GHC.runGhcT (Just GHC.libdir) x) `mplus` (GHC.runGhcT (Just GHC.libdir) y)

-- ---------------------------------------------------------------------

instance ExceptionMonad (StateT RefactState IO) where
    gcatch act handler = control $ \run ->
        run act `gcatch` (run . handler)

    gmask = liftBaseOp gmask . liftRestore
     where liftRestore f r = f $ liftBaseOp_ r

-- ---------------------------------------------------------------------

-- | Initialise the GHC session, when starting a refactoring.
--   This should never be called directly.
initGhcSession :: RefactGhc ()
initGhcSession = do
    logm $ "initGhcSession:entered"
    settings <- getRefacSettings
    df <- GHC.getSessionDynFlags
    let df2 = GHC.gopt_set df GHC.Opt_KeepRawTokenStream
    void $ GHC.setSessionDynFlags df2

    -- liftIO $ putStrLn "initGhcSession:entered (IO)"
    logm $ "initGhcSession:entered2"
    cr <- cradle
    logm $ "initGhcSession:cr=" ++ show cr
    case cradleCabalFile cr of
      Just cabalFile -> do
        targets <- getCabalAllTargets cr cabalFile
        logm $ "initGhcSession:targets=" ++ show targets

        -- TODO: Cannot load multiple main modules, must try to load
        -- each main module and retrieve its module graph, and then
        -- set the targets to this superset.

        let targets' = getEnabledTargets settings targets

        case targets' of
          ([],[]) -> return ()
          (libTgts,exeTgts) -> do
                     -- liftIO $ warningM "HaRe" $ "initGhcSession:tgts=" ++ (show (libTgts,exeTgts))
                     logm $ "initGhcSession:(libTgts,exeTgts)=" ++ (show (libTgts,exeTgts))
                     -- setTargetFiles tgts
                     -- void $ GHC.load GHC.LoadAllTargets

                     mapM_ loadModuleGraphGhc $ map (\t -> Just [t]) exeTgts

                     -- Load the library last, most likely in context
                     case libTgts of
                       [] -> return ()
                       _ -> loadModuleGraphGhc (Just libTgts)

                     -- moduleGraph <- gets rsModuleGraph
                     -- logm $ "initGhcSession:rsModuleGraph=" ++ (show moduleGraph)

      Nothing -> do
          let maybeMainFile = rsetMainFile settings
          loadModuleGraphGhc maybeMainFile
          return()

    return ()

-- ---------------------------------------------------------------------

-- | Extracting all 'Module' 'FilePath's for libraries, executables,
-- tests and benchmarks.
cabalAllTargets :: Cradle -> RefactGhc ([String],[String],[String],[String])
cabalAllTargets crdl = RefactGhc (GmlT $ cabalOpts crdl)
  where
    -- Note: This runs inside ghc-mod's GmlT monad
    cabalOpts :: Cradle -> GhcModT (StateT RefactState IO) ([String],[String],[String],[String])
    cabalOpts Cradle{..} = do
        comps <- mapM (resolveEntrypoint crdl) =<< getComponents
        mcs <- cached cradleRootDir resolvedComponentsCache comps
        --mcs:: (Map.Map ChComponentName (GmComponent GMCResolved (Set.Set ModulePath)))

        let entrypoints = Map.toList $ Map.map gmcEntrypoints mcs
            -- graphs      = Map.map gmcHomeModuleGraph mcs
            isExe (ChExeName _,_)     = True
            isExe _                   = False
            isLib (ChLibName,_)       = True
            isLib _                   = False
            isTest (ChTestName _,_)   = True
            isTest _                  = False
            isBench (ChBenchName _,_) = True
            isBench _                 = False
            getTgts :: (ChComponentName,Set.Set ModulePath) -> [String]
            getTgts (_,mps) = map mpPath $ Set.toList mps
            -- exeTargets' :: [(ChComponentName,Set.Set ModulePath)]

            exeTargets   = concatMap getTgts $ filter isExe entrypoints
            libTargets   = concatMap getTgts $ filter isLib entrypoints
            testTargets  = concatMap getTgts $ filter isTest entrypoints
            benchTargets = concatMap getTgts $ filter isBench entrypoints
        -- liftIO $ putStrLn $ "cabalOpts:mcs=" ++ show mcs
        -- liftIO $ putStrLn $ "cabalOpts:entrypoints=" ++ show entrypoints
        -- liftIO $ putStrLn $ "cabalOpts:graphs=" ++ show graphs
        return (libTargets,exeTargets,testTargets,benchTargets)

-- ---------------------------------------------------------------------

getCabalAllTargets :: Cradle -> FilePath -> RefactGhc ([FilePath],[FilePath],[FilePath],[FilePath])
getCabalAllTargets cr cabalFile = do
   (libs,exes,tests,benches) <- cabalAllTargets cr
   return (libs,exes,tests,benches)

{-
getCabalAllTargets :: Cradle -> FilePath -> RefactGhc ([FilePath],[FilePath],[FilePath],[FilePath])
getCabalAllTargets cr cabalFile = do
   currentDir <- liftIO getCurrentDirectory
   -- let cabalDir = gfromJust "getCabalAllTargets" (cradleCabalDir cradle)
   let cabalDir = cradleRootDir cr

   liftIO $ setCurrentDirectory cabalDir

   pkgDesc <- parseCabalFile cr cabalFile
   (libs,exes,tests,benches) <- liftIO $ cabalAllTargets pkgDesc
   liftIO $ setCurrentDirectory currentDir

   let libs'    = filter (\l -> not (isPrefixOf "Paths_" l)) libs
       exes'    = addCabalDir exes
       tests'   = addCabalDir tests
       benches' = addCabalDir benches

       addCabalDir ts = map (\t -> combine cabalDir t) ts

   return (libs',exes',tests',benches')
-}

-- ---------------------------------------------------------------------

-- | Load a module graph into the GHC session, starting from main
loadModuleGraphGhc ::
  Maybe [FilePath] -> RefactGhc ()
loadModuleGraphGhc maybeTargetFiles = do
  currentDir <- liftIO getCurrentDirectory
  -- liftIO $ warningM "HaRe" $ "loadModuleGraphGhc:maybeTargetFiles=" ++ show (maybeTargetFiles,currentDir)
  case maybeTargetFiles of
    Just targetFiles -> do
      ---- from ghc-mod Target
      crdl <- cradle
      opts <- getTargetGhcOptions crdl (Set.fromList $ map Left targetFiles)
      let opts' = opts ++ ["-O0"] --  ++ ghcUserOptions

      initGmlSession opts' $
          setModeSimple >>> setEmptyLogger >>> setDynFlags -- return -- >>> mdf

      ----------------------------------
      loadTarget targetFiles
      -- setTargetFiles [targetFile]
      -- void $ GHC.load GHC.LoadAllTargets

      graph <- GHC.getModuleGraph
      cgraph <- canonicalizeGraph graph

      let canonMaybe filepath = ghandle handler (canonicalizePath filepath)
            where
              handler :: SomeException -> IO FilePath
              handler _e = return filepath

      ctargetFiles <- liftIO $ mapM canonMaybe targetFiles

      settings <- get
      put $ settings {
                       rsGraph         = (rsGraph settings)       ++ [(ctargetFiles,cgraph)]
                     , rsModuleGraph   = (rsModuleGraph settings) ++ [(ctargetFiles,graph)]
                     , rsCurrentTarget = maybeTargetFiles
                     }

      -- logm $ "loadModuleGraphGhc:cgraph=" ++ show (map fst cgraph)
      -- logm $ "loadModuleGraphGhc:cgraph=" ++ showGhc graph

      return ()
    Nothing -> return ()
  return ()

-- ---------------------------------------------------------------------

initGmlSession :: [GHCOption] -> (GHC.DynFlags -> GHC.Ghc GHC.DynFlags) -> RefactGhc ()
initGmlSession opts mdf = RefactGhc (GmlT $ initSession opts mdf)

getTargetGhcOptions :: Cradle -> Set.Set (Either FilePath GHC.ModuleName)
                  -> RefactGhc [GHCOption]
getTargetGhcOptions crdl mfns
  = RefactGhc (GmlT $ targetGhcOptions crdl mfns)

-- ---------------------------------------------------------------------
loadTarget :: [FilePath] -> RefactGhc ()
loadTarget targetFiles = RefactGhc (loadTargets targetFiles)
{-
loadTarget :: [FilePath] -> RefactGhc ()
loadTarget targetFiles = do
  let
    guessOne :: FilePath -> RefactGhc GHC.Target
    guessOne f = GHC.guessTarget f Nothing
  targets <- mapM guessOne targetFiles
  -- ++AZ++: Use ghc-mod loading process here?
  GHC.setTargets targets
  void $ GHC.load GHC.LoadAllTargets
-}
-- ---------------------------------------------------------------------

-- | Make sure the given file is the currently loaded target, and load
-- it if not. Assumes that all the module graphs had been generated
-- before, so these are not updated.
ensureTargetLoaded :: TargetModule -> RefactGhc GHC.ModSummary
ensureTargetLoaded (target,(_,modSum)) = do
  settings <- get
  let currentTarget = rsCurrentTarget settings
  if currentTarget == Just target
    then return modSum
    else do
      logm $ "ensureTargetLoaded: loading:" ++ show target
      loadTarget target
      put $ settings { rsCurrentTarget = Just target}
      graph <- GHC.getModuleGraph
      let newModSum = filter (\ms -> GHC.ms_mod modSum == GHC.ms_mod ms) graph
      return $ ghead "ensureTargetLoaded" newModSum

-- ---------------------------------------------------------------------

canonicalizeGraph ::
  [GHC.ModSummary] -> RefactGhc [(Maybe FilePath, GHC.ModSummary)]
canonicalizeGraph graph = do
  let mm = map (\m -> (GHC.ml_hs_file $ GHC.ms_location m, m)) graph
      canon ((Just fp),m) = do
        fp' <- canonicalizePath fp
        return $ (Just fp',m)
      canon (Nothing,m)  = return (Nothing,m)

  mm' <- mapM (liftIO . canon) mm

  return mm'

canonicalizeModSummary ::
  GHC.ModSummary -> RefactGhc (Maybe FilePath, GHC.ModSummary)
canonicalizeModSummary modSum = do
  let modSum'  = (\m -> (GHC.ml_hs_file $ GHC.ms_location m, m)) modSum
      canon ((Just fp),m) = do
        fp' <- canonicalizePath fp
        return $ (Just fp',m)
      canon (Nothing,m)  = return (Nothing,m)

  mm' <- liftIO $ canon modSum'

  return mm'

-- ---------------------------------------------------------------------

getRefacSettings :: RefactGhc RefactSettings
getRefacSettings = do
  s <- get
  return (rsSettings s)

-- ---------------------------------------------------------------------

getEnabledTargets :: RefactSettings -> ([FilePath],[FilePath],[FilePath],[FilePath]) -> ([FilePath],[FilePath])
getEnabledTargets settings (libt,exet,testt,bencht) = (targetsLib,targetsExe)
  where
    (libEnabled, exeEnabled, testEnabled, benchEnabled) = rsetEnabledTargets settings
    targetsLib = on libEnabled libt
    targetsExe = on exeEnabled exet
              ++ on testEnabled testt
              ++ on benchEnabled bencht

    on flag xs = if flag then xs else []


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

{-
timeStamp :: IO String
timeStamp = do
  k <- getCurrentTime
  return (show k)
-}

-- ---------------------------------------------------------------------

instance Show GHC.ModSummary where
  show m = show $ GHC.ms_mod m

instance Show GHC.Module where
  show m = GHC.moduleNameString $ GHC.moduleName m

-- ---------------------------------------------------------------------
