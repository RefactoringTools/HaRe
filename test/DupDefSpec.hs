module DupDefSpec (main, spec) where

import           Test.Hspec

import Language.Haskell.Refact.Refactoring.DupDef
import System.Directory

import TestUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do

  describe "doDuplicateDef" $ do
    it "checks for a clash of the new name" $ do
     res <- catchException (ct $ duplicateDef defaultTestSettings testOptions "DupDef/Dd1.hs" "c" (4,1))
     -- res <- catchException (ct $ duplicateDef logTestSettings testOptions "DupDef/Dd1.hs" "c" (4,1))
     -- let res = "foo"
     (show res) `shouldBe` "Just \"The new name'c' will cause name clash/capture or ambiguity problem after duplicating, please select another name!\""

    -- ---------------------------------

    it "checks for no definition selected" $ do
     -- res <- catchException (ct $ doDuplicateDef ["DupDef/Dd1.hs","c","5","1"])
     res <- catchException (ct $ duplicateDef defaultTestSettings testOptions "DupDef/Dd1.hs" "c" (5,1))
     (show res) `shouldBe` "Just \"Invalid cursor position!\""

    -- ---------------------------------

    it "checks for invalid new name" $ do
     -- res <- catchException (ct $ doDuplicateDef ["DupDef/Dd1.hs","$c","5","1"])
     res <- catchException (ct $ duplicateDef defaultTestSettings testOptions "DupDef/Dd1.hs" "$c" (5,1))
     (show res) `shouldBe` "Just \"Invalid new function name:$c!\""

    -- ---------------------------------

    it "notifies if no definition selected" $ do
     res <- catchException (ct $ duplicateDef defaultTestSettings testOptions "DupDef/Dd1.hs" "ccc" (14,13))
     -- res <- catchException (ct $ duplicateDef logTestSettings testOptions "DupDef/Dd1.hs" "ccc" (14,13))
     (show res) `shouldBe` "Just \"The selected identifier is not a function/simple pattern name, or is not defined in this module \""

    -- ---------------------------------

    it "duplicates a definition at the top level" $ do
     res <- ct $ duplicateDef defaultTestSettings testOptions "DupDef/Dd1.hs" "tl2" (4,1)
     -- res <- ct $ duplicateDef logTestSettings testOptions "DupDef/Dd1.hs" "tl2" (4,1)
     res' <- ct $ mapM makeRelativeToCurrentDirectory res
     (show res') `shouldBe` "[\"DupDef/Dd1.hs\"]"
     diff <- compareFiles "./test/testdata/DupDef/Dd1.refactored.hs"
                          "./test/testdata/DupDef/Dd1.hs.expected"
     diff `shouldBe` []

    -- ---------------------------------

    it "duplicates a definition in a match" $ do
     res <- ct $ duplicateDef defaultTestSettings testOptions "DupDef/Dd1.hs" "nn" (23,5)
     -- res <- ct $ duplicateDef logTestSettings testOptions "DupDef/Dd1.hs" "nn" (23,5)
     res' <- ct $ mapM makeRelativeToCurrentDirectory res
     (show res') `shouldBe` "[\"DupDef/Dd1.hs\"]"
     diff <- compareFiles "./test/testdata/DupDef/Dd1.refactored.hs"
                          "./test/testdata/DupDef/Dd1.hs.expected.nn"
     diff `shouldBe` []

    -- ---------------------------------

    it "duplicates a definition in a pattern match" $ do
     res <- ct $ duplicateDef defaultTestSettings testOptions "DupDef/Dd1.hs" "gg" (17,5)
     -- res <- ct $ duplicateDef logTestSettings testOptions "DupDef/Dd1.hs" "gg" (17,5)
     res' <- ct $ mapM makeRelativeToCurrentDirectory res
     (show res') `shouldBe` "[\"DupDef/Dd1.hs\"]"
     diff <- compareFiles "./test/testdata/DupDef/Dd1.refactored.hs"
                          "./test/testdata/DupDef/Dd1.hs.expected.gg"
     diff `shouldBe` []

    -- ---------------------------------

    it "duplicates a definition in a let expression" $ do
     res <- ct $ duplicateDef defaultTestSettings testOptions "DupDef/Dd1.hs" "lll" (27,5)
     -- res <- ct $ duplicateDef logTestSettings testOptions "DupDef/Dd1.hs" "lll" (27,5)
     res' <- ct $ mapM makeRelativeToCurrentDirectory res
     (show res') `shouldBe` "[\"DupDef/Dd1.hs\"]"
     diff <- compareFiles "./test/testdata/DupDef/Dd1.refactored.hs"
                          "./test/testdata/DupDef/Dd1.hs.expected.ll"
     diff `shouldBe` []

    -- ---------------------------------

    it "duplicates a definition in a let statement" $ do
     res <- ct $ duplicateDef defaultTestSettings testOptions "DupDef/Dd1.hs" "sss" (31,7)
     -- res <- ct $ duplicateDef logTestSettings testOptions "DupDef/Dd1.hs" "sss" (31,7)
     res' <- ct $ mapM makeRelativeToCurrentDirectory res
     (show res') `shouldBe` "[\"DupDef/Dd1.hs\"]"
     diff <- compareFiles "./test/testdata/DupDef/Dd1.refactored.hs"
                          "./test/testdata/DupDef/Dd1.hs.expected.dd"
     diff `shouldBe` []

    -- ---------------------------------

    it "hides the new definition if it will cause problems in client mods" $ do
     res <- ct $ duplicateDef defaultTestSettings testOptions "DupDef/Dd1.hs" "mm" (21,1)
     -- res <- ct $ duplicateDef logTestSettings testOptions "DupDef/Dd1.hs" "mm" (21,1)
     r' <- ct $ mapM makeRelativeToCurrentDirectory res
     (show r') `shouldBe` "[\"DupDef/Dd1.hs\",\"DupDef/Dd2.hs\",\"DupDef/Dd3.hs\"]"
     diff <- compareFiles "./test/testdata/DupDef/Dd1.refactored.hs"
                          "./test/testdata/DupDef/Dd1.hs.expected.mm"
     diff `shouldBe` []
     diff2 <- compareFiles "./test/testdata/DupDef/Dd2.refactored.hs"
                           "./test/testdata/DupDef/Dd2.hs.expected"
     diff2 `shouldBe` []
     diff3 <- compareFiles "./test/testdata/DupDef/Dd3.refactored.hs"
                           "./test/testdata/DupDef/Dd3.hs.expected"
     diff3 `shouldBe` []

    -- ---------------------------------

    it "duplicates a definition and formats properly" $ do
     res <- ct $ duplicateDef defaultTestSettings testOptions "Case/B.hs" "joe" (9,1)
     -- res <- ct $ duplicateDef logTestSettings testOptions "Case/B.hs" "joe" (9,1)
     res' <- ct $ mapM makeRelativeToCurrentDirectory res
     (show res') `shouldBe` "[\"Case/B.hs\"]"
     diff <- compareFiles "./test/testdata/Case/B.refactored.hs"
                          "./test/testdata/Case/B.hs.expected.dd"
     diff `shouldBe` []

-- ---------------------------------------------------------------------
-- Helper functions

