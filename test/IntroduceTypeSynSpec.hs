module IntroduceTypeSynSpec (spec,main) where


import Test.Hspec
import Language.Haskell.Refact.Refactoring.IntroduceTypeSyn
import System.Directory
import TestUtils

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do
  describe "doIntroduceTypeSyn" $ do
    it "Introduces a small synonym and modifies the type of a single function." $ do
      res <- ct $ introduceTypeSyn logTestSettings testOptions "./IntroduceTypeSyn/TS1.hs" (3,0) "Name" "String"
      res' <- ct $ mapM makeRelativeToCurrentDirectory res
      res' `shouldBe` ["IntroduceTypeSyn/TS1.hs"]
      diff <- ct $ compareFiles "./IntroduceTypeSyn/TS1.refactored.hs"
                           "./IntroduceTypeSyn/TS1.hs.expected"
      diff `shouldBe` []
      
    it "Intruduces the synonym for a tuple and changes the type of two functions" $ do
      res <- ct$ introduceTypeSyn defaultTestSettings testOptions "./IntroduceTypeSyn/TS2.hs" (3,0) "Foo" "(String,Int)"
      res' <- ct $ mapM makeRelativeToCurrentDirectory res
      res' `shouldBe` ["IntroduceTypeSyn/TS2.hs"]
      diff <- ct $ compareFiles "./IntroduceTypeSyn/TS2.refactored.hs"
                           "./IntroduceTypeSyn/TS2.hs.expected"
      diff `shouldBe` []
