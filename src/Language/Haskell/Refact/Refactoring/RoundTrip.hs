module Language.Haskell.Refact.Refactoring.RoundTrip(roundTrip) where

-- import qualified Data.Generics         as SYB
-- import qualified GHC.SYB.Utils         as SYB

-- import qualified GHC           as GHC

-- import Control.Monad
-- import Control.Monad.IO.Class
import Language.Haskell.GhcMod
import Language.Haskell.Refact.API

-- ---------------------------------------------------------------------

-- | Roundtrip the source code, to check that the infrastructure is solid
roundTrip :: RefactSettings -> Options -> FilePath -> IO [FilePath]
roundTrip settings opts fileName =
  runRefacSession settings opts (comp fileName)

comp :: FilePath -> RefactGhc [ApplyRefacResult]
comp fileName = do
  getModuleGhc fileName
  (r,_) <- applyRefac (setRefactStreamModified RefacModified) RSAlreadyLoaded
  return [r]

-- EOF



