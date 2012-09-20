module TypeUtilsSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import           TestUtils

import qualified GHC        as GHC
import qualified GhcMonad   as GHC
import qualified Outputable as GHC
import qualified RdrName    as GHC
import qualified SrcLoc     as GHC

import Control.Monad.State
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.TypeSyn

main :: IO ()
main = hspec spec

spec :: Spec
spec = do

  describe "pNTtoPN" $ do
    it "Converts an unqualified PNT to a PN" $ do
      -- modInfo@((_, _, mod), toks) <- parsedFileBGhc
      pending "Complete this test"

    it "Converts an qualified PNT to a PN" $ do
      -- modInfo@((_, _, mod), toks) <- parsedFileBGhc
      pending "Complete this test"


-- ---------------------------------------------------------------------
-- Helper functions

parsedFileBGhc :: IO (ParseResult,[PosToken])
parsedFileBGhc = parsedFileGhc "./test/testdata/B.hs"

