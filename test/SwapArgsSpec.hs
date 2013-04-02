module SwapArgsSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import qualified GHC      as GHC
import qualified GhcMonad as GHC
import qualified RdrName  as GHC
import qualified SrcLoc   as GHC

import Exception
import Control.Monad.State
import Language.Haskell.Refact.SwapArgs
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.LocUtils

import TestUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  setLogger
  hspec spec

spec :: Spec
spec = do

  describe "swapArgs" $ do
    it "checks for that an identifier is selected" $ do
     res <- catchException (swapArgs ["./test/testdata/SwapArgs/B.hs","4","1"])
     -- let res = "foo"
     (show res) `shouldBe` "Just \"Incorrect identifier selected!\""


    it "swaps arguments for a definition at the top level" $ do
     swapArgs ["./test/testdata/SwapArgs/B.hs","9","1"]
     diff <- compareFiles "./test/testdata/SwapArgs/B.hs.refactored"
                          "./test/testdata/SwapArgs/B.hs.expected"
     diff `shouldBe` []



-- ---------------------------------------------------------------------
-- Helper functions

