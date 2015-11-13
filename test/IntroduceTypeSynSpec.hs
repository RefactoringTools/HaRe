module IntroduceTypeSynSpec (spec,main) where


import Test.Hspec
import Language.Haskell.Refact.Refactoring.IntroduceTypeSyn

import TestUtils

main :: IO ()
main = return ()

spec = undefined
{-main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do
  describe "doIntroduceTypeSyn" $ do
    it "Introduces a small synonym and modifies the type of a single function." $ do
      res <- introduceTypeSyn logTestSettings testCradle "./test/testdata/IntroduceTypeSyn/TS1.hs" (3,0) "Name" "String"
      (show res) `shouldBe` "[\"./test/testdata/IntroduceTypeSyn/TS1.hs\"]"
      diff <- compareFiles "./test/testdata/IntroduceTypeSyn/TS1.refactored.hs"
                           "./test/testdata/IntroduceTypeSyn/TS1.hs.expected"
      diff `shouldBe` []
      
    it "Intruduces the synonym for a tuple and changes the type of two functions" $ do
      res <- introduceTypeSyn defaultTestSettings testCradle "./test/testdata/IntroduceTypeSyn/TS2.hs" (3,0) "Foo" "(String,Int)"
      (show res) `shouldBe` "[\"./test/testdata/IntroduceTypeSyn/TS2.hs\"]"
      diff <- compareFiles "./test/testdata/IntroduceTypeSyn/TS2.refactored.hs"
                           "./test/testdata/IntroduceTypeSyn/TS2.hs.expected"
      diff `shouldBe` []
-}
