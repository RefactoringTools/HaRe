module TestUtils
       ( compareFiles
       , compareStrings
       , parsedFileGhc
       , parsedFileGhcCd
       , parseSourceFileTest
       -- , getTestDynFlags
       , runLogTestGhc
       , runTestGhc
       , runRefactGhcState
       , runRefactGhcStateLog
       , initialState
       , initialLogOnState
       , showAnnDataFromState
       , showAnnDataItemFromState
       , showAnnsFromState
       , exactPrintFromState
       , sourceFromState
       , annsFromState
       , defaultTestSettings
       , logTestSettings
       , testSettingsMainfile
       , logTestSettingsMainfile
       , testOptions
       , testCradle
       , catchException
       , mkTokenCache
       , hex
       , unspace
       , mkTestGhcName
       , setLogger
       , cdAndDo
       , ct
       , pwd
       , cd
       , parseToAnnotated
       , ss2span
       ) where


-- import qualified DynFlags      as GHC
import qualified FastString    as GHC
import qualified GHC           as GHC
import qualified Name          as GHC
-- import qualified Outputable    as GHC
import qualified Unique        as GHC

import Control.Monad.State
import Data.Algorithm.Diff
import Data.Data
import Exception
import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Annotate
import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.GHC.ExactPrint.Utils
import qualified Language.Haskell.GhcMod          as GM (Options(..),defaultOptions,Cradle(..),ProjectType(..),logLevel)
import qualified Language.Haskell.GhcMod.Internal as GM (GmLogLevel(..))
import Language.Haskell.Refact.Utils.GhcBugWorkArounds
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.Types
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.Utils
import Numeric
import System.Directory
import System.Log.Handler.Simple
import System.Log.Logger

import qualified Data.Map as Map
-- import Control.Monad.IO.Class

-- ---------------------------------------------------------------------

pwd :: IO FilePath
pwd = getCurrentDirectory

cd :: FilePath -> IO ()
cd = setCurrentDirectory

-- ---------------------------------------------------------------------

hex :: Int -> String
hex v = "0x" ++ showHex v ""

-- ---------------------------------------------------------------------

compareFiles :: FilePath -> FilePath -> IO [Diff [String]]
compareFiles fileA fileB = do
  astr <- readFile fileA
  bstr <- readFile fileB
  -- return $ filter (\c -> not( isBoth c)) $ getGroupedDiff (lines astr) (lines bstr)
  return $ compareStrings astr bstr

compareStrings :: String -> String -> [Diff [String]]
compareStrings astr bstr = filter (\c -> not( isBoth c)) $ getGroupedDiff (lines astr) (lines bstr)
    where
      isBoth (Both _ _) = True
      isBoth _        = False

-- ---------------------------------------------------------------------

parsedFileGhc :: String -> IO (ParseResult,[PosToken],Targets)
parsedFileGhc fileName = do
  let
    comp = do
       res <- parseSourceFileTest fileName
       return res
  (parseResult,_s) <- runRefactGhcStateLog comp fileName Normal
  return parseResult

-- ---------------------------------------------------------------------

parsedFileGhcCd :: FilePath -> FilePath -> IO (ParseResult,[PosToken],Targets)
parsedFileGhcCd path fileName = do
  old <- getCurrentDirectory
  let
    comp = do
       res <- parseSourceFileTest fileName
       return res
    newDir = setCurrentDirectory path
    oldDir _ = setCurrentDirectory old
  (parseResult,_s) <- GHC.gbracket newDir oldDir $ \_ -> runRefactGhcState comp fileName
  return parseResult

-- ---------------------------------------------------------------------

ct :: IO a -> IO a
ct = cdAndDo "./test/testdata/"

cdAndDo :: FilePath -> IO a -> IO a
cdAndDo path fn = do
  old <- getCurrentDirectory
  r <- GHC.gbracket (setCurrentDirectory path) (\_ -> setCurrentDirectory old)
          $ \_ -> fn
  return r

-- ---------------------------------------------------------------------

parseSourceFileTest :: FilePath -> RefactGhc (ParseResult,[PosToken],Targets)
parseSourceFileTest fileName = do
  parseSourceFileGhc fileName -- Load the file first
  p <- getTypecheckedModule
  toks <- fetchOrigToks
  absFileName <- liftIO $ canonicalizePath fileName
  return (p,toks,[Left absFileName])

