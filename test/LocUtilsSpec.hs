module LocUtilsSpec (main, spec) where

import           Test.Hspec

import           TestUtils

import Language.Haskell.GHC.ExactPrint

import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.Utils

-- ---------------------------------------------------------------------

main :: IO ()
main = hspec spec

spec :: Spec
spec = do

  -- -------------------------------------------------------------------

  describe "getSrcSpan" $ do
    it "Finds the top SrcSpan" $ do
      let
        comp = do
         parseSourceFileGhc "./DupDef/Dd1.hs"
         parsed <- getRefactParsed
         decls <- liftT $ hsDecls parsed
         let ss = getSrcSpan decls
         return (decls,ss)
      ((d,ss'),_s) <- ct $ runRefactGhc comp initialState testOptions
      (showGhcQual d) `shouldBe` "[toplevel :: Integer -> Integer, toplevel x = c * x,\n c, d :: Integer, c = 7, d = 9, tup :: (Int, Int), h :: Int,\n t :: Int,\n tup@(h, t)\n   = head $ zip [1 .. 10] [3 .. ff]\n   where\n       ff :: Int\n       ff = 15,\n data D = A | B String | C,\n ff y\n   = y + zz\n   where\n       zz = 1,\n l z = let ll = 34 in ll + z,\n dd q\n   = do { let ss = 5;\n          return (ss + q) }]"
      (showGhcQual ss') `shouldBe` "Just DupDef/Dd1.hs:3:1-30"

    -- -------------------------------

    it "Finds the SrcSpan for a top level decl" $ do
      let
        comp = do
         parseSourceFileGhc "./MoveDef/Demote.hs"
         parsed <- getRefactParsed
         decls <- liftT $ hsDecls parsed
         let decl = head $ drop 2 decls
             ss = getSrcSpan decl
         return (decl,ss)
      ((d,ss'),_s) <- ct $ runRefactGhc comp initialState testOptions
      (showGhcQual d) `shouldBe` "c = 7"
      (showGhcQual ss') `shouldBe` "Just MoveDef/Demote.hs:7:1-5"

-- ---------------------------------------------------------------------

-- EOF
