{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
module Language.Haskell.Refact.Utils.Monad
       ( ParseResult
       , RefactResult
       , RefactSettings(..)
       , RefactState(..)
       -- GHC monad stuff
       , RefactGhc
       , runRefactGhc
       , getRefacSettings

       -- * Conveniences for state access
       , fetchToks
       , putToks
       , getRefactInscopes
       , getRefactRenamed
       , getRefactParsed

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

import Language.Haskell.Refact.Utils.TypeSyn

data RefactSettings = RefSet
        { rsetImportPath :: [FilePath]
        } deriving (Show)


-- | State for refactoring a single file. Holds/hides the token
-- stream, which gets updated transparently at key points.
data RefactState = RefSt
        { rsSettings :: RefactSettings -- ^Session level settings
        , rsUniqState :: Int -- ^ Current Unique creator value, incremented every time it is used

        -- The current module being refactored
        , rsTypecheckedMod :: GHC.TypecheckedModule
        , rsTokenStream :: [PosToken]  -- ^Token stream for the current module
        , rsStreamModified :: Bool     -- ^current module has updated the token stream
        }

-- |Result of parsing a Haskell source file. The first element in the
-- result is the inscope relation, the second element is the export
-- relation and the third is the AST of the module. This is likely to
-- change as we learn more

-- type ParseResult = (InScopes, Maybe GHC.RenamedSource, GHC.ParsedSource) 
type ParseResult = GHC.TypecheckedModule

type RefactResult = GHC.RenamedSource


-- ---------------------------------------------------------------------
-- StateT and GhcT stack

type RefactGhc a = GHC.GhcT (StateT RefactState IO) a

instance (MonadIO (GHC.GhcT (StateT RefactState IO))) where
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

{-
instance MonadPlus (RefactGhc a) where
   mzero = RefactGhc (StateT(\ st -> mzero))

   -- x `mplus` y =  RefactGhc (StateT ( \ st -> runRefact x st `mplus` runRefact y st))  
   -- ^Try one of the refactorings, x or y, with the same state plugged in
-}

runRefactGhc ::
  RefactGhc a -> RefactState -> IO (a, RefactState)
runRefactGhc comp initState = do
    runStateT (GHC.runGhcT (Just GHC.libdir) comp) initState

getRefacSettings :: RefactGhc RefactSettings
getRefacSettings = do
  s <- get
  return (rsSettings s)

-- ---------------------------------------------------------------------

fetchToks :: RefactGhc [PosToken]
fetchToks = gets rsTokenStream

putToks :: [PosToken] -> Bool -> RefactGhc ()
putToks toks isModified = do
  st <- get
  put $ st {rsTokenStream = toks, rsStreamModified = isModified}

-- ---------------------------------------------------------------------

-- type ParseResult = (InScopes, Maybe GHC.RenamedSource, GHC.ParsedSource) 
getRefactInscopes :: RefactGhc InScopes
getRefactInscopes = GHC.getNamesInScope

getRefactRenamed :: RefactGhc GHC.RenamedSource
getRefactRenamed = do
  t <- gets rsTypecheckedMod
  return $ fromJust $ GHC.tm_renamed_source t

getRefactParsed :: RefactGhc GHC.ParsedSource
getRefactParsed = do
  t <- gets rsTypecheckedMod
  let pm = GHC.tm_parsed_module t
  return $ GHC.pm_parsed_source pm

-- ---------------------------------------------------------------------

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