-- ---------------------------------------------------------------------

fetchOrigToks :: RefactGhc [PosToken]
fetchOrigToks = do
  mtm <- gets rsModule
  case mtm of
    Nothing  -> return []
    Just tm -> getRichTokenStreamWA $ GHC.ms_mod $ GHC.pm_mod_summary
                                    $ GHC.tm_parsed_module $ rsTypecheckedMod tm

-- ---------------------------------------------------------------------

initialState :: RefactState
initialState = RefSt
  { rsSettings = defaultTestSettings
  , rsUniqState = 1
  , rsSrcSpanCol = 1
  , rsFlags = RefFlags False
  , rsStorage = StorageNone
  -- , rsGraph = []
  , rsCabalGraph = []
  , rsModuleGraph = []
  , rsCurrentTarget = Nothing
  , rsModule = Nothing
  }

-- ---------------------------------------------------------------------

initialLogOnState :: RefactState
initialLogOnState = RefSt
  { rsSettings = logTestSettings
  , rsUniqState = 1
  , rsSrcSpanCol = 1
  , rsFlags = RefFlags False
  , rsStorage = StorageNone
  -- , rsGraph = []
  , rsCabalGraph = []
  , rsModuleGraph = []
  , rsCurrentTarget = Nothing
  , rsModule = Nothing
  }

-- ---------------------------------------------------------------------

mkTokenCache :: a -> TokenCache a
mkTokenCache forest = TK (Map.fromList [((TId 0),forest)]) (TId 0)

-- ---------------------------------------------------------------------

runTestInternal :: RefactGhc a -> FilePath -> RefactState -> GM.Options
                -> IO (a, RefactState)
runTestInternal comp fileName st opts =
  runRefactGhc (initGhcSession [Left fileName] >> comp) [Left fileName] st opts
  -- runRefactGhc comp [Left fileName] st opts

-- ---------------------------------------------------------------------

runLogTestGhc :: RefactGhc a -> FilePath -> IO (a, RefactState)
runLogTestGhc comp fileName =
   runTestInternal comp fileName initialLogOnState testOptions

-- ---------------------------------------------------------------------

runTestGhc :: RefactGhc a -> FilePath -> IO (a, RefactState)
runTestGhc comp fileName = do
   runTestInternal comp fileName initialState testOptions

-- ---------------------------------------------------------------------

runRefactGhcState :: RefactGhc t -> FilePath -> IO (t, RefactState)
runRefactGhcState comp fileName = runRefactGhcStateLog comp fileName Normal

-- ---------------------------------------------------------------------

runRefactGhcStateLog :: RefactGhc t -> FilePath -> VerboseLevel -> IO (t, RefactState)
runRefactGhcStateLog comp fileName logOn  = do
  let
     initState = RefSt
        { rsSettings = defaultTestSettings { rsetVerboseLevel = logOn }
        , rsUniqState = 1
        , rsSrcSpanCol = 1
        , rsFlags = RefFlags False
        , rsStorage = StorageNone
        -- , rsGraph = []
        , rsCabalGraph = []
        , rsModuleGraph = []
        , rsCurrentTarget = Nothing
        , rsModule = Nothing
        }
  runTestInternal comp fileName initState testOptions

-- ---------------------------------------------------------------------

testOptions :: GM.Options
testOptions = GM.defaultOptions { GM.logLevel = GM.GmError }

-- ---------------------------------------------------------------------

testCradle :: GM.Cradle
-- testCradle = GM.Cradle GM.CabalProject "./test/testdata/" "./test/testdata/" "/tmp" Nothing "./dist"
testCradle = GM.Cradle GM.CabalProject "./test/testdata/" "./test/testdata/" "/tmp" Nothing
{-
-- | The environment where this library is used.
data Cradle = Cradle {
    cradleProjectType:: ProjectType
  -- | The directory where this library is executed.
  , cradleCurrentDir :: FilePath
  -- | The project root directory.
  , cradleRootDir    :: FilePath
  -- | Per-Project temporary directory
  , cradleTempDir    :: FilePath
  -- | The file name of the found cabal file.
  , cradleCabalFile  :: Maybe FilePath
  -- | The build info directory.
  , cradleDistDir    :: FilePath
  } deriving (Eq, Show)
-}
-- ---------------------------------------------------------------------

