module LocUtilsSpec (main, spec) where

import           Test.Hspec

import           TestUtils

import qualified GHC        as GHC

import Data.Maybe

import Language.Haskell.GHC.ExactPrint.Utils

import Language.Haskell.Refact.Utils.Binds
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  -- setLogger
  hspec spec

spec :: Spec
spec = do

  -- -------------------------------------------------------------------

  describe "getSrcSpan" $ do
    it "Finds the top SrcSpan" $ do
      (t, _toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let declsr = hsBinds renamed
          ss = getSrcSpan declsr
      (showGhc declsr) `shouldBe` "[DupDef.Dd1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) },\n DupDef.Dd1.l z = let ll = 34 in ll GHC.Num.+ z,\n DupDef.Dd1.ff y\n   = y GHC.Num.+ zz\n   where\n       zz = 1,\n DupDef.Dd1.tup@(DupDef.Dd1.h, DupDef.Dd1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15,\n DupDef.Dd1.d = 9, DupDef.Dd1.c = 7,\n DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x]"
      (showGhc ss) `shouldBe` "Just test/testdata/DupDef/Dd1.hs:(30,1)-(32,17)"

    -- -------------------------------
    it "Finds the SrcSpan for a top level decl" $ do
      (t, _toks) <- parsedFileDemoteGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let declsr = hsBinds renamed
          decl = head $ drop 2 declsr
          ss = getSrcSpan decl
      (showGhc decl) `shouldBe` "MoveDef.Demote.toplevel x = MoveDef.Demote.c GHC.Num.* x"
      (showGhc ss) `shouldBe` "Just test/testdata/MoveDef/Demote.hs:4:1-18"

-- ---------------------------------------------------------------------

parsedFileDd1Ghc :: IO (ParseResult,[PosToken])
parsedFileDd1Ghc = parsedFileGhc "./test/testdata/DupDef/Dd1.hs"

-- -----------

parsedFileDemoteGhc :: IO (ParseResult,[PosToken])
parsedFileDemoteGhc = parsedFileGhc "./test/testdata/MoveDef/Demote.hs"



-- EOF
