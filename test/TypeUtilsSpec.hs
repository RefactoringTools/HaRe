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

import Control.Monad.State
import Data.Maybe
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
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
      GHC.showPpr l `shouldBe` "test/testdata/B.hs:7:1-3"
      getLocatedStart res `shouldBe` (7,1)
      GHC.showRdrName n `shouldBe` "foo"

    it "returns a pnt for a given source location, if it falls anywhere in an identifier #2" $ do
      -- ((_, _, parsed), toks) <- parsedFileBGhc
      (t, toks) <- parsedFileBGhc
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let (PNT res@(GHC.L l n)) = locToPNT bFileName (25,8) parsed
      GHC.showRdrName n `shouldBe` "bob"
      GHC.showPpr l `shouldBe` "test/testdata/B.hs:25:7-9"
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
      modInfo@(t, toks) <- parsedFileBGhc
      let mod = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let res = allPNT bFileName (7,6) mod
      show res `shouldBe`  "[(PNT test/testdata/B.hs:7:1-3 foo),(PNT test/testdata/B.hs:7:5 x),(PNT test/testdata/B.hs:7:13-15 odd),(PNT test/testdata/B.hs:7:17 x),(PNT test/testdata/B.hs:9:1-3 bob),(PNT test/testdata/B.hs:9:5 x),(PNT test/testdata/B.hs:9:7 y),(PNT test/testdata/B.hs:9:15-17 foo),(PNT test/testdata/B.hs:9:19 x),(PNT test/testdata/B.hs:9:23 x),(PNT test/testdata/B.hs:9:25 +),(PNT test/testdata/B.hs:9:37-39 foo),(PNT test/testdata/B.hs:9:41 x),(PNT test/testdata/B.hs:9:45 x),(PNT test/testdata/B.hs:9:46 +),(PNT test/testdata/B.hs:9:53 x),(PNT test/testdata/B.hs:9:55 +),(PNT test/testdata/B.hs:9:57-59 foo),(PNT test/testdata/B.hs:9:61 y),(PNT test/testdata/B.hs:11:9-11 foo),(PNT test/testdata/B.hs:11:13 x),(PNT test/testdata/B.hs:11:17 x),(PNT test/testdata/B.hs:11:19 +),(PNT test/testdata/B.hs:14:1-4 foo'),(PNT test/testdata/B.hs:14:6 x),(PNT test/testdata/B.hs:14:16-18 odd),(PNT test/testdata/B.hs:14:20 x),(PNT test/testdata/B.hs:15:3-6 True),(PNT test/testdata/B.hs:16:3-7 False),(PNT test/testdata/B.hs:18:1-4 main),(PNT test/testdata/B.hs:19:1-4 main),(PNT test/testdata/B.hs:20:3-10 putStrLn),(PNT test/testdata/B.hs:20:12 $),(PNT test/testdata/B.hs:20:14-17 show),(PNT test/testdata/B.hs:20:19 $),(PNT test/testdata/B.hs:20:22-24 foo),(PNT test/testdata/B.hs:20:29 +),(PNT test/testdata/B.hs:20:31-35 C.baz),(PNT test/testdata/B.hs:22:1-4 mary),(PNT test/testdata/B.hs:23:1-4 mary),(PNT test/testdata/B.hs:25:1 h),(PNT test/testdata/B.hs:25:3 z),(PNT test/testdata/B.hs:25:7-9 bob),(PNT test/testdata/B.hs:25:11 z),(PNT test/testdata/B.hs:27:6 D),(PNT test/testdata/B.hs:27:10 A),(PNT test/testdata/B.hs:27:14 B),(PNT test/testdata/B.hs:27:25 C),(PNT test/testdata/B.hs:29:1-7 subdecl),(PNT test/testdata/B.hs:29:9 x),(PNT test/testdata/B.hs:29:13-14 zz),(PNT test/testdata/B.hs:29:16 x),(PNT test/testdata/B.hs:31:5-6 zz),(PNT test/testdata/B.hs:31:8 n),(PNT test/testdata/B.hs:31:12 n),(PNT test/testdata/B.hs:31:14 +)]"

 
  -- -------------------------------------------------------------------

  describe "locToName" $ do
    it "returns a GHC.Name for a given source location, if it falls anywhere in an identifier" $ do
      -- ((_,renamed,_), _toks) <- parsedFileBGhc
      (t, _toks) <- parsedFileBGhc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just (res@(GHC.L l n)) = locToName bFileName (7,3) renamed
      GHC.showPpr l `shouldBe` "test/testdata/B.hs:7:1-3"
      getLocatedStart res `shouldBe` (7,1)
      GHC.showPpr n `shouldBe` "B.foo"

    it "returns a GHC.Name for a given source location, if it falls anywhere in an identifier #2" $ do
      -- ((_, renamed,_),_toks) <- parsedFileBGhc
      (t, _toks) <- parsedFileBGhc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just (res@(GHC.L l n)) = locToName bFileName (25,8) renamed
      GHC.showPpr n `shouldBe` "B.bob"
      GHC.showPpr l `shouldBe` "test/testdata/B.hs:25:7-9"
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
      -- ((_, renamed,_), _toks) <- parsedFileBGhc
      (t, _toks) <- parsedFileBGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let res = allNames bFileName (7,6) renamed
      -- let res' = map (\(GHC.L l n) -> (GHC.showPpr $ GHC.nameUnique n,GHC.showPpr (l, n))) res
      let res' = map (\(GHC.L l n) -> (GHC.showPpr $ GHC.nameUnique n,GHC.showPpr (l, GHC.getSrcSpan n, n))) res

      -- Map.insertWith :: Ord k => (a -> a -> a) -> k -> a -> Map k a -> Map k a
      let res'' = foldl' (\m (k,a) -> Map.insertWith (++) k a m) Map.empty res'

      (sort $ Map.elems res'') `shouldBe` 
                 ["(test/testdata/B.hs:11:17, test/testdata/B.hs:11:13, x)(test/testdata/B.hs:11:13, test/testdata/B.hs:11:13, x)"
                 ,"(test/testdata/B.hs:11:9-11, test/testdata/B.hs:11:9-11, foo)"
                 ,"(test/testdata/B.hs:14:1-4, test/testdata/B.hs:14:1-4, B.foo')"
                 ,"(test/testdata/B.hs:14:20, test/testdata/B.hs:14:6, x)(test/testdata/B.hs:14:6, test/testdata/B.hs:14:6, x)"
                 ,"(test/testdata/B.hs:15:3-6, <wired into compiler>, GHC.Types.True)"
                 ,"(test/testdata/B.hs:16:3-7, <wired into compiler>, GHC.Types.False)"
                 ,"(test/testdata/B.hs:18:1-4, test/testdata/B.hs:19:1-4, B.main)(test/testdata/B.hs:19:1-4, test/testdata/B.hs:19:1-4, B.main)"
                 ,"(test/testdata/B.hs:20:14-17, <no location info>, GHC.Show.show)"
                 ,"(test/testdata/B.hs:20:19, <no location info>, GHC.Base.$)(test/testdata/B.hs:20:12, <no location info>, GHC.Base.$)"
                 ,"(test/testdata/B.hs:20:22-24, test/testdata/B.hs:7:1-3, B.foo)(test/testdata/B.hs:7:1-3, test/testdata/B.hs:7:1-3, B.foo)"
                 ,"(test/testdata/B.hs:20:29, <no location info>, GHC.Num.+)(test/testdata/B.hs:11:19, <no location info>, GHC.Num.+)(test/testdata/B.hs:9:55, <no location info>, GHC.Num.+)(test/testdata/B.hs:9:46, <no location info>, GHC.Num.+)(test/testdata/B.hs:9:25, <no location info>, GHC.Num.+)(test/testdata/B.hs:31:14, <no location info>, GHC.Num.+)"
                 ,"(test/testdata/B.hs:20:3-10,\n <no location info>,\n System.IO.putStrLn)"
                 ,"(test/testdata/B.hs:20:31-35, test/testdata/C.hs:4:1-3, C.baz)"
                 ,"(test/testdata/B.hs:22:1-4, test/testdata/B.hs:23:1-4, B.mary)(test/testdata/B.hs:23:1-4, test/testdata/B.hs:23:1-4, B.mary)"
                 ,"(test/testdata/B.hs:25:1, test/testdata/B.hs:25:1, B.h)"
                 ,"(test/testdata/B.hs:25:11, test/testdata/B.hs:25:3, z)(test/testdata/B.hs:25:3, test/testdata/B.hs:25:3, z)"
                 ,"(test/testdata/B.hs:25:7-9, test/testdata/B.hs:9:1-3, B.bob)(test/testdata/B.hs:9:1-3, test/testdata/B.hs:9:1-3, B.bob)"
                 ,"(test/testdata/B.hs:27:10, test/testdata/B.hs:27:10, B.A)"
                 ,"(test/testdata/B.hs:27:14, test/testdata/B.hs:27:14, B.B)"
                 ,"(test/testdata/B.hs:27:25, test/testdata/B.hs:27:25, B.C)"
                 ,"(test/testdata/B.hs:27:6, test/testdata/B.hs:27:6, B.D)"
                 ,"(test/testdata/B.hs:29:1-7, test/testdata/B.hs:29:1-7, B.subdecl)"
                 ,"(test/testdata/B.hs:29:16, test/testdata/B.hs:29:9, x)(test/testdata/B.hs:29:9, test/testdata/B.hs:29:9, x)"
                 ,"(test/testdata/B.hs:31:12, test/testdata/B.hs:31:8, n)(test/testdata/B.hs:31:8, test/testdata/B.hs:31:8, n)"
                 ,"(test/testdata/B.hs:31:5-6, test/testdata/B.hs:31:5-6, zz)(test/testdata/B.hs:29:13-14, test/testdata/B.hs:31:5-6, zz)"
                 ,"(test/testdata/B.hs:7:13-15, <no location info>, GHC.Real.odd)(test/testdata/B.hs:14:16-18, <no location info>, GHC.Real.odd)"
                 ,"(test/testdata/B.hs:7:17, test/testdata/B.hs:7:5, x)(test/testdata/B.hs:7:5, test/testdata/B.hs:7:5, x)"
                 ,"(test/testdata/B.hs:9:15-17, test/testdata/B.hs:9:15-17, foo)"
                 ,"(test/testdata/B.hs:9:23, test/testdata/B.hs:9:19, x)(test/testdata/B.hs:9:19, test/testdata/B.hs:9:19, x)"
                 ,"(test/testdata/B.hs:9:45, test/testdata/B.hs:9:41, x)(test/testdata/B.hs:9:41, test/testdata/B.hs:9:41, x)"
                 ,"(test/testdata/B.hs:9:53, test/testdata/B.hs:9:5, x)(test/testdata/B.hs:9:5, test/testdata/B.hs:9:5, x)"
                 ,"(test/testdata/B.hs:9:57-59, test/testdata/B.hs:9:37-39, foo)(test/testdata/B.hs:9:37-39, test/testdata/B.hs:9:37-39, foo)"
                 ,"(test/testdata/B.hs:9:61, test/testdata/B.hs:9:7, y)(test/testdata/B.hs:9:7, test/testdata/B.hs:9:7, y)"
                 ]

  -- -------------------------------------------------------------------

  describe "getName" $ do 
    it "gets a qualified Name at the top level" $ do
      -- ((_, renamed,_), _toks) <- parsedFileBGhc
      (t, _toks) <- parsedFileBGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let Just n = getName "B.foo'" renamed
      (GHC.showPpr n) `shouldBe` "B.foo'"
      (GHC.showPpr $ GHC.getSrcSpan n) `shouldBe` "test/testdata/B.hs:14:1-4"

    it "gets any instance of an unqualified Name" $ do
      -- ((_, renamed,_), _toks) <- parsedFileBGhc
      (t, _toks) <- parsedFileBGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let Just n = getName "foo" renamed
      (GHC.showPpr n) `shouldBe` "foo"
      (GHC.showPpr $ GHC.getSrcSpan n) `shouldBe` "test/testdata/B.hs:9:15-17"

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

    it "finds in a data decl" $ do
      -- ((_,Just renamed,_), _toks) <- parsedFileDd1Ghc
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
      -- ((_,renamed,_), _toks) <- parsedFileDeclareGhc
      (t, _toks) <- parsedFileDeclareGhc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let res = hsFreeAndDeclaredPNs renamed
          -- m = GHC.mkModule () (GHC.MkModuleName ""FreeAndDeclared.Declare")
      -- (GHC.showPpr $ map (\n -> (n, GHC.isSystemName n)) (fst res)) `shouldBe` "foo"
      -- (GHC.showPpr $ map (\n -> (n, GHC.isInternalName n)) (fst res)) `shouldBe` "foo" -- Seems to be from own source, non top-level
      -- (GHC.showPpr $ map (\n -> (n, GHC.isExternalName n)) (fst res)) `shouldBe` "foo" -- Exported somewhere?
      -- (GHC.showPpr $ map (\n -> (n, GHC.isWiredInName n)) (fst res)) `shouldBe` "foo" 
      -- (GHC.showPpr $ map (\n -> (n, GHC.nameIsLocalOrFrom m n)) (fst res)) `shouldBe` "foo" 
      (GHC.showPpr $ map (\n -> (n, GHC.nameModule_maybe n)) (fst res)) `shouldBe` "foo" 
{-
      (GHC.showPpr res)  `shouldBe` "([System.IO.getChar, GHC.Base.>>=, GHC.Base.fail,\n  System.IO.putStrLn, GHC.Base.return, a, b, y, GHC.Base.$,\n  GHC.List.head, GHC.List.zip, GHC.Num.fromInteger, GHC.Num.*,\n  FreeAndDeclared.Declare.c, x],\n"
      ++ " [FreeAndDeclared.Declare.main, a, FreeAndDeclared.Declare.unF, a,\n  b, FreeAndDeclared.Declare.unD, y, FreeAndDeclared.Declare.h,\n  FreeAndDeclared.Declare.t, FreeAndDeclared.Declare.d,\n  FreeAndDeclared.Declare.c, FreeAndDeclared.Declare.toplevel, x])"
-}

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

  describe "hsVisiblePNs" $ do
    it "Returns [] if e does not occur in t" $ do
      -- ((_,Just renamed,_parsed),_toks) <- parsedFileDd1Ghc
      (t,_toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just tl1  = locToExp (4,13) (4,40) renamed :: (Maybe (GHC.Located (GHC.HsExpr GHC.Name)))
      let Just tup = getName "DupDef.Dd1.tup" renamed
      let [decl] = definingDeclsNames [tup] (hsBinds renamed) False False
      (GHC.showPpr $ hsVisiblePNs tl1 tup) `shouldBe` "[]"

    it "Returns visible vars if e does occur in t" $ do
      -- ((_,Just renamed, parsed), toks) <- parsedFileDd1Ghc
      (t,_toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just tl1  = locToExp (14,1) (14,40) renamed :: (Maybe (GHC.Located (GHC.HsExpr GHC.Name)))
      let Just tup = getName "DupDef.Dd1.tup" renamed
      let [decl] = definingDeclsNames [tup] (hsBinds renamed) False False
      (GHC.showPpr $ hsVisiblePNs tl1 tup) `shouldBe` "foo"

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

  describe "mkNewName" $ do
    it "Creates a new GHC.Name" $ do
      let
        comp = do
         name1 <- mkNewName "foo"
         name2 <- mkNewName "bar"
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
         name1 <- mkNewName "foo"
         name2 <- mkNewName "bar"
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

      let declsr = getDecls renamed
      let Just (GHC.L _ n) = locToName dd1FileName (3, 1) renamed
      let
        comp = do
         _newName <- mkNewName "bar"
         newName2 <- mkNewName "bar2"
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

      let declsr = getDecls renamed
      let Just (GHC.L l n) = locToName dd1FileName (17, 5) renamed
      (GHC.showPpr n) `shouldBe` "ff"
      -- (GHC.showPpr declsr) `shouldBe` "loc"

      -- let Just (GHC.L _ n) = locToName dd1FileName (23, 5) renamed
      let
        comp = do
         newName2 <- mkNewName "gg"

         let
           declsToDup = definingDeclsNames [n] declsr True False
           funBinding = filter isFunOrPatBindR declsToDup     --get the fun binding.

         -- newBinding <- duplicateDecl declsr renamed n newName2

         -- return newBinding
         return (funBinding,declsToDup)
      ((nb,dd),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "ff"
      (GHC.showPpr dd) `shouldBe` "ff"
      (GHC.showPpr nb) `shouldBe` "ff"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module DupDef.Dd1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n "
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "ffff"
      (GHC.showPpr nb) `shouldBe` "[bar2_H3 x = DupDef.Dd1.c GHC.Num.* x]"


  -- ---------------------------------------------

  describe "addParamsToDecl" $ do
    it "Adds parameters to a declaration, and updates the token stream" $ do
      (t, toks) <- parsedFileMd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let declsr = getDecls renamed
      let Just (GHC.L _ n) = locToName md1FileName (3, 1) renamed
      let
        comp = do
         _newName <- mkNewName "bar"
         newName2 <- mkNewName "bar2"
         newBinding <- addParamsToDecls declsr n [newName2] True

         return newBinding
      (nb,s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "MoveDef.Md1.toplevel"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n "
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n  toplevel :: Integer -> Integer\n  toplevel bar2 x = c * x\n\n  c , d :: Integer\n  c = 7\n  d = 9\n\n -- Pattern bind\n  tup :: ( Int , Int )\n  h :: Int\n  t :: Int\n  tup @ ( h , t ) = head $ zip [ 1 .. 10 ] [ 3 .. ff ]\n   where\n      ff :: Int\n      ff = 15\n\n   data D = A | B String | C\n\n  ff :: Int -> Int\n  ff y = y + zz\n   where\n      zz = 1\n\n   l z =\n   let\n      ll = 34\n    in ll + z\n\n  dd q = do\n    let  ss = 5\n     return ( ss + q )\n\n   zz1 a = 1 + toplevel a\n\n "
      (GHC.showPpr $ last $ init nb) `shouldBe` "MoveDef.Md1.toplevel bar2 x = MoveDef.Md1.c GHC.Num.* x"

  -- ---------------------------------------------

  describe "rmDecl" $ do
    it "Removes a top level declaration, leaving type signature" $ do
      (t, toks) <- parsedFileMd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let declsr = getDecls renamed
      let Just (GHC.L _ n) = locToName md1FileName (22, 1) renamed
      let
        comp = do
         newDecls <- rmDecl n False declsr

         return newDecls
      (nb,s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "MoveDef.Md1.ff"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n "
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n\n\n\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n "
      (GHC.showPpr nb) `shouldBe` "[MoveDef.Md1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) },\n MoveDef.Md1.l z = let ll = 34 in ll GHC.Num.+ z,\n MoveDef.Md1.tup@(MoveDef.Md1.h, MoveDef.Md1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15,\n MoveDef.Md1.d = 9, MoveDef.Md1.c = 7,\n MoveDef.Md1.toplevel x = MoveDef.Md1.c GHC.Num.* x,\n MoveDef.Md1.zz1 a = 1 GHC.Num.+ MoveDef.Md1.toplevel a]"

    it "Removes a top level declaration, and type signature" $ do
      (t, toks) <- parsedFileMd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let declsr = getDecls renamed
      let Just (GHC.L _ n) = locToName md1FileName (22, 1) renamed
      let
        comp = do
         newDecls <- rmDecl n True declsr
         return newDecls
      (nb,s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "MoveDef.Md1.ff"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n "
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n\n\n\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n "
      (GHC.showPpr nb) `shouldBe` "[MoveDef.Md1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) },\n MoveDef.Md1.l z = let ll = 34 in ll GHC.Num.+ z,\n MoveDef.Md1.tup@(MoveDef.Md1.h, MoveDef.Md1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15,\n MoveDef.Md1.d = 9, MoveDef.Md1.c = 7,\n MoveDef.Md1.toplevel x = MoveDef.Md1.c GHC.Num.* x,\n MoveDef.Md1.zz1 a = 1 GHC.Num.+ MoveDef.Md1.toplevel a]"


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
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n "
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n "
      (GHC.showPpr nb) `shouldBe` "(MoveDef.Md1.toplevel ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.toplevel x = MoveDef.Md1.c GHC.Num.* x\n MoveDef.Md1.c, MoveDef.Md1.d :: GHC.Integer.Type.Integer\n MoveDef.Md1.c = 7\n MoveDef.Md1.d = 9\n MoveDef.Md1.tup :: (GHC.Types.Int, GHC.Types.Int)\n MoveDef.Md1.h :: GHC.Types.Int\n MoveDef.Md1.t :: GHC.Types.Int\n MoveDef.Md1.tup@(MoveDef.Md1.h, MoveDef.Md1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15\n MoveDef.Md1.ff y\n   = y GHC.Num.+ zz\n   where\n       zz = 1\n MoveDef.Md1.l z = let ll = 34 in ll GHC.Num.+ z\n MoveDef.Md1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) }\n MoveDef.Md1.zz1 a = 1 GHC.Num.+ MoveDef.Md1.toplevel a\n \n data MoveDef.Md1.D\n     = MoveDef.Md1.A | MoveDef.Md1.B GHC.Base.String | MoveDef.Md1.C,\n [import (implicit) Prelude],\n Nothing,\n Nothing)"
      -- (GHC.showPpr renamed) `shouldBe` ""

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
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n "
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n "
      (GHC.showPpr nb) `shouldBe` "(MoveDef.Md1.toplevel ::\n   GHC.Integer.Type.Integer -> GHC.Integer.Type.Integer\n MoveDef.Md1.toplevel x = MoveDef.Md1.c GHC.Num.* x\n MoveDef.Md1.c, MoveDef.Md1.d :: GHC.Integer.Type.Integer\n MoveDef.Md1.c = 7\n MoveDef.Md1.d = 9\n MoveDef.Md1.tup :: (GHC.Types.Int, GHC.Types.Int)\n MoveDef.Md1.h :: GHC.Types.Int\n MoveDef.Md1.t :: GHC.Types.Int\n MoveDef.Md1.tup@(MoveDef.Md1.h, MoveDef.Md1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff = 15\n MoveDef.Md1.ff :: GHC.Types.Int -> GHC.Types.Int\n MoveDef.Md1.ff y\n   = y GHC.Num.+ zz\n   where\n       zz = 1\n MoveDef.Md1.l z = let ll = 34 in ll GHC.Num.+ z\n MoveDef.Md1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) }\n MoveDef.Md1.zz1 a = 1 GHC.Num.+ MoveDef.Md1.toplevel a\n \n data MoveDef.Md1.D\n     = MoveDef.Md1.A | MoveDef.Md1.B GHC.Base.String | MoveDef.Md1.C,\n [import (implicit) Prelude],\n Nothing,\n Nothing)"
      -- (GHC.showPpr renamed) `shouldBe` ""
      

  -- ---------------------------------------------

  -- ---------------------------------------------

  describe "addDecl" $ do
    it "Adds a top level declaration" $ do
      (t, toks) <- parsedFileMd1Ghc
      let
        comp = do
         renamed <- getRefactRenamed
         nn <- mkNewName "nn"
         nn2 <- mkNewName "nn2"
         let newDecl = GHC.noLoc (GHC.VarBind nn (GHC.noLoc (GHC.HsVar nn2)) False)
         newDecls <- addDecl renamed Nothing ([newDecl],Nothing) True

         return newDecls
      (nb,s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      -- (GHC.showPpr n) `shouldBe` "MoveDef.Md1.ff"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n "
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module MoveDef.Md1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff :: Int -> Int\n\n\n\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n zz1 a = 1 + toplevel a\n\n "
      (GHC.showPpr nb) `shouldBe` "[MoveDef.Md1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) },\n MoveDef.Md1.l z = let ll = 34 in ll GHC.Num.+ z,\n MoveDef.Md1.tup@(MoveDef.Md1.h, MoveDef.Md1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15,\n MoveDef.Md1.d = 9, MoveDef.Md1.c = 7,\n MoveDef.Md1.toplevel x = MoveDef.Md1.c GHC.Num.* x,\n MoveDef.Md1.zz1 a = 1 GHC.Num.+ MoveDef.Md1.toplevel a]"

  -- ---------------------------------------------

  describe "renamePN" $ do
    it "Replace a Name with another, updating tokens" $ do
      (t, toks) <- parsedFileDd1Ghc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let declsr = getDecls renamed
      let Just (GHC.L l n) = locToName dd1FileName (3, 1) renamed
      let
        comp = do
         newName <- mkNewName "bar2"
         new <- renamePN n newName True declsr

         return (new,newName)
      let

      ((nb,nn),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule t toks }
      (GHC.showPpr n) `shouldBe` "DupDef.Dd1.toplevel"
      (showToks $ [newNameTok l nn]) `shouldBe` "[(((3,1),(3,9)),ITvarid \"bar2\",\"bar2\")]"
      (GHC.showRichTokenStream $ toks) `shouldBe` "module DupDef.Dd1 where\n\n toplevel :: Integer -> Integer\n toplevel x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n "
      (GHC.showRichTokenStream $ toksFromState s) `shouldBe` "module DupDef.Dd1 where\n\n toplevel :: Integer -> Integer\n bar2 x = c * x\n\n c,d :: Integer\n c = 7\n d = 9\n\n -- Pattern bind\n tup :: (Int, Int)\n h :: Int\n t :: Int\n tup@(h,t) = head $ zip [1..10] [3..ff]\n   where\n     ff :: Int\n     ff = 15\n\n data D = A | B String | C\n\n ff y = y + zz\n   where\n     zz = 1\n\n l z =\n   let\n     ll = 34\n   in ll + z\n\n dd q = do\n   let ss = 5\n   return (ss + q)\n\n "
      (GHC.showPpr nb) `shouldBe` "[DupDef.Dd1.dd q\n   = do { let ss = 5;\n          GHC.Base.return (ss GHC.Num.+ q) },\n DupDef.Dd1.l z = let ll = 34 in ll GHC.Num.+ z,\n DupDef.Dd1.ff y\n   = y GHC.Num.+ zz\n   where\n       zz = 1,\n DupDef.Dd1.tup@(DupDef.Dd1.h, DupDef.Dd1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15,\n DupDef.Dd1.d = 9, DupDef.Dd1.c = 7,\n bar2 x = DupDef.Dd1.c GHC.Num.* x]"


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

         let declsr = getDecls parentr
             duplicatedDecls = definingDeclsNames [n] declsr True False

             -- res = findEntity ln duplicatedDecls
             res = findEntity' ln duplicatedDecls

         return (res,duplicatedDecls,ln)
      ((r,d,l),_s) <- runRefactGhcState comp
      (GHC.showPpr d) `shouldBe` "[DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x]"
      -- (show l) `shouldBe` "foo"
      (show r) `shouldBe` "foo"

    it "Returns false if a syntax phrase is not part of another" $ do
      let
        comp = do

         -- ((_,Just parentr,_parsed),_toks) <- parseSourceFileGhc "./test/testdata/DupDef/Dd1.hs"
         (t, toks) <- parseSourceFileGhc "./test/testdata/DupDef/Dd1.hs"
         putParsedModule t toks
         parentr <- getRefactRenamed

         let mn = locToName (GHC.mkFastString "./test/testdata/DupDef/Dd1.hs") (4,1) parentr
         let (Just (ln@(GHC.L _ n))) = mn

         let declsr = getDecls parentr
             duplicatedDecls = definingDeclsNames [n] declsr True False

             res = findEntity ln duplicatedDecls
             -- res = findEntity' ln duplicatedDecls

         return (res,duplicatedDecls,ln)
      ((r,d,l),_s) <- runRefactGhcState comp
      (GHC.showPpr d) `shouldBe` "[DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x]"
      -- (show l) `shouldBe` "foo"
      (show r) `shouldBe` "foo"


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
         n1   <- mkNewName "n1"
         n2   <- mkNewName "n2"
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
         n1   <- mkNewName "n1"
         n2   <- mkNewName "n2"
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
          let res = getDeclAndToks n True toks renamed
          return (res,n,name)

      (((d,t),n1,n2),s) <- runRefactGhcState comp 
      (GHC.showPpr n1) `shouldBe` "MoveDef.Md1.tlFunc"
      (GHC.showPpr d) `shouldBe` "[MoveDef.Md1.tlFunc x = MoveDef.Md1.c GHC.Num.* x]"
      (show $ getStartEndLoc d) `shouldBe` "((40,1),(40,17))"
      (show $ startEndLocIncComments (toksFromState s) d) `shouldBe` "((40,1),(40,17))"
      (showToks t) `shouldBe` "[(((40,1),(40,1)),ITsemi,\"\"),(((40,1),(40,7)),ITvarid \"tlFunc\",\"tlFunc\"),(((40,8),(40,9)),ITvarid \"x\",\"x\"),(((40,10),(40,11)),ITequal,\"=\"),(((40,12),(40,13)),ITvarid \"c\",\"c\"),(((40,14),(40,15)),ITstar,\"*\"),(((40,16),(40,17)),ITvarid \"x\",\"x\")]"

  -- ---------------------------------------
myShow :: GHC.RdrName -> String
myShow n = case n of
  GHC.Unqual on  -> ("Unqual:" ++ (GHC.showPpr on))
  GHC.Qual ms on -> ("Qual:" ++ (GHC.showPpr ms) ++ ":" ++ (GHC.showPpr on))
  GHC.Orig ms on -> ("Orig:" ++ (GHC.showPpr ms) ++ ":" ++ (GHC.showPpr on))
  GHC.Exact en   -> ("Exact:" ++ (GHC.showPpr en))



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

parsedFileDd2Ghc :: IO (ParseResult,[PosToken])
parsedFileDd2Ghc = parsedFileGhc "./test/testdata/DupDef/Dd2.hs"

parsedFileDeclareGhc :: IO (ParseResult,[PosToken])
parsedFileDeclareGhc = parsedFileGhc "./test/testdata/FreeAndDeclared/Declare.hs"

parsedFileDeclare1Ghc :: IO (ParseResult,[PosToken])
parsedFileDeclare1Ghc = parsedFileGhc "./test/testdata/FreeAndDeclared/Declare1.hs"

parsedFileDeclare2Ghc :: IO (ParseResult,[PosToken])
parsedFileDeclare2Ghc = parsedFileGhc "./test/testdata/FreeAndDeclared/Declare2.hs"

parsedFileMd1Ghc :: IO (ParseResult,[PosToken])
parsedFileMd1Ghc = parsedFileGhc "./test/testdata/MoveDef/Md1.hs"

md1FileName :: GHC.FastString
md1FileName = GHC.mkFastString "./test/testdata/MoveDef/Md1.hs"

-- ----------------------------------------------------

-- Runners

-- t = withArgs ["--match", "hsFreeAndDeclaredPNs"] main
-- t = withArgs ["--match", "allNames"] main
-- t = withArgs ["--match", "definingDeclsNames"] main

-- t = withArgs ["--match", "getName"] main



