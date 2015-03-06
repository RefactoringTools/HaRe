module RoundTripSpec (main, spec) where

import           Test.Hspec

import Language.Haskell.Refact.Refactoring.RoundTrip

import TestUtils

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do
  describe "roundtrip" $ do
    it "roundtrips B" $ do
      r <- ct $ roundTrip defaultTestSettings testOptions "Case/BSimpleExpected.hs"
      -- r <- ct $ roundTrip logTestSettings testOptions "Case/BSimpleExpected.hs"
      r `shouldBe` ["Case/BSimpleExpected.hs"]
      diff <- compareFiles "./test/testdata/Case/BSimpleExpected.refactored.hs"
                           "./test/testdata/Case/BSimpleExpected.hs"
      diff `shouldBe` []

    -- ---------------------------------

    it "roundtrips FooExpected" $ do
      r <- ct $ roundTrip defaultTestSettings testOptions "Case/FooExpected.hs"
      -- r <- ct $ roundTrip logTestSettings testOptions "Case/FooExpected.hs"
      r `shouldBe` ["Case/FooExpected.hs"]
      diff <- compareFiles "./test/testdata/Case/FooExpected.refactored.hs"
                           "./test/testdata/Case/FooExpected.hs"
      diff `shouldBe` []

    -- ---------------------------------

    it "roundtrips FExpected" $ do
      r <- ct $ roundTrip defaultTestSettings testOptions "Case/FExpected.hs"
      -- r <- ct $ roundTrip logTestSettings testOptions "Case/FExpected.hs"
      r `shouldBe` ["Case/FExpected.hs"]
      diff <- compareFiles "./test/testdata/Case/FExpected.refactored.hs"
                           "./test/testdata/Case/FExpected.hs"
      diff `shouldBe` []

    -- ---------------------------------

    it "roundtrips Zipper.hs" $ do
      r <- cdAndDo "/home/alanz/tmp/hackage/syz-0.2.0.0/" $ roundTrip defaultTestSettings testOptions "./Data/Generics/Zipper.hs"
      r `shouldBe` ["/home/alanz/tmp/hackage/syz-0.2.0.0/Data/Generics/Zipper.hs"]
      diff <- compareFiles "/home/alanz/tmp/hackage/syz-0.2.0.0/Data/Generics/Zipper.refactored.hs"
                           "/home/alanz/tmp/hackage/syz-0.2.0.0/Data/Generics/Zipper.hs"
      diff `shouldBe` []

    -- ---------------------------------
-- ---------------------------------------------------------------------
-- Helper functions


