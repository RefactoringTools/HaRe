module SwapArgsSpec (main, spec) where

import           Test.Hspec

-- import qualified GHC      as GHC
-- import qualified GhcMonad as GHC
-- import qualified RdrName  as GHC
-- import qualified SrcLoc   as GHC

import Language.Haskell.Refact.Refactoring.SwapArgs

import TestUtils

import System.Directory

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  -- setLogger
  hspec spec

spec :: Spec
spec = do

  describe "swapArgs" $ do
    it "checks for that an identifier is selected" $ do
     res <- catchException (ct $ swapArgs defaultTestSettings testOptions ["./SwapArgs/B.hs","4","1"])
     -- let res = "foo"
     (show res) `shouldBe` "Just \"Incorrect identifier selected!\""


    it "swaps arguments for a definition at the top level" $ do
     r <- ct $ swapArgs defaultTestSettings testOptions ["./SwapArgs/B.hs","9","1"]
     -- r <- ct $ swapArgs logTestSettings testOptions ["./SwapArgs/B.hs","9","1"]
     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     (show r') `shouldBe` "[\"SwapArgs/B.hs\"]"
     pendingWith "need to complete this"
     -- diff <- compareFiles "./test/testdata/SwapArgs/B.refactored.hs"
     --                      "./test/testdata/SwapArgs/B.hs.expected"
     -- diff `shouldBe` []



-- ---------------------------------------------------------------------
-- Helper functions

