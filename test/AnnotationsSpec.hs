module AnnotationsSpec (main, spec) where

import           Test.Hspec

-- import qualified FastString as GHC
import qualified GHC        as GHC
-- import qualified Lexer      as GHC

import qualified GHC.SYB.Utils as SYB

import Data.Maybe

import Language.Haskell.Refact.Utils.Binds
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

import qualified Data.Map as Map


import TestUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do

  -- ---------------------------------------------

  describe "foo" $ do
    it "bar" $ do
      "a" `shouldBe` "b"
