{-# LANGUAGE CPP #-}
module TypeUtilsSpec (main, spec) where

import           Test.Hspec

import           TestUtils

import qualified GHC.SYB.Utils         as SYB

import qualified GHC        as GHC
import qualified GhcMonad   as GHC
import qualified Name       as GHC
import qualified RdrName    as GHC
import qualified Module     as GHC

import Data.Maybe

import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Parsers
import Language.Haskell.GHC.ExactPrint.Types

import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TypeUtils
import Language.Haskell.Refact.Utils.Utils
import Language.Haskell.Refact.Utils.Variables

import Data.List

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do

  -- -------------------------------------------------------------------
{-
  describe "findAllNameOccurences" $ do
   it "finds all occurrences of the given name in a syntax phrase" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/S.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (4,5) parsed
      (showGhcQual n) `shouldBe` "x"

      let res = findAllNameOccurences n renamed
      (showGhcQual res) `shouldBe` "[x, x]"
      -- NOTE: does not get the x's in line 8
      (showGhcQual $ map startEndLocGhc res) `shouldBe` "[((4, 5), (4, 6)), ((4, 17), (4, 18))]"
-}
  -- -------------------------------------------------------------------

  describe "locToName" $ do
    it "returns a GHC.Name for a given source location, if it falls anywhere in an identifier #1" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/B.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just (res'@(GHC.L l _)) = locToRdrName (7,3) parsed
          n = rdrName2NamePure nm res'
          res = GHC.L l n
      showGhcQual l `shouldBe` "TypeUtils/B.hs:7:1-3"
      getLocatedStart res `shouldBe` (7,1)
      showGhcQual n `shouldBe` "TypeUtils.B.foo"

    -- ---------------------------------

    it "returns a GHC.Name for a given source location, if it falls anywhere in an identifier #2" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/B.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just (res'@(GHC.L l _)) = locToRdrName (25,8) parsed
          n = rdrName2NamePure nm res'
          res = GHC.L l n
      showGhcQual n `shouldBe` "TypeUtils.B.bob"
      showGhcQual l `shouldBe` "TypeUtils/B.hs:25:7-9"
      getLocatedStart res `shouldBe` (25,7)

    -- ---------------------------------

    it "returns Nothing for a given source location, if it does not fall in an identifier" $ do
      t <- ct $ parsedFileGhc "TypeUtils/B.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let res = locToNameRdrPure nm (7,7) parsed
      (showGhcQual res) `shouldBe` "Nothing"

    -- ---------------------------------

    it "gets a short name too" $ do
      t <- ct $ parsedFileGhc "./Demote/WhereIn2.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just (res'@(GHC.L l _)) = locToRdrName (14,1) parsed
          n = rdrName2NamePure nm res'
          res = GHC.L l n
      showGhcQual n `shouldBe` "Demote.WhereIn2.sq"
      showGhcQual l `shouldBe` "Demote/WhereIn2.hs:14:1-2"
      getLocatedStart res `shouldBe` (14,1)

    -- ---------------------------------

    it "gets a type variable name" $ do
      t <- ct $ parsedFileGhc "./Renaming/ConstructorIn3.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just (res'@(GHC.L l _)) = locToRdrName (9,12) parsed
          n = rdrName2NamePure nm res'
          res = GHC.L l n
      showGhcQual n `shouldBe` "a"
      -- Note: loc does not line up due to multiple matches in FunBind
      showGhcQual l `shouldBe` "Renaming/ConstructorIn3.hs:9:12"
      getLocatedStart res `shouldBe` (9,12)

    -- ---------------------------------

    it "gets an instance class name" $ do
      t <- ct $ parsedFileGhc "./Renaming/ClassIn3.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just (res'@(GHC.L l _)) = locToRdrName (16,10) parsed
          n = rdrName2NamePure nm res'
          res = GHC.L l n
      showGhcQual n `shouldBe` "GHC.Classes.Eq"
      showGhcQual l `shouldBe` "Renaming/ClassIn3.hs:16:10-11"
      getLocatedStart res `shouldBe` (16,10)

  -- -------------------------------------------------------------------

  describe "locToRdrName" $ do
    it "returns a GHC.RdrName for a given source location, if it falls anywhere in an identifier" $ do
      t <- ct $ parsedFileGhc "./Renaming/D5.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let Just (res@(GHC.L l n)) = locToRdrName (20,1) parsed
      (show $ ss2span l) `shouldBe` "((20,1),(20,11))"
      getLocatedStart res `shouldBe` (20,1)
      showGhcQual n `shouldBe` "sumSquares"

    it "returns a GHC.RdrName for a source location, in a MatchGroup" $ do
      t <- ct $ parsedFileGhc "./LocToName.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let Just (res@(GHC.L l n)) = locToRdrName (24,2) parsed
      showGhcQual n `shouldBe` "sumSquares"
      getLocatedStart res `shouldBe` (24,1)
      showGhcQual l `shouldBe` "LocToName.hs:24:1-10"

  -- -------------------------------------------------------------------

  describe "getName" $ do
    it "gets a qualified Name at the top level" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/B.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let Just n = getName "TypeUtils.B.foo'" renamed
      (showGhcQual n) `shouldBe` "TypeUtils.B.foo'"
      (showGhcQual $ GHC.getSrcSpan n) `shouldBe` "TypeUtils/B.hs:14:1-4"

    it "gets any instance of an unqualified Name" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/B.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let Just n = getName "foo" renamed
      (showGhcQual n) `shouldBe` "foo"
      (showGhcQual $ GHC.getSrcSpan n) `shouldBe` "TypeUtils/B.hs:9:15-17"

    it "returns Nothing if the Name is not found" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/B.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let res = getName "baz" renamed
      (showGhcQual res) `shouldBe` "Nothing"

  -- -------------------------------------------------------------------

  describe "definingDeclsRdrNames" $ do
    it "returns [] if not found" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let nm = initRdrNameMap t
      let Just n = locToNameRdrPure nm (16,6) parsed
      let decls = GHC.hsmodDecls $ GHC.unLoc parsed
      let res = definingDeclsRdrNames nm [n] decls False False
      showGhcQual res `shouldBe` "[]"

    -- ---------------------------------

    it "finds declarations at the top level" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (3,3) parsed
      let decls = GHC.hsmodDecls $ GHC.unLoc parsed
      let res = definingDeclsRdrNames nm [n] decls False False
      showGhcQual res `shouldBe` "[toplevel x = c * x]"

    -- ---------------------------------

    it "finds declarations not at the top level 1" $ do
      t <- ct $ parsedFileGhc "./LiftToToplevel/WhereIn6.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (13,29) parsed
      let decls = GHC.hsmodDecls $ GHC.unLoc parsed
      let res = definingDeclsRdrNames nm [n] decls False True
      showGhcQual n `shouldBe` "pow"
      showGhcQual res `shouldBe` "[pow = 2]"

    -- ---------------------------------

    it "finds declarations not at the top level 2" $ do
      t <- ct $ parsedFileGhc "./LiftToToplevel/LetIn1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (11,22) parsed
      let decls = GHC.hsmodDecls $ GHC.unLoc parsed
      let res = definingDeclsRdrNames nm [n] decls False True
      showGhcQual n `shouldBe` "sq"
      showGhcQual res `shouldBe` "[sq 0 = 0\n sq z = z ^ pow]"

    -- ---------------------------------

    it "finds in a patbind" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (14,1) parsed
      let decls = GHC.hsmodDecls $ GHC.unLoc parsed
      let res = definingDeclsRdrNames nm [n] decls False False
      showGhcQual res `shouldBe` "[tup@(h, t)\n   = head $ zip [1 .. 10] [3 .. ff]\n   where\n       ff :: Int\n       ff = 15]"

    -- ---------------------------------

    it "finds recursively in sub-binds" $ do
      {-
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let res = definingDecls [(PN (mkRdrName "zz"))] ds False True
      showGhcQual res `shouldBe` "[zz n = n + 1]" -- TODO: Currently fails, will come back to it
      -}
      pending -- "Currently fails, will come back to it"

    -- ---------------------------------

    it "only finds recursively in sub-binds if asked" $ do
      {-
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let res = definingDecls [(PN (mkRdrName "zz"))] ds False False
      showGhcQual res `shouldBe` "[]"
      -}
      pending -- "Convert to definingDeclsNames"

  -- -------------------------------------------------------------------
{-
  describe "definingDeclsNames" $ do
    it "returns [] if not found" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (16,6) parsed
      let res = definingDeclsNames [n] (hsBinds renamed) False False
      showGhcQual res `shouldBe` "[]"

    it "finds declarations at the top level" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (3,3) parsed
      let res = definingDeclsNames [n] (hsBinds renamed) False False
      showGhcQual res `shouldBe` "[DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x]"


    it "finds in a patbind" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (14,1) parsed
      let res = definingDeclsNames [n] (hsBinds renamed) False False
      showGhcQual res `shouldBe` "[DupDef.Dd1.tup@(DupDef.Dd1.h, DupDef.Dd1.t)\n   = GHC.List.head GHC.Base.$ GHC.List.zip [1 .. 10] [3 .. ff]\n   where\n       ff :: GHC.Types.Int\n       ff = 15]"


    it "finds recursively in sub-binds" $ do
      {-
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let res = definingDecls [(PN (mkRdrName "zz"))] ds False True
      showGhcQual res `shouldBe` "[zz n = n + 1]" -- TODO: Currently fails, will come back to it
      -}
      pending -- "Currently fails, will come back to it"

    it "only finds recursively in sub-binds if asked" $ do
      {-
      modInfo@((_, _, mod@(GHC.L l (GHC.HsModule name exps imps ds _ _))), toks) <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let res = definingDecls [(PN (mkRdrName "zz"))] ds False False
      showGhcQual res `shouldBe` "[]"
      -}
      pending -- "Convert to definingDeclsNames"
-}
  -- -------------------------------------------------------------------

  describe "definingSigsRdrNames" $ do
    it "returns [] if not found" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (21,1) parsed
      showGhcQual n `shouldBe` "DupDef.Dd1.ff"
      let res = definingSigsRdrNames nm [n] parsed
      showGhcQual res `shouldBe` "[]"

    -- ---------------------------------

    it "finds signatures at the top level" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (4,1) parsed
      showGhcQual n `shouldBe` "DupDef.Dd1.toplevel"
      let res = definingSigsRdrNames nm [n] parsed
      showGhcQual res `shouldBe` "[toplevel :: Integer -> Integer]"

    -- ---------------------------------

    it "returns only the single signature where there are others too" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (7,1) parsed
      showGhcQual n `shouldBe` "DupDef.Dd1.c"
      let res = definingSigsRdrNames nm [n] parsed
      showGhcQual res `shouldBe`  "[c :: Integer]"

    -- ---------------------------------

    it "finds signatures at lower levels" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (16,5) parsed
      showGhcQual n `shouldBe` "ff"
      let res = definingSigsRdrNames nm [n] parsed
      showGhcQual res `shouldBe` "[ff :: Int]"

    -- ---------------------------------

    it "finds multiple signatures 1" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let nm = initRdrNameMap t

      let Just n1 = locToNameRdrPure nm (21,1) parsed
      showGhcQual n1 `shouldBe` "DupDef.Dd1.ff"

      let Just n2 = locToNameRdrPure nm (16,5) parsed
      showGhcQual n2 `shouldBe` "ff"

      let Just n3 = locToNameRdrPure nm (4,1) parsed
      showGhcQual n3 `shouldBe` "DupDef.Dd1.toplevel"

      let res = definingSigsRdrNames nm [n1,n2,n3] parsed
      showGhcQual res `shouldBe` "[toplevel :: Integer -> Integer, ff :: Int]"

    -- ---------------------------------

    it "finds multiple signatures 2" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let nm = initRdrNameMap t

      let Just n1 = locToNameRdrPure nm (14,1) parsed
      showGhcQual n1 `shouldBe` "DupDef.Dd1.tup"

      let Just n2 = locToNameRdrPure nm (14,6) parsed
      showGhcQual n2 `shouldBe` "DupDef.Dd1.h"

      let Just n3 = locToNameRdrPure nm (14,8) parsed
      showGhcQual n3 `shouldBe` "DupDef.Dd1.t"

      let res = definingSigsRdrNames nm [n1,n2,n3] parsed
      showGhcQual res `shouldBe` "[tup :: (Int, Int), h :: Int, t :: Int]"

  -- -------------------------------------------------------------------

  describe "definingTyClDeclsNames" $ do
    it "returns [] if not found" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/TyClDecls.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (10,29) parsed
      let res = definingTyClDeclsNames nm [n] parsed
      showGhcQual res `shouldBe` "[]"

    -- ---------------------------------

    it "finds foreign type declarations" $ do
      pending

    -- ---------------------------------

    it "finds family declarations" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/TyClDecls.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      -- putStrLn $ "parsed:" ++ SYB.showData SYB.Parser 0 parsed

      let Just n = locToNameRdrPure nm (7,14) parsed
      let res = definingTyClDeclsNames nm [n] parsed
      showGhcQual res `shouldBe` "[data family XList a]"

    -- ---------------------------------

    it "finds data declarations" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/TyClDecls.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (12,6) parsed
      let res = definingTyClDeclsNames nm [n] parsed
      (unspace $ showGhcQual res) `shouldBe` "[data Foo = Foo Int]"

    -- ---------------------------------

    it "finds type declarations" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/TyClDecls.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (14,6) parsed
      let res = definingTyClDeclsNames nm [n] parsed
      showGhcQual res `shouldBe` "[type Foo2 = String]"

    -- ---------------------------------

    it "finds class declarations" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/TyClDecls.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (16,7) parsed
      let res = definingTyClDeclsNames nm [n] parsed
      showGhcQual res `shouldBe` "[class Bar a where\n   bar :: a -> Bool]"

    -- ---------------------------------

    it "finds multiple declarations" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/TyClDecls.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n1 = locToNameRdrPure nm (14,6) parsed
      let Just n2 = locToNameRdrPure nm (16,7) parsed
      let res = definingTyClDeclsNames nm [n1,n2] parsed
      showGhcQual res `shouldBe` "[type Foo2 = String,\n class Bar a where\n   bar :: a -> Bool]"


  -- -------------------------------------------------------------------

  describe "isFunBindR" $ do
    it "Returns False if not a function definition" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let decls = getHsDecls parsed
      let Just tup = getName "DupDef.Dd1.tup" renamed
      let [GHC.L l (GHC.ValD decl)] = definingDeclsRdrNames nm [tup] decls False False
      isFunBindR (GHC.L l decl)  `shouldBe` False

    it "Returns True if a function definition" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let (GHC.L _l (GHC.HsModule _name _exps _imps _ds _ _)) = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just toplevel = getName "DupDef.Dd1.toplevel" renamed
      let [GHC.L l (GHC.ValD decl)] = definingDeclsRdrNames nm [toplevel] (getHsDecls parsed) False False
      isFunBindR (GHC.L l decl)  `shouldBe` True

  -- -------------------------------------------------------------------

  describe "isFunOrPatName" $ do
    it "return True if a PName is a function/pattern name defined in t" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let renamed  = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      -- putStrLn $ "parsed:\n" ++ SYB.showData SYB.Parser 0 parsed
      let Just tup = getName "DupDef.Dd1.tup" renamed
      (showGhcQual tup) `shouldBe` "DupDef.Dd1.tup"
      isFunOrPatName nm tup parsed  `shouldBe` True

    -- ---------------------------------

    it "return False if a PName is a function/pattern name defined in t" $ do
      t  <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      t2 <- ct $ parsedFileGhc "./DupDef/Dd2.hs"
      let renamed  = fromJust $ GHC.tm_renamed_source t
      let parsed2 = GHC.pm_parsed_source $ GHC.tm_parsed_module t2
          nm2 = initRdrNameMap t2

      let Just tup = getName "DupDef.Dd1.tup" renamed
      isFunOrPatName nm2 tup parsed2  `shouldBe` False


  -- -------------------------------------------------------------------

  describe "hsFreeAndDeclaredXXXX" $ do

    it "finds declared in type class definitions" $ do
      t <- ct $ parsedFileGhc "./FreeAndDeclared/DeclareTypes.hs"

      let
        comp = do
          parsed <- getRefactParsed
          decls <- liftT $ hsDecls parsed
          tdss <- mapM getDeclaredTypesRdr decls
          let tds = nub $ concat tdss
          return (tds)
      ((res),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((res),_s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (res)) `shouldBe`
          "[(FreeAndDeclared.DeclareTypes.XList, (8, 1)),\n"++
          " (FreeAndDeclared.DeclareTypes.X, (19, 1)),\n"++
          " (FreeAndDeclared.DeclareTypes.Y, (19, 10)),\n"++
          " (FreeAndDeclared.DeclareTypes.Z, (19, 22)),\n"++
          " (FreeAndDeclared.DeclareTypes.W, (19, 26)),\n"++
          " (FreeAndDeclared.DeclareTypes.Foo, (21, 1)),\n"++
          " (FreeAndDeclared.DeclareTypes.Bar, (23, 1)),\n"++
          " (FreeAndDeclared.DeclareTypes.doBar, (27, 3)),\n"++
          " (FreeAndDeclared.DeclareTypes.BarVar, (24, 3)),\n"++
          " (FreeAndDeclared.DeclareTypes.BarData, (25, 3))]"

    -- ---------------------------------

    it "finds declared HsVar" $ do
      t <- ct $ parsedFileGhc "./FreeAndDeclared/Declare.hs"
      let
        comp = do
          parsed <- getRefactParsed
          nm <- getRefactNameMap
          logDataWithAnns "parsed:"  parsed
          let rr = hsFreeAndDeclaredRdr nm parsed
          rg <-    hsFreeAndDeclaredPNs    parsed
          return (rg,rr)
      -- ((resg,(FN fr,DN dr)),_s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      ((resg,(FN fr,DN dr)),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      -- ---------------------
      -- Free Vars - parsed
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) fr) `shouldBe`
                   "[(GHC.Integer.Type.Integer, (-1, -1)), "++
                   "(GHC.Num.*, (-1, -1)),\n "++
                   "(GHC.Types.Int, (-1, -1)), "++
                   "(GHC.Base.$, (-1, -1)),\n "++
                   "(GHC.List.head, (-1, -1)), "++
                   "(GHC.List.zip, (-1, -1)),\n "++
                   "(System.IO.getChar, (-1, -1)), "++
                   "(System.IO.putStrLn, (-1, -1)),\n "++
                   "(Data.Generics.Text.gshow, (-1, -1))]"

      -- Declared Vars - parsed
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) dr) `shouldBe`
                   "[(FreeAndDeclared.Declare.toplevel, (6, 1)),\n "++
                   "(FreeAndDeclared.Declare.c, (9, 1)),\n "++
                   "(FreeAndDeclared.Declare.d, (10, 1)),\n "++
                   "(FreeAndDeclared.Declare.tup, (16, 1)),\n "++
                   "(FreeAndDeclared.Declare.h, (16, 6)),\n "++
                   "(FreeAndDeclared.Declare.t, (16, 8)),\n "++
                   "(FreeAndDeclared.Declare.D, (18, 1)),\n "++
                   "(FreeAndDeclared.Declare.A, (18, 10)),\n "++
                   "(FreeAndDeclared.Declare.B, (18, 14)),\n "++
                   "(FreeAndDeclared.Declare.C, (18, 25)),\n "++
                   "(FreeAndDeclared.Declare.unD, (21, 1)),\n "++
                   "(FreeAndDeclared.Declare.F, (25, 1)),\n "++
                   "(FreeAndDeclared.Declare.G, (25, 10)),\n "++
                   "(FreeAndDeclared.Declare.:|, (25, 14)),\n "++
                   "(FreeAndDeclared.Declare.unF, (27, 1)),\n "++
                   "(FreeAndDeclared.Declare.main, (30, 1)),\n "++
                   "(FreeAndDeclared.Declare.mkT, (34, 1)),\n "++
                   "(FreeAndDeclared.Declare.ff, (36, 1))]"

      -- ---------------------
      -- GHC version
      -- Free Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (fst resg)) `shouldBe`
                   "[(GHC.Integer.Type.Integer, (-1, -1)), "++
                   "(GHC.Num.*, (-1, -1)),\n "++
                   "(GHC.Types.Int, (-1, -1)), "++
                   "(GHC.Base.$, (-1, -1)),\n "++
                   "(GHC.List.head, (-1, -1)), "++
                   "(GHC.List.zip, (-1, -1)),\n "++
                   "(System.IO.getChar, (-1, -1)), "++
                   "(System.IO.putStrLn, (-1, -1)),\n "++
                   "(Data.Generics.Text.gshow, (-1, -1))]"

      -- Declared Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (snd resg)) `shouldBe`
                  "[(FreeAndDeclared.Declare.toplevel, (6, 1)),\n "++
                  "(FreeAndDeclared.Declare.c, (9, 1)),\n "++
                  "(FreeAndDeclared.Declare.d, (10, 1)),\n "++
                  "(FreeAndDeclared.Declare.tup, (16, 1)),\n "++
                  "(FreeAndDeclared.Declare.h, (16, 6)),\n "++
                  "(FreeAndDeclared.Declare.t, (16, 8)),\n "++
                  "(FreeAndDeclared.Declare.D, (18, 1)),\n "++
                  "(FreeAndDeclared.Declare.A, (18, 10)),\n "++
                  "(FreeAndDeclared.Declare.B, (18, 14)),\n "++
                  "(FreeAndDeclared.Declare.C, (18, 25)),\n "++
                  "(FreeAndDeclared.Declare.unD, (21, 1)),\n "++
                  "(FreeAndDeclared.Declare.F, (25, 1)),\n "++
                  "(FreeAndDeclared.Declare.G, (25, 10)),\n "++
                  "(FreeAndDeclared.Declare.:|, (25, 14)),\n "++
                  "(FreeAndDeclared.Declare.unF, (27, 1)),\n "++
                  "(FreeAndDeclared.Declare.main, (30, 1)),\n "++
                  "(FreeAndDeclared.Declare.mkT, (34, 1)),\n "++
                  "(FreeAndDeclared.Declare.ff, (36, 1))]"


    -- ---------------------------------

    it "finds free and declared in a single bind PrefixCon" $ do
      t <- ct $ parsedFileGhc "./FreeAndDeclared/Declare.hs"
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let
        comp = do
          parsed <- getRefactParsed
          decls <- liftT $ hsDecls parsed
          -- let b = head $ drop 4 $ hsBinds renamed
          let b = head $ drop 10 $ decls
          rg <- hsFreeAndDeclaredPNs [b]
          return (b,rg)
      ((bb,resg),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions


      (showGhcQual bb) `shouldBe` "unD (B y) = y"
      -- (SYB.showData SYB.Renamer 0 bb) `shouldBe` ""

      -- GHC version
      -- Free Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (fst resg)) `shouldBe`
                   "[(FreeAndDeclared.Declare.B, (18, 14))]"

      -- Declared Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (snd resg)) `shouldBe`
                   "[(FreeAndDeclared.Declare.unD, (21, 1))]"

    -- ---------------------------------

    it "finds free and declared in a single bind InfixCon" $ do
      t <- ct $ parsedFileGhc "./FreeAndDeclared/Declare.hs"

      let
        comp = do
          parsed <- getRefactParsed
          decls <- liftT $ hsDecls parsed
          -- let b = head $ drop 3 $ hsBinds renamed
          let b = head $ drop 12 $ decls
          rg <- hsFreeAndDeclaredPNs [b]
          return (b,rg)
      ((bb,resg),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual bb) `shouldBe` "unF (a :| b) = (a, b)"
      -- (SYB.showData SYB.Renamer 0 bb) `shouldBe` ""

      -- GHC version
      -- Free Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (fst resg)) `shouldBe`
                   "[(FreeAndDeclared.Declare.:|, (25, 14))]"

      -- Declared Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (snd resg)) `shouldBe`
                   "[(FreeAndDeclared.Declare.unF, (27, 1))]"

    -- ---------------------------------

    it "finds free and declared in a single bind RecCon" $ do
      t <- ct $ parsedFileGhc "./FreeAndDeclared/DeclareRec.hs"

      let
        comp = do
          parsed <- getRefactParsed
          decls <- liftT $ hsDecls parsed
          -- let b = head $ drop 0 $ hsBinds renamed
          let b = head $ drop 2 decls
          rg <- hsFreeAndDeclaredPNs [b]
          return (b,rg)
      ((bb,resg),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions


      (showGhcQual bb) `shouldBe` "unR2 (RCon {r1 = a}) = a"
      -- (SYB.showData SYB.Renamer 0 bb) `shouldBe` ""

      -- GHC version
      -- Free Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (fst resg)) `shouldBe`
                   "[(FreeAndDeclared.DeclareRec.RCon, (3, 10))]"

      -- Declared Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (snd resg)) `shouldBe`
                   "[(FreeAndDeclared.DeclareRec.unR2, (7, 1))]"

    -- -----------------------------------------------------------------

    it "hsFreeAndDeclaredPNs simplest" $ do
      t <- ct $ parsedFileGhc "./FreeAndDeclared/DeclareS.hs"
      let
        comp = do
          parsed <- getRefactParsed
          r <- hsFreeAndDeclaredPNs parsed
          return r
      ((res),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      -- Free Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (fst res)) `shouldBe` "[]"

      -- Declared Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (snd res)) `shouldBe` "[(FreeAndDeclared.DeclareS.c, (6, 1))]"

    -- -----------------------------------------------------------------

    it "finds free and declared in a single bind #2" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just tup = getName "DupDef.Dd1.ff" renamed

      let
        comp = do
          parsed <- getRefactParsed
          nm <- getRefactNameMap
          decls <- liftT $ hsDecls parsed
          let [decl] = definingDeclsRdrNames nm [tup] decls False False
          r <- hsFreeAndDeclaredPNs [decl]
          return (r,decl)
      ((res,d),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual d) `shouldBe` "ff y\n  = y + zz\n  where\n      zz = 1"
      -- (SYB.showData SYB.Renamer 0 d) `shouldBe` ""

      -- Free Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (fst res)) `shouldBe`
                   "[(GHC.Num.+, (-1, -1))]"

      -- Declared Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (snd res)) `shouldBe`
                   "[(DupDef.Dd1.ff, (21, 1))]"

    -- -----------------------------------------------------------------

    it "finds free and declared at the top level 1" $ do
      t <- ct $ parsedFileGhc "./LiftToToplevel/WhereIn1.hs"

      let
        comp = do
          parsed <- getRefactParsed
          -- r <- hsFreeAndDeclaredPNs $ hsBinds renamed
          r <- hsFreeAndDeclaredPNs parsed
          return r
      ((res),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      -- Declared Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (snd res)) `shouldBe`
                   "[(LiftToToplevel.WhereIn1.sumSquares, (9, 1)),\n "++
                   "(LiftToToplevel.WhereIn1.anotherFun, (15, 1))]"

      -- Free Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (fst res)) `shouldBe`
                   "[(GHC.Num.+, (-1, -1)), (GHC.Real.^, (-1, -1))]"

    -- -----------------------------------------------------------------

    it "finds free and declared at the top level 2" $ do
      t <- ct $ parsedFileGhc "./Renaming/IdIn3.hs"

      let
        comp = do
          parsed <- getRefactParsed
          r <- hsFreeAndDeclaredPNs parsed
          return r
      ((res),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      -- Declared Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (snd res)) `shouldBe`
                  "[(IdIn3.x, (10, 1)), "++
                  "(IdIn3.foo, (12, 1)), "++
                  "(IdIn3.bar, (14, 1)),\n "++
                  "(IdIn3.main, (18, 1))]"

      -- Free Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (fst res)) `shouldBe`
                   "[(GHC.Num.+, (-1, -1))]"

    -- -----------------------------------------------------------------

    it "finds free and declared in a GRHSs" $ do
      t <- ct $ parsedFileGhc "./LiftOneLevel/LetIn2.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just tup = getName "LiftOneLevel.LetIn2.sumSquares" renamed
      let
        comp = do
          nm <- getRefactNameMap
          parsed <- getRefactParsed
          decls <- liftT $ hsDecls parsed
          let [decl] = definingDeclsRdrNames nm [tup] decls False False

