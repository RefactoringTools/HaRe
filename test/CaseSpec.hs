module CaseSpec (main, spec) where

import           Test.Hspec

import Language.Haskell.Refact.Refactoring.Case

import TestUtils

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do
  describe "ifToCase" $ do
    it "converts an if expression to a case expression BSimple" $ do
      r <- ct $ ifToCase defaultTestSettings testOptions "Case/BSimple.hs" (4,7) (4,43)
      -- r <- ct $ ifToCase logTestSettings testOptions  "Case/BSimple.hs" (4,7) (4,43)
      r `shouldBe` ["Case/BSimple.hs"]
      diff <- compareFiles "./test/testdata/Case/BSimple.refactored.hs"
                           "./test/testdata/Case/BSimple.hs.expected"
      diff `shouldBe` []

    -- ---------------------------------

    it "converts an if expression to a case expression Foo" $ do
      r <- ct $ ifToCase defaultTestSettings testOptions "Case/Foo.hs" (4,1) (9,1)
      -- r <- ct $ ifToCase logTestSettings testOptions  "Case/Foo.hs" (4,1) (9,1)
      r `shouldBe` ["Case/Foo.hs"]
      diff <- compareFiles "./test/testdata/Case/Foo.refactored.hs"
                           "./test/testdata/Case/Foo.hs.expected"
      diff `shouldBe` []

    -- ---------------------------------

    it "converts an if expression to a case expression B" $ do
      r <- ct $ ifToCase defaultTestSettings testOptions "Case/B.hs" (4,7) (4,43)
      -- r <- ct $ ifToCase logTestSettings testOptions  "Case/B.hs" (4,7) (4,43)
      r `shouldBe` ["Case/B.hs"]
      diff <- compareFiles "./test/testdata/Case/B.refactored.hs"
                           "./test/testdata/Case/B.hs.expected"
      diff `shouldBe` []

    -- ---------------------------------

    it "converts an if expression with comments to a case expression 1 C" $ do

      r <- ct $ ifToCase defaultTestSettings testOptions "Case/C.hs" (5,7) (10,1)
      -- ct $ ifToCase logTestSettings testOptions "Case/C.hs" (5,7) (10,1)
      r `shouldBe` ["Case/C.hs"]
      diff <- compareFiles "./test/testdata/Case/C.refactored.hs"
                           "./test/testdata/Case/C.hs.expected"
      diff `shouldBe` []

    -- ---------------------------------

    it "converts an if expression with comments to a case expression 2 D" $ do
      r <- ct $ ifToCase defaultTestSettings testOptions "Case/D.hs" (5,7) (12,1)
      -- ct $ ifToCase logTestSettings testOptions "Case/D.hs" (5,7) (12,1)
      r `shouldBe` ["Case/D.hs"]
      diff <- compareFiles "./test/testdata/Case/D.refactored.hs"
                           "./test/testdata/Case/D.hs.expected"
      diff `shouldBe` []

    -- ---------------------------------

    it "converts in complex sub level expression 2 E" $ do
      r <- ct $ ifToCase defaultTestSettings testOptions "Case/E.hs" (7,8) (13,20)
      -- ct $ ifToCase logTestSettings testOptions "Case/E.hs" (7,8) (13,20)
      r `shouldBe` ["Case/E.hs"]
      diff <- compareFiles "./test/testdata/Case/E.refactored.hs"
                           "./test/testdata/Case/E.hs.expected"
      diff `shouldBe` []

    -- ---------------------------------

    it "converts in complex sub level expression F" $ do
      r <- ct $ ifToCase defaultTestSettings testOptions "Case/F.hs" (4,7) (8,20)
      -- ct $ ifToCase logTestSettings testOptions "Case/F.hs" (4,7) (8,20)
      r `shouldBe` ["Case/F.hs"]
      diff <- compareFiles "./test/testdata/Case/F.refactored.hs"
                           "./test/testdata/Case/F.hs.expected"
      diff `shouldBe` []

   -- ---------------------------------

    it "complains if an if-then-else is not selected" $ do
      res <- catchException(ct $ ifToCase defaultTestSettings testOptions "Case/C.hs" (4,7) (9,1))
      -- ifToCase logTestSettings testOptions "./test/testdata/Case/C.hs" (4,7) (9,1)
      (show res) `shouldBe` "Just \"You haven't selected an if-then-else  expression!\""

-- ---------------------------------------------------------------------
-- Helper functions


