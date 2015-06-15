module Language.Haskell.Refact.Utils.Cabal
  (
    cabalAllTargets
  -- , cleanupGhcModEnv
  -- , cleanupCradle
  ) where

-- import Language.Haskell.GhcMod.CabalConfig
-- import Language.Haskell.GhcMod.Error
-- import Language.Haskell.GhcMod.Gap (benchmarkBuildInfo, benchmarkTargets,
--                                     toModuleString)
-- import Language.Haskell.GhcMod.GhcPkg
-- import Language.Haskell.GhcMod.Types

--import System.Directory (getCurrentDirectory, removeDirectoryRecursive)
import Language.Haskell.GhcMod.Internal
import Language.Haskell.GhcMod
import Control.Monad (filterM)
--import Data.Maybe (maybeToList)
--import Data.Set (fromList, toList)
--import Distribution.Package (Dependency(Dependency)
--                           , PackageName(PackageName))
--import qualified Distribution.Package as C
-- import Distribution.PackageDescription (PackageDescription, TestSuite, TestSuiteInterface(..), Executable)
-- import qualified Distribution.PackageDescription as P
--import Distribution.PackageDescription.Configuration (finalizePackageDescription)
--import Distribution.PackageDescription.Parse (readPackageDescription)
--import Distribution.Simple.Compiler (CompilerInfo(..),AbiTag(..),CompilerId(..), CompilerFlavor(..))
--import Distribution.Simple.Program as C (ghcProgram)
--import Distribution.Simple.Program.Types (programName, programFindVersion)
--import Distribution.System (buildPlatform)
--import Distribution.Text (display)
--import Distribution.Verbosity (silent)
--import Distribution.Version (Version)
import System.Directory (doesFileExist)
import System.FilePath ((</>))

-- import qualified Distribution.ModuleName as M (ModuleName,toFilePath)
-- import Distribution.Helper

-- ---------------------------------------------------------------------

cabalAllTargets = do
  error $ "cabalAllTargets undefined"

----------------------------------------------------------------
{-
-- | Extracting all 'Module' 'FilePath's for libraries, executables,
-- tests and benchmarks.
cabalAllTargets :: PackageDescription -> IO ([String],[String],[String],[String])
cabalAllTargets pd = do
    exeTargets  <- mapM getExecutableTarget $ P.executables pd
    testTargets <- mapM getTestTarget $ P.testSuites pd
    return (libTargets,concat exeTargets,concat testTargets,benchTargets)
  where
    lib = case P.library pd of
            Nothing -> []
            Just l -> P.libModules l

    libTargets = map toModuleString lib
    benchTargets = benchmarkTargets pd

    getTestTarget :: TestSuite -> IO [String]
    getTestTarget ts =
       case P.testInterface ts of
        (TestSuiteExeV10 _ filePath) -> do
          let maybeTests = [p </> e | p <- P.hsSourceDirs $ P.testBuildInfo ts, e <- [filePath]]
          liftIO $ filterM doesFileExist maybeTests
        (TestSuiteLibV09 _ moduleName) -> return [toModuleString moduleName]
        (TestSuiteUnsupported _)       -> return []

    getExecutableTarget :: Executable -> IO [String]
    getExecutableTarget exe = do
      let maybeExes = [p </> e | p <- P.hsSourceDirs $ P.buildInfo exe, e <- [P.modulePath exe]]
      liftIO $ filterM doesFileExist maybeExes

-- ---------------------------------------------------------------------

benchmarkTargets :: P.PackageDescription -> [String]
benchmarkTargets pd = map toModuleString $ concatMap P.benchmarkModules $ P.benchmarks pd

toModuleString :: M.ModuleName -> String
toModuleString mn = fromFilePath $ M.toFilePath mn
  where
    fromFilePath :: FilePath -> String
    fromFilePath fp = map (\c -> if c=='/' then '.' else c) fp
-}
-- ---------------------------------------------------------------------
{-
cleanupGhcModEnv :: GhcModEnv -> IO ()
cleanupGhcModEnv env = cleanupCradle $ gmCradle env

cleanupCradle :: Cradle -> IO ()
cleanupCradle crdl = removeDirectoryRecursive $ cradleTempDir crdl

-}
