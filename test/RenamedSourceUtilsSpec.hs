module RenamedSourceUtilsSpec (main, spec) where

import           Test.Hspec

import           TestUtils

import qualified GHC        as GHC
import qualified NameSet    as GHC

import Data.Maybe
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.RenamedSourceUtils
import Language.Haskell.Refact.Utils.TypeSyn

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  -- setLogger
  hspec spec

spec :: Spec
spec = do

  describe "getFreeVariables" $ do
    it "gets the free variables for a given syntax element" $ do
      (t, _toks) <- parsedFileBGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let fvs = getFreeVariables renamed
      (showGhc $ GHC.nameSetToList $ GHC.unionManyNameSets fvs) `shouldBe` "[TypeUtils.B.foo, TypeUtils.B.bob]"



-- ---------------------------------------------------------------------
-- Helper functions

-- bFileName :: GHC.FastString
-- bFileName = GHC.mkFastString "./test/testdata/TypeUtils/B.hs"

parsedFileBGhc :: IO (ParseResult,[PosToken])
parsedFileBGhc = parsedFileGhc "./test/testdata/TypeUtils/B.hs"


-- ---------------------------------------------------------------------

