module IntroduceTypeSynSpec (main, spec) where


import Test.Hspec
import Language.Haskell.Refact.Refactoring.IntroduceTypeSyn

import TestUtils

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do
  describe "doIntroduceTypeSyn" $ do
    it "Introduces a small synonym and modifies the type of a single function." $ do
      res <- introduceTypeSyn logTestSettings testCradle "./test/testdata/IntroduceTypeSyn/TS1.hs" (3,0)
      (show res) `shouldBe` "[\"./test/testdata/IntroduceTypeSyn/TS1.hs\"]"
      diff <- compareFiles "./test/testdata/IntroduceTypeSyn/TS1.refactored.hs"
                           "./test/testdata/IntroduceTypeSyn/TS1.hs.expected"
      diff `shouldBe` []
