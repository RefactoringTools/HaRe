{-# LANGUAGE BangPatterns #-}
module AnnotationsSpec (main, spec) where

import           Test.Hspec

import qualified GHC        as GHC

import qualified GHC.SYB.Utils as SYB

import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.Types
import Language.Haskell.Refact.Utils.Utils

import Language.Haskell.GHC.ExactPrint

import TestUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do

  -- ---------------------------------------------

  describe "new ghc-mod" $ do
    it "can load a file" $ do
      -- (t,toks) <- parsedFileGhc "./test/testdata/MoveDef/Md1.hs"
      (t,toks) <- parsedFileGhcCd "./test/testdata/" "TokenTest.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      putStrLn $ SYB.showData SYB.Parser 0 parsed
      "a" `shouldBe` "b"

    -- ---------------------------------

    it "can round-trip a file 1" $ do
      -- (t,toks) <- parsedFileGhc "./test/testdata/MoveDef/Md1.hs"
      (t,toks) <- parsedFileGhcCd "./test/testdata/" "TokenTest.hs"
      let
        comp = do
          (r,_) <- applyRefac (setRefactStreamModified RefacModified) RSAlreadyLoaded
          return r
      (((fn,m),(anns,mod')),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule t toks }) testOptions
      (show (fn,m)) `shouldBe` "(\"TokenTest.hs\",RefacModified)"
      putStrLn $ SYB.showData SYB.Parser 0 mod'
      let !printed = exactPrintAnnotation mod' [] anns
      printed `shouldBe` "foo"

    -- ---------------------------------

    it "can round-trip a file 2" $ do
      -- (t,toks) <- parsedFileGhc "./test/testdata/MoveDef/Md1.hs"
      (t,toks) <- parsedFileGhcCd "/home/alanz/mysrc/github/alanz/ghc-exactprint/src/" "./Language/Haskell/GHC/ExactPrint/Utils.hs"
      let
        comp = do
          (r,_) <- applyRefac (setRefactStreamModified RefacModified) RSAlreadyLoaded
          return r
      (((fn,m),(anns,mod')),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule t toks }) testOptions
      (show (fn,m)) `shouldBe` "(\"TokenTest.hs\",RefacModified)"
      putStrLn $ SYB.showData SYB.Parser 0 mod'
      let !printed = exactPrintAnnotation mod' [] anns
      printed `shouldBe` "foo"
