module AddRmParamSpec (main, spec) where

import           Test.Hspec

import Language.Haskell.Refact.Refactoring.AddRmParam

import TestUtils

import System.Directory

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do

  describe "Adding" $ do
    it "addOneParameter in D3 A3" $ do
      r <- ct $ addOneParameter defaultTestSettings testOptions "./AddOneParameter/D3.hs" "y" (7,1)
      -- r <- ct $ addOneParameter logTestSettings testOptions "./AddOneParameter/D3.hs" "y" (7,1)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "AddOneParameter/D3.hs"
                    , "AddOneParameter/A3.hs"
                    ]

      diffD <- ct $ compareFiles "./AddOneParameter/D3.expected.hs"
                                 "./AddOneParameter/D3.refactored.hs"
      diffD `shouldBe` []

      diffA <- ct $ compareFiles "./AddOneParameter/A3.expected.hs"
                                 "./AddOneParameter/A3.refactored.hs"
      diffA `shouldBe` []

    -- -------------------

    it "addOneParameter in D1 B1 C1 A1" $ do
      r <- ct $ addOneParameter defaultTestSettings testOptions "./AddOneParameter/D1.hs" "f" (10,1)
      -- r <- ct $ addOneParameter logTestSettings testOptions "./AddOneParameter/D1.hs" "f" (10,1)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "AddOneParameter/D1.hs"
                    , "AddOneParameter/A1.hs"
                    , "AddOneParameter/C1.hs"
                    ]

      diffD <- ct $ compareFiles "./AddOneParameter/D1.expected.hs"
                                 "./AddOneParameter/D1.refactored.hs"
      diffD `shouldBe` []

      diffC <- ct $ compareFiles "./AddOneParameter/C1.expected.hs"
                                 "./AddOneParameter/C1.refactored.hs"
      diffC `shouldBe` []

      diffA <- ct $ compareFiles "./AddOneParameter/A1.expected.hs"
                                 "./AddOneParameter/A1.refactored.hs"
      diffA `shouldBe` []

    -- -------------------

    it "addOneParameter in D2 B2 C2 A2" $ do
      r <- ct $ addOneParameter defaultTestSettings testOptions "./AddOneParameter/D2.hs" "f" (11,1)
      -- r <- ct $ addOneParameter logTestSettings testOptions "./AddOneParameter/D2.hs" "f" (11,1)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "AddOneParameter/D2.hs"
                    , "AddOneParameter/A2.hs"
                    , "AddOneParameter/C2.hs"
                    ]

      diffD <- ct $ compareFiles "./AddOneParameter/D2.expected.hs"
                                 "./AddOneParameter/D2.refactored.hs"
      diffD `shouldBe` []

      diffC <- ct $ compareFiles "./AddOneParameter/C2.expected.hs"
                                 "./AddOneParameter/C2.refactored.hs"
      diffC `shouldBe` []

      diffA <- ct $ compareFiles "./AddOneParameter/A2.expected.hs"
                                 "./AddOneParameter/A2.refactored.hs"
      diffA `shouldBe` []

    -- -------------------

    it "addOneParameter in PatIn1" $ do
      r <- ct $ addOneParameter defaultTestSettings testOptions "./AddOneParameter/PatIn1.hs" "x" (7,1)
      -- r <- ct $ addOneParameter logTestSettings testOptions "./AddOneParameter/PatIn1.hs" "x" (7,1)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "AddOneParameter/PatIn1.hs"
                    ]

      diffD <- ct $ compareFiles "./AddOneParameter/PatIn1.expected.hs"
                                 "./AddOneParameter/PatIn1.refactored.hs"
      diffD `shouldBe` []

    -- -------------------

    it "addOneParameter in FunIn1" $ do
      -- (["FunIn1.hs"],["y","7","1"]),
      r <- ct $ addOneParameter defaultTestSettings testOptions "./AddOneParameter/FunIn1.hs" "y" (7,1)
      -- r <- ct $ addOneParameter logTestSettings testOptions "./AddOneParameter/FunIn1.hs" "y" (7,1)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "AddOneParameter/FunIn1.hs"
                    ]

      diffD <- ct $ compareFiles "./AddOneParameter/FunIn1.expected.hs"
                                 "./AddOneParameter/FunIn1.refactored.hs"
      diffD `shouldBe` []

    -- -------------------

    it "addOneParameter in FunIn2" $ do
          -- (["FunIn2.hs"],["y","10","18"]),
      r <- ct $ addOneParameter defaultTestSettings testOptions "./AddOneParameter/FunIn2.hs" "y" (10,18)
      -- r <- ct $ addOneParameter logTestSettings testOptions "./AddOneParameter/FunIn2.hs" "y" (10,18)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "AddOneParameter/FunIn2.hs"
                    ]

      diffD <- ct $ compareFiles "./AddOneParameter/FunIn2.expected.hs"
                                 "./AddOneParameter/FunIn2.refactored.hs"
      diffD `shouldBe` []

    -- -------------------

    it "addOneParameter in FunIn3" $ do
          -- (["FunIn3.hs"],["y","9","11"]),
      r <- ct $ addOneParameter defaultTestSettings testOptions "./AddOneParameter/FunIn3.hs" "y" (9,11)
      -- r <- ct $ addOneParameter logTestSettings testOptions "./AddOneParameter/FunIn3.hs" "y" (9,11)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "AddOneParameter/FunIn3.hs"
                    ]

      diffD <- ct $ compareFiles "./AddOneParameter/FunIn3.expected.hs"
                                 "./AddOneParameter/FunIn3.refactored.hs"
      diffD `shouldBe` []

    -- -------------------

    it "addOneParameter in FunIn4" $ do
          -- (["FunIn4.hs"],["y","8","22"])],
      r <- ct $ addOneParameter defaultTestSettings testOptions "./AddOneParameter/FunIn4.hs" "y" (8,22)
      -- r <- ct $ addOneParameter logTestSettings testOptions "./AddOneParameter/FunIn4.hs" "y" (8,22)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "AddOneParameter/FunIn4.hs"
                    ]

      diffD <- ct $ compareFiles "./AddOneParameter/FunIn4.expected.hs"
                                 "./AddOneParameter/FunIn4.refactored.hs"
      diffD `shouldBe` []

    -- -------------------

    it "addOneParameter in FunIn6" $ do
          -- (["FunIn6.hs"],["y","8","22"])],
      r <- ct $ addOneParameter defaultTestSettings testOptions "./AddOneParameter/FunIn6.hs" "y" (9,7)
      -- r <- ct $ addOneParameter logTestSettings testOptions "./AddOneParameter/FunIn6.hs" "y" (9,7)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "AddOneParameter/FunIn6.hs"
                    ]

      diffD <- ct $ compareFiles "./AddOneParameter/FunIn6.expected.hs"
                                 "./AddOneParameter/FunIn6.refactored.hs"
      diffD `shouldBe` []

    -- -------------------

    it "addOneParameter in Nested" $ do
      r <- ct $ addOneParameter defaultTestSettings testOptions "./AddOneParameter/Nested.hs" "y" (8,1)
      -- r <- ct $ addOneParameter logTestSettings testOptions "./AddOneParameter/Nested.hs" "y" (8,1)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "AddOneParameter/Nested.hs"
                    ]

      diffD <- ct $ compareFiles "./AddOneParameter/Nested.expected.hs"
                                 "./AddOneParameter/Nested.refactored.hs"
      diffD `shouldBe` []

    -- ---------------------------------
    -- Negative tests
    -- ---------------------------------

    it "fails complex pat binding PatIn2" $ do
     -- [(["PatIn2.hs"],["x","7","20"]),
     res <- catchException (ct $ addOneParameter defaultTestSettings testOptions "./AddOneParameter/PatIn2.hs" "x" (7,20))
     (show res) `shouldBe` "Just \"Parameter can not be added to complex pattern binding\""

    -- -------------------

    it "fails name clash FunIn5" $ do
         -- (["FunIn5.hs"],["h","8","1"])]
     res <- catchException (ct $ addOneParameter defaultTestSettings testOptions "./AddOneParameter/FunIn5.hs" "h" (8,1))
     (show res) `shouldBe` "Just \"The new parameter name will cause name clash or semantics change, please choose another name!\""

    -- -------------------
{-
TestCases{refactorCmd="addOneParameter",
positive=[(["D3.hs","A3.hs"],["y","7","1"]),
          (["D1.hs","C1.hs","A1.hs"],["f","10","1"]),
          (["D2.hs","C2.hs","A2.hs"],["f","11","1"]),
          (["PatIn1.hs"],["x","7","1"]),
          (["FunIn1.hs"],["y","7","1"]),
          (["FunIn2.hs"],["y","10","18"]),
          (["FunIn3.hs"],["y","9","11"]),
          (["FunIn4.hs"],["y","8","22"])],
negative=[(["PatIn2.hs"],["x","7","20"]),
         (["FunIn5.hs"],["h","8","1"])]

-}

    -- ---------------------------------

  describe "Removing" $ do
    it "rmOneParameter in D1 A1" $ do
          -- (["D1.hs","A1.hs"],["6","19"]),
      r <- ct $ rmOneParameter defaultTestSettings testOptions "./RmOneParameter/D1.hs" (6,19)
      -- r <- ct $ rmOneParameter logTestSettings testOptions "./RmOneParameter/D1.hs" (6,19)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "RmOneParameter/D1.hs"
                    , "RmOneParameter/A1.hs"
                    ]

      diffD <- ct $ compareFiles "./RmOneParameter/D1.expected.hs"
                                 "./RmOneParameter/D1.refactored.hs"
      diffD `shouldBe` []

      diffA <- ct $ compareFiles "./RmOneParameter/A1.expected.hs"
                                 "./RmOneParameter/A1.refactored.hs"
      diffA `shouldBe` []

    -- -------------------

    it "rmOneParameter in D2 A2" $ do
          -- (["D2.hs","A2.hs"],["7","19"]),
      r <- ct $ rmOneParameter defaultTestSettings testOptions "./RmOneParameter/D2.hs" (7,19)
      -- r <- ct $ rmOneParameter logTestSettings testOptions "./RmOneParameter/D2.hs" (7,19)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "RmOneParameter/D2.hs"
                    , "RmOneParameter/A2.hs"
                    ]

      diffD <- ct $ compareFiles "./RmOneParameter/D2.expected.hs"
                                 "./RmOneParameter/D2.refactored.hs"
      diffD `shouldBe` []

      diffA <- ct $ compareFiles "./RmOneParameter/A2.expected.hs"
                                 "./RmOneParameter/A2.refactored.hs"
      diffA `shouldBe` []

    -- -------------------

    it "rmOneParameter in FunIn1" $ do
          -- (["FunIn1.hs"],["8","5"]),
      r <- ct $ rmOneParameter defaultTestSettings testOptions "./RmOneParameter/FunIn1.hs" (8,5)
      -- r <- ct $ rmOneParameter logTestSettings testOptions "./RmOneParameter/FunIn1.hs" (8,5)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "RmOneParameter/FunIn1.hs"
                    ]

      diffD <- ct $ compareFiles "./RmOneParameter/FunIn1.expected.hs"
                                 "./RmOneParameter/FunIn1.refactored.hs"
      diffD `shouldBe` []

    -- -------------------

    it "rmOneParameter in FunIn2" $ do
          -- (["FunIn2.hs"],["8","5"]),
      r <- ct $ rmOneParameter defaultTestSettings testOptions "./RmOneParameter/FunIn2.hs" (8,5)
      -- r <- ct $ rmOneParameter logTestSettings testOptions "./RmOneParameter/FunIn2.hs" (8,5)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "RmOneParameter/FunIn2.hs"
                    ]

      diffD <- ct $ compareFiles "./RmOneParameter/FunIn2.expected.hs"
                                 "./RmOneParameter/FunIn2.refactored.hs"
      diffD `shouldBe` []

    -- -------------------

    it "rmOneParameter in FunIn2a" $ do
          -- (["FunIn2.hs"],["8","5"]),
      r <- ct $ rmOneParameter defaultTestSettings testOptions "./RmOneParameter/FunIn2a.hs" (8,5)
      -- r <- ct $ rmOneParameter logTestSettings testOptions "./RmOneParameter/FunIn2a.hs" (8,5)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "RmOneParameter/FunIn2a.hs"
                    ]

      diffD <- ct $ compareFiles "./RmOneParameter/FunIn2a.expected.hs"
                                 "./RmOneParameter/FunIn2a.refactored.hs"
      diffD `shouldBe` []

    -- -------------------

    it "rmOneParameter in FunIn3" $ do
          -- (["FunIn3.hs"],["7","5"]),
      r <- ct $ rmOneParameter defaultTestSettings testOptions "./RmOneParameter/FunIn3.hs" (7,5)
      -- r <- ct $ rmOneParameter logTestSettings testOptions "./RmOneParameter/FunIn3.hs" (7,5)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "RmOneParameter/FunIn3.hs"
                    ]

      diffD <- ct $ compareFiles "./RmOneParameter/FunIn3.expected.hs"
                                 "./RmOneParameter/FunIn3.refactored.hs"
      diffD `shouldBe` []

    -- -------------------

    it "rmOneParameter in FunIn5" $ do
          -- (["FunIn5.hs"],["7","6"]),
      r <- ct $ rmOneParameter defaultTestSettings testOptions "./RmOneParameter/FunIn5.hs" (7,6)
      -- r <- ct $ rmOneParameter logTestSettings testOptions "./RmOneParameter/FunIn5.hs" (7,6)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "RmOneParameter/FunIn5.hs"
                    ]

      diffD <- ct $ compareFiles "./RmOneParameter/FunIn5.expected.hs"
                                 "./RmOneParameter/FunIn5.refactored.hs"
      diffD `shouldBe` []

    -- -------------------

    it "rmOneParameter in FunIn6" $ do
          -- (["FunIn6.hs"],["7","5"]),
      r <- ct $ rmOneParameter defaultTestSettings testOptions "./RmOneParameter/FunIn6.hs" (7,5)
      -- r <- ct $ rmOneParameter logTestSettings testOptions "./RmOneParameter/FunIn6.hs" (7,5)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "RmOneParameter/FunIn6.hs"
                    ]

      diffD <- ct $ compareFiles "./RmOneParameter/FunIn6.expected.hs"
                                 "./RmOneParameter/FunIn6.refactored.hs"
      diffD `shouldBe` []

    -- -------------------

    it "rmOneParameter in FunIn0" $ do
          -- (["FunIn0.hs"],["10","7"])],
      r <- ct $ rmOneParameter defaultTestSettings testOptions "./RmOneParameter/FunIn0.hs" (10,7)
      -- r <- ct $ rmOneParameter logTestSettings testOptions "./RmOneParameter/FunIn0.hs" (10,7)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "RmOneParameter/FunIn0.hs"
                    ]

      diffD <- ct $ compareFiles "./RmOneParameter/FunIn0.expected.hs"
                                 "./RmOneParameter/FunIn0.refactored.hs"
      diffD `shouldBe` []

    -- -------------------

    it "rmOneParameter in SubFun1" $ do
      r <- ct $ rmOneParameter defaultTestSettings testOptions "./RmOneParameter/SubFun1.hs" (10,9)
      -- r <- ct $ rmOneParameter logTestSettings testOptions "./RmOneParameter/SubFun1.hs" (10,9)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "RmOneParameter/SubFun1.hs"
                    ]

      diffD <- ct $ compareFiles "./RmOneParameter/SubFun1.expected.hs"
                                 "./RmOneParameter/SubFun1.refactored.hs"
      diffD `shouldBe` []

    -- -------------------

    it "rmOneParameter in SubFun2" $ do
      r <- ct $ rmOneParameter defaultTestSettings testOptions "./RmOneParameter/SubFun2.hs" (10,9)
      -- r <- ct $ rmOneParameter logTestSettings testOptions "./RmOneParameter/SubFun2.hs" (10,9)

      r' <- ct $ mapM makeRelativeToCurrentDirectory r

      r' `shouldBe` [ "RmOneParameter/SubFun2.hs"
                    ]

      diffD <- ct $ compareFiles "./RmOneParameter/SubFun2.expected.hs"
                                 "./RmOneParameter/SubFun2.refactored.hs"
      diffD `shouldBe` []

    -- ---------------------------------
    -- Negative tests
    -- ---------------------------------

    it "fails FunIn4" $ do
     -- (["FunIn4.hs"],["7","6"]),
     res <- catchException (ct $ rmOneParameter defaultTestSettings testOptions "./RmOneParameter/FunIn4.hs" (7,6))
     -- ct $ rmOneParameter logTestSettings testOptions "./RmOneParameter/FunIn4.hs" (7,6)
     (show res) `shouldBe` "Just \"This parameter can not be removed, as it is used!\""

    -- -------------------

    it "fails FunIn7" $ do
          -- (["FunIn7.hs"],["10","4"])]
     res <- catchException (ct $ rmOneParameter defaultTestSettings testOptions "./RmOneParameter/FunIn7.hs" (10,4))
     (show res) `shouldBe` "Just \"Invalid cursor position!\""

    -- -------------------
{-
TestCases{refactorCmd="rmOneParameter",
positive=[
          (["D1.hs","A1.hs"],["6","19"]),
          (["D2.hs","A2.hs"],["7","19"]),
          (["FunIn1.hs"],["8","5"]),
          (["FunIn2.hs"],["8","5"]),
          (["FunIn3.hs"],["7","5"]),
          (["FunIn5.hs"],["7","6"]),
          (["FunIn6.hs"],["7","5"]),
          (["FunIn0.hs"],["10","7"])],
negative=[(["FunIn4.hs"],["7","6"]),
          (["FunIn7.hs"],["10","4"])]
}

TODO: Add a test for a PatBind too
-}
