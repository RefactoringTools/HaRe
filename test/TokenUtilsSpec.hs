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
      (invariant [Node (Entry GHC.noSrcSpan []) []]) `shouldBe` ["FAIL: exactly one of toks or subforest must be empty: Node (Entry UnhelpfulSpan \"<no location info>\" []) []"]

    -- -----------------------
    it "checks that a tree nonempty tokens and empty subForest passes" $ do
      (_t,toks) <- parsedFileTokenTestGhc
      (invariant [Node (Entry GHC.noSrcSpan (take 3 toks)) []]) `shouldBe` []

    -- -----------------------
    it "checks that a tree with nonempty tokens and nonempty subForest fails" $ do
      (_t,toks) <- parsedFileTokenTestGhc

      (invariant [Node (Entry GHC.noSrcSpan (take 1 toks)) [emptyTree]]) `shouldBe` ["FAIL: exactly one of toks or subforest must be empty: Node (Entry UnhelpfulSpan \"<no location info>\" [((((1,1),(1,7)),ITmodule),\"module\")]) [Node {rootLabel = Entry (UnhelpfulSpan \"<no location info>\") [], subForest = []}]","FAIL: exactly one of toks or subforest must be empty: Node (Entry UnhelpfulSpan \"<no location info>\" []) []"]

    -- -----------------------
    it "checks that a tree with empty tokens and nonempty subForest passes" $ do
      (_t,toks) <- parsedFileTokenTestGhc

      (invariant [Node (Entry GHC.noSrcSpan []) [mkTreeFromTokens toks]]) `shouldBe` []

    -- -----------------------
    it "checks the subtrees too" $ do
      (_t,toks) <- parsedFileTokenTestGhc

      (invariant [Node (Entry GHC.noSrcSpan []) [emptyTree]]) `shouldBe` ["FAIL: exactly one of toks or subforest must be empty: Node (Entry UnhelpfulSpan \"<no location info>\" []) []"]

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

