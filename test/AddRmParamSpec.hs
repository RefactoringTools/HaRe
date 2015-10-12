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
    it "renames in D1 B1 C1 A1 6 6" $ do
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
