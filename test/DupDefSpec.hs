module DupDefSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import qualified GHC      as GHC
import qualified GhcMonad as GHC
import qualified RdrName  as GHC
import qualified SrcLoc   as GHC

import Control.Monad.State
import Language.Haskell.Refact.DupDef
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.LocUtils

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  
  describe "duplicateDef" $ do
    it "duplicates a definition at the same level" $ do
     duplicateDef ["./test/testdata/DupDef/Dd1.hs","tl2","3","1"]

  -- -------------------------------------------------------------------

  describe "second thing" $ do
    it "does something good" $ do
      pending "real soon now"

-- ---------------------------------------------------------------------
-- Helper functions

