module CaseSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import qualified GHC      as GHC
import qualified GhcMonad as GHC
import qualified RdrName  as GHC
import qualified SrcLoc   as GHC

import Control.Monad.State
import Language.Haskell.Refact.Case
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.LocUtils

import TestUtils

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  
-- t1 = GhcRefacCase.ifToCase ["./old/refactorer/B.hs","4","7","4","43"]

  describe "ifToCase" $ do
    it "converts an if expression to a case expression" $ do
      ifToCase ["./test/testdata/Case/B.hs","4","7","4","43"]
      diff <- compareFiles "./test/testdata/Case/B.hs.refactored"
                           "./test/testdata/Case/B.hs.expected"
      diff `shouldBe` []

  -- -------------------------------------------------------------------

  describe "second thing" $ do
    it "does something good" $ do
      pending "real soon now"

-- ---------------------------------------------------------------------
-- Helper functions

