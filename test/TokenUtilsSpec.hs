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


  describe "case 1" $ do
    it "gets a set of tokens, including comments" $ do
      pending "1"
    it "add a new set of tokens after the ones we have" $ do
      pending "2"
    it "gives us all the tokens in order after this" $ do
      pending "3"

  -- ---------------------------------------------

  describe "getTokens" $ do
    it "gets the tokens for a given srcloc, and caches them in the tree" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls

      let tm = initModule t toks
      let (tm',declToks) = getTokensFor tm l

      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"
      (GHC.showPpr decl) `shouldBe` "TokenTest.foo x y\n  = do { c <- System.IO.getChar;\n         GHC.Base.return c }"
      (showToks declToks) `shouldBe` "[(((18,1),(18,19)),ITlineComment \"-- leading comment\",\"-- leading comment\"),(((19,1),(19,1)),ITsemi,\"\"),(((19,1),(19,4)),ITvarid \"foo\",\"foo\"),(((19,5),(19,6)),ITvarid \"x\",\"x\"),(((19,7),(19,8)),ITvarid \"y\",\"y\"),(((19,9),(19,10)),ITequal,\"=\"),(((20,3),(20,5)),ITdo,\"do\"),(((20,6),(20,6)),ITvocurly,\"\"),(((20,6),(20,7)),ITvarid \"c\",\"c\"),(((20,8),(20,10)),ITlarrow,\"<-\"),(((20,11),(20,18)),ITvarid \"getChar\",\"getChar\"),(((21,6),(21,6)),ITsemi,\"\"),(((21,6),(21,12)),ITvarid \"return\",\"return\"),(((21,13),(21,14)),ITvarid \"c\",\"c\")]"

      -- Note: Although the tokens include leading and following
      -- comments, the SrcSpan must tie up with the original GHC
      -- SrcSpan in the AST
      (drawForestEntry $ mTokenCache tm') `shouldBe`
            "((1,1),(26,1))\n|\n"++
            "+- ((1,1),(15,18))\n|\n"++
            "+- ((19,1),(21,14))\n|\n"++
            "`- ((26,1),(26,1))\n\n"

  -- ---------------------------------------------

  describe "getSrcSpanFor" $ do
    it "inserts a SrcSpan if it was not in the forest" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      let forest = [mkTreeFromTokens toks]

      let (forest',tree) = getSrcSpanFor forest l

      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"
      (drawForestEntry forest') `shouldBe`
            "((1,1),(26,1))\n|\n"++
            "+- ((1,1),(15,18))\n|\n"++
            "+- ((19,1),(21,14))\n|\n"++
            "`- ((26,1),(26,1))\n\n"

      (show $ treeStartEnd tree) `shouldBe` "((19,1),(21,14))"

  -- ---------------------------------------------

  describe "lookupSrcSpan" $ do
    it "looks up a SrcSpan that is fully enclosed in the forest" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let tree1 = mkTreeFromTokens (take 10 toks)
      let tree2 = mkTreeFromTokens (take 10 $ drop 10 toks)
      let tree3 = mkTreeFromTokens (take 10 $ drop 20 toks)
      let tree4 = mkTreeFromTokens (drop 30 toks)
      let forest = [tree1,tree2,tree3,tree4]
      (invariant forest) `shouldBe` []

      (show $ treeStartEnd tree1) `shouldBe` "((1,1),(5,11))"
      (show $ treeStartEnd tree2) `shouldBe` "((6,3),(8,7))"
      (show $ treeStartEnd tree3) `shouldBe` "((8,9),(13,1))"
      (show $ treeStartEnd tree4) `shouldBe` "((13,5),(26,1))"

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let r = lookupSrcSpan forest l
      (map showTree r) `shouldBe` ["Node (Entry ((13,5),(26,1)) [(((13,5),(13,6)),ITvarid \"a\",\"a\")]..[(((26,1),(26,1)),ITsemi,\"\")]) []"]

    -- -----------------------
    it "looks up a SrcSpan that spans two trees in the forest" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let tree1 = mkTreeFromTokens (take 20 toks)
      let tree2 = mkTreeFromTokens (take 10 $ drop 20 toks)
      let tree3 = mkTreeFromTokens (take 20 $ drop 30 toks)
      let tree4 = mkTreeFromTokens (drop 50 toks)
      let forest = [tree1,tree2,tree3,tree4]
      (invariant forest) `shouldBe` []

      (show $ treeStartEnd tree1) `shouldBe` "((1,1),(8,7))"
      (show $ treeStartEnd tree2) `shouldBe` "((8,9),(13,1))"
      (show $ treeStartEnd tree3) `shouldBe` "((13,5),(19,9))"
      (show $ treeStartEnd tree4) `shouldBe` "((20,3),(26,1))"

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let r = lookupSrcSpan forest l
      (show $ map treeStartEnd r) `shouldBe` "[((13,5),(19,9)),((20,3),(26,1))]"

    -- -----------------------
    it "looks up a SrcSpan that spans four trees in the forest" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let tree1 = mkTreeFromTokens (take 48 toks)
      let tree2 = mkTreeFromTokens (take  5 $ drop 48 toks)
      let tree3 = mkTreeFromTokens (take  3 $ drop 53 toks)
      let tree4 = mkTreeFromTokens (drop 56 toks)
      (show $ treeStartEnd tree1) `shouldBe` "((1,1),(19,5))"
      (show $ treeStartEnd tree2) `shouldBe` "((19,7),(20,6))"
      (show $ treeStartEnd tree3) `shouldBe` "((20,8),(21,6))"
      (show $ treeStartEnd tree4) `shouldBe` "((21,6),(26,1))"
      let forest = [tree1,tree2,tree3,tree4]
      (invariant forest) `shouldBe` []

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let r = lookupSrcSpan forest l
      (show $ map treeStartEnd r) `shouldBe`
               "[((1,1),(19,5)),"++
               "((19,7),(20,6)),"++
               "((20,8),(21,6)),"++
               "((21,6),(26,1))]"

    -- -----------------------
    it "looks up a SrcSpan that is in a subtree of the forest" $ do
      (t,toks) <- parsedFileTokenTestGhc

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls

      let forest = insertSrcSpan [mkTreeFromTokens toks] l

      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      (drawForestEntry forest) `shouldBe`
            "((1,1),(26,1))\n|\n"++
            "+- ((1,1),(15,18))\n|\n"++
            "+- ((19,1),(21,14))\n|\n"++
            "`- ((26,1),(26,1))\n\n"

      let r = lookupSrcSpan forest l
      (show $ map treeStartEnd r) `shouldBe` "[((19,1),(21,14))]"


  -- ---------------------------------------------

  describe "splitForestOnSpan" $ do
    it "splits a forest into (begin,middle,end) according to a span" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let tree1 = mkTreeFromTokens (take 20 toks)
      let tree2 = mkTreeFromTokens (take 10 $ drop 20 toks)
      let tree3 = mkTreeFromTokens (take 15 $ drop 30 toks)
      let tree4 = mkTreeFromTokens (drop 45 toks)
      let forest = [tree1,tree2,tree3,tree4]
      (invariant forest) `shouldBe` []

      (show $ treeStartEnd tree1) `shouldBe` "((1,1),(8,7))"
      (show $ treeStartEnd tree2) `shouldBe` "((8,9),(13,1))"
      (show $ treeStartEnd tree3) `shouldBe` "((13,5),(18,1))"
      (show $ treeStartEnd tree4) `shouldBe` "((19,1),(26,1))"

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (begin,middle,end) = splitForestOnSpan forest l
      (map treeStartEnd begin) `shouldBe` [((1,1),(8,7)),((8,9),(13,1)),((13,5),(18,1))]
      (map treeStartEnd middle) `shouldBe` [((19,1),(26,1))]
      (map treeStartEnd end) `shouldBe` []

  -- ---------------------------------------------

  describe "insertSrcSpan" $ do
    it "checks that the forest is split into two parts" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = [mkTreeFromTokens toks]

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let forest' = insertSrcSpan forest l
      (drawForestEntry forest') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,18))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n\n"

  -- ---------------------------------------------

  describe "getPathFor" $ do
    it "retrieves an empty path if the SrcSpan is not in the tree" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = [mkTreeFromTokens toks]

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      (concatMap showTree $ getPathFor forest l) `shouldBe` ""

    -- -----------------------------------
    it "retrieves the path if the SrcSpan is in the tree" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = [mkTreeFromTokens toks]

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"
      (show $ ghcSpanStartEnd l) `shouldBe` "((19,1),(21,14))"

      let forest' = insertSrcSpan forest l
      (drawForestEntry forest') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,18))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n\n"

      (map treeStartEnd $ getPathFor forest' l) `shouldBe` [((1,1),(26,1)),((19,1),(21,14))]

  -- ---------------------------------------------

  describe "retrieveTokens" $ do
    it "extracts all the tokens from the leaves of the trees, in order" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = [mkTreeFromTokens toks]

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let forest' = insertSrcSpan forest l
      (drawForestEntry forest') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,18))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n\n"

      let toks' = retrieveTokens forest'
      (show toks') `shouldBe` (show toks)

  -- ---------------------------------------------

  describe "ghcLineToForestLine" $ do
    it "converts a GHC line to a ForestLine" $ do
      (ghcLineToForestLine 34) `shouldBe` ForestLine 0 34
      (ghcLineToForestLine   1000034) `shouldBe` ForestLine 1 34
      (ghcLineToForestLine 530000034) `shouldBe` ForestLine 530 34

  describe "forestLineToGhcLine" $ do
    it "converts a ForestLine value to a GHC line" $ do
      (forestLineToGhcLine $ ForestLine   0 34) `shouldBe`        34
      (forestLineToGhcLine $ ForestLine   1 34) `shouldBe`   1000034
      (forestLineToGhcLine $ ForestLine 530 34) `shouldBe` 530000034

  -- ---------------------------------------------

  describe "ForestLine Ord" $ do
    it "implements Ord for ForestLine" $ do
      compare (ForestLine 0 1) (ForestLine 0 3) `shouldBe` LT
      compare (ForestLine 0 3) (ForestLine 1 3) `shouldBe` LT
      compare (ForestLine 1 1) (ForestLine 2 3) `shouldBe` LT
      compare (ForestLine 9 3) (ForestLine 0 4) `shouldBe` LT

      compare (ForestLine 7 3) (ForestLine 7 3) `shouldBe` EQ

      compare (ForestLine 0 4) (ForestLine 0 3) `shouldBe` GT

  -- ---------------------------------------------

  describe "addNewSrcSpanAndToks" $ do
    it "Adds a new SrcSpan after an existing one in the forest." $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = [mkTreeFromTokens toks]

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (forest',tree) = getSrcSpanFor forest l

      let toks' = retrieveTokens [tree]
      let (forest'',sspan) = addNewSrcSpanAndToks forest' l l toks'
      (invariant forest'') `shouldBe` []
      (drawForestEntry forest'') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,18))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++ 
              "+- ((1000019,1),(21,14))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n\n"
      (showSrcSpan sspan) `shouldBe` ""

      let toksFinal = retrieveTokens forest''
      (GHC.showRichTokenStream toksFinal) `shouldBe` ""

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
      (showTree tree)  `shouldBe` "Node (Entry ((1,1),(26,1)) [(((1,1),(1,7)),ITmodule,\"module\")]..[(((26,1),(26,1)),ITsemi,\"\")]) []"
      (showTree tree2) `shouldBe` "Node (Entry ((1,8),(26,1)) [(((1,8),(1,17)),ITconid \"TokenTest\",\"TokenTest\")]..[(((26,1),(26,1)),ITsemi,\"\")]) []"
      (showTree tree3) `shouldBe` "Node (Entry ((1,1),(5,11)) [(((1,1),(1,7)),ITmodule,\"module\")]..[(((5,11),(5,12)),ITvarid \"x\",\"x\")]) []"

      (invariant [Node (Entry sspan []) [tree2]]) `shouldBe` ["FAIL: subForest start and end does not match entry: Node (Entry ((1,1),(26,1)) []) [\"Node (Entry ((1,8),(26,1)) [(((1,8),(1,17)),ITconid \\\"TokenTest\\\",\\\"TokenTest\\\")]..[(((26,1),(26,1)),ITsemi,\\\"\\\")]) []\"]"]
      (invariant [Node (Entry sspan []) [tree3]]) `shouldBe` ["FAIL: subForest start and end does not match entry: Node (Entry ((1,1),(26,1)) []) [\"Node (Entry ((1,1),(5,11)) [(((1,1),(1,7)),ITmodule,\\\"module\\\")]..[(((5,11),(5,12)),ITvarid \\\"x\\\",\\\"x\\\")]) []\"]"]

      (invariant [Node (Entry sspan []) [tree3,tree4]]) `shouldBe` []

    it "checks that a the subree is in span order" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let (Node (Entry sspan _) _) = mkTreeFromTokens toks
      let tree1 = mkTreeFromTokens (take 10 toks)
      let tree2 = mkTreeFromTokens (take 10 $ drop 10 toks)
      let tree3 = mkTreeFromTokens (take 10 $ drop 20 toks)
      let tree4 = mkTreeFromTokens (drop 30 toks)

      (show $ treeStartEnd tree1) `shouldBe` "((1,1),(5,11))"
      (show $ treeStartEnd tree2) `shouldBe` "((6,3),(8,7))"
      (show $ treeStartEnd tree3) `shouldBe` "((8,9),(13,1))"
      (show $ treeStartEnd tree4) `shouldBe` "((13,5),(26,1))"

      (invariant [Node (Entry sspan []) [tree1,tree2,tree3,tree4]]) `shouldBe` []
      (invariant [Node (Entry sspan []) [tree1,tree3,tree2,tree4]]) `shouldBe` ["FAIL: subForest not in order: (13,1) not < (6,3):Node (Entry ((1,1),(26,1)) []) [\"Node (Entry ((1,1),(5,11)) [(((1,1),(1,7)),ITmodule,\\\"module\\\")]..[(((5,11),(5,12)),ITvarid \\\"x\\\",\\\"x\\\")]) []\",\"Node (Entry ((8,9),(13,1)) [(((8,9),(8,10)),ITequal,\\\"=\\\")]..[(((13,1),(13,4)),ITvarid \\\"bab\\\",\\\"bab\\\")]) []\",\"Node (Entry ((6,3),(8,7)) [(((6,3),(6,8)),ITwhere,\\\"where\\\")]..[(((8,7),(8,8)),ITvarid \\\"b\\\",\\\"b\\\")]) []\",\"Node (Entry ((13,5),(26,1)) [(((13,5),(13,6)),ITvarid \\\"a\\\",\\\"a\\\")]..[(((26,1),(26,1)),ITsemi,\\\"\\\")]) []\"]"]

  -- ---------------------------------------------

  describe "invariant 3" $ do
    it "checks that the forest is in order, hence no overlaps" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let tree1 = mkTreeFromTokens (take 10 toks)
      let tree2 = mkTreeFromTokens (take 10 $ drop 10 toks)
      let tree3 = mkTreeFromTokens (take 10 $ drop 20 toks)
      let tree4 = mkTreeFromTokens (drop 30 toks)

      (show $ treeStartEnd tree1) `shouldBe` "((1,1),(5,11))"
      (show $ treeStartEnd tree2) `shouldBe` "((6,3),(8,7))"
      (show $ treeStartEnd tree3) `shouldBe` "((8,9),(13,1))"
      (show $ treeStartEnd tree4) `shouldBe` "((13,5),(26,1))"

      (invariant [tree1,tree2,tree3,tree4]) `shouldBe` []
      (invariant [tree1,tree3,tree2,tree4]) `shouldBe` ["FAIL: forest not in order: (13,1) not < (6,3)"]

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
      (show tree) `shouldBe` "Node {rootLabel = Entry (RealSrcSpan (SrcSpanOneLine {srcSpanFile = \"./test/testdata/TokenTest.hs\", srcSpanLine = 5, srcSpanSCol = 1, srcSpanECol = 5})) [((((5,1),(5,4)),ITvarid \"bob\"),\"bob\"),((((5,5),(5,6)),ITvarid \"a\"),\"a\")], subForest = []}"


-- ---------------------------------------------------------------------
-- Helper functions

emptyTree :: Tree Entry
emptyTree = Node (Entry GHC.noSrcSpan []) []


-- ---------------------------------------------------------------------

tokenTestFileName :: GHC.FastString
tokenTestFileName = GHC.mkFastString "./test/testdata/TokenTest.hs"

parsedFileTokenTestGhc :: IO (ParseResult,[PosToken])
parsedFileTokenTestGhc = parsedFileGhc "./test/testdata/TokenTest.hs"

