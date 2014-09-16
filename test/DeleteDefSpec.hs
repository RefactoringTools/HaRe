module DeleteDefSpec (main, spec) where


import Test.Hspec
import Language.Haskell.Refact.Refactoring.DeleteDef

import TestUtils

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do
  it "removes a small definition from the top level of a function" $ do
    res <- deleteDef defaultTestSettings testCradle "./test/testdata/DeleteDef/Dd1.hs"  (5,1)
    (show res) `shouldBe` "[\"./test/testdata/DeleteDef/Dd1.hs\"]"
    diff <- compareFiles "./test/testdata/DeleteDef/Dd1.refactored.hs"
                         "./test/testdata/DeleteDef/Dd1.hs.expected"
    diff `shouldBe` []
