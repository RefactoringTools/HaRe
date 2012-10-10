module TypeUtilsSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import           TestUtils

import qualified FastString as GHC
import qualified GHC        as GHC
import qualified GhcMonad   as GHC
import qualified Name       as GHC
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
      show res `shouldBe`  "[(PNT test/testdata/B.hs:7:1-3 foo),(PNT test/testdata/B.hs:7:5 x),(PNT test/testdata/B.hs:7:13-15 odd),(PNT test/testdata/B.hs:7:17 x),(PNT test/testdata/B.hs:9:1-3 bob),(PNT test/testdata/B.hs:9:5 x),(PNT test/testdata/B.hs:9:7 y),(PNT test/testdata/B.hs:9:15-17 foo),(PNT test/testdata/B.hs:9:19 x),(PNT test/testdata/B.hs:9:23 x),(PNT test/testdata/B.hs:9:25 +),(PNT test/testdata/B.hs:9:37-39 foo),(PNT test/testdata/B.hs:9:41 x),(PNT test/testdata/B.hs:9:45 x),(PNT test/testdata/B.hs:9:46 +),(PNT test/testdata/B.hs:9:53 x),(PNT test/testdata/B.hs:9:55 +),(PNT test/testdata/B.hs:9:57-59 foo),(PNT test/testdata/B.hs:9:61 y),(PNT test/testdata/B.hs:11:9-11 foo),(PNT test/testdata/B.hs:11:13 x),(PNT test/testdata/B.hs:11:17 x),(PNT test/testdata/B.hs:11:19 +),(PNT test/testdata/B.hs:14:1-4 foo'),(PNT test/testdata/B.hs:14:6 x),(PNT test/testdata/B.hs:14:16-18 odd),(PNT test/testdata/B.hs:14:20 x),(PNT test/testdata/B.hs:15:3-6 True),(PNT test/testdata/B.hs:16:3-7 False),(PNT test/testdata/B.hs:18:1-4 main),(PNT test/testdata/B.hs:19:3-10 putStrLn),(PNT test/testdata/B.hs:19:12 $),(PNT test/testdata/B.hs:19:14-17 show),(PNT test/testdata/B.hs:19:19 $),(PNT test/testdata/B.hs:19:22-24 foo),(PNT test/testdata/B.hs:19:29 +),(PNT test/testdata/B.hs:19:31-35 C.baz),(PNT test/testdata/B.hs:21:1-4 mary),(PNT test/testdata/B.hs:23:1 h),(PNT test/testdata/B.hs:23:3 z),(PNT test/testdata/B.hs:23:7-9 bob),(PNT test/testdata/B.hs:23:11 z),(PNT test/testdata/B.hs:25:6 D),(PNT test/testdata/B.hs:25:10 A),(PNT test/testdata/B.hs:25:14 B),(PNT test/testdata/B.hs:25:25 C),(PNT test/testdata/B.hs:27:1-7 subdecl),(PNT test/testdata/B.hs:27:9 x),(PNT test/testdata/B.hs:27:13-14 zz),(PNT test/testdata/B.hs:27:16 x),(PNT test/testdata/B.hs:29:5-6 zz),(PNT test/testdata/B.hs:29:8 n),(PNT test/testdata/B.hs:29:12 n),(PNT test/testdata/B.hs:29:14 +)]"

 
  -- -------------------------------------------------------------------

  describe "locToName" $ do
    it "returns a GHC.Name for a given source location, if it falls anywhere in an identifier" $ do
      ((_,renamed,_), _toks) <- parsedFileBGhc
      let Just (res@(GHC.L l n)) = locToName bFileName (7,3) renamed
      GHC.showPpr l `shouldBe` "test/testdata/B.hs:7:1-3"
      getLocatedStart res `shouldBe` (7,1)
      GHC.showPpr n `shouldBe` "B.foo"

    it "returns a pnt for a given source location, if it falls anywhere in an identifier #2" $ do
      modInfo@((_, renamed,_),_toks) <- parsedFileBGhc
      let Just (res@(GHC.L l n)) = locToName bFileName (23,8) renamed
      GHC.showPpr n `shouldBe` "B.bob"
      GHC.showPpr l `shouldBe` "test/testdata/B.hs:23:7-9"
      getLocatedStart res `shouldBe` (23,7)

    it "returns Nothing for a given source location, if it does not fall in an identifier" $ do
      modInfo@((_, renamed,_),_toks) <- parsedFileBGhc
      let res = locToName bFileName (7,7) renamed
      res `shouldBe` Nothing

  -- -------------------------------------------------------------------

  describe "allNames" $ do 
    it "lists all Names" $ do
      ((_, renamed,_), _toks) <- parsedFileBGhc
      let res = allNames bFileName (7,6) renamed
      -- let res' = map (\(GHC.L l n) -> (GHC.showPpr $ GHC.nameUnique n,GHC.showPpr (l, n))) res
      let res' = map (\(GHC.L l n) -> (GHC.showPpr $ GHC.nameUnique n,GHC.showPpr (l, GHC.getSrcSpan n, n))) res

      -- Map.insertWith :: Ord k => (a -> a -> a) -> k -> a -> Map k a -> Map k a
      let res'' = foldl' (\m (k,a) -> Map.insertWith (++) k a m) Map.empty res'

      (sort $ Map.elems res'') `shouldBe` 
                 ["(test/testdata/B.hs:11:17, x)(test/testdata/B.hs:11:13, x)"
                 ,"(test/testdata/B.hs:11:9-11, foo)"
                 ,"(test/testdata/B.hs:14:1-4, B.foo')"
                 ,"(test/testdata/B.hs:14:20, x)(test/testdata/B.hs:14:6, x)"
                 ,"(test/testdata/B.hs:15:3-6, GHC.Types.True)"
                 ,"(test/testdata/B.hs:16:3-7, GHC.Types.False)"
                 ,"(test/testdata/B.hs:18:1-4, B.main)"
                 ,"(test/testdata/B.hs:19:14-17, GHC.Show.show)"
                 ,"(test/testdata/B.hs:19:19, GHC.Base.$)(test/testdata/B.hs:19:12, GHC.Base.$)"
                 ,"(test/testdata/B.hs:19:22-24, B.foo)(test/testdata/B.hs:7:1-3, B.foo)"
                 ,"(test/testdata/B.hs:19:29, GHC.Num.+)(test/testdata/B.hs:11:19, GHC.Num.+)"
                    ++"(test/testdata/B.hs:9:55, GHC.Num.+)(test/testdata/B.hs:9:46, GHC.Num.+)"
                    ++"(test/testdata/B.hs:9:25, GHC.Num.+)(test/testdata/B.hs:29:14, GHC.Num.+)"
                 ,"(test/testdata/B.hs:19:3-10, System.IO.putStrLn)"
                 ,"(test/testdata/B.hs:19:31-35, C.baz)"
                 ,"(test/testdata/B.hs:21:1-4, B.mary)"
                 ,"(test/testdata/B.hs:23:1, B.h)"
                 ,"(test/testdata/B.hs:23:11, z)(test/testdata/B.hs:23:3, z)"
                 ,"(test/testdata/B.hs:23:7-9, B.bob)(test/testdata/B.hs:9:1-3, B.bob)"
                 ,"(test/testdata/B.hs:25:10, B.A)"
                 ,"(test/testdata/B.hs:25:14, B.B)"
                 ,"(test/testdata/B.hs:25:25, B.C)"
                 ,"(test/testdata/B.hs:25:6, B.D)"
                 ,"(test/testdata/B.hs:27:1-7, B.subdecl)"
                 ,"(test/testdata/B.hs:27:16, x)(test/testdata/B.hs:27:9, x)"
                 ,"(test/testdata/B.hs:29:12, n)(test/testdata/B.hs:29:8, n)"
                 ,"(test/testdata/B.hs:29:5-6, zz)(test/testdata/B.hs:27:13-14, zz)"
                 ,"(test/testdata/B.hs:7:13-15, GHC.Real.odd)(test/testdata/B.hs:14:16-18, GHC.Real.odd)"
                 ,"(test/testdata/B.hs:7:17, x)(test/testdata/B.hs:7:5, x)"
                 ,"(test/testdata/B.hs:9:15-17, foo)"
                 ,"(test/testdata/B.hs:9:23, x)(test/testdata/B.hs:9:19, x)"
                 ,"(test/testdata/B.hs:9:45, x)(test/testdata/B.hs:9:41, x)"
                 ,"(test/testdata/B.hs:9:53, x)(test/testdata/B.hs:9:5, x)"
                 ,"(test/testdata/B.hs:9:57-59, foo)(test/testdata/B.hs:9:37-39, foo)"
                 ,"(test/testdata/B.hs:9:61, y)(test/testdata/B.hs:9:7, y)"
                 ]


  -- -------------------------------------------------------------------

  describe "getName" $ do 
    it "gets a qualified Name at the top level" $ do
      ((_, renamed,_), _toks) <- parsedFileBGhc
      let Just n = getName "B.foo'" renamed
      (GHC.showPpr n) `shouldBe` "B.foo'"
      (GHC.showPpr $ GHC.getSrcSpan n) `shouldBe` "test/testdata/B.hs:14:1-4"

    it "gets any instance of an unqualified Name" $ do
      ((_, renamed,_), _toks) <- parsedFileBGhc
      let Just n = getName "foo" renamed
      (GHC.showPpr n) `shouldBe` "foo"
      (GHC.showPpr $ GHC.getSrcSpan n) `shouldBe` "test/testdata/B.hs:9:15-17"

    it "returns Nothing if the Name is not found" $ do
      ((_, renamed,_), _toks) <- parsedFileBGhc
      let res = getName "baz" renamed
      (GHC.showPpr res) `shouldBe` "Nothing"


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
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let res = definingDecls [(PN (mkRdrName "tup"))] ds False False
      GHC.showPpr res `shouldBe` "[tup@(h, t) = head $ zip [1 .. 10] [3 .. 15]]"

    it "finds in a patbind, with type signature" $ do
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let res = definingDecls [(PN (mkRdrName "tup"))] ds True False
      GHC.showPpr res `shouldBe` "[tup :: (Int, Int), tup@(h, t) = head $ zip [1 .. 10] [3 .. 15]]"

    it "finds in a data decl" $ do
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
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
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let res = definingDecls [(PN (mkRdrName "zz"))] ds False False
      GHC.showPpr res `shouldBe` "[]"

  -- -------------------------------------------------------------------

  describe "definingDeclsNames" $ do
    it "returns [] if not found" $ do
      ((_,renamed,_), _toks) <- parsedFileDd1Ghc
      let Just ((GHC.L _ n)) = locToName dd1FileName (16,6) renamed
      let res = definingDeclsNames [n] renamed False False
      GHC.showPpr res `shouldBe` "[]"

    it "finds declarations at the top level" $ do
      ((_,renamed,_), _toks) <- parsedFileDd1Ghc
      let Just (GHC.L _ n) = locToName dd1FileName (3,3) renamed
      let res = definingDeclsNames [n] renamed False False
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
      ((_,renamed,_), _toks) <- parsedFileDd1Ghc
      let Just (GHC.L _ n) = locToName dd1FileName (14,1) renamed
      let res = definingDeclsNames [n] renamed False False
      GHC.showPpr res `shouldBe` "[DupDef.Dd1.tup@(DupDef.Dd1.h, DupDef.Dd1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. 15]]"


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
      ((_,renamed,_), _toks) <- parsedFileDd1Ghc
      let Just (GHC.L _ n) = locToName dd1FileName (16,6) renamed
      let res = definingDeclsNames [n] renamed False False
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

  describe "isFunBind" $ do
    it "Returns False if not a function definition" $ do
      modInfo@((_, renamed, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      -- let [decl] = definingDecls [(PN (mkRdrName "tup"))] ds False False
      let Just tup = getName "DupDef.Dd1.tup" renamed
      let [decl] = definingDeclsNames [tup] renamed False False
      isFunBind decl  `shouldBe` False

    it "Returns True if a function definition" $ do
      modInfo@((_, renamed, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDd1Ghc
      let Just toplevel = getName "DupDef.Dd1.toplevel" renamed
      let [decl] = definingDeclsNames [toplevel] renamed False False
      isFunBind decl  `shouldBe` True

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
    {-
    it "Finds declared HsVar" $ do
      let 
          comp = do
            modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDeclareGhc
            r <- hsFreeAndDeclaredPNs mod
            return r
      (res,s) <- runRefactGhcState comp
      (GHC.showPpr res)  `shouldBe` "foo"
    -}
    it "Finds declared HsVar" $ do
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- parsedFileDeclareGhc
      res <- hsFreeAndDeclaredPNs mod
      (show res)  `shouldBe` "foo"


  -- ---------------------------------------------------------------------

  describe "hsFDsFromInside" $ do
    it "does something useful" $ do
      pending "Complete this"

  describe "hsFDNamesFromInside" $ do
    it "does something useful" $ do
      pending "Complete this"

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
      GHC.showPpr n1 `shouldBe` "foo_C2"
      GHC.getOccString n2 `shouldBe` "bar"
      GHC.showPpr n2 `shouldBe` "bar_C3"


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

parsedFileDeclareGhc :: IO (ParseResult,[PosToken])
parsedFileDeclareGhc = parsedFileGhc "./test/testdata/FreeAndDeclared/Declare.hs"

-- ----------------------------------------------------

-- Runners

-- t = withArgs ["--match", "hsFreeAndDeclaredPNs"] main
-- t = withArgs ["--match", "allNames"] main
-- t = withArgs ["--match", "definingDeclsNames"] main

t = withArgs ["--match", "getName"] main



