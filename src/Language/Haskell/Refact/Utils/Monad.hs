{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Language.Haskell.Refact.Utils.Monad
       ( ParseResult
       , VerboseLevel(..)
       , RefactSettings(..)
       , RefactState(..)
       , RefactModule(..)
       , TargetModule
       , RefactStashId(..)
       , RefactFlags(..)
       , StateStorage(..)

       -- GHC monad stuff
       , RefactGhc
       , runRefactGhc
       , getRefacSettings
       , defaultSettings
       , logSettings
       , initGhcSession

       , loadModuleGraphGhc
       , ensureTargetLoaded
       , canonicalizeGraph

       , logm
       ) where


import qualified GHC           as GHC
import qualified GHC.Paths     as GHC
import qualified GhcMonad      as GHC
import qualified MonadUtils    as GHC

import Control.Monad.State
import Data.List
import Data.Time.Clock
import Data.Tree
import Exception
import Language.Haskell.GhcMod
import Language.Haskell.GhcMod.Internal
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn
import System.Directory
import System.Log.Logger
import qualified Control.Monad.IO.Class as MU

-- ---------------------------------------------------------------------

data VerboseLevel = Debug | Normal | Off
            deriving (Eq,Show)

data RefactSettings = RefSet
        { rsetGhcOpts      :: ![String]
        , rsetImportPaths :: ![FilePath]
        , rsetExpandSplice :: Bool
        , rsetLineSeparator :: LineSeparator
        , rsetMainFile     :: Maybe FilePath
        , rsetCheckTokenUtilsInvariant :: !Bool
        , rsetVerboseLevel :: !VerboseLevel
        , rsetEnabledTargets :: (Bool,Bool,Bool,Bool)
        } deriving (Show)

deriving instance Show LineSeparator

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
        , rsOrigTokenStream :: ![PosToken]  -- ^Original Token stream for the current module
        , rsTokenCache      :: !TokenCache  -- ^Token stream for the current module, maybe modified, in SrcSpan tree form
        , rsStreamModified  :: !Bool        -- ^current module has updated the token stream
        }

data RefactFlags = RefFlags
       { rsDone :: !Bool -- ^Current traversal has already made a change
       }

-- | State for refactoring a single file. Holds/hides the token
-- stream, which gets updated transparently at key points.
data RefactState = RefSt
        { rsSettings  :: !RefactSettings -- ^Session level settings
        , rsUniqState :: !Int -- ^ Current Unique creator value, incremented every time it is used
        , rsFlags     :: !RefactFlags -- ^ Flags for controlling generic traversals
        , rsStorage   :: !StateStorage -- ^Temporary storage of values
                                      -- while refactoring takes place
        , rsGraph     :: [TargetGraph]
        , rsModuleGraph :: [(FilePath,GHC.ModuleGraph)]
        , rsCurrentTarget :: Maybe FilePath
        , rsModule    :: !(Maybe RefactModule) -- ^The current module being refactored
        }

type TargetModule = (FilePath, GHC.ModSummary)

type TargetGraph = (FilePath,[(Maybe FilePath, GHC.ModSummary)])

-- |Result of parsing a Haskell source file. It is simply the
-- TypeCheckedModule produced by GHC.
type ParseResult = GHC.TypecheckedModule

-- |Provide some temporary storage while the refactoring is taking
-- place
data StateStorage = StorageNone
                  | StorageBind (GHC.LHsBind GHC.Name)
                  | StorageSig (GHC.LSig GHC.Name)

instance Show StateStorage where
  show StorageNone        = "StorageNone"
  show (StorageBind _bind) = "(StorageBind " {- ++ (showGhc bind) -} ++ ")"
  show (StorageSig _sig)   = "(StorageSig " {- ++ (showGhc sig) -} ++ ")"

-- ---------------------------------------------------------------------
-- StateT and GhcT stack

type RefactGhc a = GHC.GhcT (StateT RefactState IO) a

instance (MU.MonadIO (GHC.GhcT (StateT RefactState IO))) where
         liftIO = GHC.liftIO

instance GHC.MonadIO (StateT RefactState IO) where
         liftIO f = MU.liftIO f

instance ExceptionMonad m => ExceptionMonad (StateT s m) where
    gcatch f h = StateT $ \s -> gcatch (runStateT f s) (\e -> runStateT (h e) s)
    gblock = mapStateT gblock
    gunblock = mapStateT gunblock


instance (MonadState RefactState (GHC.GhcT (StateT RefactState IO))) where
    get = lift get
    put = lift . put
    -- state = lift . state

instance (MonadTrans GHC.GhcT) where
   lift = GHC.liftGhcT

instance (MonadPlus m,Functor m,GHC.MonadIO m,ExceptionMonad m) => MonadPlus (GHC.GhcT m) where
  mzero = GHC.GhcT $ \_s -> mzero
  x `mplus` y = GHC.GhcT $ \_s -> (GHC.runGhcT (Just GHC.libdir) x) `mplus` (GHC.runGhcT (Just GHC.libdir) y)

-- ---------------------------------------------------------------------