#if __GLASGOW_HASKELL__ <= 710
          let (GHC.L _ (GHC.ValD (GHC.FunBind _ _ (GHC.MG [match] _ _ _) _ _ _))) = decl
#else
          let (GHC.L _ (GHC.ValD (GHC.FunBind _ (GHC.MG (GHC.L _ [match]) _ _ _) _ _ _))) = decl
#endif
          let (GHC.L _ (GHC.Match _ _pat _ grhss)) = match

          r <- hsFreeAndDeclaredPNs grhss
          return r
      ((res),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions


      -- Declared Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (snd res)) `shouldBe`
                   "[]"

      -- Free Vars
      (showGhcQual $ map (\n -> (n, getGhcLoc $ GHC.nameSrcSpan n)) (fst res)) `shouldBe`
                   "[(GHC.Real.^, (-1, -1)), (GHC.Num.+, (-1, -1)), (x, (10, 12)),\n (y, (10, 14))]"

    -- -----------------------------------------------------------------

    it "finds free and declared in a single bind" $ do
      pending -- "fix the prior test"

  -- ---------------------------------------------------------------------


  describe "hsFDsFromInsideRdr" $ do
    it "does something useful" $ do
      pendingWith "need to convert to using Parsed source" -- "Complete this"

  describe "hsFDsFromInside" $ do
    it "does something useful" $ do
      pending -- "Complete this"

  describe "hsFDNamesFromInside" $ do
    it "does something useful" $ do
      pending -- "Complete this"

  -- ---------------------------------------------------------------------

  describe "hsVisibleNames" $ do
    it "does something useful" $ do
      pending -- "Complete this"

  -- ---------------------------------------------------------------------

  describe "hsVisibleDsRdr" $ do

    -- ---------------------------------

    it "returns [] if e does not occur in t" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just tl1  = locToExp (4,13) (4,40) parsed :: (Maybe (GHC.Located (GHC.HsExpr GHC.RdrName)))
      let Just tup = getName "DupDef.Dd1.tup" renamed
      let
        comp = do
          DN r <- hsVisibleDsRdr nm tup tl1
          return r
      ((res),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (null res) `shouldBe` True

    -- -----------------------------------------------------------------

    it "returns visible vars if e does occur in t #1" $ do
      pendingWith "no longer relevant?"
{-
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just tl1  = locToExp (28,4) (28,12) parsed :: (Maybe (GHC.LHsExpr GHC.RdrName))
      (showGhcQual tl1) `shouldBe` "ll + z"

      let Just tup = getName "DupDef.Dd1.l" renamed

      let
        comp = do
         decls <- liftT $ hsDecls parsed
         let [decl] = definingDeclsRdrNames nm [tup] decls False False
         r <- hsVisibleDsRdr nm (rdrName2NamePure nm tl1) decl
         return (r,decl)
      ((res,d),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual d) `shouldBe` "l z = let ll = 34 in ll + z"
      (showGhcQual res ) `shouldBe` "[z, ll]"
      -- (showGhcQual res2 ) `shouldBe` "[z, ll]"
-}
    -- -----------------------------------------------------------------

    it "returns visible vars if e does occur in t #2" $ do
      pendingWith "no longer relevant?"
 {-
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just tl1  = locToExp (28,4) (28,12) parsed :: (Maybe (GHC.LHsExpr GHC.RdrName))
      (showGhcQual tl1) `shouldBe` "ll + z"

      let Just rhs  = locToExp (26,1) (28,12) parsed :: (Maybe (GHC.LHsExpr GHC.RdrName))
      (showGhcQual rhs) `shouldBe` "let ll = 34 in ll + z"

      let
        comp = do
          r <- hsVisibleDsRdr nm (rdrName2NamePure nm tl1) rhs
          return r
      ((res),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual res) `shouldBe` "[ll]"
-}
    -- ---------------------------------

    it "Rdr:finds function arguments visible in RHS 1" $ do
      pendingWith "no longer relevant?"
  {-
      t <- ct $ parsedFileGhc "./Visible/Simple.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let Just e  = locToExp (5,11) (5,19) parsed :: (Maybe (GHC.LHsExpr GHC.RdrName))
      (showGhcQual e) `shouldBe` "a + b"

      let Just n = getName "Visible.Simple.params" renamed

      let
        comp = do
          nm <- getRefactNameMap
          declsp <- liftT $ hsDecls parsed
          let [decl] = definingDeclsRdrNames nm [n] declsp False False
          fds' <- hsVisibleDsRdr nm (rdrName2NamePure nm e) decl
          return (fds')
      -- ((fds),_s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      ((fds),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (show fds) `shouldBe` "DN [a, b, GHC.Num.+]"
-}
    -- -----------------------------------

    it "finds function arguments visible in RHS 2" $ do
      pendingWith "no longer relevant?"
   {-
      t <- ct $ parsedFileGhc "./Visible/Simple.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let Just e   = locToExp (9,15) (9,17) parsed  :: (Maybe (GHC.LHsExpr GHC.RdrName))
      (showGhcQual e) `shouldBe` "x"

      let Just n = getName "Visible.Simple.param2" renamed

      let
        comp = do
          nm <- getRefactNameMap
          declsp <- liftT $ hsDecls parsed
          let [decl] = definingDeclsRdrNames nm [n] declsp False False
          fds' <- hsVisibleDsRdr nm (rdrName2NamePure nm e) decl
          return (fds')
      -- ((fds),_s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      ((fds),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (show fds) `shouldBe` "DN [x]"
-}
    -- -----------------------------------

    it "finds visible vars inside a function" $ do
      t <- ct $ parsedFileGhc "./Renaming/IdIn5.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let Just rhs  = locToExp (14,6) (15,14) parsed  :: (Maybe (GHC.LHsExpr GHC.RdrName))
      (showGhcQual rhs) `shouldBe` "x + y + z"

      -- let Just er = getName "IdIn5.x" renamed
      let Just e  = locToRdrName (14,7) parsed
      (showGhcQual e) `shouldBe` "x"
      (SYB.showData SYB.Parser 0 e) `shouldBe` "\n(L {Renaming/IdIn5.hs:14:7} \n (Unqual {OccName: x}))"

      let
        comp = do
          nm <- getRefactNameMap
          fds' <- hsVisibleDsRdr nm (rdrName2NamePure nm e) rhs
          -- ffds <- hsFreeAndDeclaredGhc rhsr
          let ffds = hsFreeAndDeclaredRdr nm rhs
          return (fds',ffds)
      -- ((fds,_fds),_s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      ((fds,_fds),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (show _fds) `shouldBe` "(FN [GHC.Num.+, IdIn5.x, y, z],DN [])"
      (show fds)  `shouldBe` "DN [GHC.Num.+, IdIn5.x, y, z]"

    -- -----------------------------------

    it "finds visible vars inside a data declaration" $ do
      t <- ct $ parsedFileGhc "./Renaming/D1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let Just ln = locToRdrName (6, 6) parsed
      (showGhcQual ln) `shouldBe` "Tree"
      (SYB.showData SYB.Parser 0 ln) `shouldBe` "\n(L {Renaming/D1.hs:6:6-9} \n (Unqual {OccName: Tree}))"

      let
        comp = do
          -- logDataWithAnns "parsed" parsed
          nm <- getRefactNameMap
          fds' <- hsVisibleDsRdr nm (rdrName2NamePure nm ln) parsed
          -- ffds <- hsFreeAndDeclaredGhc renamed
          let ffds = hsFreeAndDeclaredRdr nm parsed
          return (fds',ffds)
      ((fds,_fds),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((fds,_fds),_s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (show _fds) `shouldBe` "(FN [a, "++
                                  "GHC.Base.++, "++
                                  "GHC.Types.Int, "++
                                  "GHC.Classes.==, "++
                                  "GHC.Classes./=, "++
                                  ":,\n "++
                                  "GHC.Num.+, "++
                                  "GHC.Real.^, "++
                                  "[]],"++
                             "DN [Renaming.D1.Tree, "++
                                 "Renaming.D1.Leaf, "++
                                 "Renaming.D1.Branch,\n "++
                                 "Renaming.D1.fringe, "++
                                 "Renaming.D1.SameOrNot, "++
                                 "Renaming.D1.isSame,\n "++
                                 "Renaming.D1.isNotSame, "++
                                 "Renaming.D1.sumSquares])"

      (show fds) `shouldBe` "DN [Renaming.D1.Tree, Renaming.D1.Leaf, Renaming.D1.Branch]"

    -- -----------------------------------

    it "finds visible vars inIdIn5" $ do
      t <- ct $ parsedFileGhc "./Renaming/IdIn5.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let Just ln = locToRdrName (10, 1) parsed
      (showGhcQual ln) `shouldBe` "x"
      (SYB.showData SYB.Parser 0 ln) `shouldBe` "\n(L {Renaming/IdIn5.hs:10:1} \n (Unqual {OccName: x}))"

      let
        comp = do
          logDataWithAnns "parsed" parsed
          nm <- getRefactNameMap
          fds' <- hsVisibleDsRdr nm (rdrName2NamePure nm ln) parsed
          let ffds = hsFreeAndDeclaredRdr nm parsed
          return (fds',ffds)
      ((fds,_fds),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((fds,_fds),_s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (show _fds) `shouldBe` "(FN [GHC.Num.+],"++
                              "DN [IdIn5.x, IdIn5.foo, IdIn5.bar, IdIn5.main])"

      (show fds) `shouldBe` "DN [GHC.Num.+, IdIn5.x, z, y, IdIn5.foo, IdIn5.bar]"


  -- ---------------------------------------------------------------------

  describe "hsFreeAndDeclaredRdr" $ do
    it "finds function arguments visible in RHS fd" $ do
      t <- ct $ parsedFileGhc "./Visible/Simple.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just e  = locToExp (5,11) (5,19) parsed :: (Maybe (GHC.Located (GHC.HsExpr GHC.RdrName)))
      (showGhcQual e) `shouldBe` "a + b"

      let Just n = getName "Visible.Simple.params" renamed

      let
        comp = do
          decls <- liftT $ hsDecls parsed
          let [decl] = definingDeclsRdrNames nm [n] decls False False
          let fds' = hsFreeAndDeclaredRdr nm decl
          return (fds')
      -- ((fds),_s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      ((fds),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (show fds) `shouldBe` "(FN [GHC.Num.+],DN [Visible.Simple.params])"

    -- -----------------------------------

    it "finds function arguments and free vars visible in RHS" $ do
      t <- ct $ parsedFileGhc "./Visible/Simple.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just e  = locToExp (9,15) (9,17) parsed :: Maybe (GHC.LHsExpr GHC.RdrName)
      (showGhcQual e) `shouldBe` "x"

      let Just n = getName "Visible.Simple.param2" renamed
      let
        comp = do
          decls <- liftT $ hsDecls parsed
          let [decl] = definingDeclsRdrNames nm [n] decls False False

#if __GLASGOW_HASKELL__ <= 710
          let (GHC.L _ (GHC.ValD (GHC.FunBind _ _ (GHC.MG matches _ _ _) _ _ _))) = decl
#else
          let (GHC.L _ (GHC.ValD (GHC.FunBind _ (GHC.MG (GHC.L _ matches) _ _ _) _ _ _))) = decl
#endif
          let [(GHC.L _ (GHC.Match _ pats _ _))] = matches
          let lpat = head pats
          logDataWithAnns "lpat" lpat

          -- fds' <- hsFreeAndDeclaredGhc $ lpat
          let fds' = hsFreeAndDeclaredRdr nm lpat
          return (fds')
      -- ((fds),_s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      ((fds),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (show fds) `shouldBe` "(FN [Visible.Simple.B],DN [x])"

    -- -----------------------------------

    it "finds imported functions used in the rhs" $ do
      t <- ct $ parsedFileGhc "./FreeAndDeclared/Declare.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let Just n = getName "FreeAndDeclared.Declare.tup" renamed

      let
        comp = do
          nm <- getRefactNameMap
          decls <- liftT $ hsDecls parsed
          let [decl] = definingDeclsRdrNames nm [n] decls False False
          let fds' = hsFreeAndDeclaredRdr nm decl
          return (fds')
      ((fds),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (show fds) `shouldBe`
            "(FN [GHC.Base.$, GHC.List.head, GHC.List.zip],"++
            "DN [FreeAndDeclared.Declare.tup, FreeAndDeclared.Declare.h,\n "++
                "FreeAndDeclared.Declare.t])"

    -- -----------------------------------

    it "finds free vars in HsWithBndrs" $ do
      t <- ct $ parsedFileGhc "./FreeAndDeclared/Binders.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t

      let Just n = getName "FreeAndDeclared.Binders.findNewPName" renamed
      let
        comp = do
          nm <- getRefactNameMap
          parsed <- getRefactParsed
          -- logDataWithAnns "parsed" parsed
          decls <- liftT $ hsDecls parsed
          let [decl] = definingDeclsRdrNames nm [n] decls False False
#if __GLASGOW_HASKELL__ <= 710
          let (GHC.L _ (GHC.ValD (GHC.FunBind _ _ (GHC.MG [match] _ _ _) _ _ _))) = decl
#else
          let (GHC.L _ (GHC.ValD (GHC.FunBind _ (GHC.MG (GHC.L _ [match]) _ _ _) _ _ _))) = decl
#endif
          let (GHC.L _ (GHC.Match _ _pats _rhs binds)) = match

          logDataWithAnns "binds" binds
          -- fds' <- hsFreeAndDeclaredGhc $ binds
          let fds' = hsFreeAndDeclaredRdr nm binds
          return (fds')
      -- ((fds),_s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      ((fds),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (show fds) `shouldBe`
            "(FN [FreeAndDeclared.Binders.gfromJust,\n "++
            "FreeAndDeclared.Binders.somethingStaged,\n "++
            "FreeAndDeclared.Binders.Renamer, "++
            "GHC.Base.Nothing, "++
            "renamed,\n "++
            "FreeAndDeclared.Binders.Name, "++
            "GHC.Classes.==, "++
            "GHC.Base.$,\n "++
            "FreeAndDeclared.Binders.occNameString,\n "++
            "FreeAndDeclared.Binders.getOccName, "++
            "name, "++
            "GHC.Base.Just],"++
            "DN [res, worker])"

    -- -----------------------------------

    it "finds free vars in TH files" $ do
      t <- ct $ parsedFileGhc "./TH/Main.hs"
      let
        comp = do
          parseSourceFileGhc "./TH/Main.hs"
          parsed <- getRefactParsed
          nm <- getRefactNameMap
          let fds' = hsFreeAndDeclaredRdr nm parsed
          return (fds')
      ((fds),_s) <- ct $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (show fds) `shouldBe`
            "(FN [System.IO.putStrLn, pr],"++
             "DN [TH.Main.main, TH.Main.baz, TH.Main.sillyString])"

  -- ---------------------------------------------

  describe "isLocalPN" $ do
    it "returns True if the name is local to the module" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just n = locToNameRdrPure nm (17, 5) parsed
      (showGhcQual n) `shouldBe` "ff"
      isLocalPN n `shouldBe` True

    it "returns False if the name is not local to the module" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just n = locToNameRdrPure nm (21, 1) parsed
      (showGhcQual n) `shouldBe` "DupDef.Dd1.ff"
      isLocalPN n `shouldBe` False

  -- ---------------------------------------------

  describe "isTopLevelPN" $ do
    it "returns False if the name is not defined at the top level of the module" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let
        comp = do
          parsed <- getRefactParsed
          nm <- getRefactNameMap
          let Just n = locToNameRdrPure nm (17, 5) parsed
          topLevel <- isTopLevelPN n
          return (n,topLevel)
      ((nf,tl),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual nf) `shouldBe` "ff"
      tl `shouldBe` False

    it "returns True if the name is defined at the top level of the module" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let
        comp = do
          parsed <- getRefactParsed
          nm <- getRefactNameMap
          let Just n = locToNameRdrPure nm (21, 1) parsed
          topLevel <- isTopLevelPN n
          return (n,topLevel)

      ((nf,tl),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual nf) `shouldBe` "DupDef.Dd1.ff"
      tl `shouldBe` True

  -- ---------------------------------------------

  describe "definedPNsRdr" $ do
    it "gets the PNs defined in a declaration" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just pn = locToNameRdrPure nm (3, 1) parsed
      (showGhcQual pn) `shouldBe` "DupDef.Dd1.toplevel"

      let origDecls = getHsDecls parsed
      let demotedDecls'= definingDeclsRdrNames nm [pn] origDecls True False
      let declaredPns = nub $ concatMap definedPNsRdr demotedDecls'

      (showGhcQual declaredPns) `shouldBe` "[toplevel]"

    -- ---------------------------------

    it "gets the PNs defined in an as-match" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just pn = locToNameRdrPure nm (14, 1) parsed
      (showGhcQual pn) `shouldBe` "DupDef.Dd1.tup"

      let origDecls = getHsDecls parsed
      let demotedDecls'= definingDeclsRdrNames nm [pn] origDecls True False
      let declaredPns = nub $ concatMap definedPNsRdr demotedDecls'

      (showGhcQual declaredPns) `shouldBe` "[tup, h, t]"


  -- ---------------------------------------------

  describe "inScopeInfo" $ do
    it "returns 4 element tuples for in scope names" $ do
      pending -- "is this still needed?"
      {-
      ((inscopes, _renamed, _parsed), _toks) <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let info = inScopeInfo inscopes
      (show $ head info) `shouldBe` "foo"
      -- (show $ info) `shouldBe` "foo"
      -}

  -- ---------------------------------------------

  describe "isInScopeAndUnqualified" $ do
    it "True if the identifier is in scope and unqualified" $ do
      pending -- "needed?"
      {-
      ((inscopes, _renamed, _parsed), _toks) <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let info = inScopeInfo inscopes
      (show $ head info) `shouldBe` "foo"
      -}
-- inScopeInfo for c is
-- (\"DupDef.Dd1.c\",VarName,DupDef.Dd1,Nothing)

  -- ---------------------------------------------

  describe "isInScopeAndUnqualifiedGhc" $ do
    it "True if the identifier is in scope and unqualified" $ do
      let
        comp = do
         parseSourceFileGhc "./DupDef/Dd1.hs"
         ctx <- GHC.getContext
         res1 <- isInScopeAndUnqualifiedGhc "c" Nothing
         res2 <- isInScopeAndUnqualifiedGhc "DupDef.Dd1.c" Nothing
         res3 <- isInScopeAndUnqualifiedGhc "nonexistent" Nothing
         return (res1,res2,res3,ctx)
      ((r1,r2,r3,_c),_s) <- ct $ runRefactGhc comp (initialState { rsModule = Nothing }) testOptions
      r1 `shouldBe` True
      r2 `shouldBe` True
      r3 `shouldBe` False

    -- ---------------------------------

    it "requires qualification on name clash with an import" $ do
      t <- ct $ parsedFileGhc  "./ScopeAndQual.hs"
      let
        comp = do
         parseSourceFileGhc "./ScopeAndQual.hs"
         -- putParsedModule t
         renamed <- getRefactRenamed
         parsed <- getRefactParsed
         nm <- getRefactNameMap

         logm $ "renamed=" ++ (SYB.showData SYB.Renamer 0 renamed) -- ++AZ++

         ctx <- GHC.getContext

         let Just sumSquares = locToNameRdrPure nm (13,15) parsed
         ssUnqual <- isQualifiedPN sumSquares
         names <- GHC.parseName "sum"
         names2 <- GHC.parseName "mySumSq"
         res1 <- isInScopeAndUnqualifiedGhc "sum" Nothing
         res2 <- isInScopeAndUnqualifiedGhc "L.sum" Nothing
         return (res1,res2,names,names2,sumSquares,ssUnqual,ctx)
      ((r1,r2,ns,ns2,ss,ssu,_c),_s) <- ct $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (prettyprint ss) `shouldBe` "sumSquares"
      (showGhcQual ss) `shouldBe` "ScopeAndQual.sumSquares"
      (show $ ssu) `shouldBe` "False"
      (showGhcQual ns) `shouldBe` "[ScopeAndQual.sum]"
      (showGhcQual ns2) `shouldBe` "[ScopeAndQual.mySumSq]"
      "1" ++ (show r1) `shouldBe` "1True"
      "2" ++ (show r2) `shouldBe` "2True"

  -- ---------------------------------------------

  describe "mkNewGhcName" $ do
    it "Creates a new GHC.Name" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let
        comp = do
         parsed <- getRefactParsed
         nm <- getRefactNameMap
         let Just topLevel = locToNameRdrPure nm (3,1) parsed

         name1 <- mkNewGhcName Nothing "foo"
         name2 <- mkNewGhcName Nothing "bar"
         name3 <- mkNewGhcName (Just (GHC.nameModule topLevel)) "baz"

         return (name1,name2,name3)
      ((n1,n2,n3),_s) <- ct $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      GHC.getOccString n1 `shouldBe` "foo"
      showGhcQual n1 `shouldBe` "foo"
      GHC.getOccString n2 `shouldBe` "bar"
      showGhcQual n2 `shouldBe` "bar"
      (showGhcQual $ GHC.nameModule n3) `shouldBe` "main@main:DupDef.Dd1"
      (SYB.showData SYB.Renamer 0 n3) `shouldBe` "{Name: baz}"
      GHC.getOccString n3 `shouldBe` "baz"
      showGhcQual n3 `shouldBe` "DupDef.Dd1.baz"
      (showGhcQual $ GHC.nameUnique n1) `shouldBe` "H2"
      (showGhcQual $ GHC.nameUnique n2) `shouldBe` "H3"
      (showGhcQual $ GHC.nameUnique n3) `shouldBe` "H4"

  -- ---------------------------------------------

  describe "prettyprint" $ do
    it "Prints a GHC.Name ready for parsing into tokens" $ do
      -- (_t, _toks, _tgt) <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let
        comp = do
         name1 <- mkNewGhcName Nothing "foo"
         name2 <- mkNewGhcName Nothing "bar"
         return (name1,name2)
      ((n1,n2),_s) <- ct $ runRefactGhcState comp
      GHC.getOccString n1 `shouldBe` "foo"
      showGhcQual n1 `shouldBe` "foo"
      GHC.getOccString n2 `shouldBe` "bar"
      showGhcQual n2 `shouldBe` "bar"
      showGhcQual n1 `shouldBe` "foo"

  -- ---------------------------------------------

  describe "duplicateDecl" $ do
    it "duplicates a bind only" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (3, 1) parsed
      let
        comp = do
         -- parsed <- getRefactParsed
         declsp <- liftT $ hsDecls parsed
         newName2 <- mkNewGhcName Nothing "bar2"
         newBindings <- duplicateDecl declsp n newName2
         parsed' <- liftT $ replaceDecls parsed newBindings
         putRefactParsed parsed' emptyAnns

         return newBindings
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual n) `shouldBe` "DupDef.Dd1.toplevel"
      (sourceFromState s) `shouldBe` "module DupDef.Dd1 where\n\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\n\nbar2 :: Integer -> Integer\nbar2 x = c * x\n\nc,d :: Integer\nc = 7\nd = 9\n\n-- Pattern bind\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h,t) = head $ zip [1..10] [3..ff]\n  where\n    ff :: Int\n    ff = 15\n\ndata D = A | B String | C\n\nff y = y + zz\n  where\n    zz = 1\n\nl z =\n  let\n    ll = 34\n  in ll + z\n\ndd q = do\n  let ss = 5\n  return (ss + q)\n\n"

  -- ---------------------------------------------

    it "duplicates a bind with a signature, and an offset" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just np = locToNameRdrPure nm (14, 1) parsed
      (showGhcQual np) `shouldBe` "DupDef.Dd1.tup"

      let Just ln'@(GHC.L l _) = locToRdrName (17, 6) parsed
          n = rdrName2NamePure nm ln'
          ln = GHC.L l n
      (showGhcQual n) `shouldBe` "ff"
      let
        comp = do
         newName2 <- mkNewGhcName Nothing "gg"

         -- parsed <- getRefactParsed
         decls <- liftT $ hsDecls parsed

         (front,[parent],back) <- divideDecls decls ln

         (parent',Just (funBinding,declsToDup,declsp')) <- modifyValD (GHC.getLoc parent) parent $ \_m declsp -> do
           let
             declsToDup = definingDeclsRdrNames nm [n] declsp True True
             funBinding = filter isFunOrPatBindP declsToDup     --get the fun binding.

           declsp' <- duplicateDecl declsp n newName2

           return (declsp',Just (funBinding,declsToDup,declsp'))

         parsed' <- liftT $ replaceDecls parsed (front ++ [parent'] ++ back)
         putRefactParsed parsed' emptyAnns

         return (funBinding,declsToDup,declsp')

      ((fb,dd,newb),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((fb,dd,newb),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "ff"
      (showGhcQual dd) `shouldBe` "[ff = 15]"
      (showGhcQual fb) `shouldBe` "[ff = 15]"
      (show $ getStartEndLoc fb) `shouldBe` "((17,5),(17,12))"
      (sourceFromState s) `shouldBe` "module DupDef.Dd1 where\n\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\n\nc,d :: Integer\nc = 7\nd = 9\n\n-- Pattern bind\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h,t) = head $ zip [1..10] [3..ff]\n  where\n    ff :: Int\n    ff = 15\n\n    gg :: Int\n    gg = 15\n\ndata D = A | B String | C\n\nff y = y + zz\n  where\n    zz = 1\n\nl z =\n  let\n    ll = 34\n  in ll + z\n\ndd q = do\n  let ss = 5\n  return (ss + q)\n\n"
      (showGhcQual newb) `shouldBe` "[ff :: Int, ff = 15, gg :: Int, gg = 15]"
      (showGhcQual fb) `shouldBe` "[ff = 15]"


  -- ---------------------------------------------

  describe "addParamsToDecl" $ do
    it "adds parameters to a declaration" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Md1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (3, 1) parsed
      let
        comp = do
         declsp <- liftT $ hsDecls parsed
         let newName2 = mkRdrName "bar2"
         declsp' <- addParamsToDecls declsp n [newName2]
         parsed' <- liftT $ replaceDecls parsed declsp'
         putRefactParsed parsed' emptyAnns

         return declsp'
      (nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "MoveDef.Md1.toplevel"
      (sourceFromState s) `shouldBe` "module MoveDef.Md1 where\n\ntoplevel :: Integer -> Integer\ntoplevel bar2 x = c * x\n\nc,d :: Integer\nc = 7\nd = 9\n\n-- Pattern bind\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h,t) = head $ zip [1..10] [3..ff]\n  where\n    ff :: Int\n    ff = 15\n\ndata D = A | B String | C\n\nff :: Int -> Int\nff y = y + zz\n  where\n    zz = 1\n\nl z =\n  let\n    ll = 34\n  in ll + z\n\ndd q = do\n  let ss = 5\n  return (ss + q)\n\nzz1 a = 1 + toplevel a\n\n-- General Comment\n-- |haddock comment\ntlFunc :: Integer -> Integer\ntlFunc x = c * x\n-- Comment at end\n\n\n"
      (showGhcQual $ head $ tail nb) `shouldBe` "toplevel bar2 x = c * x"

    -- ---------------------------------

    it "adds parameters to a declaration with multiple matches" $ do
      t <- ct $ parsedFileGhc "./AddParams1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (3, 1) parsed
      let
        comp = do
         declsp <- liftT $ hsDecls parsed
         let newName = mkRdrName "pow"
         declsp' <- addParamsToDecls declsp n [newName]
         parsed' <- liftT $ replaceDecls parsed declsp'
         putRefactParsed parsed' emptyAnns
         return declsp'
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- (_nb,s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "AddParams1.sq"
      (sourceFromState s) `shouldBe` "module AddParams1 where\n\nsq pow  0 = 0\nsq pow  z = z^2\n\nfoo = 3\n\n"

    -- ---------------------------------

    it "adds parameters to a declaration with no existing ones" $ do
      t <- ct $ parsedFileGhc "./AddParams1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (6, 1) parsed
      let
        comp = do
         declsp <- liftT $ hsDecls parsed
         let newName1 = mkRdrName "baz"
         let newName2 = mkRdrName "bar"
         declsp' <- addParamsToDecls declsp n [newName1,newName2]
         parsed' <- liftT $ replaceDecls parsed declsp'
         putRefactParsed parsed' emptyAnns

         return declsp'
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "AddParams1.foo"
      (sourceFromState s) `shouldBe` "module AddParams1 where\n\nsq  0 = 0\nsq  z = z^2\n\nfoo baz bar = 3\n\n"

  -- ---------------------------------------------

  describe "addActualParamsToRhs" $ do
    it "adds a parameter to the rhs of a declaration" $ do
      t <- ct $ parsedFileGhc "./LiftToToplevel/D1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (6, 21) parsed
      let
        comp = do
         -- parsed <- getRefactParsed
         declsp <- liftT $ hsDecls parsed
         let decl = head declsp
         let newName2 = mkRdrName "bar2"
         newBinding <- addActualParamsToRhs n [newName2] decl

         return (newBinding,decl)
      ((nb,decl'),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((nb,decl'),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      -- putStrLn $ "nb[]\n" ++ showAnnDataItemFromState s nb ++ "\n]"
      (showGhcQual decl') `shouldBe` "sumSquares (x : xs)\n  = sq x + sumSquares xs\n  where\n      sq x = x ^ pow\n      pow = 2\nsumSquares [] = 0"
      (showGhcQual n) `shouldBe` "sq"
      (showGhcQual nb) `shouldBe` "sumSquares (x : xs)\n  = (sq bar2) x + sumSquares xs\n  where\n      sq x = x ^ pow\n      pow = 2\nsumSquares [] = 0"
      (exactPrintFromState s nb) `shouldBe` "\n\n{-lift 'sq' to top level. This refactoring\n  affects module 'D1' and 'C1' -}\n\nsumSquares (x:xs) = (sq bar2) x + sumSquares xs\n  where\n     sq x = x ^ pow\n     pow =2\n\nsumSquares [] = 0"

    -- --------------------

    it "adds parameters to a complex rhs of a declaration" $ do
      t <- ct $ parsedFileGhc "./LiftToToplevel/WhereIn7.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (10, 17) parsed
      let
        comp = do
         -- parsed <- getRefactParsed
         declsp <- liftT $ hsDecls parsed
         let decl = head declsp

         let newName1 = mkRdrName "x1"
         let newName2 = mkRdrName "y1"
         let newName3 = mkRdrName "z1"
         newBinding <- addActualParamsToRhs n [newName1,newName2,newName3] decl

         return (newBinding,decl)
      ((nb,decl'),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual decl') `shouldBe` "fun x y z\n  = inc addthree\n  where\n      inc a = a + 1\n      addthree = x + y + z"
      (showGhcQual n) `shouldBe` "addthree"
      (showGhcQual nb) `shouldBe` "fun x y z\n  = inc (addthree x1 y1 z1)\n  where\n      inc a = a + 1\n      addthree = x + y + z"
      (exactPrintFromState s nb) `shouldBe` "\n\n--A definition can be lifted from a where or let to the top level binding group.\n--Lifting a definition widens the scope of the definition.\n\n--In this example, lift 'addthree' defined in 'fun'.\n--This example aims to test adding parenthese.\n\n\nfun x y z =inc (addthree x1 y1 z1)\n       where inc a =a +1\n             addthree=x+y+z"


  -- ---------------------------------------------

  describe "rmDecl" $ do
    it "removes a top level declaration, leaving type signature 1" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Md1a.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just n = locToNameRdrPure nm (6, 1) parsed
      let
        comp = do
         (parsed',_removedDecl,_removedSig) <- rmDecl n False parsed
         putRefactParsed parsed' emptyAnns

         return parsed'
      -- (_nb,s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "MoveDef.Md1a.ff"
      (sourceFromState s) `shouldBe` "module MoveDef.Md1a where\n\ndata D = A | B String | C\n\nff :: Int -> Int\n\nl = 1\n\n"

    -- ---------------------------------

    it "removes a top level declaration, leaving type signature 2b" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Md1b.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just n = locToNameRdrPure nm (6, 1) parsed
      let
        comp = do
         (parsed',_removedDecl,_removedSig) <- rmDecl n False parsed
         putRefactParsed parsed' emptyAnns
         return parsed'
      -- (_nb,s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "MoveDef.Md1b.ff"
      (sourceFromState s) `shouldBe` "module MoveDef.Md1b where\n\ndata D = A | C\n\nff :: Int -> Int\n\nl z =\n  let\n    ll = 34\n  in ll + z\n\n"

    -- ---------------------------------

    it "removes a top level declaration, leaving type signature 2" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Md1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just n = locToNameRdrPure nm (22, 1) parsed
      let
        comp = do
         (parsed',_removedDecl,_removedSig) <- rmDecl n False parsed
         putRefactParsed parsed' emptyAnns
         logDataWithAnns "parsed'" parsed'
         return parsed'
      -- (_nb,s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "MoveDef.Md1.ff"
      (sourceFromState s) `shouldBe` "module MoveDef.Md1 where\n\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\n\nc,d :: Integer\nc = 7\nd = 9\n\n-- Pattern bind\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h,t) = head $ zip [1..10] [3..ff]\n  where\n    ff :: Int\n    ff = 15\n\ndata D = A | B String | C\n\nff :: Int -> Int\n\nl z =\n  let\n    ll = 34\n  in ll + z\n\ndd q = do\n  let ss = 5\n  return (ss + q)\n\nzz1 a = 1 + toplevel a\n\n-- General Comment\n-- |haddock comment\ntlFunc :: Integer -> Integer\ntlFunc x = c * x\n-- Comment at end\n\n\n"

    -- ---------------------------------

    it "removes a top level declaration, and type signature" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Md1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (22, 1) parsed
      let
        comp = do
         (newDecls,_removedDecl,_removedSig) <- rmDecl n True parsed
         putRefactParsed newDecls emptyAnns
         return newDecls
      -- (_nb,s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "MoveDef.Md1.ff"
      (sourceFromState s) `shouldBe` "module MoveDef.Md1 where\n\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\n\nc,d :: Integer\nc = 7\nd = 9\n\n-- Pattern bind\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h,t) = head $ zip [1..10] [3..ff]\n  where\n    ff :: Int\n    ff = 15\n\ndata D = A | B String | C\n\nl z =\n  let\n    ll = 34\n  in ll + z\n\ndd q = do\n  let ss = 5\n  return (ss + q)\n\nzz1 a = 1 + toplevel a\n\n-- General Comment\n-- |haddock comment\ntlFunc :: Integer -> Integer\ntlFunc x = c * x\n-- Comment at end\n\n\n"

    -- -----------------------------------

    it "removes the last local decl in a let/in clause" $ do
      t <- ct $ parsedFileGhc "./LiftToToplevel/LetIn1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (11, 22) parsed
      let
        comp = do
         -- parsed <- getRefactParsed
         (parsed',_removedDecl,_removedSig) <- rmDecl n True parsed

         putRefactParsed parsed' emptyAnns

         return parsed'
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- (_nb,s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "sq"
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (sourceFromState s) `shouldBe` "module LiftToToplevel.LetIn1 where\n\n--A definition can be lifted from a where or let to the top level binding group.\n--Lifting a definition widens the scope of the definition.\n\n--In this example, lift 'sq' in 'sumSquares'\n--This example aims to test lifting a definition from a let clause to top level,\n--and the elimination of the keywords 'let' and 'in'\n\nsumSquares x y = sq x + sq y\n                       where pow=2\n\nanotherFun 0 y = sq y\n     where sq x = x^2\n"

    -- -----------------------------------

    it "removes the last local decl in a where clause" $ do
      t <- ct $ parsedFileGhc "./RmDecl3.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (6, 5) parsed
      let
        comp = do
         (parsed',_removedDecl,_removedSig) <- rmDecl n True parsed

         putRefactParsed parsed' emptyAnns

         return parsed'
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- (_nb,s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "zz"
      (sourceFromState s) `shouldBe` "module RmDecl3 where\n\n-- Remove last declaration from a where clause, where should disappear too\nff y = y + zz\n\n-- EOF\n"

    -- -----------------------------------

    it "removes the first local decl in a where clause" $ do
      t <- ct $ parsedFileGhc "./RmDecl4.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let Just n = locToNameRdrPure nm (7, 5) parsed
      let
        comp = do
         (parsed',_removedDecl,_removedSig) <- rmDecl n True parsed

         putRefactParsed parsed' emptyAnns

         return parsed'
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- (_nb,s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "zz"
      (sourceFromState s) `shouldBe` "{-# LANGUAGE FlexibleContexts #-}\nmodule RmDecl4 where\n\n-- Remove first declaration from a where clause, rest should still be indented\nff y = y + zz ++ xx\n  where\n    xx = 2\n\n-- EOF\n"

    -- -----------------------------------

    it "removes the non last local decl in a let/in clause 1" $ do
      t <- ct $ parsedFileGhc "./Demote/LetIn1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      -- (SYB.showData SYB.Renamer 0 renamed) `shouldBe` ""

      let Just n = locToNameRdrPure nm (12, 22) parsed
      let
        comp = do
         (parsed',_removedDecl,_removedSig) <- rmDecl n False parsed
         putRefactParsed parsed' emptyAnns

         return parsed'
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- (_nb,s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "pow"
      (sourceFromState s) `shouldBe` "module Demote.LetIn1 where\n\n--A definition can be demoted to the local 'where' binding of a friend declaration,\n--if it is only used by this friend declaration.\n\n--Demoting a definition narrows down the scope of the definition.\n--In this example, demote the local  'pow' to 'sq'\n--This example also aims to test the demoting a local declaration in 'let'.\n\nsumSquares x y = let sq 0=0\n                     sq z=z^pow\n                 in sq x + sq y\n\n\nanotherFun 0 y = sq y\n     where  sq x = x^2\n\n  "

    -- -----------------------------------

    it "removes the non last local decl in a let/in clause 2" $ do
      t <- ct $ parsedFileGhc "./Demote/LetIn2.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (10, 22) parsed
      let
        comp = do
         (parsed',_removedDecl,_removedSig) <- rmDecl n False parsed
         putRefactParsed parsed' emptyAnns

         return parsed'
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- (_nb,s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "sq"
      (sourceFromState s) `shouldBe` "module Demote.LetIn2 where\n\n--A definition can be demoted to the local 'where' binding of a friend declaration,\n--if it is only used by this friend declaration.\n\n--Demoting a definition narrows down the scope of the definition.\n--In this example, demote the local  'pow' will fail.\n\nsumSquares x y = let pow=2\n                 in sq x + sq y +pow\n\n\nanotherFun 0 y = sq y\n     where  sq x = x^2\n\n  "

    -- -----------------------------------------------------------------

    it "removes a decl with a trailing comment" $ do
      t <- ct $ parsedFileGhc "./Demote/WhereIn3.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just n = locToNameRdrPure nm (14, 1) parsed
      let
        comp = do
         (parsed',_removedDecl,_removedSig1) <- rmDecl n False parsed
         putRefactParsed parsed' emptyAnns

         return parsed'
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- (_nb,s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual n) `shouldBe` "Demote.WhereIn3.sq"
      (sourceFromState s) `shouldBe` "module Demote.WhereIn3 where\n\n--A definition can be demoted to the local 'where' binding of a friend declaration,\n--if it is only used by this friend declaration.\n\n--Demoting a definition narrows down the scope of the definition.\n--In this example, demote the top level 'sq' to 'sumSquares'\n--In this case (there are multi matches), the parameters are not folded after demoting.\n\nsumSquares x y = sq p x + sq p y\n         where p=2  {-There is a comment-}\n\nsq :: Int -> Int -> Int\n\n{- foo bar -}\nanotherFun 0 y = sq y\n     where  sq x = x^2\n"


    -- -----------------------------------------------------------------

    it "removes a sub decl liftOneLevel D1" $ do
      t <- ct $ parsedFileGhc "./LiftOneLevel/D1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just n = locToNameRdrPure nm (8, 6) parsed
      let
        comp = do
         (parsed',_removedDecl,_removedSig1) <- rmDecl n False parsed
         putRefactParsed parsed' emptyAnns

         return parsed'
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- (_nb,s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual n) `shouldBe` "sq"
      (sourceFromState s) `shouldBe` "module LiftOneLevel.D1 where\n\n{-lift 'sq' to top level. This refactoring\naffects module 'D1' and 'C1' -}\n\nsumSquares (x:xs) = sq x + sumSquares xs\n  where\n     pow =2\n\nsumSquares [] = 0\n\nmain = sumSquares [1..4]\n"


  -- ---------------------------------------------

  describe "rmTypeSig" $ do
    it "removes a type signature from the top level 1" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Md1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just n = locToNameRdrPure nm (22, 1) parsed
      let
        comp = do
         (renamed',sigRemoved) <- rmTypeSig n parsed
         putRefactParsed renamed' emptyAnns
         return (renamed',sigRemoved)
      ((_nb,os),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((_nb,os),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "MoveDef.Md1.ff"
      (sourceFromState s) `shouldBe` "module MoveDef.Md1 where\n\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\n\nc,d :: Integer\nc = 7\nd = 9\n\n-- Pattern bind\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h,t) = head $ zip [1..10] [3..ff]\n  where\n    ff :: Int\n    ff = 15\n\ndata D = A | B String | C\n\nff y = y + zz\n  where\n    zz = 1\n\nl z =\n  let\n    ll = 34\n  in ll + z\n\ndd q = do\n  let ss = 5\n  return (ss + q)\n\nzz1 a = 1 + toplevel a\n\n-- General Comment\n-- |haddock comment\ntlFunc :: Integer -> Integer\ntlFunc x = c * x\n-- Comment at end\n\n\n"
      (showGhcQual os) `shouldBe` "Just ff :: Int -> Int"

    -- -----------------------------------------------------------------

    it "removes a type signature from the top level, after decl removed" $ do
      t <- ct $ parsedFileGhc "./Demote/WhereIn3.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just n = locToNameRdrPure nm (14, 1) parsed
      let
        comp = do
         (parsed',_removedDecl,_removedSig1) <- rmDecl    n False parsed
         (parsed2,_removedSig2)              <- rmTypeSig n parsed'
         putRefactParsed parsed2 emptyAnns

         return parsed2
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- (_nb,s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual n) `shouldBe` "Demote.WhereIn3.sq"
      (sourceFromState s) `shouldBe` "module Demote.WhereIn3 where\n\n--A definition can be demoted to the local 'where' binding of a friend declaration,\n--if it is only used by this friend declaration.\n\n--Demoting a definition narrows down the scope of the definition.\n--In this example, demote the top level 'sq' to 'sumSquares'\n--In this case (there are multi matches), the parameters are not folded after demoting.\n\nsumSquares x y = sq p x + sq p y\n         where p=2  {-There is a comment-}\n\n{- foo bar -}\nanotherFun 0 y = sq y\n     where  sq x = x^2\n"


    -- -----------------------------------------------------------------

    it "removes a type signature from non-top level" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Md1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just n = locToNameRdrPure nm (16, 5) parsed
      let
        comp = do
         (renamed',_removedSig) <- rmTypeSig n parsed
         putRefactParsed renamed' emptyAnns
         return renamed'
      -- (_nb,s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (_nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "ff"
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (sourceFromState s) `shouldBe` "module MoveDef.Md1 where\n\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\n\nc,d :: Integer\nc = 7\nd = 9\n\n-- Pattern bind\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h,t) = head $ zip [1..10] [3..ff]\n  where\n    ff = 15\n\ndata D = A | B String | C\n\nff :: Int -> Int\nff y = y + zz\n  where\n    zz = 1\n\nl z =\n  let\n    ll = 34\n  in ll + z\n\ndd q = do\n  let ss = 5\n  return (ss + q)\n\nzz1 a = 1 + toplevel a\n\n-- General Comment\n-- |haddock comment\ntlFunc :: Integer -> Integer\ntlFunc x = c * x\n-- Comment at end\n\n\n"

    -- -----------------------------------------------------------------

    it "removes a type signature within multi signatures 1" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/TypeSigs.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just b = locToNameRdrPure nm (12, 1) parsed
      let
        comp = do
         (renamed',removedSig) <- rmTypeSig b parsed
         putRefactParsed renamed' emptyAnns
         return (renamed',removedSig)
      ((_nb,os),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (exactPrintFromState s (fromJust os)) `shouldBe` "\n\nb::Int->Integer->Char"
      (showGhcQual b) `shouldBe` "TypeSigs.b"
      (sourceFromState s) `shouldBe` "module TypeSigs where\n\nsq,anotherFun :: Int -> Int\nsq 0 = 0\nsq z = z^2\n\nanotherFun x = x^2\n\na,c::Int->Integer->Char\n\na x y = undefined\nb x y = undefined\nc x y = undefined\n\n"

    -- -----------------------------------------------------------------

    it "removes a type signature within multi signatures 2" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/TypeSigs.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just n = locToNameRdrPure nm (4, 1) parsed
      let
        comp = do
         (renamed',removedSig) <- rmTypeSig n parsed
         putRefactParsed renamed' emptyAnns
         return (renamed',removedSig)
      -- ((_nb,os),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      ((_nb,os),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- putStrLn $ "anntree\n" ++ showAnnDataFromState s
      (exactPrintFromState s (fromJust os)) `shouldBe` "\n\nsq :: Int -> Int"
      (showGhcQual n) `shouldBe` "TypeSigs.sq"
      (sourceFromState s) `shouldBe` "module TypeSigs where\n\nanotherFun :: Int -> Int\nsq 0 = 0\nsq z = z^2\n\nanotherFun x = x^2\n\na,b,c::Int->Integer->Char\n\na x y = undefined\nb x y = undefined\nc x y = undefined\n\n"
      (showGhcQual os) `shouldBe` "Just sq :: Int -> Int"

    -- -----------------------------------------------------------------

    it "removes a type signature within multi signatures 3" $ do
      t <- ct $ parsedFileGhc "./Demote/WhereIn7.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just n = locToNameRdrPure nm (12, 1) parsed
      let
        comp = do
         (parsed',removedSig) <- rmTypeSig n parsed
         putRefactParsed parsed' emptyAnns
         return (parsed',removedSig)
      -- ((_nb,os),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      ((_nb,os),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual n) `shouldBe` "WhereIn7.sq"
      (exactPrintFromState s (fromJust os)) `shouldBe` "\n\nsq :: Int -> Int"
      (sourceFromState s) `shouldBe` "module WhereIn7 where\n\n--A definition can be demoted to the local 'where' binding of a friend declaration,\n--if it is only used by this friend declaration.\n\n--Demoting a definition narrows down the scope of the definition.\n--In this example, demote the top level 'sq' to 'sumSquares'\n--This example also aims to test the split of type signature.\n\nsumSquares x y = sq x + sq y\n\nanotherFun :: Int -> Int\nsq 0 = 0\nsq z = z^pow\n   where  pow=2\n\nanotherFun x = x^2\n "
      (showGhcQual os) `shouldBe` "Just sq :: Int -> Int"

    -- -----------------------------------------------------------------
{-
    it "removes a type signature for a pattern in a bind" $ do
      t <- ct $ parsedFileGhc "./LiftToToplevel/PatBindIn1.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let Just (GHC.L _ n) = locToName (GHC.mkFastString "./test/testdata/LiftToToplevel/PatBindIn1.hs") (18, 7) renamed
      let
        comp = do
         (renamed',removedSig) <- rmTypeSig n renamed
         let (Just (GHC.L ss _)) = removedSig
         oldSigToks <- getToksForSpan ss
         return (renamed',removedSig,oldSigToks)
      -- ((nb,os,ot),s) <- runRefactGhc comp $ initialState { rsModule = initRefactModule [] t }
      ((nb,os,ot),s) <- runRefactGhc comp $ initialLogOnState { rsModule = initRefactModule [] t }
      (showGhcQual n) `shouldBe` "tup"
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""
      (sourceFromState s) `shouldBe` "module LiftToToplevel.PatBindIn1 where\n\n --A definition can be lifted from a where or let into the surrounding binding group.\n --Lifting a definition widens the scope of the definition.\n\n --In this example, lift 'tup' defined in 'foo'\n --This example aims to test renaming and the lifting of type signatures.\n\n main :: Int\n main = foo 3\n\n foo :: Int -> Int\n foo x = h + t + (snd tup)\n       where\n       \n       \n\n       tup@(h,t) = head $ zip [1..10] [3..15]\n "
      (showGhcQual nb) `shouldBe` ""
      (showGhcQual os) `shouldBe` ""
      (GHC.showRichTokenStream ot) `shouldBe` ""
-}
  -- ---------------------------------------------

  describe "addDecl" $ do
    it "adds a top level declaration without a type signature, in default pos" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Md1.hs"
      let
        comp = do
         parsed <- getRefactParsed
         (decl,declAnns) <- GHC.liftIO $ withDynFlags (\df -> parseDeclToAnnotated df "a" "nn = n2")
         -- let declAnns' = setPrecedingLines declAnns newDecl 2
         parsed' <- addDecl parsed Nothing ([decl],Just declAnns)
         putRefactParsed parsed' emptyAnns
         return parsed'
      (nb,s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- (nb,s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (sourceFromState s) `shouldBe` "module MoveDef.Md1 where\n\nnn = n2\n\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\n\nc,d :: Integer\nc = 7\nd = 9\n\n-- Pattern bind\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h,t) = head $ zip [1..10] [3..ff]\n  where\n    ff :: Int\n    ff = 15\n\ndata D = A | B String | C\n\nff :: Int -> Int\nff y = y + zz\n  where\n    zz = 1\n\nl z =\n  let\n    ll = 34\n  in ll + z\n\ndd q = do\n  let ss = 5\n  return (ss + q)\n\nzz1 a = 1 + toplevel a\n\n-- General Comment\n-- |haddock comment\ntlFunc :: Integer -> Integer\ntlFunc x = c * x\n-- Comment at end\n\n\n"
      (unspace $ showGhcQual nb) `shouldBe` unspace "module MoveDef.Md1 where\nnn = n2\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\nc, d :: Integer\nc = 7\nd = 9\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h, t)\n = head $ zip [1 .. 10] [3 .. ff]\n where\n ff :: Int\n ff = 15\ndata D = A | B String | C\nff :: Int -> Int\nff y\n = y + zz\n where\n zz = 1\nl z = let ll = 34 in ll + z\ndd q\n = do { let ss = 5;\n return (ss + q) }\nzz1 a = 1 + toplevel a\ntlFunc :: Integer -> Integer\ntlFunc x = c * x"

    -- -------------------------------------------

    it "adds a top level declaration with a type signature 1" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Md1.hs"
      let
        comp = do
         parsed <- getRefactParsed
         (decl,declAnns) <- GHC.liftIO $ withDynFlags (\df -> parseDeclToAnnotated df "decl" "nn = 2")
         (sig, sigAnns)  <- GHC.liftIO $ withDynFlags (\df -> parseDeclToAnnotated df "sig"  "nn :: Int")
         parsed' <- addDecl parsed Nothing ([sig,decl],Just $ mergeAnns sigAnns declAnns)
         putRefactParsed parsed' emptyAnns
         return (sig,parsed')
      ((_hs,nb),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (sourceFromState s) `shouldBe` "module MoveDef.Md1 where\n\nnn :: Int\nnn = 2\n\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\n\nc,d :: Integer\nc = 7\nd = 9\n\n-- Pattern bind\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h,t) = head $ zip [1..10] [3..ff]\n  where\n    ff :: Int\n    ff = 15\n\ndata D = A | B String | C\n\nff :: Int -> Int\nff y = y + zz\n  where\n    zz = 1\n\nl z =\n  let\n    ll = 34\n  in ll + z\n\ndd q = do\n  let ss = 5\n  return (ss + q)\n\nzz1 a = 1 + toplevel a\n\n-- General Comment\n-- |haddock comment\ntlFunc :: Integer -> Integer\ntlFunc x = c * x\n-- Comment at end\n\n\n"
      (unspace $ showGhcQual nb) `shouldBe` unspace "module MoveDef.Md1 where\nnn :: Int\nnn = 2\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\nc, d :: Integer\nc = 7\nd = 9\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h, t)\n = head $ zip [1 .. 10] [3 .. ff]\n where\n ff :: Int\n ff = 15\ndata D = A | B String | C\nff :: Int -> Int\nff y\n = y + zz\n where\n zz = 1\nl z = let ll = 34 in ll + z\ndd q\n = do { let ss = 5;\n return (ss + q) }\nzz1 a = 1 + toplevel a\ntlFunc :: Integer -> Integer\ntlFunc x = c * x"

    -- -------------------------------------------

    it "adds a top level declaration after a specified one 1" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Md1.hs"
      let
        comp = do
         parsed <- getRefactParsed
         (decl,declAnns) <- GHC.liftIO $ withDynFlags (\df -> parseDeclToAnnotated df "a" "nn = nn2")
         nm <- getRefactNameMap
         let Just n = locToNameRdrPure nm (21, 1) parsed
         parsed' <- addDecl parsed (Just n) ([decl],Just declAnns)
         putRefactParsed parsed' emptyAnns
         return (n,parsed')
      ((n,nb),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((n,nb),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual n) `shouldBe` "MoveDef.Md1.ff"
      (sourceFromState s) `shouldBe` "module MoveDef.Md1 where\n\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\n\nc,d :: Integer\nc = 7\nd = 9\n\n-- Pattern bind\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h,t) = head $ zip [1..10] [3..ff]\n  where\n    ff :: Int\n    ff = 15\n\ndata D = A | B String | C\n\nff :: Int -> Int\nff y = y + zz\n  where\n    zz = 1\n\nnn = nn2\n\nl z =\n  let\n    ll = 34\n  in ll + z\n\ndd q = do\n  let ss = 5\n  return (ss + q)\n\nzz1 a = 1 + toplevel a\n\n-- General Comment\n-- |haddock comment\ntlFunc :: Integer -> Integer\ntlFunc x = c * x\n-- Comment at end\n\n\n"
      (unspace $ showGhcQual nb) `shouldBe` unspace "module MoveDef.Md1 where\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\nc, d :: Integer\nc = 7\nd = 9\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h, t)\n = head $ zip [1 .. 10] [3 .. ff]\n where\n ff :: Int\n ff = 15\ndata D = A | B String | C\nff :: Int -> Int\nff y\n = y + zz\n where\n zz = 1\nnn = nn2\nl z = let ll = 34 in ll + z\ndd q\n = do { let ss = 5;\n return (ss + q) }\nzz1 a = 1 + toplevel a\ntlFunc :: Integer -> Integer\ntlFunc x = c * x"


    -- -------------------------------------------

    it "adds a top level declaration after a specified one 2" $ do
      t <- ct $ parsedFileGhc "./AddOneParameter/FunIn1.hs"
      let
        comp = do
         parsed <- getRefactParsed
         (decl,declAnns) <- GHC.liftIO $ withDynFlags (\df -> parseDeclToAnnotated df "a" "nn = nn2")
         nm <- getRefactNameMap
         let Just n = locToNameRdrPure nm (7, 1) parsed
         parsed' <- addDecl parsed (Just n) ([decl],Just declAnns)
         putRefactParsed parsed' emptyAnns
         return (n,parsed')
      ((n,nb),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((n,nb),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual n) `shouldBe` "FunIn1.foo"
      -- putStrLn (sourceFromState s)
      (sourceFromState s) `shouldBe` "module FunIn1 where\n\n--Default parameters can be added to definition of functions and simple constants.\n\n--In this example: add parameter 'y' to 'foo'\nfoo :: Int -> Int\nfoo  x= h + t where (h,t) = head $ zip [1..x] [3..15] {-There\nis a comment-}\n\nnn = nn2\n\nmain :: Int\nmain = foo 4\n"
      (unspace $ showGhcQual nb) `shouldBe` unspace "module FunIn1 where\nfoo :: Int -> Int\nfoo x\n = h + t\n where\n (h, t) = head $ zip [1 .. x] [3 .. 15]\nnn = nn2\nmain :: Int\nmain = foo 4"


    -- -------------------------------------------

    it "adds a top level declaration with a type signature after a specified one" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Md1.hs"
      let
        comp = do
         parsed <- getRefactParsed
         nm <- getRefactNameMap
         let Just n = locToNameRdrPure nm (21, 1) parsed
         (decl,declAnns) <- GHC.liftIO $ withDynFlags (\df -> parseDeclToAnnotated df "decl" "nn = nn2")
         (sig, sigAnns)  <- GHC.liftIO $ withDynFlags (\df -> parseDeclToAnnotated df "sig"  "nn :: Int")
         parsed' <- addDecl parsed (Just n) ([sig,decl],Just $ mergeAnns sigAnns declAnns)
         putRefactParsed parsed' emptyAnns
         return (n,parsed')
      ((nn,nb),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual nn) `shouldBe` "MoveDef.Md1.ff"
      (sourceFromState s) `shouldBe`"module MoveDef.Md1 where\n\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\n\nc,d :: Integer\nc = 7\nd = 9\n\n-- Pattern bind\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h,t) = head $ zip [1..10] [3..ff]\n  where\n    ff :: Int\n    ff = 15\n\ndata D = A | B String | C\n\nff :: Int -> Int\nff y = y + zz\n  where\n    zz = 1\n\nnn :: Int\nnn = nn2\n\nl z =\n  let\n    ll = 34\n  in ll + z\n\ndd q = do\n  let ss = 5\n  return (ss + q)\n\nzz1 a = 1 + toplevel a\n\n-- General Comment\n-- |haddock comment\ntlFunc :: Integer -> Integer\ntlFunc x = c * x\n-- Comment at end\n\n\n"
      (unspace $ showGhcQual nb) `shouldBe` unspace "module MoveDef.Md1 where\ntoplevel :: Integer -> Integer\ntoplevel x = c * x\nc, d :: Integer\nc = 7\nd = 9\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h, t)\n = head $ zip [1 .. 10] [3 .. ff]\n where\n ff :: Int\n ff = 15\ndata D = A | B String | C\nff :: Int -> Int\nff y\n = y + zz\n where\n zz = 1\nnn :: Int\nnn = nn2\nl z = let ll = 34 in ll + z\ndd q\n = do { let ss = 5;\n return (ss + q) }\nzz1 a = 1 + toplevel a\ntlFunc :: Integer -> Integer\ntlFunc x = c * x"


    -- -------------------------------------------

    it "adds a local declaration without a type signature 1" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Md1.hs"

      let
        comp = do
         parsed <- getRefactParsed
         nm <- getRefactNameMap

         let Just tl = locToNameRdrPure nm (4, 1) parsed
         decls <- liftT (hsDecls parsed)
         let
             [tlDecl] = definingDeclsRdrNames nm [tl] decls True False

         (decl,declAnns) <- GHC.liftIO $ withDynFlags (\df -> parseDeclToAnnotated df "decl" "nn = nn2")

         newDecl <- addDecl tlDecl Nothing ([decl],Just declAnns)

         logm $ "test:addDecl done"

         return (tlDecl,newDecl)
      -- ((tl,nb),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      ((tl,nb),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual tl) `shouldBe` "toplevel x = c * x"
      (exactPrintFromState s nb) `shouldBe` "\ntoplevel x = c * x\n  where\n    nn = nn2"
      (showGhcQual nb)           `shouldBe` "toplevel x\n  = c * x\n  where\n      nn = nn2"

    -- -------------------------------------------

    it "adds a local declaration with a type signature 1" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Md1.hs"
      let
        comp = do
         parsed <- getRefactParsed
         nm <- getRefactNameMap

         let Just tl = locToNameRdrPure nm (4, 1) parsed
         decls <- liftT (hsDecls parsed)
         let
             [tlDecl] = definingDeclsRdrNames nm [tl] decls True False

         (decl,declAnns) <- GHC.liftIO $ withDynFlags (\df -> parseDeclToAnnotated df "decl" "nn = nn2")
         (sig, sigAnns)  <- GHC.liftIO $ withDynFlags (\df -> parseDeclToAnnotated df "sig"  "nn :: Int")

         newDecl <- addDecl tlDecl Nothing ([sig,decl],Just $ mergeAnns sigAnns declAnns)

         return (tlDecl,newDecl)
      ((tl,nb),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((tl,nb),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual tl) `shouldBe` "toplevel x = c * x"
      -- putStrLn (showAnnDataItemFromState s nb)
      (exactPrintFromState s nb) `shouldBe` "\ntoplevel x = c * x\n  where\n    nn :: Int\n    nn = nn2"
      (showGhcQual nb) `shouldBe` "toplevel x\n  = c * x\n  where\n      nn = nn2\n      nn :: Int"
    -- -------------------------------------------

    it "adds a local declaration with a where clause" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Demote.hs"
      let
        comp = do

         parsed <- getRefactParsed
         nm <- getRefactNameMap

         let Just tl = locToNameRdrPure nm (4, 1) parsed
         decls <- liftT (hsDecls parsed)
         let
             [tlDecl] = definingDeclsRdrNames nm [tl] decls True False

         (decl,declAnns) <- GHC.liftIO $ withDynFlags (\df -> parseDeclToAnnotated df "decl" "nn = nn2")

         newDecl <- addDecl tlDecl Nothing ([decl],Just declAnns)

         return (tlDecl,newDecl)
      ((tl,nb),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual tl) `shouldBe` "toplevel x = c * x"
      (exactPrintFromState s nb) `shouldBe` "\ntoplevel x = c * x\n  where\n    nn = nn2"
      (showGhcQual nb) `shouldBe` "toplevel x\n  = c * x\n  where\n      nn = nn2"

    -- -------------------------------------------

    it "adds a local declaration to an existing one" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Md2.hs"
      let
        comp = do

         parsed <- getRefactParsed
         nm <- getRefactNameMap

         let Just tl = locToNameRdrPure nm (4, 1) parsed
         decls <- liftT (hsDecls parsed)
         let
             [tlDecl] = definingDeclsRdrNames nm [tl] decls True False

         (decl,declAnns) <- GHC.liftIO $ withDynFlags (\df -> parseDeclToAnnotated df "decl" "nn = nn2")

         newDecl <- addDecl tlDecl Nothing ([decl],Just declAnns)

         return (tlDecl,newDecl)
      ((tl,nb),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((tl,nb),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual tl) `shouldBe` "toplevel x\n  = c * x * b\n  where\n      b = 3"
      (exactPrintFromState s nb) `shouldBe` "\ntoplevel x = c * x * b\n  where\n    nn = nn2\n\n    b = 3"
      (showGhcQual nb) `shouldBe` "toplevel x\n  = c * x * b\n  where\n      b = 3\n      nn = nn2"

    -- -------------------------------------------

    it "adds a local declaration with a type signature to an existing one" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Md2.hs"
      let
        comp = do

         parsed <- getRefactParsed
         nm <- getRefactNameMap

         let Just tl = locToNameRdrPure nm (4, 1) parsed
         decls <- liftT (hsDecls parsed)
         let
             [tlDecl] = definingDeclsRdrNames nm [tl] decls True False

         (decl,declAnns) <- GHC.liftIO $ withDynFlags (\df -> parseDeclToAnnotated df "decl" "nn = nn2")
         (sig, sigAnns)  <- GHC.liftIO $ withDynFlags (\df -> parseDeclToAnnotated df "sig"  "nn :: Int")

         newDecl <- addDecl tlDecl Nothing ([sig,decl],Just $ mergeAnns sigAnns declAnns)

         return (tlDecl,newDecl)
      ((tl,nb),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual tl) `shouldBe` "toplevel x\n  = c * x * b\n  where\n      b = 3"
      (exactPrintFromState s nb) `shouldBe` "\ntoplevel x = c * x * b\n  where\n    nn :: Int\n    nn = nn2\n\n    b = 3"
      (showGhcQual nb) `shouldBe` "toplevel x\n  = c * x * b\n  where\n      b = 3\n      nn = nn2\n      nn :: Int"

    -- -------------------------------------------

    it "adds a local decl with type signature to an existing one, with a comment" $ do
      t <- ct $ parsedFileGhc "./Demote/WhereIn3.hs"
      let
        comp = do
         parsed  <- getRefactParsed
         nm <- getRefactNameMap

         let Just tl = locToNameRdrPure nm (10, 1) parsed
         decls <- liftT (hsDecls parsed)
         let [tlDecl] = definingDeclsRdrNames nm [tl] decls True False

         let Just sq = locToNameRdrPure nm (14, 1) parsed
         let Just af = locToNameRdrPure nm (18, 1) parsed

         let [sqSig]  = definingSigsRdrNames  nm [sq] parsed
             [sqDecl] = definingDeclsRdrNames nm [sq] decls False False
             [afDecl] = definingDeclsRdrNames nm [af] decls False False

         let  sqSigDecl = wrapSig sqSig
         liftT (balanceComments tlDecl sqSigDecl)
         liftT (balanceComments sqDecl afDecl)

         newDecl <- addDecl tlDecl Nothing ([sqSigDecl,sqDecl],Nothing)

         return (sqSig,sqDecl,tlDecl,afDecl,newDecl)
      -- ((sigs,_sd,tl,aa,nb),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      ((sigs,_sd,tl,aa,nb),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual sigs) `shouldBe` "sq :: Int -> Int -> Int"
      (showGhcQual tl) `shouldBe` "sumSquares x y\n  = sq p x + sq p y\n  where\n      p = 2"
      (showGhcQual aa) `shouldBe` "anotherFun 0 y\n  = sq y\n  where\n      sq x = x ^ 2"
      (exactPrintFromState s nb) `shouldBe` "\n\n--A definition can be demoted to the local 'where' binding of a friend declaration,\n--if it is only used by this friend declaration.\n\n--Demoting a definition narrows down the scope of the definition.\n--In this example, demote the top level 'sq' to 'sumSquares'\n--In this case (there are multi matches), the parameters are not folded after demoting.\n\nsumSquares x y = sq p x + sq p y\n         where sq :: Int -> Int -> Int\n               sq pow 0 = 0\n               sq pow z = z^pow  --there is a comment\n\n               p=2  {-There is a comment-}"
      (showGhcQual nb) `shouldBe` "sumSquares x y\n  = sq p x + sq p y\n  where\n      p = 2\n      sq :: Int -> Int -> Int\n      sq pow 0 = 0\n      sq pow z = z ^ pow"

    -- -------------------------------------------

    it "does not add a local decl to a FunBind with multiple matches" $ do
      t <- ct $ parsedFileGhc "./MoveDef/MultiFunBind1.hs"
      let
        comp = do
         parsed  <- getRefactParsed
         nm <- getRefactNameMap

         let Just tl = locToNameRdrPure nm (3, 1) parsed
         decls <- liftT (hsDecls parsed)
         let -- decls = hsBinds parsed
             [tlDecl] = definingDeclsRdrNames nm [tl] decls True False

         let Just y = locToNameRdrPure nm (6, 1) parsed

         let [yDecl] = definingDeclsRdrNames nm [y] decls False False

         newDecl <- addDecl tlDecl Nothing ([yDecl],Nothing)

         return (yDecl,tlDecl,newDecl)
      Just r <- catchException $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (isPrefixOf "addDecl:Cannot add a local decl to a FunBind with multiple matches" r) `shouldBe` True

    -- -------------------------------------------

    it "adds a local declaration to a PatBind" $ do
      t <- ct $ parsedFileGhc "./MoveDef/PatBind1.hs"
      let
        comp = do

         parsed <- getRefactParsed
         nm <- getRefactNameMap

         let Just tl = locToNameRdrPure nm (3, 1) parsed
         decls <- liftT (hsDecls parsed)
         let
             [tlDecl] = definingDeclsRdrNames nm [tl] decls True False

         (decl,declAnns) <- GHC.liftIO $ withDynFlags (\df -> parseDeclToAnnotated df "decl" "nn = nn2")

         newDecl <- addDecl tlDecl Nothing ([decl],Just declAnns)

         return (tlDecl,newDecl)
      ((tl,nb),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((tl,nb),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual tl) `shouldBe` "tup@(h, t) = (x, 1)"
      (exactPrintFromState s nb) `shouldBe` "\n\ntup@(h,t) = (x,1)\n  where\n    nn = nn2"
      (showGhcQual nb) `shouldBe` "tup@(h, t)\n  = (x, 1)\n  where\n      nn = nn2"

  -- ---------------------------------------------

  describe "renamePN" $ do
    it "replaces a Name with another 1" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let
        comp = do
         parsed <- getRefactParsed
         nm <- getRefactNameMap
         let Just n' = locToNameRdrPure nm (3, 1) parsed
         newName <- mkNewGhcName Nothing "bar2"
         new <- renamePN n' newName PreserveQualify parsed
         putRefactParsed new emptyAnns
         return (new,newName,n')
      let

      ((nb,nn,n),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual (n,nn)) `shouldBe` "(DupDef.Dd1.toplevel, bar2)"
      (sourceFromState s) `shouldBe` "module DupDef.Dd1 where\n\nbar2 :: Integer -> Integer\nbar2 x = c * x\n\nc,d :: Integer\nc = 7\nd = 9\n\n-- Pattern bind\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h,t) = head $ zip [1..10] [3..ff]\n  where\n    ff :: Int\n    ff = 15\n\ndata D = A | B String | C\n\nff y = y + zz\n  where\n    zz = 1\n\nl z =\n  let\n    ll = 34\n  in ll + z\n\ndd q = do\n  let ss = 5\n  return (ss + q)\n\n"
      (showGhcQual nb) `shouldBe` "module DupDef.Dd1 where\nbar2 :: Integer -> Integer\nbar2 x = c * x\nc, d :: Integer\nc = 7\nd = 9\ntup :: (Int, Int)\nh :: Int\nt :: Int\ntup@(h, t)\n  = head $ zip [1 .. 10] [3 .. ff]\n  where\n      ff :: Int\n      ff = 15\ndata D = A | B String | C\nff y\n  = y + zz\n  where\n      zz = 1\nl z = let ll = 34 in ll + z\ndd q\n  = do { let ss = 5;\n         return (ss + q) }"

    -- -----------------------------------------------------------------

    it "replaces a Name with another 2" $ do
      t <- ct $ parsedFileGhc "./Demote/WhereIn4.hs"

      let
        comp = do
         parsed <- getRefactParsed
         nm <- getRefactNameMap
         declsr <- liftT $ hsDecls parsed
         let decl = head $ drop 0 declsr
         let Just n' = locToNameRdrPure nm (11, 21) parsed
         newName <- mkNewGhcName Nothing "p_1"
         new <- renamePN n' newName PreserveQualify decl
         parsed' <- liftT $ replaceDecls parsed (new:tail declsr)
         putRefactParsed parsed' emptyAnns
         return (new,newName,decl,n')
      let
      ((nb,nn,d,n),s) <- ct $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual d) `shouldBe` "sumSquares x y\n  = sq p x + sq p y\n  where\n      p = 2"
      (showGhcQual (n,nn)) `shouldBe` "(p, p_1)"
      (sourceFromState s) `shouldBe` "module Demote.WhereIn4 where\n\n--A definition can be demoted to the local 'where' binding of a friend declaration,\n--if it is only used by this friend declaration.\n\n--Demoting a definition narrows down the scope of the definition.\n--In this example, demote the top level 'sq' to 'sumSquares'\n--In this case (there is single matches), if possible,\n--the parameters will be folded after demoting and type sigature will be removed.\n\nsumSquares x y = sq p_1 x + sq p_1 y\n         where p_1=2  {-There is a comment-}\n\nsq::Int->Int->Int\nsq pow z = z^pow  --there is a comment\n\nanotherFun 0 y = sq y\n     where  sq x = x^2\n\n"
      (showGhcQual nb) `shouldBe` "sumSquares x y\n  = sq p_1 x + sq p_1 y\n  where\n      p_1 = 2"


    -- ---------------------------------

    it "replaces a Name with another in limited scope 1" $ do
      t <- ct $ parsedFileGhc "./TokenTest.hs"

      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just n = locToNameRdrPure nm (19, 1) parsed
      (showGhcQual n) `shouldBe` "TokenTest.foo"

      let
        comp = do
         -- parsed <- getRefactParsed
         decls <- liftT $ hsDecls parsed
         newName <- mkNewGhcName Nothing "bar2"
         new <- renamePN n newName PreserveQualify (head $ drop 3 decls)
         parsed' <- liftT $ replaceDecls parsed (take 3 decls ++ [new] ++ drop 4 decls)
         putRefactParsed parsed' emptyAnns
         return (new,newName)
      let

      ((nb,nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((nb,nn),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual (n,nn)) `shouldBe` "(TokenTest.foo, bar2)"
      (sourceFromState s) `shouldBe` "module TokenTest where\n\n-- Test new style token manager\n\nbob a b = x\n  where x = 3\n\nbib a b = x\n  where\n    x = 3\n\n\nbab a b =\n  let bar = 3\n  in     b + bar -- ^trailing comment\n\n\n-- leading comment\nbar2 x y =\n  do c <- getChar\n     return c\n\n\n\n\n"
      (showGhcQual nb) `shouldBe` "bar2 x y\n  = do { c <- getChar;\n         return c }"
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""

    -- ---------------------------------

    it "replace a Name with another in limited scope 2" $ do
      t <- ct $ parsedFileGhc "./TokenTest.hs"

      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
      let Just n = locToNameRdrPure nm (19, 1) parsed
      (showGhcQual n) `shouldBe` "TokenTest.foo"

      let
        comp = do
         -- parsed <- getRefactParsed
         decls <- liftT $ hsDecls parsed
         let decl = head $ drop 3 decls
         newName <- mkNewGhcName Nothing "bar2"
         new <- renamePN n newName PreserveQualify decl

         parsed' <- liftT $ replaceDecls parsed (take 3 decls ++ [new] ++ drop 4 decls)
         putRefactParsed parsed' emptyAnns

         return (new,newName)

      ((nb,_nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "TokenTest.foo"
      (sourceFromState s) `shouldBe` "module TokenTest where\n\n-- Test new style token manager\n\nbob a b = x\n  where x = 3\n\nbib a b = x\n  where\n    x = 3\n\n\nbab a b =\n  let bar = 3\n  in     b + bar -- ^trailing comment\n\n\n-- leading comment\nbar2 x y =\n  do c <- getChar\n     return c\n\n\n\n\n"
      (showGhcQual nb) `shouldBe` "bar2 x y\n  = do { c <- getChar;\n         return c }"
      -- (showToks $ take 20 $ toksFromState s) `shouldBe` ""

    ------------------------------------

    it "replaces a name in a data declaration too" $ do
      t <- ct $ parsedFileGhc "./Renaming/Field1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (5, 19) parsed
      let
        comp = do
         logParsedSource "parsed"
         logm $ "nm:" ++ showNameMap nm
         logm $ "n:nameUnique:" ++ show (GHC.nameUnique n)
         newName <- mkNewGhcName Nothing "pointx1"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns
         logParsedSource "parsed:after"
         return (new,newName)
      let

      ((nb,_nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((nb,_nn),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "Field1.pointx"
      (sourceFromState s) `shouldBe` "module Field1 where\n\n--Rename field name 'pointx' to 'pointx1'\n\ndata Point = Pt {pointx1, pointy :: Float}\n\nabsPoint :: Point -> Float\nabsPoint p = sqrt (pointx1 p * pointx1 p +\n                  pointy p * pointy p)\n\n"
      (unspace $ showGhcQual nb) `shouldBe` "module Field1 where\ndata Point = Pt {pointx1, pointy :: Float}\nabsPoint :: Point -> Float\nabsPoint p = sqrt (pointx1 p * pointx1 p + pointy p * pointy p)"


    ------------------------------------

    it "replaces a name in a type signature too" $ do
      t <- ct $ parsedFileGhc "./Renaming/Field1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (5, 6) parsed
      let
        comp = do
         logParsedSource "parsed"
         newName <- mkNewGhcName Nothing "NewPoint"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns
         logParsedSource "parsed:after"

         return (new,newName)
      let

      ((nb,_nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((nb,nn),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual n) `shouldBe` "Field1.Point"
      (sourceFromState s) `shouldBe` "module Field1 where\n\n--Rename field name 'pointx' to 'pointx1'\n\ndata NewPoint = Pt {pointx, pointy :: Float}\n\nabsPoint :: NewPoint -> Float\nabsPoint p = sqrt (pointx p * pointx p +\n                  pointy p * pointy p)\n\n"
      (unspace $ showGhcQual nb) `shouldBe` "module Field1 where\ndata NewPoint = Pt {pointx, pointy :: Float}\nabsPoint :: NewPoint -> Float\nabsPoint p = sqrt (pointx p * pointx p + pointy p * pointy p)"

    ------------------------------------

    it "replace a name in a FunBind with multiple patterns" $ do
      t <- ct $ parsedFileGhc "./LocToName.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (20, 1) parsed
      let
        comp = do
         newName <- mkNewGhcName Nothing "newPoint"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns

         return (new,newName)
      let

      ((nb,_nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual n) `shouldBe` "LocToName.sumSquares"
      (sourceFromState s) `shouldBe` "module LocToName where\n\n{-\n\n\n\n\n\n\n\n\n-}\n\n\n\n\n\n\n\nnewPoint (x:xs) = x ^2 + newPoint xs\n    -- where sq x = x ^pow \n    --       pow = 2\n\nnewPoint [] = 0\n"
      (unspace $ showGhcQual nb) `shouldBe` "module LocToName where\nnewPoint (x : xs) = x ^ 2 + newPoint xs\nnewPoint [] = 0"

    ------------------------------------

    it "replaces a qualified name in a FunBind with multiple patterns" $ do
      t <- ct $ parsedFileGhc "./LocToName.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
#if __GLASGOW_HASKELL__ <= 710
      let modu = GHC.mkModule (GHC.stringToPackageKey "mypackage-1.0") (GHC.mkModuleName "LocToName")
#else
      let modu = GHC.mkModule (GHC.stringToUnitId     "mypackage-1.0") (GHC.mkModuleName "LocToName")
#endif

      let Just n = locToNameRdrPure nm (20, 1) parsed
      let
        comp = do
         -- logm $ "renamed:" ++ (SYB.showData SYB.Renamer 0 renamed)
         logDataWithAnns "parsed" parsed
         newName <- mkNewGhcName (Just modu) "newPoint"
         new <- renamePN n newName Qualify parsed

         putRefactParsed new emptyAnns
         -- logParsedSource "parsed:after"

         return (new,newName)

      ((nb,_nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((nb,_nn),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual n) `shouldBe` "LocToName.sumSquares"
      (unspace $ showGhcQual nb) `shouldBe` "module LocToName where\nLocToName.newPoint (x : xs) = x ^ 2 + LocToName.newPoint xs\nLocToName.newPoint [] = 0"
      (sourceFromState s) `shouldBe` "module LocToName where\n\n{-\n\n\n\n\n\n\n\n\n-}\n\n\n\n\n\n\n\nnewPoint (x:xs) = x ^2 + LocToName.newPoint xs\n    -- where sq x = x ^pow \n    --       pow = 2\n\nnewPoint [] = 0\n"


    ------------------------------------

    it "replaces a parameter name in a FunBind" $ do
      t <- ct $ parsedFileGhc "./Renaming/LayoutIn2.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (8, 7) parsed
      let
        comp = do
         logParsedSource "parsed"

         newName <- mkNewGhcName Nothing "ls"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns
         logParsedSource "parsed:after"

         return (new,newName)

      ((nb,_nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((nb,_nn),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (sourceFromState s) `shouldBe` "module LayoutIn2 where\n\n--Layout rule applies after 'where','let','do' and 'of'\n\n--In this Example: rename 'list' to 'ls'.\n\nsilly :: [Int] -> Int\nsilly ls = case ls of  (1:xs) -> 1\n--There is a comment\n                       (2:xs)\n                         | x < 10    -> 4  where  x = last xs\n                       otherwise -> 12\n"
      (unspace $ showGhcQual nb) `shouldBe` "module LayoutIn2 where\nsilly :: [Int] -> Int\nsilly ls\n = case ls of {\n (1 : xs) -> 1\n (2 : xs)\n | x < 10 -> 4\n where\n x = last xs\n otherwise -> 12 }"


    ------------------------------------

    it "does not qualify a name in an import hiding clause" $ do
      t <- ct $ parsedFileGhc "./ScopeAndQual.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
#if __GLASGOW_HASKELL__ <= 710
      let modu = GHC.mkModule (GHC.stringToPackageKey "mypackage-1.0") (GHC.mkModuleName "LocToName")
#else
      let modu = GHC.mkModule (GHC.stringToUnitId "mypackage-1.0") (GHC.mkModuleName "LocToName")
#endif

      let Just n = locToNameRdrPure nm (4, 24) parsed
      let
        comp = do
         logParsedSource "parsed"
         newName <- mkNewGhcName (Just modu) "mySum"
         new <- renamePN n newName Qualify parsed

         putRefactParsed new emptyAnns

         return (new,newName)

      ((nb,_nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((nb,_nn),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "Data.Foldable.sum"
      (sourceFromState s) `shouldBe` "module ScopeAndQual where\n\nimport qualified Data.List as L\nimport Prelude hiding (mySum)\n\nmain :: IO ()\nmain = putStrLn (show $ L.mySum [1,2,3])\n\nsum a b = a + b\n\nsumSquares xs = L.mySum $ map (\\x -> x*x) xs\n\nmySumSq = sumSquares\n"
      (unspace $ showGhcQual nb) `shouldBe` "module ScopeAndQual where\nimport qualified Data.List as L\nimport Prelude hiding ( mySum )\nmain :: IO ()\nmain = putStrLn (show $ L.mySum [1, 2, 3])\nsum a b = a + b\nsumSquares xs = L.mySum $ map (\\ x -> x * x) xs\nmySumSq = sumSquares"


    ------------------------------------

    it "does not qualify the subject of a type signature" $ do
      t <- ct $ parsedFileGhc "./Renaming/C7.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t
#if __GLASGOW_HASKELL__ <= 710
      let modu = GHC.mkModule (GHC.stringToPackageKey "mypackage-1.0") (GHC.mkModuleName "LocToName")
#else
      let modu = GHC.mkModule (GHC.stringToUnitId "mypackage-1.0") (GHC.mkModuleName "LocToName")
#endif

      let Just n = locToNameRdrPure nm (5, 1) parsed
      let
        comp = do
         logParsedSource "parsed"
         newName <- mkNewGhcName (Just modu) "myNewFringe"

         new <- renamePN n newName Qualify parsed
         putRefactParsed new emptyAnns

         return (new,newName)

      ((nb,_nn),s) <- ct $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((nb,_nn),s) <- ct $ runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "Renaming.C7.myFringe"
      (sourceFromState s) `shouldBe` "module Renaming.C7(LocToName.myNewFringe)  where\n\nimport Renaming.D7\n\nmyNewFringe:: Tree a -> [a]\nmyNewFringe (Leaf x ) = [x]\nmyNewFringe (Branch left right) = LocToName.myNewFringe left ++ fringe right\n\n\n\n\n"
      (unspace $ showGhcQual nb) `shouldBe` "module Renaming.C7 (\n LocToName.myNewFringe\n ) where\nimport Renaming.D7\nmyNewFringe :: Tree a -> [a]\nLocToName.myNewFringe (Leaf x) = [x]\nLocToName.myNewFringe (Branch left right)\n = LocToName.myNewFringe left ++ fringe right"

    ------------------------------------

    it "realigns in a case for a shorter name" $ do
      t <- ct $ parsedFileGhc "./Renaming/LayoutIn2.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (8, 7) parsed
      let
        comp = do
         logm $ "renamed:" ++ (SYB.showData SYB.Renamer 0 renamed)

         newName <- mkNewGhcName Nothing "ls"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns

         return (new,newName)

      ((nb,_nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "list"
      (sourceFromState s) `shouldBe` "module LayoutIn2 where\n\n--Layout rule applies after 'where','let','do' and 'of'\n\n--In this Example: rename 'list' to 'ls'.\n\nsilly :: [Int] -> Int\nsilly ls = case ls of  (1:xs) -> 1\n--There is a comment\n                       (2:xs)\n                         | x < 10    -> 4  where  x = last xs\n                       otherwise -> 12\n"
      (unspace $ showGhcQual nb) `shouldBe` "module LayoutIn2 where\nsilly :: [Int] -> Int\nsilly ls\n = case ls of {\n (1 : xs) -> 1\n (2 : xs)\n | x < 10 -> 4\n where\n x = last xs\n otherwise -> 12 }"



    ------------------------------------

    it "realigns in a case for a longer name" $ do
      t <- ct $ parsedFileGhc "./Renaming/LayoutIn2.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (8, 7) parsed
      let
        comp = do
         logm $ "renamed:" ++ (SYB.showData SYB.Renamer 0 renamed)

         newName <- mkNewGhcName Nothing "listlonger"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns

         return (new,newName)

      ((nb,_nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "list"
      (sourceFromState s) `shouldBe` "module LayoutIn2 where\n\n--Layout rule applies after 'where','let','do' and 'of'\n\n--In this Example: rename 'list' to 'ls'.\n\nsilly :: [Int] -> Int\nsilly listlonger = case listlonger of  (1:xs) -> 1\n            --There is a comment\n                                       (2:xs)\n                                         | x < 10    -> 4  where  x = last xs\n                                       otherwise -> 12\n"
      (unspace $ showGhcQual nb) `shouldBe` "module LayoutIn2 where\nsilly :: [Int] -> Int\nsilly listlonger\n = case listlonger of {\n (1 : xs) -> 1\n (2 : xs)\n | x < 10 -> 4\n where\n x = last xs\n otherwise -> 12 }"


    ------------------------------------

    it "realigns in a do for a shorter name" $ do
      t <- ct $ parsedFileGhc "./Renaming/LayoutIn4.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (7, 8) parsed
      let
        comp = do
         logm $ "renamed:" ++ (SYB.showData SYB.Renamer 0 renamed)

         newName <- mkNewGhcName Nothing "io"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns

         return (new,newName)

      ((nb,_nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "ioFun"
      (sourceFromState s) `shouldBe` "module LayoutIn4 where\n\n--Layout rule applies after 'where','let','do' and 'of'\n\n--In this Example: rename 'ioFun' to  'io'\n\nmain = io \"hello\" where io s= do  let  k = reverse s\n--There is a comment\n                                  s <- getLine\n                                  let  q = (k ++ s)\n                                  putStr q\n                                  putStr \"foo\"\n\n"
      (unspace $ showGhcQual nb) `shouldBe` "module LayoutIn4 where\nmain\n = io \"hello\"\n where\n io s\n = do { let k = reverse s;\n s <- getLine;\n let q = (k ++ s);\n putStr q;\n putStr \"foo\" }"


    ------------------------------------

    it "realigns in a do for a longer name" $ do
      t <- ct $ parsedFileGhc "./Renaming/LayoutIn4.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (7, 8) parsed
      let
        comp = do
         logm $ "renamed:" ++ (SYB.showData SYB.Renamer 0 renamed)

         newName <- mkNewGhcName Nothing "ioFunLong"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns

         return (new,newName)

      ((nb,_nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "ioFun"
      (sourceFromState s) `shouldBe` "module LayoutIn4 where\n\n--Layout rule applies after 'where','let','do' and 'of'\n\n--In this Example: rename 'ioFun' to  'io'\n\nmain = ioFunLong \"hello\" where ioFunLong s= do  let  k = reverse s\n         --There is a comment\n                                                s <- getLine\n                                                let  q = (k ++ s)\n                                                putStr q\n                                                putStr \"foo\"\n\n"
      (unspace $ showGhcQual nb) `shouldBe` "module LayoutIn4 where\nmain\n = ioFunLong \"hello\"\n where\n ioFunLong s\n = do { let k = reverse s;\n s <- getLine;\n let q = (k ++ s);\n putStr q;\n putStr \"foo\" }"

    ------------------------------------

    it "realigns in a where for a shorter name" $ do
      t <- ct $ parsedFileGhc "./Renaming/LayoutIn1.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (7, 17) parsed
      let
        comp = do
         logm $ "renamed:" ++ (SYB.showData SYB.Renamer 0 renamed)

         newName <- mkNewGhcName Nothing "q"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns

         return (new,newName)

      ((nb,_nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "sq"
      (sourceFromState s) `shouldBe` "module LayoutIn1 where\n\n--Layout rule applies after 'where','let','do' and 'of'\n\n--In this Example: rename 'sq' to 'square'.\n\nsumSquares x y= q x + q y where q x= x^pow\n--There is a comment.\n                                pow=2\n"
      (unspace $ showGhcQual nb) `shouldBe` "module LayoutIn1 where\nsumSquares x y\n = q x + q y\n where\n q x = x ^ pow\n pow = 2"


    ------------------------------------

    it "realigns in a where for a longer name" $ do
      t <- ct $ parsedFileGhc "./Renaming/LayoutIn1.hs"
      -- let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (7, 17) parsed
      let
        comp = do
         -- logm $ "renamed:" ++ (SYB.showData SYB.Renamer 0 renamed)
         logParsedSource "parsed"

         newName <- mkNewGhcName Nothing "square"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns

         return (new,newName)

      ((nb,_nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((nb,_nn),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "sq"
      (sourceFromState s) `shouldBe` "module LayoutIn1 where\n\n--Layout rule applies after 'where','let','do' and 'of'\n\n--In this Example: rename 'sq' to 'square'.\n\nsumSquares x y= square x + square y where square x= x^pow\n          --There is a comment.\n                                          pow=2\n"
      (unspace $ showGhcQual nb) `shouldBe` "module LayoutIn1 where\nsumSquares x y\n = square x + square y\n where\n square x = x ^ pow\n pow = 2"

    ------------------------------------

    it "realigns in a let/in for a shorter name" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/LayoutLet1.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (6, 6) parsed
      let
        comp = do
         logm $ "renamed:" ++ (SYB.showData SYB.Renamer 0 renamed)

         newName <- mkNewGhcName Nothing "x"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns

         return (new,newName)

      ((nb,_nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "xxx"
      (sourceFromState s) `shouldBe` "module LayoutLet1 where\n\n-- Simple let expression, rename xxx to something longer or shorter\n-- and the let/in layout should adjust accordingly\n\nfoo x = let a = 1\n            b = 2\n        in x + a + b\n\n"
      (unspace $ showGhcQual nb) `shouldBe` "module LayoutLet1 where\nfoo x\n = let\n a = 1\n b = 2\n in x + a + b"

    ------------------------------------

    it "realigns in a let/in for a longer name 1" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/LayoutLet1.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (6, 6) parsed
      let
        comp = do
         logm $ "renamed:" ++ (SYB.showData SYB.Renamer 0 renamed)

         newName <- mkNewGhcName Nothing "xxxlong"
         -- new <- renamePN n newName False renamed
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns

         return (new,newName)

      ((nb,_nn),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((nb,nn),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "xxx"
      (sourceFromState s) `shouldBe` "module LayoutLet1 where\n\n-- Simple let expression, rename xxx to something longer or shorter\n-- and the let/in layout should adjust accordingly\n\nfoo xxxlong = let a = 1\n                  b = 2\n              in xxxlong + a + b\n\n"
      (unspace $ showGhcQual nb) `shouldBe` "module LayoutLet1 where\nfoo xxxlong\n = let\n a = 1\n b = 2\n in xxxlong + a + b"


    ------------------------------------

    it "realigns in a let/in for a longer name 2" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/LayoutLet2.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (7, 6) parsed
      let
        comp = do
         logm $ "renamed:" ++ (SYB.showData SYB.Renamer 0 renamed)

         newName <- mkNewGhcName Nothing "xxxlong"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns

         return (new,newName)

      ((nb,nn),s) <- ct $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((nb,nn),s) <- ct $ runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual (n,nn)) `shouldBe` "(xxx, xxxlong)"
      (sourceFromState s) `shouldBe` "module LayoutLet2 where\n\n-- Simple let expression, rename xxx to something longer or shorter\n-- and the let/in layout should adjust accordingly\n-- In this case the tokens for xxx + a + b should also shift out\n\nfoo xxxlong = let a = 1\n                  b = 2 in xxxlong + a + b\n\n"
      (unspace $ showGhcQual nb) `shouldBe` "module LayoutLet2 where\nfoo xxxlong\n = let\n a = 1\n b = 2\n in xxxlong + a + b"


    ------------------------------------

    it "renames an exported data type" $ do
      t <- ct $ parsedFileGhc "./Renaming/RenameInExportedType2.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (6, 24) parsed
      let
        comp = do
         logm $ "parsed:" ++ (SYB.showData SYB.Parser 0 parsed)

         newName <- mkNewGhcName Nothing "NewType"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns
         logm $ "parsed:after" ++ (SYB.showData SYB.Parser 0 new)

         return (new,newName)

      ((_nb,nn),s) <- ct $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((_nb,nn),s) <- ct $ runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual (n,nn)) `shouldBe` "(Renaming.RenameInExportedType.NT, NewType)"
      (sourceFromState s) `shouldBe` "module Renaming.RenameInExportedType\n  (\n  MyType (NewType)\n  ) where\n\ndata MyType = MT Int | NewType\n\n\n"

    ------------------------------------

    it "renames a qualified usage of a name" $ do
      t <- ct $ parsedFileGhc "./Renaming/QualClient.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (10, 10) parsed
      let
        comp = do
         logm $ "parsed:" ++ (SYB.showData SYB.Parser 0 parsed)

         newName <- mkNewGhcName Nothing "foo1"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns
         logm $ "parsed:after" ++ (SYB.showData SYB.Parser 0 new)

         return (new,newName)

      ((_nb,nn),s) <- ct $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((_nb,nn),s) <- ct $ runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual (n,nn)) `shouldBe` "(Renaming.QualServer.foo, foo1)"
      (sourceFromState s) `shouldBe` "module Renaming.QualClient where\n\n{- foo is imported qualified as in QualClient. Renaming should\n   preserve the qualification there\n-}\n\nimport qualified Renaming.QualServer as QS\n\nbaz :: String\nbaz = QS.foo1 : \"hello\"\n"

    ------------------------------------

    it "renames a class op signature" $ do
      t <- ct $ parsedFileGhc "./Renaming/D4.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (13, 5) parsed
      let
        comp = do
         logm $ "parsed:" ++ (SYB.showData SYB.Parser 0 parsed)

         newName <- mkNewGhcName Nothing "isSameOrNot"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns
         logm $ "parsed:after" ++ (SYB.showData SYB.Parser 0 new)

         return (new,newName)

      ((_nb,nn),s) <- ct $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((_nb,nn),s) <- ct $ runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual (n,nn)) `shouldBe` "(Renaming.D4.isSame, isSameOrNot)"
      (sourceFromState s) `shouldBe` "module Renaming.D4 where\n\n{-Rename instance name 'isSame'' to 'sameOrNot'.\n  This refactoring affects module `D4', 'B4' and 'C4' -}\n\ndata Tree a = Leaf a | Branch (Tree a) (Tree a)\n\nfringe :: Tree a -> [a]\nfringe (Leaf x ) = [x]\nfringe (Branch left right) = fringe left ++ fringe right\n\nclass SameOrNot a where\n   isSameOrNot  :: a -> a -> Bool\n   isNotSame :: a -> a -> Bool\n\ninstance SameOrNot Int where\n   isSameOrNot a  b = a == b\n   isNotSame a b = a /= b\n\nsumSquares (x:xs) = sq x + sumSquares xs\n    where sq x = x ^pow\n          pow = 2\n\nsumSquares [] = 0\n"


    ------------------------------------

    it "renames a data decl parameter" $ do
      t <- ct $ parsedFileGhc "./Renaming/ConstructorIn3.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm = initRdrNameMap t

      let Just n = locToNameRdrPure nm (9, 13) parsed
      let
        comp = do
         logParsedSource "parsed"

         newName <- mkNewGhcName Nothing "b"
         new <- renamePN n newName PreserveQualify parsed

         putRefactParsed new emptyAnns
         logParsedSource "parsed:after"

         return (new,newName)

      ((_nb,nn),s) <- ct $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((_nb,nn),s) <- ct $ runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual (n,nn)) `shouldBe` "(a, b)"
      (sourceFromState s) `shouldBe` "module ConstructorIn3 where\n\n\n--Any type/data constructor name declared in this module can be renamed.\n--Any type variable can be renamed.\n\n--Rename tyoe variable 'a' in BTree to 'b'\n\ndata BTree b = Empty | T b (BTree b) (BTree b)\n               deriving Show\n\nbuildtree :: Ord a => [a] -> BTree a\nbuildtree [] = Empty\nbuildtree (x:xs) = insert x (buildtree xs)\n\ninsert :: Ord a => a -> BTree a -> BTree a\ninsert val Empty = T val Empty Empty\ninsert val tree@(T tval left right)\n   | val > tval = T tval left (insert val right)\n   | otherwise = T tval (insert val left) right\n\nmain :: BTree Int\nmain = buildtree [3,1,2]\n"


  -- ---------------------------------------------

  describe "qualifyToplevelName" $ do
    it "qualifies a name at the top level" $ do
      t <- ct $ parsedFileGhc "./Renaming/C7.hs"
      let parsed  = GHC.pm_parsed_source $ GHC.tm_parsed_module t
          nm      = initRdrNameMap t

      let Just n = locToNameRdrPure nm (7, 1) parsed
      let
        comp = do
         qualifyToplevelName n

         return ()
      let

      (_,s) <- ct $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- (_,s) <- ct $ runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual n) `shouldBe` "Renaming.C7.myFringe"
      (sourceFromState s) `shouldBe` "module Renaming.C7(Renaming.C7.myFringe)  where\n\nimport Renaming.D7\n\nmyFringe:: Tree a -> [a]\nmyFringe (Leaf x ) = [x]\nmyFringe (Branch left right) = Renaming.C7.myFringe left ++ fringe right\n\n\n\n\n"



  -- ---------------------------------------------

  describe "findEntity" $ do
    it "returns true if a (Located) Name is part of a HsBind 1" $ do
      pendingWith "this may go away"
      {-
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let
        comp = do
         parentr <- getRefactRenamed
         parsed <- getRefactParsed
         nm <- getRefactNameMap

         let (Just ln'@(GHC.L l _)) = locToRdrName (4,1) parsed
         let n = rdrName2NamePure nm ln'
             ln = GHC.L l n

         let declsr = hsBinds parentr
             duplicatedDecls = definingDeclsNames [n] declsr True False

             res  = findEntity ln duplicatedDecls
             res2 = findEntity n duplicatedDecls
             -- res = findEntity' ln duplicatedDecls

         return (res,res2,duplicatedDecls,ln)
      ((r,r2,d,_l),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual d) `shouldBe` "[DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x]"
      (showGhcQual _l) `shouldBe` "DupDef.Dd1.toplevel"
      ("1" ++ show r) `shouldBe` "1True"
      ("2" ++ show r2) `shouldBe` "2True"
      -}

    -- ---------------------------------

    it "returns true if a (Located) Name is part of a HsBind 2" $ do
      pendingWith "this may go away"
      {-
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let
        comp = do
         parentr <- getRefactRenamed
         parsed <- getRefactParsed
         nm <- getRefactNameMap

         let (Just ln'@(GHC.L l _)) = locToRdrName (31,7) parsed
         let n = rdrName2NamePure nm ln'
             ln = GHC.L l n

         let (Just nd) = locToNameRdrPure nm (30,1) parsed

         let declsr = hsBinds parentr
             duplicatedDecls = definingDeclsNames [nd] declsr True False

             res = findEntity ln duplicatedDecls
             res2 = findEntity  n duplicatedDecls

         return (res,res2,duplicatedDecls,ln)
      ((r,r2,d,_l),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual d) `shouldBe` "[DupDef.Dd1.dd q\n   = do { let ss = 5;\n"++
                             "          GHC.Base.return (ss GHC.Num.+ q) }]"
      (showGhcQual _l) `shouldBe` "ss"
      ("1" ++ show r) `shouldBe` "1True"
      ("2" ++ show r2) `shouldBe` "2True"
      -}

    -- -----------------------------------------------------------------

    it "returns false if a syntax phrase is not part of another" $ do
      pendingWith "this may go away"
      {-
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let
        comp = do
         parentr <- getRefactRenamed
         parsed <- getRefactParsed
         nm <- getRefactNameMap

         let (Just n) = locToNameRdrPure nm (4,1) parsed

         let (Just tup) = locToNameRdrPure nm (11,1) parsed

         let declsr = hsBinds parentr
             duplicatedDecls = definingDeclsNames [n] declsr True False

             res = findEntity tup duplicatedDecls
             -- res = findEntity' ln duplicatedDecls

         return (res,duplicatedDecls)
      ((r,d),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual d) `shouldBe` "[DupDef.Dd1.toplevel x = DupDef.Dd1.c GHC.Num.* x]"
      ("1" ++ show r) `shouldBe` "1False"
      -}

    -- -----------------------------------------------------------------

    it "Finds an entity in [HsBind Name]" $ do
      pending -- "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (MatchGroup matches _)" $ do
      pending -- "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (HsLet decls _)" $ do
      pending -- "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (HsLet _ e1)" $ do
      pending -- "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (HsLet decls _)" $ do
      pending -- "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (PatBind pat rhs _ _ _)" $ do
      pending -- "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (Match _ _ rhs)" $ do
      pending -- "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (LetStmt binds)" $ do
      pending -- "write this test"

    -- -----------------------------------------------------------------

    it "Finds an entity in (BindStmt _ rhs _ _)" $ do
      pending -- "write this test"


  -- ---------------------------------------------

  describe "modIsExported" $ do
    it "Returns True if the module is explicitly exported" $ do
      t <- ct $ parsedFileGhc "./FreeAndDeclared/Declare.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let renamed = fromJust $ GHC.tm_renamed_source t
      let (Just (modName,_)) = getModuleName parsed

      (modIsExported modName renamed) `shouldBe` True

    it "Returns True if the module is exported by default" $ do
      t <- ct $ parsedFileGhc "./FreeAndDeclared/Declare1.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let renamed = fromJust $ GHC.tm_renamed_source t
      let (Just (modName,_)) = getModuleName parsed

      (modIsExported modName renamed) `shouldBe` True

    it "Returns False if the module is explicitly not exported" $ do
      t <- ct $ parsedFileGhc "./FreeAndDeclared/Declare2.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let renamed = fromJust $ GHC.tm_renamed_source t
      let (Just (modName,_)) = getModuleName parsed

      (modIsExported modName renamed) `shouldBe` False

  -- ---------------------------------------------

  describe "isExported" $ do
    it "returns True if a GHC.Name is exported" $ do
      t <- ct $ parsedFileGhc "./Renaming/B1.hs"

      let
        comp = do
         parsed <- getRefactParsed
         nm <- getRefactNameMap

         let (Just myFringe) = locToNameRdrPure nm (11,1) parsed
         let (Just sumSquares) = locToNameRdrPure nm (15,1) parsed

         exMyFring <- isExported myFringe
         exSumSquares <- isExported sumSquares

         return (myFringe,exMyFring,sumSquares,exSumSquares)
      ((mf,emf,ss,ess),_s) <- ct $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t}) testOptions

      (showGhcQual mf) `shouldBe` "Renaming.B1.myFringe"
      emf `shouldBe` True
      (showGhcQual ss) `shouldBe` "Renaming.B1.sumSquares"
      ess `shouldBe` False

  -- ---------------------------------------------

  describe "addHiding" $ do
    it "add a hiding entry to the imports with no existing hiding" $ do
      t1 <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let
        comp = do
         clearParsedModule
         t2 <- parseSourceFileTest "./DupDef/Dd2.hs"
         let renamed2 = fromJust $ GHC.tm_renamed_source t2

         let parsed1 = GHC.pm_parsed_source $ GHC.tm_parsed_module t1
         let parsed2 = GHC.pm_parsed_source $ GHC.tm_parsed_module t2

         -- let mn = locToName (4,1) renamed1
         -- let (Just (GHC.L _ _n)) = mn

         let Just (modName,_) = getModuleName parsed1
         let
           n1 = mkRdrName "n1"
           n2 = mkRdrName "n2"
         res  <- addHiding modName parsed2 [n1,n2]
         putRefactParsed res emptyAnns

         return (res,renamed2)
      ((_r,_r2),s) <- ct $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t1}) testOptions
      -- ((_r,_r2),s) <- ct $ runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t1}) testOptions

      (sourceFromState s) `shouldBe` "module DupDef.Dd2 where\n\nimport DupDef.Dd1 hiding (n1,n2)\n\n\nf2 x = ff (x+1)\n\nmm = 5\n\n\n"

    ------------------------------------

    it "adds a hiding entry to the imports with an existing hiding" $ do
      t1 <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let
        comp = do

         clearParsedModule
         t2 <- parseSourceFileTest "./DupDef/Dd3.hs"
         let renamed2 = fromJust $ GHC.tm_renamed_source t2

         let parsed1 = GHC.pm_parsed_source $ GHC.tm_parsed_module t1
         let parsed2 = GHC.pm_parsed_source $ GHC.tm_parsed_module t2

         -- let mn = locToName (4,1) renamed1
         -- let (Just (GHC.L _ _n)) = mn

         let Just (modName,_) = getModuleName parsed1
         let
           n1 = mkRdrName "n1"
           n2 = mkRdrName "n2"
         res  <- addHiding modName parsed2 [n1,n2]

         return (res,renamed2)
      ((_r,_r2),s) <- ct $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t1}) testOptions
      (sourceFromState s) `shouldBe` "module DupDef.Dd3 where\n\nimport DupDef.Dd1 hiding (dd,n1,n2)\n\n\nf2 x = ff (x+1)\n\nmm = 5\n\n\n"

  -- ---------------------------------------------

  describe "equivalentNameInNewMod" $ do
    it "finds equivalent name for normal import" $ do
      let
        ctc = cdAndDo "./test/testdata/cabal/foo"
      let
        comp = do
          parseSourceFileGhc "./src/Foo/Bar.hs"
          parsed <- getRefactParsed
          nm <- getRefactNameMap
          let Just old = locToNameRdrPure nm (3,1) parsed
          parseSourceFileGhc "./src/Main.hs"
          [equiv] <- equivalentNameInNewMod old
          return (old,equiv)

      ((o,e),_s) <- ctc $ runRefactGhc comp initialState testOptions
      -- ((o,e),_s) <- ctc $ runRefactGhc comp initialLogOnState testOptions
      (showGhcQual (o,e)) `shouldBe` "(Foo.Bar.bar, Foo.Bar.bar)"
      -- putStrLn( "(GHC.nameUnique o,GHC.nameUnique e)" ++ (showGhcQual (GHC.nameUnique o,GHC.nameUnique e)))
      -- (GHC.nameUnique o == GHC.nameUnique e) `shouldBe` True -- seems to reuse the already loaded names?

    -- ---------------------------------

    it "finds equivalent name for qualified import" $ do
      let
        ctc = cdAndDo "./test/testdata/cabal/cabal4"
      let
        comp = do
          parseSourceFileGhc "./src/Foo/Bar.hs"
          parsed <- getRefactParsed
          nm <- getRefactNameMap
          let Just old = locToNameRdrPure nm (3,1) parsed
          parseSourceFileGhc "./src/main4.hs"
          parsed' <- getRefactParsed
          [equiv] <- equivalentNameInNewMod old

          let Just ((GHC.L _l new)) = locToRdrName (11,12) parsed'
          return (old,equiv,new)

      ((o,e,n),_s) <- ctc $ runRefactGhc comp initialState testOptions
      (showGhcQual (o,e,n)) `shouldBe` "(Foo.Bar.baz, Foo.Bar.baz, B.baz)"
      -- (showGhcQual (GHC.nameUnique o,GHC.nameUnique e)) `shouldBe` ""
      -- (GHC.nameUnique o == GHC.nameUnique e) `shouldBe` True -- seems to reuse the already loaded names?

  -- ---------------------------------------------

  describe "usedWithoutQualR" $ do
    it "returns True if the identifier is used unqualified Dd1" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let
        comp = do
          parsed <- getRefactParsed
          nm <- getRefactNameMap

          let Just n@name = locToNameRdrPure nm (14,21) parsed
          let res = usedWithoutQualR name parsed
          return (res,n,name)

      ((r,n1,n2),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (GHC.getOccString n2) `shouldBe` "zip"
      (showGhcQual n1) `shouldBe` "GHC.List.zip"
      r `shouldBe` True

    -- ---------------------------------

    it "returns True if the identifier is used unqualified Dd3" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd3.hs"
      let
        comp = do
          parsed <- getRefactParsed
          nm <- getRefactNameMap

          let Just n@name = locToNameRdrPure nm (8,1) parsed
          let res = usedWithoutQualR name parsed
          return (res,n,name)

      ((r,n1,n2),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (GHC.getOccString n2) `shouldBe` "mm"
      (showGhcQual n1) `shouldBe` "DupDef.Dd3.mm"
      r `shouldBe` True

    -- ---------------------------------

    it "returns False if the identifier is used qualified" $ do
      t <- ct $ parsedFileGhc "./FreeAndDeclared/Declare.hs"
      let
        comp = do
          parsed <- getRefactParsed
          nm <- getRefactNameMap

          let Just n@name = locToNameRdrPure nm (36,12) parsed
          let Just (GHC.L _ namep) = locToRdrName (36,12) parsed
          let res = usedWithoutQualR name parsed
          return (res,namep,name,n)
      ((r,np,n1,n2),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (myShow np) `shouldBe` "Qual:G:gshow"
      (myShow $ GHC.getRdrName n1) `shouldBe` "Exact:Data.Generics.Text.gshow"
      (showGhcQual $ GHC.getRdrName n1) `shouldBe` "Data.Generics.Text.gshow"
      (showGhcQual n2) `shouldBe` "Data.Generics.Text.gshow"
      r `shouldBe` False

  -- ---------------------------------------------

  describe "isExplicitlyExported" $ do
    it "Returns True if the identifier is explicitly exported" $ do
      pending -- "write this "

    it "Returns False if the identifier is not explicitly exported" $ do
      pending -- "write this "

  -- ---------------------------------------------

  describe "causeNameClashInExports" $ do
    it "Returns True if there is a clash" $ do

      t <- ct $ parsedFileGhc "./Renaming/ConflictExport.hs"
      let nm = initRdrNameMap t
      let parsed  = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let modu = GHC.ms_mod $ GHC.pm_mod_summary $ GHC.tm_parsed_module t

      -- Is this the right module?
      let Just (modName,_) = getModuleName parsed

      let Just myFringe = locToNameRdrPure nm (9,1) parsed
      (showGhcQual myFringe) `shouldBe` "Renaming.ConflictExport.myFringe"

      -- old name is myFringe
      -- new name is "Renaming.ConflictExport.fringe"
      let newName = mkTestGhcName 1 (Just modu) "fringe"

      (showGhcQual modu) `shouldBe` "main@main:Renaming.ConflictExport"
      (showGhcQual newName) `shouldBe` "Renaming.ConflictExport.fringe"

      (showGhcQual $ GHC.localiseName newName) `shouldBe` "fringe"

      let res = causeNameClashInExports nm myFringe newName modName parsed
      res `shouldBe` True

    it "Returns False if there is no clash" $ do
      t <- ct $ parsedFileGhc "./Renaming/ConflictExport.hs"
      let nm = initRdrNameMap t
      let parsed  = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let modu = GHC.ms_mod $ GHC.pm_mod_summary $ GHC.tm_parsed_module t

      -- Is this the right module?
      let Just (modName,_) = getModuleName parsed

      let Just myFringe = locToNameRdrPure nm (9,1) parsed
      (showGhcQual myFringe) `shouldBe` "Renaming.ConflictExport.myFringe"

      -- old name is myFringe
      -- new name is "Renaming.ConflictExport.fringe"
      let newName = mkTestGhcName 1 (Just modu) "fringeOk"

      (showGhcQual modu) `shouldBe` "main@main:Renaming.ConflictExport"
      (showGhcQual newName) `shouldBe` "Renaming.ConflictExport.fringeOk"

      (showGhcQual $ GHC.localiseName newName) `shouldBe` "fringeOk"

      let res = causeNameClashInExports nm myFringe newName modName parsed
      res `shouldBe` False

  -- ---------------------------------------

  describe "rmQualifier" $ do
    it "removes the qualifiers from a list of identifiers in a given syntax phrase" $ do
      let
        comp = do
          parseSourceFileGhc "./TypeUtils/Qualified.hs"
          parsed <- getRefactParsed
          decls <- liftT $ hsDecls parsed
          nm <- getRefactNameMap

          let Just foo = locToNameRdrPure nm (5, 1) parsed
          let Just baz = locToNameRdrPure nm (5, 27) parsed

          let [fooDecl] = definingDeclsRdrNames nm [foo] decls False False

          res <- rmQualifier [baz] fooDecl
          return (res,fooDecl,baz)

      ((r,d,n1),_s) <- ct $ runRefactGhc comp initialState  testOptions
      (showGhcQual n1) `shouldBe` "TypeUtils.C.baz"
      (showGhcQual d) `shouldBe` "main = return TypeUtils.C.baz"
      (showGhcQual r) `shouldBe` "main = return baz"

    it "Removes the qualifiers and updates the tokens" $ do
      pending -- "Is this needed?"

  -- ---------------------------------------

  describe "usedByRhs" $ do
    it "returns True if a given identifier is used in the RHS of a syntax element" $ do
      t <- ct $ parsedFileGhc "./MoveDef/Demote.hs"
      let
        comp = do
          parsed <- getRefactParsed
          declsp <- liftT $ hsDecls parsed
          nm <- getRefactNameMap

          let Just tl   = locToNameRdrPure nm (4,1) parsed
          let Just name = locToNameRdrPure nm (7,1) parsed
          let decls = definingDeclsRdrNames nm [tl] declsp False False
          decls' <- rmQualifier [name] decls

          let res = usedByRhsRdr nm decls' [name]

          return (res,decls,tl,name)

      ((r,d,n1,n2),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual n1) `shouldBe` "MoveDef.Demote.toplevel"
      (showGhcQual n2) `shouldBe` "MoveDef.Demote.c"
      (showGhcQual d) `shouldBe` "[toplevel x = c * x]"
      r `shouldBe` True

  -- ---------------------------------------

  describe "autoRenameLocalVar" $ do
    it "renames an identifier if it is used and updates tokens" $ do
      t <- ct $ parsedFileGhc "./Demote/WhereIn4.hs"
      let
        comp = do
          parsed <- getRefactParsed
          nm <- getRefactNameMap
          tlDecls <- liftT $ hsDecls parsed

          let Just tl   = locToNameRdrPure nm (11,1) parsed
          let Just name = locToNameRdrPure nm (11,21) parsed
          let [decls] = definingDeclsRdrNames nm [tl] tlDecls False True
          decls' <- autoRenameLocalVar name decls

          return (decls',decls,tl,name)

      ((r,d,n1,n2),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((r,d,n1,n2),s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions
      (showGhcQual n1) `shouldBe` "Demote.WhereIn4.sumSquares"
      (showGhcQual n2) `shouldBe` "p"
      (showGhcQual d) `shouldBe` "sumSquares x y\n  = sq p x + sq p y\n  where\n      p = 2"
      (showGhcQual r) `shouldBe` "sumSquares x y\n  = sq p_1 x + sq p_1 y\n  where\n      p_1 = 2"
      (exactPrintFromState s r) `shouldBe` "\n\n--A definition can be demoted to the local 'where' binding of a friend declaration,\n--if it is only used by this friend declaration.\n\n--Demoting a definition narrows down the scope of the definition.\n--In this example, demote the top level 'sq' to 'sumSquares'\n--In this case (there is single matches), if possible,\n--the parameters will be folded after demoting and type sigature will be removed.\n\nsumSquares x y = sq p_1 x + sq p_1 y\n         where p_1=2"

  -- ---------------------------------------

  describe "mkNewName" $ do
    it "Makes a new name that does not clash with existing ones" $ do
      (mkNewName "f" ["f"] 0) `shouldBe` "f_1"
      (mkNewName "f" ["g"] 0) `shouldBe` "f"
      (mkNewName "f" ["g","f_1","f"] 0) `shouldBe` "f_2"

  -- ---------------------------------------

  describe "addImportDecl" $ do
    it "adds an import entry to a module with already existing, non conflicting imports and other declarations" $ do
      t <- ct $ parsedFileGhc "./DupDef/Dd1.hs"
      let
        comp = do
         clearParsedModule
         parseSourceFileGhc "./DupDef/Dd2.hs"
         renamed2 <- getRefactRenamed
         parsed2 <- getRefactParsed

         let listModName  = GHC.mkModuleName "Data.List"
         res  <- addImportDecl parsed2 listModName Nothing False False False Nothing False []
         putRefactParsed res emptyAnns

         return (res,renamed2)
      ((_r,_r2),s) <- ct $ runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (sourceFromState s) `shouldBe` "module DupDef.Dd2 where\n\nimport DupDef.Dd1\nimport Data.List\n\n\nf2 x = ff (x+1)\n\nmm = 5\n\n\n"

    -- ---------------------------------

    it "adds an import entry to a module with some declaration, but no explicit imports." $ do
      t <- ct $ parsedFileGhc "./TypeUtils/Simplest.hs"
      let
        comp = do

         let renamed1 = fromJust $ GHC.tm_renamed_source t
         parsed <- getRefactParsed

         let listModName  = GHC.mkModuleName "Data.List"
         res  <- addImportDecl parsed listModName Nothing False False False Nothing False []
         putRefactParsed res emptyAnns

         return (res,renamed1)
      ((_r,_r2),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (sourceFromState s) `shouldBe` "module Simplest where\nimport Data.List\n\n\nsimple x = x\n"

    -- ---------------------------------

    it "adds an import entry to a module with explicit imports, but no declarations." $ do
      t <- ct $ parsedFileGhc "./TypeUtils/JustImports.hs"
      let
        comp = do
         let renamed1 = fromJust $ GHC.tm_renamed_source t
         parsed <- getRefactParsed

         let listModName  = GHC.mkModuleName "Data.List"
         res  <- addImportDecl parsed listModName Nothing False False False Nothing False []
         putRefactParsed res emptyAnns

         return (res,renamed1)
      ((_r,_r2),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (sourceFromState s) `shouldBe` "module JustImports where\n\nimport Data.Maybe\nimport Data.List\n"

    -- ---------------------------------

    it "adds an import entry to a module with no declarations and no explicit imports" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/Empty.hs"
      let
        comp = do
         renamed1 <- getRefactRenamed
         parsed <- getRefactParsed

         let listModName  = GHC.mkModuleName "Data.List"
         res  <- addImportDecl parsed listModName Nothing False False False Nothing False []
         putRefactParsed res emptyAnns

         return (res,renamed1)
      ((_r,_r2),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      (sourceFromState s) `shouldBe` "module Empty where\nimport Data.List\n\n"


  -- ---------------------------------------

  describe "addItemsToImport" $ do
    it "adds an item to an import entry with no items" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/JustImports.hs"
      let
        comp = do
         parsed <- getRefactParsed

         let modName  = GHC.mkModuleName "Data.Maybe"
         -- itemName <- mkNewGhcName Nothing "fromJust"
         let  itemName = mkRdrName "fromJust"

         res  <- addItemsToImport modName Nothing (Left [itemName]) parsed
         putRefactParsed res emptyAnns

         return (res)
      ((_r),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions

      -- This is the correct behavior. If the import doesn't have an import list, creating
      -- one for an item effectively reduces the imported interface.
      (sourceFromState s) `shouldBe` "module JustImports where\n\nimport Data.Maybe\n"

-- Not sure if this should be a test
{-    it "Try adding more than one item to an existing import entry with no items, using separate calls." $ do
      let
        comp = do
         (t1,_toks1)  <- parseSourceFileTest "./TypeUtils/JustImports.hs"
         -- clearParsedModule
         let renamed1 = fromJust $ GHC.tm_renamed_source t1

         let modName  = GHC.mkModuleName "Data.Maybe"
         itemName <- mkNewGhcName Nothing "fromJust"

         res  <- addItemsToImport modName renamed1 [itemName] --listModName Nothing False False False Nothing False []

         itemName2 <- mkNewGhcName Nothing "isJust"

         res2 <- addItemsToImport modName res [itemName2]
         toks <- fetchToks

         return (res2,toks,renamed,_toks1)
      ((_r,t,r2,tk2),s) <- ct $ runRefactGhcState comp
      (GHC.showRichTokenStream t) `shouldBe` "module JustImports where\n\n import Data.Maybe (fromJust,isJust)\n "
-}

    -- ---------------------------------

    it "adds an item to an import entry with existing items" $ do
      t <- ct $ parsedFileGhc "./TypeUtils/SelectivelyImports.hs"
      let
        comp = do
         parsed <-getRefactParsed

         let modName  = GHC.mkModuleName "Data.Maybe"
         let  itemName = mkRdrName "isJust"

         res  <- addItemsToImport modName Nothing (Left [itemName]) parsed
         putRefactParsed res emptyAnns
         return (res)
      ((_r),s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      (sourceFromState s) `shouldBe` "module SelectivelyImports where\n\nimport Data.Maybe (fromJust,isJust)\n\n__ = id\n"

{- -- test after properly inserting conditional identifier
    it "Add an item to an import entry with existing items, passing existing conditional identifier." $ do
      let
        comp = do
         (t1,_toks1)  <- parseSourceFileTest "./TypeUtils/SelectivelyImports.hs"
         -- clearParsedModule
         let renamed1 = fromJust $ GHC.tm_renamed_source t1

         let modName  = GHC.mkModuleName "Data.Maybe"
         itemName <- mkNewGhcName Nothing "isJust"
         conditionalId <- mkNewGhcName Nothing "fromJust"

         res  <- addItemsToImport modName renamed1 [itemName] (Just conditionalId)
         toks <- fetchToks

         return (res,toks,renamed1,_toks1)
      ((_r,t,r2,tk2),s) <- ct $ runRefactGhcState comp
      (GHC.showRichTokenStream t) `shouldBe` "module SelectivelyImports where\n\n import Data.Maybe (fromJust,isJust)\n\n __ = id\n "

    it "Add an item to an import entry with existing items, passing missing conditional identifier" $ do
      let
        comp = do
         (t1,_toks1)  <- parseSourceFileTest "./TypeUtils/SelectivelyImports.hs"
         -- clearParsedModule
         let renamed1 = fromJust $ GHC.tm_renamed_source t1

         let modName  = GHC.mkModuleName "Data.Maybe"
         itemName <- mkNewGhcName Nothing "isJust"

         res  <- addItemsToImport modName renamed1 [itemName] (Just itemName)
         toks <- fetchToks

         return (res,toks,renamed1,_toks1)
      ((_r,t,r2,tk2),s) <- ct $ runRefactGhcState comp
      (GHC.showRichTokenStream t) `shouldBe` "module SelectivelyImports where\n\n import Data.Maybe (fromJust)\n\n __ = id\n "
-}

  -- ---------------------------------------

  describe "addItemsToExport" $ do
    it "adds an item to an export entry with no items" $ do
      pendingWith "write these tests"

  -- ---------------------------------------

  describe "unspace" $ do
    it "Reduces all sequences of more than one space to a single one" $ do
      (unspace []) `shouldBe` []
      (unspace "a") `shouldBe` "a"
      (unspace "a bc") `shouldBe` "a bc"
      (unspace "a  bc") `shouldBe` "a bc"
      (unspace "ab   c") `shouldBe` "ab c"
      (unspace "  ab   c") `shouldBe` " ab c"
      (unspace "abc    ") `shouldBe` "abc "

  -- ---------------------------------------

  describe "isFieldName" $ do
    it "returns True if a Name is a field name" $ do
      t <- ct $ parsedFileGhc "./Renaming/Field3.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let nm = initRdrNameMap t

      let Just nf = locToNameRdrPure nm (10,21) parsed
      let Just n  = locToNameRdrPure nm (10,1)  parsed

      (showGhcQual n) `shouldBe` "Field3.absPoint"
      (showGhcQual nf) `shouldBe` "Field3.pointx"

  -- ---------------------------------------

  describe "name predicates" $ do
    it "classifies names" $ do
      t <- ct $ parsedFileGhc "./Cons.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      let nm = initRdrNameMap t

      let Just n1 = locToNameRdrPure nm (3,6)  parsed
      let Just n2 = locToNameRdrPure nm (3,12) parsed
      let Just n3 = locToNameRdrPure nm (3,16) parsed
      let Just n4 = locToNameRdrPure nm (5,1)  parsed
      let Just n5 = locToNameRdrPure nm (8,5)  parsed

      (showGhcQual n1) `shouldBe` "Main.Foo"
      "11" ++ (show $ GHC.isTyVarName n1)   `shouldBe` "11False"
      "12" ++ (show $ GHC.isTyConName n1)   `shouldBe` "12True"
      "13" ++ (show $ GHC.isDataConName n1) `shouldBe` "13False"
      "14" ++ (show $ GHC.isValName n1)     `shouldBe` "14False"
      "15" ++ (show $ GHC.isVarName n1)     `shouldBe` "15False"

      (showGhcQual n2) `shouldBe` "Main.Ff"
      "21" ++ (show $ GHC.isTyVarName n2)   `shouldBe` "21False"
      "22" ++ (show $ GHC.isTyConName n2)   `shouldBe` "22False"
      "23" ++ (show $ GHC.isDataConName n2) `shouldBe` "23True"
      "24" ++ (show $ GHC.isValName n2)     `shouldBe` "24True"
      "25" ++ (show $ GHC.isVarName n2)     `shouldBe` "25False"

      (showGhcQual n3) `shouldBe` "Main.fooA" -- field name
      "31" ++ (show $ GHC.isTyVarName n3)   `shouldBe` "31False"
      "32" ++ (show $ GHC.isTyConName n3)   `shouldBe` "32False"
      "33" ++ (show $ GHC.isDataConName n3) `shouldBe` "33False"
      "34" ++ (show $ GHC.isValName n3)     `shouldBe` "34True"
      "35" ++ (show $ GHC.isVarName n3)     `shouldBe` "35True"

      (showGhcQual n4) `shouldBe` "Main.xx"
      "41" ++ (show $ GHC.isTyVarName n4)   `shouldBe` "41False"
      "42" ++ (show $ GHC.isTyConName n4)   `shouldBe` "42False"
      "43" ++ (show $ GHC.isDataConName n4) `shouldBe` "43False"
      "44" ++ (show $ GHC.isValName n4)     `shouldBe` "44True"
      "45" ++ (show $ GHC.isVarName n4)     `shouldBe` "45True"

      (showGhcQual n5) `shouldBe` "GHC.Classes.=="
      "51" ++ (show $ GHC.isTyVarName n5)   `shouldBe` "51False"
      "52" ++ (show $ GHC.isTyConName n5)   `shouldBe` "52False"
      "53" ++ (show $ GHC.isDataConName n5) `shouldBe` "53False"
      "54" ++ (show $ GHC.isValName n5)     `shouldBe` "54True"
      "55" ++ (show $ GHC.isVarName n5)     `shouldBe` "55True"

  -- ---------------------------------------------------------------------

  describe "rdrName2Name" $ do

    it "finds a Name for a top-level RdrName" $ do
      t <- ct $ parsedFileGhc "./TokenTest.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let
        comp = do
          let (Just rdr)  = locToRdrName (5,1) parsed
              -- (Just name) = locToName    (5,1) renamed
          nname <- rdrName2Name rdr
          return (rdr,nname)
      ((r,n),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((r,n),_s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual (r,n)) `shouldBe` "(bob, TokenTest.bob)"

    -- ---------------------------------

    it "finds a Name for a local RdrName" $ do
      t <- ct $ parsedFileGhc "./TokenTest.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let
        comp = do
          let (Just rdr)  = locToRdrName (14,7) parsed
          nname <- rdrName2Name rdr
          return (rdr,nname)
      ((r,n),_s) <- runRefactGhc comp (initialState { rsModule = initRefactModule [] t }) testOptions
      -- ((r,n),_s) <- runRefactGhc comp (initialLogOnState { rsModule = initRefactModule [] t }) testOptions

      (showGhcQual (r,n)) `shouldBe` "(bar, bar)"

  -- ---------------------------------------

myShow :: GHC.RdrName -> String
myShow n = case n of
  GHC.Unqual on  -> ("Unqual:" ++ (showGhcQual on))
  GHC.Qual ms on -> ("Qual:" ++ (showGhcQual ms) ++ ":" ++ (showGhcQual on))
  GHC.Orig ms on -> ("Orig:" ++ (showGhcQual ms) ++ ":" ++ (showGhcQual on))
  GHC.Exact en   -> ("Exact:" ++ (showGhcQual en))

-- ---------------------------------------------------------------------
-- EOF
