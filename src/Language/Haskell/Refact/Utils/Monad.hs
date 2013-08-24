{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}
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

import Control.Monad.State
import Exception
import qualified Control.Monad.IO.Class as MU

-- import qualified Bag           as GHC
-- import qualified BasicTypes    as GHC
-- import qualified Coercion      as GHC
-- import qualified Digraph       as GHC
import qualified DynFlags      as GHC
-- import qualified ErrUtils      as GHC
-- import qualified FastString    as GHC
-- import qualified ForeignCall   as GHC
import qualified GHC           as GHC
import qualified GHC.Paths     as GHC
import qualified GhcMonad      as GHC
-- import qualified HsSyn         as GHC
-- import qualified InstEnv       as GHC
-- import qualified Module        as GHC
import qualified MonadUtils    as GHC
-- import qualified NameSet       as GHC
-- import qualified OccName       as GHC
-- import qualified Outputable    as GHC
-- import qualified RdrName       as GHC
-- import qualified SrcLoc        as GHC
-- import qualified StaticFlags   as GHC
-- import qualified TcEvidence    as GHC
-- import qualified TcType        as GHC
-- import qualified TypeRep       as GHC
-- import qualified Var           as GHC

import Language.Haskell.GhcModLowLevel
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn

-- ---------------------------------------------------------------------

data VerboseLevel = Debug | Normal | Off
            deriving (Eq,Show)

data RefactSettings = RefSet
        { rsetGhcOpts      :: ![String]
        , rsetExpandSplice :: Bool
        -- | The sandbox directory.
        , rsetSandbox      :: Maybe FilePath
        , rsetVerboseLevel :: !VerboseLevel
        } deriving (Show)

defaultSettings :: RefactSettings
defaultSettings = RefSet [] False Nothing Normal

logSettings :: RefactSettings
logSettings = defaultSettings { rsetVerboseLevel = Debug }


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
{-
initGhcSession :: RefactGhc ()
initGhcSession = do
      settings <- getRefacSettings
      dflags   <- GHC.getSessionDynFlags
      let dflags' = foldl GHC.xopt_set dflags
                    [GHC.Opt_Cpp, GHC.Opt_ImplicitPrelude, GHC.Opt_MagicHash
                    ]
          dflags'' = dflags' { GHC.importPaths = rsetImportPath settings }

          -- Enable GHCi style in-memory linking
          dflags''' = dflags'' { GHC.hscTarget = GHC.HscInterpreted,
                                 GHC.ghcLink   = GHC.LinkInMemory }

      _ <- GHC.setSessionDynFlags dflags'''
      return ()
-}

initGhcSession :: Cradle -> RefactGhc ()
initGhcSession cradle = do
    settings <- getRefacSettings
    let opt = Options {
                 outputStyle = PlainStyle
                 , hlintOpts = []
                 , ghcOpts = (rsetGhcOpts settings)
                 , operators = False
                 , detailed = False
                 , expandSplice = False
                 , sandbox = (rsetSandbox settings)
                 }
    readLog <- initializeFlagsWithCradle opt cradle (options settings) True
    -- setTargetFile fileName
    -- checkSlowAndSet
    void $ GHC.load GHC.LoadAllTargets
    -- liftIO readLog
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

