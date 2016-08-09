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
      res <- ct $ maybeToMonadPlus defaultTestSettings testOptions "./MaybeToMonadPlus/MMP1.hs" (4,1) "f" 1
      res' <- ct $ mapM makeRelativeToCurrentDirectory res
      res' `shouldBe` ["MaybeToMonadPlus/MMP1.hs"]
      diff <- ct $ compareFiles "./MaybeToMonadPlus/MMP1.refactored.hs"
                                "./MaybeToMonadPlus/MMP1.hs.expected"
      diff `shouldBe` []
    it "Another simple example where maybe constructor calls need to be replaced." $ do
      res <- ct $ maybeToMonadPlus logTestSettings testOptions "./MaybeToMonadPlus/MMP2.hs" (4,1) "f" 2
      res' <- ct $ mapM makeRelativeToCurrentDirectory res
      res' `shouldBe` ["MaybeToMonadPlus/MMP2.hs"]
      diff <- ct $ compareFiles "./MaybeToMonadPlus/MMP2.refactored.hs"
                                "./MaybeToMonadPlus/MMP2.hs.expected1"
      diff `shouldBe` []
    it "Function with nothing to nothing case but has mzero value and an extra parameter." $ do
      res <- ct $ maybeToMonadPlus logTestSettings testOptions "./MaybeToMonadPlus/MMP3.hs" (4,1) "f" 2
      res' <- ct $ mapM makeRelativeToCurrentDirectory res
      res' `shouldBe` ["MaybeToMonadPlus/MMP3.hs"]
      diff <- ct $ compareFiles "./MaybeToMonadPlus/MMP3.refactored.hs"
                                "./MaybeToMonadPlus/MMP3.hs.expected"
      diff `shouldBe` []
