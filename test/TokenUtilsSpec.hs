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

import qualified GHC.SYB.Utils as SYB

import Control.Monad.State
import Data.Maybe
import Data.Tree
import Exception

import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

import qualified Data.Tree.Zipper as Z
import qualified Data.Map as Map

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

  describe "getTokensFor" $ do
    it "gets the tokens for a given srcloc, and caches them in the tree" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls

      let forest = mkTreeFromTokens toks
      let (tm',declToks) = getTokensFor forest l

      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"
      (GHC.showPpr decl) `shouldBe` "TokenTest.foo x y\n  = do { c <- System.IO.getChar;\n         GHC.Base.return c }"
      (showToks declToks) `shouldBe` "[(((18,1),(18,19)),ITlineComment \"-- leading comment\",\"-- leading comment\"),(((19,1),(19,1)),ITsemi,\"\"),(((19,1),(19,4)),ITvarid \"foo\",\"foo\"),(((19,5),(19,6)),ITvarid \"x\",\"x\"),(((19,7),(19,8)),ITvarid \"y\",\"y\"),(((19,9),(19,10)),ITequal,\"=\"),(((20,3),(20,5)),ITdo,\"do\"),(((20,6),(20,6)),ITvocurly,\"\"),(((20,6),(20,7)),ITvarid \"c\",\"c\"),(((20,8),(20,10)),ITlarrow,\"<-\"),(((20,11),(20,18)),ITvarid \"getChar\",\"getChar\"),(((21,6),(21,6)),ITsemi,\"\"),(((21,6),(21,12)),ITvarid \"return\",\"return\"),(((21,13),(21,14)),ITvarid \"c\",\"c\")]"

      -- Note: Although the tokens include leading and following
      -- comments, the SrcSpan must tie up with the original GHC
      -- SrcSpan in the AST
      (drawTreeEntry tm') `shouldBe`
            "((1,1),(26,1))\n|\n"++
            "+- ((1,1),(15,17))\n|\n"++
            "+- ((19,1),(21,14))\n|\n"++
            "`- ((26,1),(26,1))\n"

    -- ---------------------------------

    it "gets the tokens for an added srcloc 1" $ do
      (t,toks) <- parsedFileDupDefDd1
      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head $ drop 6 decls

      let forest = mkTreeFromTokens toks
      let (tm',declToks) = getTokensFor forest l

      (GHC.showPpr l) `shouldBe` "test/testdata/DupDef/Dd1.hs:4:1-18"
      (showSrcSpan l) `shouldBe` "((4,1),(4,19))"
      (GHC.showPpr decl) `shouldBe` "DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x"
      (showToks declToks) `shouldBe` "[(((4,1),(4,1)),ITsemi,\"\"),(((4,1),(4,9)),ITvarid \"toplevel\",\"toplevel\"),(((4,10),(4,11)),ITvarid \"x\",\"x\"),(((4,12),(4,13)),ITequal,\"=\"),(((4,14),(4,15)),ITvarid \"c\",\"c\"),(((4,16),(4,17)),ITstar,\"*\"),(((4,18),(4,19)),ITvarid \"x\",\"x\")]"

      let (tm'',newSpan,decl') = addDeclToksAfterSrcSpan tm' l (PlaceOffset 2 0 2) declToks decl
      (GHC.showPpr newSpan) `shouldBe` "test/testdata/DupDef/Dd1.hs:1000006:1-18"

      (SYB.showData SYB.Renamer 0 decl') `shouldBe` "\n(L {test/testdata/DupDef/Dd1.hs:1000006:1-18} \n (FunBind \n  (L {test/testdata/DupDef/Dd1.hs:6:1-8} {Name: DupDef.Dd1.toplevel}) \n  (False) \n  (MatchGroup \n   [\n    (L {test/testdata/DupDef/Dd1.hs:4:1-18} \n     (Match \n      [\n       (L {test/testdata/DupDef/Dd1.hs:1000006:10} \n        (VarPat {Name: x}))] \n      (Nothing) \n      (GRHSs \n       [\n        (L {test/testdata/DupDef/Dd1.hs:4:14-18} \n         (GRHS \n          [] \n          (L {test/testdata/DupDef/Dd1.hs:1000006:14-18} \n           (OpApp \n            (L {test/testdata/DupDef/Dd1.hs:1000006:14} \n             (HsVar {Name: DupDef.Dd1.c})) \n            (L {test/testdata/DupDef/Dd1.hs:1000006:16} \n             (HsVar {Name: GHC.Num.*})) {Fixity: infixl 7} \n            (L {test/testdata/DupDef/Dd1.hs:1000006:18} \n             (HsVar {Name: x}))))))] \n       (EmptyLocalBinds))))] {!type placeholder here?!}) \n  (WpHole) {NameSet: \n  [{Name: DupDef.Dd1.c}]} \n  (Nothing)))"

      (drawTreeEntry tm'') `shouldBe`
            "((1,1),(34,1))\n|\n"++
            "+- ((1,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "+- ((1000006,1),(1000006,19))\n|\n"++
            "`- ((6,1),(34,1))\n"

    -- ---------------------------------

    it "gets the tokens for an added srcloc with one line spacing" $ do
      (t,toks) <- parsedFileDupDefDd1
      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let forest = mkTreeFromTokens toks

      let decl@(GHC.L l _) = head $ drop 6 decls
      let (tm',declToks) = getTokensFor forest l
      (drawTreeEntry tm') `shouldBe`
            "((1,1),(34,1))\n|\n"++
            "+- ((1,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "`- ((6,1),(34,1))\n"

      (GHC.showPpr l) `shouldBe` "test/testdata/DupDef/Dd1.hs:4:1-18"
      (showSrcSpan l) `shouldBe` "((4,1),(4,19))"
      (GHC.showPpr decl) `shouldBe` "DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x"
      (showToks declToks) `shouldBe` "[(((4,1),(4,1)),ITsemi,\"\"),(((4,1),(4,9)),ITvarid \"toplevel\",\"toplevel\"),(((4,10),(4,11)),ITvarid \"x\",\"x\"),(((4,12),(4,13)),ITequal,\"=\"),(((4,14),(4,15)),ITvarid \"c\",\"c\"),(((4,16),(4,17)),ITstar,\"*\"),(((4,18),(4,19)),ITvarid \"x\",\"x\")]"

      let Just (GHC.L _ n) = locToName dupDefDd1FileName (4, 2) renamed
      let typeSig = head $ definingSigsNames [n] renamed
      let (GHC.L ln _) = typeSig
      (showSrcSpan ln) `shouldBe` "((3,1),(3,31))"
      let (tm'',sigToks) = getTokensFor tm' ln
      (drawTreeEntry tm'') `shouldBe`
            "((1,1),(34,1))\n|\n"++
            "+- ((1,1),(3,31))\n|  |\n"++
            "|  +- ((1,1),(1,24))\n|  |\n"++
            "|  `- ((3,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "`- ((6,1),(34,1))\n"

      let (tm''',newSpan,typeSig') = addDeclToksAfterSrcSpan tm'' l (PlaceOffset 2 0 0) sigToks typeSig
      (GHC.showPpr newSpan) `shouldBe` "test/testdata/DupDef/Dd1.hs:1000006:1-30"

      (SYB.showData SYB.Renamer 0 typeSig') `shouldBe` "\n(L {test/testdata/DupDef/Dd1.hs:1000006:1-30} \n (TypeSig \n  [\n   (L {test/testdata/DupDef/Dd1.hs:6:1-8} {Name: DupDef.Dd1.toplevel})] \n  (L {test/testdata/DupDef/Dd1.hs:1000006:13-30} \n   (HsFunTy \n    (L {test/testdata/DupDef/Dd1.hs:1000006:13-19} \n     (HsTyVar {Name: GHC.Integer.Type.Integer})) \n    (L {test/testdata/DupDef/Dd1.hs:1000006:24-30} \n     (HsTyVar {Name: GHC.Integer.Type.Integer}))))))"

      (drawTreeEntry tm''') `shouldBe`
            "((1,1),(34,1))\n|\n"++
            "+- ((1,1),(3,31))\n|  |\n"++
            "|  +- ((1,1),(1,24))\n|  |\n"++
            "|  `- ((3,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "+- ((1000006,1),(1000006,31))\n|\n"++
            "`- ((6,1),(34,1))\n"
      -- -- -- -- --
      {-
      let (ff,tt) = getSrcSpanFor tm''' (fs newSpan)
          z = openZipperToSpan (fs newSpan) $ Z.fromTree ff
          prevToks = retrievePrevLineToks z

          (_,(ForestLine _ endRow,_))       = srcSpanToForestSpan newSpan
          prevToks' = reverse $ dropWhile (\t -> tokenRow t > endRow) $ reverse  prevToks

      (GHC.showRichTokenStream prevToks') `shouldBe` ""
      (show prevToks') `shouldBe` ""
      -}
      -- --- -- --
      let (tm'''',_newSpan',decl') = addDeclToksAfterSrcSpan tm''' newSpan (PlaceOffset 1 0 2) declToks decl
      -- (GHC.showPpr newSpan') `shouldBe` "test/testdata/DupDef/Dd1.hs:1000006:1-30"

      (drawTreeEntry tm'''') `shouldBe`
            "((1,1),(34,1))\n|\n"++
            "+- ((1,1),(3,31))\n|  |\n"++
            "|  +- ((1,1),(1,24))\n|  |\n"++
            "|  `- ((3,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "+- ((1000006,1),(1000006,31))\n|\n"++
            "+- ((1000007,1),(1000007,19))\n|\n"++
            "`- ((6,1),(34,1))\n"

    -- ---------------------------------

    it "gets the tokens for an added indented srcloc" $ do
      (t,toks) <- parsedFileDupDefDd1
      let renamed = fromJust $ GHC.tm_renamed_source t
      let forest = mkTreeFromTokens toks

      let Just (GHC.L _ n) = locToName dupDefDd1FileName (23, 5) renamed
      (GHC.showPpr n) `shouldBe` "zz"

      let sspan = posToSrcSpan forest ((23,5),(23,11))
      (GHC.showPpr sspan) `shouldBe` "test/testdata/DupDef/Dd1.hs:23:5-10"

      let (tm1,declToks) = getTokensFor forest sspan
      (GHC.showRichTokenStream declToks) `shouldBe` "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n     zz = 1"
      (drawTreeEntry tm1) `shouldBe`
           "((1,1),(34,1))\n|\n"++
           "+- ((1,1),(22,8))\n|\n"++
           "+- ((23,5),(23,11))\n|\n"++
           "`- ((25,1),(34,1))\n"

      let (tm2,newSpan) = addToksAfterSrcSpan tm1 sspan (PlaceIndent 1 0 1) declToks
      (GHC.showPpr newSpan) `shouldBe` "test/testdata/DupDef/Dd1.hs:1000024:5-10"
      (drawTreeEntry tm2) `shouldBe`
           "((1,1),(34,1))\n|\n"++
           "+- ((1,1),(22,8))\n|\n"++
           "+- ((23,5),(23,11))\n|\n"++
           "+- ((1000024,5),(1000024,11))\n|\n"++
           "`- ((25,1),(34,1))\n"

  -- ---------------------------------------------

  describe "getTokensBefore" $ do
    it "gets the tokens before a given srcloc" $ do
      (t,toks) <- parsedFileMoveDefMd1
      let renamed = fromJust $ GHC.tm_renamed_source t
      -- let decls = hsBinds renamed

      let forest = mkTreeFromTokens toks

      let sspan = posToSrcSpan forest ((24,5),(24,11))

      let (tm',toksSpan) = getTokensFor forest sspan

      (GHC.showPpr sspan) `shouldBe` "test/testdata/MoveDef/Md1.hs:24:5-10"
      (showSrcSpan sspan) `shouldBe` "((24,5),(24,11))"
      (showToks toksSpan) `shouldBe` "[(((24,5),(24,5)),ITvocurly,\"\"),(((24,5),(24,7)),ITvarid \"zz\",\"zz\"),(((24,8),(24,9)),ITequal,\"=\"),(((24,10),(24,11)),ITinteger 1,\"1\")]"


      (drawTreeEntry tm') `shouldBe`
            "((1,1),(40,17))\n|\n"++
            "+- ((1,1),(23,8))\n|\n"++
            "+- ((24,5),(24,11))\n|\n"++
            "`- ((26,1),(40,17))\n"

      let (tm'',toksBefore) = getTokensBefore tm' sspan
      (showToks $ drop 100 toksBefore) `shouldBe` "[(((22,10),(22,11)),ITvarsym \"+\",\"+\"),(((22,12),(22,14)),ITvarid \"zz\",\"zz\"),(((23,3),(23,8)),ITwhere,\"where\")]"

      (drawTreeEntry tm'') `shouldBe`
            "((1,1),(40,17))\n|\n"++
            "+- ((1,1),(23,8))\n|\n"++
            "+- ((24,5),(24,11))\n|\n"++
            "`- ((26,1),(40,17))\n"

  -- ---------------------------------------------

  describe "getSrcSpanFor" $ do
    it "inserts a SrcSpan if it was not in the forest" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      let forest = mkTreeFromTokens toks

      let (forest',tree) = getSrcSpanFor forest (fs l)

      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"
      (showForestSpan (fs l)) `shouldBe` "((19,1),(21,14))"
      (drawTreeEntry forest') `shouldBe`
            "((1,1),(26,1))\n|\n"++
            "+- ((1,1),(15,17))\n|\n"++
            "+- ((19,1),(21,14))\n|\n"++
            "`- ((26,1),(26,1))\n"

      (showForestSpan $ treeStartEnd tree) `shouldBe` "((19,1),(21,14))"

  -- ---------------------------------------------
{-
  describe "lookupSrcSpan" $ do
    it "looks up a SrcSpan that is fully enclosed in the forest" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let tree1 = mkTreeFromTokens (take 10 toks)
      let tree2 = mkTreeFromTokens (take 10 $ drop 10 toks)
      let tree3 = mkTreeFromTokens (take 10 $ drop 20 toks)
      let tree4 = mkTreeFromTokens (drop 30 toks)
      let forest = mkTreeFromSubTrees [tree1,tree2,tree3,tree4]
      (invariant forest) `shouldBe` []

      (showForestSpan $ treeStartEnd tree1) `shouldBe` "((1,1),(5,12))"
      (showForestSpan $ treeStartEnd tree2) `shouldBe` "((6,3),(8,8))"
      (showForestSpan $ treeStartEnd tree3) `shouldBe` "((8,9),(13,4))"
      (showForestSpan $ treeStartEnd tree4) `shouldBe` "((13,5),(26,1))"

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let r = lookupSrcSpan [forest] (fs l)
      (map showTree r) `shouldBe` ["Node (Entry ((13,5),(26,1)) [(((13,5),(13,6)),ITvarid \"a\",\"a\")]..[(((26,1),(26,1)),ITsemi,\"\")]) []"]

    -- -----------------------
    it "looks up a SrcSpan that spans two trees in the forest" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let tree1 = mkTreeFromTokens (take 20 toks)
      let tree2 = mkTreeFromTokens (take 10 $ drop 20 toks)
      let tree3 = mkTreeFromTokens (take 20 $ drop 30 toks)
      let tree4 = mkTreeFromTokens (drop 50 toks)
      let forest = mkTreeFromSubTrees [tree1,tree2,tree3,tree4]
      (invariant forest) `shouldBe` []

      (showForestSpan $ treeStartEnd tree1) `shouldBe` "((1,1),(8,8))"
      (showForestSpan $ treeStartEnd tree2) `shouldBe` "((8,9),(13,4))"
      (showForestSpan $ treeStartEnd tree3) `shouldBe` "((13,5),(19,10))"
      (showForestSpan $ treeStartEnd tree4) `shouldBe` "((20,3),(26,1))"

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let r = lookupSrcSpan [forest] (fs l)
      (map showForestSpan $ map treeStartEnd r) `shouldBe`
           ["((13,5),(19,10))","((20,3),(26,1))"]

    -- -----------------------
    it "looks up a SrcSpan that spans four trees in the forest" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let tree1 = mkTreeFromTokens (take 48 toks)
      let tree2 = mkTreeFromTokens (take  5 $ drop 48 toks)
      let tree3 = mkTreeFromTokens (take  3 $ drop 53 toks)
      let tree4 = mkTreeFromTokens (drop 56 toks)
      (showForestSpan $ treeStartEnd tree1) `shouldBe` "((1,1),(19,6))"
      (showForestSpan $ treeStartEnd tree2) `shouldBe` "((19,7),(20,7))"
      (showForestSpan $ treeStartEnd tree3) `shouldBe` "((20,8),(20,18))"
      (showForestSpan $ treeStartEnd tree4) `shouldBe` "((21,6),(26,1))"
      let forest = mkTreeFromSubTrees [tree1,tree2,tree3,tree4]
      (invariant forest) `shouldBe` []

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let r = lookupSrcSpan [forest] (fs l)
      (map showForestSpan $ map treeStartEnd r) `shouldBe`
               ["((1,1),(19,6))",
               "((19,7),(20,7))",
               "((20,8),(20,18))",
               "((21,6),(26,1))"]

    -- -----------------------
    it "looks up a SrcSpan that is in a subtree of the forest" $ do
      (t,toks) <- parsedFileTokenTestGhc

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls

      let forest = insertSrcSpan (mkTreeFromTokens toks) (fs l)

      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      (drawTreeEntry forest) `shouldBe`
            "((1,1),(26,1))\n|\n"++
            "+- ((1,1),(15,17))\n|\n"++
            "+- ((19,1),(21,14))\n|\n"++
            "`- ((26,1),(26,1))\n"

      let [r] = lookupSrcSpan [forest] (fs l)
      -- (show $ map treeStartEnd r) `shouldBe` "[((19,1),(21,14))]"
      (showForestSpan $ treeStartEnd r) `shouldBe` "((19,1),(21,14))"

    -- -----------------------

    it "looks up a SrcSpan with no gap before prior one" $ do
      (t, toks) <- parsedFileGhc "./test/testdata/DupDef/Dd3.hs"

      let forest = mkTreeFromTokens toks

      let (GHC.L l _,_) = head $ drop 9 toks

      (GHC.showPpr l) `shouldBe` "test/testdata/DupDef/Dd3.hs:3:29"
      (showSrcSpan l) `shouldBe` "((3,29),(3,30))"

      let forest' = insertSrcSpan forest (fs l)
      (invariant forest') `shouldBe` []
      (drawTreeEntry forest') `shouldBe`
          "((1,1),(8,7))\n|\n"++
          "+- ((1,1),(3,29))\n|\n"++
          "+- ((3,29),(3,30))\n|\n"++
          "`- ((6,1),(8,7))\n"

      let subtrees = lookupSrcSpan [forest'] (fs l)
      (map showForestSpan $ map treeStartEnd subtrees)
           `shouldBe` ["((3,29),(3,30))"]

-}
  -- ---------------------------------------------

  describe "splitForestOnSpan" $ do
    it "splits a forest into (begin,middle,end) according to a span" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let tree1 = mkTreeFromTokens (take 20 toks)
      let tree2 = mkTreeFromTokens (take 10 $ drop 20 toks)
      let tree3 = mkTreeFromTokens (take 15 $ drop 30 toks)
      let tree4 = mkTreeFromTokens (drop 45 toks)
      let forest = mkTreeFromSubTrees [tree1,tree2,tree3,tree4]
      (invariant forest) `shouldBe` []

      (showForestSpan $ treeStartEnd tree1) `shouldBe` "((1,1),(8,8))"
      (showForestSpan $ treeStartEnd tree2) `shouldBe` "((8,9),(13,4))"
      (showForestSpan $ treeStartEnd tree3) `shouldBe` "((13,5),(15,17))"
      (showForestSpan $ treeStartEnd tree4) `shouldBe` "((19,1),(26,1))"

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (begin,middle,end) = splitForestOnSpan (subForest forest) (fs l)
      (map showForestSpan $ map treeStartEnd begin) `shouldBe`
             ["((1,1),(8,8))","((8,9),(13,4))","((13,5),(15,17))"]
      (map showForestSpan $ map treeStartEnd middle) `shouldBe` ["((19,1),(26,1))"]
      (show $ map treeStartEnd end) `shouldBe` "[]"

  -- ---------------------------------------------

  describe "insertSrcSpan" $ do
    it "checks that the forest is split into two parts" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      --
      let z = openZipperToSpan (fs l) $ Z.fromTree forest
      let toksz = retrieveTokens $ Z.tree z
      let (tokStartPos,tokEndPos) = forestSpanToSimpPos (fs l)
      (show (tokStartPos,tokEndPos)) `shouldBe` "((19,1),(21,14))"

      -- (show toksz) `shouldBe` ""
      let (_begin,middle,end) = splitToks (tokStartPos,tokEndPos) toksz
      (show middle) `shouldBe` "[((((19,1),(19,1)),ITsemi),\"\"),((((19,1),(19,4)),ITvarid \"foo\"),\"foo\"),((((19,5),(19,6)),ITvarid \"x\"),\"x\"),((((19,7),(19,8)),ITvarid \"y\"),\"y\"),((((19,9),(19,10)),ITequal),\"=\"),((((20,3),(20,5)),ITdo),\"do\"),((((20,6),(20,6)),ITvocurly),\"\"),((((20,6),(20,7)),ITvarid \"c\"),\"c\"),((((20,8),(20,10)),ITlarrow),\"<-\"),((((20,11),(20,18)),ITvarid \"getChar\"),\"getChar\"),((((21,6),(21,6)),ITsemi),\"\"),((((21,6),(21,12)),ITvarid \"return\"),\"return\"),((((21,13),(21,14)),ITvarid \"c\"),\"c\")]"

      let (startLoc,endLoc) = startEndLocIncComments' toksz (tokStartPos,tokEndPos)
      (show (startLoc,endLoc)) `shouldBe` "((18,1),(21,14))"

      --

      let forest' = insertSrcSpan forest (fs l)
      (invariant forest') `shouldBe` []
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n"

    -- -----------------------

    it "inserts a span above others, if it spans them" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let forest' = insertSrcSpan forest (fs l)
      (invariant forest') `shouldBe` []
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n"

      let l' = posToSrcSpan forest' ((13,1),(21,14))
      (GHC.showPpr l') `shouldBe` "test/testdata/TokenTest.hs:(13,1)-(21,13)"
      (showSrcSpan l') `shouldBe` "((13,1),(21,14))"

      let forest'' = insertSrcSpan forest' (fs l')
      (invariant forest'') `shouldBe` []
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(10,10))\n|\n"++
              "+- ((13,1),(21,14))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n"

    it "does not delete existing versioned spans" $ do
      (_t,toks) <- parsedFileDemoteD1
      let forest = mkTreeFromTokens toks

      let sspan = posToSrcSpan forest ((6,21),(6,41))
      (GHC.showPpr sspan) `shouldBe` "test/testdata/Demote/D1.hs:6:21-40"
      (showSrcSpan sspan) `shouldBe` "((6,21),(6,41))"

      let forest1 = insertSrcSpan forest (fs sspan)

      declToks <- liftIO $ tokenise (realSrcLocFromTok mkZeroToken) 0 True "where\n  sq = x ^ pow\n"
      -- putToksAfterPos ((6,21),(6,41)) at PlaceIndent 1 4 2
      let (forest2,_newSpan) = addToksAfterSrcSpan forest1 sspan (PlaceIndent 1 4 2) declToks

      (invariant forest2) `shouldBe` []
      (drawTreeEntry forest2) `shouldBe`
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(6,20))\n|\n"++
               "+- ((6,21),(6,41))\n|\n"++
               "+- ((1000007,5),(1000009,6))\n|\n"++
               "`- ((7,1),(13,25))\n"

      -- Context set up, now for the test.

      let sspan2 = posToSrcSpan forest ((9,1),(9,14))
      (GHC.showPpr sspan2) `shouldBe` "test/testdata/Demote/D1.hs:9:1-13"

      let z = openZipperToSpan (fs sspan2) $ Z.fromTree forest2
      (drawTreeEntry $ Z.tree z) `shouldBe` "((7,1),(13,25))\n"
      -- (show $ treeStartEnd (Z.tree z)) `shouldBe` "((ForestLine {flInsertVersion = 0, flLine = 1},1),(ForestLine {flInsertVersion = 0, flLine = 13},25))"
      -- (show (Z.firstChild z)) `shouldBe` ""
      -- (show $ Z.next $ fromJust $ (Z.firstChild z)) `shouldBe` ""
 {-
      let childrenAsZ = go [] (Z.firstChild z)
           where
            go acc Nothing = acc
            go acc (Just zz) = go (acc ++ [zz]) (Z.next zz)

      (show $ map treeStartEnd $ map Z.tree childrenAsZ) `shouldBe`
           "[((ForestLine {flInsertVersion = 0, flLine = 1},1),(ForestLine {flInsertVersion = 0, flLine = 6},20)),"++
            "((ForestLine {flInsertVersion = 0, flLine = 6},21),(ForestLine {flInsertVersion = 0, flLine = 6},41)),"++
            "((ForestLine {flInsertVersion = 1, flLine = 7},5),(ForestLine {flInsertVersion = 1, flLine = 11},1)),"++
            "((ForestLine {flInsertVersion = 0, flLine = 7},1),(ForestLine {flInsertVersion = 0, flLine = 13},25))]"


      let xx = filter contains childrenAsZ
           where
             contains zn = (startPos <= nodeStart && endPos >= nodeEnd)
               where
                 (startPos,endPos) = treeStartEnd $ Z.tree zn
                 (nodeStart,nodeEnd) = (fs sspan2)

      -- (show xx) `shouldBe` ""

      let xx' = filter (\zt -> (treeStartEnd $ Z.tree zt) == (fs sspan2)) xx

      -- (show xx') `shouldBe` ""
-}


      (drawTreeEntry $ insertSrcSpan forest2 (fs sspan2)) `shouldBe`
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(6,20))\n|\n"++
               "+- ((6,21),(6,41))\n|\n"++
               "+- ((1000007,5),(1000009,6))\n|\n"++
               "`- ((7,1),(13,25))\n   |\n"++
               "   +- ((7,1),(7,18))\n   |\n"++
               "   +- ((9,1),(9,14))\n   |\n"++
               "   `- ((11,1),(13,25))\n"

  -- ---------------------------------------------

  describe "removeSrcSpan" $ do
    it "removes a span from the forest" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let forest' = insertSrcSpan forest (fs l)
      (invariant forest') `shouldBe` []
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n"

      let (forest'',delTree) = removeSrcSpan forest' (fs l)
      (invariant forest'') `shouldBe` []
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              -- "+- ((19,1),(21,14))\n|\n"++ -- removed again
              "`- ((26,1),(26,1))\n"

      (drawTreeEntry delTree) `shouldBe`
              "((19,1),(21,14))\n" -- removed again

      let toks' = retrieveTokens forest''
      -- (showToks toks') `shouldBe` ""
      (GHC.showRichTokenStream toks') `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n\n\n\n\n\n\n\n\n "

    -- ---------------------------------
    it "removes a span and tokens that were not explicitly in the forest" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head $ drop 1 decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(13,1)-(15,16)"
      (showSrcSpan l) `shouldBe` "((13,1),(15,17))"

      let (forest',delTree) = removeSrcSpan forest (fs l)
      (invariant forest') `shouldBe` []
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(10,10))\n|\n"++
              "`- ((19,1),(26,1))\n"

      (drawTreeEntry delTree) `shouldBe`
              "((13,1),(15,17))\n" -- removed again

      let toks' = retrieveTokens forest'
      -- (showToks toks') `shouldBe` ""
      (GHC.showRichTokenStream toks') `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n\n\n\n\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n\n\n\n "

    -- ---------------------------------

    it "Removes a span and tokens without destroying the forest 1" $ do
      (_t,toks) <- parsedFileDemoteD1
      let forest = mkTreeFromTokens toks

      let sspan = posToSrcSpan forest ((6,21),(6,41))
      (GHC.showPpr sspan) `shouldBe` "test/testdata/Demote/D1.hs:6:21-40"
      (showSrcSpan sspan) `shouldBe` "((6,21),(6,41))"

      let forest1 = insertSrcSpan forest (fs sspan)

      declToks <- liftIO $ tokenise (realSrcLocFromTok mkZeroToken) 0 True "where\n  sq = x ^ pow\n"
      -- putToksAfterPos ((6,21),(6,41)) at PlaceIndent 1 4 2
      let (forest2,_newSpan) = addToksAfterSrcSpan forest1 sspan (PlaceIndent 1 4 2) declToks

      (invariant forest2) `shouldBe` []
      (drawTreeEntry forest2) `shouldBe`
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(6,20))\n|\n"++
               "+- ((6,21),(6,41))\n|\n"++
               "+- ((1000007,5),(1000009,6))\n|\n"++
               "`- ((7,1),(13,25))\n"
      -- Context set up, now for the test.

      let sspan2 = posToSrcSpan forest ((9,1),(9,14))
      (GHC.showPpr sspan2) `shouldBe` "test/testdata/Demote/D1.hs:9:1-13"
      let (forest3,delTree) = removeSrcSpan forest2 (fs sspan2)

      (drawTreeEntry $ insertSrcSpan forest2 (fs sspan2)) `shouldBe`
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(6,20))\n|\n"++
               "+- ((6,21),(6,41))\n|\n"++
               "+- ((1000007,5),(1000009,6))\n|\n"++
               "`- ((7,1),(13,25))\n   |\n"++
               "   +- ((7,1),(7,18))\n   |\n"++
               "   +- ((9,1),(9,14))\n   |\n"++
               "   `- ((11,1),(13,25))\n"

      (drawTreeEntry delTree) `shouldBe`
              "((9,1),(9,14))\n" -- removed again


      (invariant forest3) `shouldBe` []
      (drawTreeEntry forest3) `shouldBe`
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(6,20))\n|\n"++
               "+- ((6,21),(6,41))\n|\n"++
               "+- ((1000007,5),(1000009,6))\n|\n"++
               "`- ((7,1),(13,25))\n   |\n"++
               "   +- ((7,1),(7,18))\n   |\n"++
               "   `- ((11,1),(13,25))\n"

      let toks' = retrieveTokens forest3
      -- (showToks toks') `shouldBe` ""
      (GHC.showRichTokenStream toks') `shouldBe` "module Demote.D1 where\n\n {-demote 'sq' to 'sumSquares'. This refactoring\n  affects module 'D1' and 'C1' -}\n\n sumSquares (x:xs) = sq x + sumSquares xs\n     where\n        sq = x ^ pow\n      \n\n \n\n  sumSquares [] = 0\n\n\n\n pow = 2\n\n main = sumSquares [1..4]\n\n "

    -- ---------------------------------

    it "Removes a span and tokens without destroying the forest 2" $ do
      (_t,toks) <- parsedFileGhc "./test/testdata/Demote/WhereIn6.hs"
      let forest = mkTreeFromTokens toks
      let tk = initTokenCache toks

      -- removeToksForPos ((13,1),(13,21))
      let sspan = posToSrcSpan forest ((13,1),(13,21))
      (GHC.showPpr sspan) `shouldBe` "test/testdata/Demote/WhereIn6.hs:13:1-20"

      let tk2 = removeToksFromCache tk sspan
      (drawTokenCache tk2) `shouldBe`
               "tree TId 0:\n"++
               "((1,1),(13,21))\n|\n"++
               "`- ((1,1),(11,25))\n"++
               "tree TId 1:\n"++
               "((100000013,1),(100000013,21))\n"


      -- putToksForSpan test/testdata/Demote/WhereIn6.hs:100000013:16:[((((0,1),(0,2)),ITvarid "x"),"x")]
      let ss2 = posToSrcSpan forest ((100000013,16),(100000013,17))
      (GHC.showPpr ss2) `shouldBe` "test/testdata/Demote/WhereIn6.hs:100000013:16"
      toks2 <- basicTokenise "x"
      (show toks2) `shouldBe` "[((((0,1),(0,2)),ITvarid \"x\"),\"x\")]"
      let (tk3,_ss2') = putToksInCache tk2 ss2 toks2
      (drawTokenCache tk3) `shouldBe`
               "tree TId 0:\n"++
               "((1,1),(13,21))\n|\n"++
               "`- ((1,1),(11,25))\n"++
               "tree TId 1:\n"++
               "((100000013,1),(100000013,21))\n|\n"++
               "+- ((100000013,1),(100000013,16))\n|\n"++
               "+- ((100000013,16),(100000013,17))\n|\n"++
               "`- ((100000013,17),(100000013,21))\n"++
               "tree TId 2:\n"++
               "((200000013,16),(200000013,17))\n"

      (GHC.showRichTokenStream $ retrieveTokens $ getTreeFromCache ss2 tk3) `shouldBe` 
                "\n\n\n\n\n\n\n\n\n\n\n\n addthree a b c=x+b+c"

      -- putToksForSpan test/testdata/Demote/WhereIn6.hs:100000013:18:[((((0,1),(0,2)),ITvarid "y"),"y")]
      let ss3 = posToSrcSpan forest ((100000013,18),(100000013,19))
      (GHC.showPpr ss3) `shouldBe` "test/testdata/Demote/WhereIn6.hs:100000013:18"
      toks3 <- basicTokenise "y"
      (show toks3) `shouldBe` "[((((0,1),(0,2)),ITvarid \"y\"),\"y\")]"
      let (tk4,_ss3') = putToksInCache tk3 ss3 toks3
      (drawTokenCache tk4) `shouldBe`
               "tree TId 0:\n"++
               "((1,1),(13,21))\n|\n"++
               "`- ((1,1),(11,25))\n"++
               "tree TId 1:\n"++
               "((100000013,1),(100000013,21))\n|\n"++
               "+- ((100000013,1),(100000013,16))\n|\n"++
               "+- ((100000013,16),(100000013,17))\n|\n"++
               "`- ((100000013,17),(100000013,21))\n   |\n"++
               "   +- ((100000013,17),(100000013,18))\n   |\n"++
               "   +- ((100000013,18),(100000013,19))\n   |\n"++
               "   `- ((100000013,19),(100000013,21))\n"++
               "tree TId 2:\n"++
               "((200000013,16),(200000013,17))\n"++
               "tree TId 3:\n"++
               "((300000013,18),(300000013,19))\n"
      (GHC.showRichTokenStream $ retrieveTokens $ getTreeFromCache ss2 tk4) `shouldBe` 
                "\n\n\n\n\n\n\n\n\n\n\n\n addthree a b c=x+y+c"



      -- Context set up, now for the test.
{-
      let sspan2 = posToSrcSpan forest ((9,1),(9,14))
      (GHC.showPpr sspan2) `shouldBe` "test/testdata/Demote/D1.hs:9:1-13"
      let (forest3,delTree) = removeSrcSpan forest2 (fs sspan2)

      (drawTreeEntry $ insertSrcSpan forest2 (fs sspan2)) `shouldBe`
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(6,20))\n|\n"++
               "+- ((6,21),(6,41))\n|\n"++
               "+- ((1000007,5),(1000009,6))\n|\n"++
               "`- ((7,1),(13,25))\n   |\n"++
               "   +- ((7,1),(7,18))\n   |\n"++
               "   +- ((9,1),(9,14))\n   |\n"++
               "   `- ((11,1),(13,25))\n"

      (drawTreeEntry delTree) `shouldBe`
              "((9,1),(9,14))\n" -- removed again


      (invariant forest3) `shouldBe` []
      (drawTreeEntry forest3) `shouldBe`
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(6,20))\n|\n"++
               "+- ((6,21),(6,41))\n|\n"++
               "+- ((1000007,5),(1000009,6))\n|\n"++
               "`- ((7,1),(13,25))\n   |\n"++
               "   +- ((7,1),(7,18))\n   |\n"++
               "   `- ((11,1),(13,25))\n"

      let toks' = retrieveTokens forest3
      -- (showToks toks') `shouldBe` ""
      (GHC.showRichTokenStream toks') `shouldBe` "module Demote.D1 where\n\n {-demote 'sq' to 'sumSquares'. This refactoring\n  affects module 'D1' and 'C1' -}\n\n sumSquares (x:xs) = sq x + sumSquares xs\n     where\n        sq = x ^ pow\n      \n\n \n\n  sumSquares [] = 0\n\n\n\n pow = 2\n\n main = sumSquares [1..4]\n\n "
-}

  -- ---------------------------------------------

  describe "retrieveTokens" $ do
    it "extracts all the tokens from the leaves of the trees, in order" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let forest' = insertSrcSpan forest (fs l)
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n"

      let toks' = retrieveTokens forest'
      (show toks') `shouldBe` (show toks)

  -- ---------------------------------------------

  describe "updateTokensForSrcSpan" $ do
    it "replaces the tokens for a given span, inserting the span if needed" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"
      (GHC.showPpr decl) `shouldBe` "TokenTest.foo x y\n  = do { c <- System.IO.getChar;\n         GHC.Base.return c }"

      let (forest',newSpan,_) = updateTokensForSrcSpan forest l (take 3 toks)
      (GHC.showPpr newSpan) `shouldBe` "test/testdata/TokenTest.hs:18:1-22"
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((18,1),(18,23))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n" 

      let toks' = retrieveTokens forest'
      -- (showToks toks ) `shouldBe` ""
      -- (showToks toks') `shouldBe` ""
      (GHC.showRichTokenStream toks') `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n  module TokenTest where\n\n\n\n\n\n\n\n "

    -- --------------------------------------

    it "replaces the tokens for a given span, and returns all the tokens later" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let toks' = retrieveTokens tree
      let (forest'',sspan) = addNewSrcSpanAndToksAfter forest' l l (PlaceOffset 2 0 2) toks'

      (invariant forest'') `shouldBe` []
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++
              "+- ((1000019,1),(1000021,14))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n"
      (showSrcSpan sspan) `shouldBe` "((1000019,1),(1000021,14))"

      let Just (GHC.L ln n) = locToName tokenTestFileName (19, 1) renamed
      (GHC.showPpr n) `shouldBe` "TokenTest.foo"
      (GHC.showPpr ln) `shouldBe` "test/testdata/TokenTest.hs:19:1-3"

      let (_tree,toksForOp) = getTokensFor forest'' l

      let (GHC.L _ ghcTok,_) = head toks
      let newTok = mkToken ghcTok (19,1) "bbb"

      let newToks = replaceTokNoReAlign toksForOp (19,1) newTok
      (show newToks) `shouldBe`   "[((((18,1),(18,19)),ITlineComment \"-- leading comment\"),\"-- leading comment\"),((((19,1),(19,1)),ITsemi),\"\"),((((19,1),(19,4)),ITmodule),\"bbb\"),((((19,5),(19,6)),ITvarid \"x\"),\"x\"),((((19,7),(19,8)),ITvarid \"y\"),\"y\"),((((19,9),(19,10)),ITequal),\"=\"),((((20,3),(20,5)),ITdo),\"do\"),((((20,6),(20,6)),ITvocurly),\"\"),((((20,6),(20,7)),ITvarid \"c\"),\"c\"),((((20,8),(20,10)),ITlarrow),\"<-\"),((((20,11),(20,18)),ITvarid \"getChar\"),\"getChar\"),((((21,6),(21,6)),ITsemi),\"\"),((((21,6),(21,12)),ITvarid \"return\"),\"return\"),((((21,13),(21,14)),ITvarid \"c\"),\"c\")]"

      let (forest''',_newSpan,_) = updateTokensForSrcSpan forest'' l newToks

      let toksFinal = retrieveTokens forest'''

      -- (show toksFinal) `shouldBe` ""
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n bbb x y =\n   do c <- getChar\n      return c\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n  "

    -- --------------------------------------

    it "replaces the tokens for a given span, removing any sub tree" $ do
       pending "write this"

    -- --------------------------------------

    it "replaces a single token" $ do
      (_t,toks) <- parsedFileDemoteWhereIn4
      let forest = mkTreeFromTokens toks

      let ss1 = posToSrcSpan forest ((11,18),(11,22))
      (GHC.showPpr ss1) `shouldBe` "test/testdata/Demote/WhereIn4.hs:11:18-21"
      (showSrcSpan ss1) `shouldBe` "((11,18),(11,22))"

      ss1Tok <- liftIO $ tokenise (realSrcLocFromTok mkZeroToken) 0 True "sq"
      (show ss1Tok) `shouldBe` "[((((0,0),(0,2)),ITvarid \"sq\"),\"sq\")]"

      let (forest2,_ss1',_) = updateTokensForSrcSpan forest ss1 ss1Tok

      (drawTreeEntry forest2) `shouldBe` 
           "((1,1),(20,1))\n|\n"++
           "+- ((1,1),(11,17))\n|\n"++
           "+- ((11,18),(11,20))\n|\n"++
           "`- ((11,23),(20,1))\n"

      -- (show forest2) `shouldBe` ""

      let ss2 = posToSrcSpan forest ((11,27),(11,31))
      (GHC.showPpr ss2) `shouldBe` "test/testdata/Demote/WhereIn4.hs:11:27-30"
      (showSrcSpan ss2) `shouldBe` "((11,27),(11,31))"

      ss2Tok <- liftIO $ tokenise (realSrcLocFromTok mkZeroToken) 0 True "sq"
      (show ss2Tok) `shouldBe` "[((((0,0),(0,2)),ITvarid \"sq\"),\"sq\")]"

      let (forest3,_ss2',_) = updateTokensForSrcSpan forest2 ss2 ss2Tok

      (drawTreeEntry forest3) `shouldBe` 
           "((1,1),(20,1))\n|\n"++
           "+- ((1,1),(11,17))\n|\n"++
           "+- ((11,18),(11,20))\n|\n"++
           "`- ((11,23),(20,1))\n   |\n"++
           "   +- ((11,23),(11,26))\n   |\n"++
           "   +- ((11,27),(11,29))\n   |\n"++
           "   `- ((11,32),(20,1))\n"

      -- (show forest2) `shouldBe` ""
{-
      (drawTreeEntry $ insertSrcSpan forest2 (fs ss2)) `shouldBe` 
           "((1,1),(20,1))\n|\n"++
           "+- ((1,1),(11,17))\n|\n"++
           "+- ((11,18),(11,20))\n|\n"++
           "`- ((11,23),(20,1))\n   |\n"++
           "   +- ((11,23),(11,26))\n   |\n"++
           "   +- ((11,27),(11,31))\n   |\n"++
           "   `- ((11,32),(20,1))\n"

      let (f,tree) = getSrcSpanFor forest2 (fs ss2)
      let zf = openZipperToNode tree $ Z.fromTree f

      (show tree) `shouldBe` ""
      (show zf) `shouldBe` ""
-}
      let ss3 = posToSrcSpan forest ((15,14),(15,17))
      (GHC.showPpr ss3) `shouldBe` "test/testdata/Demote/WhereIn4.hs:15:14-16"
      (showSrcSpan ss3) `shouldBe` "((15,14),(15,17))"

      ss3Tok <- liftIO $ tokenise (realSrcLocFromTok mkZeroToken) 0 True "p"
      (show ss3Tok) `shouldBe` "[((((0,0),(0,1)),ITvarid \"p\"),\"p\")]"

      let (forest4,_ss3',_) = updateTokensForSrcSpan forest3 ss3 ss3Tok
      -- (show forest4) `shouldBe` ""
      (drawTreeEntry forest4) `shouldBe` 
           "((1,1),(20,1))\n|\n"++
           "+- ((1,1),(11,17))\n|\n"++
           "+- ((11,18),(11,20))\n|\n"++
           "`- ((11,23),(20,1))\n   |\n"++
           "   +- ((11,23),(11,26))\n   |\n"++
           "   +- ((11,27),(11,29))\n   |\n"++
           "   `- ((11,32),(20,1))\n      |\n"++
           "      +- ((11,32),(15,14))\n      |\n"++
           "      +- ((15,14),(15,15))\n      |\n"++
           "      `- ((17,1),(20,1))\n"

    -- --------------------------------------

    it "replaces a single token,without disturbing adjacent ones" $ do
      (_t,toks) <- parsedFileGhc "./test/testdata/Demote/WhereIn6.hs"

      let forest = mkTreeFromTokens toks
      let tk = initTokenCache toks

      -- removeToksForPos ((13,1),(13,21))
      let sspan = posToSrcSpan forest ((13,1),(13,21))
      (GHC.showPpr sspan) `shouldBe` "test/testdata/Demote/WhereIn6.hs:13:1-20"

      -- (showToks toks) `shouldBe` ""
      let tk2 = removeToksFromCache tk sspan
      (drawTokenCache tk2) `shouldBe`
                 "tree TId 0:\n"++
               "((1,1),(13,21))\n|\n"++
               "`- ((1,1),(11,25))\n"++
               "tree TId 1:\n"++
               "((100000013,1),(100000013,21))\n"

      let ss2 = posToSrcSpan forest ((100000013,16),(100000013,17))
      (GHC.showPpr ss2) `shouldBe` "test/testdata/Demote/WhereIn6.hs:100000013:16"
      (showSrcSpan ss2) `shouldBe` "((100000013,16),(100000013,17))"
      (show (srcSpanToForestSpan ss2)) `shouldBe` "(((ForestLine 1 0 13),16),((ForestLine 1 0 13),17))"
      (show $ getGhcLoc ss2) `shouldBe` "(100000013,16)"
      (show $ getGhcLocEnd ss2) `shouldBe` "(100000013,17)"
      let (tokStartPos,tokEndPos) = forestSpanToSimpPos (srcSpanToForestSpan ss2)
      (tokStartPos,tokEndPos) `shouldBe` ((13,16),(13,17))

      let f2 = getTreeFromCache ss2 tk2
      (GHC.showRichTokenStream $ retrieveTokens f2) `shouldBe`
               "\n\n\n\n\n\n\n\n\n\n\n\n addthree a b c=a+b+c"
      toks2 <- basicTokenise "x"
      (show toks2) `shouldBe` "[((((0,1),(0,2)),ITvarid \"x\"),\"x\")]"
      --

      let z = openZipperToSpan (srcSpanToForestSpan ss2) $ Z.fromTree f2
      let toksz = retrieveTokens $ Z.tree z
      (GHC.showRichTokenStream toksz) `shouldBe` "\n\n\n\n\n\n\n\n\n\n\n\n addthree a b c=a+b+c"
      let (_begin,middle,_end) = splitToks (tokStartPos,tokEndPos) toksz
      -- (show begin) `shouldBe` ""
      (show middle) `shouldBe` "[((((13,16),(13,17)),ITvarid \"a\"),\"a\")]"
      -- (show end) `shouldBe` ""

      let (startLoc,endLoc) = startEndLocIncComments' toksz (tokStartPos,tokEndPos)
      (startLoc,endLoc) `shouldBe` ((13,16),(13,17))

      let fss = insertSrcSpan f2 (srcSpanToForestSpan ss2)
      (drawTreeEntry fss) `shouldBe`
               "((100000013,1),(100000013,21))\n|\n"++
               "+- ((13,1),(13,16))\n|\n"++
               "+- ((100000013,16),(100000013,17))\n|\n"++
               "`- ((13,17),(13,21))\n"

      let (forest',_tree) = getSrcSpanFor f2 (srcSpanToForestSpan ss2)
      (drawTreeEntry forest') `shouldBe`
               "((100000013,1),(100000013,21))\n|\n"++
               "+- ((13,1),(13,16))\n|\n"++
               "+- ((100000013,16),(100000013,17))\n|\n"++
               "`- ((13,17),(13,21))\n"
      --

      let (f3,_ss1',_) = updateTokensForSrcSpan f2 ss2 toks2

      (drawTreeEntry f3) `shouldBe`
               "((100000013,1),(100000013,21))\n|\n"++
               "+- ((13,1),(13,16))\n|\n"++
               "+- ((13,16),(13,17))\n|\n"++
               "`- ((13,17),(13,21))\n"
      -- (show f3) `shouldBe` ""
      (GHC.showRichTokenStream $ retrieveTokens f3) `shouldBe`
               "\n\n\n\n\n\n\n\n\n\n\n\n addthree a b c=x+b+c"


  -- ---------------------------------------------

  describe "posToSrcSpan" $ do
    it "Converts a simple position to a SrcSpan in the context of a forest" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let sspan = posToSrcSpan forest ((1,2),(3,5))
      (GHC.showPpr sspan) `shouldBe` "test/testdata/TokenTest.hs:(1,2)-(3,4)"
      (showSrcSpan sspan) `shouldBe` "((1,2),(3,5))"

  -- ---------------------------------------------

  describe "ghcLineToForestLine" $ do
    it "converts a GHC line to a ForestLine" $ do
      (ghcLineToForestLine         34) `shouldBe` ForestLine 0 0 34
      (ghcLineToForestLine   1000034) `shouldBe` ForestLine 0  1 34
      (ghcLineToForestLine 530000034) `shouldBe` ForestLine 5 30 34

  describe "forestLineToGhcLine" $ do
    it "converts a ForestLine value to a GHC line" $ do
      (forestLineToGhcLine $ ForestLine 0  0 34) `shouldBe`        34
      (forestLineToGhcLine $ ForestLine 0  1 34) `shouldBe`   1000034
      (forestLineToGhcLine $ ForestLine 5 30 34) `shouldBe` 530000034

  -- ---------------------------------------------

  describe "ForestLine Ord" $ do
    it "implements Ord for ForestLine" $ do
      compare (ForestLine 0 0 1) (ForestLine 0 0 3) `shouldBe` LT
      compare (ForestLine 0 0 3) (ForestLine 0 1 3) `shouldBe` LT
      compare (ForestLine 0 1 1) (ForestLine 0 2 3) `shouldBe` LT
      compare (ForestLine 0 9 3) (ForestLine 0 0 4) `shouldBe` LT

      compare (ForestLine 0 7 3) (ForestLine 0 7 3) `shouldBe` EQ

      compare (ForestLine 0 0 4) (ForestLine 0 0 3) `shouldBe` GT

  -- ---------------------------------------------

  describe "insertNodeAfter" $ do
    it "Adds a new SrcSpan after a specified one in the forest." $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let (ghcl,_c) = getGhcLoc l
      let (ForestLine tr v lin) = ghcLineToForestLine ghcl
      let newSpan' = insertForestLineInSrcSpan (ForestLine tr (v+1) lin) l

      let toksNew = take 3 toks
      let newNode = Node (Entry (fs newSpan') toksNew) []
      -- let newNode = Node (Entry l toks) []

      -- let toks' = retrieveTokens tree
      let forest'' = insertNodeAfter tree newNode forest'
      (invariant forest'') `shouldBe` []
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++
              "+- ((1000019,1),(1000021,14))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n"

      let toksFinal = retrieveTokens forest''
      (GHC.showRichTokenStream toksNew) `shouldBe` "module TokenTest where"
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c module TokenTest where\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n "

  -- ---------------------------------------------

  describe "addNewSrcSpanAndToksAfter" $ do
    it "Adds a new SrcSpan after an existing one in the forest." $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let toks' = retrieveTokens tree
      let (forest'',sspan) = addNewSrcSpanAndToksAfter forest' l l (PlaceOffset 2 0 2) toks'
      (invariant forest'') `shouldBe` []
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++
              "+- ((1000019,1),(1000021,14))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n"
      (showSrcSpan sspan) `shouldBe` "((1000019,1),(1000021,14))"

      let toksFinal = retrieveTokens forest''
      -- (showToks toksFinal) `shouldBe` ""
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n  "

  -- ---------------------------------------------

  describe "addToksAfterSrcSpan" $ do
    it "Adds a new SrcSpan after an existing one in the forest 1." $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let toks' = retrieveTokens tree
      let (forest'',sspan) = addToksAfterSrcSpan forest' l (PlaceOffset 2 0 2) toks'
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++
              "+- ((1000024,1),(1000026,14))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n"
      (showSrcSpan sspan) `shouldBe` "((1000024,1),(1000026,14))"
      (invariant forest'') `shouldBe` []

      let toksFinal = retrieveTokens forest''
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n \n\n  "

    -- ---------------------------------

    it "Adds a new SrcSpan after an existing one in the forest 2." $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head $ tail decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(13,1)-(15,16)"
      (showSrcSpan l) `shouldBe` "((13,1),(15,17))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let toks' = retrieveTokens tree
      let (forest'',sspan) = addToksAfterSrcSpan forest' l (PlaceOffset 2 0 2) toks'
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(10,10))\n|\n"++
              "+- ((13,1),(15,17))\n|\n"++
              "+- ((1000017,1),(1000019,17))\n|\n"++ -- our inserted span
              "`- ((19,1),(26,1))\n"
      (showSrcSpan sspan) `shouldBe` "((1000017,1),(1000019,17))"
      (invariant forest'') `shouldBe` []

      let toksFinal = retrieveTokens forest''
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n \n\n  -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n\n\n\n "

    -- ---------------------------------

    it "Adds a new SrcSpan after an existing one in the forest, with an indent." $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let toks' = retrieveTokens tree
      let (forest'',sspan) = addToksAfterSrcSpan forest' l (PlaceOffset 2 4 2) toks'
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++
              "+- ((1000024,5),(1000026,18))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n"
      (showSrcSpan sspan) `shouldBe` "((1000024,5),(1000026,18))"
      (invariant forest'') `shouldBe` []

      let toksFinal = retrieveTokens forest''
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n     -- leading comment\n     foo x y =\n       do c <- getChar\n          return c\n\n \n\n  "

    -- ---------------------------------

    it "Adds a new SrcSpan after an existing one, with an indent based on whole prior line." $ do
      (_t,toks) <- parsedFileGhc "./test/testdata/MoveDef/Demote.hs"
      let forest = mkTreeFromTokens toks

      --  removeToksForPos ((7,1),(7,6))
      let sspan = posToSrcSpan forest ((7,1),(7,6))
      let (forest',_delTree) = removeSrcSpan forest (srcSpanToForestSpan sspan)
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(8,6))\n|\n"++
              "+- ((1,1),(4,19))\n|\n"++
              "`- ((8,1),(8,6))\n"
      (invariant forest') `shouldBe` []


      --  putToksAfterPos ((4,14),(4,19))
      let sspan' = posToSrcSpan forest' ((4,14),(4,19))

      let finsert = insertSrcSpan forest' (srcSpanToForestSpan sspan')
      (drawTreeEntry finsert) `shouldBe`
              "((1,1),(8,6))\n|\n"++
              "+- ((1,1),(4,19))\n|  |\n"++
              "|  +- ((1,1),(4,13))\n|  |\n"++
              "|  `- ((4,14),(4,19))\n|\n"++
              "`- ((8,1),(8,6))\n"

      let newToks = take 3 toks
      let (forest'',sspan'') = addToksAfterSrcSpan finsert (sspan') (PlaceOffset 2 4 2) newToks
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(8,6))\n|\n"++
              "+- ((1,1),(4,19))\n|  |\n"++
              "|  +- ((1,1),(4,13))\n|  |\n"++
              "|  +- ((4,14),(4,19))\n|  |\n"++
              "|  `- ((1000006,5),(1000006,32))\n|\n"++
              "`- ((8,1),(8,6))\n"

      (showSrcSpan sspan'') `shouldBe` "((1000006,5),(1000006,32))"
      -- (invariant forest'') `shouldBe` []

      let toksFinal = retrieveTokens forest''
      -- (showToks toksFinal) `shouldBe` ""
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module MoveDef.Demote where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n     module MoveDef.Demote where\n\n \n\n  d = 9\n\n\n "

    -- ---------------------------------

    it "Adds a new SrcSpan after an existing one, with an indent catering for comments" $ do
      (_t,toks) <- parsedFileGhc "./test/testdata/Demote/WhereIn5.hs"
      let forest = mkTreeFromTokens toks

      -- removeToksForPos ((14,1),(14,6))
      let sspan = posToSrcSpan forest ((14,1),(14,6))
      let (forest',_delTree) = removeSrcSpan forest (srcSpanToForestSpan sspan)
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(19,1))\n|\n"++
              "+- ((1,1),(12,26))\n|\n"++
              "`- ((16,1),(19,1))\n"
      (invariant forest') `shouldBe` []

      -- addLocalDecl entered:newSource="[pow=2\n\n]"
      -- putToksAfterPos ((11,16),(12,26)) at PlaceIndent 1 0 2
      let sspan' = posToSrcSpan forest' ((11,16),(12,26))

      let finsert = insertSrcSpan forest' (srcSpanToForestSpan sspan')
      (drawTreeEntry finsert) `shouldBe`
              "((1,1),(19,1))\n|\n"++
              "+- ((1,1),(12,26))\n|  |\n"++
              "|  +- ((1,1),(11,15))\n|  |\n"++
              "|  `- ((11,16),(12,26))\n|\n"++
              "`- ((16,1),(19,1))\n"

      newToks <- liftIO $ basicTokenise "pow=2\n\n"
      let (forest'',sspan'') = addToksAfterSrcSpan finsert (sspan') (PlaceIndent 1 0 2) newToks
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(19,1))\n|\n"++
              "+- ((1,1),(12,26))\n|  |\n"++
              "|  +- ((1,1),(11,15))\n|  |\n"++
              "|  +- ((11,16),(12,26))\n|  |\n"++
              "|  `- ((1000014,16),(1000014,21))\n|\n"++
              "`- ((16,1),(19,1))\n"

      (showSrcSpan sspan'') `shouldBe` "((1000014,16),(1000014,21))"
      -- (invariant forest'') `shouldBe` []

      let toksFinal = retrieveTokens forest''
      -- (showToks toksFinal) `shouldBe` ""
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module Demote.WhereIn5 where\n\n --A definition can be demoted to the local 'where' binding of a friend declaration,\n --if it is only used by this friend declaration.\n\n --Demoting a definition narrows down the scope of the definition.\n --In this example, demote the top level 'pow' to 'sq'\n --This example aims to test demoting a function/pattern binding multi-levels.\n\n sumSquares x y = sq x + sq y\n          where sq 0=0\n                sq z=z^pow {-There \nis a comment-}\n                pow=2\n\n \n\n  anotherFun 0 y = sq y\n      where  sq x = x^2\n\n "

    -- ---------------------------------

    it "Adds a new SrcSpan after deleting toks" $ do
      (_t,toks) <- parsedFileGhc "./test/testdata/MoveDef/Demote.hs"
      let forest = mkTreeFromTokens toks

      --  removeToksForPos ((7,1),(7,6))
      let sspan = posToSrcSpan forest ((7,1),(7,6))
      let (forest',_) = removeSrcSpan forest (srcSpanToForestSpan sspan)
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(8,6))\n|\n"++
              "+- ((1,1),(4,19))\n|\n"++
              "`- ((8,1),(8,6))\n"
      (invariant forest') `shouldBe` []

      --  putToksAfterPos ((4,14),(4,19))
      let newToks = take 3 toks
      let sspan' = posToSrcSpan forest' ((4,14),(4,19))
      let position = PlaceOffset 1 4 2

      let finsert = insertSrcSpan forest' (srcSpanToForestSpan sspan')
      (drawTreeEntry finsert) `shouldBe`
              "((1,1),(8,6))\n|\n"++
              "+- ((1,1),(4,19))\n|  |\n"++
              "|  +- ((1,1),(4,13))\n|  |\n"++
              "|  `- ((4,14),(4,19))\n|\n"++
              "`- ((8,1),(8,6))\n"

      let (f,_t) = getSrcSpanFor forest' (srcSpanToForestSpan sspan')
      (drawTreeEntry f) `shouldBe`
              "((1,1),(8,6))\n|\n"++
              "+- ((1,1),(4,19))\n|  |\n"++
              "|  +- ((1,1),(4,13))\n|  |\n"++
              "|  `- ((4,14),(4,19))\n|\n"++
              "`- ((8,1),(8,6))\n"

      let (forest'',newSpan) = addToksAfterSrcSpan forest' sspan' position newToks

      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(8,6))\n|\n"++
              "+- ((1,1),(4,19))\n|  |\n"++
              "|  +- ((1,1),(4,13))\n|  |\n"++
              "|  +- ((4,14),(4,19))\n|  |\n"++
              "|  `- ((1000005,5),(1000005,32))\n|\n"++
              "`- ((8,1),(8,6))\n"

      (showSrcSpan newSpan) `shouldBe` "((1000005,5),(1000005,32))"
      (invariant forest'') `shouldBe` []

    -- ---------------------------------

    it "Adds a new SrcSpan after an existing one, in a subtree." $ do
      (_t,toks) <- parsedFileDemoteD1

      let forest = mkTreeFromTokens toks

      -- removeToksForPos ((9,1),(9,14))
      let sspan = posToSrcSpan forest ((9,1),(9,14))
      let (forest',_delTree) = removeSrcSpan forest (srcSpanToForestSpan sspan)
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(13,25))\n|\n"++
              "+- ((1,1),(7,18))\n|\n"++
              "`- ((11,1),(13,25))\n"
      (invariant forest') `shouldBe` []

      -- putToksForSpan test/testdata/Demote/D1.hs:6:21-24:[((((0,1),(0,3)),ITvarid "sq"),"sq")]
      let sspan2 = posToSrcSpan forest' ((6,21),(6,25))
      let tok2 = head $ drop 12 toks
      let (f2,_newSpan,_oldTree) = updateTokensForSrcSpan forest' sspan2 [tok2]
      (drawTreeEntry f2) `shouldBe`
              "((1,1),(13,25))\n|\n"++
              "+- ((1,1),(7,18))\n|  |\n"++
              "|  +- ((1,1),(6,20))\n|  |\n"++
              "|  +- ((6,21),(6,23))\n|  |\n"++
              "|  `- ((6,26),(7,18))\n|\n"++
              "`- ((11,1),(13,25))\n"

      -- putToksAfterPos ((6,21),(6,41)) at PlaceIndent 1 4 2
      let sspan3 = posToSrcSpan forest' ((6,21),(6,41))
      let newToks = take 20 $ drop 5 toks

      -- let (fss,_tree) = getSrcSpanFor f2 (srcSpanToForestSpan sspan3)
      let z = openZipperToSpan (srcSpanToForestSpan sspan3) $ Z.fromTree f2
      -- retrieveTokens $ Z.toTree z
      -- (show $ Z.toTree z) `shouldBe` ""
      -- (drawTreeEntry $ Z.tree z) `shouldBe` ""
      -- (show z) `shouldBe` ""

      let childrenAsZ = go [] (Z.firstChild z)
           where
            go acc Nothing = acc
            go acc (Just zz) = go (acc ++ [zz]) (Z.next zz)
      (show $ map treeStartEnd $ map Z.tree childrenAsZ) `shouldBe`
             "[(((ForestLine 0 0 1),1),((ForestLine 0 0 6),20)),"++
              "(((ForestLine 0 0 6),21),((ForestLine 0 0 6),23)),"++
              "(((ForestLine 0 0 6),26),((ForestLine 0 0 7),18))]"

      let contains zn = (startPos <= nodeStart && endPos >= nodeEnd)
            where
              (startPos,endPos) = treeStartEnd $ Z.tree zn
              (nodeStart,nodeEnd) = (srcSpanToForestSpan sspan3)

      (show $ filter contains childrenAsZ) `shouldBe` "[]"

      let fss = insertSrcSpan f2 (srcSpanToForestSpan sspan3)
      (drawTreeEntry fss) `shouldBe`
              "((1,1),(13,25))\n|\n"++
              "+- ((1,1),(7,18))\n|  |\n"++
              "|  +- ((1,1),(6,20))\n|  |\n"++
              "|  +- ((6,21),(6,41))\n|  |\n"++
              "|  `- ((7,1),(7,18))\n|\n"++ -- Problem line
              "`- ((11,1),(13,25))\n"


      let (forest'',sspan'') = addToksAfterSrcSpan f2 sspan3 (PlaceOffset 1 4 2) newToks
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(13,25))\n|\n"++
              "+- ((1,1),(7,18))\n|  |\n"++
              "|  +- ((1,1),(6,20))\n|  |\n"++
              "|  +- ((6,21),(6,41))\n|  |\n"++
              "|  +- ((1000007,5),(1000010,7))\n|  |\n"++
              "|  `- ((7,1),(7,18))\n|\n"++ -- Problem line
              "`- ((11,1),(13,25))\n"

      (showSrcSpan sspan'') `shouldBe` "((1000007,5),(1000010,7))"
      -- (invariant forest'') `shouldBe` []

      let toksFinal = retrieveTokens forest''
      -- (showToks toksFinal) `shouldBe` ""
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module Demote.D1 where\n\n {-demote 'sq' to 'sumSquares'. This refactoring\n  affects module 'D1' and 'C1' -}\n\n sumSquares (x:xs) = sq   + sumSquares xs\n     sumSquares (x:xs) = sq x + sumSquares xs\n     sumSquares [] = 0\n\n     sq\n\n \n\n  sumSquares [] = 0\n\n\n\n pow = 2\n\n main = sumSquares [1..4]\n\n "

    -- ---------------------------------

    it "Adds a new SrcSpan after the last one" $ do
      (_t,toks)  <- parsedFileGhc "./test/testdata/TypeUtils/JustImports.hs"

      let forest = mkTreeFromTokens toks

      let toksTree = retrieveTokens forest
      (GHC.showRichTokenStream toksTree) `shouldBe` "module JustImports where\n\n import Data.Maybe\n "
      (show toksTree) `shouldBe`
           "[((((1,1),(1,7)),ITmodule),\"module\"),"++
           "((((1,8),(1,19)),ITconid \"JustImports\"),\"JustImports\"),"++
           "((((1,20),(1,25)),ITwhere),\"where\"),"++
           "((((3,1),(3,1)),ITvocurly),\"\"),"++
           "((((3,1),(3,7)),ITimport),\"import\"),"++
           "((((3,8),(3,18)),ITqconid (\"Data\",\"Maybe\")),\"Data.Maybe\"),"++
           "((((4,1),(4,1)),ITsemi),\"\")]"

      (show toks) `shouldBe` (show toksTree)

      -- putToksAfterPos ((3,8),(3,18)) at PlaceOffset 1 0 1
      let sspan = posToSrcSpan forest ((3,8),(3,18))
      newToks <- basicTokenise "import Data.List"

      {-
      let (startLoc,endLoc) = startEndLocIncComments' toks ((3,8),(3,18))
      (show (startLoc,endLoc)) `shouldBe` "((3,8),(3,18))"

      let f1 = insertSrcSpan forest (fs sspan)
      (drawTreeEntry f1) `shouldBe`
              "((1,1),(3,18))\n|\n"++
              "+- ((1,1),(3,7))\n|\n"++
              "`- ((3,8),(3,18))\n"

      let (fwithspan,tree) = getSrcSpanFor forest (srcSpanToForestSpan sspan)
      (drawTreeEntry fwithspan) `shouldBe`
              "((1,1),(3,18))\n|\n"++
              "+- ((1,1),(3,7))\n|\n"++
              "`- ((3,8),(3,18))\n"
      -}

      let (forest',_sspan') = addToksAfterSrcSpan forest sspan (PlaceOffset 1 0 1) newToks
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(3,18))\n|\n"++
              "+- ((1,1),(3,7))\n|\n"++
              "+- ((3,8),(3,18))\n|\n"++
              "`- ((1000004,1),(1000004,17))\n"

      (invariant forest') `shouldBe` []

      let toksFinal = retrieveTokens forest'
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module JustImports where\n\n import Data.Maybe\n import Data.List\n \n "

  -- ---------------------------------------------

  describe "retrievePrevLineToks" $ do
    it "Retrieves the previous non-empty line tokens from an open zipper" $ do
      (_t,toks) <- parsedFileGhc "./test/testdata/MoveDef/Demote.hs"
      let forest = mkTreeFromTokens toks

      --  removeToksForPos ((7,1),(7,6))
      let sspan = posToSrcSpan forest ((7,1),(7,6))
      let (forest',_) = removeSrcSpan forest (srcSpanToForestSpan sspan)
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(8,6))\n|\n"++
              "+- ((1,1),(4,19))\n|\n"++
              "`- ((8,1),(8,6))\n"
      (invariant forest') `shouldBe` []

      --  putToksAfterPos ((4,14),(4,19))
      let sspan' = posToSrcSpan forest' ((4,14),(4,19))

      let finsert = insertSrcSpan forest' (srcSpanToForestSpan sspan')
      (drawTreeEntry finsert) `shouldBe`
              "((1,1),(8,6))\n|\n"++
              "+- ((1,1),(4,19))\n|  |\n"++
              "|  +- ((1,1),(4,13))\n|  |\n"++
              "|  `- ((4,14),(4,19))\n|\n"++
              "`- ((8,1),(8,6))\n"
      -- (invariant forest'') `shouldBe` []

      -- Now we have the test case set up. We want prior toks from
      -- ((4,14),(4,19))
      let tspan = posToSrcSpan forest ((4,14),(4,19))

      let z = openZipperToSpan (srcSpanToForestSpan tspan) $ Z.fromTree finsert

      let toksPrev = retrievePrevLineToks z

      (GHC.showRichTokenStream toksPrev) `shouldBe` "module MoveDef.Demote where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x"

  -- ---------------------------------------------

  describe "invariant 1" $ do
    it "checks that a tree with empty tokens and empty subForest fails" $ do
      (invariant $ Node (Entry nonNullSpan []) []) `shouldBe` ["FAIL: exactly one of toks or subforest must be empty: Node (Entry ((0,0),(1,0)) []) []"]

    -- -----------------------
    it "checks that a tree nonempty tokens and empty subForest passes" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      (invariant $ Node (Entry nonNullSpan (take 3 toks)) []) `shouldBe` []

    -- -----------------------
    it "checks that a tree with nonempty tokens and nonempty subForest fails" $ do
      (_t,toks) <- parsedFileTokenTestGhc

      (invariant (Node (Entry (simpPosToForestSpan ((1,1),(1,7))) (take 1 toks)) [emptyTree])) `shouldBe`
             ["FAIL: exactly one of toks or subforest must be empty: Node (Entry ((1,1),(1,7)) [(((1,1),(1,7)),ITmodule,\"module\")]) [\"Node (Entry ((0,0),(1,0)) []) []\"]",
              "FAIL: subForest start and end does not match entry: Node (Entry ((1,1),(1,7)) [(((1,1),(1,7)),ITmodule,\"module\")]) [\"Node (Entry ((0,0),(1,0)) []) []\"]",
              "FAIL: exactly one of toks or subforest must be empty: Node (Entry ((0,0),(1,0)) []) []"]


    -- -----------------------
    it "checks that a tree with empty tokens and nonempty subForest passes" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let tree@(Node (Entry sspan _) _) = mkTreeFromTokens toks

      (invariant (Node (Entry sspan []) [tree])) `shouldBe` []

    -- -----------------------
    it "checks the subtrees too" $ do
      (_t,_toks) <- parsedFileTokenTestGhc

      (invariant (Node (Entry nonNullSpan []) [emptyTree])) `shouldBe` ["FAIL: exactly one of toks or subforest must be empty: Node (Entry ((0,0),(1,0)) []) []"]

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
      (showTree tree3) `shouldBe` "Node (Entry ((1,1),(5,12)) [(((1,1),(1,7)),ITmodule,\"module\")]..[(((5,11),(5,12)),ITvarid \"x\",\"x\")]) []"

      (invariant (Node (Entry sspan []) [tree2])) `shouldBe` ["FAIL: subForest start and end does not match entry: Node (Entry ((1,1),(26,1)) []) [\"Node (Entry ((1,8),(26,1)) [(((1,8),(1,17)),ITconid \\\"TokenTest\\\",\\\"TokenTest\\\")]..[(((26,1),(26,1)),ITsemi,\\\"\\\")]) []\"]"]
      (invariant (Node (Entry sspan []) [tree3])) `shouldBe` ["FAIL: subForest start and end does not match entry: Node (Entry ((1,1),(26,1)) []) [\"Node (Entry ((1,1),(5,12)) [(((1,1),(1,7)),ITmodule,\\\"module\\\")]..[(((5,11),(5,12)),ITvarid \\\"x\\\",\\\"x\\\")]) []\"]"]

      (invariant (Node (Entry sspan []) [tree3,tree4])) `shouldBe` []

    it "checks that a the subree is in span order" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let (Node (Entry sspan _) _) = mkTreeFromTokens toks
      let tree1 = mkTreeFromTokens (take 10 toks)
      let tree2 = mkTreeFromTokens (take 10 $ drop 10 toks)
      let tree3 = mkTreeFromTokens (take 10 $ drop 20 toks)
      let tree4 = mkTreeFromTokens (drop 30 toks)

      (showForestSpan $ treeStartEnd tree1) `shouldBe` "((1,1),(5,12))"
      (showForestSpan $ treeStartEnd tree2) `shouldBe` "((6,3),(8,8))"
      (showForestSpan $ treeStartEnd tree3) `shouldBe` "((8,9),(13,4))"
      (showForestSpan $ treeStartEnd tree4) `shouldBe` "((13,5),(26,1))"

      (invariant (Node (Entry sspan []) [tree1,tree2,tree3,tree4])) `shouldBe` []
      (invariant (Node (Entry sspan []) [tree1,tree3,tree2,tree4])) `shouldBe` ["FAIL: subForest not in order: ((ForestLine 0 0 13),4) not < ((ForestLine 0 0 6),3):Node (Entry ((1,1),(26,1)) []) [\"Node (Entry ((1,1),(5,12)) [(((1,1),(1,7)),ITmodule,\\\"module\\\")]..[(((5,11),(5,12)),ITvarid \\\"x\\\",\\\"x\\\")]) []\",\"Node (Entry ((8,9),(13,4)) [(((8,9),(8,10)),ITequal,\\\"=\\\")]..[(((13,1),(13,4)),ITvarid \\\"bab\\\",\\\"bab\\\")]) []\",\"Node (Entry ((6,3),(8,8)) [(((6,3),(6,8)),ITwhere,\\\"where\\\")]..[(((8,7),(8,8)),ITvarid \\\"b\\\",\\\"b\\\")]) []\",\"Node (Entry ((13,5),(26,1)) [(((13,5),(13,6)),ITvarid \\\"a\\\",\\\"a\\\")]..[(((26,1),(26,1)),ITsemi,\\\"\\\")]) []\"]"]

  -- ---------------------------------------------
{-
  describe "invariant 3" $ do
    it "checks that the forest is in order, hence no overlaps" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let tree1 = mkTreeFromTokens (take 10 toks)
      let tree2 = mkTreeFromTokens (take 10 $ drop 10 toks)
      let tree3 = mkTreeFromTokens (take 10 $ drop 20 toks)
      let tree4 = mkTreeFromTokens (drop 30 toks)

      (showForestSpan $ treeStartEnd tree1) `shouldBe` "((1,1),(5,11))"
      (showForestSpan $ treeStartEnd tree2) `shouldBe` "((6,3),(8,7))"
      (showForestSpan $ treeStartEnd tree3) `shouldBe` "((8,9),(13,1))"
      (showForestSpan $ treeStartEnd tree4) `shouldBe` "((13,5),(26,1))"

      (invariant [tree1,tree2,tree3,tree4]) `shouldBe` []
      (invariant [tree1,tree3,tree2,tree4]) `shouldBe` ["FAIL: forest not in order: (13,1) not < (6,3)"]
-}
  -- ---------------------------------------------

  describe "invariant 3" $ do
    it "checks that all ForestSpans have the same version for start and end" $ do
      pending "write this test (and function)"

  -- ---------------------------------------------

  describe "mkTreeFromTokens" $ do
    it "creates a tree from an empty token list" $ do
      (show $ mkTreeFromTokens []) `shouldBe` "Node {rootLabel = Entry (((ForestLine 0 0 0),0),((ForestLine 0 0 0),0)) [], subForest = []}"

    -- -----------------------

    it "creates a tree from a list of tokens" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let toks' = take 2 $ drop 5 toks
      let tree = mkTreeFromTokens toks'
      (show toks') `shouldBe` "[((((5,1),(5,4)),ITvarid \"bob\"),\"bob\"),((((5,5),(5,6)),ITvarid \"a\"),\"a\")]"
      (show tree) `shouldBe` "Node {rootLabel = Entry (((ForestLine 0 0 5),1),((ForestLine 0 0 5),6)) [((((5,1),(5,4)),ITvarid \"bob\"),\"bob\"),((((5,5),(5,6)),ITvarid \"a\"),\"a\")], subForest = []}"

  -- ---------------------------------------------

  describe "invariant 5" $ do
    it "checks that a tree with a null SrcSpan fails" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let toks' = take 2 $ drop 5 toks
      (invariant $ Node (Entry nullSpan toks') []) `shouldBe` ["FAIL: null SrcSpan in tree: Node (Entry ((0,0),(0,0)) [(((5,1),(5,4)),ITvarid \"bob\",\"bob\"),(((5,5),(5,6)),ITvarid \"a\",\"a\")]) []"]

  -- ---------------------------------------------

  describe "syncAST" $ do
    it "updates an AST and a treeto have the same SrcSpan structure" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head $ drop 1 decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(13,1)-(15,16)"
      (showSrcSpan l) `shouldBe` "((13,1),(15,17))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let toks' = retrieveTokens tree
      let (forest'',sspan) = addNewSrcSpanAndToksAfter forest' l l (PlaceOffset 2 0 2) toks'
      (invariant forest'') `shouldBe` []
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(10,10))\n|\n"++
              "+- ((13,1),(15,17))\n|\n"++
              "+- ((1000013,1),(1000015,17))\n|\n"++ -- our inserted span
              "`- ((19,1),(26,1))\n"
      (showSrcSpan sspan) `shouldBe` "((1000013,1),(1000015,17))"

      let (decl',forest''') = syncAST decl sspan forest''

      (GHC.showPpr decl') `shouldBe` "TokenTest.bab a b = let bar = 3 in b GHC.Num.+ bar"
      (take 90 $ SYB.showData SYB.Renamer 0 decl') `shouldBe` "\n(L {test/testdata/TokenTest.hs:(1000013,1)-(1000015,16)} \n (FunBind \n  (L {test/testdata/"

      let toksFinal = retrieveTokens forest'''
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n  -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n\n\n\n "

  -- ---------------------------------------------

  describe "reSequenceToks" $ do
    it "Modifies a token stream to cater for changes in length of a token after e.g. renaming" $ do
      pending "write this"

  -- ---------------------------------------------

  describe "getTreeFromCache" $ do
    it "get the appropriate tree from the token cache, based on the SrcSpan" $ do
      (t,toks) <- parsedFileDemoteD1
      let tk = initTokenCache toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/Demote/D1.hs:11:1-7"
      (showSrcSpan l) `shouldBe` "((11,1),(11,8))"

      let tk' = removeToksFromCache tk l
      (drawTokenCache tk') `shouldBe` 
             "tree TId 0:\n"++
             "((1,1),(13,25))\n|\n"++
             "+- ((1,1),(9,14))\n|\n"++
             "`- ((13,1),(13,25))\n"++
             "tree TId 1:\n"++
             "((100000011,1),(100000011,8))\n"

      let mainForest = (tkCache tk') Map.! mainTid
      let sspan = posToSrcSpan mainForest ((11,1),(11,8))

      let tree1 = getTreeFromCache sspan tk'
      (drawTreeEntry tree1) `shouldBe` 
             "((1,1),(13,25))\n|\n"++
             "+- ((1,1),(9,14))\n|\n"++
             "`- ((13,1),(13,25))\n"

      let sspan2 = insertForestLineInSrcSpan (ForestLine 1 0 1) sspan
      (GHC.showPpr sspan2) `shouldBe` "test/testdata/Demote/D1.hs:(100000001,1)-(100000011,7)"
      (showSrcSpan sspan2) `shouldBe` "((100000001,1),(100000011,8))"

      let tid = treeIdFromForestSpan $ srcSpanToForestSpan sspan2
      (show tid) `shouldBe` "TId 1"

      let tree2 = getTreeFromCache sspan2 tk'
      (drawTreeEntry tree2) `shouldBe` 
             "((100000011,1),(100000011,8))\n"


  -- ---------------------------------------------

  describe "replaceTreeInCache" $ do
    it "replace the appropriate tree from the token cache, based on the SrcSpan" $ do
      (t,toks) <- parsedFileDemoteD1
      let tk = initTokenCache toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/Demote/D1.hs:11:1-7"
      (showSrcSpan l) `shouldBe` "((11,1),(11,8))"

      let tk' = removeToksFromCache tk l
      (drawTokenCache tk') `shouldBe` 
             "tree TId 0:\n"++
             "((1,1),(13,25))\n|\n"++
             "+- ((1,1),(9,14))\n|\n"++
             "`- ((13,1),(13,25))\n"++
             "tree TId 1:\n"++
             "((100000011,1),(100000011,8))\n"

      let mainForest = (tkCache tk') Map.! mainTid
      let sspan = posToSrcSpan mainForest ((11,1),(11,8))

      let sspan2 = insertForestLineInSrcSpan (ForestLine 1 0 1) sspan
      (GHC.showPpr sspan2) `shouldBe` "test/testdata/Demote/D1.hs:(100000001,1)-(100000011,7)"
      (showSrcSpan sspan2) `shouldBe` "((100000001,1),(100000011,8))"

      let tree1 = mkTreeFromTokens (take 10 toks)
      let tk1 = replaceTreeInCache sspan tree1 tk'
      (drawTokenCache tk1) `shouldBe` 
             "tree TId 0:\n"++
             "((1,1),(6,17))\n"++
             "tree TId 1:\n"++
             "((100000011,1),(100000011,8))\n"

      let tk2 = replaceTreeInCache sspan2 tree1 tk'
      (drawTokenCache tk2) `shouldBe` 
             "tree TId 0:\n"++
             "((1,1),(13,25))\n|\n"++
             "+- ((1,1),(9,14))\n|\n"++
             "`- ((13,1),(13,25))\n"++
             "tree TId 1:\n"++
             "((100000001,1),(100000006,17))\n" 

  -- -----------------------------------

  describe "removeToksFromCache" $ do
    it "removes a SrcSpan from the main tree, and stashes it" $ do
      (_t,toks) <- parsedFileDemoteWhereIn4
      let tk = initTokenCache toks

      -- removeToksForPos ((15,1),(15,17))
      let pos = ((15,1),(15,17))
      let mainForest = (tkCache tk) Map.! mainTid
      let sspan = posToSrcSpan mainForest pos
      let tk' = removeToksFromCache tk sspan

      (drawTokenCache tk') `shouldBe` 
             "tree TId 0:\n"++
             "((1,1),(20,1))\n|\n"++
             "+- ((1,1),(14,18))\n|\n"++
             "`- ((17,1),(20,1))\n"++
             "tree TId 1:\n"++
             "((100000015,1),(100000015,17))\n"

      let tree1 = (tkCache tk') Map.! (TId 1)

      (show $ retrieveTokens tree1) `shouldBe` "[((((15,1),(15,1)),ITsemi),\"\"),((((15,1),(15,3)),ITvarid \"sq\"),\"sq\"),((((15,4),(15,7)),ITvarid \"pow\"),\"pow\"),((((15,8),(15,9)),ITvarid \"z\"),\"z\"),((((15,10),(15,11)),ITequal),\"=\"),((((15,12),(15,13)),ITvarid \"z\"),\"z\"),((((15,13),(15,14)),ITvarsym \"^\"),\"^\"),((((15,14),(15,17)),ITvarid \"pow\"),\"pow\"),((((15,19),(15,39)),ITlineComment \"--there is a comment\"),\"--there is a comment\")]"

      -- putToksForSpan test/testdata/Demote/WhereIn4.hs:100000015:14-16:[((((0,1),(0,2)),ITvarid "p"),"p")]

      let sspan3 = posToSrcSpan mainForest ((100000015,14),(100000015,17))
      (GHC.showPpr sspan3) `shouldBe` "test/testdata/Demote/WhereIn4.hs:100000015:14-16"
      let toks3 = [mkToken (GHC.ITvarid (GHC.mkFastString "p")) (0,1) "p"]
      (show toks3) `shouldBe` "[((((0,1),(0,2)),ITvarid \"p\"),\"p\")]"
      let (tk3,_newSpan) = putToksInCache tk' sspan3 toks3
      (drawTokenCache tk3) `shouldBe` 
             "tree TId 0:\n"++
             "((1,1),(20,1))\n|\n"++
             "+- ((1,1),(14,18))\n|\n"++
             "`- ((17,1),(20,1))\n"++
             "tree TId 1:\n"++
             "((100000015,1),(100000015,17))\n|\n"++
             "+- ((100000015,1),(100000015,14))\n|\n"++
             "`- ((100000015,14),(100000015,15))\n"++
             "tree TId 2:\n"++
             "((200000015,14),(200000015,17))\n"

      let (forest2,tree1') = getSrcSpanFor tree1 (srcSpanToForestSpan sspan3)
      (show $ retrieveTokens forest2) `shouldBe` "[((((15,1),(15,1)),ITsemi),\"\"),((((15,1),(15,3)),ITvarid \"sq\"),\"sq\"),((((15,4),(15,7)),ITvarid \"pow\"),\"pow\"),((((15,8),(15,9)),ITvarid \"z\"),\"z\"),((((15,10),(15,11)),ITequal),\"=\"),((((15,12),(15,13)),ITvarid \"z\"),\"z\"),((((15,13),(15,14)),ITvarsym \"^\"),\"^\"),((((15,14),(15,17)),ITvarid \"pow\"),\"pow\"),((((15,19),(15,39)),ITlineComment \"--there is a comment\"),\"--there is a comment\")]"

      (show $ retrieveTokens tree1') `shouldBe` "[((((15,14),(15,17)),ITvarid \"pow\"),\"pow\"),((((15,19),(15,39)),ITlineComment \"--there is a comment\"),\"--there is a comment\")]"

      let tree3 = (tkCache tk3) Map.! (TId 1)
      (show $ retrieveTokens tree3) `shouldBe` "[((((15,1),(15,1)),ITsemi),\"\"),((((15,1),(15,3)),ITvarid \"sq\"),\"sq\"),((((15,4),(15,7)),ITvarid \"pow\"),\"pow\"),((((15,8),(15,9)),ITvarid \"z\"),\"z\"),((((15,10),(15,11)),ITequal),\"=\"),((((15,12),(15,13)),ITvarid \"z\"),\"z\"),((((15,13),(15,14)),ITvarsym \"^\"),\"^\"),((((15,14),(15,15)),ITvarid \"p\"),\"p\"),((((15,19),(15,39)),ITlineComment \"--there is a comment\"),\"--there is a comment\")]"

  -- ---------------------------------------------

  describe "syncAstToLatestCache" $ do
    it "update the SrcSpans in a declaration to math the latest stash" $ do
      (t,toks) <- parsedFileDemoteD1
      let tk = initTokenCache toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/Demote/D1.hs:11:1-7"
      (showSrcSpan l) `shouldBe` "((11,1),(11,8))"

      let tk' = removeToksFromCache tk l
      (drawTokenCache tk') `shouldBe` 
             "tree TId 0:\n"++
             "((1,1),(13,25))\n|\n"++
             "+- ((1,1),(9,14))\n|\n"++
             "`- ((13,1),(13,25))\n"++
             "tree TId 1:\n"++
             "((100000011,1),(100000011,8))\n"

      let mainForest = (tkCache tk') Map.! mainTid
      let sspan = posToSrcSpan mainForest ((11,1),(11,8))

      let sspan2 = insertForestLineInSrcSpan (ForestLine 1 0 1) sspan
      (GHC.showPpr sspan2) `shouldBe` "test/testdata/Demote/D1.hs:(100000001,1)-(100000011,7)"
      (showSrcSpan sspan2) `shouldBe` "((100000001,1),(100000011,8))"

      let (GHC.L ss' _) = syncAstToLatestCache tk' decl
      (GHC.showPpr ss') `shouldBe` "test/testdata/Demote/D1.hs:100000011:1-7"
      (showSrcSpan ss') `shouldBe` "((100000011,1),(100000011,8))"

-- ---------------------------------------------------------------------
-- Helper functions

fs :: GHC.SrcSpan -> ForestSpan
fs = srcSpanToForestSpan

emptyTree :: Tree Entry
emptyTree = Node (Entry nonNullSpan []) []

mkTreeFromSubTrees :: [Tree Entry] -> Tree Entry
mkTreeFromSubTrees [] = Node (Entry nullSpan []) []
mkTreeFromSubTrees trees = Node (Entry sspan []) trees
  where
   (Node (Entry _ startToks) _) = head trees
   (Node (Entry _ endToks) _) = last trees
   startLoc = tokenPos $ head startToks
   endLoc   = tokenPosEnd $ last endToks -- SrcSpans count from start of token, not end
   sspan    = simpPosToForestSpan (startLoc,endLoc)

nonNullSpan :: ForestSpan
nonNullSpan = ((ForestLine 0 0 0,0),(ForestLine 0 0 1,0))


-- ---------------------------------------------------------------------

tokenTestFileName :: GHC.FastString
tokenTestFileName = GHC.mkFastString "./test/testdata/TokenTest.hs"

parsedFileTokenTestGhc :: IO (ParseResult,[PosToken])
parsedFileTokenTestGhc = parsedFileGhc "./test/testdata/TokenTest.hs"

-- ---------------------------------------------------------------------

dupDefDd1FileName :: GHC.FastString
dupDefDd1FileName = GHC.mkFastString "./test/testdata/DupDef/Dd1.hs"

parsedFileDupDefDd1 :: IO (ParseResult, [PosToken])
parsedFileDupDefDd1 = parsedFileGhc "./test/testdata/DupDef/Dd1.hs"

-- ---------------------------------------------------------------------

moveDefMd1FileName :: GHC.FastString
moveDefMd1FileName = GHC.mkFastString "./test/testdata/MoveDef/Md1.hs"

parsedFileMoveDefMd1 :: IO (ParseResult, [PosToken])
parsedFileMoveDefMd1 = parsedFileGhc "./test/testdata/MoveDef/Md1.hs"

-- ---------------------------------------------------------------------

demoteD1FileName  :: GHC.FastString
demoteD1FileName = GHC.mkFastString "./test/testdata/Demote/D1.hs"

parsedFileDemoteD1 :: IO (ParseResult, [PosToken])
parsedFileDemoteD1 = parsedFileGhc "./test/testdata/Demote/D1.hs"

-- ---------------------------------------------------------------------

demoteWherIn4FileName  :: GHC.FastString
demoteWherIn4FileName = GHC.mkFastString "./test/testdata/Demote/WhereIn4.hs"

parsedFileDemoteWhereIn4 :: IO (ParseResult, [PosToken])
parsedFileDemoteWhereIn4 = parsedFileGhc "./test/testdata/Demote/WhereIn4.hs"

-- ---------------------------------------------------------------------
