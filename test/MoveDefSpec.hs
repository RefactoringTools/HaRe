module MoveDefSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import qualified GHC      as GHC
import qualified GhcMonad as GHC
import qualified RdrName  as GHC
import qualified SrcLoc   as GHC

import Exception
import Control.Monad.State
import Language.Haskell.Refact.MoveDef
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.LocUtils

import TestUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = hspec spec

spec :: Spec
spec = do

  describe "doLiftToTopLevel" $ do
    it "Cannot lift a top level declaration" $ do
     res <- catchException (doLiftToTopLevel ["./test/testdata/MoveDef/Md1.hs","4","1"])
     (show res) `shouldBe` "Just \"\\nThe identifier is not a local function/pattern name!\""

    it "checks for name clashes" $ do
     res <- catchException (doLiftToTopLevel ["./test/testdata/MoveDef/Md1.hs","17","5"])
     (show res) `shouldBe` "Just \"The identifier(s):[ff] will cause name clash/capture or ambiguity occurrence problem after lifting, please do renaming first!\""

    {-
    it "checks for invalid new name" $ do
     res <- catchException (doDuplicateDef ["./test/testdata/DupDef/Dd1.hs","$c","5","1"])
     (show res) `shouldBe` "Just \"Invalid new function name:$c!\""

    it "notifies if no definition selected" $ do
     res <- catchException (doDuplicateDef ["./test/testdata/DupDef/Dd1.hs","ccc","14","13"])
     (show res) `shouldBe` "Just \"The selected identifier is not a function/simple pattern name, or is not defined in this module \""
    -}

    it "lifts a definition to the top level" $ do
     doLiftToTopLevel ["./test/testdata/MoveDef/Md1.hs","24","5"]
     diff <- compareFiles "./test/testdata/MoveDef/Md1.hs.refactored"
                          "./test/testdata/MoveDef/Md1.hs.expected"
     diff `shouldBe` []


  -- -------------------------------------------------------------------

  describe "doDemote" $ do
    {-
    it "Cannot lift a top level declaration" $ do
     res <- catchException (doLiftToTopLevel ["./test/testdata/MoveDef/Md1.hs","4","1"])
     (show res) `shouldBe` "Just \"\\nThe identifier is not a local function/pattern name!\""

    it "checks for name clashes" $ do
     res <- catchException (doLiftToTopLevel ["./test/testdata/MoveDef/Md1.hs","17","5"])
     (show res) `shouldBe` "Just \"The identifier(s):[ff] will cause name clash/capture or ambiguity occurrence problem after lifting, please do renaming first!\""
    -}

    it "notifies if no definition selected" $ do
     res <- catchException (doDemote ["./test/testdata/MoveDef/Md1.hs","14","13"])
     (show res) `shouldBe` "Just \"\\nInvalid cursor position!\""


    it "demotes a definition from the top level" $ do
     doDemote ["./test/testdata/MoveDef/Md1.hs","4","1"]
     diff <- compareFiles "./test/testdata/MoveDef/Md1.hs.refactored"
                          "./test/testdata/MoveDef/Md1.hs.expected"
     diff `shouldBe` []


-- ---------------------------------------------------------------------
-- Helper functions

