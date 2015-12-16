module MaybeToMonadPlusSpec (main, spec) where

import Test.Hspec
import Language.Haskell.Refact.Refactoring.MaybeToMonadPlus
import System.Directory
import TestUtils

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do
  describe "doMaybeToMonadPlus" $ do
    it "Simple function that uses pattern matching to be collapsed into a bind." $ do
      res <- ct $ maybeToMonadPlus defaultTestSettings testOptions "./MaybeToMonadPlus/MMP1.hs" (4,1) "f"
      res' <- ct $ mapM makeRelativeToCurrentDirectory res
      res' `shouldBe` ["MaybeToMonadPlus/MMP1.hs"]
      diff <- ct $ compareFiles "./MaybeToMonadPlus/MMP1.refactored.hs"
                                "./MaybeToMonadPlus/MMP1.hs.expected"
      diff `shouldBe` []
