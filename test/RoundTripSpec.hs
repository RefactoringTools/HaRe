module RoundTripSpec (main, spec) where

import           Test.Hspec

import Language.Haskell.Refact.Refactoring.RoundTrip

import TestUtils

import System.Directory

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do
  describe "roundtrip" $ do
    it "roundtrips B" $ do
      r <- ct $ roundTrip defaultTestSettings testOptions "Case/BSimpleExpected.hs"
      -- r <- ct $ roundTrip logTestSettings testOptions "Case/BSimpleExpected.hs"
      r' <- ct $ mapM makeRelativeToCurrentDirectory r
      r' `shouldBe` ["Case/BSimpleExpected.hs"]
      diff <- compareFiles "./test/testdata/Case/BSimpleExpected.refactored.hs"
                           "./test/testdata/Case/BSimpleExpected.hs"
      diff `shouldBe` []

    -- ---------------------------------

    it "roundtrips FooExpected" $ do
      r <- ct $ roundTrip defaultTestSettings testOptions "Case/FooExpected.hs"
      -- r <- ct $ roundTrip logTestSettings testOptions "Case/FooExpected.hs"
      r' <- ct $ mapM makeRelativeToCurrentDirectory r
      r' `shouldBe` ["Case/FooExpected.hs"]
      diff <- compareFiles "./test/testdata/Case/FooExpected.refactored.hs"
                           "./test/testdata/Case/FooExpected.hs"
      diff `shouldBe` []

    -- ---------------------------------

    it "roundtrips FExpected" $ do
      r <- ct $ roundTrip defaultTestSettings testOptions "Case/FExpected.hs"
      -- r <- ct $ roundTrip logTestSettings testOptions "Case/FExpected.hs"
      r' <- ct $ mapM makeRelativeToCurrentDirectory r
      r' `shouldBe` ["Case/FExpected.hs"]
      diff <- compareFiles "./test/testdata/Case/FExpected.refactored.hs"
                           "./test/testdata/Case/FExpected.hs"
      diff `shouldBe` []

    -- ---------------------------------

    it "roundtrips CExpected" $ do
      r <- ct $ roundTrip defaultTestSettings testOptions "Case/CExpected.hs"
      -- r <- ct $ roundTrip logTestSettings testOptions "Case/CExpected.hs"
      r' <- ct $ mapM makeRelativeToCurrentDirectory r
      r' `shouldBe` ["Case/CExpected.hs"]
      diff <- compareFiles "./test/testdata/Case/CExpected.refactored.hs"
                           "./test/testdata/Case/CExpected.hs"
      diff `shouldBe` []

-- ---------------------------------------------------------------------
