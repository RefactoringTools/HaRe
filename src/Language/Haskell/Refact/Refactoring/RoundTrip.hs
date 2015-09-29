module Language.Haskell.Refact.Refactoring.RoundTrip(roundTrip) where

import qualified Language.Haskell.GhcMod as GM (Options(..))
import Language.Haskell.Refact.API

import System.Directory

-- ---------------------------------------------------------------------

-- | Roundtrip the source code, to check that the infrastructure is solid
roundTrip :: RefactSettings -> GM.Options -> FilePath -> IO [FilePath]
roundTrip settings opts fileName = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings opts [Left absFileName] (comp absFileName)

comp :: FilePath -> RefactGhc [ApplyRefacResult]
comp fileName = do
  getModuleGhc fileName
  (r,_) <- applyRefac (setRefactStreamModified RefacModified) RSAlreadyLoaded
  return [r]

-- EOF

