module TestUtils
       ( compareFiles
       , parsedFileGhc
       , parseSourceFileTest
       , getTestDynFlags
       , runLogTestGhc
       , runTestGhc
       , runRefactGhcState
       , runRefactGhcStateLog
       , initialState
       , initialLogOnState
       , toksFromState
       , entriesFromState
       , defaultTestSettings
       , logTestSettings
       , testSettingsMainfile
       , logTestSettingsMainfile
       , testCradle
       , catchException
       , mkTokenCache
       , hex
       , unspace
       , mkTestGhcName
       , setLogger
       ) where


-- import qualified Bag           as GHC
-- import qualified BasicTypes    as GHC
-- import qualified FastString    as GHC
import qualified GHC           as GHC
-- import qualified Lexer         as GHC
-- import qualified Module        as GHC
import qualified Name          as GHC
-- import qualified NameSet       as GHC
-- import qualified Outputable    as GHC
-- import qualified RdrName       as GHC
-- import qualified SrcLoc        as GHC
import qualified Unique        as GHC
-- import qualified UniqSet       as GHC

import Data.Algorithm.Diff
import Exception
import Language.Haskell.GhcModLowLevel
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn
import Numeric

import Data.Tree
import System.Log.Handler.Simple
import System.Log.Logger
import qualified Data.Map as Map


-- ---------------------------------------------------------------------

hex :: Int -> String
hex v = "0x" ++ showHex v ""

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
       res <- parseSourceFileTest fileName
       return res
  (parseResult,_s) <- runRefactGhcState comp
  return parseResult

-- ---------------------------------------------------------------------

parseSourceFileTest :: FilePath -> RefactGhc (ParseResult,[PosToken])
parseSourceFileTest fileName = do
  parseSourceFileGhc fileName -- Load the file first
  p <- getTypecheckedModule
  toks <- fetchOrigToks
  return (p,toks)

-- ---------------------------------------------------------------------

initialState :: RefactState
initialState = RefSt
  { rsSettings = defaultTestSettings
  , rsUniqState = 1
  , rsFlags = RefFlags False
  , rsStorage = StorageNone
  , rsModule = Nothing
  }

-- ---------------------------------------------------------------------

initialLogOnState :: RefactState
initialLogOnState = RefSt
  { rsSettings = logTestSettings
  , rsUniqState = 1
  , rsFlags = RefFlags False
  , rsStorage = StorageNone
  , rsModule = Nothing
  }

-- ---------------------------------------------------------------------

toksFromState :: RefactState -> [PosToken]
toksFromState st =
  case (rsModule st) of
    -- Just tm -> retrieveTokens $ (tkCache $ rsTokenCache tm) Map.! mainTid
    Just tm -> retrieveTokensFinal $ (tkCache $ rsTokenCache tm) Map.! mainTid
    Nothing -> []

-- ---------------------------------------------------------------------

entriesFromState :: RefactState -> [Entry]
entriesFromState st =
  case (rsModule st) of
    -- Just tm -> retrieveTokens $ (tkCache $ rsTokenCache tm) Map.! mainTid
    Just tm -> retrieveTokens' $ (tkCache $ rsTokenCache tm) Map.! mainTid
    Nothing -> []

-- ---------------------------------------------------------------------

mkTokenCache :: Tree Entry -> TokenCache
mkTokenCache forest = TK (Map.fromList [((TId 0),forest)]) (TId 0)

-- ---------------------------------------------------------------------

getTestDynFlags :: IO GHC.DynFlags
getTestDynFlags = do
  (df,_) <- runTestGhc $ GHC.getSessionDynFlags
  return df

-- ---------------------------------------------------------------------

runLogTestGhc :: RefactGhc a -> IO (a, RefactState)
runLogTestGhc comp = do
   res <- runRefactGhc comp $ initialLogOnState
   return res

-- ---------------------------------------------------------------------

runTestGhc :: RefactGhc a -> IO (a, RefactState)
runTestGhc comp = do
   res <- runRefactGhc comp $ initialState
   return res

-- ---------------------------------------------------------------------

runRefactGhcState :: RefactGhc t -> IO (t, RefactState)
runRefactGhcState paramcomp = runRefactGhcStateLog paramcomp Normal

-- ---------------------------------------------------------------------

runRefactGhcStateLog :: RefactGhc t -> VerboseLevel -> IO (t, RefactState)
runRefactGhcStateLog paramcomp logOn  = do
  let
     initState = RefSt
        { rsSettings = defaultTestSettings { rsetVerboseLevel = logOn }
        , rsUniqState = 1
        , rsFlags = RefFlags False
        , rsStorage = StorageNone
        , rsModule = Nothing
        }
  (r,s) <- runRefactGhc (initGhcSession testCradle (rsetImportPaths defaultTestSettings) >> 
                                                paramcomp) initState
  return (r,s)

-- ---------------------------------------------------------------------

testCradle :: Cradle
testCradle = Cradle "./test/testdata/" Nothing Nothing Nothing

-- ---------------------------------------------------------------------

defaultTestSettings :: RefactSettings
defaultTestSettings = defaultSettings { rsetImportPaths = ["./test/testdata/"]
                                      , rsetVerboseLevel = Normal }

logTestSettings :: RefactSettings
logTestSettings = defaultSettings { rsetImportPaths = ["./test/testdata/"]
                                  , rsetVerboseLevel = Debug }

testSettingsMainfile :: FilePath -> RefactSettings
testSettingsMainfile mainFile = defaultTestSettings { rsetMainFile = Just mainFile }

logTestSettingsMainfile :: FilePath -> RefactSettings
logTestSettingsMainfile mainFile = logTestSettings { rsetMainFile = Just mainFile }

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

-- |Convert any sequence of more than one space to a single space
unspace :: String -> String
unspace str = go [] str
  where
    go acc []  = acc
    go acc [x] = acc ++ [x]
    go acc (' ':' ':xs) = go acc (' ':xs)
    go acc (x:xs) = go (acc++[x]) xs

-- ---------------------------------------------------------------------

mkTestGhcName :: Int -> Maybe GHC.Module -> String -> GHC.Name
mkTestGhcName u maybeMod name = n
  where
      un = GHC.mkUnique 'H' (u+1) -- H for HaRe :)
      n = case maybeMod of
               Nothing -> GHC.localiseName $ GHC.mkSystemName un (GHC.mkVarOcc name)
               Just modu -> GHC.mkExternalName un modu (GHC.mkVarOcc name) nullSrcSpan

-- ---------------------------------------------------------------------

-- EOF

