module UtilsSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.LocUtils

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  
  describe "locToExp" $ do
    it "finds the largest leftmost expression contained in a given region #1" $ do
      let modInfo@((_, _, mod), toks) = parsedTestFile

      let exp = locToExp (4,7) (4,43) toks mod
      getLocatedStart exp `shouldBe` (4,9)
      getLocatedEnd   exp `shouldBe` (4,42)


    it "finds the largest leftmost expression contained in a given region #2" $ do
      let modInfo@((_, _, mod), toks) = parsedTestFile

      let exp = locToExp (4,7) (4,41) toks mod
      getLocatedStart exp `shouldBe` (4,12)
      getLocatedEnd   exp `shouldBe` (4,19)

  

  describe "sameOccurrence" $ do
    it "checks that a given syntax element is the same occurrence as another" $ do
      pending "write this test"

    it "gives the original list, if applied twice" $ property $
      \xs -> reverse (reverse xs) == (xs :: [Int])


-- ---------------------------------------------------------------------
-- Helper functions

parsedTestFile = unsafeParseSourceFile fileName 
  where
    fileName = "./test/testdata/B.hs"

