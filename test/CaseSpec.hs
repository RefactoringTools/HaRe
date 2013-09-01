module CaseSpec (main, spec) where

import           Test.Hspec



import Language.Haskell.Refact.Case

import TestUtils

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do
  describe "ifToCase" $ do
    it "converts an if expression to a case expression" $ do
      -- doIfToCase ["./test/testdata/Case/B.hs","4","7","4","43"]
      ifToCase defaultTestSettings testCradle "./test/testdata/Case/B.hs" (4,7) (4,43)
      -- ifToCase logTestSettings Nothing "./test/testdata/Case/B.hs" (4,7) (4,43)
      diff <- compareFiles "./test/testdata/Case/B.hs.refactored"
                           "./test/testdata/Case/B.hs.expected"
      diff `shouldBe` []

  -- -------------------------------------------------------------------

  describe "second thing" $ do
    it "does something good" $ do
      pending -- "real soon now"


-- ---------------------------------------------------------------------
-- Helper functions