defaultTestSettings :: RefactSettings
defaultTestSettings = defaultSettings { rsetImportPaths = ["./test/testdata/"]
                                      , rsetCheckTokenUtilsInvariant = True
                                      , rsetVerboseLevel = Normal }

logTestSettings :: RefactSettings
logTestSettings = defaultSettings { rsetImportPaths = ["./test/testdata/"]
                                  , rsetCheckTokenUtilsInvariant = True
                                  , rsetVerboseLevel = Debug
                                  }

testSettingsMainfile :: FilePath -> RefactSettings
testSettingsMainfile mainFile = defaultTestSettings { rsetMainFile = Just [mainFile] }

logTestSettingsMainfile :: FilePath -> RefactSettings
logTestSettingsMainfile mainFile = logTestSettings { rsetMainFile = Just [mainFile] }

-- ---------------------------------------------------------------------

catchException :: (IO t) -> IO (Maybe String)
catchException f = do
  res <- handle handler (f >> return Nothing)
  return res
  where
    handler:: SomeException -> IO (Maybe String)
    handler e = return (Just (show e))

-- ---------------------------------------------------------------------

showAnnDataFromState :: RefactState -> String
showAnnDataFromState st =
  case rsModule st of
    Just tm -> r
      where
        anns = tkCache (rsTokenCache tm) Map.! mainTid
        parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module
                 $ rsTypecheckedMod tm
        r = showAnnData anns 0 parsed
    Nothing -> []

-- ---------------------------------------------------------------------

showAnnDataItemFromState :: (Data a) => RefactState -> a -> String
showAnnDataItemFromState st t =
  case rsModule st of
    Just tm -> r
      where
        anns = tkCache (rsTokenCache tm) Map.! mainTid
        r = showAnnData anns 0 t
    Nothing -> []

-- ---------------------------------------------------------------------

showAnnsFromState :: RefactState -> String
showAnnsFromState st =
  case rsModule st of
    Just tm -> r
      where
        anns = tkCache (rsTokenCache tm) Map.! mainTid
        r = showGhc anns
    Nothing -> []

-- ---------------------------------------------------------------------

exactPrintFromState :: (Annotate a) => RefactState -> GHC.Located a -> String
exactPrintFromState st ast =
  case rsModule st of
    Just tm -> r
      where
        -- anns = tkCache (rsTokenCache tm) Map.! mainTid
        anns = case Map.lookup mainTid (tkCache (rsTokenCache tm)) of
          Just a -> a
          Nothing -> error $ "exactPrintFromState:mainTid not found"
        r = exactPrintWithAnns ast anns
    Nothing -> []

-- ---------------------------------------------------------------------

sourceFromState :: RefactState -> String
sourceFromState st =
  case rsModule st of
    Just tm -> r
      where
        anns = tkCache (rsTokenCache tm) Map.! mainTid
        parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module
                 $ rsTypecheckedMod tm
        r = exactPrintWithAnns parsed anns
    Nothing -> []

-- ---------------------------------------------------------------------

annsFromState :: RefactState -> Anns
annsFromState st =
  case rsModule st of
    Just tm -> tkCache (rsTokenCache tm) Map.! mainTid
    Nothing -> error $ "annsFromState: no rsModule"

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

nullSrcSpan :: GHC.SrcSpan
nullSrcSpan = GHC.UnhelpfulSpan $ GHC.mkFastString "HaRe nullSrcSpan"

-- ---------------------------------------------------------------------

parseToAnnotated :: (Show a, Annotate ast)
                 => GHC.DynFlags
                 -> FilePath
                 -> (GHC.DynFlags -> FilePath -> String -> Either a (Anns, GHC.Located ast))
                 -- -> Parser
                 -> String
                 -> (GHC.Located ast, Anns)
parseToAnnotated df fp parser src = (ast,anns)
  where
    (anns, ast) = case (parser df fp src) of
                            Right xs -> xs
                            Left err -> error (show err)

-- ---------------------------------------------------------------------

ss2span :: GHC.SrcSpan -> (Pos,Pos)
ss2span ss = (ss2pos ss,ss2posEnd ss)

-- ---------------------------------------------------------------------
-- EOF
