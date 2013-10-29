{-# LANGUAGE TypeOperators #-}
module LayoutUtilsSpec (main, spec) where

import           Test.Hspec

import qualified FastString as GHC
import qualified GHC        as GHC
import qualified Lexer      as GHC

import qualified GHC.SYB.Utils as SYB

import Control.Monad.State
import Data.Maybe
import Data.Tree

import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.Layout
import Language.Haskell.Refact.Utils.LayoutTypes
import Language.Haskell.Refact.Utils.LayoutUtils
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

import qualified Data.Tree.Zipper as Z
import qualified Data.Map as Map

import Data.Traversable

import TestUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do

  -- ---------------------------------------------

  describe "getLayoutFor" $ do
    it "gets the layout for a leaf in the LayoutTree " $ do
      (t,toks) <- parsedFileLetExpr
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- (SYB.showData SYB.Parser 0 parsed) `shouldBe` ""

      let layout = allocTokens parsed toks

      (show $ retrieveTokens layout) `shouldBe` (show toks)

      -- (showGhc layout) `shouldBe`
      --    ""

      let sspan = posToSrcSpanTok (head toks) ((7,7),(7,9))

      (GHC.isSubspanOf sspan sspan) `shouldBe` True

      let lay = getLayoutFor sspan (TL layout)

      (showGhc lay) `shouldBe`
          "Leaf\n"++
          "  test/testdata/Layout/LetExpr.hs:7:7-8\n"++
          "  NoChange\n"++
          "  [((((7,7),(7,7)),ITvccurly),\"\"),((((7,7),(7,9)),ITin),\"in\")]"

  -- ---------------------------------------------

    it "gets the layout for a group in the LayoutTree " $ do
      (t,toks) <- parsedFileLetExpr
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- (SYB.showData SYB.Parser 0 parsed) `shouldBe` ""

      let layout = allocTokens parsed toks

      (show $ retrieveTokens layout) `shouldBe` (show toks)

      let sspan = posToSrcSpanTok (head toks) ((5,5),(7,15))

      let lay = getLayoutFor sspan (TL layout)

      (showLTOne lay) `shouldBe`
          "(Group test/testdata/Layout/LetExpr.hs:(5,5)-(7,14) NoChange [test/testdata/Layout/LetExpr.hs:5:5,\n test/testdata/Layout/LetExpr.hs:(5,7)-(7,14)])"

  -- ---------------------------------------------


  -- ---------------------------------------------

  describe "openZipper" $ do
    it "opens a zipper to the given SrcSpan" $ do
      (t,toks) <- parsedFileLetExpr
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- (SYB.showData SYB.Parser 0 parsed) `shouldBe` ""

      let layout = allocTokens parsed toks

      (show $ retrieveTokens layout) `shouldBe` (show toks)

      -- (showGhc layout) `shouldBe`
      --    ""

      let sspan = posToSrcSpanTok (head toks) ((7,7),(7,9))

      let z = (Z.fromTree layout)
      let z1 = openZipper sspan z

      (showGhc $ Z.tree z1) `shouldBe`
         "Node\n  Label test/testdata/Layout/LetExpr.hs:7:7-8 NoChange [((((7,7),(7,7)),ITvccurly),\"\"),((((7,7),(7,9)),ITin),\"in\")]\n  []"


-- ---------------------------------------------------------------------

parsedFileBare :: IO (ParseResult,[PosToken])
parsedFileBare = parsedFileGhc "./test/testdata/Layout/Bare.hs"

-- ---------------------------------------------------------------------

parsedFileLetExpr :: IO (ParseResult,[PosToken])
parsedFileLetExpr = parsedFileGhc "./test/testdata/Layout/LetExpr.hs"

-- ---------------------------------------------------------------------

parsedFileLetStmt :: IO (ParseResult,[PosToken])
parsedFileLetStmt = parsedFileGhc "./test/testdata/Layout/LetStmt.hs"

-- ---------------------------------------------------------------------
