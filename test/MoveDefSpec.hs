module MoveDefSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import qualified GHC      as GHC
import qualified GhcMonad as GHC
import qualified SrcLoc   as GHC

import Control.Monad.State
import Exception
import Language.Haskell.Refact.MoveDef
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import System.Directory

import TestUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  -- setLogger
  hspec spec

spec :: Spec
spec = do

  -- -------------------------------------------------------------------

  describe "doLiftToTopLevel" $ do
    it "Cannot lift a top level declaration" $ do
     res <- catchException (doLiftToTopLevel ["./test/testdata/MoveDef/Md1.hs","4","1"])
     (show res) `shouldBe` "Just \"\\nThe identifier is not a local function/pattern name!\""

    it "checks for name clashes" $ do
     res <- catchException (doLiftToTopLevel ["./test/testdata/MoveDef/Md1.hs","17","5"])
     (show res) `shouldBe` "Just \"The identifier(s): (ff, test/testdata/MoveDef/Md1.hs:17:5) will cause name clash/capture or ambiguity occurrence problem after lifting, please do renaming first!\""

    {-
    it "checks for invalid new name" $ do
     res <- catchException (doDuplicateDef ["./test/testdata/DupDef/Dd1.hs","$c","5","1"])
     (show res) `shouldBe` "Just \"Invalid new function name:$c!\""

    it "notifies if no definition selected" $ do
     res <- catchException (doDuplicateDef ["./test/testdata/DupDef/Dd1.hs","ccc","14","13"])
     (show res) `shouldBe` "Just \"The selected identifier is not a function/simple pattern name, or is not defined in this module \""
    -}

    -- ---------------------------------

    it "lifts a definition to the top level" $ do
     doLiftToTopLevel ["./test/testdata/MoveDef/Md1.hs","24","5"]
     -- liftToTopLevel logTestSettings Nothing "./test/testdata/MoveDef/Md1.hs" (24,5)
     diff <- compareFiles "./test/testdata/MoveDef/Md1.hs.expected"
                          "./test/testdata/MoveDef/Md1.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "liftToTopLevel D1 C1 A1 8 6" $ do
     liftToTopLevel defaultTestSettings (Just "./test/testdata/LiftToToplevel/A1.hs") "./test/testdata/LiftToToplevel/D1.hs" (8,6)
     -- liftToTopLevel logTestSettings     (Just "./test/testdata/LiftToToplevel/A1.hs") "./test/testdata/LiftToToplevel/D1.hs" (8,6)
     diff <- compareFiles "./test/testdata/LiftToToplevel/D1.hs.expected"
                          "./test/testdata/LiftToToplevel/D1.hs.refactored"
     diff `shouldBe` []

     diff2 <- compareFiles "./test/testdata/LiftToToplevel/C1.hs.expected"
                          "./test/testdata/LiftToToplevel/C1.hs.refactored"
     diff2 `shouldBe` []

     a1Refactored <- doesFileExist "./test/testdata/LiftToToplevel/A1.hs.refactored"
     a1Refactored `shouldBe` False


    -- ---------------------------------

    it "liftToTopLevel D2 C2 A2 8 6" $ do
     liftToTopLevel defaultTestSettings (Just "./test/testdata/LiftToToplevel/A2.hs") "./test/testdata/LiftToToplevel/D2.hs" (8,6)
     -- liftToTopLevel logTestSettings     (Just "./test/testdata/LiftToToplevel/A2.hs") "./test/testdata/LiftToToplevel/D2.hs" (8,6)
     diff <- compareFiles "./test/testdata/LiftToToplevel/D2.hs.expected"
                          "./test/testdata/LiftToToplevel/D2.hs.refactored"
     diff `shouldBe` []

     diff2 <- compareFiles "./test/testdata/LiftToToplevel/C2.hs.expected"
                          "./test/testdata/LiftToToplevel/C2.hs.refactored"
     diff2 `shouldBe` []

     a1Refactored <- doesFileExist "./test/testdata/LiftToToplevel/A2.hs.refactored"
     a1Refactored `shouldBe` False


    -- ---------------------------------

    it "liftToTopLevel D3 C3 A3 8 6" $ do
     liftToTopLevel defaultTestSettings (Just "./test/testdata/LiftToToplevel/A3.hs") "./test/testdata/LiftToToplevel/D3.hs" (8,6)
     -- liftToTopLevel logTestSettings     (Just "./test/testdata/LiftToToplevel/A3.hs") "./test/testdata/LiftToToplevel/D3.hs" (8,6)
     diff <- compareFiles "./test/testdata/LiftToToplevel/D3.hs.expected"
                          "./test/testdata/LiftToToplevel/D3.hs.refactored"
     diff `shouldBe` []

     c3Refactored <- doesFileExist "./test/testdata/LiftToToplevel/C3.hs.refactored"
     c3Refactored `shouldBe` False

     a3Refactored <- doesFileExist "./test/testdata/LiftToToplevel/A3.hs.refactored"
     a3Refactored `shouldBe` False


    -- ---------------------------------

    it "liftToTopLevel WhereIn1 12 18" $ do
     liftToTopLevel defaultTestSettings Nothing "./test/testdata/LiftToToplevel/WhereIn1.hs" (12,18)
     -- liftToTopLevel logTestSettings     Nothing "./test/testdata/LiftToToplevel/WhereIn1.hs" (12,18)
     diff <- compareFiles "./test/testdata/LiftToToplevel/WhereIn1.hs.expected"
                          "./test/testdata/LiftToToplevel/WhereIn1.hs.refactored"
     diff `shouldBe` []


    -- ---------------------------------

    it "liftToTopLevel WhereIn6 13 29" $ do
     liftToTopLevel defaultTestSettings Nothing "./test/testdata/LiftToToplevel/WhereIn6.hs" (13,29)
     -- liftToTopLevel logTestSettings     Nothing "./test/testdata/LiftToToplevel/WhereIn6.hs" (13,29)
     diff <- compareFiles "./test/testdata/LiftToToplevel/WhereIn6.hs.expected"
                          "./test/testdata/LiftToToplevel/WhereIn6.hs.refactored"
     diff `shouldBe` []


    -- ---------------------------------

    it "liftToTopLevel WhereIn7 12 14" $ do
     liftToTopLevel defaultTestSettings Nothing "./test/testdata/LiftToToplevel/WhereIn7.hs" (12,14)
     -- liftToTopLevel logTestSettings     Nothing "./test/testdata/LiftToToplevel/WhereIn7.hs" (12,14)
     diff <- compareFiles "./test/testdata/LiftToToplevel/WhereIn7.hs.expected"
                          "./test/testdata/LiftToToplevel/WhereIn7.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "liftToTopLevel LetIn1 11 22" $ do
     liftToTopLevel defaultTestSettings Nothing "./test/testdata/LiftToToplevel/LetIn1.hs" (11,22)
     -- liftToTopLevel logTestSettings     Nothing "./test/testdata/LiftToToplevel/LetIn1.hs" (11,22)
     diff <- compareFiles "./test/testdata/LiftToToplevel/LetIn1.hs.expected"
                          "./test/testdata/LiftToToplevel/LetIn1.hs.refactored"
     diff `shouldBe` []


    -- ---------------------------------

    it "liftToTopLevel LetIn2 10 22" $ do
     liftToTopLevel defaultTestSettings Nothing "./test/testdata/LiftToToplevel/LetIn2.hs" (10,22)
     -- liftToTopLevel logTestSettings     Nothing "./test/testdata/LiftToToplevel/LetIn2.hs" (10,22)
     diff <- compareFiles "./test/testdata/LiftToToplevel/LetIn2.hs.expected"
                          "./test/testdata/LiftToToplevel/LetIn2.hs.refactored"
     diff `shouldBe` []


    -- ---------------------------------

    it "liftToTopLevel LetIn3 10 27" $ do
     liftToTopLevel defaultTestSettings Nothing "./test/testdata/LiftToToplevel/LetIn3.hs" (10,27)
     -- liftToTopLevel logTestSettings     Nothing "./test/testdata/LiftToToplevel/LetIn3.hs" (10,27)
     diff <- compareFiles "./test/testdata/LiftToToplevel/LetIn3.hs.expected"
                          "./test/testdata/LiftToToplevel/LetIn3.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "liftToTopLevel PatBindIn1 18 7" $ do
     liftToTopLevel defaultTestSettings Nothing "./test/testdata/LiftToToplevel/PatBindIn1.hs" (18,7)
     -- liftToTopLevel logTestSettings     Nothing "./test/testdata/LiftToToplevel/PatBindIn1.hs" (18,7)
     diff <- compareFiles "./test/testdata/LiftToToplevel/PatBindIn1.hs.expected"
                          "./test/testdata/LiftToToplevel/PatBindIn1.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "liftToTopLevel PatBindIn3 11 `15" $ do
      pending

    -- ---------------------------------

    it "liftToTopLevel CaseIn1 10 28" $ do
      pending

    -- ---------------------------------

    it "liftToTopLevel PatBindIn2 17 7 fails" $ do
      pending

    -- ---------------------------------

    it "liftToTopLevel WhereIn2 11 18 fails" $ do
      pending


{- original tests
positive=[(["D1.hs","C1.hs","A1.hs"],["8","6"]),
          (["D2.hs","C2.hs","A2.hs"],["8","6"]),
          (["D3.hs","C3.hs","A3.hs"],["8","6"]),
          (["WhereIn1.hs"],["12","18"]),
          (["WhereIn6.hs"],["13","29"]),
          (["WhereIn7.hs"],["12","14"]),
          (["LetIn1.hs"],["11","22"]),
          (["LetIn2.hs"],["10","22"]),
          (["LetIn3.hs"],["10","27"]),
          (["PatBindIn1.hs"],["18","7"]),
          (["PatBindIn3.hs"],["11","15"]),
          (["CaseIn1.hs"],["10","28"])],
negative=[(["PatBindIn2.hs"],["17","7"]),
          (["WhereIn2.hs"],["11","18"])
         ]

-}

  -- -------------------------------------------------------------------

  describe "doDemote" $ do

    it "notifies if no definition selected" $ do
     res <- catchException (doDemote ["./test/testdata/MoveDef/Md1.hs","14","13"])
     (show res) `shouldBe` "Just \"\\nInvalid cursor position!\""

    it "will not demote if nowhere to go" $ do
     res <- catchException (doDemote ["./test/testdata/MoveDef/Md1.hs","8","1"])
     (show res) `shouldBe` "Just \"\\n Nowhere to demote this function!\\n\""

    it "demotes a definition from the top level 1" $ do
     doDemote ["./test/testdata/MoveDef/Demote.hs","7","1"]
     -- demote logTestSettings Nothing "./test/testdata/MoveDef/Demote.hs" (7,1)
     diff <- compareFiles "./test/testdata/MoveDef/Demote.hs.refactored"
                          "./test/testdata/MoveDef/Demote.hs.expected"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

    it "demotes a definition from the top level D1" $ do
     doDemote ["./test/testdata/Demote/D1.hs","9","1"]
     diff <- compareFiles "./test/testdata/Demote/D1.hs.refactored"
                          "./test/testdata/Demote/D1.hs.expected"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

    it "demotes WhereIn1 12 1" $ do
     doDemote ["./test/testdata/Demote/WhereIn1.hs","12","1"]
     diff <- compareFiles "./test/testdata/Demote/WhereIn1.hs.refactored"
                          "./test/testdata/Demote/WhereIn1.hs.expected"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

    it "demotes WhereIn3 14 1" $ do
     doDemote ["./test/testdata/Demote/WhereIn3.hs","14","1"]
     diff <- compareFiles "./test/testdata/Demote/WhereIn3.hs.refactored"
                          "./test/testdata/Demote/WhereIn3.hs.expected"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

    it "demotes WhereIn4 14 1" $ do
     doDemote ["./test/testdata/Demote/WhereIn4.hs","14","1"]
     diff <- compareFiles "./test/testdata/Demote/WhereIn4.hs.refactored"
                          "./test/testdata/Demote/WhereIn4.hs.expected"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

    it "demotes WhereIn5 14 1" $ do
     doDemote ["./test/testdata/Demote/WhereIn5.hs","14","1"]
     diff <- compareFiles "./test/testdata/Demote/WhereIn5.hs.refactored"
                          "./test/testdata/Demote/WhereIn5.hs.expected"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

    it "demotes WhereIn6 13 1" $ do
     doDemote ["./test/testdata/Demote/WhereIn6.hs","13","1"]
     diff <- compareFiles "./test/testdata/Demote/WhereIn6.hs.refactored"
                          "./test/testdata/Demote/WhereIn6.hs.expected"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

    it "demotes WhereIn7 13 1" $ do
     doDemote ["./test/testdata/Demote/WhereIn7.hs","13","1"]
     diff <- compareFiles "./test/testdata/Demote/WhereIn7.hs.refactored"
                          "./test/testdata/Demote/WhereIn7.hs.expected"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

    it "demotes CaseIn1 16 1" $ do
     doDemote ["./test/testdata/Demote/CaseIn1.hs","16","1"]
     diff <- compareFiles "./test/testdata/Demote/CaseIn1.hs.refactored"
                          "./test/testdata/Demote/CaseIn1.hs.expected"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

    it "demotes LetIn1 12 22" $ do
     doDemote ["./test/testdata/Demote/LetIn1.hs","12","22"]
     diff <- compareFiles "./test/testdata/Demote/LetIn1.hs.refactored"
                          "./test/testdata/Demote/LetIn1.hs.expected"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

    it "demotes PatBindIn1 19 1" $ do
       -- pending -- "todo"
     doDemote ["./test/testdata/Demote/PatBindIn1.hs","19","1"]
     diff <- compareFiles "./test/testdata/Demote/PatBindIn1.hs.refactored"
                          "./test/testdata/Demote/PatBindIn1.hs.expected"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

    it "demotes D2 5 1 when not imported by other module" $ do
     doDemote ["./test/testdata/Demote/D2.hs","5","1"]
     -- demote logTestSettings Nothing "./test/testdata/Demote/D2.hs" (5,1)
     diff <- compareFiles "./test/testdata/Demote/D2.hs.refactored"
                          "./test/testdata/Demote/D2.hs.expected"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

    it "fails WhereIn2 14 1" $ do
     res <- catchException (doDemote ["./test/testdata/Demote/WhereIn2.hs","14","1"])
     -- demote (Just logSettings) Nothing "./test/testdata/Demote/WhereIn2.hs" (14,1)
     (show res) `shouldBe` "Just \"\\n Nowhere to demote this function!\\n\""

    -- -----------------------------------------------------------------

    it "fails LetIn2 11 22" $ do
     res <- catchException (doDemote ["./test/testdata/Demote/LetIn2.hs","11","22"])
     (show res) `shouldBe` "Just \"This function can not be demoted as it is used in current level!\\n\""

    -- -----------------------------------------------------------------

    it "fails PatBindIn4 18 1" $ do
     res <- catchException (doDemote ["./test/testdata/Demote/PatBindIn4.hs","18","1"])
     -- (show res) `shouldBe` "Just \"\\n Nowhere to demote this function!\\n\""
     (show res) `shouldBe` "Just \"\\nThis function/pattern binding is used by more than one friend bindings\\n\""

    -- -----------------------------------------------------------------

    it "fails WhereIn8 16 1" $ do
     res <- catchException (doDemote ["./test/testdata/Demote/WhereIn8.hs","16","1"])
     (show res) `shouldBe` "Just \"\\n Nowhere to demote this function!\\n\""

    -- -----------------------------------------------------------------

    it "fails D2 5 1" $ do
     res <- catchException (demote defaultTestSettings (Just "./test/testdata/Demote/A2.hs") "./test/testdata/Demote/D2.hs" (5,1))
     -- res <- catchException (demote logTestSettings (Just "./test/testdata/Demote/A2.hs") "./test/testdata/Demote/D2.hs" (5,1))
     (show res) `shouldBe` "Just \"This definition can not be demoted, as it is used in the client module 'main:Demote.A2'!\""

    -- -----------------------------------------------------------------

    it "fails for re-export in client module"  $ do
      pending

    -- -----------------------------------------------------------------

    it "fails D3 5 1" $ do
     res <- catchException (doDemote ["./test/testdata/Demote/D3.hs","5","1"])
     (show res) `shouldBe` "Just \"This definition can not be demoted, as it is explicitly exported by the current module!\""



{- Original test cases. These files are now in testdata/Demote

-- TODO: reinstate these tests

TestCases{refactorCmd="demote",
positive=[(["D1.hs","C1.hs","A1.hs"],["9","1"]),
          (["WhereIn1.hs"],["12","1"]),
          (["WhereIn3.hs"],["14","1"]),
          (["WhereIn4.hs"],["14","1"]),
          (["WhereIn5.hs"],["14","1"]),
          (["WhereIn6.hs"],["13","1"]),
          (["WhereIn7.hs"],["13","1"]),
          (["CaseIn1.hs"],["16","1"]),
          (["LetIn1.hs"],["12","22"]),
          (["PatBindIn1.hs"],["19","1"])],
negative=[(["WhereIn2.hs"],["14","1"]),
          (["LetIn2.hs"],["11","22"]),
          (["PatBindIn4.hs"],["18","1"]),
          (["WhereIn8.hs"],["16","1"]),
          (["D2.hs","C2.hs","A2.hs"],["5","1"]),
          (["D3.hs"],["5","1"])]
}
-}

-- ---------------------------------------------------------------------
-- Helper functions

