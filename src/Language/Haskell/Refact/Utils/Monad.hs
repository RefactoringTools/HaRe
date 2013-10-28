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

       ) where


import qualified GHC           as GHC
import qualified GHC.Paths     as GHC
import qualified GhcMonad      as GHC
import qualified MonadUtils    as GHC

import Control.Monad.State
import Data.List
import Exception
import Language.Haskell.GhcMod
import Language.Haskell.GhcMod.Internal
import Language.Haskell.Refact.Utils.LayoutTypes
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn
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
    , rsetEnabledTargets = (True,False,True,False)
    }

logSettings :: RefactSettings
logSettings = defaultSettings { rsetVerboseLevel = Debug }


data RefactStashId = Stash !String deriving (Show,Eq,Ord)

data RefactModule = RefMod
        { rsTypecheckedMod  :: !GHC.TypecheckedModule
        , rsOrigTokenStream :: ![PosToken]  -- ^Original Token stream for the current module
        , rsTokenCache      :: !TokenCache  -- ^Token stream for the current module, maybe modified, in SrcSpan tree form
        , rsTokenLayout     :: !TokenLayout -- ^Token stream for the current module, maybe modified, in SrcSpan tree form
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
        , rsModule    :: !(Maybe RefactModule) -- ^The current module being refactored
        }

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
                 , expandSplice = False
                 , lineSeparator = rsetLineSeparator settings
                 }
    (_readLog,mcabal) <- initializeFlagsWithCradle opt cradle (options settings) True

    case mcabal of
      Just cabal -> do
        targets <- liftIO $ cabalAllTargets cabal
        -- liftIO $ warningM "HaRe" $ "initGhcSession:targets=" ++ show targets

        -- TODO: Cannot load multiple main modules, must try to load
        -- each main module and retrieve its module graph, and then
        -- set the targets to this superset.

        let targets' = getEnabledTargets settings targets
        -- let (libt,exet,testt,bencht) = targets
        -- case libt ++ exet ++ testt ++ bencht of
        -- case libt {- ++ exet -} ++ testt ++ bencht of
        case targets' of
          [] -> return ()
          tgts -> do
                     -- liftIO $ warningM "HaRe" $ "initGhcSession:tgts=" ++ (show tgts)
                     setTargetFiles tgts
                     checkSlowAndSet
                     void $ GHC.load GHC.LoadAllTargets

      Nothing -> return()

    return ()
    where
      options opt
        | rsetExpandSplice opt = "-w:"   : rsetGhcOpts opt
        | otherwise            = "-Wall" : rsetGhcOpts opt


runRefactGhc ::
  RefactGhc a -> RefactState -> IO (a, RefactState)
runRefactGhc comp initState = do
    runStateT (GHC.runGhcT (Just GHC.libdir) comp) initState
    -- runStateT (GHC.runGhcT (Just GHC.libdir) (initGhcSession >> comp)) initState

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
-- ++AZ++ trying to wrap this in GhcT, or vice versa
-- For inspiration:
-- https://github.com/bjpop/berp/blob/200fa0f26a4da7c6f6ff6fcdc29a2468a1c39e60/src/Berp/Interpreter/Monad.hs
{-
type Repl a = GhcT (StateT ReplState Compile) a

data ReplState = ReplState { repl_inputState :: !InputState }

runRepl :: Maybe FilePath -> Repl a -> IO a
runRepl filePath comp = do
   initInputState <- initializeInput defaultSettings
   let initReplState = ReplState { repl_inputState = initInputState }
   runCompileMonad $ (flip evalStateT) initReplState $ runGhcT filePath comp

withInputState :: (InputState -> Repl a) -> Repl a
withInputState f = do
   state <- liftGhcT $ gets repl_inputState
   f state

-- Ugliness because GHC has its own MonadIO class
instance MU.MonadIO m => MonadIO (GhcT m) where
   liftIO = MU.liftIO

instance MonadIO m => MU.MonadIO (StateT s m) where
   liftIO = MT.liftIO

instance ExceptionMonad m => ExceptionMonad (StateT s m) where
    gcatch f h = StateT $ \s -> gcatch (runStateT f s) (\e -> runStateT (h e) s)
    gblock = mapStateT gblock
    gunblock = mapStateT gunblock
-}

