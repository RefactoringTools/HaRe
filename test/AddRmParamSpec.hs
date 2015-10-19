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
