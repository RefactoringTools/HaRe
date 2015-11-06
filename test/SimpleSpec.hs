module SimpleSpec (main, spec) where

import           Test.Hspec

import Language.Haskell.Refact.Refactoring.Simple

import TestUtils

import System.Directory

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do
  describe "removeBrackets" $ do
    it "Removes redundent brackets around a simple expression A.hs" $ do
      r <- ct $ removeBracket defaultTestSettings testOptions "Simple/A.hs" (4,7) (4,11)
      -- r <- ct $ removeBracket logTestSettings testOptions "Simple/A.hs" (4,7) (4,11)
      r' <- ct $ mapM makeRelativeToCurrentDirectory r
      r' `shouldBe` ["Simple/A.hs"]
      diff <- compareFiles "./test/testdata/Simple/A.refactored.hs"
                           "./test/testdata/Simple/A.hs.expected"
      diff `shouldBe` []
