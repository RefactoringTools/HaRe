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
      (showGhc layout) `shouldBe`
         "[LeafLocated test/testdata/Layout/Bare.hs:3:1-4 "++
            "[((((3,1),(3,5)),ITvarid \"main\"),\"main\")],\n "++
         "Leaf [((((3,6),(3,7)),ITequal),\"=\")],\n "++
         "LeafLocated test/testdata/Layout/Bare.hs:3:8-15 "++
            "[((((3,8),(3,16)),ITvarid \"putStrLn\"),\"putStrLn\")],\n "++
         "LeafLocated test/testdata/Layout/Bare.hs:3:17-23 "++
            "[((((3,17),(3,24)),ITstring \"hello\"),\"\\\"hello\\\"\")]]"

-- ---------------------------------------------------------------------

parsedFileBare :: IO (ParseResult,[PosToken])
parsedFileBare = parsedFileGhc "./test/testdata/Layout/Bare.hs"

-- ---------------------------------------------------------------------
