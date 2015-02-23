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

    it "roundtrips Zipper.hs" $ do
      r <- cdAndDo "/home/alanz/tmp/hackage/syz-0.2.0.0/" $ roundTrip defaultTestSettings testOptions "./Data/Generics/Zipper.hs"
      r `shouldBe` ["/home/alanz/tmp/hackage/syz-0.2.0.0/Data/Generics/Zipper.hs"]
      diff <- compareFiles "/home/alanz/tmp/hackage/syz-0.2.0.0/Data/Generics/Zipper.refactored.hs"
                           "/home/alanz/tmp/hackage/syz-0.2.0.0/Data/Generics/Zipper.hs"
      diff `shouldBe` []

    -- ---------------------------------
-- ---------------------------------------------------------------------
-- Helper functions


