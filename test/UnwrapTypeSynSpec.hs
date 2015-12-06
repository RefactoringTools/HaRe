module UnwrapTypeSynSpec (spec,main) where

import Test.Hspec
import Language.Haskell.Refact.Refactoring.UnwrapTypeSyn
import System.Directory
import TestUtils

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "doUnwrapTypeSyn" $ do
    it "Removes a simply synonym for String" $ do
      res <- ct $ unwrapTypeSyn defaultTestSettings testOptions "./UnwrapTypeSyn/UTS1.hs" (3,6) "Foo"
      res' <- ct $ mapM makeRelativeToCurrentDirectory res
      res' `shouldBe` ["UnwrapTypeSyn/UTS1.hs"]
      diff <- ct $ compareFiles "./UnwrapTypeSyn/UTS1.refactored.hs"
                           "./UnwrapTypeSyn/UTS1.hs.expected"
      diff `shouldBe` []
    it "Removes a more complicated tuple type" $ do
      res <- ct $ unwrapTypeSyn logTestSettings testOptions "./UnwrapTypeSyn/UTS2.hs" (3,6) "Foo"
      res' <- ct $ mapM makeRelativeToCurrentDirectory res
      res' `shouldBe` ["UnwrapTypeSyn/UTS2.hs"]
      diff <- ct $ compareFiles "./UnwrapTypeSyn/UTS2.refactored.hs"
              "./UnwrapTypeSyn/UTS2.hs.expected"
      diff `shouldBe` []
