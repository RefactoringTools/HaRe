module TokenUtilsSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import qualified Bag        as GHC
import qualified Digraph    as GHC
import qualified FastString as GHC
import qualified GHC        as GHC
import qualified GhcMonad   as GHC
import qualified Lexer      as GHC
import qualified Name       as GHC
import qualified Outputable as GHC
import qualified SrcLoc     as GHC

import Control.Monad.State
import Data.Maybe
import Data.Tree
import Exception

import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

import TestUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = hspec spec

spec :: Spec
spec = do

  describe "getTokens" $ do
    it "gets the tokens for a given srcloc, and caches them" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls      
      let tm = initModule t toks
      let (tm',declToks) = getTokensFor tm l
      {-
      let
        comp = do
         newName <- mkNewGhcName "bar2"

         return (newName)
      ((nn),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      -}

      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(17,1)-(19,13)"
      (GHC.showPpr decl) `shouldBe` "TokenTest.foo x y\n  = do { c <- System.IO.getChar;\n         GHC.Base.return c }"
      (showToks declToks) `shouldBe` ""
      (show $ mTokenCache tm') `shouldBe` ""

  -- ---------------------------------------------

  describe "invariant 1" $ do
    it "checks that a tree with empty tokens and empty subForest fails" $ do
      (invariant [Node (Entry GHC.noSrcSpan []) []]) `shouldBe` ["FAIL: exactly one of toks or subforest must be empty: Node (Entry ((-1,-1),(-1,-1)) []) []"]

    -- -----------------------
    it "checks that a tree nonempty tokens and empty subForest passes" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      (invariant [Node (Entry GHC.noSrcSpan (take 3 toks)) []]) `shouldBe` []

    -- -----------------------
    it "checks that a tree with nonempty tokens and nonempty subForest fails" $ do
      (_t,toks) <- parsedFileTokenTestGhc

      (invariant [Node (Entry GHC.noSrcSpan (take 1 toks)) [emptyTree]]) `shouldBe`
               ["FAIL: exactly one of toks or subforest must be empty: Node (Entry ((-1,-1),(-1,-1)) [(((1,1),(1,7)),ITmodule,\"module\")]) [\"Node (Entry ((-1,-1),(-1,-1)) []) []\"]",
                "FAIL: exactly one of toks or subforest must be empty: Node (Entry ((-1,-1),(-1,-1)) []) []"]

    -- -----------------------
    it "checks that a tree with empty tokens and nonempty subForest passes" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let tree@(Node (Entry sspan _) _) = mkTreeFromTokens toks

      (invariant [Node (Entry sspan []) [tree]]) `shouldBe` []

    -- -----------------------
    it "checks the subtrees too" $ do
      (_t,toks) <- parsedFileTokenTestGhc

      (invariant [Node (Entry GHC.noSrcSpan []) [emptyTree]]) `shouldBe` ["FAIL: exactly one of toks or subforest must be empty: Node (Entry ((-1,-1),(-1,-1)) []) []"]

  -- ---------------------------------------------

  describe "invariant 2" $ do
    it "checks that a the subree fully includes the parent" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let tree@(Node (Entry sspan _) _) = mkTreeFromTokens toks
      let tree2 = mkTreeFromTokens (tail toks)
      let tree3 = mkTreeFromTokens (take 10 toks)
      let tree4 = mkTreeFromTokens (drop 10 toks)
      (showTree tree)  `shouldBe` "Node (Entry ((1,1),(24,1)) [(((1,1),(1,7)),ITmodule,\"module\")]..[(((24,1),(24,1)),ITsemi,\"\")]) []"
      (showTree tree2) `shouldBe` "Node (Entry ((1,8),(24,1)) [(((1,8),(1,17)),ITconid \"TokenTest\",\"TokenTest\")]..[(((24,1),(24,1)),ITsemi,\"\")]) []"
      (showTree tree3) `shouldBe` "Node (Entry ((1,1),(5,12)) [(((1,1),(1,7)),ITmodule,\"module\")]..[(((5,11),(5,12)),ITvarid \"x\",\"x\")]) []"

      (invariant [Node (Entry sspan []) [tree2]]) `shouldBe` ["FAIL: subForest start and end does not match entry: Node (Entry ((1,1),(24,1)) []) [\"Node (Entry ((1,8),(24,1)) [(((1,8),(1,17)),ITconid \\\"TokenTest\\\",\\\"TokenTest\\\")]..[(((24,1),(24,1)),ITsemi,\\\"\\\")]) []\"]"]
      (invariant [Node (Entry sspan []) [tree3]]) `shouldBe` ["FAIL: subForest start and end does not match entry: Node (Entry ((1,1),(24,1)) []) [\"Node (Entry ((1,1),(5,12)) [(((1,1),(1,7)),ITmodule,\\\"module\\\")]..[(((5,11),(5,12)),ITvarid \\\"x\\\",\\\"x\\\")]) []\"]"]

      (invariant [Node (Entry sspan []) [tree3,tree4]]) `shouldBe` []

    it "checks that a the subree is in span order" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let tree@(Node (Entry sspan _) _) = mkTreeFromTokens toks
      let tree1 = mkTreeFromTokens (take 10 toks)
      let tree2 = mkTreeFromTokens (take 10 $ drop 10 toks)
      let tree3 = mkTreeFromTokens (take 10 $ drop 20 toks)
      let tree4 = mkTreeFromTokens (drop 30 toks)

      (show $ treeStartEnd tree1) `shouldBe` "((1,1),(5,12))"
      (show $ treeStartEnd tree2) `shouldBe` "((6,3),(8,8))"
      (show $ treeStartEnd tree3) `shouldBe` "((8,9),(13,4))"
      (show $ treeStartEnd tree4) `shouldBe` "((13,5),(24,1))"

      (invariant [Node (Entry sspan []) [tree1,tree2,tree3,tree4]]) `shouldBe` []
      (invariant [Node (Entry sspan []) [tree1,tree3,tree2,tree4]]) `shouldBe` ["FAIL: subForest not in order: (13,4) not < (6,3):Node (Entry ((1,1),(24,1)) []) [\"Node (Entry ((1,1),(5,12)) [(((1,1),(1,7)),ITmodule,\\\"module\\\")]..[(((5,11),(5,12)),ITvarid \\\"x\\\",\\\"x\\\")]) []\",\"Node (Entry ((8,9),(13,4)) [(((8,9),(8,10)),ITequal,\\\"=\\\")]..[(((13,1),(13,4)),ITvarid \\\"bab\\\",\\\"bab\\\")]) []\",\"Node (Entry ((6,3),(8,8)) [(((6,3),(6,8)),ITwhere,\\\"where\\\")]..[(((8,7),(8,8)),ITvarid \\\"b\\\",\\\"b\\\")]) []\",\"Node (Entry ((13,5),(24,1)) [(((13,5),(13,6)),ITvarid \\\"a\\\",\\\"a\\\")]..[(((24,1),(24,1)),ITsemi,\\\"\\\")]) []\"]"]

  -- ---------------------------------------------

  describe "invariant 3" $ do
    it "checks that the forest is in order, hence no overlaps" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let tree@(Node (Entry sspan _) _) = mkTreeFromTokens toks
      let tree1 = mkTreeFromTokens (take 10 toks)
      let tree2 = mkTreeFromTokens (take 10 $ drop 10 toks)
      let tree3 = mkTreeFromTokens (take 10 $ drop 20 toks)
      let tree4 = mkTreeFromTokens (drop 30 toks)

      (show $ treeStartEnd tree1) `shouldBe` "((1,1),(5,12))"
      (show $ treeStartEnd tree2) `shouldBe` "((6,3),(8,8))"
      (show $ treeStartEnd tree3) `shouldBe` "((8,9),(13,4))"
      (show $ treeStartEnd tree4) `shouldBe` "((13,5),(24,1))"

      (invariant [tree1,tree2,tree3,tree4]) `shouldBe` []
      (invariant [tree1,tree3,tree2,tree4]) `shouldBe` ["FAIL: forest not in order: (13,4) not < (6,3)"]

  -- ---------------------------------------------

  describe "mkTreeFromTokens" $ do
    it "creates a tree from an empty token list" $ do
      (show $ mkTreeFromTokens []) `shouldBe` "Node {rootLabel = Entry (UnhelpfulSpan \"<no location info>\") [], subForest = []}"

    -- -----------------------

    it "creates a tree from a list of tokens" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let toks' = take 2 $ drop 5 toks
      let tree = mkTreeFromTokens toks'
      (show toks') `shouldBe` "[((((5,1),(5,4)),ITvarid \"bob\"),\"bob\"),((((5,5),(5,6)),ITvarid \"a\"),\"a\")]"
      (show tree) `shouldBe` "Node {rootLabel = Entry (RealSrcSpan (SrcSpanOneLine {srcSpanFile = \"./test/testdata/TokenTest.hs\", srcSpanLine = 5, srcSpanSCol = 1, srcSpanECol = 6})) [((((5,1),(5,4)),ITvarid \"bob\"),\"bob\"),((((5,5),(5,6)),ITvarid \"a\"),\"a\")], subForest = []}"


-- ---------------------------------------------------------------------
-- Helper functions

emptyTree :: Tree Entry
emptyTree = Node (Entry GHC.noSrcSpan []) []


-- ---------------------------------------------------------------------

tokenTestFileName :: GHC.FastString
tokenTestFileName = GHC.mkFastString "./test/testdata/TokenTest.hs"

parsedFileTokenTestGhc :: IO (ParseResult,[PosToken])
parsedFileTokenTestGhc = parsedFileGhc "./test/testdata/TokenTest.hs"

