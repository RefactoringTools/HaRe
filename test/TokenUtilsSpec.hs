module TokenUtilsSpec (main, spec) where

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

  describe "getTokensFor" $ do
    it "gets the tokens for a given srcloc, and caches them in the tree" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls

      let forest = mkTreeFromTokens toks
      let (tm',declToks) = getTokensFor True forest l

      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"
      (showGhc decl) `shouldBe` "TokenTest.foo x y\n  = do { c <- System.IO.getChar;\n         GHC.Base.return c }"
      (showToks declToks) `shouldBe` "[(((18,1),(18,19)),ITlineComment \"-- leading comment\",\"-- leading comment\"),(((19,1),(19,1)),ITsemi,\"\"),(((19,1),(19,4)),ITvarid \"foo\",\"foo\"),(((19,5),(19,6)),ITvarid \"x\",\"x\"),(((19,7),(19,8)),ITvarid \"y\",\"y\"),(((19,9),(19,10)),ITequal,\"=\"),(((20,3),(20,5)),ITdo,\"do\"),(((20,6),(20,6)),ITvocurly,\"\"),(((20,6),(20,7)),ITvarid \"c\",\"c\"),(((20,8),(20,10)),ITlarrow,\"<-\"),(((20,11),(20,18)),ITvarid \"getChar\",\"getChar\"),(((21,6),(21,6)),ITsemi,\"\"),(((21,6),(21,12)),ITvarid \"return\",\"return\"),(((21,13),(21,14)),ITvarid \"c\",\"c\")]"

      -- Note: Although the tokens include leading and following
      -- comments, the SrcSpan must tie up with the original GHC
      -- SrcSpan in the AST
      (drawTreeEntry tm') `shouldBe`
            "((1,1),(21,14))\n|\n"++
            "+- ((1,1),(15,17))\n|\n"++
            "`- ((19,1),(21,14))\n"

    -- ---------------------------------

    it "gets the tokens for an added srcloc 1" $ do
      (t,toks) <- parsedFileDupDefDd1
      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head $ drop 6 decls

      let forest = mkTreeFromTokens toks
      let (tm',declToks) = getTokensFor True forest l

      (showGhc l) `shouldBe` "test/testdata/DupDef/Dd1.hs:4:1-18"
      (showSrcSpan l) `shouldBe` "((4,1),(4,19))"
      (showGhc decl) `shouldBe` "DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x"
      (showToks declToks) `shouldBe` "[(((4,1),(4,1)),ITsemi,\"\"),(((4,1),(4,9)),ITvarid \"toplevel\",\"toplevel\"),(((4,10),(4,11)),ITvarid \"x\",\"x\"),(((4,12),(4,13)),ITequal,\"=\"),(((4,14),(4,15)),ITvarid \"c\",\"c\"),(((4,16),(4,17)),ITstar,\"*\"),(((4,18),(4,19)),ITvarid \"x\",\"x\")]"

      let (tm'',newSpan,decl') = addDeclToksAfterSrcSpan tm' l (PlaceOffset 2 0 2) declToks decl
      (showGhc newSpan) `shouldBe` "test/testdata/DupDef/Dd1.hs:1048582:1-18"

      (SYB.showData SYB.Renamer 0 decl') `shouldBe` "\n(L {test/testdata/DupDef/Dd1.hs:1048582:1-18} \n (FunBind \n  (L {test/testdata/DupDef/Dd1.hs:1048582:1-8} {Name: DupDef.Dd1.toplevel}) \n  (False) \n  (MatchGroup \n   [\n    (L {test/testdata/DupDef/Dd1.hs:1048582:1-18} \n     (Match \n      [\n       (L {test/testdata/DupDef/Dd1.hs:1048582:10} \n        (VarPat {Name: x}))] \n      (Nothing) \n      (GRHSs \n       [\n        (L {test/testdata/DupDef/Dd1.hs:4:14-18} \n         (GRHS \n          [] \n          (L {test/testdata/DupDef/Dd1.hs:1048582:14-18} \n           (OpApp \n            (L {test/testdata/DupDef/Dd1.hs:1048582:14} \n             (HsVar {Name: DupDef.Dd1.c})) \n            (L {test/testdata/DupDef/Dd1.hs:1048582:16} \n             (HsVar {Name: GHC.Num.*})) {Fixity: infixl 7} \n            (L {test/testdata/DupDef/Dd1.hs:1048582:18} \n             (HsVar {Name: x}))))))] \n       (EmptyLocalBinds))))] {!type placeholder here?!}) \n  (WpHole) {NameSet: \n  [{Name: DupDef.Dd1.c}]} \n  (Nothing)))"

      (drawTreeEntry tm'') `shouldBe`
            "((1,1),(32,18))\n|\n"++
            "+- ((1,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "+- ((1000006,1),(1000006,19))\n|\n"++
            "`- ((6,1),(32,18))\n"

    -- ---------------------------------

    it "gets the tokens for an added srcloc with one line spacing" $ do
      (t,toks) <- parsedFileDupDefDd1
      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let forest = mkTreeFromTokens toks

      let decl@(GHC.L l _) = head $ drop 6 decls
      let (tm',declToks) = getTokensFor True forest l
      (drawTreeEntry tm') `shouldBe`
            "((1,1),(32,18))\n|\n"++
            "+- ((1,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "`- ((6,1),(32,18))\n"

      (showGhc l) `shouldBe` "test/testdata/DupDef/Dd1.hs:4:1-18"
      (showSrcSpan l) `shouldBe` "((4,1),(4,19))"
      (showGhc decl) `shouldBe` "DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x"
      (showToks declToks) `shouldBe` "[(((4,1),(4,1)),ITsemi,\"\"),(((4,1),(4,9)),ITvarid \"toplevel\",\"toplevel\"),(((4,10),(4,11)),ITvarid \"x\",\"x\"),(((4,12),(4,13)),ITequal,\"=\"),(((4,14),(4,15)),ITvarid \"c\",\"c\"),(((4,16),(4,17)),ITstar,\"*\"),(((4,18),(4,19)),ITvarid \"x\",\"x\")]"

      let Just (GHC.L _ n) = locToName (4, 2) renamed
      let typeSig = head $ definingSigsNames [n] renamed
      let (GHC.L ln _) = typeSig
      (showSrcSpan ln) `shouldBe` "((3,1),(3,31))"
      let (tm'',sigToks) = getTokensFor True tm' ln
      (drawTreeEntry tm'') `shouldBe`
            "((1,1),(32,18))\n|\n"++
            "+- ((1,1),(3,31))\n|  |\n"++
            "|  +- ((1,1),(1,24))\n|  |\n"++
            "|  `- ((3,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "`- ((6,1),(32,18))\n"

      let (tm''',newSpan,typeSig') = addDeclToksAfterSrcSpan tm'' l (PlaceOffset 2 0 0) sigToks typeSig
      (showGhc newSpan) `shouldBe` "test/testdata/DupDef/Dd1.hs:1048582:1-30"

      (SYB.showData SYB.Renamer 0 typeSig') `shouldBe` "\n(L {test/testdata/DupDef/Dd1.hs:1048582:1-30} \n (TypeSig \n  [\n   (L {test/testdata/DupDef/Dd1.hs:1048582:1-8} {Name: DupDef.Dd1.toplevel})] \n  (L {test/testdata/DupDef/Dd1.hs:1048582:13-30} \n   (HsFunTy \n    (L {test/testdata/DupDef/Dd1.hs:1048582:13-19} \n     (HsTyVar {Name: GHC.Integer.Type.Integer})) \n    (L {test/testdata/DupDef/Dd1.hs:1048582:24-30} \n     (HsTyVar {Name: GHC.Integer.Type.Integer}))))))"

      (drawTreeEntry tm''') `shouldBe`
            "((1,1),(32,18))\n|\n"++
            "+- ((1,1),(3,31))\n|  |\n"++
            "|  +- ((1,1),(1,24))\n|  |\n"++
            "|  `- ((3,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "+- ((1000006,1),(1000006,31))\n|\n"++
            "`- ((6,1),(32,18))\n"
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
      let (tm'''',_newSpan',_decl') = addDeclToksAfterSrcSpan tm''' newSpan (PlaceOffset 1 0 2) declToks decl
      -- (showGhc newSpan') `shouldBe` "test/testdata/DupDef/Dd1.hs:1000006:1-30"

      (drawTreeEntry tm'''') `shouldBe`
            "((1,1),(32,18))\n|\n"++
            "+- ((1,1),(3,31))\n|  |\n"++
            "|  +- ((1,1),(1,24))\n|  |\n"++
            "|  `- ((3,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "+- ((1000006,1),(1000006,31))\n|\n"++
            "+- ((1000007,1),(1000007,19))\n|\n"++
            "`- ((6,1),(32,18))\n"

    -- ---------------------------------

    it "gets the tokens for an added indented srcloc" $ do
      (t,toks) <- parsedFileDupDefDd1
      let renamed = fromJust $ GHC.tm_renamed_source t
      let forest = mkTreeFromTokens toks

      let Just (GHC.L _ n) = locToName (23, 5) renamed
      (showGhc n) `shouldBe` "zz"

      let sspan = posToSrcSpan forest ((23,5),(23,11))
      (showGhc sspan) `shouldBe` "test/testdata/DupDef/Dd1.hs:23:5-10"

      let (tm1,declToks) = getTokensFor True forest sspan
      (GHC.showRichTokenStream declToks) `shouldBe` "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n     zz = 1"
      (drawTreeEntry tm1) `shouldBe`
           "((1,1),(32,18))\n|\n"++
           "+- ((1,1),(22,8))\n|\n"++
           "+- ((23,5),(23,11))\n|\n"++
           "`- ((25,1),(32,18))\n"

      let (tm2,newSpan) = addToksAfterSrcSpan tm1 sspan (PlaceIndent 1 0 1) declToks
      (showGhc newSpan) `shouldBe` "test/testdata/DupDef/Dd1.hs:1048600:5-10"
      (drawTreeEntry tm2) `shouldBe`
           "((1,1),(32,18))\n|\n"++
           "+- ((1,1),(22,8))\n|\n"++
           "+- ((23,5),(23,11))\n|\n"++
           "+- ((1000024,5),(1000024,11))\n|\n"++
           "`- ((25,1),(32,18))\n"

    -- ---------------------------------

    it "gets the tokens after adding and renaming" $ do
      (t,toks) <- parsedFileDupDefDd1
      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let forest = mkTreeFromTokens toks

      let decl@(GHC.L l _) = head $ drop 6 decls
      (showSrcSpanF l) `shouldBe` "(((False,0,0,4),1),((False,0,0,4),19))"
      let (tm',declToks) = getTokensFor True forest l
      (drawTreeEntry tm') `shouldBe`
            "((1,1),(32,18))\n|\n"++
            "+- ((1,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "`- ((6,1),(32,18))\n"

      (showGhc l) `shouldBe` "test/testdata/DupDef/Dd1.hs:4:1-18"
      (showSrcSpan l) `shouldBe` "((4,1),(4,19))"
      (showGhc decl) `shouldBe` "DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x"
      (showToks declToks) `shouldBe` "[(((4,1),(4,1)),ITsemi,\"\"),(((4,1),(4,9)),ITvarid \"toplevel\",\"toplevel\"),(((4,10),(4,11)),ITvarid \"x\",\"x\"),(((4,12),(4,13)),ITequal,\"=\"),(((4,14),(4,15)),ITvarid \"c\",\"c\"),(((4,16),(4,17)),ITstar,\"*\"),(((4,18),(4,19)),ITvarid \"x\",\"x\")]"

      let Just (GHC.L _ n) = locToName (4, 2) renamed
      let typeSig = head $ definingSigsNames [n] renamed
      let (GHC.L ln _) = typeSig
      (showSrcSpan ln) `shouldBe` "((3,1),(3,31))"
      let (tm'',sigToks) = getTokensFor True tm' ln
      (drawTreeEntry tm'') `shouldBe`
            "((1,1),(32,18))\n|\n"++
            "+- ((1,1),(3,31))\n|  |\n"++
            "|  +- ((1,1),(1,24))\n|  |\n"++
            "|  `- ((3,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "`- ((6,1),(32,18))\n"

      let (tm''',newSpan,typeSig') = addDeclToksAfterSrcSpan tm'' l (PlaceOffset 2 0 0) sigToks typeSig
      -- (showSrcSpanF newSpan) `shouldBe` "test/testdata/DupDef/Dd1.hs:1048582:1-30"
      (showSrcSpanF newSpan) `shouldBe` "(((False,0,1,6),1),((False,0,1,6),31))"

      (SYB.showData SYB.Renamer 0 typeSig') `shouldBe` "\n(L {test/testdata/DupDef/Dd1.hs:1048582:1-30} \n (TypeSig \n  [\n   (L {test/testdata/DupDef/Dd1.hs:1048582:1-8} {Name: DupDef.Dd1.toplevel})] \n  (L {test/testdata/DupDef/Dd1.hs:1048582:13-30} \n   (HsFunTy \n    (L {test/testdata/DupDef/Dd1.hs:1048582:13-19} \n     (HsTyVar {Name: GHC.Integer.Type.Integer})) \n    (L {test/testdata/DupDef/Dd1.hs:1048582:24-30} \n     (HsTyVar {Name: GHC.Integer.Type.Integer}))))))"

      (drawTreeEntry tm''') `shouldBe`
            "((1,1),(32,18))\n|\n"++
            "+- ((1,1),(3,31))\n|  |\n"++
            "|  +- ((1,1),(1,24))\n|  |\n"++
            "|  `- ((3,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "+- ((1000006,1),(1000006,31))\n|\n"++
            "`- ((6,1),(32,18))\n"

      -- getToksForSpan test/testdata/DupDef/Dd1.hs:1048582:1-30:("(((False,0,1,6),1),((False,0,1,6),31))"
      let sspan3 = posToSrcSpan forest $
                        (((forestLineToGhcLine $ ForestLine False 0 1 6),1),
                         ((forestLineToGhcLine $ ForestLine False 0 1 6),31) )
      let (tm4,toks4) = getTokensFor True tm''' sspan3
      (drawTreeEntry tm4) `shouldBe`
            "((1,1),(32,18))\n|\n"++
            "+- ((1,1),(3,31))\n|  |\n"++
            "|  +- ((1,1),(1,24))\n|  |\n"++
            "|  `- ((3,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "+- ((1000006,1),(1000006,31))\n|\n"++
            "`- ((6,1),(32,18))\n"

      -- putToksForSpan test/testdata/DupDef/Dd1.hs:1048582:1-30:(((False,0,1,6),1),((False,0,1,6),31))
      -- NOTE: shortcut, using same toks, it is the book-keeping we
      -- are testing
      let (tm5,_sspan5,tree5) = updateTokensForSrcSpan tm4 sspan3 toks4
      (drawTreeEntry tm5) `shouldBe`
            "((1,1),(32,18))\n|\n"++
            "+- ((1,1),(3,31))\n|  |\n"++
            "|  +- ((1,1),(1,24))\n|  |\n"++
            "|  `- ((3,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "+- ((10001000006,1),(10001000006,31))\n|\n"++
            "`- ((6,1),(32,18))\n"

      -- putDeclToksAfterSpan test/testdata/DupDef/Dd1.hs:1048582:1-30:("(((False,0,1,6),1),((False,0,1,6),31))",PlaceIndent 1 0 2

      -- --
      let newSpan = posToSrcSpan tm5 ((7,1),(7,19))
      (showSrcSpanF newSpan) `shouldBe` "(((False,0,0,7),1),((False,0,0,7),19))"
      -- let (forest',newSpan') = addNewSrcSpanAndToksAfter tm5 sspan3 newSpan (PlaceIndent 1 0 2) declToks

      let z = openZipperToSpan (srcSpanToForestSpan sspan3) $ Z.fromTree tm5
      (show $ treeStartEnd (Z.tree z))    `shouldBe` "(((ForestLine True 0 1 6),1),((ForestLine True 0 1 6),31))"
      (show (srcSpanToForestSpan sspan3)) `shouldBe` "(((ForestLine False 0 1 6),1),((ForestLine False 0 1 6),31))"
      (show $ treeStartEnd (Z.tree z) == (srcSpanToForestSpan sspan3)) `shouldBe` "True"

      let f1 = insertSrcSpan tm5 (srcSpanToForestSpan sspan3)
      (drawTreeEntry f1) `shouldBe`
            "((1,1),(32,18))\n|\n"++
            "+- ((1,1),(3,31))\n|  |\n"++
            "|  +- ((1,1),(1,24))\n|  |\n"++
            "|  `- ((3,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "+- ((10001000006,1),(10001000006,31))\n|\n"++
            "`- ((6,1),(32,18))\n"

      let (forest',_tree) = getSrcSpanFor tm5 (srcSpanToForestSpan sspan3)
      (drawTreeEntry forest') `shouldBe`
            "((1,1),(32,18))\n|\n"++
            "+- ((1,1),(3,31))\n|  |\n"++
            "|  +- ((1,1),(1,24))\n|  |\n"++
            "|  `- ((3,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "+- ((10001000006,1),(10001000006,31))\n|\n"++
            "`- ((6,1),(32,18))\n"
      -- --

      let (tm6,_sspan6) = addToksAfterSrcSpan tm5 sspan3 (PlaceIndent 1 0 2) declToks
      (drawTreeEntry tm6) `shouldBe`
            "((1,1),(32,18))\n|\n"++
            "+- ((1,1),(3,31))\n|  |\n"++
            "|  +- ((1,1),(1,24))\n|  |\n"++
            "|  `- ((3,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "+- ((10001000006,1),(10001000006,31))\n|\n"++
            "+- ((1000007,1),(1000007,19))\n|\n"++
            "`- ((6,1),(32,18))\n"

      -- Context set up at last, actual test:
      -- getToksForSpan test/testdata/DupDef/Dd1.hs:1048583:1-18:("(((False,0,1,7),1),((False,0,1,7),19))"
      let sspan4 = posToSrcSpan forest $
                        (((forestLineToGhcLine $ ForestLine False 0 1 7),1),
                         ((forestLineToGhcLine $ ForestLine False 0 1 7),19) )
      let (tm7,toks7) = getTokensFor True tm6 sspan4
      (drawTreeEntry tm7) `shouldBe`
            "((1,1),(32,18))\n|\n"++
            "+- ((1,1),(3,31))\n|  |\n"++
            "|  +- ((1,1),(1,24))\n|  |\n"++
            "|  `- ((3,1),(3,31))\n|\n"++
            "+- ((4,1),(4,19))\n|\n"++
            "+- ((10001000006,1),(10001000006,31))\n|\n"++
            "+- ((1000007,1),(1000007,19))\n|\n"++
            "`- ((6,1),(32,18))\n"

      (show toks7) `shouldBe` "[((((7,1),(7,1)),ITsemi),\"\"),((((7,1),(7,9)),ITvarid \"toplevel\"),\"toplevel\"),((((7,10),(7,11)),ITvarid \"x\"),\"x\"),((((7,12),(7,13)),ITequal),\"=\"),((((7,14),(7,15)),ITvarid \"c\"),\"c\"),((((7,16),(7,17)),ITstar),\"*\"),((((7,18),(7,19)),ITvarid \"x\"),\"x\"),((((9,1),(9,1)),ITvocurly),\"\")]"

    -- ---------------------------------

    it "gets the tokens after renaming" $ do
      (t,toks) <- parsedFileLiftD1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t
      -- let decls = hsBinds renamed
      let forest = mkTreeFromTokens toks

      -- putToksForSpan test/testdata/LiftToToplevel/D1.hs:6:24:(((False,0,0,6),24),((False,0,0,6),25))
      -- [((((0,1),(0,3)),ITvarid "sq"),"sq"),((((0,4),(0,5)),IToparen),"("),((((0,5),(0,6)),ITvarid "x"),"x"),((((0,7),(0,10)),ITvarid "pow"),"pow"),((((0,10),(0,11)),ITcparen),")")]

      let sspan1 = posToSrcSpan forest $
                        (((forestLineToGhcLine $ ForestLine False 0 0 6),24),
                         ((forestLineToGhcLine $ ForestLine False 0 0 6),25) )
      newToks <- liftIO $ basicTokenise "sq (x pow)"
      (show newToks) `shouldBe` "[((((0,1),(0,3)),ITvarid \"sq\"),\"sq\"),((((0,4),(0,5)),IToparen),\"(\"),((((0,5),(0,6)),ITvarid \"x\"),\"x\"),((((0,7),(0,10)),ITvarid \"pow\"),\"pow\"),((((0,10),(0,11)),ITcparen),\")\")]"

      let (tm2,_sspan2,tree2) = updateTokensForSrcSpan forest sspan1 newToks
      (drawTreeEntry tm2) `shouldBe`
            "((1,1),(13,25))\n|\n"++
            "+- ((1,1),(6,23))\n|\n"++
            "+- ((10000000006,24),(10000000006,34))\n|\n"++
            "`- ((6,26),(13,25))\n"

      -- putToksAfterPos ((8,6),(8,8)) at PlaceAdjacent:[((((0,2),(0,5)),ITvarid "pow"),"pow")]
      let sspan2 = posToSrcSpan forest $
                        (((forestLineToGhcLine $ ForestLine False 0 0 8),6),
                         ((forestLineToGhcLine $ ForestLine False 0 0 8),8) )
      toks3 <- liftIO $ basicTokenise " pow"
      (show toks3) `shouldBe` "[((((0,2),(0,5)),ITvarid \"pow\"),\"pow\")]"
      let toks3' = map markToken toks3
      (show toks3') `shouldBe` "[((((0,2),(0,5)),ITvarid \"pow\"),\"pow\")]"
      let (tm3,newSpan3) = addToksAfterSrcSpan tm2 sspan2 PlaceAdjacent toks3'
      (showSrcSpanF newSpan3) `shouldBe` "(((False,0,1,8),9),((False,0,1,8),12))"
      -- (show tm3) `shouldBe` ""
      (drawTreeEntry tm3) `shouldBe`
            "((1,1),(13,25))\n|\n"++
            "+- ((1,1),(6,23))\n|\n"++
            "+- ((10000000006,24),(10000000006,34))\n|\n"++
            "`- ((6,26),(13,25))\n   |\n"++
            "   +- ((6,26),(7,8))\n   |\n"++
            "   +- ((8,6),(8,8))\n   |\n"++
            "   +- ((1000008,9),(1000008,12))\n   |\n"++
            "   `- ((8,9),(13,25))\n"
      (invariant tm3) `shouldBe` []

      -- The test ....
      -- getToksForSpan test/testdata/LiftToToplevel/D1.hs:8:6-19:("(((False,0,0,8),6),((False,0,0,8),20))",
      let sspan3 = posToSrcSpan forest $
                        (((forestLineToGhcLine $ ForestLine False 0 0 8),6),
                         ((forestLineToGhcLine $ ForestLine False 0 0 8),20) )

      let (tm4,toks4) = getTokensFor True tm3 sspan3
      (drawTreeEntry tm4) `shouldBe`
            "((1,1),(13,25))\n|\n"++
            "+- ((1,1),(6,23))\n|\n"++
            "+- ((10000000006,24),(10000000006,34))\n|\n"++
            "`- ((6,26),(13,25))\n   |\n"++
            "   +- ((6,26),(7,8))\n   |\n"++
            "   +- ((8,6),(8,20))\n   |  |\n"++
            "   |  +- ((8,6),(8,8))\n   |  |\n"++
            "   |  +- ((1000008,9),(1000008,12))\n   |  |\n"++
            "   |  `- ((8,9),(8,20))\n   |\n"++
            "   `- ((9,6),(13,25))\n"
{-
            "((1,1),(13,25))\n|\n"++
            "+- ((1,1),(6,23))\n|\n"++
            "+- ((10000000006,24),(10000000006,34))\n|\n"++
            "`- ((6,26),(13,25))\n   |\n"++
            "   +- ((6,26),(7,8))\n   |\n"++
            "   +- ((8,6),(8,20))\n   |\n"++
            "   `- ((9,6),(13,25))\n"
-}

{-
tree TId 0:
((1,1),(11,18))
|
+- ((1,1),(6,23))
|
+- ((10000000006,24),(10000000006,34))
|
`- ((6,26),(11,18))
   |
   +- ((6,26),(7,8))
   |
   +- ((8,6),(8,20))
   |
   `- ((8,21),(11,18))
-}


      (showToks toks4) `shouldBe` "[(((8,6),(8,6)),ITvocurly,\"\"),(((8,6),(8,8)),ITvarid \"sq\",\"sq\"),(((8,9),(8,12)),ITvarid \"pow\",\"pow\"),(((8,9),(8,10)),ITvarid \"x\",\"x\"),(((8,11),(8,12)),ITequal,\"=\"),(((8,13),(8,14)),ITvarid \"x\",\"x\"),(((8,15),(8,16)),ITvarsym \"^\",\"^\"),(((8,17),(8,20)),ITvarid \"pow\",\"pow\")]"

    -- ---------------------------------

    it "gets the tokens after updating a SrcSpan" $ do
      (t,toks) <- parsedFileLiftLetIn1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t
      -- let decls = hsBinds renamed
      let forest = mkTreeFromTokens toks

      -- putToksForSpan test/testdata/LiftToToplevel/LetIn1.hs:12:22-23:(((False,0,0,12),22),((False,0,0,12),24))
      -- [((((0,1),(0,2)),IToparen),"("),((((0,2),(0,4)),ITvarid "sq"),"sq"),((((0,5),(0,8)),ITvarid "pow"),"pow"),((((0,8),(0,9)),ITcparen),")")]

      let sspan1 = posToSrcSpan forest $
                        (((forestLineToGhcLine $ ForestLine False 0 0 12),22),
                         ((forestLineToGhcLine $ ForestLine False 0 0 12),24) )
--
      let ff = insertSrcSpan forest (fs sspan1)
      (drawTreeEntry ff) `shouldBe`
            "((1,1),(16,22))\n|\n"++
            "+- ((1,1),(11,32))\n|\n"++
            "+- ((12,22),(12,24))\n|\n"++
            "`- ((12,25),(16,22))\n"
      -- (show ff) `shouldBe` ""
--
      newToks <- liftIO $ basicTokenise "(sq pow)"
      (show newToks) `shouldBe` "[((((0,1),(0,2)),IToparen),\"(\"),((((0,2),(0,4)),ITvarid \"sq\"),\"sq\"),((((0,5),(0,8)),ITvarid \"pow\"),\"pow\"),((((0,8),(0,9)),ITcparen),\")\")]"

      let (tm2,_sspan2,tree2) = updateTokensForSrcSpan forest sspan1 newToks
      -- (show tm2) `shouldBe` ""
      (drawTreeEntry tm2) `shouldBe`
            "((1,1),(16,22))\n|\n"++
            "+- ((1,1),(11,32))\n|\n"++
            "+- ((10000000012,22),(10000000012,30))\n|\n"++
            "`- ((12,25),(16,22))\n"

      -- putToksForSpan test/testdata/LiftToToplevel/LetIn1.hs:12:29-30:(((False,0,0,12),29),((False,0,0,12),31))
      -- [((((0,1),(0,2)),IToparen),"("),((((0,2),(0,4)),ITvarid "sq"),"sq"),((((0,5),(0,8)),ITvarid "pow"),"pow"),((((0,8),(0,9)),ITcparen),")")]

      let sspan2 = posToSrcSpan forest $
                        (((forestLineToGhcLine $ ForestLine False 0 0 12),29),
                         ((forestLineToGhcLine $ ForestLine False 0 0 12),31) )
      newToks2 <- liftIO $ basicTokenise "(sq pow)"
      (show newToks2) `shouldBe` "[((((0,1),(0,2)),IToparen),\"(\"),((((0,2),(0,4)),ITvarid \"sq\"),\"sq\"),((((0,5),(0,8)),ITvarid \"pow\"),\"pow\"),((((0,8),(0,9)),ITcparen),\")\")]"

      let (tm3,_sspan3,tree3) = updateTokensForSrcSpan tm2 sspan2 newToks2
      (drawTreeEntry tm3) `shouldBe`
            "((1,1),(16,22))\n|\n"++
            "+- ((1,1),(11,32))\n|\n"++
            "+- ((10000000012,22),(10000000012,30))\n|\n"++
            "`- ((12,25),(16,22))\n   |\n"++
            "   +- ((12,25),(12,28))\n   |\n"++
            "   +- ((10000000012,29),(10000000012,37))\n   |\n"++
            "   `- ((12,32),(16,22))\n"


      -- The test ....
      -- getToksForSpan test/testdata/LiftToToplevel/LetIn1.hs:12:22-32:("(((False,0,0,12),22),((False,0,0,12),33))"
      let sspan4 = posToSrcSpan forest $
                        (((forestLineToGhcLine $ ForestLine False 0 0 12),22),
                         ((forestLineToGhcLine $ ForestLine False 0 0 12),33) )
      --

      let f1 = insertSrcSpan tm3 (srcSpanToForestSpan sspan4)
      -- (show f1) `shouldBe` ""
      (drawTreeEntry f1) `shouldBe`
            "((1,1),(16,22))\n|\n"++
            "+- ((1,1),(11,32))\n|\n"++
            "+- ((12,22),(12,33))\n|  |\n"++
            "|  +- ((10000000012,22),(10000000012,30))\n|  |\n"++
            "|  +- ((12,25),(12,28))\n|  |\n"++
            "|  +- ((10000000012,29),(10000000012,37))\n|  |\n"++
            "|  `- ((12,32),(12,33))\n|\n"++
            "`- ((13,24),(16,22))\n"

      let ss1 = posToSrcSpan forest $
                        (((forestLineToGhcLine $ ForestLine False 0 0  1), 1),
                         ((forestLineToGhcLine $ ForestLine False 0 0 12),21) )
      let ss2 = posToSrcSpan forest $
                        (((forestLineToGhcLine $ ForestLine True  0 0 12),22),
                         ((forestLineToGhcLine $ ForestLine True  0 0 12),30) )
      let ss3 = posToSrcSpan forest $
                        (((forestLineToGhcLine $ ForestLine False 0 0 12),25),
                         ((forestLineToGhcLine $ ForestLine False 0 0 16),22) )


      (show $ containsEnd (((ForestLine True 0 0 12),22),((ForestLine True 0 0 12),30)) (srcSpanToForestSpan sspan4)) `shouldBe` "False"
      (show $ containsMiddle (((ForestLine True 0 0 12),22),((ForestLine True 0 0 12),30)) (srcSpanToForestSpan sspan4)) `shouldBe` "True"

      (show $ containsEnd (((ForestLine False 0 0 12),25),((ForestLine False 0 0 16),22)) (srcSpanToForestSpan sspan4)) `shouldBe` "True"
      (show $ containsMiddle (((ForestLine False 0 0 12),25),((ForestLine False 0 0 16),22)) (srcSpanToForestSpan sspan4)) `shouldBe` "False"

      (show $ containsMiddle (((ForestLine False 0 0 12),25),((ForestLine False 0 0 12),28)) (srcSpanToForestSpan sspan4)) `shouldBe` "True"

      (show $ containsMiddle (((ForestLine True 0 0 12),29),((ForestLine True 0 0 12),37)) (srcSpanToForestSpan sspan4)) `shouldBe` "False"
      (show $ containsEnd    (((ForestLine True 0 0 12),29),((ForestLine True 0 0 12),37)) (srcSpanToForestSpan sspan4)) `shouldBe` "True"


      (show $ containsMiddle (((ForestLine False 0 0 12),32),((ForestLine False 0 0 16),22)) (srcSpanToForestSpan sspan4)) `shouldBe` "False"

      let (b1,m1@[m1a,m1b],e1) = splitSubtree tm3 (srcSpanToForestSpan sspan4)
      -- (show (b1,m1,e1)) `shouldBe` "([],[],[])"

      let (b2,m2,e2) = splitSubtree m1b (srcSpanToForestSpan sspan4)
      -- (show (b2,m2,e2)) `shouldBe` "([],[],[])"


      -- let (f2,t2) = getSrcSpanFor tm3 (srcSpanToForestSpan sspan4)

      -- (show t2) `shouldBe` ""
      --
      {-
      (show tm3) `shouldBe` ""
      Node {rootLabel = Entry (((ForestLine False 0 0 12),32),((ForestLine False 0 0 16),22)) 
        [((((12,32),(12,33)),ITvarid \"y\"),\"y\"),
         ((((13,24),(13,29)),ITwhere),\"where\"),
      -}
      let ss2f@(ss2fs,ss2fe)        = srcSpanToForestSpan ss2
      let sspan4f@(sspan4s,sspan4e) = srcSpanToForestSpan sspan4
      (show (ss2f,sspan4f)) `shouldBe` "((((ForestLine True 0 0 12),22),((ForestLine True 0 0 12),30)),"++
                                       "(((ForestLine False 0 0 12),22),((ForestLine False 0 0 12),33)))"
      -- (ss2fe >= sspan4s,ss2fe <= sspan4e) `shouldBe` (True,False)
      (containsStart ss2f sspan4f,containsEnd ss2f sspan4f) `shouldBe` (True,False)

      let (tm5,toks5) = getTokensFor True tm3 sspan4

      -- (showTree tm3) `shouldBe` ""

      (GHC.showRichTokenStream toks5) `shouldBe`
         "\n\n\n\n\n\n\n\n\n\n\n                      (sq pow)x + (sq pow)y"
      -- (showToks toks5) `shouldBe` ""

      (drawTreeEntry tm5) `shouldBe`
            "((1,1),(16,22))\n|\n"++
            "+- ((1,1),(11,32))\n|\n"++
            "+- ((12,22),(12,33))\n|  |\n"++
            "|  +- ((10000000012,22),(10000000012,30))\n|  |\n"++
            "|  +- ((12,25),(12,28))\n|  |\n"++
            "|  +- ((10000000012,29),(10000000012,37))\n|  |\n"++
            "|  `- ((12,32),(12,33))\n|\n"++
            "`- ((13,24),(16,22))\n"

  -- ---------------------------------------------

  describe "getTokensBefore" $ do
    it "gets the tokens before a given srcloc" $ do
      (t,toks) <- parsedFileMoveDefMd1
      let renamed = fromJust $ GHC.tm_renamed_source t
      -- let decls = hsBinds renamed

      let forest = mkTreeFromTokens toks

      let sspan = posToSrcSpan forest ((24,5),(24,11))

      let (tm',toksSpan) = getTokensFor True forest sspan

      (showGhc sspan) `shouldBe` "test/testdata/MoveDef/Md1.hs:24:5-10"
      (showSrcSpan sspan) `shouldBe` "((24,5),(24,11))"
      (showToks toksSpan) `shouldBe` "[(((24,5),(24,5)),ITvocurly,\"\"),(((24,5),(24,7)),ITvarid \"zz\",\"zz\"),(((24,8),(24,9)),ITequal,\"=\"),(((24,10),(24,11)),ITinteger 1,\"1\")]"


      (drawTreeEntry tm') `shouldBe`
            "((1,1),(40,17))\n|\n"++
            "+- ((1,1),(23,8))\n|\n"++
            "+- ((24,5),(24,11))\n|\n"++
            "`- ((26,1),(40,17))\n"

      let (tm'',toksBefore) = getTokensBefore tm' sspan
      (showToks $ drop 100 $ unReverseToks toksBefore) `shouldBe` "[(((22,10),(22,11)),ITvarsym \"+\",\"+\"),(((22,12),(22,14)),ITvarid \"zz\",\"zz\"),(((23,3),(23,8)),ITwhere,\"where\")]"

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

      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"
      (showForestSpan (fs l)) `shouldBe` "((19,1),(21,14))"
      (drawTreeEntry forest') `shouldBe`
            "((1,1),(21,14))\n|\n"++
            "+- ((1,1),(15,17))\n|\n"++
            "`- ((19,1),(21,14))\n"

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
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
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
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
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
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
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

      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
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

      (showGhc l) `shouldBe` "test/testdata/DupDef/Dd3.hs:3:29"
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

  describe "containment" $ do
    it "checks containsStart,containsMiddle and containsEnd" $ do
      let sspan@(s,e) = (((ForestLine False 0 0 24),1),((ForestLine False 0 0 24),4))
      let nspan@(ns,ne) = (((ForestLine False 0 1 24),1),((ForestLine False 0 1 26),14))

      (show $ compare s ns) `shouldBe` "LT"

      -- "0" ++ (show $ s >= ns) `shouldBe` "0True"
      "1" ++ (show $ s <= ne) `shouldBe` "1True"

      "2" ++ (show $ containsStart  nspan sspan) `shouldBe` "2False"
      "3" ++ (show $ containsMiddle nspan sspan) `shouldBe` "3False"
      "4" ++ (show $ containsEnd    nspan sspan) `shouldBe` "4False"


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
      (showForestSpan $ treeStartEnd tree4) `shouldBe` "((19,1),(21,14))"

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (begin,middle,end) = splitForestOnSpan (subForest forest) (fs l)
      (map showForestSpan $ map treeStartEnd begin) `shouldBe`
             ["((1,1),(8,8))","((8,9),(13,4))","((13,5),(15,17))"]
      (map showForestSpan $ map treeStartEnd middle) `shouldBe` ["((19,1),(21,14))"]
      (show $ map treeStartEnd end) `shouldBe` "[]"

  -- ---------------------------------------------

  describe "insertSrcSpan" $ do
    it "checks that the forest is split into two parts" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      --
      let z = openZipperToSpan (fs l) $ Z.fromTree forest
      let toksz = retrieveTokensInterim $ Z.tree z
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
              "((1,1),(21,14))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "`- ((19,1),(21,14))\n" -- our inserted span

    -- -----------------------

    it "inserts a span above others, if it spans them" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let forest' = insertSrcSpan forest (fs l)
      (invariant forest') `shouldBe` []
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(21,14))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "`- ((19,1),(21,14))\n" -- our inserted span

      let l' = posToSrcSpan forest' ((8,1),(10,10))
      (showGhc l') `shouldBe` "test/testdata/TokenTest.hs:(8,1)-(10,9)"
      (showSrcSpan l') `shouldBe` "((8,1),(10,10))"

      let forest'' = insertSrcSpan forest' (fs l')
      (invariant forest'') `shouldBe` []
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(21,14))\n|\n"++
              "+- ((1,1),(15,17))\n|  |\n"++
              "|  +- ((1,1),(6,14))\n|  |\n"++
              "|  +- ((8,1),(10,10))\n|  |\n"++ -- our inserted span
              "|  `- ((13,1),(15,17))\n|\n"++
              "`- ((19,1),(21,14))\n"

    ------------------------------------

    it "does not delete existing versioned spans" $ do
      (_t,toks) <- parsedFileDemoteD1
      let forest = mkTreeFromTokens toks

      let sspan = posToSrcSpan forest ((6,21),(6,41))
      (showGhc sspan) `shouldBe` "test/testdata/Demote/D1.hs:6:21-40"
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
               "+- ((1000007,5),(1000008,20))\n|\n"++
               "`- ((7,1),(13,25))\n"

      -- Context set up, now for the test.

      let sspan2 = posToSrcSpan forest ((9,1),(9,14))
      (showGhc sspan2) `shouldBe` "test/testdata/Demote/D1.hs:9:1-13"

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
               "+- ((1000007,5),(1000008,20))\n|\n"++
               "`- ((7,1),(13,25))\n   |\n"++
               "   +- ((7,1),(7,18))\n   |\n"++
               "   +- ((9,1),(9,14))\n   |\n"++
               "   `- ((11,1),(13,25))\n"

    ------------------------------------

    it "insert a span after deleting one" $ do
      (_t,toks) <- parsedFileLiftLetIn1Ghc
      let forest = mkTreeFromTokens toks

      -- getToksForSpan test/testdata/LiftToToplevel/LetIn1.hs:12:22-32

      let sspan = posToSrcSpan forest ((12,22),(12,33))
      (showGhc sspan) `shouldBe` "test/testdata/LiftToToplevel/LetIn1.hs:12:22-32"
      (showSrcSpan sspan) `shouldBe` "((12,22),(12,33))"

      -- let forest1 = insertSrcSpan forest (fs sspan)
      let (forest1,declToks) = getTokensFor True forest sspan
      -- (show forest1) `shouldBe` ""

      -- removeToksForPos ((10,22),(11,32))
      let sspan2 = posToSrcSpan forest ((10,22),(11,32))
      let (f2,_t2) = removeSrcSpan forest1 (srcSpanToForestSpan sspan2)

      (invariant f2) `shouldBe` []
      (drawTreeEntry f2) `shouldBe`
            "((1,1),(16,22))\n|\n"++
            "+- ((1,1),(11,32))\n|  |\n"++
            "|  +- ((1,1),(10,21))\n|  |\n"++
            "|  `- ((10,22),(11,32))(1,-13)D\n|\n"++
            "+- ((12,22),(12,33))\n|\n"++
            "`- ((13,24),(16,22))\n"

      -- Context in place, time for test




      -- putToksForSpan test/testdata/LiftToToplevel/LetIn1.hs:(10,18)-(12,32):
      (show declToks) `shouldBe` "[((((12,19),(12,19)),ITvccurly),\"\"),((((12,19),(12,21)),ITin),\"in\"),((((12,22),(12,24)),ITvarid \"sq\"),\"sq\"),((((12,25),(12,26)),ITvarid \"x\"),\"x\"),((((12,27),(12,28)),ITvarsym \"+\"),\"+\"),((((12,29),(12,31)),ITvarid \"sq\"),\"sq\"),((((12,32),(12,33)),ITvarid \"y\"),\"y\")]"

      -- putToksForSpan test/testdata/LiftToToplevel/LetIn1.hs:(10,18)-(12,32)
      let sspan3 = posToSrcSpan forest ((10,18),(12,33))

--
      let (b1,m1,e1) = splitSubtree f2 (srcSpanToForestSpan sspan3)
      -- (show (b1,m1,e1)) `shouldBe` "([],[],[])"

--


      let (f3,_newSpan3,_tree3) = updateTokensForSrcSpan f2 sspan3 declToks

      (invariant f3) `shouldBe` []
      (drawTreeEntry f3) `shouldBe`
            "((1,1),(16,22))\n|\n"++
            "+- ((1,1),(10,17))\n|\n"++
            "+- ((10000000010,21),(10000000010,32))\n|\n"++
            "`- ((13,24),(16,22))\n"

    ------------------------------------

    it "manipulates the Token Tree without breaking the invariant" $ do
      (_t,toks) <- parsedFileLiftLetIn1Ghc
      let forest = mkTreeFromTokens toks


      -- putToksForSpan test/testdata/LiftToToplevel/LetIn1.hs:12:22-23:(((False,0,0,12),22),((False,0,0,12),24))
      newToks1 <- liftIO $ basicTokenise "(sq pow)"
      (show newToks1) `shouldBe` "[((((0,1),(0,2)),IToparen),\"(\"),((((0,2),(0,4)),ITvarid \"sq\"),\"sq\"),((((0,5),(0,8)),ITvarid \"pow\"),\"pow\"),((((0,8),(0,9)),ITcparen),\")\")]"

      let sspan1 = posToSrcSpan forest ((12,22),(12,24))

      let (f2,_newSpan2,_tree2) = updateTokensForSrcSpan forest sspan1 newToks1

      (invariant f2) `shouldBe` []
      (drawTreeEntry f2) `shouldBe`
               "((1,1),(16,22))\n|\n"++
               "+- ((1,1),(11,32))\n|\n"++
               "+- ((10000000012,22),(10000000012,30))\n|\n"++
               "`- ((12,25),(16,22))\n"


      -- putToksForSpan test/testdata/LiftToToplevel/LetIn1.hs:12:29-30:(((False,0,0,12),29),((False,0,0,12),31))
      (show newToks1) `shouldBe` "[((((0,1),(0,2)),IToparen),\"(\"),((((0,2),(0,4)),ITvarid \"sq\"),\"sq\"),((((0,5),(0,8)),ITvarid \"pow\"),\"pow\"),((((0,8),(0,9)),ITcparen),\")\")]"

      let sspan2 = posToSrcSpan forest ((12,29),(12,31))

      let (f3,_newSpan3,_tree3) = updateTokensForSrcSpan f2 sspan2 newToks1

      (invariant f3) `shouldBe` []
      (drawTreeEntry f3) `shouldBe`
            "((1,1),(16,22))\n|\n"++
            "+- ((1,1),(11,32))\n|\n"++
            "+- ((10000000012,22),(10000000012,30))\n|\n"++
            "`- ((12,25),(16,22))\n   |\n"++
            "   +- ((12,25),(12,28))\n   |\n"++
            "   +- ((10000000012,29),(10000000012,37))\n   |\n"++
            "   `- ((12,32),(16,22))\n"


      -- getToksForSpan test/testdata/LiftToToplevel/LetIn1.hs:10:25:("(((False,0,0,10),25),((False,0,0,10),26))",[((((10,25),(10,26)),ITinteger 0),"0")])
      let sspan3 = posToSrcSpan forest ((10,25),(10,26))
      let (f4,toks4) = getTokensFor True f3 sspan3

      (invariant f4) `shouldBe` []
      (drawTreeEntry f4) `shouldBe`
            "((1,1),(16,22))\n|\n"++
            "+- ((1,1),(11,32))\n|  |\n"++
            "|  +- ((1,1),(10,24))\n|  |\n"++
            "|  +- ((10,25),(10,26))\n|  |\n"++
            "|  `- ((10,26),(11,32))\n|\n"++
            "+- ((10000000012,22),(10000000012,30))\n|\n"++
            "`- ((12,25),(16,22))\n   |\n"++
            "   +- ((12,25),(12,28))\n   |\n"++
            "   +- ((10000000012,29),(10000000012,37))\n   |\n"++
            "   `- ((12,32),(16,22))\n"

      -- putToksForSpan test/testdata/LiftToToplevel/LetIn1.hs:10:25:(((False,0,0,10),25),((False,0,0,10),26))
      newToks2 <- liftIO $ basicTokenise "pow" -- TODO: check that
                                               -- using basicTokenise
                                               -- here is ok
      -- (show newToks2) `shouldBe` "[((((10,26),(10,29)),ITvarid \"pow\"),\"pow\")]"
      let (f5,_newSpan5,_tree5) = updateTokensForSrcSpan f4 sspan3 newToks2

      (invariant f5) `shouldBe` []
      (drawTreeEntry f5) `shouldBe`
            "((1,1),(16,22))\n|\n"++
            "+- ((1,1),(11,32))\n|  |\n"++
            "|  +- ((1,1),(10,24))\n|  |\n"++
            "|  +- ((10000000010,25),(10000000010,28))\n|  |\n"++
            "|  `- ((10,26),(11,32))\n|\n"++
            "+- ((10000000012,22),(10000000012,30))\n|\n"++
            "`- ((12,25),(16,22))\n   |\n"++
            "   +- ((12,25),(12,28))\n   |\n"++
            "   +- ((10000000012,29),(10000000012,37))\n   |\n"++
            "   `- ((12,32),(16,22))\n"


      -- putToksAfterSpan test/testdata/LiftToToplevel/LetIn1.hs:10:25:(((False,0,0,10),25),((False,0,0,10),26)) at PlaceAdjacent:[(((10,25),(10,26)),ITinteger 0,"0")]
      let sspan5 = posToSrcSpan forest ((10,25),(10,26))
      newToks3 <- liftIO $ basicTokenise "0"
      (show newToks3) `shouldBe` "[((((0,1),(0,2)),ITinteger 0),\"0\")]"
      let (f6,_newSpan6) = addToksAfterSrcSpan f5 sspan5 PlaceAdjacent newToks3

      (invariant f6) `shouldBe` []
      (drawTreeEntry f6) `shouldBe`
            "((1,1),(16,22))\n|\n"++
            "+- ((1,1),(11,32))\n|  |\n"++
            "|  +- ((1,1),(10,24))\n|  |\n"++
            "|  +- ((10000000010,25),(10000000010,28))\n|  |  |\n"++
            "|  |  +- ((10,25),(10,26))\n|  |  |\n"++
            "|  |  `- ((1000010,29),(1000010,30))\n|  |\n"++
            "|  `- ((10,26),(11,32))\n|\n"++
            "+- ((10000000012,22),(10000000012,30))\n|\n"++
            "`- ((12,25),(16,22))\n   |\n"++
            "   +- ((12,25),(12,28))\n   |\n"++
            "   +- ((10000000012,29),(10000000012,37))\n   |\n"++
            "   `- ((12,32),(16,22))\n"


      -- getToksForSpan test/testdata/LiftToToplevel/LetIn1.hs:11:25:("(((False,0,0,11),25),((False,0,0,11),26))",[((((11,25),(11,26)),ITvarid "z"),"z")])

      let sspan6 = posToSrcSpan forest ((11,25),(11,26))
      let (f7,toks7) = getTokensFor True f6 sspan6

      (invariant f7) `shouldBe` []
      (drawTreeEntry f7) `shouldBe`
            "((1,1),(16,22))\n|\n"++
            "+- ((1,1),(11,32))\n|  |\n"++
            "|  +- ((1,1),(10,24))\n|  |\n"++
            "|  +- ((10000000010,25),(10000000010,28))\n|  |  |\n"++
            "|  |  +- ((10,25),(10,26))\n|  |  |\n"++
            "|  |  `- ((1000010,29),(1000010,30))\n|  |\n"++
            "|  `- ((10,26),(11,32))\n|     |\n"++
            "|     +- ((10,26),(11,24))\n|     |\n"++
            "|     +- ((11,25),(11,26))\n|     |\n"++
            "|     `- ((11,26),(11,32))\n|\n"++
            "+- ((10000000012,22),(10000000012,30))\n|\n"++
            "`- ((12,25),(16,22))\n   |\n"++
            "   +- ((12,25),(12,28))\n   |\n"++
            "   +- ((10000000012,29),(10000000012,37))\n   |\n"++
            "   `- ((12,32),(16,22))\n"

      -- putToksForSpan test/testdata/LiftToToplevel/LetIn1.hs:11:25:(((False,0,0,11),25),((False,0,0,11),26))[((((11,26),(11,29)),ITvarid "pow"),"pow")]

      let (f8,_newSpan8,_tree8) = updateTokensForSrcSpan f7 sspan6 newToks2

      (invariant f8) `shouldBe` []
      (drawTreeEntry f8) `shouldBe`
            "((1,1),(16,22))\n|\n"++
            "+- ((1,1),(11,32))\n|  |\n"++
            "|  +- ((1,1),(10,24))\n|  |\n"++
            "|  +- ((10000000010,25),(10000000010,28))\n|  |  |\n"++
            "|  |  +- ((10,25),(10,26))\n|  |  |\n"++
            "|  |  `- ((1000010,29),(1000010,30))\n|  |\n"++
            "|  `- ((10,26),(11,32))\n|     |\n"++
            "|     +- ((10,26),(11,24))\n|     |\n"++
            "|     +- ((10000000011,25),(10000000011,28))\n|     |\n"++
            "|     `- ((11,26),(11,32))\n|\n"++
            "+- ((10000000012,22),(10000000012,30))\n|\n"++
            "`- ((12,25),(16,22))\n   |\n"++
            "   +- ((12,25),(12,28))\n   |\n"++
            "   +- ((10000000012,29),(10000000012,37))\n   |\n"++
            "   `- ((12,32),(16,22))\n"


      -- putToksAfterSpan test/testdata/LiftToToplevel/LetIn1.hs:11:25:(((False,0,0,11),25),((False,0,0,11),26)) at PlaceAdjacent:[(((11,25),(11,26)),ITvarid "z","z")]

      newToks4 <- liftIO $ basicTokenise "z"
      (show newToks4) `shouldBe` "[((((0,1),(0,2)),ITvarid \"z\"),\"z\")]"
      let (f9,_newSpan9) = addToksAfterSrcSpan f8 sspan6 PlaceAdjacent newToks4

      (invariant f9) `shouldBe` []
      (drawTreeEntry f9) `shouldBe`
            "((1,1),(16,22))\n|\n"++
            "+- ((1,1),(11,32))\n|  |\n"++
            "|  +- ((1,1),(10,24))\n|  |\n"++
            "|  +- ((10000000010,25),(10000000010,28))\n|  |  |\n"++
            "|  |  +- ((10,25),(10,26))\n|  |  |\n"++
            "|  |  `- ((1000010,29),(1000010,30))\n|  |\n"++
            "|  `- ((10,26),(11,32))\n|     |\n"++
            "|     +- ((10,26),(11,24))\n|     |\n"++
            "|     +- ((10000000011,25),(10000000011,28))\n|     |  |\n"++
            "|     |  +- ((11,25),(11,26))\n|     |  |\n"++
            "|     |  `- ((1000011,29),(1000011,30))\n|     |\n"++
            "|     `- ((11,26),(11,32))\n|\n"++
            "+- ((10000000012,22),(10000000012,30))\n|\n"++
            "`- ((12,25),(16,22))\n   |\n"++
            "   +- ((12,25),(12,28))\n   |\n"++
            "   +- ((10000000012,29),(10000000012,37))\n   |\n"++
            "   `- ((12,32),(16,22))\n"

      -- Context in place, time for test

      -- getToksForSpan test/testdata/LiftToToplevel/LetIn1.hs:(10,22)-(11,31)
      let sspan9 = posToSrcSpan forest ((10,22),(11,31))
      let (f10,_toks10) = getTokensFor True f9 sspan9

--
      let z = openZipperToSpan (fs sspan9) $ Z.fromTree f9
      -- let (before,middle,end) = doSplitTree (Z.tree z) (fs sspan9)
      let (before,middle,end) = splitSubtree (Z.tree z) (fs sspan9)
      (show (map treeStartEnd before,map treeStartEnd middle,map treeStartEnd end)) `shouldBe`
               "([],"++
               "[(((ForestLine False 0 0 1),1),((ForestLine False 0 0 10),24)),"++
                "(((ForestLine True 0 0 10),25),((ForestLine True 0 0 10),28)),"++
                "(((ForestLine False 0 0 10),26),((ForestLine False 0 0 11),32))],"++
               "[])"
      let (b2,m2,e2) = splitSubToks (head middle) (fs sspan9)
      -- (show (b2,m2,e2)) `shouldBe` ""
      let (b3,m3,e3) = splitSubtree (last middle) (fs sspan9)
      (show (map treeStartEnd b3,map treeStartEnd m3,map treeStartEnd  e3)) `shouldBe` 
               "([],"++
               "[(((ForestLine False 0 0 10),26),((ForestLine False 0 0 11),24)),"++
                "(((ForestLine True 0 0 11),25),((ForestLine True 0 0 11),28)),"++
                "(((ForestLine False 0 0 11),26),((ForestLine False 0 0 11),32))],"++
               "[])"
      let ss9 = (((ForestLine False 0 0 11),26),((ForestLine False 0 0 12),21))
      (show (containsStart ss9 (fs sspan9),containsEnd ss9 (fs sspan9))) `shouldBe` "(False,True)"
      let (b4,m4,e4) = splitSubToks (last m3) (fs sspan9)
      -- (show (b4,m4,e4)) `shouldBe` ""
--

      (drawTreeEntry f10) `shouldBe`
            "((1,1),(16,22))\n|\n"++
            "+- ((1,1),(11,32))\n|  |\n"++
            "|  +- ((1,1),(10,21))\n|  |\n"++
            "|  `- ((10,22),(11,31))\n|     |\n"++
            "|     +- ((10,22),(10,24))\n|     |\n"++
            "|     +- ((10000000010,25),(10000000010,28))\n|     |  |\n"++
            "|     |  +- ((10,25),(10,26))\n|     |  |\n"++
            "|     |  `- ((1000010,29),(1000010,30))\n|     |\n"++
            "|     +- ((10,26),(11,24))\n|     |\n"++
            "|     +- ((10000000011,25),(10000000011,28))\n|     |  |\n"++
            "|     |  +- ((11,25),(11,26))\n|     |  |\n"++
            "|     |  `- ((1000011,29),(1000011,30))\n|     |\n"++
            "|     `- ((11,26),(11,31))\n|\n"++
            "+- ((10000000012,22),(10000000012,30))\n|\n"++
            "`- ((12,25),(16,22))\n   |\n"++
            "   +- ((12,25),(12,28))\n   |\n"++
            "   +- ((10000000012,29),(10000000012,37))\n   |\n"++
            "   `- ((12,32),(16,22))\n"
      (invariant f10) `shouldBe` []

    ------------------------------------

    it "updates tokens without breaking things" $ do
      (_t,toks) <- parsedFileGhc "./test/testdata/LiftToToplevel/PatBindIn3.hs"
      let forest = mkTreeFromTokens toks


      -- putToksForSpan test/testdata/LiftToToplevel/PatBindIn3.hs:9:16-17:(((False,0,0,9),16),((False,0,0,9),18))
      newToks1 <- liftIO $ basicTokenise "(sq x pow)"
      (show newToks1) `shouldBe` "[((((0,1),(0,2)),IToparen),\"(\"),((((0,2),(0,4)),ITvarid \"sq\"),\"sq\"),((((0,5),(0,6)),ITvarid \"x\"),\"x\"),((((0,7),(0,10)),ITvarid \"pow\"),\"pow\"),((((0,10),(0,11)),ITcparen),\")\")]"

      let sspan1 = posToSrcSpan forest ((9,16),(9,18))

      let (f2,_newSpan2,_tree2) = updateTokensForSrcSpan forest sspan1 newToks1

      (invariant f2) `shouldBe` []
      (drawTreeEntry f2) `shouldBe`
               "((1,1),(15,22))\n|\n"++
               "+- ((1,1),(9,15))\n|\n"++
               "+- ((10000000009,16),(10000000009,26))\n|\n"++
               "`- ((9,19),(15,22))\n"
      let toks2 = retrieveTokensFinal f2
      (GHC.showRichTokenStream toks2) `shouldBe` "module LiftToToplevel.PatBindIn3 where\n\n --A definition can be lifted from a where or let to the top level binding group.\n --Lifting a definition widens the scope of the definition.\n\n --In this example, lift 'sq' defined in 'sumSquares'\n --This example aims to test changing a constant to a function.\n\n sumSquares x = (sq x pow)+ sq\n            where\n               sq = x^pow\n               pow =2\n\n anotherFun 0 y = sq y\n      where sq x = x^2\n\n "

      -- putToksForSpan test/testdata/LiftToToplevel/PatBindIn3.hs:9:21-22:(((False,0,0,9),21),((False,0,0,9),23))
      (show newToks1) `shouldBe` "[((((0,1),(0,2)),IToparen),\"(\"),((((0,2),(0,4)),ITvarid \"sq\"),\"sq\"),((((0,5),(0,6)),ITvarid \"x\"),\"x\"),((((0,7),(0,10)),ITvarid \"pow\"),\"pow\"),((((0,10),(0,11)),ITcparen),\")\")]"

      let sspan2 = posToSrcSpan forest ((9,21),(9,23))

--
      -- (show f2) `shouldBe` ""
{-
      let z = openZipperToSpan (fs sspan2) $ Z.fromTree f2
      (Z.isLeaf z) `shouldBe` True

      let (forest',tree@(Node (Entry _s _) _)) = getSrcSpanFor f2 (fs sspan2)
      (drawTreeEntry forest') `shouldBe`
               "((1,1),(15,22))\n|\n"++
               "+- ((1,1),(9,15))\n|\n"++
               "+- ((10000000009,16),(10000000009,26))\n|\n"++
               "`- ((9,19),(15,22))\n   |\n"++
               "   +- ((9,19),(9,20))\n   |\n"++
               "   +- ((9,21),(9,23))\n   |\n"++
               "   `- ((10,12),(15,22))\n"

      let zf = openZipperToNode tree $ Z.fromTree forest'
      (show zf) `shouldBe` ""
-}
--

      let (f3,_newSpan3,_tree3) = updateTokensForSrcSpan f2 sspan2 newToks1
      (invariant f3) `shouldBe` []
      (drawTreeEntry f3) `shouldBe`
               "((1,1),(15,22))\n|\n"++
               "+- ((1,1),(9,15))\n|\n"++
               "+- ((10000000009,16),(10000000009,26))\n|\n"++
               "`- ((9,19),(15,22))\n   |\n"++
               "   +- ((9,19),(9,20))\n   |\n"++
               "   +- ((10000000009,21),(10000000009,31))\n   |\n"++
               "   `- ((10,12),(15,22))\n"
      let toks3 = retrieveTokensFinal f3
      (GHC.showRichTokenStream toks3) `shouldBe` "module LiftToToplevel.PatBindIn3 where\n\n --A definition can be lifted from a where or let to the top level binding group.\n --Lifting a definition widens the scope of the definition.\n\n --In this example, lift 'sq' defined in 'sumSquares'\n --This example aims to test changing a constant to a function.\n\n sumSquares x = (sq x pow)+ (sq x pow)\n            where\n               sq = x^pow\n               pow =2\n\n anotherFun 0 y = sq y\n      where sq x = x^2\n\n "

    ------------------------------------

    it "allocates comments in an if then else expression" $ do
      (_t,toks) <- parsedFileGhc "./test/testdata/Case/C.hs"
      let t1 = mkTreeFromTokens toks

      -- getToksForSpan test/testdata/Case/C.hs:5:12-18:("(((False,0,0,5),12),((False,0,0,5),19))
      let s1 = posToSrcSpan t1 $
                 (((forestLineToGhcLine $ ForestLine False 0 0 5),12),
                  ((forestLineToGhcLine $ ForestLine False 0 0 5),19) )
      (showGhc s1) `shouldBe` "test/testdata/Case/C.hs:5:12-18"
      let t2 = insertSrcSpan t1 (fs s1)

      -- getToksForSpan test/testdata/Case/C.hs:7:13-19:("(((False,0,0,7),13),((False,0,0,7),20))
      let s2 = posToSrcSpan t1 $
                 (((forestLineToGhcLine $ ForestLine False 0 0 7),13),
                  ((forestLineToGhcLine $ ForestLine False 0 0 7),20) )
      (showGhc s2) `shouldBe` "test/testdata/Case/C.hs:7:13-19"
      let t3 = insertSrcSpan t2 (fs s2)

-- innards of insertSrcSpan
      let sspan = fs s2
      let z = openZipperToSpan (fs s2) $ Z.fromTree t2
      (Z.isLeaf z) `shouldBe` True
      let (Entry _ toks) = Z.label z
      let (tokStartPos,tokEndPos) = forestSpanToSimpPos sspan

      (GHC.showRichTokenStream toks) `shouldBe` "\n\n\n\n\n           then -- This is an odd result\n             bob x 1\n           else -- This is an even result\n             bob x 2\n\n bob x y = x + y\n\n "

      let (startLoc,endLoc) = startEndLocIncComments' toks (tokStartPos,tokEndPos)
      -- let (startLoc,endLoc) = startEndLocIncCommentsDebug toks (tokStartPos,tokEndPos)
      (show (tokStartPos,tokEndPos)) `shouldBe` "((7,13),(7,20))"
      (show (startLoc,endLoc)) `shouldBe` "((6,11),(7,20))"
--


      -- getToksForSpan test/testdata/Case/C.hs:9:13-19:("(((False,0,0,9),13),((False,0,0,9),20))  
      let s3 = posToSrcSpan t1 $
                 (((forestLineToGhcLine $ ForestLine False 0 0 9),13),
                  ((forestLineToGhcLine $ ForestLine False 0 0 9),20) )
      (showGhc s3) `shouldBe` "test/testdata/Case/C.hs:9:13-19"
      let t4 = insertSrcSpan t3 (fs s3)

      (drawTreeEntry t4) `shouldBe`
            "((1,1),(11,16))\n|\n"++
            "+- ((1,1),(5,11))\n|\n"++
            "+- ((5,12),(5,19))\n|\n"++
            "`- ((7,13),(11,16))\n   |\n"++
            "   +- ((7,13),(7,20))\n   |\n"++
            "   `- ((9,13),(11,16))\n      |\n"++
            "      +- ((9,13),(9,20))\n      |\n"++
            "      `- ((11,1),(11,16))\n"

      let (_,thenToks) = getTokensFor False t4 s2
      let (_,elseToks) = getTokensFor False t4 s3

      (GHC.showRichTokenStream thenToks) `shouldBe`
           "\n\n\n\n\n           "++
           -- "-- This is an odd result\n             bob x 1"
           "then -- This is an odd result\n             bob x 1"
      (GHC.showRichTokenStream elseToks) `shouldBe`
           "\n\n\n\n\n\n\n           "++
           "else -- This is an even result\n             bob x 2"

  -- ---------------------------------------------

  describe "removeSrcSpan" $ do
    it "removes a span from the forest" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let forest' = insertSrcSpan forest (fs l)
      (invariant forest') `shouldBe` []
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(21,14))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "`- ((19,1),(21,14))\n" -- our inserted span

      let (forest'',delTree) = removeSrcSpan forest' (fs l)
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(21,14))\n|\n"++
               "+- ((1,1),(15,17))\n|\n"++
               "`- ((19,1),(21,14))(2,0)D\n" -- removed again

      (invariant forest'') `shouldBe` []

      (drawTreeEntry delTree) `shouldBe`
              "((19,1),(21,14))\n" -- removed again

      let toks' = retrieveTokensFinal forest''
      -- (showToks toks') `shouldBe` ""
      (GHC.showRichTokenStream toks') `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment"

    -- ---------------------------------

    it "removes a span and tokens that were not explicitly in the forest" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head $ drop 1 decls
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(13,1)-(15,16)"
      (showSrcSpan l) `shouldBe` "((13,1),(15,17))"

      let (forest',delTree) = removeSrcSpan forest (fs l)
      (invariant forest') `shouldBe` []
      (drawTreeEntry forest') `shouldBe`
               "((1,1),(21,14))\n|\n"++
               "+- ((1,1),(10,10))\n|\n"++
               "+- ((13,1),(15,17))(3,-16)D\n|\n"++
               "`- ((19,1),(21,14))\n"

      (drawTreeEntry delTree) `shouldBe`
              "((13,1),(15,17))\n" -- removed again

      let toks' = retrieveTokensFinal forest'
      -- (showToks toks') `shouldBe` ""
      (GHC.showRichTokenStream toks') `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n\n\n\n "

    -- ---------------------------------

    it "Removes a span and tokens without destroying the forest 1" $ do
      (_t,toks) <- parsedFileDemoteD1
      let forest = mkTreeFromTokens toks

      let sspan = posToSrcSpan forest ((6,21),(6,41))
      (showGhc sspan) `shouldBe` "test/testdata/Demote/D1.hs:6:21-40"
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
               "+- ((1000007,5),(1000008,20))\n|\n"++
               "`- ((7,1),(13,25))\n"

      -- Context set up, now for the test.

      let sspan2 = posToSrcSpan forest ((9,1),(9,14))
      (showGhc sspan2) `shouldBe` "test/testdata/Demote/D1.hs:9:1-13"
      let (forest3,delTree) = removeSrcSpan forest2 (fs sspan2)

      (drawTreeEntry $ insertSrcSpan forest2 (fs sspan2)) `shouldBe`
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(6,20))\n|\n"++
               "+- ((6,21),(6,41))\n|\n"++
               "+- ((1000007,5),(1000008,20))\n|\n"++
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
               "+- ((1000007,5),(1000008,20))\n|\n"++
               "`- ((7,1),(13,25))\n   |\n"++
               "   +- ((7,1),(7,18))\n   |\n"++
               "   +- ((9,1),(9,14))(2,-13)D\n   |\n"++
               "   `- ((11,1),(13,25))\n"

      let toks' = retrieveTokensFinal forest3
      -- (showToks toks') `shouldBe` ""
      (GHC.showRichTokenStream toks') `shouldBe` "module Demote.D1 where\n\n {-demote 'sq' to 'sumSquares'. This refactoring\n  affects module 'D1' and 'C1' -}\n\n sumSquares (x:xs) = sq x + sumSquares xs\n     where\n        sq = x ^ pow\n      \n\n \n sumSquares [] = 0\n\n pow = 2\n\n main = sumSquares [1..4]\n\n "

    -- ---------------------------------

    it "removes a span and tokens without destroying the forest 2" $ do
      (_t,toks) <- parsedFileGhc "./test/testdata/Demote/WhereIn6.hs"
      let forest = mkTreeFromTokens toks
      let tk = initTokenCache toks

      -- removeToksForPos ((13,1),(13,21))
      let sspan = posToSrcSpan forest ((13,1),(13,21))
      (showGhc sspan) `shouldBe` "test/testdata/Demote/WhereIn6.hs:13:1-20"

      let tk2 = removeToksFromCache tk sspan
      (drawTokenCache tk2) `shouldBe`
               "tree TId 0:\n"++
               "((1,1),(13,21))\n|\n"++
               "+- ((1,1),(11,25))\n|\n"++
               "`- ((13,1),(13,21))(2,0)D\n"++
               "tree TId 1:\n"++
               "((100000013,1),(100000013,21))\n"

      -- putToksForSpan test/testdata/Demote/WhereIn6.hs:100000013:16:[((((0,1),(0,2)),ITvarid "x"),"x")]
      -- let ss2 = posToSrcSpan forest ((100000013,16),(100000013,17))
      let ss2 = posToSrcSpan forest $ (((forestLineToGhcLine $ ForestLine False 1 0 13),16),
                                       ((forestLineToGhcLine $ ForestLine False 1 0 13),17) )

      -- (showGhc ss2) `shouldBe` "test/testdata/Demote/WhereIn6.hs:100000013:16"
      (showGhc ss2) `shouldBe` "test/testdata/Demote/WhereIn6.hs:33554445:16"
      (showSrcSpanF ss2) `shouldBe` "(((False,1,0,13),16),((False,1,0,13),17))"
      toks2 <- basicTokenise "x"
      (show toks2) `shouldBe` "[((((0,1),(0,2)),ITvarid \"x\"),\"x\")]"
      let (tk3,_ss2') = putToksInCache tk2 ss2 toks2
      (drawTokenCache tk3) `shouldBe`
               "tree TId 0:\n"++
               "((1,1),(13,21))\n|\n"++
               "+- ((1,1),(11,25))\n|\n"++
               "`- ((13,1),(13,21))(2,0)D\n"++
               "tree TId 1:\n"++
               "((100000013,1),(100000013,21))\n|\n"++
               "+- ((100000013,1),(100000013,16))\n|\n"++
               "+- ((10100000013,16),(10100000013,17))\n|\n"++
               "`- ((100000013,17),(100000013,21))\n"++
               "tree TId 2:\n"++
               "((200000013,16),(200000013,17))\n"

      -- (show $ retrieveTokensInterim $ getTreeFromCache ss2 tk3) `shouldBe` "" 
      -- (show $ getTreeFromCache ss2 tk3) `shouldBe` ""
      (GHC.showRichTokenStream $ retrieveTokensInterim $ getTreeFromCache ss2 tk3) `shouldBe` 
                "\n\n\n\n\n\n\n\n\n\n\n\n addthree a b c=x+b+c"

      -- putToksForSpan test/testdata/Demote/WhereIn6.hs:100000013:18:[((((0,1),(0,2)),ITvarid "y"),"y")]
      -- let ss3 = posToSrcSpan forest ((100000013,18),(100000013,19))
      let ss3 = posToSrcSpan forest $ (((forestLineToGhcLine $ ForestLine False 1 0 13),18),
                                       ((forestLineToGhcLine $ ForestLine False 1 0 13),19) )

      -- (showGhc ss3) `shouldBe` "test/testdata/Demote/WhereIn6.hs:100000013:18"
      (showGhc ss3) `shouldBe` "test/testdata/Demote/WhereIn6.hs:33554445:18"
      (showSrcSpanF ss3) `shouldBe` "(((False,1,0,13),18),((False,1,0,13),19))"
      toks3 <- basicTokenise "y"
      (show toks3) `shouldBe` "[((((0,1),(0,2)),ITvarid \"y\"),\"y\")]"
      let (tk4,_ss3') = putToksInCache tk3 ss3 toks3
      (drawTokenCache tk4) `shouldBe`
               "tree TId 0:\n"++
               "((1,1),(13,21))\n|\n"++
               "+- ((1,1),(11,25))\n|\n"++
               "`- ((13,1),(13,21))(2,0)D\n"++
               "tree TId 1:\n"++
               "((100000013,1),(100000013,21))\n|\n"++
               "+- ((100000013,1),(100000013,16))\n|\n"++
               "+- ((10100000013,16),(10100000013,17))\n|\n"++
               "`- ((100000013,17),(100000013,21))\n   |\n"++
               "   +- ((100000013,17),(100000013,18))\n   |\n"++
               "   +- ((10100000013,18),(10100000013,19))\n   |\n"++
               "   `- ((100000013,19),(100000013,21))\n"++
               "tree TId 2:\n"++
               "((200000013,16),(200000013,17))\n"++
               "tree TId 3:\n"++
               "((300000013,18),(300000013,19))\n"

      (GHC.showRichTokenStream $ retrieveTokensInterim $ getTreeFromCache ss2 tk4) `shouldBe` 
                "\n\n\n\n\n\n\n\n\n\n\n\n addthree a b c=x+y+c"



      -- Context set up, now for the test.
{-
      let sspan2 = posToSrcSpan forest ((9,1),(9,14))
      (showGhc sspan2) `shouldBe` "test/testdata/Demote/D1.hs:9:1-13"
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
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let forest' = insertSrcSpan forest (fs l)
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(21,14))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "`- ((19,1),(21,14))\n" -- our inserted span

      let toksClean = reverse $ dropWhile isEmpty $ reverse toks

      let toks' = retrieveTokensFinal forest'
      (show toks') `shouldBe` (show toksClean)

  -- ---------------------------------------------

  describe "retrieveTokensFinal" $ do
    it "extracts all the tokens from the leaves of the trees, in order, realigned" $ do
      pending

  -- ---------------------------------------------

  describe "monotonicLineToks" $ do
    it "makes sure the tokens are in strictly increasing order of line" $ do
      pending

  -- ---------------------------------------------

  describe "updateTokensForSrcSpan" $ do
    it "replaces the tokens for a given span, inserting the span if needed" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"
      (showGhc decl) `shouldBe` "TokenTest.foo x y\n  = do { c <- System.IO.getChar;\n         GHC.Base.return c }"

      let (forest',newSpan,_) = updateTokensForSrcSpan forest l (take 3 toks)
      -- (showGhc newSpan) `shouldBe` "test/testdata/TokenTest.hs:(18,1)-(1000018,22)"
      (showGhc newSpan) `shouldBe` "test/testdata/TokenTest.hs:1073741843:1-22"
      (showSrcSpanF newSpan) `shouldBe` "(((True,0,0,19),1),((True,0,0,19),23))"

      (drawTreeEntry forest') `shouldBe`
              "((1,1),(21,14))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "`- ((10000000019,1),(10000000019,23))\n"  -- our inserted span

      let toks' = retrieveTokensFinal forest'
      (GHC.showRichTokenStream toks') `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n module TokenTest where"

    -- --------------------------------------

    it "replaces the tokens for a given span, and returns all the tokens later" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let toks' = retrieveTokensInterim tree
      let (forest'',sspan) = addNewSrcSpanAndToksAfter forest' l l (PlaceOffset 2 0 2) toks'

      (invariant forest'') `shouldBe` []
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(21,14))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++
              "`- ((1000019,1),(1000021,14))\n" -- our inserted span

      (showSrcSpanF sspan) `shouldBe` "(((False,0,1,19),1),((False,0,1,21),14))"

      let Just (GHC.L ln n) = locToName (19, 1) renamed
      (showGhc n) `shouldBe` "TokenTest.foo"
      (showGhc ln) `shouldBe` "test/testdata/TokenTest.hs:19:1-3"

      let (_tree,toksForOp) = getTokensFor True forest'' l

      let (GHC.L _ ghcTok,_) = head toks
      let newTok = mkToken ghcTok (19,1) "bbb"

      let newToks = replaceTokNoReAlign toksForOp (19,1) newTok
      (show newToks) `shouldBe`   "[((((18,1),(18,19)),ITlineComment \"-- leading comment\"),\"-- leading comment\"),((((19,1),(19,1)),ITsemi),\"\"),((((19,1),(19,4)),ITmodule),\"bbb\"),((((19,5),(19,6)),ITvarid \"x\"),\"x\"),((((19,7),(19,8)),ITvarid \"y\"),\"y\"),((((19,9),(19,10)),ITequal),\"=\"),((((20,3),(20,5)),ITdo),\"do\"),((((20,6),(20,6)),ITvocurly),\"\"),((((20,6),(20,7)),ITvarid \"c\"),\"c\"),((((20,8),(20,10)),ITlarrow),\"<-\"),((((20,11),(20,18)),ITvarid \"getChar\"),\"getChar\"),((((21,6),(21,6)),ITsemi),\"\"),((((21,6),(21,12)),ITvarid \"return\"),\"return\"),((((21,13),(21,14)),ITvarid \"c\"),\"c\")]"

      let (forest''',_newSpan,_) = updateTokensForSrcSpan forest'' l newToks

      let toksFinal = retrieveTokensFinal forest'''

      -- (show toksFinal) `shouldBe` ""
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n bbb x y =\n   do c <- getChar\n      return c\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n "

    -- --------------------------------------

    it "replaces the tokens for a given span, removing any sub tree" $ do
       pending -- "write this"

    -- --------------------------------------

    it "replaces a single token" $ do
      (_t,toks) <- parsedFileDemoteWhereIn4
      let forest = mkTreeFromTokens toks

      let ss1 = posToSrcSpan forest ((11,18),(11,22))
      (showGhc ss1) `shouldBe` "test/testdata/Demote/WhereIn4.hs:11:18-21"
      (showSrcSpan ss1) `shouldBe` "((11,18),(11,22))"

      ss1Tok <- liftIO $ tokenise (realSrcLocFromTok mkZeroToken) 0 True "sq"
      (show ss1Tok) `shouldBe` "[((((0,0),(0,2)),ITvarid \"sq\"),\"sq\")]"

      let (forest2,_ss1',_) = updateTokensForSrcSpan forest ss1 ss1Tok

      (drawTreeEntry forest2) `shouldBe` 
           "((1,1),(18,23))\n|\n"++
           "+- ((1,1),(11,17))\n|\n"++
           "+- ((10000000011,18),(10000000011,20))\n|\n"++
           "`- ((11,23),(18,23))\n"

      -- (show forest2) `shouldBe` ""

      let ss2 = posToSrcSpan forest ((11,27),(11,31))
      (showGhc ss2) `shouldBe` "test/testdata/Demote/WhereIn4.hs:11:27-30"
      (showSrcSpan ss2) `shouldBe` "((11,27),(11,31))"

      ss2Tok <- liftIO $ tokenise (realSrcLocFromTok mkZeroToken) 0 True "sq"
      (show ss2Tok) `shouldBe` "[((((0,0),(0,2)),ITvarid \"sq\"),\"sq\")]"

      let (forest3,_ss2',_) = updateTokensForSrcSpan forest2 ss2 ss2Tok

      (drawTreeEntry forest3) `shouldBe` 
           "((1,1),(18,23))\n|\n"++
           "+- ((1,1),(11,17))\n|\n"++
           "+- ((10000000011,18),(10000000011,20))\n|\n"++
           "`- ((11,23),(18,23))\n   |\n"++
           "   +- ((11,23),(11,26))\n   |\n"++
           "   +- ((10000000011,27),(10000000011,29))\n   |\n"++
           "   `- ((11,32),(18,23))\n"

      -- (show forest2) `shouldBe` ""
{-
      (drawTreeEntry $ insertSrcSpan forest2 (fs ss2)) `shouldBe` 
           "((1,1),(20,1))\n|\n"++
           "+- ((1,1),(11,17))\n|\n"++
           "+- ((11,18),(1000011,20))\n|\n"++
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
      (showGhc ss3) `shouldBe` "test/testdata/Demote/WhereIn4.hs:15:14-16"
      (showSrcSpan ss3) `shouldBe` "((15,14),(15,17))"

      ss3Tok <- liftIO $ tokenise (realSrcLocFromTok mkZeroToken) 0 True "p"
      (show ss3Tok) `shouldBe` "[((((0,0),(0,1)),ITvarid \"p\"),\"p\")]"

      let (forest4,_ss3',_) = updateTokensForSrcSpan forest3 ss3 ss3Tok
      -- (show forest4) `shouldBe` ""
      (drawTreeEntry forest4) `shouldBe`
           "((1,1),(18,23))\n|\n"++
           "+- ((1,1),(11,17))\n|\n"++
           "+- ((10000000011,18),(10000000011,20))\n|\n"++
           "`- ((11,23),(18,23))\n   |\n"++
           "   +- ((11,23),(11,26))\n   |\n"++
           "   +- ((10000000011,27),(10000000011,29))\n   |\n"++
           "   `- ((11,32),(18,23))\n      |\n"++
           "      +- ((11,32),(15,14))\n      |\n"++
           "      +- ((10000000015,14),(10000000015,15))\n      |\n"++
           "      `- ((17,1),(18,23))\n"

    -- --------------------------------------

    it "replaces a single token,without disturbing adjacent ones" $ do
      (_t,toks) <- parsedFileGhc "./test/testdata/Demote/WhereIn6.hs"

      let forest = mkTreeFromTokens toks
      let tk = initTokenCache toks

      -- removeToksForPos ((13,1),(13,21))
      let sspan = posToSrcSpan forest ((13,1),(13,21))
      (showGhc sspan) `shouldBe` "test/testdata/Demote/WhereIn6.hs:13:1-20"

      -- (showToks toks) `shouldBe` ""
      let tk2 = removeToksFromCache tk sspan
      (drawTokenCache tk2) `shouldBe`
               "tree TId 0:\n"++
               "((1,1),(13,21))\n|\n"++
               "+- ((1,1),(11,25))\n|\n"++
               "`- ((13,1),(13,21))(2,0)D\n"++
               "tree TId 1:\n"++
               "((100000013,1),(100000013,21))\n"

      -- let ss2 = posToSrcSpan forest ((100000013,16),(100000013,17))
      let ss2 = posToSrcSpan forest $ (((forestLineToGhcLine $ ForestLine False 1 0 13),16),
                                       ((forestLineToGhcLine $ ForestLine False 1 0 13),17) )
      -- (showGhc ss2) `shouldBe` "test/testdata/Demote/WhereIn6.hs:100000013:16"
      (showGhc ss2) `shouldBe` "test/testdata/Demote/WhereIn6.hs:33554445:16"
      (showSrcSpanF ss2) `shouldBe` "(((False,1,0,13),16),((False,1,0,13),17))"
      (show (srcSpanToForestSpan ss2)) `shouldBe` "(((ForestLine False 1 0 13),16),((ForestLine False 1 0 13),17))"
      let (tokStartPos,tokEndPos) = forestSpanToSimpPos (srcSpanToForestSpan ss2)
      (tokStartPos,tokEndPos) `shouldBe` ((13,16),(13,17))

      let f2 = getTreeFromCache ss2 tk2
      (GHC.showRichTokenStream $ retrieveTokensInterim f2) `shouldBe`
               "\n\n\n\n\n\n\n\n\n\n\n\n addthree a b c=a+b+c"
      toks2 <- basicTokenise "x"
      (show toks2) `shouldBe` "[((((0,1),(0,2)),ITvarid \"x\"),\"x\")]"
      --

      let z = openZipperToSpan (srcSpanToForestSpan ss2) $ Z.fromTree f2
      let toksz = retrieveTokensInterim $ Z.tree z
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
               "+- ((10200000013,16),(10200000013,17))\n|\n"++
               "`- ((13,17),(13,21))\n"
      -- (show f3) `shouldBe` ""
      (GHC.showRichTokenStream $ retrieveTokensFinal f3) `shouldBe`
               "\n\n\n\n\n\n\n\n\n\n\n\n addthree a b c=x+b+c"

  -- ---------------------------------------------

  describe "replaceTokenForSrcSpan" $ do
    it "replaces a single token in a given span, without disturbing the tree" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      let Just (GHC.L ln n) = locToName (13, 1) renamed


      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"
      (showGhc decl) `shouldBe` "TokenTest.foo x y\n  = do { c <- System.IO.getChar;\n         GHC.Base.return c }"
      (showGhc n) `shouldBe` "TokenTest.bab"

      let newTok = markToken $ newNameTok False l n
      let forest' = replaceTokenForSrcSpan forest l newTok

      (drawTreeEntry forest') `shouldBe`
              "((1,1),(21,14))\n"

      let toks' = retrieveTokensFinal forest'
      (GHC.showRichTokenStream toks') `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n bab x y =\n   do c <- getChar\n      return c\n\n\n\n\n "

    -- ---------------------------------

    it "replaces a single token in an added span" $ do
      (_t,toks) <- parsedFileDd1Ghc

      let f1 = mkTreeFromTokens toks

      let ss1 = posToSrcSpan f1 ((4,1),(4,19))
      let (f2,_toks1) = getTokensFor True f1 ss1

      let ss2 = posToSrcSpan f1 ((3,1),(3,31))
      let (f3,toks2) = getTokensFor True f2 ss2

      (drawTreeEntry f3) `shouldBe`
              "((1,1),(32,18))\n|\n"++
              "+- ((1,1),(3,31))\n|  |\n"++
              "|  +- ((1,1),(1,24))\n|  |\n"++
              "|  `- ((3,1),(3,31))\n|\n"++
              "+- ((4,1),(4,19))\n|\n"++
              "`- ((6,1),(32,18))\n"

      -- putDeclToksAfterSpan test/testdata/DupDef/Dd1.hs:4:1-18:("(((False,0,0,4),1),((False,0,0,4),19))",PlaceAbsCol 2 1 0,[((((3,1),(3,1)),ITvocurly),""),((((3,1),(3,9)),ITvarid "toplevel"),"toplevel"),((((3,10),(3,12)),ITdcolon),"::"),((((3,13),(3,20)),ITconid "Integer"),"Integer"),((((3,21),(3,23)),ITrarrow),"->"),((((3,24),(3,31)),ITconid "Integer"),"Integer")])
      let (f4,ss4) = addToksAfterSrcSpan f3 ss1 (PlaceAbsCol 2 1 0) toks2

      (drawTreeEntry f4) `shouldBe`
              "((1,1),(32,18))\n|\n"++
              "+- ((1,1),(3,31))\n|  |\n"++
              "|  +- ((1,1),(1,24))\n|  |\n"++
              "|  `- ((3,1),(3,31))\n|\n"++
              "+- ((4,1),(4,19))\n|\n"++
              "+- ((1000006,1),(1000006,31))\n|\n"++
              "`- ((6,1),(32,18))\n"

      (showSrcSpan ss4) `shouldBe` "((1048582,1),(1048582,31))"
      (showSrcSpanF ss4) `shouldBe` "(((False,0,1,6),1),((False,0,1,6),31))"

      -- renamePN.worker entry:l=(((False,0,1,6),1),((False,0,1,6),9))
      let ss5 = posToSrcSpan f1 $
                        (((forestLineToGhcLine $ ForestLine False 0 1 6),1),
                         ((forestLineToGhcLine $ ForestLine False 0 1 6),9) )

      -- (markToken $ newNameTok useQual' l newName)
      let newName = mkTestGhcName 1 Nothing "bar2"
      let newTok = markToken $ newNameTok False ss5 newName
      (show newTok) `shouldBe` "((((6,1),(6,5)),ITvarid \"bar2\"),\"bar2\")"

--
      let  (GHC.L tl _,_) = newTok
      let z = openZipperToSpan (srcSpanToForestSpan ss5) $ Z.fromTree f4

      (drawTreeEntry $ Z.tree z) `shouldBe`
                    "((1000006,1),(1000006,31))\n"
--
      let f5 = replaceTokenForSrcSpan f4 ss5 newTok
      (drawTreeEntry f5) `shouldBe`
              "((1,1),(32,18))\n|\n"++
              "+- ((1,1),(3,31))\n|  |\n"++
              "|  +- ((1,1),(1,24))\n|  |\n"++
              "|  `- ((3,1),(3,31))\n|\n"++
              "+- ((4,1),(4,19))\n|\n"++
              "+- ((1000006,1),(1000006,31))\n|\n"++
              "`- ((6,1),(32,18))\n"

      let toks' = retrieveTokensFinal f5
      (GHC.showRichTokenStream toks') `shouldBe` "module DupDef.Dd1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n bar2 :: Integer -> Integerc,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n "


  -- ---------------------------------------------

  describe "posToSrcSpan" $ do
    it "Converts a simple position to a SrcSpan in the context of a forest" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let sspan = posToSrcSpan forest ((1,2),(3,5))
      (showGhc sspan) `shouldBe` "test/testdata/TokenTest.hs:(1,2)-(3,4)"
      (showSrcSpan sspan) `shouldBe` "((1,2),(3,5))"

  -- ---------------------------------------------

  describe "ghcLineToForestLine" $ do
    it "converts a GHC line to a ForestLine" $ do
      (ghcLineToForestLine         34) `shouldBe` ForestLine False 0  0 34
      (ghcLineToForestLine   0x100022) `shouldBe` ForestLine False 0  1 34
      (ghcLineToForestLine  0xbe00022) `shouldBe` ForestLine False 5 30 34
      (ghcLineToForestLine 0x49400022) `shouldBe` ForestLine True  4 20 34
      (ghcLineToForestLine 0x40100022) `shouldBe` ForestLine True  0  1 34

  describe "forestLineToGhcLine" $ do
    it "converts a ForestLine value to a GHC line" $ do
      (hex $ forestLineToGhcLine $ ForestLine False 0  0 34) `shouldBe`       "0x22"
      (hex $ forestLineToGhcLine $ ForestLine False 0  1 34) `shouldBe`   "0x100022"
      (hex $ forestLineToGhcLine $ ForestLine False 5 30 34) `shouldBe`  "0xbe00022"
                                        -- 0xbe = 101 11110
      (hex $ forestLineToGhcLine $ ForestLine True  4 20 34) `shouldBe` "0x49400022"
                                   -- 0x494 = 1 00100 10100
      (hex $ forestLineToGhcLine $ ForestLine True  0  1 34) `shouldBe` "0x40100022"

  -- ---------------------------------------------

  describe "ForestLine Ord" $ do
    it "implements Ord for ForestLine" $ do
      compare (ForestLine False 0 0 1) (ForestLine False 0 0 3) `shouldBe` LT
      compare (ForestLine False 0 0 3) (ForestLine False 0 1 3) `shouldBe` LT
      compare (ForestLine False 0 1 1) (ForestLine False 0 2 3) `shouldBe` LT
      compare (ForestLine False 0 9 3) (ForestLine False 0 0 4) `shouldBe` LT
      compare (ForestLine True  0 0 6) (ForestLine False 0 0 4) `shouldBe` GT

      compare (ForestLine False 0 7 3) (ForestLine False 0 7 3) `shouldBe` EQ

      compare (ForestLine False 0 0 4) (ForestLine False 0 0 3) `shouldBe` GT

  -- ---------------------------------------------

  describe "insertNodeAfter" $ do
    it "Adds a new SrcSpan after a specified one in the forest." $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let (ghcl,_c) = getGhcLoc l
      let (ForestLine ch tr v lin) = ghcLineToForestLine ghcl
      let newSpan' = insertForestLineInSrcSpan (ForestLine ch tr (v+1) lin) l

      let toksNew = take 3 toks
      let newNode = Node (Entry (fs newSpan') toksNew) []
      -- let newNode = Node (Entry l toks) []

      -- let toks' = retrieveTokens tree
      let forest'' = insertNodeAfter tree newNode forest'
      (invariant forest'') `shouldBe` []
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(21,14))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++
              "`- ((1000019,1),(1000021,14))\n" -- our inserted span


      let toksFinal = retrieveTokensFinal forest''
      (GHC.showRichTokenStream toksNew) `shouldBe` "module TokenTest where"
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n module TokenTest where"

  -- ---------------------------------------------

  describe "addNewSrcSpanAndToksAfter" $ do
    it "Adds a new SrcSpan after an existing one in the forest." $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let toks' = retrieveTokensInterim tree
      let (forest'',sspan) = addNewSrcSpanAndToksAfter forest' l l (PlaceOffset 2 0 2) toks'
      (invariant forest'') `shouldBe` []
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(21,14))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++
              "`- ((1000019,1),(1000021,14))\n" -- our inserted span

      (showSrcSpanF sspan) `shouldBe` "(((False,0,1,19),1),((False,0,1,21),14))"

      let toksFinal = retrieveTokensFinal forest''
      -- (showToks toksFinal) `shouldBe` ""
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n "

  -- ---------------------------------------------

  describe "addToksAfterSrcSpan" $ do
    it "Adds a new SrcSpan after an existing one in the forest 1." $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let toks' = retrieveTokensInterim tree
      let (forest'',sspan) = addToksAfterSrcSpan forest' l (PlaceOffset 2 0 2) toks'
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(21,14))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++
              "`- ((1000024,1),(1000026,14))\n" -- our inserted span

      (showSrcSpanF sspan) `shouldBe` "(((False,0,1,24),1),((False,0,1,26),14))"
      (invariant forest'') `shouldBe` []

      let toksFinal = retrieveTokensFinal forest''
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n "

    -- ---------------------------------

    it "Adds a new SrcSpan after an existing one in the forest 2." $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head $ tail decls
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(13,1)-(15,16)"
      (showSrcSpan l) `shouldBe` "((13,1),(15,17))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let toks' = retrieveTokensInterim tree
      let (forest'',sspan) = addToksAfterSrcSpan forest' l (PlaceOffset 2 0 2) toks'
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(21,14))\n|\n"++
              "+- ((1,1),(10,10))\n|\n"++
              "+- ((13,1),(15,17))\n|\n"++
              "+- ((1000017,1),(1000019,17))\n|\n"++ -- our inserted span
              "`- ((19,1),(21,14))\n"
      (showSrcSpanF sspan) `shouldBe` "(((False,0,1,17),1),((False,0,1,19),17))"
      (invariant forest'') `shouldBe` []

      let toksFinal = retrieveTokensFinal forest''
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n \n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n\n\n\n "

    -- ---------------------------------

    it "Adds a new SrcSpan after an existing one in the forest, with an indent." $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(19,1)-(21,13)"
      (showSrcSpan l) `shouldBe` "((19,1),(21,14))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let toks' = retrieveTokensInterim tree
      let (forest'',sspan) = addToksAfterSrcSpan forest' l (PlaceOffset 2 4 2) toks'
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(21,14))\n|\n"++
              "+- ((1,1),(15,17))\n|\n"++
              "+- ((19,1),(21,14))\n|\n"++
              "`- ((1000024,5),(1000026,18))\n" -- our inserted span

      (showSrcSpanF sspan) `shouldBe` "(((False,0,1,24),5),((False,0,1,26),18))"
      (invariant forest'') `shouldBe` []

      let toksFinal = retrieveTokensFinal forest''
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n     -- leading comment\n     foo x y =\n       do c <- getChar\n          return c\n\n "

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
               "+- ((7,1),(7,6))(1,-5)D\n|\n"++
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
               "+- ((7,1),(7,6))(1,-5)D\n|\n"++
               "`- ((8,1),(8,6))\n"

      let newToks = take 3 toks
      let (forest'',sspan'') = addToksAfterSrcSpan finsert (sspan') (PlaceOffset 2 4 2) newToks
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(8,6))\n|\n"++
               "+- ((1,1),(4,19))\n|  |\n"++
               "|  +- ((1,1),(4,13))\n|  |\n"++
               "|  +- ((4,14),(4,19))\n|  |\n"++
               "|  `- ((1000006,5),(1000006,32))\n|\n"++
               "+- ((7,1),(7,6))(1,-5)D\n|\n"++
               "`- ((8,1),(8,6))\n"

      (showSrcSpanF sspan'') `shouldBe` "(((False,0,1,6),5),((False,0,1,6),32))"
      -- (invariant forest'') `shouldBe` []

      let toksFinal = retrieveTokensFinal forest''
      -- (showToks toksFinal) `shouldBe` ""
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module MoveDef.Demote where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n     module MoveDef.Demote where\n\n \n d = 9\n\n\n "

    -- ---------------------------------

    it "Adds a new SrcSpan after an existing one, with an indent catering for comments" $ do
      (_t,toks) <- parsedFileGhc "./test/testdata/Demote/WhereIn5.hs"
      let forest = mkTreeFromTokens toks

      -- removeToksForPos ((14,1),(14,6))
      let sspan = posToSrcSpan forest ((14,1),(14,6))
      let (forest',_delTree) = removeSrcSpan forest (srcSpanToForestSpan sspan)
      (drawTreeEntry forest') `shouldBe`
               "((1,1),(17,23))\n|\n"++
               "+- ((1,1),(12,26))\n|\n"++
               "+- ((14,1),(14,6))(2,-5)D\n|\n"++
               "`- ((16,1),(17,23))\n"
      (invariant forest') `shouldBe` []

      -- addLocalDecl entered:newSource="[pow=2\n\n]"
      -- putToksAfterPos ((11,16),(12,26)) at PlaceIndent 1 0 2
      let sspan' = posToSrcSpan forest' ((11,16),(12,26))

      let finsert = insertSrcSpan forest' (srcSpanToForestSpan sspan')
      (drawTreeEntry finsert) `shouldBe`
               "((1,1),(17,23))\n|\n"++
               "+- ((1,1),(12,26))\n|  |\n"++
               "|  +- ((1,1),(11,15))\n|  |\n"++
               "|  `- ((11,16),(12,26))\n|\n"++
               "+- ((14,1),(14,6))(2,-5)D\n|\n"++
               "`- ((16,1),(17,23))\n"

      newToks <- liftIO $ basicTokenise "pow=2\n\n"
      let (forest'',sspan'') = addToksAfterSrcSpan finsert (sspan') (PlaceIndent 1 0 2) newToks
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(17,23))\n|\n"++
               "+- ((1,1),(12,26))\n|  |\n"++
               "|  +- ((1,1),(11,15))\n|  |\n"++
               "|  +- ((11,16),(12,26))\n|  |\n"++
               "|  `- ((1000014,16),(1000014,21))\n|\n"++
               "+- ((14,1),(14,6))(2,-5)D\n|\n"++
               "`- ((16,1),(17,23))\n"

      (showSrcSpanF sspan'') `shouldBe` "(((False,0,1,14),16),((False,0,1,14),21))"
      -- (invariant forest'') `shouldBe` []

      let toksFinal = retrieveTokensFinal forest''
      -- (showToks toksFinal) `shouldBe` ""
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module Demote.WhereIn5 where\n\n --A definition can be demoted to the local 'where' binding of a friend declaration,\n --if it is only used by this friend declaration.\n\n --Demoting a definition narrows down the scope of the definition.\n --In this example, demote the top level 'pow' to 'sq'\n --This example aims to test demoting a function/pattern binding multi-levels.\n\n sumSquares x y = sq x + sq y\n          where sq 0=0\n                sq z=z^pow {-There \nis a comment-}\n                pow=2\n\n anotherFun 0 y = sq y\n      where  sq x = x^2\n\n "

    -- ---------------------------------

    it "Adds a new SrcSpan after deleting toks 1" $ do
      (_t,toks) <- parsedFileGhc "./test/testdata/MoveDef/Demote.hs"
      let forest = mkTreeFromTokens toks

      --  removeToksForPos ((7,1),(7,6))
      let sspan = posToSrcSpan forest ((7,1),(7,6))
      let (forest',_) = removeSrcSpan forest (srcSpanToForestSpan sspan)
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(8,6))\n|\n"++
               "+- ((1,1),(4,19))\n|\n"++
               "+- ((7,1),(7,6))(1,-5)D\n|\n"++
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
               "+- ((7,1),(7,6))(1,-5)D\n|\n"++
               "`- ((8,1),(8,6))\n"

      let (f,_t) = getSrcSpanFor forest' (srcSpanToForestSpan sspan')
      (drawTreeEntry f) `shouldBe`
              "((1,1),(8,6))\n|\n"++
               "+- ((1,1),(4,19))\n|  |\n"++
               "|  +- ((1,1),(4,13))\n|  |\n"++
               "|  `- ((4,14),(4,19))\n|\n"++
               "+- ((7,1),(7,6))(1,-5)D\n|\n"++
               "`- ((8,1),(8,6))\n"

      let (forest'',newSpan) = addToksAfterSrcSpan forest' sspan' position newToks

      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(8,6))\n|\n"++
               "+- ((1,1),(4,19))\n|  |\n"++
               "|  +- ((1,1),(4,13))\n|  |\n"++
               "|  +- ((4,14),(4,19))\n|  |\n"++
               "|  `- ((1000005,5),(1000005,32))\n|\n"++
               "+- ((7,1),(7,6))(1,-5)D\n|\n"++
               "`- ((8,1),(8,6))\n"

      (showSrcSpanF newSpan) `shouldBe` "(((False,0,1,5),5),((False,0,1,5),32))"
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
               "+- ((9,1),(9,14))(2,-13)D\n|\n"++
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
               "|  +- ((10000000006,21),(10000000006,23))\n|  |\n"++
               "|  `- ((6,26),(7,18))\n|\n"++
               "+- ((9,1),(9,14))(2,-13)D\n|\n"++
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
             "[(((ForestLine False 0 0 1),1),((ForestLine False 0 0 6),20)),"++
              "(((ForestLine True 0 0 6),21),((ForestLine True 0 0 6),23)),"++
              "(((ForestLine False 0 0 6),26),((ForestLine False 0 0 7),18))]"

      let contains zn = (startPos <= nodeStart && endPos >= nodeEnd)
            where
              (startPos,endPos) = treeStartEnd $ Z.tree zn
              (nodeStart,nodeEnd) = (srcSpanToForestSpan sspan3)

      (show $ filter contains childrenAsZ) `shouldBe` "[]"

--
      let z = openZipperToSpan (fs sspan3) $ Z.fromTree f2
      let (b1,m1,e1) = splitSubtree (Z.tree z) (fs sspan3)
      (show (map treeStartEnd b1,map treeStartEnd m1,map treeStartEnd e1)) `shouldBe` 
              "([(((ForestLine False 0 0 1),1),((ForestLine False 0 0 6),20))],"++
               "[(((ForestLine True 0 0 6),21),((ForestLine True 0 0 6),23)),"++
                "(((ForestLine False 0 0 6),26),((ForestLine False 0 0 7),18))],"++
               "[])"
      let (b2,m2,e2) = splitSubToks (head m1) (fs sspan3)
      -- (show (b2,m2,e2)) `shouldBe` ""
--
      let fss = insertSrcSpan f2 (srcSpanToForestSpan sspan3)
      (drawTreeEntry fss) `shouldBe`
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(7,18))\n|  |\n"++
               "|  +- ((1,1),(6,20))\n|  |\n"++
               "|  +- ((6,21),(6,41))\n|  |  |\n"++
               "|  |  +- ((10000000006,21),(10000000006,23))\n|  |  |\n"++
               "|  |  `- ((6,26),(6,41))\n|  |\n"++
               "|  `- ((7,1),(7,18))\n|\n"++
               "+- ((9,1),(9,14))(2,-13)D\n|\n"++
               "`- ((11,1),(13,25))\n"


      let (forest'',sspan'') = addToksAfterSrcSpan f2 sspan3 (PlaceOffset 1 4 2) newToks
      (drawTreeEntry forest'') `shouldBe`
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(7,18))\n|  |\n"++
               "|  +- ((1,1),(6,20))\n|  |\n"++
               "|  +- ((6,21),(6,41))\n|  |  |\n"++
               "|  |  +- ((10000000006,21),(10000000006,23))\n|  |  |\n"++
               "|  |  `- ((6,26),(6,41))\n|  |\n"++
               "|  +- ((1000007,5),(1000010,7))\n|  |\n"++
               "|  `- ((7,1),(7,18))\n|\n"++
               "+- ((9,1),(9,14))(2,-13)D\n|\n"++
               "`- ((11,1),(13,25))\n"

      (showSrcSpanF sspan'') `shouldBe` "(((False,0,1,7),5),((False,0,1,10),7))"
      -- (invariant forest'') `shouldBe` []

      let toksFinal = retrieveTokensFinal forest''
      -- (showToks toksFinal) `shouldBe` ""
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module Demote.D1 where\n\n {-demote 'sq' to 'sumSquares'. This refactoring\n  affects module 'D1' and 'C1' -}\n\n sumSquares (x:xs) = sq   + sumSquares xs\n     sumSquares (x:xs) = sq x + sumSquares xs\n     sumSquares [] = 0\n\n     sq\n\n \n sumSquares [] = 0\n\n pow = 2\n\n main = sumSquares [1..4]\n\n "

    -- ---------------------------------

    it "Adds a new SrcSpan after the last one" $ do
      (_t,toks)  <- parsedFileGhc "./test/testdata/TypeUtils/JustImports.hs"

      let forest = mkTreeFromTokens toks

      let toksTree = retrieveTokensInterim forest
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

      let toksFinal = retrieveTokensFinal forest'
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module JustImports where\n\n import Data.Maybe\n import Data.List\n "

    -- ---------------------------------

    it "adds a SrcSpan after deleting, without extra tokens" $ do
      (_t,toks)  <- parsedFileGhc "./test/testdata/Demote/LetIn1.hs"
      let forest = mkTreeFromTokens toks

      -- removeToksForPos ((12,22),(12,27))
      let sspan = posToSrcSpan forest ((12,22),(12,27))
      let (forest',_) = removeSrcSpan forest (srcSpanToForestSpan sspan)
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(17,23))\n|\n"++
               "+- ((1,1),(11,32))\n|\n"++
               "+- ((12,22),(12,27))(1,-9)D\n|\n"++
               "`- ((13,21),(17,23))\n"
      (invariant forest') `shouldBe` []

      -- putToksAfterPos ((11,27),(11,32)) at PlaceOffset 1 4 2
      newToks <- basicTokenise "where\n   pow=2\n"
      (show newToks) `shouldBe`
             "[((((0,1),(0,6)),ITwhere),\"where\"),"++
              "((((1,4),(1,4)),ITvocurly),\"\"),"++
              "((((1,4),(1,7)),ITvarid \"pow\"),\"pow\"),"++
              "((((1,7),(1,8)),ITequal),\"=\"),"++
              "((((1,8),(1,9)),ITinteger 2),\"2\"),"++
              "((((2,1),(2,1)),ITvccurly),\"\")]" -- ++AZ++ odd, ok.
      let sspan' = posToSrcSpan forest' ((11,27),(11,32))
      let position = PlaceOffset 1 4 2

      --
      let finsert = insertSrcSpan forest' (srcSpanToForestSpan sspan')
      (drawTreeEntry finsert) `shouldBe`
              "((1,1),(17,23))\n|\n"++
               "+- ((1,1),(11,32))\n|  |\n"++
               "|  +- ((1,1),(11,27))\n|  |\n"++
               "|  `- ((11,27),(11,32))\n|\n"++
               "+- ((12,22),(12,27))(1,-9)D\n|\n"++
               "`- ((13,21),(17,23))\n"

      let (fwithspan,_t) = getSrcSpanFor forest' (srcSpanToForestSpan sspan')
      (drawTreeEntry fwithspan) `shouldBe`
              "((1,1),(17,23))\n|\n"++
               "+- ((1,1),(11,32))\n|  |\n"++
               "|  +- ((1,1),(11,27))\n|  |\n"++
               "|  `- ((11,27),(11,32))\n|\n"++
               "+- ((12,22),(12,27))(1,-9)D\n|\n"++
               "`- ((13,21),(17,23))\n"

      let z = openZipperToSpan (srcSpanToForestSpan sspan') $ Z.fromTree fwithspan
      let prevToks = retrievePrevLineToks z
      let prevToks'' = limitPrevToks prevToks sspan'
      (show prevToks'') `shouldBe`
          "RT [((((11,29),(11,32)),ITvarid \"pow\"),\"pow\"),"++
              "((((11,28),(11,29)),ITvarsym \"^\"),\"^\"),"++
              "((((11,27),(11,28)),ITvarid \"z\"),\"z\"),"++
              "((((11,26),(11,27)),ITequal),\"=\"),"++
              "((((11,25),(11,26)),ITvarid \"z\"),\"z\"),"++
              "((((11,22),(11,24)),ITvarid \"sq\"),\"sq\"),"++
              "((((11,22),(11,22)),ITsemi),\"\")]"
      let toks'' = reIndentToks position (unReverseToks prevToks'') newToks
      (show toks'') `shouldBe`
             "[((((12,26),(12,31)),ITwhere),\"where\"),"++
              "((((13,29),(13,29)),ITvocurly),\"\"),"++
              "((((13,29),(13,32)),ITvarid \"pow\"),\"pow\"),"++
              "((((13,32),(13,33)),ITequal),\"=\"),"++
              "((((13,33),(13,34)),ITinteger 2),\"2\"),"++
              "((((14,26),(14,26)),ITvccurly),\"\"),"++ -- ++AZ++ WTF?
              "((((16,1),(16,1)),ITvocurly),\"\")]"     -- ++AZ++ WTF?
      --
      let (forest'',newSpan) = addToksAfterSrcSpan forest' sspan' position newToks

      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(17,23))\n|\n"++
               "+- ((1,1),(11,32))\n|  |\n"++
               "|  +- ((1,1),(11,27))\n|  |\n"++
               "|  +- ((11,27),(11,32))\n|  |\n"++
               "|  `- ((1000012,26),(1000013,34))\n|\n"++
               "+- ((12,22),(12,27))(1,-9)D\n|\n"++
               "`- ((13,21),(17,23))\n"

      (showSrcSpanF newSpan) `shouldBe` "(((False,0,1,12),26),((False,0,1,13),34))"
      (invariant forest'') `shouldBe` []
      (GHC.showRichTokenStream $ retrieveTokensFinal forest'') `shouldBe` "module Demote.LetIn1 where\n\n --A definition can be demoted to the local 'where' binding of a friend declaration,\n --if it is only used by this friend declaration.\n\n --Demoting a definition narrows down the scope of the definition.\n --In this example, demote the local  'pow' to 'sq'\n --This example also aims to test the demoting a local declaration in 'let'.\n\n sumSquares x y = let sq 0=0\n                      sq z=z^pow\n                          where\n                             pow=2\n                          \n\n \n                  in sq x + sq y\n\n\n anotherFun 0 y = sq y\n      where  sq x = x^2\n\n   "

    -- ---------------------------------

    it "Adds a SrcSpan, chasing a bug in MoveDef" $ do
      (_t,toks)  <- parsedFileGhc "./test/testdata/MoveDef/Md1.hs"
      let forest = mkTreeFromTokens toks

      -- getToksForSpan test/testdata/MoveDef/Md1.hs:24:5-10:("(((False,0,0,24),5),((False,0,0,24),11))",
      let sspan1 = posToSrcSpan forest ((24,5),(24,11))
      let (f1,_toks1) = getTokensFor True forest sspan1

      (drawTreeEntry f1) `shouldBe`
              "((1,1),(40,17))\n|\n"++
              "+- ((1,1),(23,8))\n|\n"++
              "+- ((24,5),(24,11))\n|\n"++
              "`- ((26,1),(40,17))\n"
      (invariant f1) `shouldBe` []

      -- removeToksForPos ((24,5),(24,11))
      let (f2,_) = removeSrcSpan f1 (srcSpanToForestSpan sspan1)
      (drawTreeEntry f2) `shouldBe`
              "((1,1),(40,17))\n|\n"++
               "+- ((1,1),(23,8))\n|\n"++
               "+- ((24,5),(24,11))(2,-10)D\n|\n"++
               "`- ((26,1),(40,17))\n"
      (invariant f2) `shouldBe` []

      -- removeToksForPos ((23,3),(23,8))
      let sspan3 = posToSrcSpan forest ((23,3),(23,8))
      let (f3,_) = removeSrcSpan f2 (srcSpanToForestSpan sspan3)
      (drawTreeEntry f3) `shouldBe`
              "((1,1),(40,17))\n|\n"++
               "+- ((1,1),(23,8))\n|  |\n"++
               "|  +- ((1,1),(22,14))\n|  |\n"++
               "|  `- ((23,3),(23,8))(1,-3)D\n|\n"++
               "+- ((24,5),(24,11))(2,-10)D\n|\n"++
               "`- ((26,1),(40,17))\n"
      (invariant f3) `shouldBe` []

      -- Context set, time for test

      -- putDeclToksAfterSpan test/testdata/MoveDef/Md1.hs:(22,1)-(24,10):("(((False,0,0,22),1),((False,0,0,24),11))",PlaceOffset 2 0 2,[((((1,6),(1,8)),ITvarid "zz"),"zz"),((((1,9),(1,10)),ITequal),"="),((((1,11),(1,12)),ITinteger 1),"1")])
      newToks <- basicTokenise "\n     zz = 1"
      (show newToks) `shouldBe` "[((((1,6),(1,8)),ITvarid \"zz\"),\"zz\"),((((1,9),(1,10)),ITequal),\"=\"),((((1,11),(1,12)),ITinteger 1),\"1\")]"

      let sspan4 = posToSrcSpan forest ((22,1),(24,11))

--
      let z = openZipperToSpan (fs sspan4) $ Z.fromTree f3
      (drawTreeEntry $ Z.tree z) `shouldBe`
              "((1,1),(40,17))\n|\n"++
               "+- ((1,1),(23,8))\n|  |\n"++
               "|  +- ((1,1),(22,14))\n|  |\n"++
               "|  `- ((23,3),(23,8))(1,-3)D\n|\n"++
               "+- ((24,5),(24,11))(2,-10)D\n|\n"++
               "`- ((26,1),(40,17))\n"

      -- (show $ subForest (Z.tree z)) `shouldBe` ""

      -- let (b1,m1,e1) = doSplitTree (Z.tree z) (fs sspan4)
      let (b1,m1,e1) = splitSubtree (Z.tree z) (fs sspan4)
      (show (map treeStartEnd b1,map treeStartEnd m1,map treeStartEnd e1)) `shouldBe` 
              "([],"++

              "[(((ForestLine False 0 0 1),1),((ForestLine False 0 0 23),8)),"++
               "(((ForestLine False 0 0 24),5),((ForestLine False 0 0 24),11))],"++

              "[(((ForestLine False 0 0 26),1),((ForestLine False 0 0 40),17))])"

      let (b2,m2,e2) = splitSubtree (head m1) (fs sspan4)
      (show (map treeStartEnd b2,map treeStartEnd m2,map treeStartEnd e2)) `shouldBe` 
              "([],"++
              "[(((ForestLine False 0 0 1),1),((ForestLine False 0 0 22),14)),"++
               "(((ForestLine False 0 0 23),3),((ForestLine False 0 0 23),8))],"++ 
              "[])"

      let (Node (Entry ss toks2) _) = head m2

      (containsStart ss (fs sspan4),containsEnd ss (fs sspan4)) `shouldBe` (True,False)

      let (sspanStart,_sspanEnd) = fs sspan4

      let (_,toksb,toksm) = splitToks (forestSpanToSimpPos (nullPos,sspanStart)) toks2
      (show (head toksb,last toksb)) `shouldBe`
               "(((((1,1),(1,7)),ITmodule),\"module\"),"++
               "((((21,14),(21,17)),ITconid \"Int\"),\"Int\"))"
      (show (head toksm,last toksm)) `shouldBe`
               "(((((22,1),(22,1)),ITsemi),\"\"),"++
               "((((22,12),(22,14)),ITvarid \"zz\"),\"zz\"))"

      let (b3,m3,e3) = splitSubToks (head m2) (fs sspan4)
      (show (map treeStartEnd b3,map treeStartEnd m3,map treeStartEnd e3)) `shouldBe`
              "([(((ForestLine False 0 0 1),1),((ForestLine False 0 0 21),17))],"++
              -- ++AZ++ How does this get to (24,11), input only goes to (23,8)?
               "[(((ForestLine False 0 0 22),1),((ForestLine False 0 0 22),14))],"++
               "[])"

      -- TODO: span is deleted twice. Deal with it.
      let f3' = insertSrcSpan f3 (fs sspan4)
      (drawTreeEntry f3') `shouldBe`
              "((1,1),(40,17))\n|\n"++
              "+- ((1,1),(21,17))\n|\n"++
              "+- ((22,1),(24,11))\n|  |\n"++
              "|  +- ((22,1),(22,14))\n|  |\n"++
              "|  +- ((23,3),(23,8))(1,-3)D\n|  |\n"++
              "|  `- ((24,5),(24,11))(2,-10)D\n|\n"++
              "`- ((26,1),(40,17))\n"
      (invariant f3') `shouldBe` []

      let (fwithspan,tree) = getSrcSpanFor f3 (srcSpanToForestSpan sspan4)
      (drawTreeEntry fwithspan) `shouldBe`
              "((1,1),(40,17))\n|\n"++
              "+- ((1,1),(21,17))\n|\n"++
              "+- ((22,1),(24,11))\n|  |\n"++
              "|  +- ((22,1),(22,14))\n|  |\n"++
              "|  +- ((23,3),(23,8))(1,-3)D\n|  |\n"++
              "|  `- ((24,5),(24,11))(2,-10)D\n|\n"++
              "`- ((26,1),(40,17))\n"

      let toks'' = placeToksForSpan fwithspan sspan4 tree (PlaceOffset 2 0 2) newToks
      let (startPos,endPos) = nonCommentSpan toks''
      let newSpan = posToSrcSpan forest (startPos,endPos)
      (showGhc newSpan) `shouldBe` "test/testdata/MoveDef/Md1.hs:24:1-6"

      let (forest',tree') = getSrcSpanFor f3 (srcSpanToForestSpan sspan4)
      -- (show tree') `shouldBe` ""

      -- let (forest',newSpan') = addNewSrcSpanAndToksAfter f3 sspan4 newSpan (PlaceOffset 2 0 2) newToks
      (drawTreeEntry forest') `shouldBe`
              "((1,1),(40,17))\n|\n"++
              "+- ((1,1),(21,17))\n|\n"++
              "+- ((22,1),(24,11))\n|  |\n"++
              "|  +- ((22,1),(22,14))\n|  |\n"++
              "|  +- ((23,3),(23,8))(1,-3)D\n|  |\n"++
              "|  `- ((24,5),(24,11))(2,-10)D\n|\n"++
              "`- ((26,1),(40,17))\n"


      let (ghcl,_c) = getGhcLoc newSpan
      let (ForestLine ch tr v l) = ghcLineToForestLine ghcl
      let newSpan' = insertForestLineInSrcSpan (ForestLine ch tr (v+1) l) newSpan
      let toks' = placeToksForSpan forest' sspan4 tree' (PlaceOffset 2 0 2) newToks
      let newNode = Node (Entry (srcSpanToForestSpan newSpan') toks') []
      (show newNode) `shouldBe` "Node {rootLabel = Entry (((ForestLine False 0 1 24),1),((ForestLine False 0 1 24),7)) [((((24,1),(24,3)),ITvarid \"zz\"),\"zz\"),((((24,4),(24,5)),ITequal),\"=\"),((((24,6),(24,7)),ITinteger 1),\"1\"),((((26,1),(26,1)),ITvocurly),\"\")], subForest = []}"

      let forest'' = insertNodeAfter tree' newNode forest'
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(40,17))\n|\n"++
              "+- ((1,1),(21,17))\n|\n"++
              "+- ((22,1),(24,11))\n|  |\n"++
              "|  +- ((22,1),(22,14))\n|  |\n"++
              "|  +- ((23,3),(23,8))(1,-3)D\n|  |\n"++
              "|  `- ((24,5),(24,11))(2,-10)D\n|\n"++
              "+- ((1000024,1),(1000024,7))\n|\n"++
              "`- ((26,1),(40,17))\n"
--

      let (f4,_newSpan4) = addToksAfterSrcSpan f3 sspan4 (PlaceOffset 2 0 2) newToks
      (drawTreeEntry f4) `shouldBe`
              "((1,1),(40,17))\n|\n"++
              "+- ((1,1),(21,17))\n|\n"++
              "+- ((22,1),(24,11))\n|  |\n"++
              "|  +- ((22,1),(22,14))\n|  |\n"++
              "|  +- ((23,3),(23,8))(1,-3)D\n|  |\n"++
              "|  `- ((24,5),(24,11))(2,-10)D\n|\n"++
              "+- ((1000024,1),(1000024,7))\n|\n"++
              "`- ((26,1),(40,17))\n"
      (invariant f4) `shouldBe` []

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
               "+- ((7,1),(7,6))(1,-5)D\n|\n"++
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
               "+- ((7,1),(7,6))(1,-5)D\n|\n"++
               "`- ((8,1),(8,6))\n"
      -- (invariant forest'') `shouldBe` []

      -- Now we have the test case set up. We want prior toks from
      -- ((4,14),(4,19))
      let tspan = posToSrcSpan forest ((4,14),(4,19))

      let z = openZipperToSpan (srcSpanToForestSpan tspan) $ Z.fromTree finsert

      let toksPrev = retrievePrevLineToks z

      (GHC.showRichTokenStream (unReverseToks toksPrev)) `shouldBe` "module MoveDef.Demote where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x"

  -- -------------------------------------------------------------------

  describe "reAlignOneLine" $ do
    it "Does nothing if token lengths have not changed" $ do
      let toks = [mkToken GHC.ITsemi (1,1) "v1"
                 ,mkToken GHC.ITsemi (1,4) "v2"
                 ,mkToken GHC.ITsemi (1,7) "v3"
                 ]
      (showToks toks) `shouldBe` "[(((1,1),(1,3)),ITsemi,\"v1\"),(((1,4),(1,6)),ITsemi,\"v2\"),(((1,7),(1,9)),ITsemi,\"v3\")]"
      (showToks $ reAlignOneLine toks) `shouldBe` "[(((1,1),(1,3)),ITsemi,\"v1\"),(((1,4),(1,6)),ITsemi,\"v2\"),(((1,7),(1,9)),ITsemi,\"v3\")]"

    ------------------------------------

    it "spaces tokens out if one increases length" $ do
      let toks' = [mkToken GHC.ITsemi (1, 1) "v1"
                  ,mkToken GHC.ITsemi (1, 4) "v2"
                  ,mkToken GHC.ITsemi (1, 7) "v3"
                  ,mkToken GHC.ITsemi (1,10) "v4"
                  ]
      let tv2@(GHC.L l _,_) = head $ tail toks'
      let t2 = markToken $ matchTokenPos tv2 $ newNameTok False l (mkTestGhcName 1 Nothing "v2long")
      let toks = head toks':t2:drop 2 toks'
      (showToks toks) `shouldBe`
           "[(((1,1),(1,3)),ITsemi,\"v1\"),"++
            "(((1,4),(1,6)),ITvarid \"v2long\",\"v2long\"),"++
            "(((1,7),(1,9)),ITsemi,\"v3\"),"++
            "(((1,10),(1,12)),ITsemi,\"v4\")]"

      (showToks $ reAlignOneLine toks) `shouldBe`
            "[(((1,1),(1,3)),ITsemi,\"v1\"),"++
             "(((1,4),(1,10)),ITvarid \"v2long\",\"v2long\"),"++
             "(((1,11),(1,13)),ITsemi,\"v3\"),"++
             "(((1,14),(1,16)),ITsemi,\"v4\")]"

    ------------------------------------

    it "spaces tokens out if one increases length, maintaining the gap" $ do
      let toks' = [mkToken GHC.ITsemi (1, 1) "v1"
                  ,mkToken GHC.ITsemi (1, 4) "v2"
                  ,mkToken GHC.ITsemi (1,10) "v3"
                  ,mkToken GHC.ITsemi (1,13) "v4"
                  ]
      let tv2@(GHC.L l _,_) = head $ tail toks'
      let t2 = markToken $ matchTokenPos tv2 $ newNameTok False l (mkTestGhcName 1 Nothing "v2long")
      let toks = head toks':t2:drop 2 toks'
      (showToks toks) `shouldBe`
           "[(((1,1),(1,3)),ITsemi,\"v1\"),"++
            "(((1,4),(1,6)),ITvarid \"v2long\",\"v2long\"),"++
            "(((1,10),(1,12)),ITsemi,\"v3\"),"++
            "(((1,13),(1,15)),ITsemi,\"v4\")]"

      (showToks $ reAlignOneLine toks) `shouldBe`
            "[(((1,1),(1,3)),ITsemi,\"v1\"),"++
             "(((1,4),(1,10)),ITvarid \"v2long\",\"v2long\"),"++
             "(((1,14),(1,16)),ITsemi,\"v3\"),"++
             "(((1,17),(1,19)),ITsemi,\"v4\")]"

    ------------------------------------

    it "spaces tokens out if one decreases length" $ do
      let toks' = [mkToken GHC.ITsemi (1, 1) "v1"
                  ,mkToken GHC.ITsemi (1, 4) "v2"
                  ,mkToken GHC.ITsemi (1, 7) "v3"
                  ,mkToken GHC.ITsemi (1,10) "v4"
                  ]
      let tv2@(GHC.L l _,_) = head $ tail toks'
      let t2 = markToken $ matchTokenPos tv2 $ newNameTok False l (mkTestGhcName 1 Nothing "v")
      let toks = head toks':t2:drop 2 toks'
      (showToks toks) `shouldBe`
           "[(((1,1),(1,3)),ITsemi,\"v1\"),"++
            "(((1,4),(1,6)),ITvarid \"v\",\"v\"),"++
            "(((1,7),(1,9)),ITsemi,\"v3\"),"++
            "(((1,10),(1,12)),ITsemi,\"v4\")]"

      (showToks $ reAlignOneLine toks) `shouldBe`
            "[(((1,1),(1,3)),ITsemi,\"v1\"),"++
             "(((1,4),(1,5)),ITvarid \"v\",\"v\"),"++
             "(((1,6),(1,8)),ITsemi,\"v3\"),"++
             "(((1,9),(1,11)),ITsemi,\"v4\")]"



  -- -------------------------------------------------------------------

  describe "reAlignToks" $ do
    it "spaces tokens out if they overlap" $ do
      let toks = [mkToken GHC.ITsemi (1,1) "v1"
                 ,mkToken GHC.ITsemi (1,1) "v2"
                 ,mkToken GHC.ITsemi (1,1) "v3"
                 ]
      (showToks toks) `shouldBe` "[(((1,1),(1,3)),ITsemi,\"v1\"),(((1,1),(1,3)),ITsemi,\"v2\"),(((1,1),(1,3)),ITsemi,\"v3\")]"
      (showToks $ reAlignToks toks) `shouldBe` "[(((1,1),(1,3)),ITsemi,\"v1\"),(((1,4),(1,6)),ITsemi,\"v2\"),(((1,7),(1,9)),ITsemi,\"v3\")]"

    it "spaces tokens out if they overlap, over multiple lines" $ do
      let toks = [mkToken GHC.ITsemi (1,1) "v1"
                 ,mkToken GHC.ITsemi (1,1) "v2"
                 ,mkToken GHC.ITsemi (1,1) "v3"
                 ,mkToken GHC.ITsemi (2,1) "v4"
                 ,mkToken GHC.ITsemi (2,9) "v5"
                 ]
      (showToks toks) `shouldBe`
            "[(((1,1),(1,3)),ITsemi,\"v1\"),(((1,1),(1,3)),ITsemi,\"v2\"),(((1,1),(1,3)),ITsemi,\"v3\"),"++
            "(((2,1),(2,3)),ITsemi,\"v4\"),(((2,9),(2,11)),ITsemi,\"v5\")]"

      (showToks $ reAlignToks toks) `shouldBe`
            "[(((1,1),(1,3)),ITsemi,\"v1\"),(((1,4),(1,6)),ITsemi,\"v2\"),(((1,7),(1,9)),ITsemi,\"v3\"),"++
            "(((2,1),(2,3)),ITsemi,\"v4\"),(((2,9),(2,11)),ITsemi,\"v5\")]"

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
      let tree1@(Node (Entry sspan _) _)  = mkTreeFromTokens toks
      let tree2@(Node (Entry sspan2 _) _) = mkTreeFromTokens (tail toks)
      let tree3@(Node (Entry sspan3 _) _) = mkTreeFromTokens (take 10 toks)
      let tree4 = mkTreeFromTokens (drop 10 toks)
      (showTree tree1) `shouldBe` "Node (Entry ((1,1),(21,14)) [(((1,1),(1,7)),ITmodule,\"module\")]..[(((26,1),(26,1)),ITsemi,\"\")]) []"
      (showTree tree2) `shouldBe` "Node (Entry ((1,8),(21,14)) [(((1,8),(1,17)),ITconid \"TokenTest\",\"TokenTest\")]..[(((26,1),(26,1)),ITsemi,\"\")]) []"
      (showTree tree3) `shouldBe` "Node (Entry ((1,1),(5,12)) [(((1,1),(1,7)),ITmodule,\"module\")]..[(((5,11),(5,12)),ITvarid \"x\",\"x\")]) []"

      (invariant (Node (Entry sspan2 []) [tree1])) `shouldBe` ["FAIL: subForest start and end does not match entry: Node (Entry ((1,8),(21,14)) []) [\"Node (Entry ((1,1),(21,14)) [(((1,1),(1,7)),ITmodule,\\\"module\\\")]..[(((26,1),(26,1)),ITsemi,\\\"\\\")]) []\"]"]

      (invariant (Node (Entry sspan3 []) [tree1])) `shouldBe` ["FAIL: subForest start and end does not match entry: Node (Entry ((1,1),(5,12)) []) [\"Node (Entry ((1,1),(21,14)) [(((1,1),(1,7)),ITmodule,\\\"module\\\")]..[(((26,1),(26,1)),ITsemi,\\\"\\\")]) []\"]"]

      (invariant (Node (Entry sspan []) [tree3,tree4])) `shouldBe` []

    -- -----------------------------------------------------------------

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
      (showForestSpan $ treeStartEnd tree4) `shouldBe` "((13,5),(21,14))"

      (invariant (Node (Entry sspan []) [tree1,tree2,tree3,tree4])) `shouldBe` []
      (invariant (Node (Entry sspan []) [tree1,tree3,tree2,tree4])) `shouldBe` ["FAIL: subForest not in order: ((ForestLine False 0 0 13),4) not < ((ForestLine False 0 0 6),3):Node (Entry ((1,1),(21,14)) []) [\"Node (Entry ((1,1),(5,12)) [(((1,1),(1,7)),ITmodule,\\\"module\\\")]..[(((5,11),(5,12)),ITvarid \\\"x\\\",\\\"x\\\")]) []\",\"Node (Entry ((8,9),(13,4)) [(((8,9),(8,10)),ITequal,\\\"=\\\")]..[(((13,1),(13,4)),ITvarid \\\"bab\\\",\\\"bab\\\")]) []\",\"Node (Entry ((6,3),(8,8)) [(((6,3),(6,8)),ITwhere,\\\"where\\\")]..[(((8,7),(8,8)),ITvarid \\\"b\\\",\\\"b\\\")]) []\",\"Node (Entry ((13,5),(21,14)) [(((13,5),(13,6)),ITvarid \\\"a\\\",\\\"a\\\")]..[(((26,1),(26,1)),ITsemi,\\\"\\\")]) []\"]"]

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
      pending -- "write this test (and function)"

  -- ---------------------------------------------

  describe "mkTreeFromTokens" $ do
    it "creates a tree from an empty token list" $ do
      (show $ mkTreeFromTokens []) `shouldBe` "Node {rootLabel = Entry (((ForestLine False 0 0 0),0),((ForestLine False 0 0 0),0)) [], subForest = []}"

    -- -----------------------

    it "creates a tree from a list of tokens" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let toks' = take 2 $ drop 5 toks
      let tree = mkTreeFromTokens toks'
      (show toks') `shouldBe` "[((((5,1),(5,4)),ITvarid \"bob\"),\"bob\"),((((5,5),(5,6)),ITvarid \"a\"),\"a\")]"
      (show tree) `shouldBe` "Node {rootLabel = Entry (((ForestLine False 0 0 5),1),((ForestLine False 0 0 5),6)) [((((5,1),(5,4)),ITvarid \"bob\"),\"bob\"),((((5,5),(5,6)),ITvarid \"a\"),\"a\")], subForest = []}"

  -- ---------------------------------------------

  describe "invariant 5" $ do
    it "checks that a tree with a null SrcSpan fails" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      let toks' = take 2 $ drop 5 toks
      (invariant $ Node (Entry nullSpan toks') []) `shouldBe` ["FAIL: null SrcSpan in tree: Node (Entry ((0,0),(0,0)) [(((5,1),(5,4)),ITvarid \"bob\",\"bob\"),(((5,5),(5,6)),ITvarid \"a\",\"a\")]) []"]

  -- ---------------------------------------------

  describe "syncAST" $ do
    it "updates an AST and a tree to have the same SrcSpan structure" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head $ drop 1 decls
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(13,1)-(15,16)"
      (showSrcSpan l) `shouldBe` "((13,1),(15,17))"

      let (forest',tree) = getSrcSpanFor forest (fs l)

      let toks' = retrieveTokensInterim tree
      let (forest'',sspan) = addNewSrcSpanAndToksAfter forest' l l (PlaceOffset 2 0 2) toks'
      (invariant forest'') `shouldBe` []
      (drawTreeEntry forest'') `shouldBe`
              "((1,1),(21,14))\n|\n"++
              "+- ((1,1),(10,10))\n|\n"++
              "+- ((13,1),(15,17))\n|\n"++
              "+- ((1000013,1),(1000015,17))\n|\n"++ -- our inserted span
              "`- ((19,1),(21,14))\n"
      (showSrcSpanF sspan) `shouldBe` "(((False,0,1,13),1),((False,0,1,15),17))"

      let (decl',forest''') = syncAST decl sspan forest''

      (showGhc decl') `shouldBe` "TokenTest.bab a b = let bar = 3 in b GHC.Num.+ bar"
      (take 90 $ SYB.showData SYB.Renamer 0 decl') `shouldBe` "\n(L {test/testdata/TokenTest.hs:(1048589,1)-(1048591,16)} \n (FunBind \n  (L {test/testdata/"

      let toksFinal = retrieveTokensFinal forest'''
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n \n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n\n\n\n "

  -- ---------------------------------------------

  describe "indentDeclToks" $ do
    it "adds a positive offset to a decl and toks" $ do
      (t,toks) <- parsedFileLayoutIn2
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed

      let Just decl@(GHC.L l _) = (locToExp (8,13) (12,43) renamed) :: Maybe (GHC.Located (GHC.HsExpr GHC.Name))

      (showGhc l) `shouldBe` "test/testdata/Renaming/LayoutIn2.hs:(8,14)-(12,42)"
      (showSrcSpan l) `shouldBe` "((8,14),(12,43))"

      (showGhc decl) `shouldBe`
           "case list of {\n"++
           "  (1 : xs) -> 1\n"++
           "  (2 : xs)\n"++
           "    | x GHC.Classes.< 10 -> 4\n"++
           "    where\n"++
           "        x = GHC.List.last xs\n"++
           "  otherwise -> 12 }"
      let (GHC.L _ (GHC.HsCase expr (GHC.MatchGroup matches typ))) = decl
      (showGhc expr) `shouldBe` "list"

      let (GHC.L m1l _) = head matches
      (showSrcSpan m1l) `shouldBe` "((8,28),(8,39))"
      let (m1,forest') = indentDeclToks (head matches) forest 4

      -- let toks' = retrieveTokensInterim forest'
      (invariant forest') `shouldBe` []
      (drawTreeEntry forest') `shouldBe`
              "((10000000001,1),(10000000012,43))\n|\n"++
              "+- ((1,1),(8,26))\n|\n"++
              "+- ((8,32),(8,43))\n|\n"++ -- Indented by 4
              "`- ((10,28),(12,43))\n"

      let toksFinal = retrieveTokensFinal forest'
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module LayoutIn2 where\n\n --Layout rule applies after 'where','let','do' and 'of'\n\n --In this Example: rename 'list' to 'ls'.\n\n silly :: [Int] -> Int\n silly list = case list of      (1:xs) -> 1\n --There is a comment\n                            (2:xs)\n                              | x < 10    -> 4  where  x = last xs\n                            otherwise -> 12\n\n "

      let decl' = (GHC.L l (GHC.HsCase expr (GHC.MatchGroup (m1:(tail matches)) typ)))
      (showGhc decl') `shouldBe` "case list of {\n  (1 : xs) -> 1\n  (2 : xs)\n    | x GHC.Classes.< 10 -> 4\n    where\n        x = GHC.List.last xs\n  otherwise -> 12 }"
      (take 320 $ SYB.showData SYB.Renamer 0 decl') `shouldBe` "\n(L {test/testdata/Renaming/LayoutIn2.hs:(8,14)-(12,42)} \n (HsCase \n  (L {test/testdata/Renaming/LayoutIn2.hs:8:19-22} \n   (HsVar {Name: list})) \n  (MatchGroup \n   [\n    (L {test/testdata/Renaming/LayoutIn2.hs:8:32-42} \n     (Match \n      [\n       (L {test/testdata/Renaming/LayoutIn2.hs:8:32-37} \n        (ParPat \n     "

    ------------------------------------

    it "adds a negative offset to a decl and toks" $ do
      (t,toks) <- parsedFileLayoutIn2
      let forest = mkTreeFromTokens toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed

      let Just decl@(GHC.L l _) = (locToExp (8,13) (12,43) renamed) :: Maybe (GHC.Located (GHC.HsExpr GHC.Name))

      (showGhc l) `shouldBe` "test/testdata/Renaming/LayoutIn2.hs:(8,14)-(12,42)"
      (showSrcSpan l) `shouldBe` "((8,14),(12,43))"

      (showGhc decl) `shouldBe`
           "case list of {\n"++
           "  (1 : xs) -> 1\n"++
           "  (2 : xs)\n"++
           "    | x GHC.Classes.< 10 -> 4\n"++
           "    where\n"++
           "        x = GHC.List.last xs\n"++
           "  otherwise -> 12 }"
      let (GHC.L _ (GHC.HsCase expr (GHC.MatchGroup matches typ))) = decl
      (showGhc expr) `shouldBe` "list"

      let (GHC.L m1l _) = head matches
      (showSrcSpan m1l) `shouldBe` "((8,28),(8,39))"
      let (m1,forest') = indentDeclToks (head matches) forest (-2)

      -- let toks' = retrieveTokensInterim forest'
      (invariant forest') `shouldBe` []
      (drawTreeEntry forest') `shouldBe`
              "((10000000001,1),(10000000012,43))\n|\n"++
              "+- ((1,1),(8,26))\n|\n"++
              "+- ((8,26),(8,37))\n|\n"++ -- dedented by 2
              "`- ((10,28),(12,43))\n"

      let toksFinal = retrieveTokensFinal forest'
      (GHC.showRichTokenStream toksFinal) `shouldBe` "module LayoutIn2 where\n\n --Layout rule applies after 'where','let','do' and 'of'\n\n --In this Example: rename 'list' to 'ls'.\n\n silly :: [Int] -> Int\n silly list = case list of(1:xs) -> 1\n --There is a comment\n                            (2:xs)\n                              | x < 10    -> 4  where  x = last xs\n                            otherwise -> 12\n\n "

      let decl' = (GHC.L l (GHC.HsCase expr (GHC.MatchGroup (m1:(tail matches)) typ)))
      (showGhc decl') `shouldBe` "case list of {\n  (1 : xs) -> 1\n  (2 : xs)\n    | x GHC.Classes.< 10 -> 4\n    where\n        x = GHC.List.last xs\n  otherwise -> 12 }"
      (take 320 $ SYB.showData SYB.Renamer 0 decl') `shouldBe` "\n(L {test/testdata/Renaming/LayoutIn2.hs:(8,14)-(12,42)} \n (HsCase \n  (L {test/testdata/Renaming/LayoutIn2.hs:8:19-22} \n   (HsVar {Name: list})) \n  (MatchGroup \n   [\n    (L {test/testdata/Renaming/LayoutIn2.hs:8:26-36} \n     (Match \n      [\n       (L {test/testdata/Renaming/LayoutIn2.hs:8:26-31} \n        (ParPat \n     "

      -- Now to do it for the second item in the list
      let (GHC.L m2l _) = head $ drop 1 matches
      (showSrcSpan m2l) `shouldBe` "((10,28),(11,66))"
      let (m2,forest2) = indentDeclToks (head $ drop 1 matches) forest' (-2)

      -- (show forest2) `shouldBe` ""
      -- TODO: sort out this invariant failing
      -- (show forest) `shouldBe` "forest"
      -- (show forest') `shouldBe` "forest'"
      -- (show forest2) `shouldBe` "forest2"
      (invariant forest2) `shouldBe` []
      (drawTreeEntry forest2) `shouldBe`
              "((10000000001,1),(10000000012,43))\n|\n"++
              "+- ((1,1),(8,26))\n|\n"++
              "+- ((8,26),(8,37))\n|\n"++
              "`- ((10000000010,28),(10000000012,43))\n   |\n"++
              "   +- ((10,26),(11,64))\n   |\n"++
              "   `- ((12,28),(12,43))\n"

      let toksFinal2 = retrieveTokensFinal forest2
      (GHC.showRichTokenStream toksFinal2) `shouldBe` "module LayoutIn2 where\n\n --Layout rule applies after 'where','let','do' and 'of'\n\n --In this Example: rename 'list' to 'ls'.\n\n silly :: [Int] -> Int\n silly list = case list of(1:xs) -> 1\n--There is a comment\n                          (2:xs)\n                            | x < 10    -> 4  where  x = last xs\n                            otherwise -> 12\n\n "

      let decl2 = (GHC.L l (GHC.HsCase expr (GHC.MatchGroup (m1:m2:(tail $ tail matches)) typ)))
      (showGhc decl2) `shouldBe` "case list of {\n  (1 : xs) -> 1\n  (2 : xs)\n    | x GHC.Classes.< 10 -> 4\n    where\n        x = GHC.List.last xs\n  otherwise -> 12 }"
      (take 320 $ SYB.showData SYB.Renamer 0 decl2) `shouldBe` "\n(L {test/testdata/Renaming/LayoutIn2.hs:(8,14)-(12,42)} \n (HsCase \n  (L {test/testdata/Renaming/LayoutIn2.hs:8:19-22} \n   (HsVar {Name: list})) \n  (MatchGroup \n   [\n    (L {test/testdata/Renaming/LayoutIn2.hs:8:26-36} \n     (Match \n      [\n       (L {test/testdata/Renaming/LayoutIn2.hs:8:26-31} \n        (ParPat \n     "

  -- ---------------------------------------------

  describe "reSequenceToks" $ do
    it "Modifies a token stream to cater for changes in length of a token after e.g. renaming" $ do
      pending -- "write this"

  -- ---------------------------------------------

  describe "getTreeFromCache" $ do
    it "get the appropriate tree from the token cache, based on the SrcSpan" $ do
      (t,toks) <- parsedFileDemoteD1
      let tk = initTokenCache toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let (GHC.L l _) = head decls
      (showGhc l) `shouldBe` "test/testdata/Demote/D1.hs:11:1-7"
      (showSrcSpan l) `shouldBe` "((11,1),(11,8))"

      let tk' = removeToksFromCache tk l
      (drawTokenCache tk') `shouldBe`
               "tree TId 0:\n"++
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(9,14))\n|\n"++
               "+- ((11,1),(11,8))(2,-7)D\n|\n"++
               "`- ((13,1),(13,25))\n"++
               "tree TId 1:\n"++
               "((100000011,1),(100000011,8))\n"
      let mainForest = (tkCache tk') Map.! mainTid
      let sspan = posToSrcSpan mainForest ((11,1),(11,8))

      let tree1 = getTreeFromCache sspan tk'
      (drawTreeEntry tree1) `shouldBe`
             "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(9,14))\n|\n"++
               "+- ((11,1),(11,8))(2,-7)D\n|\n"++
               "`- ((13,1),(13,25))\n"

      let sspan2 = insertForestLineInSrcSpan (ForestLine False 1 0 1) sspan
      (showGhc sspan2) `shouldBe` "test/testdata/Demote/D1.hs:(33554433,1)-(33554443,7)"
      (showSrcSpanF sspan2) `shouldBe` "(((False,1,0,1),1),((False,1,0,11),8))"

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
      (showGhc l) `shouldBe` "test/testdata/Demote/D1.hs:11:1-7"
      (showSrcSpan l) `shouldBe` "((11,1),(11,8))"

      let tk' = removeToksFromCache tk l
      (drawTokenCache tk') `shouldBe`
               "tree TId 0:\n"++
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(9,14))\n|\n"++
               "+- ((11,1),(11,8))(2,-7)D\n|\n"++
               "`- ((13,1),(13,25))\n"++
               "tree TId 1:\n"++
               "((100000011,1),(100000011,8))\n"
      let mainForest = (tkCache tk') Map.! mainTid
      let sspan = posToSrcSpan mainForest ((11,1),(11,8))

      let sspan2 = insertForestLineInSrcSpan (ForestLine False 1 0 1) sspan
      (showGhc sspan2) `shouldBe` "test/testdata/Demote/D1.hs:(33554433,1)-(33554443,7)"
      (showSrcSpanF sspan2) `shouldBe` "(((False,1,0,1),1),((False,1,0,11),8))"

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
               "+- ((11,1),(11,8))(2,-7)D\n|\n"++
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
               "((1,1),(18,23))\n|\n"++
               "+- ((1,1),(14,18))\n|\n"++
               "+- ((15,1),(15,17))(2,-16)D\n|\n"++
               "`- ((17,1),(18,23))\n"++
               "tree TId 1:\n"++
               "((100000015,1),(100000015,17))\n"

      let tree1 = (tkCache tk') Map.! (TId 1)

      (show $ retrieveTokensInterim tree1) `shouldBe` "[((((15,1),(15,1)),ITsemi),\"\"),((((15,1),(15,3)),ITvarid \"sq\"),\"sq\"),((((15,4),(15,7)),ITvarid \"pow\"),\"pow\"),((((15,8),(15,9)),ITvarid \"z\"),\"z\"),((((15,10),(15,11)),ITequal),\"=\"),((((15,12),(15,13)),ITvarid \"z\"),\"z\"),((((15,13),(15,14)),ITvarsym \"^\"),\"^\"),((((15,14),(15,17)),ITvarid \"pow\"),\"pow\"),((((15,19),(15,39)),ITlineComment \"--there is a comment\"),\"--there is a comment\")]"

      -- putToksForSpan test/testdata/Demote/WhereIn4.hs:100000015:14-16:[((((0,1),(0,2)),ITvarid "p"),"p")]

      -- let sspan3 = posToSrcSpan mainForest ((100000015,14),(100000015,17))
      let sspan3 = posToSrcSpan mainForest $
                        (((forestLineToGhcLine $ ForestLine False 1 0 15),14),
                         ((forestLineToGhcLine $ ForestLine False 1 0 15),17) )

      -- (showGhc sspan3) `shouldBe` "test/testdata/Demote/WhereIn4.hs:100000015:14-16"
      (showGhc sspan3) `shouldBe` "test/testdata/Demote/WhereIn4.hs:33554447:14-16"
      (showSrcSpanF sspan3) `shouldBe` "(((False,1,0,15),14),((False,1,0,15),17))"
      let toks3 = [mkToken (GHC.ITvarid (GHC.mkFastString "p")) (0,1) "p"]
      (show toks3) `shouldBe` "[((((0,1),(0,2)),ITvarid \"p\"),\"p\")]"
      let (tk3,_newSpan) = putToksInCache tk' sspan3 toks3
      (drawTokenCache tk3) `shouldBe`
               "tree TId 0:\n"++
               "((1,1),(18,23))\n|\n"++
               "+- ((1,1),(14,18))\n|\n"++
               "+- ((15,1),(15,17))(2,-16)D\n|\n"++
               "`- ((17,1),(18,23))\n"++
               "tree TId 1:\n"++
               "((100000015,1),(100000015,17))\n|\n"++
               "+- ((100000015,1),(100000015,14))\n|\n"++
               "`- ((10100000015,14),(10100000015,15))\n"++
               "tree TId 2:\n"++
               "((200000015,14),(200000015,17))\n"

      let (forest2,tree1') = getSrcSpanFor tree1 (srcSpanToForestSpan sspan3)
      (show $ retrieveTokensInterim forest2) `shouldBe` "[((((15,1),(15,1)),ITsemi),\"\"),((((15,1),(15,3)),ITvarid \"sq\"),\"sq\"),((((15,4),(15,7)),ITvarid \"pow\"),\"pow\"),((((15,8),(15,9)),ITvarid \"z\"),\"z\"),((((15,10),(15,11)),ITequal),\"=\"),((((15,12),(15,13)),ITvarid \"z\"),\"z\"),((((15,13),(15,14)),ITvarsym \"^\"),\"^\"),((((15,14),(15,17)),ITvarid \"pow\"),\"pow\"),((((15,19),(15,39)),ITlineComment \"--there is a comment\"),\"--there is a comment\")]"

      (show $ retrieveTokensInterim tree1') `shouldBe` "[((((15,14),(15,17)),ITvarid \"pow\"),\"pow\"),((((15,19),(15,39)),ITlineComment \"--there is a comment\"),\"--there is a comment\")]"

      let tree3 = (tkCache tk3) Map.! (TId 1)
      (show $ retrieveTokensInterim tree3) `shouldBe` "[((((15,1),(15,1)),ITsemi),\"\"),((((15,1),(15,3)),ITvarid \"sq\"),\"sq\"),((((15,4),(15,7)),ITvarid \"pow\"),\"pow\"),((((15,8),(15,9)),ITvarid \"z\"),\"z\"),((((15,10),(15,11)),ITequal),\"=\"),((((15,12),(15,13)),ITvarid \"z\"),\"z\"),((((15,13),(15,14)),ITvarsym \"^\"),\"^\"),((((15,14),(15,15)),ITvarid \"p\"),\"p\"),((((15,19),(15,39)),ITlineComment \"--there is a comment\"),\"--there is a comment\")]"

  -- ---------------------------------------------

  describe "syncAstToLatestCache" $ do
    it "update the SrcSpans in a declaration to match the latest stash" $ do
      (t,toks) <- parsedFileDemoteD1
      let tk = initTokenCache toks

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head decls
      (showGhc l) `shouldBe` "test/testdata/Demote/D1.hs:11:1-7"
      (showSrcSpan l) `shouldBe` "((11,1),(11,8))"

      let tk' = removeToksFromCache tk l
      (drawTokenCache tk') `shouldBe`
               "tree TId 0:\n"++
               "((1,1),(13,25))\n|\n"++
               "+- ((1,1),(9,14))\n|\n"++
               "+- ((11,1),(11,8))(2,-7)D\n|\n"++
               "`- ((13,1),(13,25))\n"++
               "tree TId 1:\n"++
               "((100000011,1),(100000011,8))\n"

      let mainForest = (tkCache tk') Map.! mainTid
      let sspan = posToSrcSpan mainForest ((11,1),(11,8))

      let sspan2 = insertForestLineInSrcSpan (ForestLine False 1 0 1) sspan
      (showGhc sspan2) `shouldBe` "test/testdata/Demote/D1.hs:(33554433,1)-(33554443,7)"
      (showSrcSpanF sspan2) `shouldBe` "(((False,1,0,1),1),((False,1,0,11),8))"

      let (GHC.L ss' _) = syncAstToLatestCache tk' decl
      -- (showGhc ss') `shouldBe` "test/testdata/Demote/D1.hs:100000011:1-7"
      (showGhc ss') `shouldBe` "test/testdata/Demote/D1.hs:33554443:1-7"
      (showSrcSpanF ss') `shouldBe` "(((False,1,0,11),1),((False,1,0,11),8))"

  -- ---------------------------------------------

  describe "formatAfterDelete" $ do
    it "Does not leave a blank line in toks after deleting" $ do
      (t,toks) <- parsedFileTokenTestGhc
      let f1 = mkTreeFromTokens toks
      (GHC.showRichTokenStream $ retrieveTokensFinal f1) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n\n bab a b =\n   let bar = 3\n   in     b + bar -- ^trailing comment\n\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n\n\n\n "

      let renamed = fromJust $ GHC.tm_renamed_source t
      let decls = hsBinds renamed
      let decl@(GHC.L l _) = head $ drop 1 decls
      (showGhc l) `shouldBe` "test/testdata/TokenTest.hs:(13,1)-(15,16)"
      (showSrcSpan l) `shouldBe` "((13,1),(15,17))"

      let (f2,_) = removeSrcSpan f1 (fs l)

      (drawTreeEntry f2) `shouldBe`
            "((1,1),(21,14))\n|\n"++
            "+- ((1,1),(10,10))\n|\n"++
            "+- ((13,1),(15,17))(3,-16)D\n|\n"++
            "`- ((19,1),(21,14))\n"

      let es = retrieveTokens' f2
      -- (show $ deleteGapsToks es) `shouldBe` ""
      (GHC.showRichTokenStream $ retrieveTokensFinal f2) `shouldBe` "module TokenTest where\n\n -- Test new style token manager\n\n bob a b = x\n   where x = 3\n\n bib a b = x\n   where\n     x = 3\n\n -- leading comment\n foo x y =\n   do c <- getChar\n      return c\n\n\n\n\n "

  -- ---------------------------------------------

  describe "deleteGapsToks" $ do
    it "Closes the gap when finding a Deleted Entry" $ do
      (t,toks) <- parsedFileLiftWhereIn1Ghc
      let f1 = mkTreeFromTokens toks

      -- removeToksForPos ((11,18),(12,32))
      -- |  +- ((11,18),(12,31))D
      let pos = ((11,18),(12,32))
      let sspan = posToSrcSpan f1 pos
      let (f2,_t2) = removeSrcSpan f1 (srcSpanToForestSpan sspan)

      (drawTreeEntry f2) `shouldBe`
            "((1,1),(16,23))\n|\n"++
            "+- ((1,1),(10,17))\n|\n"++
            "+- ((11,18),(12,32))(1,-14)D\n|\n"++
            "`- ((13,18),(16,23))\n"

      -- putDeclToksAfterSpan test/testdata/LiftToToplevel/WhereIn1.hs:(9,1)-(13,22):("(((False,0,0,9),1),((False,0,0,13),23))",PlaceOffset 2 0 2,[((((1,19),(1,21)),ITvarid "sq"),"sq"),((((1,23),(1,26)),ITvarid "pow"),"pow"),((((1,27),(1,28)),ITinteger 0),"0"),((((1,28),(1,29)),ITequal),"="),((((1,30),(1,31)),ITinteger 0),"0"),((((2,19),(2,21)),ITvarid "sq"),"sq"),((((2,23),(2,26)),ITvarid "pow"),"pow"),((((2,27),(2,28)),ITvarid "z"),"z"),((((2,28),(2,29)),ITequal),"="),((((2,30),(2,31)),ITvarid "z"),"z"),((((2,31),(2,32)),ITvarsym "^"),"^"),((((2,32),(2,35)),ITvarid "pow"),"pow")])

      newToks <- liftIO $ basicTokenise "\n                  sq  pow 0= 0\n                  sq  pow z= z^pow"
      (show newToks) `shouldBe` "[((((1,19),(1,21)),ITvarid \"sq\"),\"sq\"),((((1,23),(1,26)),ITvarid \"pow\"),\"pow\"),((((1,27),(1,28)),ITinteger 0),\"0\"),((((1,28),(1,29)),ITequal),\"=\"),((((1,30),(1,31)),ITinteger 0),\"0\"),((((2,19),(2,21)),ITvarid \"sq\"),\"sq\"),((((2,23),(2,26)),ITvarid \"pow\"),\"pow\"),((((2,27),(2,28)),ITvarid \"z\"),\"z\"),((((2,28),(2,29)),ITequal),\"=\"),((((2,30),(2,31)),ITvarid \"z\"),\"z\"),((((2,31),(2,32)),ITvarsym \"^\"),\"^\"),((((2,32),(2,35)),ITvarid \"pow\"),\"pow\")]"

      let sspan2 = posToSrcSpan f1 ((9,1),(13,23))
      let pos2 = (PlaceOffset 2 0 2)
      let (f3,_newSpan) = addToksAfterSrcSpan f2 sspan2 pos2 newToks
      (drawTreeEntry f3) `shouldBe`
            "((1,1),(16,23))\n|\n"++
            "+- ((1,1),(1,37))\n|\n"++
            "+- ((9,1),(13,23))\n|  |\n"++
            "|  +- ((9,1),(10,17))\n|  |\n"++
            "|  +- ((11,18),(12,32))(1,-14)D\n|  |\n"++
            "|  `- ((13,18),(13,23))\n|\n"++
            "+- ((1000015,1),(1000016,17))\n|\n"++
            "`- ((15,1),(16,23))\n"

--
      -- Seems the problem is in addToksAfterSrcSpan

      let (fwithspan,tree) = getSrcSpanFor f2 (srcSpanToForestSpan sspan2)

      let z = openZipperToSpan (srcSpanToForestSpan sspan2) $ Z.fromTree fwithspan
      let prevToks = case (retrievePrevLineToks z) of
                   RT [] -> reverseToks $ retrieveTokensInterim tree
                   xs -> xs

      let prevToks' = limitPrevToks prevToks sspan2
      let toks' = reIndentToks pos2 (unReverseToks prevToks') newToks

      -- Hmmm. This is the final position, after taking into account
      -- the deleted entry. BUT, we are putting it back into the
      -- original tree.
      (show $ last $ unReverseToks prevToks') `shouldBe` "((((13,22),(13,23)),ITinteger 2),\"2\")"

      -- What we actually need, but we are getting ((13,1),(13,3))
      let toks'' = placeToksForSpan fwithspan sspan2 tree pos2 newToks
      (show $ head toks'') `shouldBe` "((((15,1),(15,3)),ITvarid \"sq\"),\"sq\")"

--


      -- (showTree f3) `shouldBe` ""

      -- (GHC.showRichTokenStream $ retrieveTokensFinal f3) `shouldBe` ""

      let entries = retrieveTokens' f3

      -- (show entries) `shouldBe` ""

      -- (show $ deleteGapsToks entries) `shouldBe` ""
      -- (show $ deleteGapsToks' entries) `shouldBe` ""

      (GHC.showRichTokenStream $ retrieveTokensFinal f3) `shouldBe` "module LiftToToplevel.WhereIn1 where\n\n --A definition can be lifted from a where or let to the top level binding group.\n --Lifting a definition widens the scope of the definition.\n\n --In this example, lift 'sq' in 'sumSquares'\n --This example aims to test add parameters to 'sq'.\n\n sumSquares x y = sq x + sq y\n            where\n                  pow=2\n\n sq  pow 0= 0\n sq  pow z= z^pow\n\n \n anotherFun 0 y = sq y\n      where  sq x = x^2\n "


  -- ---------------------------------------------

  describe "calcEndGap" $ do
    it "Closes the gap when finding a Deleted Entry" $ do
      (_t,toks) <- parsedFileLiftWhereIn1Ghc
      let f1 = mkTreeFromTokens toks

      let pos = ((11,18),(12,32))
      let sspan = posToSrcSpan f1 pos
      let (f2,_t2) = removeSrcSpan f1 (srcSpanToForestSpan sspan)

      (drawTreeEntry f2) `shouldBe`
            "((1,1),(16,23))\n|\n"++
            "+- ((1,1),(10,17))\n|\n"++
            "+- ((11,18),(12,32))(1,-14)D\n|\n"++
            "`- ((13,18),(16,23))\n"

      (calcEndGap f2 (fs sspan)) `shouldBe` (1,-14)
      
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
nonNullSpan = ((ForestLine False 0 0 0,0),(ForestLine False 0 0 1,0))


-- ---------------------------------------------------------------------

liftD1FileName :: GHC.FastString
liftD1FileName = GHC.mkFastString "./test/testdata/LiftToToplevel/D1.hs"

parsedFileLiftD1Ghc :: IO (ParseResult,[PosToken])
parsedFileLiftD1Ghc = parsedFileGhc "./test/testdata/LiftToToplevel/D1.hs"

-- ---------------------------------------------------------------------

liftLetIn1FileName :: GHC.FastString
liftLetIn1FileName = GHC.mkFastString "./test/testdata/LiftToToplevel/LetIn1.hs"

parsedFileLiftLetIn1Ghc :: IO (ParseResult,[PosToken])
parsedFileLiftLetIn1Ghc = parsedFileGhc "./test/testdata/LiftToToplevel/LetIn1.hs"

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

liftWhereIn1FileName :: GHC.FastString
liftWhereIn1FileName = GHC.mkFastString "./test/testdata/LiftToToplevel/WhereIn1.hs"

parsedFileLiftWhereIn1Ghc :: IO (ParseResult,[PosToken])
parsedFileLiftWhereIn1Ghc = parsedFileGhc "./test/testdata/LiftToToplevel/WhereIn1.hs"

-- ---------------------------------------------------------------------

dd1FileName :: GHC.FastString
dd1FileName = GHC.mkFastString "./test/testdata/DupDef/Dd1.hs"

parsedFileDd1Ghc :: IO (ParseResult,[PosToken])
parsedFileDd1Ghc = parsedFileGhc "./test/testdata/DupDef/Dd1.hs"

-- ---------------------------------------------------------------------

layoutIn2FileName :: GHC.FastString
layoutIn2FileName = GHC.mkFastString "./test/testdata/Renaming/LayoutIn2.hs"

parsedFileLayoutIn2 :: IO (ParseResult, [PosToken])
parsedFileLayoutIn2 = parsedFileGhc "./test/testdata/Renaming/LayoutIn2.hs"

-- ---------------------------------------------------------------------
