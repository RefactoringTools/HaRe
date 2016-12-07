module DeleteDefSpec (main, spec) where


import Test.Hspec
import Language.Haskell.Refact.Refactoring.DeleteDef
import System.Directory
import TestUtils

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do
  describe "doDeleteDef" $ do
    it "removes a small definition from the top level of a function" $ do
      res <- ct $ deleteDef defaultTestSettings testOptions "./DeleteDef/Dd1.hs"  (5,1)
      res' <- ct $ mapM makeRelativeToCurrentDirectory res
      res' `shouldBe` ["DeleteDef/Dd1.hs"]
      diff <- ct $ compareFiles "./DeleteDef/Dd1.refactored.hs"
                                "./DeleteDef/Dd1.hs.expected"
      diff `shouldBe` []
    it "checks that a definition used in another module is not deleted" $ do
      res <- ct $ catchException (deleteDef defaultTestSettings testOptions "./DeleteDef/Dd2.hs" (4,1))
      (show res) `shouldBe` "Just \"The def to be deleted is still being used\""
    it "checks that a definition used in the same module is not deleted" $ do
      res <- ct $ catchException (deleteDef defaultTestSettings testOptions "./DeleteDef/Dd3.hs" (4,1))
      (show res) `shouldBe` "Just \"The def to be deleted is still being used\""
    it "checks that a recursive definition can be deleted" $ do
      res <- ct $ deleteDef defaultTestSettings testOptions "./DeleteDef/Dd1.hs" (21,1)
      res' <- ct $ mapM makeRelativeToCurrentDirectory res
      res' `shouldBe` ["DeleteDef/Dd1.hs"]
      diff <- ct $ compareFiles "./DeleteDef/Dd1.refactored.hs"
                           "./DeleteDef/Dd1.hs.expected2"
      diff `shouldBe` []
    it "checks possible bug found by tests in unwrap type synonym" $ do
      res <- ct $ deleteDef defaultTestSettings testOptions "./DeleteDef/UTS1.hs" (3,6)
      res' <- ct $ mapM makeRelativeToCurrentDirectory res
      res' `shouldBe` ["DeleteDef/UTS1.hs"]
      diff <- ct $ compareFiles "./DeleteDef/UTS1.hs.expected" "./DeleteDef/UTS1.refactored.hs"
      diff `shouldBe` []
