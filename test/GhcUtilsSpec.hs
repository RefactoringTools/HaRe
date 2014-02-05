{-# LANGUAGE ScopedTypeVariables #-}
module GhcUtilsSpec (main, spec) where

import           Test.Hspec

-- import qualified FastString as GHC
-- import qualified GHC        as GHC
-- import qualified Lexer      as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

-- import Control.Monad.State
-- import Data.Maybe
-- import Data.Tree

-- import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.GhcUtils
-- import Language.Haskell.Refact.Utils.LocUtils
-- import Language.Haskell.Refact.Utils.Monad
-- import Language.Haskell.Refact.Utils.TokenUtils
-- import Language.Haskell.Refact.Utils.Layout
-- import Language.Haskell.Refact.Utils.LayoutTypes
-- import Language.Haskell.Refact.Utils.LayoutUtils
-- import Language.Haskell.Refact.Utils.TokenUtilsTypes
-- import Language.Haskell.Refact.Utils.TypeSyn
-- import Language.Haskell.Refact.Utils.TypeUtils

-- import qualified Data.Tree.Zipper as Z
-- import qualified Data.Map as Map

-- import Data.Traversable

-- import TestUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do

  describe "onelayerStaged" $ do
    it "Only descends one layer into a structure" $ do
      let s = ([2,1,3,4,5],[6,7,8]) :: ([Int],[Int])
      let s' = (2,[3,4],5) :: (Int,[Int],Int)
      let worker (i :: Int)
           | i == 2 = ["f"]
          worker _ = []

          worker' (i::Int) = [i]
          worker'' (i::[Int]) = [head i]

      let g = onelayerStaged SYB.Renamer [] ([] `SYB.mkQ` worker') s'
      let g1 = SYB.gmapQ ([] `SYB.mkQ` worker') s'
      let g2 = SYB.gmapQl (++) [] ([] `SYB.mkQ` worker') s'

      (show g) `shouldBe` "[[2],[],[5]]"
      (show g1) `shouldBe` "[[2],[],[5]]"
      (show g2) `shouldBe` "[2,5]"


-- ---------------------------------------------------------------------
