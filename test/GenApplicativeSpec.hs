module GenApplicativeSpec (main, spec) where

import Test.Hspec
import Language.Haskell.Refact.Refactoring.GenApplicative
import System.Directory
import TestUtils

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do
  describe "doGenApplicative" $ do
    it "Simple parser that can be easily rewritten in the applicative style." $ do
      res <- ct $ genApplicative defaultTestSettings testOptions "./GenApplicative/GA1.hs" "parseStr" (4,1)
      res' <- ct $ mapM makeRelativeToCurrentDirectory res
      res' `shouldBe` ["GenApplicative/GA1.hs"]
      diff <- ct $ compareFiles "./GenApplicative/GA1.refactored.hs"
                                "./GenApplicative/GA1.hs.expected"
      diff `shouldBe` []
    it "A slightly more complicated parser" $ do
      res <- ct $ genApplicative defaultTestSettings testOptions "./GenApplicative/GA2.hs" "objEntry" (7,1)
      res' <- ct $ mapM makeRelativeToCurrentDirectory res
      res' `shouldBe` ["GenApplicative/GA2.hs"]
      diff <- ct $ compareFiles "./GenApplicative/GA2.refactored.hs"
                                "./GenApplicative/GA2.hs.expected"
      diff `shouldBe` []
    it "A more complicated pure expression needs to be formed." $ do
      res <- ct $ genApplicative defaultTestSettings testOptions "./GenApplicative/GA3.hs" "zipperM" (4,1)
      res' <- ct $ mapM makeRelativeToCurrentDirectory res
      res' `shouldBe` ["GenApplicative/GA3.hs"]
      diff <- ct $ compareFiles "./GenApplicative/GA3.refactored.hs"
                                "./GenApplicative/GA3.hs.expected"
      diff `shouldBe` []
    it "This function should not pass the precondition because a bound variable is used in a rhs." $ do
      res <- catchException (ct $ genApplicative defaultTestSettings testOptions "./GenApplicative/GA4.hs" "failBoundPrecon" (4,1))
      (show res) `shouldBe` "Just \"GenApplicative Precondition: The function given uses a bound variable in a RHS expression.\""
    it "This function should not pass the precondition because variables are bound out of order" $ do
      res <- catchException (ct $ genApplicative defaultTestSettings testOptions "./GenApplicative/GA4.hs" "failOrderPrecon" (10,1))
      (show res) `shouldBe` "Just \"GenApplicative Precondition: Variables are not bound in the order that they appear in the return statement.\""
    it "Debugging a function from html-tokenizer" $ do
      res <- ct $ genApplicative logTestSettings testOptions "./GenApplicative/HTMLTokenizer.hs" "openingTag" (88,1)
      res' <- ct $ mapM makeRelativeToCurrentDirectory res
      res' `shouldBe` ["GenApplicative/HTMLTokenizer.hs"]
      diff <- ct $ compareFiles "./GenApplicative/HTMLTokenizer.refactored.hs"
                                "./GenApplicative/HTMLTokenizer.hs.expected"
      diff `shouldBe` []

                            
