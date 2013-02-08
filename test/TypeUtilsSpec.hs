module TypeUtilsSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import           TestUtils

import qualified Data.Generics.Schemes as SYB
import qualified Data.Generics.Aliases as SYB
import qualified GHC.SYB.Utils         as SYB

import qualified Bag        as GHC
import qualified FastString as GHC
import qualified GHC        as GHC
import qualified GhcMonad   as GHC
import qualified Name       as GHC
import qualified OccName    as GHC
import qualified Outputable as GHC
import qualified RdrName    as GHC
import qualified SrcLoc     as GHC
import qualified Module     as GHC

import Control.Monad.State
import Data.Maybe
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadUtils
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils
import System.Environment

import qualified Data.Map as Map
import Data.List

main :: IO ()
main = hspec spec

spec :: Spec
spec = do

  describe "pNTtoPN" $ do
    it "Converts a PNT (located ) to a PN (unlocated)" $ do
      let pnt = PNT (GHC.L GHC.noSrcSpan (mkRdrName "aname"))
      (pNTtoPN pnt) == (PN (mkRdrName "aname")) `shouldBe` True

  -- -------------------------------------------------------------------

  describe "locToPnt" $ do
    it "returns a pnt for a given source location, if it falls anywhere in an identifier" $ do
      -- ((_, _, parsed), toks) <- parsedFileBGhc
      (t, toks) <- parsedFileBGhc
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let (PNT res@(GHC.L l n)) = locToPNT bFileName (7,3) parsed
      GHC.showPpr l `shouldBe` "test/testdata/TypeUtils/B.hs:7:1-3"
      getLocatedStart res `shouldBe` (7,1)
      GHC.showRdrName n `shouldBe` "foo"

    it "returns a pnt for a given source location, if it falls anywhere in an identifier #2" $ do
      -- ((_, _, parsed), toks) <- parsedFileBGhc
      (t, toks) <- parsedFileBGhc
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let (PNT res@(GHC.L l n)) = locToPNT bFileName (25,8) parsed
      GHC.showRdrName n `shouldBe` "bob"
      GHC.showPpr l `shouldBe` "test/testdata/TypeUtils/B.hs:25:7-9"
      getLocatedStart res `shouldBe` (25,7)

    it "returns the default pnt for a given source location, if it does not fall in an identifier" $ do
      -- modInfo@((_, _, mod), toks) <- parsedFileBGhc
      modInfo@(t, toks) <- parsedFileBGhc
      let mod = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let (PNT res@(GHC.L _ n)) = locToPNT bFileName (7,7) mod
      getLocatedStart res `shouldBe` (-1,-1)
      GHC.showRdrName n `shouldBe` "nothing"

    it "lists all PNTs" $ do
      -- modInfo@((_, _, mod), toks) <- parsedFileBGhc
      modInfo@(t, toks) <- parsedFileSGhc
      let mod = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let res = allPNT bFileName (7,6) mod
      show res `shouldBe`  "[(PNT test/testdata/TypeUtils/S.hs:4:1-3 foo),(PNT test/testdata/TypeUtils/S.hs:4:5 x),(PNT test/testdata/TypeUtils/S.hs:4:13-15 odd),(PNT test/testdata/TypeUtils/S.hs:4:17 x),(PNT test/testdata/TypeUtils/S.hs:6:6 D),(PNT test/testdata/TypeUtils/S.hs:6:10 A),(PNT test/testdata/TypeUtils/S.hs:6:14 B),(PNT test/testdata/TypeUtils/S.hs:6:25 C),(PNT test/testdata/TypeUtils/S.hs:8:1-7 subdecl),(PNT test/testdata/TypeUtils/S.hs:8:9 x),(PNT test/testdata/TypeUtils/S.hs:8:13-14 zz),(PNT test/testdata/TypeUtils/S.hs:8:16 x),(PNT test/testdata/TypeUtils/S.hs:10:5-6 zz),(PNT test/testdata/TypeUtils/S.hs:10:8 n),(PNT test/testdata/TypeUtils/S.hs:10:12 n),(PNT test/testdata/TypeUtils/S.hs:10:14 +)]"


  -- -------------------------------------------------------------------

  describe "locToName" $ do
    it "returns a GHC.Name for a given source location, if it falls anywhere in an identifier" $ do
      -- ((_,renamed,_), _toks) <- parsedFileBGhc
      (t, _toks) <- parsedFileBGhc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just (res@(GHC.L l n)) = locToName bFileName (7,3) renamed
      GHC.showPpr l `shouldBe` "test/testdata/TypeUtils/B.hs:7:1-3"
      getLocatedStart res `shouldBe` (7,1)
      GHC.showPpr n `shouldBe` "TypeUtils.B.foo"

    it "returns a GHC.Name for a given source location, if it falls anywhere in an identifier #2" $ do
      -- ((_, renamed,_),_toks) <- parsedFileBGhc
      (t, _toks) <- parsedFileBGhc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just (res@(GHC.L l n)) = locToName bFileName (25,8) renamed
      GHC.showPpr n `shouldBe` "TypeUtils.B.bob"
      GHC.showPpr l `shouldBe` "test/testdata/TypeUtils/B.hs:25:7-9"
      getLocatedStart res `shouldBe` (25,7)

    it "returns Nothing for a given source location, if it does not fall in an identifier" $ do
      -- ((_, renamed,_),_toks) <- parsedFileBGhc
      (t, _toks) <- parsedFileBGhc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let res = locToName bFileName (7,7) renamed
      res `shouldBe` Nothing

  -- -------------------------------------------------------------------

  describe "allNames" $ do
    it "lists all Names" $ do
      (t, _toks) <- parsedFileSGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let res = allNames renamed
      -- let res' = map (\(GHC.L l n) -> (GHC.showPpr $ GHC.nameUnique n,GHC.showPpr (l, n))) res
      let res' = map (\(GHC.L l n) -> (GHC.showPpr $ GHC.nameUnique n,GHC.showPpr (l, GHC.getSrcSpan n, n))) res

      -- Map.insertWith :: Ord k => (a -> a -> a) -> k -> a -> Map k a -> Map k a
      let res'' = foldl' (\m (k,a) -> Map.insertWith (++) k a m) Map.empty res'

      (sort $ Map.elems res'') `shouldBe` 
                 ["(test/testdata/TypeUtils/S.hs:10:12,\n test/testdata/TypeUtils/S.hs:10:8,\n n)(test/testdata/TypeUtils/S.hs:10:8,\n test/testdata/TypeUtils/S.hs:10:8,\n n)"
                 ,"(test/testdata/TypeUtils/S.hs:10:14, <no location info>, GHC.Num.+)"
                 ,"(test/testdata/TypeUtils/S.hs:10:5-6,\n test/testdata/TypeUtils/S.hs:10:5-6,\n zz)(test/testdata/TypeUtils/S.hs:8:13-14,\n test/testdata/TypeUtils/S.hs:10:5-6,\n zz)"
                 ,"(test/testdata/TypeUtils/S.hs:4:1-3,\n test/testdata/TypeUtils/S.hs:4:1-3,\n TypeUtils.S.foo)"
                 ,"(test/testdata/TypeUtils/S.hs:4:13-15,\n <no location info>,\n GHC.Real.odd)"
                 ,"(test/testdata/TypeUtils/S.hs:4:17,\n test/testdata/TypeUtils/S.hs:4:5,\n x)(test/testdata/TypeUtils/S.hs:4:5,\n test/testdata/TypeUtils/S.hs:4:5,\n x)"
                 ,"(test/testdata/TypeUtils/S.hs:6:10,\n test/testdata/TypeUtils/S.hs:6:10,\n TypeUtils.S.A)"
                 ,"(test/testdata/TypeUtils/S.hs:6:14,\n test/testdata/TypeUtils/S.hs:6:14,\n TypeUtils.S.B)"
                 ,"(test/testdata/TypeUtils/S.hs:6:25,\n test/testdata/TypeUtils/S.hs:6:25,\n TypeUtils.S.C)"
                 ,"(test/testdata/TypeUtils/S.hs:6:6,\n test/testdata/TypeUtils/S.hs:6:6,\n TypeUtils.S.D)"
                 ,"(test/testdata/TypeUtils/S.hs:8:1-7,\n test/testdata/TypeUtils/S.hs:8:1-7,\n TypeUtils.S.subdecl)"
                 ,"(test/testdata/TypeUtils/S.hs:8:16,\n test/testdata/TypeUtils/S.hs:8:9,\n x)(test/testdata/TypeUtils/S.hs:8:9,\n test/testdata/TypeUtils/S.hs:8:9,\n x)"
                 ]


  -- -------------------------------------------------------------------

  describe "getName" $ do 
    it "gets a qualified Name at the top level" $ do
      -- ((_, renamed,_), _toks) <- parsedFileBGhc
      (t, _toks) <- parsedFileBGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let Just n = getName "TypeUtils.B.foo'" renamed
      (GHC.showPpr n) `shouldBe` "TypeUtils.B.foo'"
      (GHC.showPpr $ GHC.getSrcSpan n) `shouldBe` "test/testdata/TypeUtils/B.hs:14:1-4"

    it "gets any instance of an unqualified Name" $ do
      -- ((_, renamed,_), _toks) <- parsedFileBGhc
      (t, _toks) <- parsedFileBGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let Just n = getName "foo" renamed
      (GHC.showPpr n) `shouldBe` "foo"
      (GHC.showPpr $ GHC.getSrcSpan n) `shouldBe` "test/testdata/TypeUtils/B.hs:9:15-17"

    it "returns Nothing if the Name is not found" $ do
      -- ((_, renamed,_), _toks) <- parsedFileBGhc
      (t, _toks) <- parsedFileBGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let res = getName "baz" renamed
      (GHC.showPpr res) `shouldBe` "Nothing"


  -- -------------------------------------------------------------------

  describe "definingDecls" $ do
    it "returns [] if not found" $ do
      (t, toks) <- parsedFileDd1Ghc
      let mod@(GHC.L l (GHC.HsModule name exps imps ds _ _)) = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let res = definingDecls [(PN (mkRdrName "notdefine"))] ds True False
      GHC.showPpr res `shouldBe` "[]"


    it "finds declarations at the top level" $ do
      (t, toks) <- parsedFileDd1Ghc
      let mod@(GHC.L l (GHC.HsModule name exps imps ds _ _)) = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let res = definingDecls [(PN (mkRdrName "toplevel"))] ds False False
      GHC.showPpr res `shouldBe` "[toplevel x = c * x]"


    it "includes the typedef if requested" $ do
      (t, toks) <- parsedFileDd1Ghc
      let mod@(GHC.L l (GHC.HsModule name exps imps ds _ _)) = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let res = definingDecls [(PN (mkRdrName "toplevel"))] ds True False
      GHC.showPpr res `shouldBe` "[toplevel :: Integer -> Integer, toplevel x = c * x]"


    it "strips other names from typedef" $ do
      (t, toks) <- parsedFileDd1Ghc
      let mod@(GHC.L l (GHC.HsModule name exps imps ds _ _)) = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let res = definingDecls [(PN (mkRdrName "c"))] ds True False
      GHC.showPpr res `shouldBe` "[c :: Integer, c = 7]"


    it "finds in a patbind" $ do
      (t, toks) <- parsedFileDd1Ghc
      let mod@(GHC.L l (GHC.HsModule name exps imps ds _ _)) = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let res = definingDecls [(PN (mkRdrName "tup"))] ds False False
      GHC.showPpr res `shouldBe` "[tup@(h, t)\n   = head $ zip [1 .. 10] [3 .. ff]\n   where\n       ff :: Int\n       ff = 15]"


    it "finds in a patbind, with type signature" $ do
      (t, toks) <- parsedFileDd1Ghc
      let mod@(GHC.L l (GHC.HsModule name exps imps ds _ _)) = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let res = definingDecls [(PN (mkRdrName "tup"))] ds True False
      GHC.showPpr res `shouldBe` "[tup :: (Int, Int),\n tup@(h, t)\n   = head $ zip [1 .. 10] [3 .. ff]\n   where\n       ff :: Int\n       ff = 15]"


    it "finds in a data decl" $ do
      (t, toks) <- parsedFileDd1Ghc
      let mod@(GHC.L l (GHC.HsModule name exps imps ds _ _)) = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let res = definingDecls [(PN (GHC.mkRdrUnqual (GHC.mkDataOcc "A")))] ds True False
      GHC.showPpr res `shouldBe` "[data D = A | B String | C]"


    it "finds recursively in sub-binds" $ do
      {-
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let res = definingDecls [(PN (mkRdrName "zz"))] ds False True
      GHC.showPpr res `shouldBe` "[zz n = n + 1]" -- TODO: Currently fails, will come back to it
      -}
      pending "Currently fails, will come back to it"

    it "only finds recursively in sub-binds if asked" $ do
      -- modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      modInfo@(t, toks) <- parsedFileDd1Ghc
      let mod@(GHC.L l (GHC.HsModule name exps imps ds _ _)) = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let res = definingDecls [(PN (mkRdrName "zz"))] ds False False
      GHC.showPpr res `shouldBe` "[]"

  -- -------------------------------------------------------------------

  describe "definingDeclsNames" $ do
    it "returns [] if not found" $ do
      -- ((_,Just renamed,_), _toks) <- parsedFileDd1Ghc
      (t, _toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just ((GHC.L _ n)) = locToName dd1FileName (16,6) renamed
      let res = definingDeclsNames [n] (hsBinds renamed) False False
      GHC.showPpr res `shouldBe` "[]"

    it "finds declarations at the top level" $ do
      -- ((_,Just renamed,_), _toks) <- parsedFileDd1Ghc
      (t, _toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just (GHC.L _ n) = locToName dd1FileName (3,3) renamed
      let res = definingDeclsNames [n] (hsBinds renamed) False False
      GHC.showPpr res `shouldBe` "[DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x]"

    {-
    it "includes the typedef if requested" $ do
      ((_,renamed,_), _toks) <- parsedFileDd1Ghc
      let Just (GHC.L _ n) = locToName dd1FileName (3,3) renamed
      let res = definingDeclsNames [n] renamed True False
      GHC.showPpr res `shouldBe` "[toplevel :: Integer -> Integer,DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x]"
    -} 

    {-
    it "strips other names from typedef" $ do
      {-
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let res = definingDecls [(PN (mkRdrName "c"))] ds True False
      GHC.showPpr res `shouldBe` "[c :: Integer, c = 7]"
      -}
      pending "Convert to definingDeclsNames"
    -}

    it "finds in a patbind" $ do
      -- ((_,Just renamed,_), _toks) <- parsedFileDd1Ghc
      (t, _toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just (GHC.L _ n) = locToName dd1FileName (14,1) renamed
      let res = definingDeclsNames [n] (hsBinds renamed) False False
      GHC.showPpr res `shouldBe` "[DupDef.Dd1.tup@(DupDef.Dd1.h, DupDef.Dd1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15]"


    {-
    it "finds in a patbind, with type signature" $ do
      {-
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let res = definingDecls [(PN (mkRdrName "tup"))] ds True False
      GHC.showPpr res `shouldBe` "[tup :: (Int, Int), tup@(h, t) = head $ zip [1 .. 10] [3 .. 15]]"
      -}
      pending "Convert to definingDeclsNames"
    -}

    {- ++AZ++ a data decl is not part of the binds
    it "finds in a data decl" $ do
      (t, _toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just (GHC.L _ n) = locToName dd1FileName (16,6) renamed
      let res = definingDeclsNames [n] (hsBinds renamed) False False
      GHC.showPpr res `shouldBe` "[data D]"
      {-
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let res = definingDecls [(PN (GHC.mkRdrUnqual (GHC.mkDataOcc "A")))] ds True False
      GHC.showPpr res `shouldBe` "[data D = A | B String | C]"
      -}
    -}

    it "finds recursively in sub-binds" $ do
      {-
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let res = definingDecls [(PN (mkRdrName "zz"))] ds False True
      GHC.showPpr res `shouldBe` "[zz n = n + 1]" -- TODO: Currently fails, will come back to it
      -}
      pending "Currently fails, will come back to it"

    it "only finds recursively in sub-binds if asked" $ do
      {-
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let res = definingDecls [(PN (mkRdrName "zz"))] ds False False
      GHC.showPpr res `shouldBe` "[]"
      -}
      pending "Convert to definingDeclsNames"

  -- -------------------------------------------------------------------

  describe "definingSigsNames" $ do
    it "returns [] if not found" $ do
      (t, _toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just ((GHC.L _ n)) = locToName dd1FileName (21,1) renamed
      GHC.showPpr n `shouldBe` "DupDef.Dd1.ff"
      let res = definingSigsNames [n] renamed
      GHC.showPpr res `shouldBe` "[]"

    it "finds signatures at the top level" $ do
      (t, _toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just ((GHC.L _ n)) = locToName dd1FileName (4,1) renamed
      GHC.showPpr n `shouldBe` "DupDef.Dd1.toplevel"
      let res = definingSigsNames [n] renamed
      GHC.showPpr res `shouldBe` "[DupDef.Dd1.toplevel ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer]"

    it "returns only the single signature where there are others too" $ do
      (t, _toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just ((GHC.L _ n)) = locToName dd1FileName (7,1) renamed
      GHC.showPpr n `shouldBe` "DupDef.Dd1.c"
      let res = definingSigsNames [n] renamed
      GHC.showPpr res `shouldBe`  "[DupDef.Dd1.c :: GHC.Integer.Type.Integer]"

    it "finds signatures at lower levels" $ do
      (t, _toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just ((GHC.L _ n)) = locToName dd1FileName (16,5) renamed
      GHC.showPpr n `shouldBe` "ff"
      let res = definingSigsNames [n] renamed
      GHC.showPpr res `shouldBe` "[ff :: GHC.Types.Int]"

    it "finds multiple signatures" $ do
      (t, _toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just ((GHC.L _ n1)) = locToName dd1FileName (21,1) renamed
      GHC.showPpr n1 `shouldBe` "DupDef.Dd1.ff"

      let Just ((GHC.L _ n2)) = locToName dd1FileName (16,5) renamed
      GHC.showPpr n2 `shouldBe` "ff"

      let Just ((GHC.L _ n3)) = locToName dd1FileName (4,1) renamed
      GHC.showPpr n3 `shouldBe` "DupDef.Dd1.toplevel"

      let res = definingSigsNames [n1,n2,n3] renamed
      GHC.showPpr res `shouldBe` "[ff :: GHC.Types.Int,\n DupDef.Dd1.toplevel ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer]"


  -- -------------------------------------------------------------------

  describe "isFunBindR" $ do
    it "Returns False if not a function definition" $ do
      -- modInfo@((_,Just renamed, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      modInfo@(t, toks) <- parsedFileDd1Ghc
      let mod@(GHC.L l (GHC.HsModule name exps imps ds _ _)) = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let renamed = fromJust $ GHC.tm_renamed_source t

      -- let [decl] = definingDecls [(PN (mkRdrName "tup"))] ds False False
      let Just tup = getName "DupDef.Dd1.tup" renamed
      let [decl] = definingDeclsNames [tup] (hsBinds renamed) False False
      isFunBindR decl  `shouldBe` False

    it "Returns True if a function definition" $ do
      -- modInfo@((_,Just renamed, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      modInfo@(t, toks) <- parsedFileDd1Ghc
      let mod@(GHC.L l (GHC.HsModule name exps imps ds _ _)) = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just toplevel = getName "DupDef.Dd1.toplevel" renamed
      let [decl] = definingDeclsNames [toplevel] (hsBinds renamed) False False
      isFunBindR decl  `shouldBe` True

  -- -------------------------------------------------------------------

  describe "isFunOrPatName" $ do
    it "Return True if a PName is a function/pattern name defined in t" $ do
      (t, _toks) <- parsedFileDd1Ghc
      let mod@(GHC.L l (GHC.HsModule name exps imps ds _ _)) = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just tup = getName "DupDef.Dd1.tup" renamed
      isFunOrPatName tup renamed  `shouldBe` True

    it "Return False if a PName is a function/pattern name defined in t" $ do
      (t, _toks)   <- parsedFileDd1Ghc
      (t2, toks2) <- parsedFileDd2Ghc
      let mod@(GHC.L l (GHC.HsModule name exps imps ds _ _)) = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let renamed  = fromJust $ GHC.tm_renamed_source t
      let renamed2 = fromJust $ GHC.tm_renamed_source t2

      let Just tup = getName "DupDef.Dd1.tup" renamed
      isFunOrPatName tup renamed2  `shouldBe` False


  -- -------------------------------------------------------------------

{- ++AZ++
  describe "isSimplePatBind" $ do
    it "returns False if not a simple pat bind" $ do
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let [decl] = definingDecls [(PN (mkRdrName "toplevel"))] ds False False
      isSimplePatBind decl  `shouldBe` False

    it "returns True if a simple pat bind" $ do
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let [decl] = definingDecls [(PN (mkRdrName "tup"))] ds False False
      isSimplePatBind decl  `shouldBe` True
-}
  -- ---------------------------------------------------------------------

  describe "hsFreeAndDeclaredPNs" $ do
    it "Finds declared HsVar" $ do
      (t, _toks) <- parsedFileDeclareGhc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let res = hsFreeAndDeclaredPNs renamed

      -- Free Vars
      (GHC.showPpr $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (fst res)) `shouldBe` "[(Data.Generics.Text.gshow, (-1, -1)), (z, (36, 4)),\n (System.IO.getChar, (-1, -1)), (GHC.Base.>>=, (-1, -1)),\n (GHC.Base.fail, (-1, -1)), (System.IO.putStrLn, (-1, -1)),\n (GHC.Base.return, (-1, -1)), (a, (27, 6)), (b, (27, 11)),\n (y, (21, 8)), (GHC.Base.$, (-1, -1)), (GHC.List.head, (-1, -1)),\n (GHC.List.zip, (-1, -1)), (GHC.Num.fromInteger, (-1, -1)),\n (GHC.Num.*, (-1, -1)), (FreeAndDeclared.Declare.c, (9, 1)),\n (x, (6, 10))]"

      -- Declared Vars
      (GHC.showPpr $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (snd res)) `shouldBe` "[(FreeAndDeclared.Declare.ff, (36, 1)), (z, (36, 4)),\n (FreeAndDeclared.Declare.mkT, (34, 1)),\n (FreeAndDeclared.Declare.main, (30, 1)), (a, (31, 3)),\n (FreeAndDeclared.Declare.unF, (27, 1)), (a, (27, 6)),\n (b, (27, 11)), (FreeAndDeclared.Declare.unD, (21, 1)),\n (y, (21, 8)), (FreeAndDeclared.Declare.h, (16, 6)),\n (FreeAndDeclared.Declare.t, (16, 8)),\n (FreeAndDeclared.Declare.d, (10, 1)),\n (FreeAndDeclared.Declare.c, (9, 1)),\n (FreeAndDeclared.Declare.toplevel, (6, 1)), (x, (6, 10))]"

    -- -----------------------------------------------------------------

    it "Finds free and declared in a single bind" $ do
      (t, _toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just tup = getName "DupDef.Dd1.ff" renamed
      let [decl] = definingDeclsNames [tup] (hsBinds renamed) False False

      let res = hsFreeAndDeclaredPNs decl

      -- Free Vars
      (GHC.showPpr $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (fst res)) `shouldBe` 
                   "[(GHC.Num.+, (-1, -1)), " ++
                    "(y, (21, 4)), " ++
                    "(zz, (23, 5)),\n " ++ -- ++AZ++: pretty sure zz is declared
                    "(GHC.Num.fromInteger, (-1, -1))]"

      -- Declared Vars
      (GHC.showPpr $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (snd res)) `shouldBe` 
                   "[(DupDef.Dd1.ff, (21, 1)), " ++
                    "(y, (21, 4)), " ++  -- ++AZ++: pretty sure y is a free var
                    "(zz, (23, 5))]"

    -- -----------------------------------------------------------------

    it "Finds free and declared in a single bind" $ do
      pending "fix the prior test"


  -- ---------------------------------------------------------------------

  describe "hsFDsFromInside" $ do
    it "does something useful" $ do
      pending "Complete this"

  describe "hsFDNamesFromInside" $ do
    it "does something useful" $ do
      pending "Complete this"

  -- ---------------------------------------------------------------------

  describe "hsVisibleNames" $ do
    it "does something useful" $ do
      pending "Complete this"

  -- ---------------------------------------------------------------------

  describe "hsVisiblePNs" $ do
    it "Returns [] if e does not occur in t" $ do
      -- ((_,Just renamed,_parsed),_toks) <- parsedFileDd1Ghc
      (t,_toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just tl1  = locToExp (4,13) (4,40) renamed :: (Maybe (GHC.Located (GHC.HsExpr GHC.Name)))
      let Just tup = getName "DupDef.Dd1.tup" renamed
      let [decl] = definingDeclsNames [tup] (hsBinds renamed) False False
      (GHC.showPpr $ hsVisiblePNs tl1 tup) `shouldBe` "[]"

    -- -----------------------------------------------------------------

    it "Returns visible vars if e does occur in t" $ do
      (t,_toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just tl1  = locToExp (28,4) (28,12) renamed :: (Maybe (GHC.Located (GHC.HsExpr GHC.Name)))
      (GHC.showPpr tl1) `shouldBe` "ll GHC.Num.+ z"

      let Just tup = getName "DupDef.Dd1.l" renamed
      let [decl] = definingDeclsNames [tup] (hsBinds renamed) False False
      (GHC.showPpr decl) `shouldBe` "DupDef.Dd1.l z = let ll = 34 in ll GHC.Num.+ z"

      (GHC.showPpr $ hsVisiblePNs tl1 decl) `shouldBe` "[z, ll]"

    -- -----------------------------------------------------------------

    it "Returns visible vars if e does occur in t #2" $ do
      (t,_toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just tl1  = locToExp (28,4) (28,12) renamed :: (Maybe (GHC.Located (GHC.HsExpr GHC.Name)))
      (GHC.showPpr tl1) `shouldBe` "ll GHC.Num.+ z"

      let Just rhs  = locToExp (26,1) (28,12) renamed :: (Maybe (GHC.Located (GHC.HsExpr GHC.Name)))
      (GHC.showPpr rhs) `shouldBe` "let ll = 34 in ll GHC.Num.+ z"

      (GHC.showPpr $ hsVisiblePNs tl1 rhs) `shouldBe` "[ll]"

  -- ---------------------------------------------

  describe "isLocalPN" $ do
    it "returns True if the name is local to the module" $ do
      (t, _toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let Just (GHC.L _ n) = locToName dd1FileName (17, 5) renamed
      (GHC.showPpr n) `shouldBe` "ff"
      isLocalPN n `shouldBe` True

    it "returns False if the name is not local to the module" $ do
      (t, _toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let Just (GHC.L _ n) = locToName dd1FileName (21, 1) renamed
      (GHC.showPpr n) `shouldBe` "DupDef.Dd1.ff"
      isLocalPN n `shouldBe` False

  -- ---------------------------------------------

  describe "isTopLevelPN" $ do
    it "returns False if the name is not defined at the top level of the module" $ do
      (t, toks) <- parsedFileDd1Ghc
      let 
        comp = do
          renamed <- getRefactRenamed
          let Just (GHC.L _ n) = locToName dd1FileName (17, 5) renamed
          topLevel <- isTopLevelPN n
          return (n,topLevel)
      ((nf,tl),_s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr nf) `shouldBe` "ff"
      tl `shouldBe` False

    it "returns True if the name is defined at the top level of the module" $ do
      (t, toks) <- parsedFileDd1Ghc
      let 
        comp = do
          renamed <- getRefactRenamed
          let Just (GHC.L _ n) = locToName dd1FileName (21, 1) renamed
          topLevel <- isTopLevelPN n
          return (n,topLevel)

      ((nf,tl),_s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr nf) `shouldBe` "DupDef.Dd1.ff"
      tl `shouldBe` True

  -- ---------------------------------------------

  describe "definedPNs" $ do
    it "foo" $ do
      pending "write this test"

  -- ---------------------------------------------

  describe "inScopeInfo" $ do
    it "returns 4 element tuples for in scope names" $ do
      pending "is this still needed?"
      {-
      ((inscopes, _renamed, _parsed), _toks) <- parsedFileDd1Ghc
      let info = inScopeInfo inscopes
      (show $ head info) `shouldBe` "foo"
      -- (show $ info) `shouldBe` "foo"
      -}

  -- ---------------------------------------------

  describe "isInScopeAndUnqualified" $ do
    it "True if the identifier is in scope and unqualified" $ do
      pending "needed?"
      {-
      ((inscopes, _renamed, _parsed), _toks) <- parsedFileDd1Ghc
      let info = inScopeInfo inscopes
      (show $ head info) `shouldBe` "foo"
      -}
-- inScopeInfo for c is
-- (\"DupDef.Dd1.c\",VarName,DupDef.Dd1,Nothing)

  -- ---------------------------------------------

  describe "isInScopeAndUnqualifiedGhc" $ do
    it "True if the identifier is in scope and unqualified" $ do
      -- ((_inscopes, _renamed, _parsed), _toks) <- parsedFileDd1Ghc
      let
        comp = do
         (p,toks) <- parseSourceFileGhc "./test/testdata/DupDef/Dd1.hs"
         res1 <- isInScopeAndUnqualifiedGhc "c"
         res2 <- isInScopeAndUnqualifiedGhc "DupDef.Dd1.c"
         res3 <- isInScopeAndUnqualifiedGhc "nonexistent"
         return (res1,res2,res3)
      ((r1,r2,r3),s) <- runRefactGhcState comp
      r1 `shouldBe` True
      r2 `shouldBe` True
      r3 `shouldBe` False

  -- ---------------------------------------------

  describe "mkNewGhcName" $ do
    it "Creates a new GHC.Name" $ do
      let
        comp = do
         name1 <- mkNewGhcName "foo"
         name2 <- mkNewGhcName "bar"
         return (name1,name2)
      ((n1,n2),s) <- runRefactGhcState comp
      GHC.getOccString n1 `shouldBe` "foo"
      GHC.showPpr n1 `shouldBe` "foo"
      GHC.getOccString n2 `shouldBe` "bar"
      GHC.showPpr n2 `shouldBe` "bar"
      (GHC.showPpr $ GHC.nameUnique n1) `shouldBe` "H2"
      (GHC.showPpr $ GHC.nameUnique n2) `shouldBe` "H3"

  -- ---------------------------------------------

  describe "prettyprint" $ do
    it "Prints a GHC.Name ready for parsing into tokens" $ do
      let
        comp = do
         name1 <- mkNewGhcName "foo"
         name2 <- mkNewGhcName "bar"
         return (name1,name2)
      ((n1,n2),s) <- runRefactGhcState comp
      GHC.getOccString n1 `shouldBe` "foo"
      GHC.showPpr n1 `shouldBe` "foo"
      GHC.getOccString n2 `shouldBe` "bar"
      GHC.showPpr n2 `shouldBe` "bar"
      prettyprint n1 `shouldBe` "foo"

  -- ---------------------------------------------

  describe "duplicateDecl" $ do
    it "Duplicates a RenamedSource bind, and updates the token stream" $ do
      (t, toks) <-parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let declsr = hsBinds renamed
      let Just (GHC.L _ n) = locToName dd1FileName (3, 1) renamed
      let
        comp = do
         _newName <- mkNewGhcName "bar"
         newName2 <- mkNewGhcName "bar2"
         newBinding <- duplicateDecl declsr renamed n newName2

         return newBinding
      (nb,s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "DupDef.Dd1.toplevel"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module DupDef.Dd1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n "
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module DupDef.Dd1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n \n bar2 :: Integer -> Integer\n  bar2 x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n "
      (GHC.showPpr nb) `shouldBe` "[bar2 x = DupDef.Dd1.c GHC.Num.* x]"

  -- ---------------------------------------------

    it "Duplicates a bind with a signature, and an offset" $ do
      (t, toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let declsr = hsBinds renamed
      let Just (GHC.L l n) = locToName dd1FileName (17, 6) renamed
      (GHC.showPpr n) `shouldBe` "ff"
      let
        comp = do
         newName2 <- mkNewGhcName "gg"

         let
           declsToDup = definingDeclsNames [n] declsr True True
           funBinding = filter isFunOrPatBindR declsToDup     --get the fun binding.

         newBinding <- duplicateDecl declsToDup renamed n newName2

         -- return newBinding
         return (funBinding,declsToDup,newBinding)
      ((fb,dd,newb),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "ff"
      (GHC.showPpr dd) `shouldBe` "[ff = 15]"
      (GHC.showPpr fb) `shouldBe` "[ff = 15]"
      (show $ getStartEndLoc fb) `shouldBe` "((17,5),(17,12))"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module DupDef.Dd1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n "
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module DupDef.Dd1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n \n     gg :: Int\n      gg = 15\n\n data D = A | B String | C\n\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n "
      (GHC.showPpr newb) `shouldBe` "[gg = 15]"
      (GHC.showPpr fb) `shouldBe` "[ff = 15]"


  -- ---------------------------------------------

  describe "addParamsToDecl" $ do
    it "Adds parameters to a declaration, and updates the token stream" $ do
      (t, toks) <- parsedFileMd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let declsr = hsBinds renamed
      let Just (GHC.L _ n) = locToName md1FileName (3, 1) renamed
      let
        comp = do
         _newName <- mkNewGhcName "bar"
         newName2 <- mkNewGhcName "bar2"
         newBinding <- addParamsToDecls declsr n [newName2] True

         return newBinding
      (nb,s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "MoveDef.Md1.toplevel"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n  toplevel :: Integer -> Integer\n  toplevel bar2 x = c * x\n\n  c , d :: Integer\n  c = 7\n  d = 9\n\n -- Pattern bind\n  tup :: ( Int , Int )\n  h :: Int\n  t :: Int\n  tup @ ( h , t ) = head $ zip [ 1 .. 10 ] [ 3 .. ff ]\n   where\n      ff :: Int\n      ff = 15\n\n   data D = A | B String | C\n\n  ff :: Int -> Int\n  ff y = y + zz\n   where\n      zz = 1\n\n   l z =\n   let\n      ll = 34\n    in ll + z\n\n  dd q = do\n    let  ss = 5\n     return ( ss + q )\n\n   zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n  tlFunc :: Integer -> Integer\n  tlFunc x = c * x\n -- Comment at end\n\n\n "
      (GHC.showPpr $ last $ init nb) `shouldBe` "MoveDef.Md1.toplevel bar2 x = MoveDef.Md1.c GHC.Num.* x"

  -- ---------------------------------------------

  describe "rmDecl" $ do
    it "Removes a top level declaration, leaving type signature" $ do
      (t, toks) <- parsedFileMd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let declsr = hsBinds renamed
      let Just (GHC.L _ n) = locToName md1FileName (22, 1) renamed
      let
        comp = do
         newDecls <- rmDecl n False declsr

         return newDecls
      (nb,s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "MoveDef.Md1.ff"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n\n\n\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      (GHC.showPpr nb) `shouldBe` "[MoveDef.Md1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) },\n MoveDef.Md1.l z = let ll = 34 in ll GHC.Num.+ z,\n MoveDef.Md1.tup@(MoveDef.Md1.h, MoveDef.Md1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15,\n MoveDef.Md1.d = 9, MoveDef.Md1.c = 7,\n MoveDef.Md1.tlFunc x = MoveDef.Md1.c GHC.Num.* x,\n MoveDef.Md1.toplevel x = MoveDef.Md1.c GHC.Num.* x,\n MoveDef.Md1.zz1 a = 1 GHC.Num.+ MoveDef.Md1.toplevel a]"

    it "Removes a top level declaration, and type signature" $ do
      (t, toks) <- parsedFileMd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let declsr = hsBinds renamed
      let Just (GHC.L _ n) = locToName md1FileName (22, 1) renamed
      let
        comp = do
         newDecls <- rmDecl n True renamed
         return newDecls
      (nb,s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "MoveDef.Md1.ff"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n\n\n\n\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      (GHC.showPpr nb) `shouldBe` "(MoveDef.Md1.toplevel ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.toplevel x = MoveDef.Md1.c GHC.Num.* x\n MoveDef.Md1.c, MoveDef.Md1.d :: GHC.Integer.Type.Integer\n MoveDef.Md1.c = 7\n MoveDef.Md1.d = 9\n MoveDef.Md1.tup :: (GHC.Types.Int, GHC.Types.Int)\n MoveDef.Md1.h :: GHC.Types.Int\n MoveDef.Md1.t :: GHC.Types.Int\n MoveDef.Md1.tup@(MoveDef.Md1.h, MoveDef.Md1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15\n MoveDef.Md1.l z = let ll = 34 in ll GHC.Num.+ z\n MoveDef.Md1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) }\n MoveDef.Md1.zz1 a = 1 GHC.Num.+ MoveDef.Md1.toplevel a\n MoveDef.Md1.tlFunc ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.tlFunc x = MoveDef.Md1.c GHC.Num.* x\n \n data MoveDef.Md1.D\n     = MoveDef.Md1.A | MoveDef.Md1.B GHC.Base.String | MoveDef.Md1.C,\n [import (implicit) Prelude],\n Nothing,\n Nothing)"


  -- ---------------------------------------------

  describe "rmTypeSig" $ do
    it "removes a type signature from the top level" $ do
      (t, toks) <- parsedFileMd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let Just (GHC.L _ n) = locToName md1FileName (22, 1) renamed
      let
        comp = do
         renamed' <- rmTypeSig n renamed
         return renamed'
      (nb,s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "MoveDef.Md1.ff"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      (GHC.showPpr nb) `shouldBe` "(MoveDef.Md1.toplevel ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.toplevel x = MoveDef.Md1.c GHC.Num.* x\n MoveDef.Md1.c, MoveDef.Md1.d :: GHC.Integer.Type.Integer\n MoveDef.Md1.c = 7\n MoveDef.Md1.d = 9\n MoveDef.Md1.tup :: (GHC.Types.Int, GHC.Types.Int)\n MoveDef.Md1.h :: GHC.Types.Int\n MoveDef.Md1.t :: GHC.Types.Int\n MoveDef.Md1.tup@(MoveDef.Md1.h, MoveDef.Md1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15\n MoveDef.Md1.ff y\n   = y GHC.Num.+ zz\n   where\n       zz = 1\n MoveDef.Md1.l z = let ll = 34 in ll GHC.Num.+ z\n MoveDef.Md1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) }\n MoveDef.Md1.zz1 a = 1 GHC.Num.+ MoveDef.Md1.toplevel a\n MoveDef.Md1.tlFunc ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.tlFunc x = MoveDef.Md1.c GHC.Num.* x\n \n data MoveDef.Md1.D\n     = MoveDef.Md1.A | MoveDef.Md1.B GHC.Base.String | MoveDef.Md1.C,\n [import (implicit) Prelude],\n Nothing,\n Nothing)"
      -- (GHC.showPpr renamed) `shouldBe` ""

    -- -----------------------------------------------------------------

    it "removes a type signature from the top level, after decl removed" $ do
      (t, toks) <- parsedFileWhereIn3Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let Just (GHC.L _ n) = locToName whereIn3FileName (14, 1) renamed
      let
        comp = do
         ds <- rmDecl n True (hsBinds renamed)
         renamed' <- rmTypeSig n renamed
         let renamed'' = (replaceBinds renamed' ds)
         return renamed''
      (nb,s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "Demote.WhereIn3.sq"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module Demote.WhereIn3 where\n\n --A definition can be demoted to the local 'where' binding of a friend declaration,\n --if it is only used by this friend declaration.\n\n --Demoting a definition narrows down the scope of the definition.\n --In this example, demote the top level 'sq' to 'sumSquares'\n --In this case (there are multi matches), the parameters are not folded after demoting.\n\n sumSquares x y = sq p x + sq p y\n          where p=2  {-There is a comment-}\n\n sq :: Int -> Int -> Int\n sq pow 0 = 0\n sq pow z = z^pow  --there is a comment\n\n anotherFun 0 y = sq y\n      where  sq x = x^2\n\n "
      -- (showToks $ take 40 $ drop 15 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module Demote.WhereIn3 where\n\n --A definition can be demoted to the local 'where' binding of a friend declaration,\n --if it is only used by this friend declaration.\n\n --Demoting a definition narrows down the scope of the definition.\n --In this example, demote the top level 'sq' to 'sumSquares'\n --In this case (there are multi matches), the parameters are not folded after demoting.\n\n sumSquares x y = sq p x + sq p y\n          where p=2  {-There is a comment-}\n\n\n\n\n\n anotherFun 0 y = sq y\n      where  sq x = x^2\n\n "
      (GHC.showPpr nb) `shouldBe` "(Demote.WhereIn3.sumSquares x y\n   = Demote.WhereIn3.sq p x GHC.Num.+ Demote.WhereIn3.sq p y\n   where\n       p = 2\n Demote.WhereIn3.anotherFun 0 y\n   = sq y\n   where\n       sq x = x GHC.Real.^ 2,\n [import (implicit) Prelude],\n Nothing,\n Nothing)"
      -- (GHC.showPpr renamed) `shouldBe` ""


    -- -----------------------------------------------------------------

    it "removes a type signature from non-top level" $ do
      (t, toks) <- parsedFileMd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let Just (GHC.L _ n) = locToName md1FileName (16, 5) renamed
      let
        comp = do
         renamed' <- rmTypeSig n renamed
         return renamed'
      (nb,s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "ff"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      (GHC.showPpr nb) `shouldBe` "(MoveDef.Md1.toplevel ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.toplevel x = MoveDef.Md1.c GHC.Num.* x\n MoveDef.Md1.c, MoveDef.Md1.d :: GHC.Integer.Type.Integer\n MoveDef.Md1.c = 7\n MoveDef.Md1.d = 9\n MoveDef.Md1.tup :: (GHC.Types.Int, GHC.Types.Int)\n MoveDef.Md1.h :: GHC.Types.Int\n MoveDef.Md1.t :: GHC.Types.Int\n MoveDef.Md1.tup@(MoveDef.Md1.h, MoveDef.Md1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff = 15\n MoveDef.Md1.ff :: GHC.Types.Int -> GHC.Types.Int\n MoveDef.Md1.ff y\n   = y GHC.Num.+ zz\n   where\n       zz = 1\n MoveDef.Md1.l z = let ll = 34 in ll GHC.Num.+ z\n MoveDef.Md1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) }\n MoveDef.Md1.zz1 a = 1 GHC.Num.+ MoveDef.Md1.toplevel a\n MoveDef.Md1.tlFunc ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.tlFunc x = MoveDef.Md1.c GHC.Num.* x\n \n data MoveDef.Md1.D\n     = MoveDef.Md1.A | MoveDef.Md1.B GHC.Base.String | MoveDef.Md1.C,\n [import (implicit) Prelude],\n Nothing,\n Nothing)"
      -- (GHC.showPpr renamed) `shouldBe` ""


  -- ---------------------------------------------
{-
  describe "moveDecl" $ do
    it "moves a declaration from one syntax element to another" $ do
      (t, toks) <- parsedFileD1Ghc
      let
        comp = do
         renamed <- getRefactRenamed
         let Just (GHC.L _ ssq) = locToName d1FileName (6, 1) renamed
         let Just (GHC.L _ sq) = locToName d1FileName (9, 1) renamed
         let declsr = hsBinds renamed
             ssqDecls = definingDeclsNames [ssq] declsr True False
             sqDecls  = definingDeclsNames [sq]  declsr True False

         newDecls <- moveDecl [sq] ssqDecls False sqDecls True

         return (ssq,sq,ssqDecls,sqDecls,newDecls)
      ((s1,s2,d1,d2,nd),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr d1) `shouldBe` "[Demote.D1.sumSquares (x : xs)\n   = Demote.D1.sq x GHC.Num.+ Demote.D1.sumSquares xs\n Demote.D1.sumSquares [] = 0]"
      (GHC.showPpr s2) `shouldBe` "Demote.D1.sq"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module Demote.D1 where\n\n {-demote 'sq' to 'sumSquares'. This refactoring\n  affects module 'D1' and 'C1' -}\n\n sumSquares (x:xs) = sq x + sumSquares xs\n sumSquares [] = 0\n\n sq x = x ^pow\n\n pow = 2\n\n main = sumSquares [1..4]\n\n "
      (showToks $ take 40 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` ""
      (GHC.showPpr nd) `shouldBe` ""
-}
  -- ---------------------------------------------

  describe "addDecl" $ do
    it "Adds a top level declaration without a type signature, in default pos" $ do
      (t, toks) <- parsedFileMd1Ghc
      let
        comp = do
         renamed <- getRefactRenamed
         nn  <- mkNewGhcName "nn"
         nn2 <- mkNewGhcName "nn2"
         let newDecl = GHC.noLoc (GHC.VarBind nn (GHC.noLoc (GHC.HsVar nn2)) False)
         newDecls <- addDecl renamed Nothing (newDecl,Nothing,Nothing) True

         return newDecls
      (nb,s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      -- (GHC.showPpr n) `shouldBe` "MoveDef.Md1.ff"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n nn = nn2\n \n  dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      (GHC.showPpr nb) `shouldBe` "(MoveDef.Md1.toplevel ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.toplevel x = MoveDef.Md1.c GHC.Num.* x\n MoveDef.Md1.c, MoveDef.Md1.d :: GHC.Integer.Type.Integer\n MoveDef.Md1.c = 7\n MoveDef.Md1.d = 9\n MoveDef.Md1.tup :: (GHC.Types.Int, GHC.Types.Int)\n MoveDef.Md1.h :: GHC.Types.Int\n MoveDef.Md1.t :: GHC.Types.Int\n MoveDef.Md1.tup@(MoveDef.Md1.h, MoveDef.Md1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15\n MoveDef.Md1.ff :: GHC.Types.Int -> GHC.Types.Int\n MoveDef.Md1.ff y\n   = y GHC.Num.+ zz\n   where\n       zz = 1\n MoveDef.Md1.l z = let ll = 34 in ll GHC.Num.+ z\n MoveDef.Md1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) }\n MoveDef.Md1.zz1 a = 1 GHC.Num.+ MoveDef.Md1.toplevel a\n MoveDef.Md1.tlFunc ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.tlFunc x = MoveDef.Md1.c GHC.Num.* x\n nn = nn2\n \n data MoveDef.Md1.D\n     = MoveDef.Md1.A | MoveDef.Md1.B GHC.Base.String | MoveDef.Md1.C,\n [import (implicit) Prelude],\n Nothing,\n Nothing)"

    -- -------------------------------------------

    it "Adds a top level declaration with a type signature" $ do
      (t, toks) <- parsedFileMd1Ghc
      let
        comp = do
         renamed <- getRefactRenamed
         nn  <- mkNewGhcName "nn"
         nn2 <- mkNewGhcName "nn2"
         let (GHC.ValBindsOut _ vb) = hsValBinds renamed
         let hSig = head $ drop 3 vb
         let (GHC.L _ (GHC.TypeSig _ (GHC.L _ (GHC.HsTyVar intName)))) = hSig
         let newDecl = GHC.noLoc (GHC.VarBind nn (GHC.noLoc (GHC.HsVar nn2)) False)
         let sig = GHC.noLoc (GHC.TypeSig [(GHC.noLoc nn)] (GHC.noLoc (GHC.HsTyVar intName)))
{-
(L {test/testdata/SwapArgs/B.hs:36:1-10} 
      (TypeSig 
       [
        (L {test/testdata/SwapArgs/B.hs:36:1-3} {Name: SwapArgs.B.baz})] 
       (L {test/testdata/SwapArgs/B.hs:36:8-10} 
        (HsTyVar {Name: GHC.Types.Int}))))
-}
         newDecls <- addDecl renamed Nothing (newDecl,Just sig,Nothing) True
         -- newDecls <- addDecl renamed Nothing (newDecl,Nothing,Nothing) True

         return (hSig,intName,newDecls)
      ((hs,iname,nb),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      -- (GHC.showPpr n) `shouldBe` "MoveDef.Md1.ff"
      (GHC.showPpr iname) `shouldBe` "GHC.Types.Int"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n nn :: Int\n nn = nn2\n \n  dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      (GHC.showPpr nb) `shouldBe` "(MoveDef.Md1.toplevel ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.toplevel x = MoveDef.Md1.c GHC.Num.* x\n MoveDef.Md1.c, MoveDef.Md1.d :: GHC.Integer.Type.Integer\n MoveDef.Md1.c = 7\n MoveDef.Md1.d = 9\n MoveDef.Md1.tup :: (GHC.Types.Int, GHC.Types.Int)\n MoveDef.Md1.h :: GHC.Types.Int\n MoveDef.Md1.t :: GHC.Types.Int\n MoveDef.Md1.tup@(MoveDef.Md1.h, MoveDef.Md1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15\n MoveDef.Md1.ff :: GHC.Types.Int -> GHC.Types.Int\n MoveDef.Md1.ff y\n   = y GHC.Num.+ zz\n   where\n       zz = 1\n MoveDef.Md1.l z = let ll = 34 in ll GHC.Num.+ z\n MoveDef.Md1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) }\n MoveDef.Md1.zz1 a = 1 GHC.Num.+ MoveDef.Md1.toplevel a\n MoveDef.Md1.tlFunc ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.tlFunc x = MoveDef.Md1.c GHC.Num.* x\n nn :: GHC.Types.Int\n nn = nn2\n \n data MoveDef.Md1.D\n     = MoveDef.Md1.A | MoveDef.Md1.B GHC.Base.String | MoveDef.Md1.C,\n [import (implicit) Prelude],\n Nothing,\n Nothing)"

    -- -------------------------------------------

    it "Adds a top level declaration after a specified one" $ do
      (t, toks) <- parsedFileMd1Ghc
      let
        comp = do
         renamed <- getRefactRenamed
         let Just (GHC.L l n) = locToName md1FileName (21, 1) renamed
         nn  <- mkNewGhcName "nn"
         nn2 <- mkNewGhcName "nn2"
         let newDecl = GHC.noLoc (GHC.VarBind nn (GHC.noLoc (GHC.HsVar nn2)) False)
         newDecls <- addDecl renamed (Just n) (newDecl,Nothing,Nothing) True

         return (n,newDecls)
      ((n,nb),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "MoveDef.Md1.ff"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n \n nn = nn2\n \n  l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      (GHC.showPpr nb) `shouldBe` "(MoveDef.Md1.toplevel ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.toplevel x = MoveDef.Md1.c GHC.Num.* x\n MoveDef.Md1.c, MoveDef.Md1.d :: GHC.Integer.Type.Integer\n MoveDef.Md1.c = 7\n MoveDef.Md1.d = 9\n MoveDef.Md1.tup :: (GHC.Types.Int, GHC.Types.Int)\n MoveDef.Md1.h :: GHC.Types.Int\n MoveDef.Md1.t :: GHC.Types.Int\n MoveDef.Md1.tup@(MoveDef.Md1.h, MoveDef.Md1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15\n MoveDef.Md1.ff :: GHC.Types.Int -> GHC.Types.Int\n MoveDef.Md1.ff y\n   = y GHC.Num.+ zz\n   where\n       zz = 1\n MoveDef.Md1.l z = let ll = 34 in ll GHC.Num.+ z\n MoveDef.Md1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) }\n MoveDef.Md1.zz1 a = 1 GHC.Num.+ MoveDef.Md1.toplevel a\n MoveDef.Md1.tlFunc ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.tlFunc x = MoveDef.Md1.c GHC.Num.* x\n nn = nn2\n \n data MoveDef.Md1.D\n     = MoveDef.Md1.A | MoveDef.Md1.B GHC.Base.String | MoveDef.Md1.C,\n [import (implicit) Prelude],\n Nothing,\n Nothing)"


    -- -------------------------------------------

    it "Adds a top level declaration with a type signature after a specified one" $ do
      (t, toks) <- parsedFileMd1Ghc
      let
        comp = do
         renamed <- getRefactRenamed
         let Just (GHC.L l n) = locToName md1FileName (21, 1) renamed
         nn  <- mkNewGhcName "nn"
         nn2 <- mkNewGhcName "nn2"
         let newDecl = GHC.noLoc (GHC.VarBind nn (GHC.noLoc (GHC.HsVar nn2)) False)

         let (GHC.ValBindsOut _ vb) = hsValBinds renamed
         let hSig = head $ drop 3 vb
         let (GHC.L _ (GHC.TypeSig _ (GHC.L _ (GHC.HsTyVar intName)))) = hSig
         let sig = GHC.noLoc (GHC.TypeSig [(GHC.noLoc nn)] (GHC.noLoc (GHC.HsTyVar intName)))

         newDecls <- addDecl renamed (Just n) (newDecl,Just sig,Nothing) True

         return (n,newDecls)
      ((n,nb),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "MoveDef.Md1.ff"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n \n nn :: Int\n nn = nn2\n \n  l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      (GHC.showPpr nb) `shouldBe` "(MoveDef.Md1.toplevel ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.toplevel x = MoveDef.Md1.c GHC.Num.* x\n MoveDef.Md1.c, MoveDef.Md1.d :: GHC.Integer.Type.Integer\n MoveDef.Md1.c = 7\n MoveDef.Md1.d = 9\n MoveDef.Md1.tup :: (GHC.Types.Int, GHC.Types.Int)\n MoveDef.Md1.h :: GHC.Types.Int\n MoveDef.Md1.t :: GHC.Types.Int\n MoveDef.Md1.tup@(MoveDef.Md1.h, MoveDef.Md1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15\n MoveDef.Md1.ff :: GHC.Types.Int -> GHC.Types.Int\n MoveDef.Md1.ff y\n   = y GHC.Num.+ zz\n   where\n       zz = 1\n MoveDef.Md1.l z = let ll = 34 in ll GHC.Num.+ z\n MoveDef.Md1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) }\n MoveDef.Md1.zz1 a = 1 GHC.Num.+ MoveDef.Md1.toplevel a\n MoveDef.Md1.tlFunc ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.tlFunc x = MoveDef.Md1.c GHC.Num.* x\n nn :: GHC.Types.Int\n nn = nn2\n \n data MoveDef.Md1.D\n     = MoveDef.Md1.A | MoveDef.Md1.B GHC.Base.String | MoveDef.Md1.C,\n [import (implicit) Prelude],\n Nothing,\n Nothing)"


    -- -------------------------------------------

    it "Adds a local declaration" $ do
      (t, toks) <- parsedFileMd1Ghc
      let
        comp = do

         renamed <- getRefactRenamed

         let Just (GHC.L _ tl) = locToName md1FileName (4, 1) renamed
         let declsr = hsBinds renamed
             [tlDecls] = definingDeclsNames [tl] declsr True False

         nn  <- mkNewGhcName "nn"
         nn2 <- mkNewGhcName "nn2"
         let newDecl = GHC.noLoc (GHC.VarBind nn (GHC.noLoc (GHC.HsVar nn2)) False)
         newDecls <- addDecl tlDecls Nothing (newDecl,Nothing,Nothing) False

         return (tlDecls,newDecls)
      ((tl,nb),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr tl) `shouldBe` "MoveDef.Md1.toplevel x = MoveDef.Md1.c GHC.Num.* x"
      -- (showToks $ take 30 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n     where\n       nn = nn2\n\n \n \n  c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      (GHC.showPpr nb) `shouldBe` "MoveDef.Md1.toplevel x\n  = MoveDef.Md1.c GHC.Num.* x\n  where\n      nn = nn2"


    -- -------------------------------------------

    it "Adds a local declaration with a type signature" $ do
      (t, toks) <- parsedFileMd1Ghc
      let
        comp = do

         renamed <- getRefactRenamed

         let Just (GHC.L _ tl) = locToName md1FileName (4, 1) renamed
         let declsr = hsBinds renamed
             [tlDecls] = definingDeclsNames [tl] declsr True False

         nn  <- mkNewGhcName "nn"
         nn2 <- mkNewGhcName "nn2"
         let newDecl = GHC.noLoc (GHC.VarBind nn (GHC.noLoc (GHC.HsVar nn2)) False)

         let (GHC.ValBindsOut _ vb) = hsValBinds renamed
         let hSig = head $ drop 3 vb
         let (GHC.L _ (GHC.TypeSig _ (GHC.L _ (GHC.HsTyVar intName)))) = hSig
         let sig = GHC.noLoc (GHC.TypeSig [(GHC.noLoc nn)] (GHC.noLoc (GHC.HsTyVar intName)))

         newDecls <- addDecl tlDecls Nothing (newDecl,Just sig,Nothing) False

         return (tlDecls,newDecls)
      ((tl,nb),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr tl) `shouldBe` "MoveDef.Md1.toplevel x = MoveDef.Md1.c GHC.Num.* x"
      -- (showToks $ take 30 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n     where\n       nn :: Int\n       nn = nn2\n\n \n \n  c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      (GHC.showPpr nb) `shouldBe` "MoveDef.Md1.toplevel x\n  = MoveDef.Md1.c GHC.Num.* x\n  where\n      nn :: GHC.Types.Int\n      nn = nn2"


    -- -------------------------------------------

    it "Adds a local declaration with a where clause" $ do
      (t, toks) <- parsedFileDemoteGhc
      let
        comp = do

         renamed <- getRefactRenamed

         let Just (GHC.L _ tl) = locToName demoteFileName (4, 1) renamed
         let declsr = hsBinds renamed
             [tlDecls] = definingDeclsNames [tl] declsr True False

         nn  <- mkNewGhcName "nn"
         nn2 <- mkNewGhcName "nn2"
         let newDecl = GHC.noLoc (GHC.VarBind nn (GHC.noLoc (GHC.HsVar nn2)) False)
         newDecls <- addDecl tlDecls Nothing (newDecl,Nothing,Nothing) False

         return (tlDecls,newDecls)
      ((tl,nb),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr tl) `shouldBe` "MoveDef.Demote.toplevel x = MoveDef.Demote.c GHC.Num.* x"
      -- (showToks $ take 30 $ toks) `shouldBe` ""
      -- (showToks $ take 30 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Demote where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n -- c,d :: Integer\n c = 7\n d = 9\n\n\n "
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Demote where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n     where\n       nn = nn2\n\n \n \n  -- c,d :: Integer\n c = 7\n d = 9\n\n\n "
      (GHC.showPpr nb) `shouldBe` "MoveDef.Demote.toplevel x\n  = MoveDef.Demote.c GHC.Num.* x\n  where\n      nn = nn2"

    -- -------------------------------------------

    it "Adds a local declaration to an existing one" $ do
      (t, toks) <- parsedFileMd2Ghc
      let
        comp = do

         renamed <- getRefactRenamed

         let Just (GHC.L _ tl) = locToName md2FileName (4, 1) renamed
         let declsr = hsBinds renamed
             [tlDecls] = definingDeclsNames [tl] declsr True False

         nn  <- mkNewGhcName "nn"
         nn2 <- mkNewGhcName "nn2"
         let newDecl = GHC.noLoc (GHC.VarBind nn (GHC.noLoc (GHC.HsVar nn2)) False)
         newDecls <- addDecl tlDecls Nothing (newDecl,Nothing,Nothing) False

         return (tlDecls,newDecls)
      ((tl,nb),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr tl) `shouldBe` "MoveDef.Md2.toplevel x\n  = MoveDef.Md2.c GHC.Num.* x GHC.Num.* b\n  where\n      b = 3"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md2 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x * b\n   where\n     b = 3\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      -- (showToks $ take 30 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md2 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x * b\n   where\n     b = 3\n     nn = nn2\n \n  c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      (GHC.showPpr nb) `shouldBe` "MoveDef.Md2.toplevel x\n  = MoveDef.Md2.c GHC.Num.* x GHC.Num.* b\n  where\n      b = 3\n      nn = nn2"

    -- -------------------------------------------

    it "Adds a local declaration with a type signature to an existing one" $ do
      (t, toks) <- parsedFileMd2Ghc
      let
        comp = do

         renamed <- getRefactRenamed

         let Just (GHC.L _ tl) = locToName md2FileName (4, 1) renamed
         let declsr = hsBinds renamed
             [tlDecls] = definingDeclsNames [tl] declsr True False

         nn  <- mkNewGhcName "nn"
         nn2 <- mkNewGhcName "nn2"
         let newDecl = GHC.noLoc (GHC.VarBind nn (GHC.noLoc (GHC.HsVar nn2)) False)

         let (GHC.ValBindsOut _ vb) = hsValBinds renamed
         let hSig = head $ drop 3 vb
         let (GHC.L _ (GHC.TypeSig _ (GHC.L _ (GHC.HsTyVar intName)))) = hSig
         let sig = GHC.noLoc (GHC.TypeSig [(GHC.noLoc nn)] (GHC.noLoc (GHC.HsTyVar intName)))

         -- newDecls <- addDecl tlDecls Nothing (newDecl,Nothing,Nothing) False
         newDecls <- addDecl tlDecls Nothing (newDecl,Just sig,Nothing) False

         return (tlDecls,newDecls)
      ((tl,nb),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr tl) `shouldBe` "MoveDef.Md2.toplevel x\n  = MoveDef.Md2.c GHC.Num.* x GHC.Num.* b\n  where\n      b = 3"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md2 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x * b\n   where\n     b = 3\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      -- (showToks $ take 30 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md2 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x * b\n   where\n     b = 3\n     nn :: Int\n     nn = nn2\n \n  c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n -- General Comment\n -- |haddock comment\n tlFunc :: Integer -> Integer\n tlFunc x = c * x\n -- Comment at end\n\n\n "
      (GHC.showPpr nb) `shouldBe` "MoveDef.Md2.toplevel x\n  = MoveDef.Md2.c GHC.Num.* x GHC.Num.* b\n  where\n      b = 3\n      nn :: GHC.Types.Int\n      nn = nn2"


    -- -------------------------------------------

    it "Adds a local decl with type signature to an existing one, with a comment" $ do
      (t, toks) <- parsedFileWhereIn3Ghc
      let
        comp = do

         renamed <- getRefactRenamed

         let Just (GHC.L _ tl) = locToName whereIn3FileName (10, 1) renamed
         let declsr = hsBinds renamed
             [tlDecls] = definingDeclsNames [tl] declsr True False

         let Just (GHC.L _ sq) = locToName whereIn3FileName (14, 1) renamed

         let [sqDecl] = definingDeclsNames [sq] (hsBinds renamed) False False
             [sqSig]  = definingSigsNames  [sq] renamed
 

         -- newDecls <- addDecl tlDecls Nothing (newDecl,Nothing,Nothing) False
         newDecls <- addDecl tlDecls Nothing (sqDecl,Just sqSig,Nothing) False

         return (sqSig,tlDecls,newDecls)
      ((sigs,tl,nb),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr sigs) `shouldBe` "Demote.WhereIn3.sq ::\n  GHC.Types.Int -> GHC.Types.Int -> GHC.Types.Int"
      (GHC.showPpr tl) `shouldBe` "Demote.WhereIn3.sumSquares x y\n  = Demote.WhereIn3.sq p x GHC.Num.+ Demote.WhereIn3.sq p y\n  where\n      p = 2"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module Demote.WhereIn3 where\n\n --A definition can be demoted to the local 'where' binding of a friend declaration,\n --if it is only used by this friend declaration.\n\n --Demoting a definition narrows down the scope of the definition.\n --In this example, demote the top level 'sq' to 'sumSquares'\n --In this case (there are multi matches), the parameters are not folded after demoting.\n\n sumSquares x y = sq p x + sq p y\n          where p=2  {-There is a comment-}\n\n sq :: Int -> Int -> Int\n sq pow 0 = 0\n sq pow z = z^pow  --there is a comment\n\n anotherFun 0 y = sq y\n      where  sq x = x^2\n\n "
      -- (showToks $ take 30 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module Demote.WhereIn3 where\n\n --A definition can be demoted to the local 'where' binding of a friend declaration,\n --if it is only used by this friend declaration.\n\n --Demoting a definition narrows down the scope of the definition.\n --In this example, demote the top level 'sq' to 'sumSquares'\n --In this case (there are multi matches), the parameters are not folded after demoting.\n\n sumSquares x y = sq p x + sq p y\n          where p=2  {-There is a comment-}\n                sq :: Int -> Int -> Int\n                sq pow 0 = 0\n                sq pow z = z ^ pow\n \n  sq :: Int -> Int -> Int\n sq pow 0 = 0\n sq pow z = z^pow  --there is a comment\n\n anotherFun 0 y = sq y\n      where  sq x = x^2\n\n "
      (GHC.showPpr nb) `shouldBe` "Demote.WhereIn3.sumSquares x y\n  = Demote.WhereIn3.sq p x GHC.Num.+ Demote.WhereIn3.sq p y\n  where\n      p = 2\n      Demote.WhereIn3.sq ::\n        GHC.Types.Int -> GHC.Types.Int -> GHC.Types.Int\n      Demote.WhereIn3.sq pow 0 = 0\n      Demote.WhereIn3.sq pow z = z GHC.Real.^ pow"


    -- -------------------------------------------

    it "Adds a local decl with type signature to an existing one, with a comment using toks" $ do
      (t, toks) <- parsedFileWhereIn3Ghc
      let
        comp = do

         renamed <- getRefactRenamed

         let Just (GHC.L _ tl) = locToName whereIn3FileName (10, 1) renamed
         let declsr = hsBinds renamed
             [tlDecls] = definingDeclsNames [tl] declsr True False

         let Just (GHC.L _ sq) = locToName whereIn3FileName (14, 1) renamed

         {-
         let [sqDecl] = definingDeclsNames [sq] (hsBinds renamed) False False
             [sqSig]  = definingSigsNames  [sq] renamed
 

         let declToks = getDeclToks sq False (hsBinds renamed) toks
             Just (_sig,sigToks) = getSigAndToks sq renamed toks 
             toksToAdd = sigToks ++ declToks
         -}
         let ([sqDecl],declToks) = getDeclAndToks sq True toks renamed
         let (Just sqSig, sigToks) =
               case (getSigAndToks sq renamed toks) of
                 Just (sig, sigToks) -> (Just sig, sigToks)
                 Nothing -> (Nothing,[])
             toksToAdd = sigToks ++ declToks

         -- newDecls <- addDecl tlDecls Nothing (newDecl,Nothing,Nothing) False
         newDecls <- addDecl tlDecls Nothing (sqDecl,Just sqSig,Just toksToAdd) False

         return (sqSig,tlDecls,newDecls,toksToAdd)
      ((sigs,tl,nb,tta),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      -- (showToks tta) `shouldBe` ""
      -- (showToks toks) `shouldBe` ""
      (GHC.showPpr sigs) `shouldBe` "Demote.WhereIn3.sq ::\n  GHC.Types.Int -> GHC.Types.Int -> GHC.Types.Int"
      (GHC.showPpr tl) `shouldBe` "Demote.WhereIn3.sumSquares x y\n  = Demote.WhereIn3.sq p x GHC.Num.+ Demote.WhereIn3.sq p y\n  where\n      p = 2"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module Demote.WhereIn3 where\n\n --A definition can be demoted to the local 'where' binding of a friend declaration,\n --if it is only used by this friend declaration.\n\n --Demoting a definition narrows down the scope of the definition.\n --In this example, demote the top level 'sq' to 'sumSquares'\n --In this case (there are multi matches), the parameters are not folded after demoting.\n\n sumSquares x y = sq p x + sq p y\n          where p=2  {-There is a comment-}\n\n sq :: Int -> Int -> Int\n sq pow 0 = 0\n sq pow z = z^pow  --there is a comment\n\n anotherFun 0 y = sq y\n      where  sq x = x^2\n\n "
      -- (showToks $ take 30 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module Demote.WhereIn3 where\n\n --A definition can be demoted to the local 'where' binding of a friend declaration,\n --if it is only used by this friend declaration.\n\n --Demoting a definition narrows down the scope of the definition.\n --In this example, demote the top level 'sq' to 'sumSquares'\n --In this case (there are multi matches), the parameters are not folded after demoting.\n\n sumSquares x y = sq p x + sq p y\n          where p=2  {-There is a comment-}\n                sq :: Int -> Int -> Int\n                sq pow 0 = 0\n                sq pow z = z^pow  --there is a comment\n \n  sq :: Int -> Int -> Int\n sq pow 0 = 0\n sq pow z = z^pow  --there is a comment\n\n anotherFun 0 y = sq y\n      where  sq x = x^2\n\n "
      (GHC.showPpr nb) `shouldBe` "Demote.WhereIn3.sumSquares x y\n  = Demote.WhereIn3.sq p x GHC.Num.+ Demote.WhereIn3.sq p y\n  where\n      p = 2\n      Demote.WhereIn3.sq ::\n        GHC.Types.Int -> GHC.Types.Int -> GHC.Types.Int\n      Demote.WhereIn3.sq pow 0 = 0\n      Demote.WhereIn3.sq pow z = z GHC.Real.^ pow"


  -- ---------------------------------------------

  describe "renamePN" $ do
    it "Replace a Name with another, updating tokens" $ do
      (t, toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let declsr = hsBinds renamed
      let Just (GHC.L l n) = locToName dd1FileName (3, 1) renamed
      let
        comp = do
         newName <- mkNewGhcName "bar2"
         new <- renamePN n newName True declsr

         return (new,newName)
      let

      ((nb,nn),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "DupDef.Dd1.toplevel"
      (showToks $ [newNameTok l nn]) `shouldBe` "[(((3,1),(3,9)),ITvarid \"bar2\",\"bar2\")]"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module DupDef.Dd1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n "
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module DupDef.Dd1 where\n\n toplevel :: Integer -> Integer\n bar2 x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n "
      (GHC.showPpr nb) `shouldBe` "[DupDef.Dd1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) },\n DupDef.Dd1.l z = let ll = 34 in ll GHC.Num.+ z,\n DupDef.Dd1.ff y\n   = y GHC.Num.+ zz\n   where\n       zz = 1,\n DupDef.Dd1.tup@(DupDef.Dd1.h, DupDef.Dd1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15,\n DupDef.Dd1.d = 9, DupDef.Dd1.c = 7,\n bar2 x = DupDef.Dd1.c GHC.Num.* x]"
      (showToks $ take 20 $ toks) `shouldBe` "[(((1,1),(1,7)),ITmodule,\"module\"),(((1,8),(1,18)),ITqconid (\"DupDef\",\"Dd1\"),\"DupDef.Dd1\"),(((1,19),(1,24)),ITwhere,\"where\"),(((3,1),(3,1)),ITvocurly,\"\"),(((3,1),(3,9)),ITvarid \"toplevel\",\"toplevel\"),(((3,10),(3,12)),ITdcolon,\"::\"),(((3,13),(3,20)),ITconid \"Integer\",\"Integer\"),(((3,21),(3,23)),ITrarrow,\"->\"),(((3,24),(3,31)),ITconid \"Integer\",\"Integer\"),(((4,1),(4,1)),ITsemi,\"\"),(((4,1),(4,9)),ITvarid \"toplevel\",\"toplevel\"),(((4,10),(4,11)),ITvarid \"x\",\"x\"),(((4,12),(4,13)),ITequal,\"=\"),(((4,14),(4,15)),ITvarid \"c\",\"c\"),(((4,16),(4,17)),ITstar,\"*\"),(((4,18),(4,19)),ITvarid \"x\",\"x\"),(((6,1),(6,1)),ITsemi,\"\"),(((6,1),(6,2)),ITvarid \"c\",\"c\"),(((6,2),(6,3)),ITcomma,\",\"),(((6,3),(6,4)),ITvarid \"d\",\"d\")]"
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""

  -- ---------------------------------------------

  describe "findEntity" $ do
    it "Returns true if a syntax phrase is part of another" $ do
      let
        comp = do
         (t, toks) <- parseSourceFileGhc "./test/testdata/DupDef/Dd1.hs"
         putParsedModule t toks
         parentr <- getRefactRenamed

         let mn = locToName (GHC.mkFastString "./test/testdata/DupDef/Dd1.hs") (4,1) parentr
         let (Just (ln@(GHC.L _ n))) = mn

         let declsr = hsBinds parentr
             duplicatedDecls = definingDeclsNames [n] declsr True False

             res = findEntity ln duplicatedDecls
             -- res = findEntity' ln duplicatedDecls

         return (res,duplicatedDecls,ln)
      ((r,d,l),_s) <- runRefactGhcState comp
      (GHC.showPpr d) `shouldBe` "[DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x]"
      -- (show l) `shouldBe` "foo"
      -- (show r) `shouldBe` "foo"
      r `shouldBe` True

    -- -----------------------------------------------------------------

    it "Returns false if a syntax phrase is not part of another" $ do
      let
        comp = do
         (t, toks) <- parseSourceFileGhc "./test/testdata/DupDef/Dd1.hs"
         putParsedModule t toks
         parentr <- getRefactRenamed

         let mn = locToName (GHC.mkFastString "./test/testdata/DupDef/Dd1.hs") (4,1) parentr
         let (Just (ln@(GHC.L _ n))) = mn

         let mltup = locToName (GHC.mkFastString "./test/testdata/DupDef/Dd1.hs") (11,1) parentr
         let (Just (ltup@(GHC.L _ tup))) = mltup

         let declsr = hsBinds parentr
             duplicatedDecls = definingDeclsNames [n] declsr True False

             res = findEntity tup duplicatedDecls
             -- res = findEntity' ln duplicatedDecls

         return (res,duplicatedDecls,ln)
      ((r,d,l),_s) <- runRefactGhcState comp
      (GHC.showPpr d) `shouldBe` "[DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x]"
      -- (show l) `shouldBe` "foo"
      -- (show r) `shouldBe` "foo"
      r `shouldBe` False

    -- -----------------------------------------------------------------

    it "Finds an entity in [HsBind Name]" $ do
      pending "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (MatchGroup matches _)" $ do
      pending "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (HsLet decls _)" $ do
      pending "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (HsLet _ e1)" $ do
      pending "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (HsLet decls _)" $ do
      pending "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (PatBind pat rhs _ _ _)" $ do
      pending "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (Match _ _ rhs)" $ do
      pending "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (LetStmt binds)" $ do
      pending "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (BindStmt _ rhs _ _)" $ do
      pending "write this test"


  -- ---------------------------------------------

  describe "modIsExported" $ do
    it "Returns True if the module is explicitly exported" $ do
      -- ((_,_renamed,parsed), _toks) <- parsedFileDeclareGhc
      (t, _toks) <- parsedFileDeclareGhc
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      (modIsExported parsed) `shouldBe` True

    it "Returns True if the module is exported by default" $ do
      -- ((_,_renamed,parsed), _toks) <- parsedFileDeclare1Ghc
      (t, _toks) <- parsedFileDeclare1Ghc
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      (modIsExported parsed) `shouldBe` True

    it "Returns False if the module is explicitly not exported" $ do
      -- ((_,_renamed,parsed), _toks) <- parsedFileDeclare2Ghc
      (t, _toks) <- parsedFileDeclare2Ghc
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      (modIsExported parsed) `shouldBe` False

  -- ---------------------------------------------

  describe "addHiding" $ do
    it "Add a hiding entry to the imports with no existing hiding" $ do
      let
        comp = do

         (t1,_toks1)  <- parseSourceFileGhc "./test/testdata/DupDef/Dd1.hs"
         clearParsedModule
         (t2, toks2) <- parseSourceFileGhc "./test/testdata/DupDef/Dd2.hs"
         -- clearParsedModule
         let renamed1 = fromJust $ GHC.tm_renamed_source t1
         let renamed2 = fromJust $ GHC.tm_renamed_source t2

         let parsed1 = GHC.pm_parsed_source $ GHC.tm_parsed_module t1
         -- let parsed2 = GHC.pm_parsed_source $ GHC.tm_parsed_module t2

         let mn = locToName (GHC.mkFastString "./test/testdata/DupDef/Dd1.hs") (4,1) renamed1
         let (Just (GHC.L _ n)) = mn

         let Just (modName,_) = getModuleName parsed1
         n1   <- mkNewGhcName "n1"
         n2   <- mkNewGhcName "n2"
         res  <- addHiding modName renamed2 [n1,n2]
         toks <- fetchToks

         return (res,toks,renamed2,toks2)
      ((_r,t,r2,tk2),s) <- runRefactGhcState comp
      (GHC.showRichTokenStream t) `shouldBe` "module DupDef.Dd2 where\n\n import DupDef.Dd1 hiding (n1,n2)\n\n\n f2 x = ff (x+1)\n\n mm = 5\n\n\n "

    it "Add a hiding entry to the imports with an existing hiding" $ do
      let
        comp = do

         (t1,_toks1)  <- parseSourceFileGhc "./test/testdata/DupDef/Dd1.hs"
         clearParsedModule
         (t2, toks2) <- parseSourceFileGhc "./test/testdata/DupDef/Dd3.hs"
         -- clearParsedModule
         let renamed1 = fromJust $ GHC.tm_renamed_source t1
         let renamed2 = fromJust $ GHC.tm_renamed_source t2

         let parsed1 = GHC.pm_parsed_source $ GHC.tm_parsed_module t1
         -- let parsed2 = GHC.pm_parsed_source $ GHC.tm_parsed_module t2

         let mn = locToName (GHC.mkFastString "./test/testdata/DupDef/Dd1.hs") (4,1) renamed1
         let (Just (GHC.L _ n)) = mn

         let Just (modName,_) = getModuleName parsed1
         n1   <- mkNewGhcName "n1"
         n2   <- mkNewGhcName "n2"
         res  <- addHiding modName renamed2 [n1,n2]
         toks <- fetchToks

         return (res,toks,renamed2,toks2)
      ((_r,t,_r2,_tk2),_s) <- runRefactGhcState comp
      (GHC.showRichTokenStream t) `shouldBe` "module DupDef.Dd3 where\n\n import DupDef.Dd1 hiding (dd,n1,n2)\n\n\n f2 x = ff (x+1)\n\n mm = 5\n\n\n "
      
  -- ---------------------------------------------

  describe "usedWithoutQual" $ do
    it "Returns True if the identifier is used unqualified" $ do
      let
        comp = do
          (t, toks) <- parseSourceFileGhc "./test/testdata/DupDef/Dd1.hs"
          putParsedModule t toks
          renamed <- getRefactRenamed

          let Just n@(GHC.L _ name) = locToName (GHC.mkFastString "./test/testdata/DupDef/Dd1.hs") (14,21) renamed
          res <- usedWithoutQual name renamed
          return (res,n,name)

      -- ((r,n1,n2),s) <- runRefactGhc comp $ initialState { rsTokenStream = toks }
      ((r,n1,n2),s) <- runRefactGhcState comp 

      (GHC.getOccString n2) `shouldBe` "zip"
      (GHC.showPpr n1) `shouldBe` "GHC.List.zip"
      r `shouldBe` True

    it "Returns False if the identifier is used qualified" $ do
      let
        comp = do
          (t, toks) <- parseSourceFileGhc "./test/testdata/FreeAndDeclared/Declare.hs"
          putParsedModule t toks
          renamed <- getRefactRenamed
          parsed <- getRefactParsed

          let Just n@(GHC.L _ name) = locToName (GHC.mkFastString "./test/testdata/FreeAndDeclared/Declare.hs") (36,12) renamed
          let PNT np@(GHC.L _ namep) = locToPNT (GHC.mkFastString "./test/testdata/FreeAndDeclared/Declare.hs") (36,12) parsed
          res <- usedWithoutQual name renamed
          return (res,namep,name,n)
      -- ((r,np,n1,n2),s) <- runRefactGhc comp $ initialState { rsTokenStream = toks }
      ((r,np,n1,n2),s) <- runRefactGhcState comp

      (myShow np) `shouldBe` "Qual:G:gshow"
      (myShow $ GHC.getRdrName n1) `shouldBe` "Exact:Data.Generics.Text.gshow"
      (GHC.showRdrName $ GHC.getRdrName n1) `shouldBe` "Data.Generics.Text.gshow"
      -- (GHC.showPpr $ GHC.occNameFS $ GHC.getOccName name) `shouldBe` "G.gshow"
      -- (GHC.getOccString name) `shouldBe` "G.gshow"
      (GHC.showPpr n2) `shouldBe` "Data.Generics.Text.gshow"
      r `shouldBe` False

  -- ---------------------------------------------

  describe "isExplicitlyExported" $ do
    it "Returns True if the identifier is explicitly exported" $ do
      pending "write this "

    it "Returns False if the identifier is not explicitly exported" $ do
      pending "write this "

  -- ---------------------------------------------

  describe "causeNameClashInExports" $ do
    it "Returns False if there is no clash" $ do
      pending "write this "

    it "Returns True if clash of type xx" $ do
      pending "write this "

  -- --------------------------------------

  describe "getDeclAndToks" $ do
    it "Returns a declaration and its associated tokens" $ do
      let
        comp = do
          (t, toks) <- parseSourceFileGhc "./test/testdata/MoveDef/Md1.hs"
          putParsedModule t toks
          renamed <- getRefactRenamed

          let Just n@(GHC.L _ name) = locToName (GHC.mkFastString "./test/testdata/MoveDef/Md1.hs") (40,4) renamed
          let res = getDeclAndToks name True toks renamed
          return (res,n,name)

      (((d,t),n1,n2),s) <- runRefactGhcState comp 
      (GHC.showPpr n1) `shouldBe` "MoveDef.Md1.tlFunc"
      (GHC.showPpr d) `shouldBe` "[MoveDef.Md1.tlFunc x = MoveDef.Md1.c GHC.Num.* x]"
      (show $ getStartEndLoc d) `shouldBe` "((40,1),(40,17))"
      (show $ startEndLocIncComments (toksFromState s) d) `shouldBe` "((40,1),(41,18))"
      (showToks t) `shouldBe` "[(((40,0),(40,0)),ITsemi,\"\"),(((40,0),(40,6)),ITvarid \"tlFunc\",\"tlFunc\"),(((40,7),(40,8)),ITvarid \"x\",\"x\"),(((40,9),(40,10)),ITequal,\"=\"),(((40,11),(40,12)),ITvarid \"c\",\"c\"),(((40,13),(40,14)),ITstar,\"*\"),(((40,15),(40,16)),ITvarid \"x\",\"x\"),(((41,0),(41,17)),ITlineComment \"-- Comment at end\",\"-- Comment at end\")]"

  -- --------------------------------------

  describe "getDeclToks" $ do
    it "Returns a the tokens associated with a declaration" $ do
      let
        comp = do
          (t, toks) <- parseSourceFileGhc "./test/testdata/Demote/D1.hs"
          putParsedModule t toks
          renamed <- getRefactRenamed

          let Just n@(GHC.L _ name) = locToName (GHC.mkFastString "./test/testdata/Demote/D1.hs") (9,1) renamed
          let res = getDeclToks name False (hsBinds renamed) toks
          return (res,n,name)

      ((dt,n1,n2),s) <- runRefactGhcState comp 
      (GHC.showPpr n1) `shouldBe` "Demote.D1.sq"
      (showToks dt) `shouldBe` "[(((9,1),(9,1)),ITsemi,\"\"),(((9,1),(9,3)),ITvarid \"sq\",\"sq\"),(((9,4),(9,5)),ITvarid \"x\",\"x\"),(((9,6),(9,7)),ITequal,\"=\"),(((9,8),(9,9)),ITvarid \"x\",\"x\"),(((9,10),(9,11)),ITvarsym \"^\",\"^\"),(((9,11),(9,14)),ITvarid \"pow\",\"pow\")]"

  -- ---------------------------------------

  describe "rmQualifier" $ do
    it "Removes the qualifiers from a list of identifiers in a given syntax phrase" $ do
      (t, toks) <- parsedFileWhereIn3Ghc
      let
        comp = do
          renamed <- getRefactRenamed

          let Just (GHC.L _ sq) = locToName whereIn3FileName (14, 1) renamed

          let ([sqDecl],declToks) = getDeclAndToks sq True toks renamed

          res <- rmQualifier [sq] sqDecl
          return (res,sqDecl,sq)

      ((r,d,n1),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n1) `shouldBe` "Demote.WhereIn3.sq"
      (GHC.showPpr d) `shouldBe` "Demote.WhereIn3.sq pow 0 = 0\nDemote.WhereIn3.sq pow z = z GHC.Real.^ pow"
      (GHC.showPpr r) `shouldBe` "sq pow 0 = 0\nsq pow z = z GHC.Real.^ pow"

    it "Removes the qualifiers and updates the tokens" $ do
      pending "Is this needed?"

  -- ---------------------------------------

  describe "usedByRhs" $ do
    it "Returns True if a given identifier is used in the RHS of a syntax element" $ do
      let
        comp = do
          (t, toks) <- parseSourceFileGhc "./test/testdata/MoveDef/Demote.hs"
          putParsedModule t toks
          renamed <- getRefactRenamed

          let Just (GHC.L _ tl)   = locToName (GHC.mkFastString "./test/testdata/MoveDef/Demote.hs") (4,1) renamed
          let Just (GHC.L _ name) = locToName (GHC.mkFastString "./test/testdata/MoveDef/Demote.hs") (7,1) renamed
          let decls = (definingDeclsNames [tl] (hsBinds renamed) False False)
          decls' <- rmQualifier [name] decls

          -- let res = usedByRhs decls [name]
          let res = usedByRhs decls' [name]

          return (res,decls,tl,name)

      ((r,d,n1,n2),s) <- runRefactGhcState comp
      (GHC.showPpr n1) `shouldBe` "MoveDef.Demote.toplevel"
      (GHC.showPpr n2) `shouldBe` "MoveDef.Demote.c"
      (GHC.showPpr d) `shouldBe` "[MoveDef.Demote.toplevel x = MoveDef.Demote.c GHC.Num.* x]"
      r `shouldBe` True

  -- ---------------------------------------

  describe "autoRenameLocalVar" $ do
    it "Renames an identifier if it is used, no token update" $ do
      let
        comp = do
          (t, toks) <- parseSourceFileGhc "./test/testdata/Demote/WhereIn4.hs"
          putParsedModule t toks
          renamed <- getRefactRenamed

          let Just (GHC.L _ tl)   = locToName (GHC.mkFastString "./test/testdata/Demote/WhereIn4.hs") (11,1) renamed
          let Just (GHC.L _ name) = locToName (GHC.mkFastString "./test/testdata/Demote/WhereIn4.hs") (11,21) renamed
          let decls = (definingDeclsNames [tl] (hsBinds renamed) False False)
          decls' <- autoRenameLocalVar False name decls

          return (decls',decls,tl,name)

      ((r,d,n1,n2),s) <- runRefactGhcState comp
      (GHC.showPpr n1) `shouldBe` "Demote.WhereIn4.sumSquares"
      (GHC.showPpr n2) `shouldBe` "p"
      (GHC.showPpr d) `shouldBe` "[Demote.WhereIn4.sumSquares x y\n   = Demote.WhereIn4.sq p x GHC.Num.+ Demote.WhereIn4.sq p y\n   where\n       p = 2]"
      (GHC.showPpr r) `shouldBe` "[Demote.WhereIn4.sumSquares x y\n   = Demote.WhereIn4.sq p_1 x GHC.Num.+ Demote.WhereIn4.sq p_1 y\n   where\n       p_1 = 2]"
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module Demote.WhereIn4 where\n\n --A definition can be demoted to the local 'where' binding of a friend declaration,\n --if it is only used by this friend declaration.\n\n --Demoting a definition narrows down the scope of the definition.\n --In this example, demote the top level 'sq' to 'sumSquares'\n --In this case (there is single matches), if possible,\n --the parameters will be folded after demoting and type sigature will be removed.\n\n sumSquares x y = sq p x + sq p y\n          where p=2  {-There is a comment-}\n\n sq::Int->Int->Int\n sq pow z = z^pow  --there is a comment\n\n anotherFun 0 y = sq y\n      where  sq x = x^2\n\n "


    it "Renames an identifier if it is used and updates tokens" $ do
      let
        comp = do
          (t, toks) <- parseSourceFileGhc "./test/testdata/Demote/WhereIn4.hs"
          putParsedModule t toks
          renamed <- getRefactRenamed

          let Just (GHC.L _ tl)   = locToName (GHC.mkFastString "./test/testdata/Demote/WhereIn4.hs") (11,1) renamed
          let Just (GHC.L _ name) = locToName (GHC.mkFastString "./test/testdata/Demote/WhereIn4.hs") (11,21) renamed
          let decls = (definingDeclsNames [tl] (hsBinds renamed) False False)
          decls' <- autoRenameLocalVar True name decls

          return (decls',decls,tl,name)

      ((r,d,n1,n2),s) <- runRefactGhcState comp
      (GHC.showPpr n1) `shouldBe` "Demote.WhereIn4.sumSquares"
      (GHC.showPpr n2) `shouldBe` "p"
      (GHC.showPpr d) `shouldBe` "[Demote.WhereIn4.sumSquares x y\n   = Demote.WhereIn4.sq p x GHC.Num.+ Demote.WhereIn4.sq p y\n   where\n       p = 2]"
      (GHC.showPpr r) `shouldBe` "[Demote.WhereIn4.sumSquares x y\n   = Demote.WhereIn4.sq p_1 x GHC.Num.+ Demote.WhereIn4.sq p_1 y\n   where\n       p_1 = 2]"
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module Demote.WhereIn4 where\n\n --A definition can be demoted to the local 'where' binding of a friend declaration,\n --if it is only used by this friend declaration.\n\n --Demoting a definition narrows down the scope of the definition.\n --In this example, demote the top level 'sq' to 'sumSquares'\n --In this case (there is single matches), if possible,\n --the parameters will be folded after demoting and type sigature will be removed.\n\n sumSquares x y = sq p_1 x + sq p_1 y\n          where p_1=2  {-There is a comment-}\n\n sq::Int->Int->Int\n sq pow z = z^pow  --there is a comment\n\n anotherFun 0 y = sq y\n      where  sq x = x^2\n\n "

  -- ---------------------------------------

  describe "mkNewName" $ do
    it "Makes a new name that does not clash with existing ones" $ do
      (mkNewName "f" ["f"] 0) `shouldBe` "f_1"
      (mkNewName "f" ["g"] 0) `shouldBe` "f"
      (mkNewName "f" ["g","f_1","f"] 0) `shouldBe` "f_2"

  -- ---------------------------------------

  describe "addImportDecl" $ do
    it "Add an import entry to a module with already existing, non conflicting imports and other declarations." $ do
      let
        comp = do

         (t1,_toks1)  <- parseSourceFileGhc "./test/testdata/DupDef/Dd1.hs"
         clearParsedModule
         (t2, toks2) <- parseSourceFileGhc "./test/testdata/DupDef/Dd2.hs"
         -- clearParsedModule
         let renamed1 = fromJust $ GHC.tm_renamed_source t1
         let renamed2 = fromJust $ GHC.tm_renamed_source t2

         let parsed1 = GHC.pm_parsed_source $ GHC.tm_parsed_module t1

         let listModName  = GHC.mkModuleName "Data.List"
         n1   <- mkNewGhcName "n1"
         n2   <- mkNewGhcName "n2"
         res  <- addImportDecl renamed2 listModName Nothing False False False Nothing False [] 
         toks <- fetchToks

         return (res,toks,renamed2,toks2)
      ((_r,t,r2,tk2),s) <- runRefactGhcState comp
      (GHC.showRichTokenStream t) `shouldBe` "module DupDef.Dd2 where\n\n import DupDef.Dd1\n\n import Data.List\n\n\n f2 x = ff (x+1)\n\n mm = 5\n\n\n "


    it "Add an import entry to a module with some declaration, but no explicit imports." $ do
      let
        comp = do

         (t1,_toks1)  <- parseSourceFileGhc "./test/testdata/TypeUtils/Simplest.hs"
         -- clearParsedModule
         let renamed1 = fromJust $ GHC.tm_renamed_source t1

         let listModName  = GHC.mkModuleName "Data.List"
         res  <- addImportDecl renamed1 listModName Nothing False False False Nothing False [] 
         toks <- fetchToks

         return (res,toks,renamed1,_toks1)
      ((_r,t,r2,tk2),s) <- runRefactGhcState comp
      (GHC.showRichTokenStream t) `shouldBe` "module Simplest where\n\n import Data.List\n\n\n simple x = x\n "


    it "Add an import entry to a module with explicit imports, but no declarations." $ do
      let
        comp = do

         (t1,_toks1)  <- parseSourceFileGhc "./test/testdata/TypeUtils/JustImports.hs"
         -- clearParsedModule
         let renamed1 = fromJust $ GHC.tm_renamed_source t1

         let listModName  = GHC.mkModuleName "Data.List"
         res  <- addImportDecl renamed1 listModName Nothing False False False Nothing False [] 
         toks <- fetchToks

         return (res,toks,renamed1,_toks1)
      ((_r,t,r2,tk2),s) <- runRefactGhcState comp
      (GHC.showRichTokenStream t) `shouldBe` "module JustImports where\n\n import Data.Maybe\n\n import Data.List\n "



    it "Add an import entry to a module with no declarations and no explicit imports." $ do
      let
        comp = do

         (t1,_toks1)  <- parseSourceFileGhc "./test/testdata/TypeUtils/Empty.hs"
         -- clearParsedModule
         let renamed1 = fromJust $ GHC.tm_renamed_source t1
       
         let listModName  = GHC.mkModuleName "Data.List"
         res  <- addImportDecl renamed1 listModName Nothing False False False Nothing False [] 
         toks <- fetchToks

         return (res,toks,renamed1,_toks1)
      ((_r,t,r2,tk2),s) <- runRefactGhcState comp

      (GHC.showRichTokenStream t) `shouldBe` "module Empty where\n\n \n\n import Data.List"


  -- ---------------------------------------

  describe "addItemsToImport" $ do
    it "Add an item to an import entry with no items." $ do
      let
        comp = do
         (t1,_toks1)  <- parseSourceFileGhc "./test/testdata/TypeUtils/JustImports.hs"
         -- clearParsedModule
         let renamed1 = fromJust $ GHC.tm_renamed_source t1

         let modName  = GHC.mkModuleName "Data.Maybe"
         itemName <- mkNewGhcName "fromJust"

         res  <- addItemsToImport modName renamed1 [itemName]  
         toks <- fetchToks

         return (res,toks,renamed1,_toks1)
      ((_r,t,r2,tk2),s) <- runRefactGhcState comp
      -- This is the correct behavior. If the import doesn't have an import list, creating 
      -- one for an item effectively reduces the imported interface. 
      (GHC.showRichTokenStream t) `shouldBe` "module JustImports where\n\n import Data.Maybe\n "

-- Not sure if this should be a test
{-    it "Try adding more than one item to an existing import entry with no items, using separate calls." $ do
      let
        comp = do
         (t1,_toks1)  <- parseSourceFileGhc "./test/testdata/TypeUtils/JustImports.hs"
         -- clearParsedModule
         let renamed1 = fromJust $ GHC.tm_renamed_source t1

         let modName  = GHC.mkModuleName "Data.Maybe"
         itemName <- mkNewGhcName "fromJust"

         res  <- addItemsToImport modName renamed1 [itemName] --listModName Nothing False False False Nothing False [] 

         itemName2 <- mkNewGhcName "isJust"

         res2 <- addItemsToImport modName res [itemName2]
         toks <- fetchToks

         return (res2,toks,renamed,_toks1)
      ((_r,t,r2,tk2),s) <- runRefactGhcState comp
      (GHC.showRichTokenStream t) `shouldBe` "module JustImports where\n\n import Data.Maybe (fromJust,isJust)\n "
-}

    it "Add an item to an import entry with existing items." $ do
      let
        comp = do
         (t1,_toks1)  <- parseSourceFileGhc "./test/testdata/TypeUtils/SelectivelyImports.hs"
         -- clearParsedModule
         let renamed1 = fromJust $ GHC.tm_renamed_source t1

         let modName  = GHC.mkModuleName "Data.Maybe"
         itemName <- mkNewGhcName "isJust"

         res  <- addItemsToImport modName renamed1 [itemName]  
         toks <- fetchToks

         return (res,toks,renamed1,_toks1)
      ((_r,t,r2,tk2),s) <- runRefactGhcState comp
      (GHC.showRichTokenStream t) `shouldBe` "module SelectivelyImports where\n\n import Data.Maybe (fromJust,isJust)\n\n __ = id\n "

{- -- test after properly inserting conditional identifier
    it "Add an item to an import entry with existing items, passing existing conditional identifier." $ do
      let
        comp = do
         (t1,_toks1)  <- parseSourceFileGhc "./test/testdata/TypeUtils/SelectivelyImports.hs"
         -- clearParsedModule
         let renamed1 = fromJust $ GHC.tm_renamed_source t1

         let modName  = GHC.mkModuleName "Data.Maybe"
         itemName <- mkNewGhcName "isJust"
         conditionalId <- mkNewGhcName "fromJust"

         res  <- addItemsToImport modName renamed1 [itemName] (Just conditionalId) 
         toks <- fetchToks

         return (res,toks,renamed1,_toks1)
      ((_r,t,r2,tk2),s) <- runRefactGhcState comp
      (GHC.showRichTokenStream t) `shouldBe` "module SelectivelyImports where\n\n import Data.Maybe (fromJust,isJust)\n\n __ = id\n "

    it "Add an item to an import entry with existing items, passing missing conditional identifier" $ do
      let
        comp = do
         (t1,_toks1)  <- parseSourceFileGhc "./test/testdata/TypeUtils/SelectivelyImports.hs"
         -- clearParsedModule
         let renamed1 = fromJust $ GHC.tm_renamed_source t1

         let modName  = GHC.mkModuleName "Data.Maybe"
         itemName <- mkNewGhcName "isJust"

         res  <- addItemsToImport modName renamed1 [itemName] (Just itemName) 
         toks <- fetchToks

         return (res,toks,renamed1,_toks1)
      ((_r,t,r2,tk2),s) <- runRefactGhcState comp
      (GHC.showRichTokenStream t) `shouldBe` "module SelectivelyImports where\n\n import Data.Maybe (fromJust)\n\n __ = id\n "
-}

  -- ---------------------------------------
foo 
  = do
      let
        comp = do

         (t1,_toks1)  <- parseSourceFileGhc "./test/testdata/TypeUtils/Empty.hs"
         -- clearParsedModule
         let renamed1@(g,_,_,_) = fromJust $ GHC.tm_renamed_source t1

         let ss = getSrcSpan g

         let listModName  = GHC.mkModuleName "Data.List"
         res  <- addImportDecl renamed1 listModName Nothing False False False Nothing False [] 
         -- let res = 3
         toks <- fetchToks

         return (res,toks,renamed1,_toks1,ss)
      ((_r,t,r2,tk2,ss'),s) <- runRefactGhcState comp
      return (GHC.showPpr ss')
      -- return (GHC.showRichTokenStream t)



myShow :: GHC.RdrName -> String
myShow n = case n of
  GHC.Unqual on  -> ("Unqual:" ++ (GHC.showPpr on))
  GHC.Qual ms on -> ("Qual:" ++ (GHC.showPpr ms) ++ ":" ++ (GHC.showPpr on))
  GHC.Orig ms on -> ("Orig:" ++ (GHC.showPpr ms) ++ ":" ++ (GHC.showPpr on))
  GHC.Exact en   -> ("Exact:" ++ (GHC.showPpr en))



-- ---------------------------------------------------------------------
-- Helper functions

bFileName :: GHC.FastString
bFileName = GHC.mkFastString "./test/testdata/TypeUtils/B.hs"

parsedFileBGhc :: IO (ParseResult,[PosToken])
parsedFileBGhc = parsedFileGhc "./test/testdata/TypeUtils/B.hs"

parsedFileSGhc :: IO (ParseResult,[PosToken])
parsedFileSGhc = parsedFileGhc "./test/testdata/TypeUtils/S.hs"


dd1FileName :: GHC.FastString
dd1FileName = GHC.mkFastString "./test/testdata/DupDef/Dd1.hs"

parsedFileDd1Ghc :: IO (ParseResult,[PosToken])
parsedFileDd1Ghc = parsedFileGhc "./test/testdata/DupDef/Dd1.hs"

parsedFileDd2Ghc :: IO (ParseResult,[PosToken])
parsedFileDd2Ghc = parsedFileGhc "./test/testdata/DupDef/Dd2.hs"

parsedFileDeclareGhc :: IO (ParseResult,[PosToken])
parsedFileDeclareGhc = parsedFileGhc "./test/testdata/FreeAndDeclared/Declare.hs"

parsedFileDeclare1Ghc :: IO (ParseResult,[PosToken])
parsedFileDeclare1Ghc = parsedFileGhc "./test/testdata/FreeAndDeclared/Declare1.hs"

parsedFileDeclare2Ghc :: IO (ParseResult,[PosToken])
parsedFileDeclare2Ghc = parsedFileGhc "./test/testdata/FreeAndDeclared/Declare2.hs"

parsedFileDemoteGhc :: IO (ParseResult,[PosToken])
parsedFileDemoteGhc = parsedFileGhc "./test/testdata/MoveDef/Demote.hs"

demoteFileName :: GHC.FastString
demoteFileName = GHC.mkFastString "./test/testdata/MoveDef/Demote.hs"

parsedFileMd1Ghc :: IO (ParseResult,[PosToken])
parsedFileMd1Ghc = parsedFileGhc "./test/testdata/MoveDef/Md1.hs"

md1FileName :: GHC.FastString
md1FileName = GHC.mkFastString "./test/testdata/MoveDef/Md1.hs"

parsedFileMd2Ghc :: IO (ParseResult,[PosToken])
parsedFileMd2Ghc = parsedFileGhc "./test/testdata/MoveDef/Md2.hs"

md2FileName :: GHC.FastString
md2FileName = GHC.mkFastString "./test/testdata/MoveDef/Md2.hs"

-- -----------

parsedFileD1Ghc :: IO (ParseResult,[PosToken])
parsedFileD1Ghc = parsedFileGhc "./test/testdata/Demote/D1.hs"

d1FileName :: GHC.FastString
d1FileName = GHC.mkFastString "./test/testdata/Demote/D1.hs"

-- -----------

parsedFileWhereIn3Ghc :: IO (ParseResult,[PosToken])
parsedFileWhereIn3Ghc = parsedFileGhc "./test/testdata/Demote/WhereIn3.hs"

whereIn3FileName :: GHC.FastString
whereIn3FileName = GHC.mkFastString "./test/testdata/Demote/WhereIn3.hs"

-- ----------------------------------------------------

-- Runners

-- t = withArgs ["--match", "hsFreeAndDeclaredPNs"] main
-- t = withArgs ["--match", "allNames"] main
-- t = withArgs ["--match", "definingDeclsNames"] main

-- t = withArgs ["--match", "getName"] main



