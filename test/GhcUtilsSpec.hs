{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE CPP #-}
module GhcUtilsSpec (main, spec) where

import           Test.Hspec

-- import           TestUtils

-- import qualified GHC     as GHC

-- import qualified Data.Generics as SYB
-- import qualified GHC.SYB.Utils as SYB

-- import Language.Haskell.GHC.ExactPrint.Utils

-- import Language.Haskell.Refact.Utils.Binds
-- import Language.Haskell.Refact.Utils.GhcUtils
-- import Language.Haskell.Refact.Utils.GhcVersionSpecific
-- import Language.Haskell.Refact.Utils.Monad
-- import Language.Haskell.Refact.Utils.MonadFunctions
-- import Language.Haskell.Refact.Utils.TypeUtils
-- import Language.Haskell.Refact.Utils.Utils
-- import Language.Haskell.Refact.Utils.Variables

-- import TestUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do
  describe "nothing happening here" $ do
    it "need to delete this" $ do
      "a" `shouldBe` "a"
  {-
  describe "onelayerStaged" $ do
    it "only descends one layer into a structure" $ do
      let s' = (2,[3,4],5) :: (Int,[Int],Int)
      let
          worker' (i::Int) = [i]

      let g = onelayerStaged SYB.Renamer [] ([] `SYB.mkQ` worker') s'
      let g1 = SYB.gmapQ ([] `SYB.mkQ` worker') s'
      let g2 = SYB.gmapQl (++) [] ([] `SYB.mkQ` worker') s'

      (show g) `shouldBe` "[[2],[],[5]]"
      (show g1) `shouldBe` "[[2],[],[5]]"
      (show g2) `shouldBe` "[2,5]"

    -- ---------------------------------

    it "Finds a GHC.Name at top level only" $ do
      let
        comp = do
         parseSourceFileGhc "./DupDef/Dd1.hs"
         renamed <- getRefactRenamed
         parsed <- getRefactParsed
         nm <- getRefactNameMap

         let mn = locToRdrName (4,1) parsed
         let Just (ln'@(GHC.L l _)) = mn
             n = rdrName2NamePure nm ln'
             ln = GHC.L l n

         let mx = locToRdrName (4,10) parsed
         let (Just (lx'@(GHC.L l2 _))) = mx
             x = rdrName2NamePure nm lx'
             lx = GHC.L l2 x

         let declsr = hsBinds renamed
             duplicatedDecls = definingDeclsNames [n] declsr True False

             res = findEntity ln duplicatedDecls
             res2 = findEntity n duplicatedDecls

             resx = findEntity lx duplicatedDecls
             resx2 = findEntity x duplicatedDecls


             worker (nn::GHC.Name) = [showGhc nn]
             g = onelayerStaged SYB.Renamer ["-1"] (["-10"] `SYB.mkQ` worker) duplicatedDecls

#if __GLASGOW_HASKELL__ <= 710
             worker2 ((GHC.L _ (GHC.FunBind (GHC.L _ n') _ _ _ _ _))::GHC.Located (GHC.HsBind GHC.Name))
#else
             worker2 ((GHC.L _ (GHC.FunBind (GHC.L _ n') _ _ _ _))::GHC.Located (GHC.HsBind GHC.Name))
#endif
               | n == n' = ["found"]
             worker2 _ = []
             g2 = onelayerStaged SYB.Renamer ["-1"] (["-10"] `SYB.mkQ` worker2) duplicatedDecls

         return (res,res2,resx,resx2,duplicatedDecls,g,g2,ln,lx)
      ((r,r2,rx,rx2,d,gg,gg2,_l,_x),_s) <- ct $ runRefactGhc comp initialState testOptions
      -- (SYB.showData SYB.Renamer 0 d) `shouldBe` ""

      (showGhcQual d) `shouldBe` "[DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x]"
      (showGhcQual _l) `shouldBe` "DupDef.Dd1.toplevel"
      (showGhc _x) `shouldBe` "x"
      (show gg) `shouldBe` "[[\"-10\"],[\"-10\"]]"
      (show gg2) `shouldBe` "[[\"found\"],[\"-10\"]]"
      r `shouldBe` True
      r2 `shouldBe` True
      rx `shouldBe` False
      rx2 `shouldBe` True
-}

-- ---------------------------------------------------------------------
