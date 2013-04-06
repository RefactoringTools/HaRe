module TestUtils 
       ( compareFiles
       , parsedFileGhc
       , runRefactGhcState
       , initialState
       , toksFromState
       , defaultTestSettings
       , logTestSettings
       , catchException
       , mkTokenCache

       , setLogger
       ) where


import qualified GHC        as GHC
import qualified GhcMonad   as GHC
import qualified Outputable as GHC
import qualified RdrName    as GHC
import qualified SrcLoc     as GHC

import Control.Monad.State
import Data.Algorithm.Diff
import Exception
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn

import Data.Tree
import System.Log.Handler.Simple
import System.Log.Logger
import qualified Data.Map as Map

-- ---------------------------------------------------------------------

compareFiles :: FilePath -> FilePath -> IO [(DI, [String])]
compareFiles fileA fileB = do
  astr <- readFile fileA
  bstr <- readFile fileB
  -- putStrLn $ "compareFiles " ++ (show $ lines astr) ++ "," ++ (show $ lines bstr) 
  return $ filter (\(c,_) -> c /= B) $ getGroupedDiff (lines astr) (lines bstr)

-- ---------------------------------------------------------------------

parsedFileGhc :: String -> IO (ParseResult,[PosToken])
parsedFileGhc fileName = do
  let
    comp = do
       (p,toks) <- parseSourceFileGhc fileName -- Load the file first
       return (p,toks)
  (parseResult,_s) <- runRefactGhcState comp
  return parseResult

-- ---------------------------------------------------------------------

initialState :: RefactState
initialState = RefSt
  { rsSettings = RefSet ["./test/testdata/"] False
  , rsUniqState = 1
  , rsFlags = RefFlags False
  , rsStorage = StorageNone
  , rsModule = Nothing
  }

-- ---------------------------------------------------------------------

toksFromState :: RefactState -> [PosToken]
toksFromState st =
  case (rsModule st) of
    Just tm -> retrieveTokens $ (tkCache $ rsTokenCache tm) Map.! mainTid
    Nothing -> []

-- ---------------------------------------------------------------------

mkTokenCache :: Tree Entry -> TokenCache
mkTokenCache forest = TK (Map.fromList [((TId 0),forest)]) (TId 0)

-- ---------------------------------------------------------------------

runRefactGhcState :: RefactGhc t -> IO (t, RefactState)
runRefactGhcState paramcomp = do
  let
     -- initialState = ReplState { repl_inputState = initInputState }
     initialState = RefSt
        { rsSettings = RefSet ["./test/testdata/"] False
        , rsUniqState = 1
        , rsFlags = RefFlags False
        , rsStorage = StorageNone
        , rsModule = Nothing
        }
  (r,s) <- runRefactGhc (initGhcSession >> paramcomp) initialState
  return (r,s)

-- ---------------------------------------------------------------------

defaultTestSettings :: Maybe RefactSettings
defaultTestSettings = Just $ RefSet ["./test/testdata/"] False

logTestSettings :: Maybe RefactSettings
logTestSettings = Just $ RefSet ["./test/testdata/"] True

-- ---------------------------------------------------------------------

catchException :: (IO t) -> IO (Maybe String)
catchException f = do
  res <- handle handler (f >> return Nothing)
  return res
  where
    handler:: SomeException -> IO (Maybe String)
    handler e = return (Just (show e))

-- ---------------------------------------------------------------------

setLogger :: IO ()
setLogger = do
  {-
  h <- fileHandler "debug.log" DEBUG >>= \lh -> return $
                 setFormatter lh (simpleLogFormatter "[$time : $loggername : $prio] $msg")
  updateGlobalLogger "MyApp.BuggyComponent" (addHandler h)
  -}

  -- s <- streamHandler stdout DEBUG
  h <- fileHandler "debug.log" DEBUG
  updateGlobalLogger rootLoggerName (setHandlers [h])

-- ---------------------------------------------------------------------

-- EOF

