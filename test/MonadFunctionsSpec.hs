module MonadFunctionsSpec (main, spec) where

import           Test.Hspec

import TestUtils

import qualified GHC        as GHC

import Language.Haskell.GHC.ExactPrint.Utils
import Language.Haskell.GHC.ExactPrint.Types

import Language.Haskell.Refact.Utils.Binds
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

-- import Language.Haskell.TokenUtils.DualTree


main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do
  describe "need tests" $ do
    it "for these functions" $ do
      "a" `shouldBe` "b"

    -- ---------------------------------

-- ---------------------------------------------------------------------

parsedFileLayoutIn2 :: IO (ParseResult, [PosToken],Targets)
parsedFileLayoutIn2 = parsedFileGhc "./test/testdata/Renaming/LayoutIn2.hs"

