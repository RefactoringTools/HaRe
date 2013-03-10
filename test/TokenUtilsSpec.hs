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
      (GHC.showPpr newSpan) `shouldBe` "test/testdata/DupDef/Dd1.hs:(1000006,1)-(1000008,0)"

      (SYB.showData SYB.Renamer 0 decl') `shouldBe` "\n(L {test/testdata/DupDef/Dd1.hs:(1000006,1)-(1000008,0)} \n (FunBind \n  (L {test/testdata/DupDef/Dd1.hs:6:1-8} {Name: DupDef.Dd1.toplevel}) \n  (False) \n  (MatchGroup \n   [\n    (L {test/testdata/DupDef/Dd1.hs:4:1-18} \n     (Match \n      [\n       (L {test/testdata/DupDef/Dd1.hs:6:10} \n        (VarPat {Name: x}))] \n      (Nothing) \n      (GRHSs \n       [\n        (L {test/testdata/DupDef/Dd1.hs:4:14-18} \n         (GRHS \n          [] \n          (L {test/testdata/DupDef/Dd1.hs:6:14-18} \n           (OpApp \n            (L {test/testdata/DupDef/Dd1.hs:6:14} \n             (HsVar {Name: DupDef.Dd1.c})) \n            (L {test/testdata/DupDef/Dd1.hs:6:16} \n             (HsVar {Name: GHC.Num.*})) {Fixity: infixl 7} \n            (L {test/testdata/DupDef/Dd1.hs:6:18} \n             (HsVar {Name: x}))))))] \n       (EmptyLocalBinds))))] {!type placeholder here?!}) \n  (WpHole) {NameSet: \n  [{Name: DupDef.Dd1.c}]} \n  (Nothing)))"

      (drawTreeEntry tm'') `shouldBe`
            "((1,1),(34,1))\n|\n"++
            "+- ((1,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "+- ((1000006,1),(1000008,1))\n|\n"++
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

      (SYB.showData SYB.Renamer 0 typeSig') `shouldBe` "\n(L {test/testdata/DupDef/Dd1.hs:1000006:1-30} \n (TypeSig \n  [\n   (L {test/testdata/DupDef/Dd1.hs:6:1-8} {Name: DupDef.Dd1.toplevel})] \n  (L {test/testdata/DupDef/Dd1.hs:6:13-30} \n   (HsFunTy \n    (L {test/testdata/DupDef/Dd1.hs:6:13-19} \n     (HsTyVar {Name: GHC.Integer.Type.Integer})) \n    (L {test/testdata/DupDef/Dd1.hs:6:24-30} \n     (HsTyVar {Name: GHC.Integer.Type.Integer}))))))"
      
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
      let (tm'''',newSpan',decl') = addDeclToksAfterSrcSpan tm''' newSpan (PlaceOffset 1 0 2) declToks decl
      -- (GHC.showPpr newSpan') `shouldBe` "test/testdata/DupDef/Dd1.hs:1000006:1-30"

      (drawTreeEntry tm'''') `shouldBe`
            "((1,1),(34,1))\n|\n"++
            "+- ((1,1),(3,31))\n|  |\n"++
            "|  +- ((1,1),(1,24))\n|  |\n"++
            "|  `- ((3,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "+- ((1000006,1),(1000006,31))\n|\n"++
            "+- ((1000007,1),(1000009,1))\n|\n"++
            "`- ((6,1),(34,1))\n"

    -- ---------------------------------

    it "gets the tokens for an added indented srcloc" $ do
      (t,toks) <- parsedFileDupDefDd1
      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
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
      (GHC.showPpr newSpan) `shouldBe` "test/testdata/DupDef/Dd1.hs:(1000024,5)-(1000025,0)"
      (drawTreeEntry tm2) `shouldBe`
           "((1,1),(34,1))\n|\n"++
           "+- ((1,1),(22,8))\n|\n"++
           "+- ((23,5),(23,11))\n|\n"++
           "+- ((1000024,5),(1000025,1))\n|\n"++
           "`- ((25,1),(34,1))\n"

  -- ---------------------------------------------

  describe "getTokensBefore" $ do
    it "gets the tokens before a given srcloc" $ do
      (t,toks) <- parsedFileMoveDefMd1
      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed

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
      let decl@(GHC.L l _) = head decls
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
      let decl@(GHC.L l _) = head decls
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
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

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
      let decl@(GHC.L l _) = head decls
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
      (t,toks) <- parsedFileDemoteD1
      let forest = mkTreeFromTokens toks

      let sspan = posToSrcSpan forest ((6,21),(6,41))
      (GHC.showPpr sspan) `shouldBe` "test/testdata/Demote/D1.hs:6:21-40"
      (showSrcSpan sspan) `shouldBe` "((6,21),(6,41))"

      let forest1 = insertSrcSpan forest (fs sspan)

      declToks <- liftIO $ tokenise (realSrcLocFromTok mkZeroToken) 0 True "where\n  sq = x ^ pow\n"
      -- putToksAfterPos ((6,21),(6,41)) at PlaceIndent 1 4 2
      let (forest2,newSpan) = addToksAfterSrcSpan forest1 sspan (PlaceIndent 1 4 2) declToks

      (invariant forest2) `shouldBe` []
      (drawTreeEntry forest2) `shouldBe`
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(6,20))\n|\n"++
               "+- ((6,21),(6,41))\n|\n"++
               "+- ((1000007,5),(1000011,1))\n|\n"++
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
               "+- ((1000007,5),(1000011,1))\n|\n"++
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
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let forest' = insertSrcSpan forest (fs l)
      (invariant forest') `shouldBe` []
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n"

      let forest'' = removeSrcSpan forest' (fs l)
      (invariant forest'') `shouldBe` []
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              -- "+- ((19,1),(21,14))\n|\n"++ -- removed again
              "`- ((26,1),(26,1))\n"

      let toks' = retrieveTokens forest''
      -- (showToks toks') `shouldBe` ""
      (GHC.showRichTokenStream toks') `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n\n\n\n\n\n\n\n\n "

    -- ---------------------------------
    it "removes a span and tokens that were not explicitly in the forest" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head $ drop 1 decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(13,1)-(15,16)"
      (showSrcSpan l) `shouldBe` "((13,1),(15,17))"

      let forest' = removeSrcSpan forest (fs l)
      (invariant forest') `shouldBe` []
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(10,10))\n|\n"++
              "`- ((19,1),(26,1))\n"

      let toks' = retrieveTokens forest'
      -- (showToks toks') `shouldBe` ""
      (GHC.showRichTokenStream toks') `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n\n\n\n\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n\n\n\n "

    -- ---------------------------------
    it "removes a span and tokens without destroying the forest" $ do
      (t,toks) <- parsedFileDemoteD1
      let forest = mkTreeFromTokens toks

      let sspan = posToSrcSpan forest ((6,21),(6,41))
      (GHC.showPpr sspan) `shouldBe` "test/testdata/Demote/D1.hs:6:21-40"
      (showSrcSpan sspan) `shouldBe` "((6,21),(6,41))"

      let forest1 = insertSrcSpan forest (fs sspan)

      declToks <- liftIO $ tokenise (realSrcLocFromTok mkZeroToken) 0 True "where\n  sq = x ^ pow\n"
      -- putToksAfterPos ((6,21),(6,41)) at PlaceIndent 1 4 2
      let (forest2,newSpan) = addToksAfterSrcSpan forest1 sspan (PlaceIndent 1 4 2) declToks

      (invariant forest2) `shouldBe` []
      (drawTreeEntry forest2) `shouldBe`
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(6,20))\n|\n"++
               "+- ((6,21),(6,41))\n|\n"++
               "+- ((1000007,5),(1000011,1))\n|\n"++
               "`- ((7,1),(13,25))\n"
      -- Context set up, now for the test.

      let sspan2 = posToSrcSpan forest ((9,1),(9,14))
      (GHC.showPpr sspan2) `shouldBe` "test/testdata/Demote/D1.hs:9:1-13"
      let forest3 = removeSrcSpan forest2 (fs sspan2)

      (drawTreeEntry $ insertSrcSpan forest2 (fs sspan2)) `shouldBe`
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(6,20))\n|\n"++
               "+- ((6,21),(6,41))\n|\n"++
               "+- ((1000007,5),(1000011,1))\n|\n"++
               "`- ((7,1),(13,25))\n   |\n"++
               "   +- ((7,1),(7,18))\n   |\n"++
               "   +- ((9,1),(9,14))\n   |\n"++
               "   `- ((11,1),(13,25))\n"

      (invariant forest3) `shouldBe` []
      (drawTreeEntry forest3) `shouldBe`
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(6,20))\n|\n"++
               "+- ((6,21),(6,41))\n|\n"++
               "+- ((1000007,5),(1000011,1))\n|\n"++
               "`- ((7,1),(13,25))\n   |\n"++
               "   +- ((7,1),(7,18))\n   |\n"++
               "   `- ((11,1),(13,25))\n"

      let toks' = retrieveTokens forest3
      -- (showToks toks') `shouldBe` ""
      (GHC.showRichTokenStream toks') `shouldBe` "module Demote.D1 where\n\n {-demote 'sq' to 'sumSquares'. This refactoring\n  affects module 'D1' and 'C1' -}\n\n sumSquares (x:xs) = sq x + sumSquares xs\n     where\n        sq = x ^ pow\n      \n\n \n\n  sumSquares [] = 0\n\n\n\n pow = 2\n\n main = sumSquares [1..4]\n\n "

  -- ---------------------------------------------

  describe "getPathFor" $ do
    it "retrieves an empty path if the SrcSpan is not in the tree" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      (map treeStartEnd $ getPathFor forest l) `shouldBe` []
      (concatMap showTree $ getPathFor forest l) `shouldBe` ""

      let forest' = insertSrcSpan forest (fs l)

      (map showForestSpan $ map treeStartEnd $ getPathFor forest' l)
           `shouldBe` ["((1,1),(26,1))","((19,1),(21,14))"]


    -- -----------------------------------
    it "retrieves the path if the SrcSpan is in the tree" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"
      (show $ ghcSpanStartEnd l) `shouldBe` "((19,1),(21,14))"

      let forest' = insertSrcSpan forest (fs l)
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n"

      (map showForestSpan $ map treeStartEnd $ getPathFor forest' l) `shouldBe`
             ["((1,1),(26,1))","((19,1),(21,14))"]

  -- ---------------------------------------------

  describe "retrieveTokens" $ do
    it "extracts all the tokens from the leaves of the trees, in order" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
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

      let (forest',newSpan) = updateTokensForSrcSpan forest l (take 3 toks)
      (GHC.showPpr newSpan) `shouldBe` "test/testdata/TokenTest.hs:18:1-22"
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((18,1),(18,23))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n" 

      let toks' = retrieveTokens forest'
      -- (showToks toks ) `shouldBe` ""
      -- (showToks toks') `shouldBe` ""
      (GHC.showRichTokenStream toks') `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n module TokenTest where\n\n\n\n\n\n\n\n "

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

      let (forest''',newSpan) = updateTokensForSrcSpan forest'' l newToks

      let toksFinal = retrieveTokens forest'''

      -- (show toksFinal) `shouldBe` ""
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n bbb x y =\n   do c <- getChar\n      return c\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n  "

    -- --------------------------------------

    it "replaces the tokens for a given span, removing any sub tree" $ do
       pending "write this"

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

  describe "insertNodeAfter" $ do
    it "Adds a new SrcSpan after a specified one in the forest." $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let (ghcl,c) = getGhcLoc l
      let (ForestLine v line) = ghcLineToForestLine ghcl
      let newSpan' = insertForestLineInSrcSpan (ForestLine (v+1) line) l

      let toksNew = take 3 toks
      let newNode = Node (Entry (fs newSpan') toksNew) []
      -- let newNode = Node (Entry l toks) []

      let toks' = retrieveTokens tree
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
      let decl@(GHC.L l _) = head decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let toks' = retrieveTokens tree
      let (forest'',sspan) = addToksAfterSrcSpan forest' l (PlaceOffset 2 0 2) toks'
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++
              "+- ((1000024,1),(1000028,1))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n"
      (showSrcSpan sspan) `shouldBe` "((1000024,1),(1000028,1))"
      (invariant forest'') `shouldBe` []

      let toksFinal = retrieveTokens forest''
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n \n\n  "

    -- ---------------------------------

    it "Adds a new SrcSpan after an existing one in the forest 2." $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head $ tail decls
      (GHC.showPpr l) `shouldBe` "test/testdata/TokenTest.hs:(13,1)-(15,16)"
      (showSrcSpan l) `shouldBe` "((13,1),(15,17))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let toks' = retrieveTokens tree
      let (forest'',sspan) = addToksAfterSrcSpan forest' l (PlaceOffset 2 0 2) toks'
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(26,1))\n|\n"++
              "+- ((1,1),(10,10))\n|\n"++
              "+- ((13,1),(15,17))\n|\n"++
              "+- ((1000017,1),(1000021,1))\n|\n"++ -- our inserted span
              "`- ((19,1),(26,1))\n"
      (showSrcSpan sspan) `shouldBe` "((1000017,1),(1000021,1))"
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
              "+- ((1000024,5),(1000028,1))\n|\n"++ -- our inserted span
              "`- ((26,1),(26,1))\n"
      (showSrcSpan sspan) `shouldBe` "((1000024,5),(1000028,1))"
      (invariant forest'') `shouldBe` []

      let toksFinal = retrieveTokens forest''
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n     -- leading comment\n     foo x y =\n       do c <- getChar\n          return c\n\n \n\n  "

    -- ---------------------------------

    it "Adds a new SrcSpan after an existing one, with an indent based on whole prior line." $ do
      (t,toks) <- parsedFileGhc "./test/testdata/MoveDef/Demote.hs"
      let forest = mkTreeFromTokens toks

      --  removeToksForPos ((7,1),(7,6))
      let sspan = posToSrcSpan forest ((7,1),(7,6))
      let forest' = removeSrcSpan forest (srcSpanToForestSpan sspan)
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
              "|  `- ((1000006,5),(1000008,1))\n|\n"++
              "`- ((8,1),(8,6))\n"

      (showSrcSpan sspan'') `shouldBe` "((1000006,5),(1000008,1))"
      -- (invariant forest'') `shouldBe` []

      let toksFinal = retrieveTokens forest''
      -- (showToks toksFinal) `shouldBe` ""
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module MoveDef.Demote where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n     module MoveDef.Demote where\n\n \n\n  d = 9\n\n\n "

    -- ---------------------------------

    it "Adds a new SrcSpan after deleting toks" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/MoveDef/Demote.hs"
      let forest = mkTreeFromTokens toks

      --  removeToksForPos ((7,1),(7,6))
      let sspan = posToSrcSpan forest ((7,1),(7,6))
      let forest' = removeSrcSpan forest (srcSpanToForestSpan sspan)
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

      let (f,t) = getSrcSpanFor forest' (srcSpanToForestSpan sspan')
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
              "|  `- ((1000005,5),(1000007,1))\n|\n"++
              "`- ((8,1),(8,6))\n"

      (showSrcSpan newSpan) `shouldBe` "((1000005,5),(1000007,1))"
      (invariant forest'') `shouldBe` []

  -- ---------------------------------------------

  describe "retrievePrevLineToks" $ do
    it "Retrieves the previous non-empty line tokens from an open zipper" $ do
      (_t,toks) <- parsedFileGhc "./test/testdata/MoveDef/Demote.hs"
      let forest = mkTreeFromTokens toks

      --  removeToksForPos ((7,1),(7,6))
      let sspan = posToSrcSpan forest ((7,1),(7,6))
      let forest' = removeSrcSpan forest (srcSpanToForestSpan sspan)
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
      (invariant (Node (Entry sspan []) [tree1,tree3,tree2,tree4])) `shouldBe` ["FAIL: subForest not in order: (ForestLine {flInsertVersion = 0, flLine = 13},4) not < (ForestLine {flInsertVersion = 0, flLine = 6},3):Node (Entry ((1,1),(26,1)) []) [\"Node (Entry ((1,1),(5,12)) [(((1,1),(1,7)),ITmodule,\\\"module\\\")]..[(((5,11),(5,12)),ITvarid \\\"x\\\",\\\"x\\\")]) []\",\"Node (Entry ((8,9),(13,4)) [(((8,9),(8,10)),ITequal,\\\"=\\\")]..[(((13,1),(13,4)),ITvarid \\\"bab\\\",\\\"bab\\\")]) []\",\"Node (Entry ((6,3),(8,8)) [(((6,3),(6,8)),ITwhere,\\\"where\\\")]..[(((8,7),(8,8)),ITvarid \\\"b\\\",\\\"b\\\")]) []\",\"Node (Entry ((13,5),(26,1)) [(((13,5),(13,6)),ITvarid \\\"a\\\",\\\"a\\\")]..[(((26,1),(26,1)),ITsemi,\\\"\\\")]) []\"]"]

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
      (show $ mkTreeFromTokens []) `shouldBe` "Node {rootLabel = Entry ((ForestLine {flInsertVersion = 0, flLine = 0},0),(ForestLine {flInsertVersion = 0, flLine = 0},0)) [], subForest = []}"

    -- -----------------------

    it "creates a tree from a list of tokens" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let toks' = take 2 $ drop 5 toks
      let tree = mkTreeFromTokens toks'
      (show toks') `shouldBe` "[((((5,1),(5,4)),ITvarid \"bob\"),\"bob\"),((((5,5),(5,6)),ITvarid \"a\"),\"a\")]"
      (show tree) `shouldBe` "Node {rootLabel = Entry ((ForestLine {flInsertVersion = 0, flLine = 5},1),(ForestLine {flInsertVersion = 0, flLine = 5},6)) [((((5,1),(5,4)),ITvarid \"bob\"),\"bob\"),((((5,5),(5,6)),ITvarid \"a\"),\"a\")], subForest = []}"

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
nonNullSpan = ((ForestLine 0 0,0),(ForestLine 0 1,0))


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
