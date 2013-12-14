module DualTreeSpec (main, spec) where

import           Test.Hspec

-- import qualified FastString as GHC
import qualified GHC        as GHC
-- import qualified Lexer      as GHC

-- import qualified GHC.SYB.Utils as SYB

-- import Control.Monad.State
-- import Data.List
-- import Data.Maybe
-- import Data.Tree

import Language.Haskell.Refact.Utils.DualTree
import Language.Haskell.Refact.Utils.GhcBugWorkArounds
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.Layout
import Language.Haskell.Refact.Utils.LocUtils
-- import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TokenUtils
-- import Language.Haskell.Refact.Utils.TokenUtilsTypes
-- import Language.Haskell.Refact.Utils.TypeSyn
-- import Language.Haskell.Refact.Utils.TypeUtils

import Data.Tree.DUAL

import TestUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do


  -- ---------------------------------------------

  describe "layoutTreeToSourceTree" $ do
    it "retrieves the tokens in SourceTree format LetExpr" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/Layout/LetExpr.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      (GHC.showRichTokenStream toks) `shouldBe` "-- A simple let expression, to ensure the layout is detected\n\n module Layout.LetExpr where\n\n foo = let x = 1\n           y = 2\n       in x + y\n\n "
      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(9,1))\n"++
          "1:((1,1),(3,7))\n"++
          "1:((3,8),(3,22))\n"++
          "1:((3,23),(3,28))\n"++
          "1:((5,1),(7,15))\n"++
          "2:((5,1),(5,4))\n"++
          "2:((5,5),(7,15))\n"++
          "3:((5,5),(5,6))\n"++
          "3:((5,7),(7,15))\n"++
          "4:((5,7),(5,10))\n"++
          "4:((5,11),(6,16))(Above None (5,11) (6,16) FromAlignCol (1,-9))\n"++
          "5:((5,11),(5,16))\n"++
          "6:((5,11),(5,12))\n"++
          "6:((5,13),(5,16))\n"++
          "7:((5,13),(5,14))\n"++
          "7:((5,15),(5,16))\n"++
          "5:((6,11),(6,16))\n"++
          "6:((6,11),(6,12))\n"++
          "6:((6,13),(6,16))\n"++
          "7:((6,13),(6,14))\n"++
          "7:((6,15),(6,16))\n"++
          "4:((7,10),(7,15))\n"++
          "5:((7,10),(7,11))\n"++
          "5:((7,12),(7,13))\n"++
          "5:((7,14),(7,15))\n"++
          "1:((9,1),(9,1))\n"


      let srcTree = layoutTreeToSourceTree layout
      -- (showGhc srcTree) `shouldBe` ""
      -- (show $ retrieveLines srcTree) `shouldBe` ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format LetStmt" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/Layout/LetStmt.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      (GHC.showRichTokenStream $ bypassGHCBug7351 toks) `shouldBe` "-- A simple let statement, to ensure the layout is detected\n\nmodule Layout.LetStmt where\n\nfoo = do\n        let x = 1\n            y = 2\n        x+y\n\n"

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []
      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(10,1))\n"++
          "1:((1,1),(3,7))\n"++
          "1:((3,8),(3,22))\n"++
          "1:((3,23),(3,28))\n"++
          "1:((5,1),(8,12))\n"++
          "2:((5,1),(5,4))\n"++
          "2:((5,5),(8,12))\n"++
          "3:((5,5),(5,6))\n"++
          "3:((5,7),(8,12))\n"++
          "4:((5,7),(5,9))\n"++
          "4:((6,9),(8,12))(Above FromAlignCol (1,-1) (6,9) (8,12) FromAlignCol (2,-11))\n"++
          "5:((6,9),(7,18))\n"++
          "6:((6,9),(6,12))\n"++
          "6:((6,13),(7,18))(Above None (6,13) (7,18) FromAlignCol (1,-9))\n"++
          "7:((6,13),(6,18))\n"++
          "8:((6,13),(6,14))\n"++
          "8:((6,15),(6,18))\n"++
          "9:((6,15),(6,16))\n"++
          "9:((6,17),(6,18))\n"++
          "7:((7,13),(7,18))\n"++
          "8:((7,13),(7,14))\n"++
          "8:((7,15),(7,18))\n"++
          "9:((7,15),(7,16))\n"++
          "9:((7,17),(7,18))\n"++
          "5:((8,9),(8,12))\n"++
          "6:((8,9),(8,10))\n"++
          "6:((8,10),(8,11))\n"++
          "6:((8,11),(8,12))\n"++
          "1:((10,1),(10,1))\n"


      -- (show layout) `shouldBe` ""

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --    ""

      (renderSourceTree srcTree) `shouldBe`
          "-- A simple let statement, to ensure the layout is detected\n\nmodule Layout.LetStmt where\n\nfoo = do\n        let x = 1\n            y = 2\n        x+y\n\n"

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format LayoutIn2" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/Renaming/LayoutIn2.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      (GHC.showRichTokenStream $ bypassGHCBug7351 toks) `shouldBe` "module LayoutIn2 where\n\n--Layout rule applies after 'where','let','do' and 'of'\n\n--In this Example: rename 'list' to 'ls'.\n\nsilly :: [Int] -> Int\nsilly list = case list of  (1:xs) -> 1\n--There is a comment\n                           (2:xs)\n                             | x < 10    -> 4  where  x = last xs\n                           otherwise -> 12\n\n"

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(14,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,17))\n"++
          "1:((1,18),(1,23))\n"++
          "1:((7,1),(7,22))\n"++
          "2:((7,1),(7,6))\n"++
          "2:((7,7),(7,9))\n"++
          "2:((7,10),(7,11))\n"++
          "2:((7,11),(7,14))\n"++
          "2:((7,14),(7,15))\n"++
          "2:((7,16),(7,18))\n"++
          "2:((7,19),(7,22))\n"++
          "1:((8,1),(12,43))\n"++
          "2:((8,1),(8,6))\n"++
          "2:((8,7),(12,43))\n"++
          "3:((8,7),(8,11))\n"++
          "3:((8,12),(8,13))\n"++
          "3:((8,14),(12,43))\n"++
          "4:((8,14),(8,18))\n"++
          "4:((8,19),(8,23))\n"++
          "4:((8,24),(8,26))\n"++
          "4:((8,28),(12,43))(Above SameLine 1 (8,28) (12,43) FromAlignCol (2,-42))\n"++
          "5:((8,28),(8,39))\n"++
          "6:((8,28),(8,34))\n"++
          "6:((8,35),(8,37))\n"++
          "6:((8,38),(8,39))\n"++
          "5:((9,1),(11,66))\n"++
          "6:((9,1),(10,34))\n"++
          "6:((11,30),(11,46))\n"++
          "7:((11,30),(11,31))\n"++
          "7:((11,32),(11,38))\n"++
          "8:((11,32),(11,33))\n"++
          "8:((11,34),(11,35))\n"++
          "8:((11,36),(11,38))\n"++
          "7:((11,45),(11,46))\n"++
          "6:((11,48),(11,53))\n"++
          "6:((11,55),(11,66))(Above SameLine 1 (11,55) (11,66) FromAlignCol (1,-38))\n"++
          "7:((11,55),(11,66))\n"++
          "8:((11,55),(11,56))\n"++
          "8:((11,57),(11,66))\n"++
          "9:((11,57),(11,58))\n"++
          "9:((11,59),(11,66))\n"++
          "10:((11,59),(11,63))\n"++
          "10:((11,64),(11,66))\n"++
          "5:((12,28),(12,43))\n"++
          "6:((12,28),(12,37))\n"++
          "6:((12,38),(12,40))\n"++
          "6:((12,41),(12,43))\n"++
          "1:((14,1),(14,1))\n"

      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format LetIn1" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/LiftToToplevel/LetIn1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""

      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format Where" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/Layout/Where.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format PatBind" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/Layout/PatBind.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(13,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,22))\n"++
         "1:((1,23),(1,28))\n"++
         "1:((4,1),(4,18))\n"++
         "2:((4,1),(4,4))\n"++
         "2:((4,5),(4,7))\n"++
         "2:((4,8),(4,9))\n"++
         "2:((4,9),(4,12))\n"++
         "2:((4,12),(4,13))\n"++
         "2:((4,14),(4,17))\n"++
         "2:((4,17),(4,18))\n"++
         "1:((5,1),(5,9))\n"++
         "2:((5,1),(5,2))\n"++
         "2:((5,3),(5,5))\n"++
         "2:((5,6),(5,9))\n"++
         "1:((6,1),(6,9))\n"++
         "2:((6,1),(6,2))\n"++
         "2:((6,3),(6,5))\n"++
         "2:((6,6),(6,9))\n"++
         "1:((7,1),(10,12))\n"++
         "2:((7,1),(7,10))\n"++
         "2:((7,11),(7,12))\n"++
         "2:((7,13),(7,38))\n"++
         "3:((7,13),(7,17))\n"++
         "3:((7,18),(7,19))\n"++
         "3:((7,20),(7,38))\n"++
         "4:((7,20),(7,30))\n"++
         "5:((7,20),(7,23))\n"++
         "5:((7,24),(7,30))\n"++
         "6:((7,24),(7,25))\n"++
         "6:((7,25),(7,26))\n"++
         "6:((7,28),(7,30))\n"++
         "4:((7,32),(7,38))\n"++
         "5:((7,32),(7,33))\n"++
         "5:((7,33),(7,34))\n"++
         "5:((7,36),(7,38))\n"++
         "2:((8,3),(8,8))\n"++
         "2:((9,5),(10,12))(Above FromAlignCol (1,-4) (9,5) (10,12) FromAlignCol (3,-11))\n"++
         "3:((9,5),(9,14))\n"++
         "4:((9,5),(9,7))\n"++
         "4:((9,8),(9,10))\n"++
         "4:((9,11),(9,14))\n"++
         "3:((10,5),(10,12))\n"++
         "4:((10,5),(10,7))\n"++
         "4:((10,8),(10,12))\n"++
         "5:((10,8),(10,9))\n"++
         "5:((10,10),(10,12))\n"++
         "1:((13,1),(13,1))\n"

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format TokenTest" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/TokenTest.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""

      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(26,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,17))\n"++
          "1:((1,18),(1,23))\n"++
          "1:((5,1),(6,14))\n"++
          "2:((5,1),(5,4))\n"++
          "2:((5,5),(6,14))\n"++
          "3:((5,5),(5,6))\n"++
          "3:((5,7),(5,8))\n"++
          "3:((5,9),(5,10))\n"++
          "3:((5,11),(5,12))\n"++
          "3:((6,3),(6,8))\n"++
          "3:((6,9),(6,14))(Above None (6,9) (6,14) FromAlignCol (2,-13))\n"++
          "4:((6,9),(6,14))\n"++
          "5:((6,9),(6,10))\n"++
          "5:((6,11),(6,14))\n"++
          "6:((6,11),(6,12))\n"++
          "6:((6,13),(6,14))\n"++
          "1:((8,1),(10,10))\n"++
          "2:((8,1),(8,4))\n"++
          "2:((8,5),(10,10))\n"++
          "3:((8,5),(8,6))\n"++
          "3:((8,7),(8,8))\n"++
          "3:((8,9),(8,10))\n"++
          "3:((8,11),(8,12))\n"++
          "3:((9,3),(9,8))\n"++
          "3:((10,5),(10,10))(Above FromAlignCol (1,-4) (10,5) (10,10) FromAlignCol (3,-9))\n"++
          "4:((10,5),(10,10))\n"++
          "5:((10,5),(10,6))\n"++
          "5:((10,7),(10,10))\n"++
          "6:((10,7),(10,8))\n"++
          "6:((10,9),(10,10))\n"++
          "1:((13,1),(15,17))\n"++
          "2:((13,1),(13,4))\n"++
          "2:((13,5),(15,17))\n"++
          "3:((13,5),(13,6))\n"++
          "3:((13,7),(13,8))\n"++
          "3:((13,9),(13,10))\n"++
          "3:((14,3),(15,17))\n"++
          "4:((14,3),(14,6))\n"++
          "4:((14,7),(14,14))(Above None (14,7) (14,14) FromAlignCol (1,-11))\n"++
          "5:((14,7),(14,14))\n"++
          "6:((14,7),(14,10))\n"++
          "6:((14,11),(14,14))\n"++
          "7:((14,11),(14,12))\n"++
          "7:((14,13),(14,14))\n"++
          "4:((15,10),(15,17))\n"++
          "5:((15,10),(15,11))\n"++
          "5:((15,12),(15,13))\n"++
          "5:((15,14),(15,17))\n"++
          "1:((19,1),(21,14))\n"++
          "2:((19,1),(19,4))\n"++
          "2:((19,5),(21,14))\n"++
          "3:((19,5),(19,6))\n"++
          "3:((19,7),(19,8))\n"++
          "3:((19,9),(19,10))\n"++
          "3:((20,3),(21,14))\n"++
          "4:((20,3),(20,5))\n"++
          "4:((20,6),(21,14))(Above None (20,6) (21,14) FromAlignCol (5,-13))\n"++
          "5:((20,6),(20,18))\n"++
          "6:((20,6),(20,7))\n"++
          "6:((20,11),(20,18))\n"++
          "5:((21,6),(21,14))\n"++
          "6:((21,6),(21,12))\n"++
          "6:((21,13),(21,14))\n"++
          "1:((26,1),(26,1))\n"

      let srcTree = layoutTreeToSourceTree layout
{-
      srcTree `shouldBe`
          []
-}
      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format Md1" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/MoveDef/Md1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""
      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(44,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,19))\n"++
          "1:((1,20),(1,25))\n"++
          "1:((3,1),(3,31))\n"++
          "2:((3,1),(3,9))\n"++
          "2:((3,10),(3,12))\n"++
          "2:((3,13),(3,20))\n"++
          "2:((3,21),(3,23))\n"++
          "2:((3,24),(3,31))\n"++
          "1:((4,1),(4,19))\n"++
          "2:((4,1),(4,9))\n"++
          "2:((4,10),(4,19))\n"++
          "3:((4,10),(4,11))\n"++
          "3:((4,12),(4,13))\n"++
          "3:((4,14),(4,19))\n"++
          "4:((4,14),(4,15))\n"++
          "4:((4,16),(4,17))\n"++
          "4:((4,18),(4,19))\n"++
          "1:((6,1),(6,15))\n"++
          "2:((6,1),(6,2))\n"++
          "2:((6,2),(6,3))\n"++
          "2:((6,3),(6,4))\n"++
          "2:((6,5),(6,7))\n"++
          "2:((6,8),(6,15))\n"++
          "1:((7,1),(7,6))\n"++
          "2:((7,1),(7,2))\n"++
          "2:((7,3),(7,6))\n"++
          "3:((7,3),(7,4))\n"++
          "3:((7,5),(7,6))\n"++
          "1:((8,1),(8,6))\n"++
          "2:((8,1),(8,2))\n"++
          "2:((8,3),(8,6))\n"++
          "3:((8,3),(8,4))\n"++
          "3:((8,5),(8,6))\n"++
          "1:((11,1),(11,18))\n"++
          "2:((11,1),(11,4))\n"++
          "2:((11,5),(11,7))\n"++
          "2:((11,8),(11,9))\n"++
          "2:((11,9),(11,12))\n"++
          "2:((11,12),(11,13))\n"++
          "2:((11,14),(11,17))\n"++
          "2:((11,17),(11,18))\n"++
          "1:((12,1),(12,9))\n"++
          "2:((12,1),(12,2))\n"++
          "2:((12,3),(12,5))\n"++
          "2:((12,6),(12,9))\n"++
          "1:((13,1),(13,9))\n"++
          "2:((13,1),(13,2))\n"++
          "2:((13,3),(13,5))\n"++
          "2:((13,6),(13,9))\n"++
          "1:((14,1),(17,12))\n"++
          "2:((14,1),(14,10))\n"++
          "2:((14,11),(14,12))\n"++
          "2:((14,13),(14,38))\n"++
          "3:((14,13),(14,17))\n"++
          "3:((14,18),(14,19))\n"++
          "3:((14,20),(14,38))\n"++
          "4:((14,20),(14,30))\n"++
          "5:((14,20),(14,23))\n"++
          "5:((14,24),(14,30))\n"++
          "6:((14,24),(14,25))\n"++
          "6:((14,25),(14,26))\n"++
          "6:((14,28),(14,30))\n"++
          "4:((14,32),(14,38))\n"++
          "5:((14,32),(14,33))\n"++
          "5:((14,33),(14,34))\n"++
          "5:((14,36),(14,38))\n"++
          "2:((15,3),(15,8))\n"++
          "2:((16,5),(17,12))(Above FromAlignCol (1,-4) (16,5) (17,12) FromAlignCol (2,-11))\n"++
          "3:((16,5),(16,14))\n"++
          "4:((16,5),(16,7))\n"++
          "4:((16,8),(16,10))\n"++
          "4:((16,11),(16,14))\n"++
          "3:((17,5),(17,12))\n"++
          "4:((17,5),(17,7))\n"++
          "4:((17,8),(17,12))\n"++
          "5:((17,8),(17,9))\n"++
          "5:((17,10),(17,12))\n"++
          "1:((19,1),(19,26))\n"++
          "2:((19,1),(19,5))\n"++
          "2:((19,6),(19,7))\n"++
          "2:((19,8),(19,26))\n"++
          "3:((19,8),(19,9))\n"++
          "3:((19,10),(19,11))\n"++
          "3:((19,12),(19,13))\n"++
          "3:((19,14),(19,22))\n"++
          "4:((19,14),(19,15))\n"++
          "4:((19,16),(19,22))\n"++
          "3:((19,23),(19,24))\n"++
          "3:((19,25),(19,26))\n"++
          "1:((21,1),(21,17))\n"++
          "2:((21,1),(21,3))\n"++
          "2:((21,4),(21,6))\n"++
          "2:((21,7),(21,10))\n"++
          "2:((21,11),(21,13))\n"++
          "2:((21,14),(21,17))\n"++
          "1:((22,1),(24,11))\n"++
          "2:((22,1),(22,3))\n"++
          "2:((22,4),(24,11))\n"++
          "3:((22,4),(22,5))\n"++
          "3:((22,6),(22,7))\n"++
          "3:((22,8),(22,14))\n"++
          "4:((22,8),(22,9))\n"++
          "4:((22,10),(22,11))\n"++
          "4:((22,12),(22,14))\n"++
          "3:((23,3),(23,8))\n"++
          "3:((24,5),(24,11))(Above FromAlignCol (1,-4) (24,5) (24,11) FromAlignCol (2,-10))\n"++
          "4:((24,5),(24,11))\n"++
          "5:((24,5),(24,7))\n"++
          "5:((24,8),(24,11))\n"++
          "6:((24,8),(24,9))\n"++
          "6:((24,10),(24,11))\n"++
          "1:((26,1),(29,12))\n"++
          "2:((26,1),(26,2))\n"++
          "2:((26,3),(29,12))\n"++
          "3:((26,3),(26,4))\n"++
          "3:((26,5),(26,6))\n"++
          "3:((27,3),(29,12))\n"++
          "4:((27,3),(27,6))\n"++
          "4:((28,5),(28,12))(Above FromAlignCol (1,-2) (28,5) (28,12) FromAlignCol (1,-9))\n"++
          "5:((28,5),(28,12))\n"++
          "6:((28,5),(28,7))\n"++
          "6:((28,8),(28,12))\n"++
          "7:((28,8),(28,9))\n"++
          "7:((28,10),(28,12))\n"++
          "4:((29,6),(29,12))\n"++
          "5:((29,6),(29,8))\n"++
          "5:((29,9),(29,10))\n"++
          "5:((29,11),(29,12))\n"++
          "1:((31,1),(33,18))\n"++
          "2:((31,1),(31,3))\n"++
          "2:((31,4),(33,18))\n"++
          "3:((31,4),(31,5))\n"++
          "3:((31,6),(31,7))\n"++
          "3:((31,8),(33,18))\n"++
          "4:((31,8),(31,10))\n"++
          "4:((32,3),(33,18))(Above FromAlignCol (1,-8) (32,3) (33,18) FromAlignCol (2,-17))\n"++
          "5:((32,3),(32,13))\n"++
          "6:((32,3),(32,6))\n"++
          "6:((32,7),(32,13))(Above None (32,7) (32,13) FromAlignCol (1,-10))\n"++
          "7:((32,7),(32,13))\n"++
          "8:((32,7),(32,9))\n"++
          "8:((32,10),(32,13))\n"++
          "9:((32,10),(32,11))\n"++
          "9:((32,12),(32,13))\n"++
          "5:((33,3),(33,18))\n"++
          "6:((33,3),(33,9))\n"++
          "6:((33,10),(33,18))\n"++
          "7:((33,10),(33,11))\n"++
          "7:((33,11),(33,17))\n"++
          "8:((33,11),(33,13))\n"++
          "8:((33,14),(33,15))\n"++
          "8:((33,16),(33,17))\n"++
          "7:((33,17),(33,18))\n"++
          "1:((35,1),(35,23))\n"++
          "2:((35,1),(35,4))\n"++
          "2:((35,5),(35,23))\n"++
          "3:((35,5),(35,6))\n"++
          "3:((35,7),(35,8))\n"++
          "3:((35,9),(35,23))\n"++
          "4:((35,9),(35,10))\n"++
          "4:((35,11),(35,12))\n"++
          "4:((35,13),(35,23))\n"++
          "5:((35,13),(35,21))\n"++
          "5:((35,22),(35,23))\n"++
          "1:((39,1),(39,29))\n"++
          "2:((39,1),(39,7))\n"++
          "2:((39,8),(39,10))\n"++
          "2:((39,11),(39,18))\n"++
          "2:((39,19),(39,21))\n"++
          "2:((39,22),(39,29))\n"++
          "1:((40,1),(40,17))\n"++
          "2:((40,1),(40,7))\n"++
          "2:((40,8),(40,17))\n"++
          "3:((40,8),(40,9))\n"++
          "3:((40,10),(40,11))\n"++
          "3:((40,12),(40,17))\n"++
          "4:((40,12),(40,13))\n"++
          "4:((40,14),(40,15))\n"++
          "4:((40,16),(40,17))\n"++
          "1:((44,1),(44,1))\n"


      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format Layout.LetIn1" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/TypeUtils/LayoutLet1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""
      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(10,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,18))\n"++
         "1:((1,19),(1,24))\n"++
         "1:((6,1),(8,25))\n"++
         "2:((6,1),(6,4))\n"++
         "2:((6,5),(8,25))\n"++
         "3:((6,5),(6,8))\n"++
         "3:((6,9),(6,10))\n"++
         "3:((6,11),(8,25))\n"++
         "4:((6,11),(6,14))\n"++
         "4:((6,15),(7,20))(Above None (6,15) (7,20) FromAlignCol (1,-9))\n"++
         "5:((6,15),(6,20))\n"++
         "6:((6,15),(6,16))\n"++
         "6:((6,17),(6,20))\n"++
         "7:((6,17),(6,18))\n"++
         "7:((6,19),(6,20))\n"++
         "5:((7,15),(7,20))\n"++
         "6:((7,15),(7,16))\n"++
         "6:((7,17),(7,20))\n"++
         "7:((7,17),(7,18))\n"++
         "7:((7,19),(7,20))\n"++
         "4:((8,14),(8,25))\n"++
         "5:((8,14),(8,21))\n"++
         "6:((8,14),(8,17))\n"++
         "6:((8,18),(8,19))\n"++
         "6:((8,20),(8,21))\n"++
         "5:((8,22),(8,23))\n"++
         "5:((8,24),(8,25))\n"++
         "1:((10,1),(10,1))\n"

      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format Layout.Comments1" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/Layout/Comments1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""
      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(8,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,24))\n"++
          "1:((1,25),(1,30))\n"++
          "1:((3,1),(4,19))\n"++
          "2:((3,1),(3,5))\n"++
          "2:((3,6),(4,19))\n"++
          "3:((3,6),(3,7))\n"++
          "3:((3,8),(3,9))\n"++
          "3:((3,10),(3,15))\n"++
          "4:((3,10),(3,11))\n"++
          "4:((3,12),(3,13))\n"++
          "4:((3,14),(3,15))\n"++
          "3:((4,10),(4,15))\n"++
          "3:((4,16),(4,19))(Above None (4,16) (4,43) FromAlignCol (2,-42))\n"++
          "4:((4,16),(4,19))\n"++
          "5:((4,16),(4,17))\n"++
          "5:((4,17),(4,19))\n"++
          "6:((4,17),(4,18))\n"++
          "6:((4,18),(4,19))\n"++
          "1:((6,1),(6,15))\n"++
          "2:((6,1),(6,11))\n"++
          "2:((6,12),(6,15))\n"++
          "3:((6,12),(6,13))\n"++
          "3:((6,14),(6,15))\n"++
          "1:((8,1),(8,1))\n"

      -- (show layout) `shouldBe` ""

      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format LocToName" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/LocToName.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""
      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(25,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,17))\n"++
         "1:((1,18),(12,3))\n"++
         "1:((20,1),(24,18))\n"++
         "2:((20,1),(20,11))\n"++
         "2:((20,12),(20,41))\n"++
         "3:((20,12),(20,18))\n"++
         "3:((20,19),(20,20))\n"++
         "3:((20,21),(20,41))\n"++
         "4:((20,21),(20,25))\n"++
         "5:((20,21),(20,22))\n"++
         "5:((20,23),(20,24))\n"++
         "5:((20,24),(20,25))\n"++
         "4:((20,26),(20,27))\n"++
         "4:((20,28),(20,41))\n"++
         "5:((20,28),(20,38))\n"++
         "5:((20,39),(20,41))\n"++
         "2:((24,1),(24,18))\n"++
         "3:((24,1),(24,11))\n"++
         "3:((24,12),(24,14))\n"++
         "3:((24,15),(24,16))\n"++
         "3:((24,17),(24,18))\n"++
         "1:((25,1),(25,1))\n"

      -- (show layout) `shouldBe` ""

      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- ---------------------------------------------

    it "retrieves the tokens in SourceTree format DupDef.Dd1" $ do
      (t,toks) <- parsedFileGhc "./test/testdata/DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (show layout) `shouldBe` ""
      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(34,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,18))\n"++
          "1:((1,19),(1,24))\n"++
          "1:((3,1),(3,31))\n"++
          "2:((3,1),(3,9))\n"++
          "2:((3,10),(3,12))\n"++
          "2:((3,13),(3,20))\n"++
          "2:((3,21),(3,23))\n"++
          "2:((3,24),(3,31))\n"++
          "1:((4,1),(4,19))\n"++
          "2:((4,1),(4,9))\n"++
          "2:((4,10),(4,19))\n"++
          "3:((4,10),(4,11))\n"++
          "3:((4,12),(4,13))\n"++
          "3:((4,14),(4,19))\n"++
          "4:((4,14),(4,15))\n"++
          "4:((4,16),(4,17))\n"++
          "4:((4,18),(4,19))\n"++
          "1:((6,1),(6,15))\n"++
          "2:((6,1),(6,2))\n"++
          "2:((6,2),(6,3))\n"++
          "2:((6,3),(6,4))\n"++
          "2:((6,5),(6,7))\n"++
          "2:((6,8),(6,15))\n"++
          "1:((7,1),(7,6))\n"++
          "2:((7,1),(7,2))\n"++
          "2:((7,3),(7,6))\n"++
          "3:((7,3),(7,4))\n"++
          "3:((7,5),(7,6))\n"++
          "1:((8,1),(8,6))\n"++
          "2:((8,1),(8,2))\n"++
          "2:((8,3),(8,6))\n"++
          "3:((8,3),(8,4))\n"++
          "3:((8,5),(8,6))\n"++
          "1:((11,1),(11,18))\n"++
          "2:((11,1),(11,4))\n"++
          "2:((11,5),(11,7))\n"++
          "2:((11,8),(11,9))\n"++
          "2:((11,9),(11,12))\n"++
          "2:((11,12),(11,13))\n"++
          "2:((11,14),(11,17))\n"++
          "2:((11,17),(11,18))\n"++
          "1:((12,1),(12,9))\n"++
          "2:((12,1),(12,2))\n"++
          "2:((12,3),(12,5))\n"++
          "2:((12,6),(12,9))\n"++
          "1:((13,1),(13,9))\n"++
          "2:((13,1),(13,2))\n"++
          "2:((13,3),(13,5))\n"++
          "2:((13,6),(13,9))\n"++
          "1:((14,1),(17,12))\n"++
          "2:((14,1),(14,10))\n"++
          "2:((14,11),(14,12))\n"++
          "2:((14,13),(14,38))\n"++
          "3:((14,13),(14,17))\n"++
          "3:((14,18),(14,19))\n"++
          "3:((14,20),(14,38))\n"++
          "4:((14,20),(14,30))\n"++
          "5:((14,20),(14,23))\n"++
          "5:((14,24),(14,30))\n"++
          "6:((14,24),(14,25))\n"++
          "6:((14,25),(14,26))\n"++
          "6:((14,28),(14,30))\n"++
          "4:((14,32),(14,38))\n"++
          "5:((14,32),(14,33))\n"++
          "5:((14,33),(14,34))\n"++
          "5:((14,36),(14,38))\n"++
          "2:((15,3),(15,8))\n"++
          "2:((16,5),(17,12))(Above FromAlignCol (1,-4) (16,5) (17,12) FromAlignCol (2,-11))\n"++
          "3:((16,5),(16,14))\n"++
          "4:((16,5),(16,7))\n"++
          "4:((16,8),(16,10))\n"++
          "4:((16,11),(16,14))\n"++
          "3:((17,5),(17,12))\n"++
          "4:((17,5),(17,7))\n"++
          "4:((17,8),(17,12))\n"++
          "5:((17,8),(17,9))\n"++
          "5:((17,10),(17,12))\n"++
          "1:((19,1),(19,26))\n"++
          "2:((19,1),(19,5))\n"++
          "2:((19,6),(19,7))\n"++
          "2:((19,8),(19,26))\n"++
          "3:((19,8),(19,9))\n"++
          "3:((19,10),(19,11))\n"++
          "3:((19,12),(19,13))\n"++
          "3:((19,14),(19,22))\n"++
          "4:((19,14),(19,15))\n"++
          "4:((19,16),(19,22))\n"++
          "3:((19,23),(19,24))\n"++
          "3:((19,25),(19,26))\n"++
          "1:((21,1),(23,11))\n"++
          "2:((21,1),(21,3))\n"++
          "2:((21,4),(23,11))\n"++
          "3:((21,4),(21,5))\n"++
          "3:((21,6),(21,7))\n"++
          "3:((21,8),(21,14))\n"++
          "4:((21,8),(21,9))\n"++
          "4:((21,10),(21,11))\n"++
          "4:((21,12),(21,14))\n"++
          "3:((22,3),(22,8))\n"++
          "3:((23,5),(23,11))(Above FromAlignCol (1,-4) (23,5) (23,11) FromAlignCol (2,-10))\n"++
          "4:((23,5),(23,11))\n"++
          "5:((23,5),(23,7))\n"++
          "5:((23,8),(23,11))\n"++
          "6:((23,8),(23,9))\n"++
          "6:((23,10),(23,11))\n"++
          "1:((25,1),(28,12))\n"++
          "2:((25,1),(25,2))\n"++
          "2:((25,3),(28,12))\n"++
          "3:((25,3),(25,4))\n"++
          "3:((25,5),(25,6))\n"++
          "3:((26,3),(28,12))\n"++
          "4:((26,3),(26,6))\n"++
          "4:((27,5),(27,12))(Above FromAlignCol (1,-2) (27,5) (27,12) FromAlignCol (1,-9))\n"++
          "5:((27,5),(27,12))\n"++
          "6:((27,5),(27,7))\n"++
          "6:((27,8),(27,12))\n"++
          "7:((27,8),(27,9))\n"++
          "7:((27,10),(27,12))\n"++
          "4:((28,6),(28,12))\n"++
          "5:((28,6),(28,8))\n"++
          "5:((28,9),(28,10))\n"++
          "5:((28,11),(28,12))\n"++
          "1:((30,1),(32,18))\n"++
          "2:((30,1),(30,3))\n"++
          "2:((30,4),(32,18))\n"++
          "3:((30,4),(30,5))\n"++
          "3:((30,6),(30,7))\n"++
          "3:((30,8),(32,18))\n"++
          "4:((30,8),(30,10))\n"++
          "4:((31,3),(32,18))(Above FromAlignCol (1,-8) (31,3) (32,18) FromAlignCol (2,-17))\n"++
          "5:((31,3),(31,13))\n"++
          "6:((31,3),(31,6))\n"++
          "6:((31,7),(31,13))(Above None (31,7) (31,13) FromAlignCol (1,-10))\n"++
          "7:((31,7),(31,13))\n"++
          "8:((31,7),(31,9))\n"++
          "8:((31,10),(31,13))\n"++
          "9:((31,10),(31,11))\n"++
          "9:((31,12),(31,13))\n"++
          "5:((32,3),(32,18))\n"++
          "6:((32,3),(32,9))\n"++
          "6:((32,10),(32,18))\n"++
          "7:((32,10),(32,11))\n"++
          "7:((32,11),(32,17))\n"++
          "8:((32,11),(32,13))\n"++
          "8:((32,14),(32,15))\n"++
          "8:((32,16),(32,17))\n"++
          "7:((32,17),(32,18))\n"++
          "1:((34,1),(34,1))\n"

      -- (show layout) `shouldBe` ""

      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe` ""

{-
      srcTree `shouldBe`
          []
-}

      (renderSourceTree srcTree) `shouldBe` origSource

    -- --------------------------------------

    it "retrieves the tokens in SourceTree format Renaming.LayoutIn4" $ do
      (t, toks) <- parsedFileGhc "./test/testdata/Renaming/LayoutIn4.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []


      -- (show layout) `shouldBe` ""
      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(14,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,17))\n"++
         "1:((1,18),(1,23))\n"++
         "1:((7,1),(12,53))\n"++
         "2:((7,1),(7,5))\n"++
         "2:((7,6),(12,53))\n"++
         "3:((7,6),(7,7))\n"++
         "3:((7,8),(7,21))\n"++
         "4:((7,8),(7,13))\n"++
         "4:((7,14),(7,21))\n"++
         "3:((7,22),(7,27))\n"++
         "3:((7,28),(12,53))(Above None (7,28) (12,53) FromAlignCol (2,-52))\n"++
         "4:((7,28),(12,53))\n"++
         "5:((7,28),(7,33))\n"++
         "5:((7,34),(12,53))\n"++
         "6:((7,34),(7,35))\n"++
         "6:((7,35),(7,36))\n"++
         "6:((7,37),(12,53))\n"++
         "7:((7,37),(7,39))\n"++
         "7:((7,41),(12,53))(Above SameLine 1 (7,41) (12,53) FromAlignCol (2,-52))\n"++
         "8:((7,41),(7,59))\n"++
         "9:((7,41),(7,44))\n"++
         "9:((7,46),(7,59))(Above SameLine 1 (7,46) (7,59) FromAlignCol (1,-57))\n"++
         "10:((7,46),(7,59))\n"++
         "11:((7,46),(7,47))\n"++
         "11:((7,48),(7,59))\n"++
         "12:((7,48),(7,49))\n"++
         "12:((7,50),(7,59))\n"++
         "13:((7,50),(7,57))\n"++
         "13:((7,58),(7,59))\n"++
         "8:((8,2),(9,53))\n"++
         "9:((8,2),(9,42))\n"++
         "9:((9,46),(9,53))\n"++
         "8:((10,41),(10,58))\n"++
         "9:((10,41),(10,44))\n"++
         "9:((10,46),(10,58))(Above SameLine 1 (10,46) (10,58) FromAlignCol (1,-17))\n"++
         "10:((10,46),(10,58))\n"++
         "11:((10,46),(10,47))\n"++
         "11:((10,48),(10,58))\n"++
         "12:((10,48),(10,49))\n"++
         "12:((10,50),(10,58))\n"++
         "13:((10,50),(10,51))\n"++
         "13:((10,51),(10,57))\n"++
         "14:((10,51),(10,52))\n"++
         "14:((10,53),(10,55))\n"++
         "14:((10,56),(10,57))\n"++
         "13:((10,57),(10,58))\n"++
         "8:((11,41),(11,49))\n"++
         "9:((11,41),(11,47))\n"++
         "9:((11,48),(11,49))\n"++
         "8:((12,41),(12,53))\n"++
         "9:((12,41),(12,47))\n"++
         "9:((12,48),(12,53))\n"++
         "1:((14,1),(14,1))\n"

      -- (show layout) `shouldBe` ""

      let srcTree = layoutTreeToSourceTree layout

      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- --------------------------------------

    it "retrieves the tokens in SourceTree format Layout.Lift with deletion/insertion 1" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Layout/Lift.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(8,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,19))\n"++
          "1:((1,20),(1,25))\n"++
          "1:((3,1),(5,11))\n"++
          "2:((3,1),(3,3))\n"++
          "2:((3,4),(5,11))\n"++
          "3:((3,4),(3,5))\n"++
          "3:((3,6),(3,7))\n"++
          "3:((3,8),(3,14))\n"++
          "4:((3,8),(3,9))\n"++
          "4:((3,10),(3,11))\n"++
          "4:((3,12),(3,14))\n"++
          "3:((4,3),(4,8))\n"++
          "3:((5,5),(5,11))(Above FromAlignCol (1,-4) (5,5) (5,11) FromAlignCol (2,-10))\n"++
          "4:((5,5),(5,11))\n"++
          "5:((5,5),(5,7))\n"++
          "5:((5,8),(5,11))\n"++
          "6:((5,8),(5,9))\n"++
          "6:((5,10),(5,11))\n"++
          "1:((7,1),(7,6))\n"++
          "2:((7,1),(7,2))\n"++
          "2:((7,3),(7,6))\n"++
          "3:((7,3),(7,4))\n"++
          "3:((7,5),(7,6))\n"++
          "1:((8,1),(8,1))\n"

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

{-
getToksForSpan test/testdata/MoveDef/Md1.hs:24:5-10:("(((False,0,0,24),5),((False,0,0,24),11))",[((((24,5),(24,5)),ITvocurly),""),((((24,5),(24,7)),ITvarid "zz"),"zz"),((((24,8),(24,9)),ITequal),"="),((((24,10),(24,11)),ITinteger 1),"1")])

removeToksForPos ((24,5),(24,11))


rmLocalDecl: where/let tokens are at((23,3),(23,8))
removeToksForPos ((23,3),(23,8))

putDeclToksAfterSpan test/testdata/MoveDef/Md1.hs:(22,1)-(24,10):("(((False,0,0,22),1),((False,0,0,24),11))",PlaceOffset 2 0 2,[((((1,6),(1,8)),ITvarid "zz"),"zz"),((((1,9),(1,10)),ITequal),"="),((((1,11),(1,12)),ITinteger 1),"1")])


-}

      let sspan1 = posToSrcSpan layout ((5,5),(5,11))
      (showGhc sspan1) `shouldBe` "test/testdata/Layout/Lift.hs:5:5-10"

      let (layout2,_old) = removeSrcSpan layout (srcSpanToForestSpan sspan1)
      -- (drawTreeCompact layout2) `shouldBe`
      --    ""

      let sspan2 = posToSrcSpan layout ((4,3),(4,8))
      (showGhc sspan2) `shouldBe` "test/testdata/Layout/Lift.hs:4:3-7"

      let (layout3,_old) = removeSrcSpan layout2 (srcSpanToForestSpan sspan2)
      -- (drawTreeCompact layout2) `shouldBe`
      --    ""

      let sspan3 = posToSrcSpan layout ((3,1),(5,11))
      (showGhc sspan3) `shouldBe` "test/testdata/Layout/Lift.hs:(3,1)-(5,10)"
      newToks <- basicTokenise "zz = 1"
      -- let (layout4,_newSpan) = addToksAfterSrcSpan layout3 sspan3 (PlaceOffset 2 0 2) newToks
      let (layout4,_newSpan) = addToksAfterSrcSpan layout3 sspan3 (PlaceOffset 2 0 2) newToks

      (drawTreeCompact layout4) `shouldBe`
          "0:((1,1),(8,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,19))\n"++
          "1:((1,20),(1,25))\n"++
          "1:((3,1),(5,11))\n"++
           "2:((3,1),(3,3))\n"++
           "2:((3,4),(5,11))\n"++
            "3:((3,4),(3,5))\n"++
            "3:((3,6),(3,7))\n"++
            "3:((3,8),(3,14))\n"++
             "4:((3,8),(3,9))\n"++
             "4:((3,10),(3,11))\n"++
             "4:((3,12),(3,14))\n"++
            "3:((4,3),(4,8))(1,-3)D\n"++
            "3:((5,5),(5,11))(2,-10)D\n"++
          "1:((1000005,1),(1000005,7))\n"++
          "1:((7,1),(7,6))\n"++
           "2:((7,1),(7,2))\n"++
           "2:((7,3),(7,6))\n"++
            "3:((7,3),(7,4))\n"++
            "3:((7,5),(7,6))\n"++
          "1:((8,1),(8,1))\n"

      -- show layout4 `shouldBe` ""

      let srcTree2 = layoutTreeToSourceTree layout4
      -- (showGhc srcTree2) `shouldBe` ""

      (renderSourceTree srcTree2) `shouldBe` "module Layout.Lift where\n\nff y = y + zz\n\nzz = 1\n\nx = 1\n"

    -- ---------------------------------

    it "retrieves the tokens in SourceTree format MoveDef.Demote with deletion/insertion 2" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/MoveDef/Demote.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(11,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,22))\n"++
          "1:((1,23),(1,28))\n"++
          "1:((3,1),(3,31))\n"++
          "2:((3,1),(3,9))\n"++
          "2:((3,10),(3,12))\n"++
          "2:((3,13),(3,20))\n"++
          "2:((3,21),(3,23))\n"++
          "2:((3,24),(3,31))\n"++
          "1:((4,1),(4,19))\n"++
          "2:((4,1),(4,9))\n"++
          "2:((4,10),(4,19))\n"++
          "3:((4,10),(4,11))\n"++
          "3:((4,12),(4,13))\n"++
          "3:((4,14),(4,19))\n"++
          "4:((4,14),(4,15))\n"++
          "4:((4,16),(4,17))\n"++
          "4:((4,18),(4,19))\n"++
          "1:((7,1),(7,6))\n"++
          "2:((7,1),(7,2))\n"++
          "2:((7,3),(7,6))\n"++
          "3:((7,3),(7,4))\n"++
          "3:((7,5),(7,6))\n"++
          "1:((8,1),(8,6))\n"++
           "2:((8,1),(8,2))\n"++
           "2:((8,3),(8,6))\n"++
           "3:((8,3),(8,4))\n"++
            "3:((8,5),(8,6))\n"++
          "1:((11,1),(11,1))\n"

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource


{-
removeToksForPos ((7,1),(7,6))

putToksAfterPos ((4,14),(4,19)) at PlaceOffset 1 4 2:[
   ((((0,1),(0,6)),ITwhere),"where"),
   ((((1,4),(1,21)),ITlineComment "-- c,d :: Integer"),"-- c,d ::
                                  -- Integer"),
   ((((2,4),(2,4)),ITvocurly),""),
   ((((2,4),(2,5)),ITvarid "c"),"c"),
   ((((2,6),(2,7)),ITequal),"="),
   ((((2,8),(2,9)),ITinteger 7),"7"),
   ((((3,1),(3,1)),ITvccurly),"")]
-}


      let sspan1 = posToSrcSpan layout ((7,1),(7,6))
      (showGhc sspan1) `shouldBe` "test/testdata/MoveDef/Demote.hs:7:1-5"

      let (layout2,_old) = removeSrcSpan layout (srcSpanToForestSpan sspan1)
      -- (drawTreeCompact layout2) `shouldBe`
      --    ""

      let sspan2 = posToSrcSpan layout ((4,14),(4,19))
      (showGhc sspan2) `shouldBe` "test/testdata/MoveDef/Demote.hs:4:14-18"

      newToks <- basicTokenise "where\n   -- c,d :: Integer\n   c = 7\n"
      show newToks `shouldBe`
         "[((((0,1),(0,6)),ITwhere),\"where\"),((((1,4),(1,21)),ITlineComment \"-- c,d :: Integer\"),\"-- c,d :: Integer\"),((((2,4),(2,4)),ITvocurly),\"\"),((((2,4),(2,5)),ITvarid \"c\"),\"c\"),((((2,6),(2,7)),ITequal),\"=\"),((((2,8),(2,9)),ITinteger 7),\"7\"),((((3,1),(3,1)),ITvccurly),\"\")]"

      let (layout3,_newSpan) = addToksAfterSrcSpan layout2 sspan2 (PlaceOffset 1 4 2) newToks

      (drawTreeCompact layout3) `shouldBe`
          "0:((1,1),(11,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,22))\n"++
          "1:((1,23),(1,28))\n"++
          "1:((3,1),(3,31))\n"++
          "2:((3,1),(3,9))\n"++
          "2:((3,10),(3,12))\n"++
          "2:((3,13),(3,20))\n"++
          "2:((3,21),(3,23))\n"++
          "2:((3,24),(3,31))\n"++
          "1:((4,1),(4,19))\n"++
           "2:((4,1),(4,9))\n"++
           "2:((4,10),(4,19))\n"++
            "3:((4,10),(4,11))\n"++
            "3:((4,12),(4,13))\n"++
            "3:((4,14),(4,19))\n"++
             "4:((4,14),(4,15))\n"++
             "4:((4,16),(4,17))\n"++
             "4:((4,18),(4,19))\n"++
            "3:((1000005,5),(1000007,13))\n"++
          "1:((7,1),(7,6))(1,-5)D\n"++
          "1:((8,1),(8,6))\n"++
           "2:((8,1),(8,2))\n"++
           "2:((8,3),(8,6))\n"++
            "3:((8,3),(8,4))\n"++
            "3:((8,5),(8,6))\n"++
          "1:((11,1),(11,1))\n"

      let srcTree2 = layoutTreeToSourceTree layout3

      -- (showGhc srcTree2) `shouldBe` ""
{-
      (showGhc $ getU srcTree2) `shouldBe`
          "Just (Up\n"++
          "       (Span (1, 1) (11, 1))\n"++
          "       [(Line 1 1 SOriginal \"module MoveDef.Demote where\"),\n"++
          "        (Line 3 1 SOriginal \"toplevel :: Integer -> Integer\"),\n"++
          "        (Line 4 1 SOriginal \"toplevel x = c * x\"),\n"++
          "        (Line 5 5 SAdded \"where\"), (Line 6 8 SAdded \"-- c,d :: Integer\"),\n"++
          "        (Line 7 8 SAdded \"c = 7\"), (Line 8 5 SAdded \"\"),\n"++
          "        (Line 9 1 SAdded \"\"), (Line 7 1 SOriginal \"d = 9\"),\n"++
          "        (Line 10 1 SOriginal \"\")]\n"++
          "       [(DeletedSpan (Span (7, 1) (7, 6)) 3 (1, -5))])"
-}

      (renderSourceTree srcTree2) `shouldBe` "module MoveDef.Demote where\n\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\n    where\n       -- c,d :: Integer\n       c = 7\n    \n\nd = 9\n\n\n"


    -- ---------------------------------

    it "retrieves the tokens in SourceTree format Layout.FromMd1 with deletion 1" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Layout/FromMd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      -- let renamed = fromJust $ GHC.tm_renamed_source t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
          "0:((1,1),(11,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,22))\n"++
          "1:((1,23),(1,28))\n"++
          "1:((3,1),(3,26))\n"++
           "2:((3,1),(3,5))\n"++
           "2:((3,6),(3,7))\n"++
           "2:((3,8),(3,26))\n"++
            "3:((3,8),(3,9))\n"++
            "3:((3,10),(3,11))\n"++
            "3:((3,12),(3,13))\n"++
            "3:((3,14),(3,22))\n"++
             "4:((3,14),(3,15))\n"++
             "4:((3,16),(3,22))\n"++
            "3:((3,23),(3,24))\n"++
            "3:((3,25),(3,26))\n"++
          "1:((5,1),(5,17))\n"++
           "2:((5,1),(5,3))\n"++
           "2:((5,4),(5,6))\n"++
           "2:((5,7),(5,10))\n"++
           "2:((5,11),(5,13))\n"++
           "2:((5,14),(5,17))\n"++
          "1:((6,1),(8,11))\n"++
           "2:((6,1),(6,3))\n"++
           "2:((6,4),(8,11))\n"++
            "3:((6,4),(6,5))\n"++
            "3:((6,6),(6,7))\n"++
            "3:((6,8),(6,14))\n"++
             "4:((6,8),(6,9))\n"++
             "4:((6,10),(6,11))\n"++
             "4:((6,12),(6,14))\n"++
            "3:((7,3),(7,8))\n"++
            "3:((8,5),(8,11))(Above FromAlignCol (1,-4) (8,5) (8,11) FromAlignCol (2,-10))\n"++
             "4:((8,5),(8,11))\n"++
              "5:((8,5),(8,7))\n"++
              "5:((8,8),(8,11))\n"++
               "6:((8,8),(8,9))\n"++
               "6:((8,10),(8,11))\n"++
          "1:((10,1),(10,6))\n"++
           "2:((10,1),(10,2))\n"++
           "2:((10,3),(10,6))\n"++
            "3:((10,3),(10,4))\n"++
            "3:((10,5),(10,6))\n"++
          "1:((11,1),(11,1))\n"

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

      -- Now check removing a span
      -- removeToksForSpan test/testdata/MoveDef/Md1.hs:21:1-16:(((False,0,0,21),1),((False,0,0,21),17))
      -- Is line 5 in FromMd1

      let sspan = posToSrcSpan layout ((5,1),(5,17))
      (showGhc sspan) `shouldBe` "test/testdata/Layout/FromMd1.hs:5:1-16"

      let (layout2,_old) = removeSrcSpan layout (srcSpanToForestSpan sspan)
      (drawTreeCompact layout2) `shouldBe`
          "0:((1,1),(11,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,22))\n"++
          "1:((1,23),(1,28))\n"++
          "1:((3,1),(3,26))\n"++
           "2:((3,1),(3,5))\n"++
           "2:((3,6),(3,7))\n"++
           "2:((3,8),(3,26))\n"++
            "3:((3,8),(3,9))\n"++
            "3:((3,10),(3,11))\n"++
            "3:((3,12),(3,13))\n"++
            "3:((3,14),(3,22))\n"++
             "4:((3,14),(3,15))\n"++
             "4:((3,16),(3,22))\n"++
            "3:((3,23),(3,24))\n"++
            "3:((3,25),(3,26))\n"++
          "1:((5,1),(5,17))(1,-16)D\n"++
          "1:((6,1),(8,11))\n"++
           "2:((6,1),(6,3))\n"++
           "2:((6,4),(8,11))\n"++
            "3:((6,4),(6,5))\n"++
            "3:((6,6),(6,7))\n"++
            "3:((6,8),(6,14))\n"++
             "4:((6,8),(6,9))\n"++
             "4:((6,10),(6,11))\n"++
             "4:((6,12),(6,14))\n"++
            "3:((7,3),(7,8))\n"++
            "3:((8,5),(8,11))(Above FromAlignCol (1,-4) (8,5) (8,11) FromAlignCol (2,-10))\n"++
             "4:((8,5),(8,11))\n"++
              "5:((8,5),(8,7))\n"++
              "5:((8,8),(8,11))\n"++
               "6:((8,8),(8,9))\n"++
               "6:((8,10),(8,11))\n"++
          "1:((10,1),(10,6))\n"++
           "2:((10,1),(10,2))\n"++
           "2:((10,3),(10,6))\n"++
            "3:((10,3),(10,4))\n"++
            "3:((10,5),(10,6))\n"++
          "1:((11,1),(11,1))\n"

      let srcTree2 = layoutTreeToSourceTree layout2
      -- (showGhc srcTree2) `shouldBe` ""

      (renderSourceTree srcTree2) `shouldBe` "module Layout.FromMd1 where\n\ndata D = A | B String | C\n\nff y = y + zz\n  where\n    zz = 1\n\nx = 3\n"


    -- ---------------------------------

    it "retrieves the tokens in SourceTree format Layout.FromMd1 with deletion 2" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Layout/FromMd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (drawTreeCompact layout) `shouldBe`
      --     ""

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

      -- Now check removing a span
      -- removeToksForPos ((22,1),(24,11))
      -- Is line 6 in FromMd1

      let sspan = posToSrcSpan layout ((6,1),(8,11))
      (showGhc sspan) `shouldBe` "test/testdata/Layout/FromMd1.hs:(6,1)-(8,10)"

      let (layout2,_old) = removeSrcSpan layout (srcSpanToForestSpan sspan)
      -- (drawTreeCompact layout2) `shouldBe`
      --    ""

      let srcTree2 = layoutTreeToSourceTree layout2
      -- (show srcTree2) `shouldBe`
      --     ""

      (renderSourceTree srcTree2) `shouldBe` "module Layout.FromMd1 where\n\ndata D = A | B String | C\n\nff :: Int -> Int\n\nx = 3\n"


    -- ---------------------------------

    it "retrieves the tokens in SourceTree format Layout.FromMd1 with deletion 3" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Layout/FromMd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (drawTreeCompact layout) `shouldBe`
      --     ""

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

      let sspan = posToSrcSpan layout ((5,1),(5,17))
      (showGhc sspan) `shouldBe` "test/testdata/Layout/FromMd1.hs:5:1-16"

      let (layout2,_old) = removeSrcSpan layout (srcSpanToForestSpan sspan)


      -- Now check removing a span
      -- removeToksForPos ((22,1),(24,11))
      -- Is line 6 in FromMd1

      let sspan2 = posToSrcSpan layout ((6,1),(8,11))
      (showGhc sspan2) `shouldBe` "test/testdata/Layout/FromMd1.hs:(6,1)-(8,10)"

      let (layout3,_old) = removeSrcSpan layout2 (srcSpanToForestSpan sspan2)
      (drawTreeCompact layout3) `shouldBe`
          "0:((1,1),(11,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,22))\n"++
          "1:((1,23),(1,28))\n"++
          "1:((3,1),(3,26))\n"++
           "2:((3,1),(3,5))\n"++
           "2:((3,6),(3,7))\n"++
           "2:((3,8),(3,26))\n"++
            "3:((3,8),(3,9))\n"++
            "3:((3,10),(3,11))\n"++
            "3:((3,12),(3,13))\n"++
            "3:((3,14),(3,22))\n"++
             "4:((3,14),(3,15))\n"++
             "4:((3,16),(3,22))\n"++
            "3:((3,23),(3,24))\n"++
            "3:((3,25),(3,26))\n"++
          "1:((5,1),(5,17))(1,-16)D\n"++
          "1:((6,1),(8,11))(2,-10)D\n"++
          "1:((10,1),(10,6))\n"++
           "2:((10,1),(10,2))\n"++
           "2:((10,3),(10,6))\n"++
            "3:((10,3),(10,4))\n"++
            "3:((10,5),(10,6))\n"++
          "1:((11,1),(11,1))\n"

      let srcTree2 = layoutTreeToSourceTree layout3
      -- (showGhc srcTree2) `shouldBe`
      --     ""

      (renderSourceTree srcTree2) `shouldBe` "module Layout.FromMd1 where\n\ndata D = A | B String | C\n\nx = 3\n"


    -- ---------------------------------

    it "retrieves the tokens in SourceTree format Layout.Where2 with deletion 4" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Layout/Where2.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      -- (drawTreeCompact layout) `shouldBe`
      --     ""

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

      -- Now check removing a span

      let sspan = posToSrcSpan layout ((5,5),(5,14))
      (showGhc sspan) `shouldBe` "test/testdata/Layout/Where2.hs:5:5-13"

      let (layout2,_old) = removeSrcSpan layout (srcSpanToForestSpan sspan)
      (drawTreeCompact layout2) `shouldBe`
          "0:((1,1),(9,1))\n"++
          "1:((1,1),(1,7))\n"++
          "1:((1,8),(1,21))\n"++
          "1:((1,22),(1,27))\n"++
          "1:((3,1),(6,12))\n"++
           "2:((3,1),(3,10))\n"++
           "2:((3,11),(3,12))\n"++
           "2:((3,13),(3,38))\n"++
            "3:((3,13),(3,17))\n"++
            "3:((3,18),(3,19))\n"++
            "3:((3,20),(3,38))\n"++
             "4:((3,20),(3,30))\n"++
              "5:((3,20),(3,23))\n"++
              "5:((3,24),(3,30))\n"++
               "6:((3,24),(3,25))\n"++
               "6:((3,25),(3,26))\n"++
               "6:((3,28),(3,30))\n"++
             "4:((3,32),(3,38))\n"++
              "5:((3,32),(3,33))\n"++
              "5:((3,33),(3,34))\n"++
              "5:((3,36),(3,38))\n"++
           "2:((4,3),(4,8))\n"++
           "2:((5,5),(6,12))(Above FromAlignCol (1,-4) (5,5) (6,12) FromAlignCol (2,-11))\n"++
            "3:((5,5),(5,14))(1,-9)D\n"++
            "3:((6,5),(6,12))\n"++
             "4:((6,5),(6,7))\n"++
             "4:((6,8),(6,12))\n"++
              "5:((6,8),(6,9))\n"++
              "5:((6,10),(6,12))\n"++
          "1:((8,1),(8,6))\n"++
           "2:((8,1),(8,2))\n"++
           "2:((8,3),(8,6))\n"++
            "3:((8,3),(8,4))\n"++
            "3:((8,5),(8,6))\n"++
          "1:((9,1),(9,1))\n"

      let srcTree2 = layoutTreeToSourceTree layout2
      -- (showGhc srcTree2) `shouldBe`
      --     ""

      (renderSourceTree srcTree2) `shouldBe` "module Layout.Where2 where\n\ntup@(h,t) = head $ zip [1..10] [3..ff]\n  where\n    ff = 15\n\nx = 3\n"


    -- ---------------------------------

    it "retrieves the tokens in SourceTree format TypeUtils.LayoutLet2" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/TypeUtils/LayoutLet2.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(10,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,18))\n"++
         "1:((1,19),(1,24))\n"++
         "1:((7,1),(8,35))\n"++
         "2:((7,1),(7,4))\n"++
         "2:((7,5),(8,35))\n"++
         "3:((7,5),(7,8))\n"++
         "3:((7,9),(7,10))\n"++
         "3:((7,11),(8,35))\n"++
         "4:((7,11),(7,14))\n"++
         "4:((7,15),(8,20))(Above None (7,15) (8,20) SameLine 1)\n"++
         "5:((7,15),(7,20))\n"++
         "6:((7,15),(7,16))\n"++
         "6:((7,17),(7,20))\n"++
         "7:((7,17),(7,18))\n"++
         "7:((7,19),(7,20))\n"++
         "5:((8,15),(8,20))\n"++
         "6:((8,15),(8,16))\n"++
         "6:((8,17),(8,20))\n"++
         "7:((8,17),(8,18))\n"++
         "7:((8,19),(8,20))\n"++
         "4:((8,24),(8,35))\n"++
         "5:((8,24),(8,31))\n"++
         "6:((8,24),(8,27))\n"++
         "6:((8,28),(8,29))\n"++
         "6:((8,30),(8,31))\n"++
         "5:((8,32),(8,33))\n"++
         "5:((8,34),(8,35))\n"++
         "1:((10,1),(10,1))\n"


      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format Renaming.LayoutIn1" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Renaming/LayoutIn1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(10,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,17))\n"++
         "1:((1,18),(1,23))\n"++
         "1:((7,1),(9,40))\n"++
         "2:((7,1),(7,11))\n"++
         "2:((7,12),(9,40))\n"++
         "3:((7,12),(7,13))\n"++
         "3:((7,14),(7,15))\n"++
         "3:((7,15),(7,16))\n"++
         "3:((7,17),(7,28))\n"++
         "4:((7,17),(7,21))\n"++
         "5:((7,17),(7,19))\n"++
         "5:((7,20),(7,21))\n"++
         "4:((7,22),(7,23))\n"++
         "4:((7,24),(7,28))\n"++
         "5:((7,24),(7,26))\n"++
         "5:((7,27),(7,28))\n"++
         "3:((7,29),(7,34))\n"++
         "3:((7,35),(9,40))(Above None (7,35) (9,40) FromAlignCol (1,-39))\n"++
         "4:((7,35),(7,46))\n"++
         "5:((7,35),(7,37))\n"++
         "5:((7,38),(7,46))\n"++
         "6:((7,38),(7,39))\n"++
         "6:((7,39),(7,40))\n"++
         "6:((7,41),(7,46))\n"++
         "7:((7,41),(7,42))\n"++
         "7:((7,42),(7,43))\n"++
         "7:((7,43),(7,46))\n"++
         "4:((9,35),(9,40))\n"++
         "5:((9,35),(9,38))\n"++
         "5:((9,38),(9,40))\n"++
         "6:((9,38),(9,39))\n"++
         "6:((9,39),(9,40))\n"++
         "1:((10,1),(10,1))\n"

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format after renaming Renaming.LayoutIn1" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Renaming/LayoutIn1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(10,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,17))\n"++
         "1:((1,18),(1,23))\n"++
         "1:((7,1),(9,40))\n"++
         "2:((7,1),(7,11))\n"++
         "2:((7,12),(9,40))\n"++
         "3:((7,12),(7,13))\n"++
         "3:((7,14),(7,15))\n"++
         "3:((7,15),(7,16))\n"++
         "3:((7,17),(7,28))\n"++
         "4:((7,17),(7,21))\n"++
         "5:((7,17),(7,19))\n"++
         "5:((7,20),(7,21))\n"++
         "4:((7,22),(7,23))\n"++
         "4:((7,24),(7,28))\n"++
         "5:((7,24),(7,26))\n"++
         "5:((7,27),(7,28))\n"++
         "3:((7,29),(7,34))\n"++
         "3:((7,35),(9,40))(Above None (7,35) (9,40) FromAlignCol (1,-39))\n"++
         "4:((7,35),(7,46))\n"++
         "5:((7,35),(7,37))\n"++
         "5:((7,38),(7,46))\n"++
         "6:((7,38),(7,39))\n"++
         "6:((7,39),(7,40))\n"++
         "6:((7,41),(7,46))\n"++
         "7:((7,41),(7,42))\n"++
         "7:((7,42),(7,43))\n"++
         "7:((7,43),(7,46))\n"++
         "4:((9,35),(9,40))\n"++
         "5:((9,35),(9,38))\n"++
         "5:((9,38),(9,40))\n"++
         "6:((9,38),(9,39))\n"++
         "6:((9,39),(9,40))\n"++
         "1:((10,1),(10,1))\n"

      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

{-

replaceToken test/testdata/Renaming/LayoutIn1.hs:7:17-18:(((False,0,0,7),17),((False,0,0,7),19))((((7,17),(7,23)),ITvarid "square"),"square")
replaceToken test/testdata/Renaming/LayoutIn1.hs:7:24-25:(((False,0,0,7),24),((False,0,0,7),26))((((7,24),(7,30)),ITvarid "square"),"square")
replaceToken test/testdata/Renaming/LayoutIn1.hs:7:35-36:(((False,0,0,7),35),((False,0,0,7),37))((((7,35),(7,41)),ITvarid "square"),"square")
replaceToken test/testdata/Renaming/LayoutIn1.hs:7:35-36:(((False,0,0,7),35),((False,0,0,7),37))((((7,35),(7,41)),ITvarid "square"),"square")
-}

      let ss1 = posToSrcSpan layout ((7,17),(7,19))
      (showGhc ss1) `shouldBe` "test/testdata/Renaming/LayoutIn1.hs:7:17-18"

      [tok1] <- basicTokenise "\n\n\n\n\n\n\n                square"
      (show tok1) `shouldBe` "((((7,17),(7,23)),ITvarid \"square\"),\"square\")"

      let layout2 = replaceTokenForSrcSpan layout ss1 tok1

      -- -- -- --

      let ss2 = posToSrcSpan layout ((7,24),(7,26))
      (showGhc ss2) `shouldBe` "test/testdata/Renaming/LayoutIn1.hs:7:24-25"

      [tok2] <- basicTokenise "\n\n\n\n\n\n\n                       square"
      (show tok2) `shouldBe` "((((7,24),(7,30)),ITvarid \"square\"),\"square\")"

      let layout3 = replaceTokenForSrcSpan layout2 ss2 tok2

      -- -- -- --

      let ss3 = posToSrcSpan layout ((7,35),(7,37))
      (showGhc ss3) `shouldBe` "test/testdata/Renaming/LayoutIn1.hs:7:35-36"

      [tok3] <- basicTokenise "\n\n\n\n\n\n\n                                  square"
      (show tok3) `shouldBe` "((((7,35),(7,41)),ITvarid \"square\"),\"square\")"

      let layout4 = replaceTokenForSrcSpan layout3 ss3 tok3

      -- -- -- --

      let layout5 = replaceTokenForSrcSpan layout4 ss3 tok3

      -- -- -- --

      (drawTreeCompact layout5) `shouldBe`
         "0:((1,1),(10,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,17))\n"++
         "1:((1,18),(1,23))\n"++
         "1:((7,1),(9,40))\n"++
          "2:((7,1),(7,11))\n"++
          "2:((7,12),(9,40))\n"++
           "3:((7,12),(7,13))\n"++
           "3:((7,14),(7,15))\n"++
           "3:((7,15),(7,16))\n"++
           "3:((7,17),(7,28))\n"++
            "4:((7,17),(7,21))\n"++
             "5:((7,17),(7,19))\n"++
             "5:((7,20),(7,21))\n"++
            "4:((7,22),(7,23))\n"++
            "4:((7,24),(7,28))\n"++
             "5:((7,24),(7,26))\n"++
             "5:((7,27),(7,28))\n"++
           "3:((7,29),(7,34))\n"++
           "3:((7,35),(9,40))(Above None (7,35) (9,40) FromAlignCol (1,-39))\n"++
            "4:((7,35),(7,46))\n"++
             "5:((7,35),(7,37))\n"++
             "5:((7,38),(7,46))\n"++
              "6:((7,38),(7,39))\n"++
              "6:((7,39),(7,40))\n"++
              "6:((7,41),(7,46))\n"++
               "7:((7,41),(7,42))\n"++
               "7:((7,42),(7,43))\n"++
               "7:((7,43),(7,46))\n"++
            "4:((9,35),(9,40))\n"++
             "5:((9,35),(9,38))\n"++
             "5:((9,38),(9,40))\n"++
              "6:((9,38),(9,39))\n"++
              "6:((9,39),(9,40))\n"++
         "1:((10,1),(10,1))\n"



      let srcTree2 = layoutTreeToSourceTree layout5
      -- (showGhc srcTree2) `shouldBe` ""


      (renderSourceTree srcTree2) `shouldBe` "module LayoutIn1 where\n\n--Layout rule applies after 'where','let','do' and 'of'\n\n--In this Example: rename 'sq' to 'square'.\n\nsumSquares x y= square x + square y where square x= x^pow\n          --There is a comment.\n                                          pow=2\n"

    -- -----------------------------------------------------------------

    it "retrieves the tokens in SourceTree format after adding a local decl Layout.Lift" $ do
      (t,toks) <-  parsedFileGhc "./test/testdata/Layout/Lift.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

      let layout = allocTokens parsed toks
      (show $ retrieveTokens layout) `shouldBe` (show toks)
      (invariant layout) `shouldBe` []

      (drawTreeCompact layout) `shouldBe`
         "0:((1,1),(8,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,19))\n"++
         "1:((1,20),(1,25))\n"++
         "1:((3,1),(5,11))\n"++
          "2:((3,1),(3,3))\n"++
          "2:((3,4),(5,11))\n"++
           "3:((3,4),(3,5))\n"++
           "3:((3,6),(3,7))\n"++
           "3:((3,8),(3,14))\n"++
            "4:((3,8),(3,9))\n"++
            "4:((3,10),(3,11))\n"++
            "4:((3,12),(3,14))\n"++
           "3:((4,3),(4,8))\n"++
           "3:((5,5),(5,11))(Above FromAlignCol (1,-4) (5,5) (5,11) FromAlignCol (2,-10))\n"++
            "4:((5,5),(5,11))\n"++
             "5:((5,5),(5,7))\n"++
             "5:((5,8),(5,11))\n"++
              "6:((5,8),(5,9))\n"++
              "6:((5,10),(5,11))\n"++ -- "zz = 1"
         "1:((7,1),(7,6))\n"++
          "2:((7,1),(7,2))\n"++
          "2:((7,3),(7,6))\n"++
           "3:((7,3),(7,4))\n"++
           "3:((7,5),(7,6))\n"++
         "1:((8,1),(8,1))\n"


      let srcTree = layoutTreeToSourceTree layout
      -- (show srcTree) `shouldBe`
      --     ""

      (renderSourceTree srcTree) `shouldBe` origSource

      -- NOTE: sspan is different, using simpler file
      -- putToksAfterPos ((6,5),(6,10)) at PlaceIndent 1 0 2:[((((0,1),(0,3)),ITvarid "nn"),"nn"),((((0,4),(0,5)),ITequal),"="),((((0,6),(0,9)),ITvarid "nn2"),"nn2")]

      let ss1 = posToSrcSpan layout ((5,5),(5,11))
      (showGhc ss1) `shouldBe` "test/testdata/Layout/Lift.hs:5:5-10"

      toks1 <- basicTokenise "nn = nn2"
      (show toks1) `shouldBe` "[((((0,1),(0,3)),ITvarid \"nn\"),\"nn\"),((((0,4),(0,5)),ITequal),\"=\"),((((0,6),(0,9)),ITvarid \"nn2\"),\"nn2\")]"

      let (layout2,_ss2) = addToksAfterSrcSpan layout ss1 (PlaceIndent 1 0 2) toks1

      -- -- -- --

      (drawTreeCompact layout2) `shouldBe`
         "0:((1,1),(8,1))\n"++
         "1:((1,1),(1,7))\n"++
         "1:((1,8),(1,19))\n"++
         "1:((1,20),(1,25))\n"++
         "1:((3,1),(5,11))\n"++
          "2:((3,1),(3,3))\n"++
          "2:((3,4),(5,11))\n"++
           "3:((3,4),(3,5))\n"++
           "3:((3,6),(3,7))\n"++
           "3:((3,8),(3,14))\n"++
            "4:((3,8),(3,9))\n"++
            "4:((3,10),(3,11))\n"++
            "4:((3,12),(3,14))\n"++
           "3:((4,3),(4,8))\n"++
           "3:((5,5),(5,11))(Above FromAlignCol (1,-4) (5,5) (5,11) FromAlignCol (2,-10))\n"++
            "4:((5,5),(5,11))\n"++
             "5:((5,5),(5,7))\n"++
             "5:((5,8),(5,11))\n"++
              "6:((5,8),(5,9))\n"++
              "6:((5,10),(5,11))\n"++
            "4:((1000006,5),(1000006,13))\n"++
         "1:((7,1),(7,6))\n"++
          "2:((7,1),(7,2))\n"++
          "2:((7,3),(7,6))\n"++
           "3:((7,3),(7,4))\n"++
           "3:((7,5),(7,6))\n"++
         "1:((8,1),(8,1))\n"

      -- (show layout2) `shouldBe` ""

      let srcTree2 = layoutTreeToSourceTree layout2
      -- (showGhc srcTree2) `shouldBe` ""

      (renderSourceTree srcTree2) `shouldBe` "module Layout.Lift where\n\nff y = y + zz\n  where\n    zz = 1\n    nn = nn2\n\nx = 1\n"

    -- -----------------------------------------------------------------

  -- -----------------------------------

