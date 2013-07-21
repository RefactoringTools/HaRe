module CaseSpec (main, spec) where

import           Test.Hspec
-- import           Test.QuickCheck

-- import qualified FastString as GHC
-- import qualified GHC        as GHC
-- import qualified GhcMonad   as GHC
-- import qualified Name       as GHC
-- import qualified OccName    as GHC
-- import qualified Outputable as GHC
-- import qualified RdrName    as GHC
-- import qualified SrcLoc     as GHC

-- import qualified Data.Generics.Schemes as SYB
-- import qualified Data.Generics.Aliases as SYB
-- import qualified GHC.SYB.Utils         as SYB

-- import Control.Monad.State
import Language.Haskell.Refact.Case
-- import Language.Haskell.Refact.Utils
-- import Language.Haskell.Refact.Utils.LocUtils
-- import Language.Haskell.Refact.Utils.Monad
-- import Language.Haskell.Refact.Utils.TypeSyn

import TestUtils

main :: IO ()
main = do
  -- setLogger
  hspec spec

spec :: Spec
spec = do
  describe "ifToCase" $ do
    it "converts an if expression to a case expression" $ do
      doIfToCase ["./test/testdata/Case/B.hs","4","7","4","43"]
      -- ifToCase logTestSettings Nothing "./test/testdata/Case/B.hs" (4,7) (4,43)
      diff <- compareFiles "./test/testdata/Case/B.hs.refactored"
                           "./test/testdata/Case/B.hs.expected"
      diff `shouldBe` []

  -- -------------------------------------------------------------------

  describe "second thing" $ do
    it "does something good" $ do
      pending -- "real soon now"


-- ---------------------------------------------------------------------
-- Helper functions


