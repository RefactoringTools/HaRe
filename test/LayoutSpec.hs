module LayoutSpec (main, spec) where

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
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

import qualified Data.Tree.Zipper as Z
import qualified Data.Map as Map

import TestUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do

  -- ---------------------------------------------

  describe "allocTokens" $ do
    it "allocates Tokens for a default main module" $ do
      (t,toks) <- parsedFileBare
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- (SYB.showData SYB.Parser 0 parsed) `shouldBe` ""

      (show toks) `shouldBe`
         "[((((3,1),(3,5)),ITvarid \"main\"),\"main\"),"++
          "((((3,6),(3,7)),ITequal),\"=\"),"++
          "((((3,8),(3,16)),ITvarid \"putStrLn\"),\"putStrLn\"),"++
          "((((3,17),(3,24)),ITstring \"hello\"),\"\\\"hello\\\"\")]"

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (showGhc layout) `shouldBe`
         "[LeafLocated test/testdata/Layout/Bare.hs:3:1-4 "++
            "[((((3,1),(3,5)),ITvarid \"main\"),\"main\")],\n "++
         "Leaf [((((3,6),(3,7)),ITequal),\"=\")],\n "++
         "LeafLocated test/testdata/Layout/Bare.hs:3:8-15 "++
            "[((((3,8),(3,16)),ITvarid \"putStrLn\"),\"putStrLn\")],\n "++
         "LeafLocated test/testdata/Layout/Bare.hs:3:17-23 "++
            "[((((3,17),(3,24)),ITstring \"hello\"),\"\\\"hello\\\"\")]]"

  -- ---------------------------------------------

    it "allocates Tokens for a let expression" $ do
      (t,toks) <- parsedFileLetExpr
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let renamed = fromJust $ GHC.tm_renamed_source t

      -- (SYB.showData SYB.Parser 0 parsed) `shouldBe` ""
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      (show toks) `shouldBe`
         "[((((1,1),(1,61)),ITlineComment \"-- A simple let expression, to ensure the layout is detected\"),\"-- A simple let expression, to ensure the layout is detected\"),"++
         "((((3,1),(3,7)),ITmodule),\"module\"),"++
         "((((3,8),(3,22)),ITqconid (\"Layout\",\"LetExpr\")),\"Layout.LetExpr\"),"++
         "((((3,23),(3,28)),ITwhere),\"where\"),"++
         "((((5,1),(5,1)),ITvocurly),\"\"),"++
         "((((5,1),(5,4)),ITvarid \"foo\"),\"foo\"),"++
         "((((5,5),(5,6)),ITequal),\"=\"),"++
         "((((5,7),(5,10)),ITlet),\"let\"),"++
         "((((5,11),(5,11)),ITvocurly),\"\"),"++
         "((((5,11),(5,12)),ITvarid \"x\"),\"x\"),"++
         "((((5,13),(5,14)),ITequal),\"=\"),"++
         "((((5,15),(5,16)),ITinteger 1),\"1\"),"++
         "((((6,11),(6,11)),ITsemi),\"\"),"++
         "((((6,11),(6,12)),ITvarid \"y\"),\"y\"),"++
         "((((6,13),(6,14)),ITequal),\"=\"),"++
         "((((6,15),(6,16)),ITinteger 2),\"2\"),"++
         "((((7,7),(7,7)),ITvccurly),\"\"),"++
         "((((7,7),(7,9)),ITin),\"in\"),"++
         "((((7,10),(7,11)),ITvarid \"x\"),\"x\"),"++
         "((((7,12),(7,13)),ITvarsym \"+\"),\"+\"),"++
         "((((7,14),(7,15)),ITvarid \"y\"),\"y\"),"++
         "((((9,1),(9,1)),ITsemi),\"\")]"


      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (showGhc layout) `shouldBe`
         ""

  -- ---------------------------------------------

    it "allocates Tokens for a let statement" $ do
      (t,toks) <- parsedFileLetStmt
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let renamed = fromJust $ GHC.tm_renamed_source t

      -- (SYB.showData SYB.Parser 0 parsed) `shouldBe` ""
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

{-
      (show toks) `shouldBe`
         "[((((1,1),(1,60)),ITlineComment \"-- A simple let statement, to ensure the layout is detected\"),\"-- A simple let statement, to ensure the layout is detected\"),"++
         "((((3,1),(3,7)),ITmodule),\"module\"),"++
         "((((3,8),(3,22)),ITqconid (\"Layout\",\"LetStmt\")),\"Layout.LetStmt\"),"++
         "((((3,23),(3,28)),ITwhere),\"where\"),"++
         "((((5,1),(5,1)),ITvocurly),\"\"),"++
         "((((5,1),(5,4)),ITvarid \"foo\"),\"foo\"),"++
         "((((5,5),(5,6)),ITequal),\"=\"),"++
         "((((5,7),(5,9)),ITdo),\"do\"),"++
         "((((6,9),(6,9)),ITvocurly),\"\"),"++
         "((((6,9),(6,12)),ITlet),\"let\"),"++
         "((((6,13),(6,13)),ITvocurly),\"\"),"++
         "((((6,13),(6,14)),ITvarid \"x\"),\"x\"),"++
         "((((6,15),(6,16)),ITequal),\"=\"),"++
         "((((6,17),(6,18)),ITinteger 1),\"1\"),"++
         "((((7,13),(7,13)),ITsemi),\"\"),"++
         "((((7,13),(7,14)),ITvarid \"y\"),\"y\"),"++
         "((((7,15),(7,16)),ITequal),\"=\"),"++
         "((((7,17),(7,18)),ITinteger 2),\"2\"),"++
         "((((8,9),(8,9)),ITvccurly),\"\"),"++
         "((((8,9),(8,9)),ITsemi),\"\"),"++
         "((((8,9),(8,10)),ITvarid \"x\"),\"x\"),"++
         "((((8,10),(8,11)),ITvarsym \"+\"),\"+\"),"++
         "((((8,11),(8,12)),ITvarid \"y\"),\"y\"),"++
         "((((10,1),(10,1)),ITvccurly),\"\"),"++
         "((((10,1),(10,1)),ITsemi),\"\")]"
-}

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (showGhc layout) `shouldBe`
         ""

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
