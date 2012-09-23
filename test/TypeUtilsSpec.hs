module TypeUtilsSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import           TestUtils

import qualified FastString as GHC
import qualified GHC        as GHC
import qualified GhcMonad   as GHC
import qualified Outputable as GHC
import qualified RdrName    as GHC
import qualified SrcLoc     as GHC

import Control.Monad.State
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

main :: IO ()
main = hspec spec

spec :: Spec
spec = do

  describe "pNTtoPN" $ do
    it "Converts an unqualified PNT to a PN" $ do
      -- modInfo@((_, _, mod), toks) <- parsedFileBGhc
      pending "Complete this test"

    it "Converts an qualified PNT to a PN" $ do
      -- modInfo@((_, _, mod), toks) <- parsedFileBGhc
      pending "Complete this test"

  -- -------------------------------------------------------------------

  describe "locToPnt" $ do
    it "returns a pnt for a given source location, if it falls anywhere in an identifier" $ do
      modInfo@((_, _, mod), toks) <- parsedFileBGhc
      let (PNT res@(GHC.L l n)) = locToPNT bFileName (7,3) mod
      GHC.showPpr l `shouldBe` "test/testdata/B.hs:7:1-3"
      getLocatedStart res `shouldBe` (7,1)
      GHC.showRdrName n `shouldBe` "foo"

    it "returns a pnt for a given source location, if it falls anywhere in an identifier #2" $ do
      modInfo@((_, _, mod), toks) <- parsedFileBGhc
      let (PNT res@(GHC.L l n)) = locToPNT bFileName (23,8) mod
      GHC.showRdrName n `shouldBe` "bob"
      GHC.showPpr l `shouldBe` "test/testdata/B.hs:23:7-9"
      getLocatedStart res `shouldBe` (23,7)

    it "returns the default pnt for a given source location, if it does not fall in an identifier" $ do
      modInfo@((_, _, mod), toks) <- parsedFileBGhc
      let (PNT res@(GHC.L _ n)) = locToPNT bFileName (7,7) mod
      getLocatedStart res `shouldBe` (-1,-1)
      GHC.showRdrName n `shouldBe` "nothing"

    it "lists all PNTs" $ do
      modInfo@((_, _, mod), toks) <- parsedFileBGhc
      let res = allPNT bFileName (7,6) mod
      show res `shouldBe` "[(PNT test/testdata/B.hs:7:1-3 foo),(PNT test/testdata/B.hs:7:5 x),(PNT test/testdata/B.hs:7:13-15 odd),(PNT test/testdata/B.hs:7:17 x),(PNT test/testdata/B.hs:9:1-3 bob),(PNT test/testdata/B.hs:9:5 x),(PNT test/testdata/B.hs:9:7 y),(PNT test/testdata/B.hs:9:11 x),(PNT test/testdata/B.hs:9:13 +),(PNT test/testdata/B.hs:9:15-17 foo),(PNT test/testdata/B.hs:9:19 y),(PNT test/testdata/B.hs:11:9-11 foo),(PNT test/testdata/B.hs:11:13 x),(PNT test/testdata/B.hs:11:17 x),(PNT test/testdata/B.hs:11:19 +),(PNT test/testdata/B.hs:14:1-4 foo'),(PNT test/testdata/B.hs:14:6 x),(PNT test/testdata/B.hs:14:16-18 odd),(PNT test/testdata/B.hs:14:20 x),(PNT test/testdata/B.hs:15:3-6 True),(PNT test/testdata/B.hs:16:3-7 False),(PNT test/testdata/B.hs:18:1-4 main),(PNT test/testdata/B.hs:19:3-10 putStrLn),(PNT test/testdata/B.hs:19:12 $),(PNT test/testdata/B.hs:19:14-17 show),(PNT test/testdata/B.hs:19:19 $),(PNT test/testdata/B.hs:19:22-24 foo),(PNT test/testdata/B.hs:19:29 +),(PNT test/testdata/B.hs:19:31-35 C.baz),(PNT test/testdata/B.hs:21:1-4 mary),(PNT test/testdata/B.hs:23:1 h),(PNT test/testdata/B.hs:23:3 z),(PNT test/testdata/B.hs:23:7-9 bob),(PNT test/testdata/B.hs:23:11 z)]"

  -- -------------------------------------------------------------------

  describe "definingDecls" $ do
    it "returns [] if not found" $ do
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let res = definingDecls [(PN (mkRdrName "notdefine"))] ds True False
      GHC.showPpr res `shouldBe` "[]"

    it "finds declarations at the top level" $ do
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let res = definingDecls [(PN (mkRdrName "toplevel"))] ds False False
      GHC.showPpr res `shouldBe` "[toplevel x = c * x]"

    it "includes the typedef if requested" $ do
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let res = definingDecls [(PN (mkRdrName "toplevel"))] ds True False
      GHC.showPpr res `shouldBe` "[toplevel :: Integer -> Integer, toplevel x = c * x]"

    it "strips other names from typedef" $ do
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let res = definingDecls [(PN (mkRdrName "c"))] ds True False
      GHC.showPpr res `shouldBe` "[c :: Integer, c = 7]"

    it "finds in a patbind" $ do
      pending "need to test and implement"

    it "finds in a data decl" $ do
      pending "need to test and implement"



-- ---------------------------------------------------------------------
-- Helper functions

bFileName :: GHC.FastString
bFileName = GHC.mkFastString "./test/testdata/B.hs"

parsedFileBGhc :: IO (ParseResult,[PosToken])
parsedFileBGhc = parsedFileGhc "./test/testdata/B.hs"

dd1FileName :: GHC.FastString
dd1FileName = GHC.mkFastString "./test/testdata/DupDef/Dd1.hs"

parsedFileDd1Ghc :: IO (ParseResult,[PosToken])
parsedFileDd1Ghc = parsedFileGhc "./test/testdata/DupDef/Dd1.hs"