-- | Initialise the GHC session, when starting a refactoring.
--   This should never be called directly.
initGhcSession :: Cradle -> [FilePath] -> RefactGhc ()
initGhcSession cradle importDirs = do
    settings <- getRefacSettings
    let ghcOptsDirs =
         case importDirs of
           [] -> (rsetGhcOpts settings)
           _  -> ("-i" ++ (intercalate ":" importDirs)):(rsetGhcOpts settings)
    let opt = Options {
                 outputStyle = PlainStyle
                 , hlintOpts = []
                 , ghcOpts = ghcOptsDirs
                 , operators = False
                 , detailed = False
                 , qualified = False
                 , expandSplice = False
                 , lineSeparator = rsetLineSeparator settings
                 , packageId = Nothing -- TODO: work this through if needed
                 }
    (_readLog,mcabal) <- initializeFlagsWithCradle opt cradle (options settings) True

    case mcabal of
      Just cabal -> do
        targets <- liftIO $ cabalAllTargets cabal
        -- liftIO $ warningM "HaRe" $ "initGhcSession:targets=" ++ show targets
        -- error $ "initGhcSession:targets=" ++ show targets

        -- TODO: Cannot load multiple main modules, must try to load
        -- each main module and retrieve its module graph, and then
        -- set the targets to this superset.

        let targets' = getEnabledTargets settings targets
        -- let (libt,exet,testt,bencht) = targets
        -- error $ "initGhcSession:targets'=" ++ show targets'
        -- liftIO $ warningM "HaRe" $ "initGhcSession:targets'=" ++ show targets'

        case targets' of
          [] -> return ()
          tgts -> do
                     -- liftIO $ warningM "HaRe" $ "initGhcSession:tgts=" ++ (show tgts)
                     -- setTargetFiles tgts
                     -- void $ GHC.load GHC.LoadAllTargets

                     mapM_ loadModuleGraphGhc $ map Just tgts

      Nothing -> do
          let maybeMainFile = rsetMainFile settings
          loadModuleGraphGhc maybeMainFile
          return()

    -- graph <- gets rsGraph
    -- liftIO $ warningM "HaRe" $ "initGhcSession:graph=" ++ show graph
    return ()
    where
      options opt
        | rsetExpandSplice opt = "-w:"   : rsetGhcOpts opt
        | otherwise            = "-Wall" : rsetGhcOpts opt

-- ---------------------------------------------------------------------

-- | Load a module graph into the GHC session, starting from main
loadModuleGraphGhc ::
  Maybe FilePath -> RefactGhc ()
loadModuleGraphGhc maybeTargetFile = do
  -- liftIO $ warningM "HaRe" $ "loadModuleGraphGhc:maybeTargetFile=" ++ show maybeTargetFile
  case maybeTargetFile of
    Just targetFile -> do
      loadTarget targetFile
      -- setTargetFiles [targetFile]
      -- void $ GHC.load GHC.LoadAllTargets

      graph <- GHC.getModuleGraph
      cgraph <- liftIO $ canonicalizeGraph graph

      settings <- get
      put $ settings { rsGraph = (rsGraph settings) ++ [(targetFile,cgraph)]
                     , rsModuleGraph = (rsModuleGraph settings) ++ [(targetFile,graph)]
                     , rsCurrentTarget = maybeTargetFile
                     }

      -- logm $ "loadModuleGraphGhc:cgraph=" ++ show (map fst cgraph)
      logm $ "loadModuleGraphGhc:cgraph=" ++ showGhc graph

      return ()
    Nothing -> return ()
  return ()

-- ---------------------------------------------------------------------

loadTarget :: FilePath -> RefactGhc ()
loadTarget targetFile = do
      setTargetFiles [targetFile]
      void $ GHC.load GHC.LoadAllTargets

-- ---------------------------------------------------------------------

-- | Make sure the given file is the currently loaded target, and load
-- it if not. Assumes that all the module graphs had been generated
-- before, so these are not updated.
ensureTargetLoaded :: FilePath -> RefactGhc ()
ensureTargetLoaded target = do
  settings <- get
  let currentTarget = rsCurrentTarget settings
  if currentTarget == Just target
    then return ()
    else do
      loadTarget target
      put $ settings { rsCurrentTarget = Just target}
      return ()

-- ---------------------------------------------------------------------

canonicalizeGraph ::
  [GHC.ModSummary] -> IO [(Maybe (FilePath), GHC.ModSummary)]
canonicalizeGraph graph = do
  let mm = map (\m -> (GHC.ml_hs_file $ GHC.ms_location m, m)) graph
      canon ((Just fp),m) = do
        fp' <- canonicalizePath fp
        return $ (Just fp',m)
      canon (Nothing,m)  = return (Nothing,m)

  mm' <- mapM canon mm

  return mm'

-- ---------------------------------------------------------------------

runRefactGhc ::
  RefactGhc a -> RefactState -> IO (a, RefactState)
runRefactGhc comp initState = do
    runStateT (GHC.runGhcT (Just GHC.libdir) comp) initState

getRefacSettings :: RefactGhc RefactSettings
getRefacSettings = do
  s <- get
  return (rsSettings s)

-- ---------------------------------------------------------------------

getEnabledTargets :: RefactSettings -> ([FilePath],[FilePath],[FilePath],[FilePath]) -> [FilePath]
getEnabledTargets settings (libt,exet,testt,bencht) = targets
  where
    (libEnabled, exeEnabled, testEnabled, benchEnabled) = rsetEnabledTargets settings
    targets = on libEnabled libt
           ++ on exeEnabled exet
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

timeStamp :: IO String
timeStamp = do
  k <- getCurrentTime
  return (show k)

-- ---------------------------------------------------------------------

instance Show GHC.ModSummary where
  show m = show $ GHC.ms_mod m

instance Show GHC.Module where
  show m = GHC.moduleNameString $ GHC.moduleName m

-- ---------------------------------------------------------------------
