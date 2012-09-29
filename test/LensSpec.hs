module LensSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import           TestUtils

import qualified FastString as GHC
import qualified GHC        as GHC
import qualified GhcMonad   as GHC
import qualified OccName    as GHC
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

  describe "allPNT" $ do
    it "lists all PNTs" $ do
      modInfo@((_, _, mod), toks) <- parsedFileBGhc
      let res = allPNT bFileName (7,6) mod
      show res `shouldBe` "[(PNT test/testdata/B.hs:7:1-3 foo),(PNT test/testdata/B.hs:7:5 x),(PNT test/testdata/B.hs:7:13-15 odd),(PNT test/testdata/B.hs:7:17 x),(PNT test/testdata/B.hs:9:1-3 bob),(PNT test/testdata/B.hs:9:5 x),(PNT test/testdata/B.hs:9:7 y),(PNT test/testdata/B.hs:9:11 x),(PNT test/testdata/B.hs:9:13 +),(PNT test/testdata/B.hs:9:15-17 foo),(PNT test/testdata/B.hs:9:19 y),(PNT test/testdata/B.hs:11:9-11 foo),(PNT test/testdata/B.hs:11:13 x),(PNT test/testdata/B.hs:11:17 x),(PNT test/testdata/B.hs:11:19 +),(PNT test/testdata/B.hs:14:1-4 foo'),(PNT test/testdata/B.hs:14:6 x),(PNT test/testdata/B.hs:14:16-18 odd),(PNT test/testdata/B.hs:14:20 x),(PNT test/testdata/B.hs:15:3-6 True),(PNT test/testdata/B.hs:16:3-7 False),(PNT test/testdata/B.hs:18:1-4 main),(PNT test/testdata/B.hs:19:3-10 putStrLn),(PNT test/testdata/B.hs:19:12 $),(PNT test/testdata/B.hs:19:14-17 show),(PNT test/testdata/B.hs:19:19 $),(PNT test/testdata/B.hs:19:22-24 foo),(PNT test/testdata/B.hs:19:29 +),(PNT test/testdata/B.hs:19:31-35 C.baz),(PNT test/testdata/B.hs:21:1-4 mary),(PNT test/testdata/B.hs:23:1 h),(PNT test/testdata/B.hs:23:3 z),(PNT test/testdata/B.hs:23:7-9 bob),(PNT test/testdata/B.hs:23:11 z),(PNT test/testdata/B.hs:25:6 D),(PNT test/testdata/B.hs:25:10 A),(PNT test/testdata/B.hs:25:14 B),(PNT test/testdata/B.hs:25:25 C),(PNT test/testdata/B.hs:27:1-7 subdecl),(PNT test/testdata/B.hs:27:9 x),(PNT test/testdata/B.hs:27:13-14 zz),(PNT test/testdata/B.hs:27:16 x),(PNT test/testdata/B.hs:29:5-6 zz),(PNT test/testdata/B.hs:29:8 n),(PNT test/testdata/B.hs:29:12 n),(PNT test/testdata/B.hs:29:14 +)]"

  describe "allPNTLens" $ do
    it "lists all PNTs via a Lens" $ do
      modInfo@((_, _, mod), toks) <- parsedFileBGhc
      let res = allPNTLens bFileName (7,6) mod
      show res `shouldBe` "[(PNT test/testdata/B.hs:7:1-3 foo),(PNT test/testdata/B.hs:7:5 x),(PNT test/testdata/B.hs:7:13-15 odd),(PNT test/testdata/B.hs:7:17 x),(PNT test/testdata/B.hs:9:1-3 bob),(PNT test/testdata/B.hs:9:5 x),(PNT test/testdata/B.hs:9:7 y),(PNT test/testdata/B.hs:9:11 x),(PNT test/testdata/B.hs:9:13 +),(PNT test/testdata/B.hs:9:15-17 foo),(PNT test/testdata/B.hs:9:19 y),(PNT test/testdata/B.hs:11:9-11 foo),(PNT test/testdata/B.hs:11:13 x),(PNT test/testdata/B.hs:11:17 x),(PNT test/testdata/B.hs:11:19 +),(PNT test/testdata/B.hs:14:1-4 foo'),(PNT test/testdata/B.hs:14:6 x),(PNT test/testdata/B.hs:14:16-18 odd),(PNT test/testdata/B.hs:14:20 x),(PNT test/testdata/B.hs:15:3-6 True),(PNT test/testdata/B.hs:16:3-7 False),(PNT test/testdata/B.hs:18:1-4 main),(PNT test/testdata/B.hs:19:3-10 putStrLn),(PNT test/testdata/B.hs:19:12 $),(PNT test/testdata/B.hs:19:14-17 show),(PNT test/testdata/B.hs:19:19 $),(PNT test/testdata/B.hs:19:22-24 foo),(PNT test/testdata/B.hs:19:29 +),(PNT test/testdata/B.hs:19:31-35 C.baz),(PNT test/testdata/B.hs:21:1-4 mary),(PNT test/testdata/B.hs:23:1 h),(PNT test/testdata/B.hs:23:3 z),(PNT test/testdata/B.hs:23:7-9 bob),(PNT test/testdata/B.hs:23:11 z),(PNT test/testdata/B.hs:25:6 D),(PNT test/testdata/B.hs:25:10 A),(PNT test/testdata/B.hs:25:14 B),(PNT test/testdata/B.hs:25:25 C),(PNT test/testdata/B.hs:27:1-7 subdecl),(PNT test/testdata/B.hs:27:9 x),(PNT test/testdata/B.hs:27:13-14 zz),(PNT test/testdata/B.hs:27:16 x),(PNT test/testdata/B.hs:29:5-6 zz),(PNT test/testdata/B.hs:29:8 n),(PNT test/testdata/B.hs:29:12 n),(PNT test/testdata/B.hs:29:14 +)]"


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

