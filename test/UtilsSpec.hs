module UtilsSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import           TestUtils

import qualified Digraph    as GHC
import qualified FastString as GHC
import qualified GHC        as GHC
import qualified GhcMonad   as GHC
import qualified Name       as GHC
import qualified Outputable as GHC
import qualified RdrName    as GHC
import qualified SrcLoc     as GHC

import Control.Monad.State
import Data.Maybe
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = hspec spec

spec :: Spec
spec = do

  describe "locToExp on ParsedSource" $ do
    it "finds the largest leftmost expression contained in a given region #1" $ do
      (t, toks) <- parsedFileBGhc
      let mod = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let (Just expr) = locToExp (7,7) (7,43) mod :: Maybe (GHC.Located (GHC.HsExpr GHC.RdrName))
      getLocatedStart expr `shouldBe` (7,9)
      getLocatedEnd   expr `shouldBe` (7,42)

    it "finds the largest leftmost expression contained in a given region #2" $ do
      -- ((_, _, mod), toks) <- parsedFileBGhc
      (t, toks) <- parsedFileBGhc
      let mod = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let (Just expr) = locToExp (7,7) (7,41) mod :: Maybe (GHC.Located (GHC.HsExpr GHC.RdrName))
      getLocatedStart expr `shouldBe` (7,12)
      getLocatedEnd   expr `shouldBe` (7,19)

    it "finds the largest leftmost expression in RenamedSource" $ do
      -- ((_, renamed, _), toks) <- parsedFileBGhc
      (t, toks) <- parsedFileBGhc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let (Just expr) = locToExp (7,7) (7,41) renamed :: Maybe (GHC.Located (GHC.HsExpr GHC.Name))
      getLocatedStart expr `shouldBe` (7,12)
      getLocatedEnd   expr `shouldBe` (7,19)

  describe "locToExp on RenamedSource" $ do
    it "finds the largest leftmost expression contained in a given region #1" $ do
      -- ((_, Just renamed, _), toks) <- parsedFileBGhc
      (t, toks) <- parsedFileBGhc
      let renamed = fromJust $ GHC.tm_renamed_source t

      let (Just expr) = locToExp (7,7) (7,43) renamed :: Maybe (GHC.Located (GHC.HsExpr GHC.Name))
      getLocatedStart expr `shouldBe` (7,9)
      getLocatedEnd   expr `shouldBe` (7,42)

  -- -------------------------------------------------------------------

  describe "sameOccurrence" $ do
    it "checks that a given syntax element is the same occurrence as another" $ do
      pending "write this test"

    it "gives the original list, if applied twice" $ property $
      \xs -> reverse (reverse xs) == (xs :: [Int])

  -- -------------------------------------------------------------------

  describe "isVarId" $ do
    it "returns True if a string is a lexically valid variable name" $ do
      isVarId "foo" `shouldBe` True

    it "returns False if a string is not lexically valid variable name" $ do
      isVarId "Foo" `shouldBe` False


  -- -------------------------------------------------------------------

  describe "getModuleName" $ do
    it "returns a string for the module name if there is one" $ do
      -- modInfo@((_, _, mod), toks) <- parsedFileBGhc
      modInfo@(t, toks) <- parsedFileBGhc
      let mod = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let (Just (modname,modNameStr)) = getModuleName mod
      -- let modNameStr = "foo"
      modNameStr `shouldBe` "TypeUtils.B"

    it "returns Nothing for the module name otherwise" $ do
      -- modInfo@((_, _, mod), toks) <- parsedFileNoMod
      modInfo@(t, toks) <- parsedFileNoMod
      let mod = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      getModuleName mod `shouldBe` Nothing

  -- -------------------------------------------------------------------

  describe "modIsExported" $ do
    it "needs a test or two" $ do
      pending "write this test"

  -- -------------------------------------------------------------------

  describe "clientModsAndFiles" $ do
    it "can only be called in a live RefactGhc session" $ do
      pending "write this test"

    it "gets modules which directly or indirectly import a module #1" $ do
      -- TODO: harvest this commonality
      let
        comp = do
         (p,toks) <- parseFileMGhc -- Load the main file first
         g <- clientModsAndFiles $ GHC.mkModuleName "S1"
         return g
      (mg,_s) <- runRefactGhcState comp
      GHC.showPpr (map GHC.ms_mod mg) `shouldBe` "[main:M2, main:M3, main:Main]"

    it "gets modules which directly or indirectly import a module #2" $ do
      let
        comp = do
         (p,toks) <- parseFileMGhc -- Load the main file first
         g <- clientModsAndFiles $ GHC.mkModuleName "M3"
         return g
      (mg,_s) <- runRefactGhcState comp
      GHC.showPpr (map GHC.ms_mod mg) `shouldBe` "[main:Main]"

  -- -------------------------------------------------------------------

  describe "serverModsAndFiles" $ do
    it "can only be called in a live RefactGhc session" $ do
      pending "write this test"

    it "gets modules which are directly or indirectly imported by a module #1" $ do
      let
        comp = do
         (p,toks) <- parseFileMGhc -- Load the main file first
         g <- serverModsAndFiles $ GHC.mkModuleName "S1"
         return g
      (mg,_s) <- runRefactGhcState comp
      GHC.showPpr (map GHC.ms_mod mg) `shouldBe` "[]"

    it "gets modules which are directly or indirectly imported by a module #2" $ do
      let
        comp = do
         (p,toks) <- parseFileMGhc -- Load the main file first
         g <- serverModsAndFiles $ GHC.mkModuleName "M3"
         return g
      (mg,_s) <- runRefactGhcState comp
      GHC.showPpr (map GHC.ms_mod mg) `shouldBe` "[main:M2, main:S1]"


  -- -------------------------------------------------------------------

  describe "getCurrentModuleGraph" $ do
    it "gets the module graph for the currently loaded modules" $ do
      let
        comp = do
         (p,toks) <- parseFileBGhc -- Load the file first
         g <- getCurrentModuleGraph
         return g
      (mg,_s) <- runRefactGhcState comp
      map (\m -> GHC.moduleNameString $ GHC.ms_mod_name m) mg `shouldBe` (["TypeUtils.B","TypeUtils.C"])
      map (\m -> show $ GHC.ml_hs_file $ GHC.ms_location m) mg `shouldBe` (["Just \"./test/testdata/TypeUtils/B.hs\""
                                                                           ,"Just \"./test/testdata/TypeUtils/C.hs\""])


    it "gets the updated graph, after a refactor" $ do
      pending "write this test"

  -- -------------------------------------------------------------------

  describe "sortCurrentModuleGraph" $ do
    it "needs a test or two" $ do
      let
        comp = do
         (p,toks) <- parseFileBGhc -- Load the file first
         g <- sortCurrentModuleGraph
         return g
      (mg,_s) <- runRefactGhcState comp
      (GHC.showPpr $ map (\m -> GHC.ms_mod m) (GHC.flattenSCCs mg)) `shouldBe` "[main:TypeUtils.C, main:TypeUtils.B]"

  -- -------------------------------------------------------------------

  describe "getModuleGhc" $ do
    it "retrieves a module from an existing module graph" $ do
      let
        comp = do
          loadModuleGraphGhc $ Just "./test/testdata/M.hs"
          m <- getModuleGhc "./test/testdata/S1.hs"
          g <- clientModsAndFiles $ GHC.mkModuleName "S1"

          return (m,g)
      -- (( ( ((_,_,parsed),_)), mg ), _s) <- runRefactGhcState comp
      (( ( (t,_)), mg ), _s) <- runRefactGhcState comp
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      (show $ getModuleName parsed) `shouldBe` "Just (S1,\"S1\")"
      GHC.showPpr (map GHC.ms_mod mg) `shouldBe` "[main:M2, main:M3, main:Main]"

    it "loads the module and dependents if no existing module graph" $ do
      let
        comp = do
          m <- getModuleGhc "./test/testdata/S1.hs"
          g <- clientModsAndFiles $ GHC.mkModuleName "S1"

          return (m,g)
      -- (( ( ((_,_,parsed),_)), mg ), _s) <- runRefactGhcState comp
      (( ( (t,_)), mg ), _s) <- runRefactGhcState comp
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      (show $ getModuleName parsed) `shouldBe` "Just (S1,\"S1\")"
      GHC.showPpr (map GHC.ms_mod mg) `shouldBe` "[]"

    it "retrieves a module from an existing module graph #2" $ do
      let
        comp = do
          loadModuleGraphGhc $ Just "./test/testdata/DupDef/Dd2.hs"
          m <- getModuleGhc "./test/testdata/DupDef/Dd1.hs"
          g <- clientModsAndFiles $ GHC.mkModuleName "DupDef.Dd1"

          return (m,g)
      -- (( ( ((_,_,parsed),_)), mg ), _s) <- runRefactGhcState comp
      (( ( (t,_)), mg ), _s) <- runRefactGhcState comp
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      (show $ getModuleName parsed) `shouldBe` "Just (DupDef.Dd1,\"DupDef.Dd1\")"
      GHC.showPpr (map GHC.ms_mod mg) `shouldBe` "[main:DupDef.Dd2]"


  -- -------------------------------------------------------------------

  describe "runRefactGhc" $ do
    it "contains a State monad" $ do
      (_,s) <- runRefactGhcState comp
      (rsUniqState s) `shouldBe` 100

    it "contains the GhcT monad" $ do
      (r,_) <- runRefactGhcState comp
      r `shouldBe` ("[\"TypeUtils.B      ( test/testdata/TypeUtils/B.hs, interpreted )\""
                  ++",\"TypeUtils.C      ( test/testdata/TypeUtils/C.hs, interpreted )\"]")



-- ---------------------------------------------------------------------
-- Helper functions

bFileName :: GHC.FastString
bFileName = GHC.mkFastString "./test/testdata/TypeUtils/B.hs"

parsedFileBGhc :: IO (ParseResult,[PosToken])
parsedFileBGhc = parsedFileGhc "./test/testdata/TypeUtils/B.hs"

parsedFileMGhc :: IO (ParseResult,[PosToken])
parsedFileMGhc = parsedFileGhc "./test/testdata/M.hs"

parseFileBGhc :: RefactGhc (ParseResult, [PosToken])
parseFileBGhc = parseSourceFileGhc fileName
  where
    fileName = "./test/testdata/TypeUtils/B.hs"

parseFileMGhc :: RefactGhc (ParseResult, [PosToken])
parseFileMGhc = parseSourceFileGhc fileName
  where
    fileName = "./test/testdata/M.hs"

-- parsedFileNoMod = unsafeParseSourceFile fileName
parsedFileNoMod = parsedFileGhc fileName
  where
    fileName = "./test/testdata/NoMod.hs"

comp :: RefactGhc String
comp = do
    s <- get
    modInfo@(t, toks) <- parseSourceFileGhc "./test/testdata/TypeUtils/B.hs"

    g <- GHC.getModuleGraph
    gs <- mapM GHC.showModule g
    GHC.liftIO (putStrLn $ "modulegraph=" ++ (show gs))

    put (s {rsUniqState = 100})
    return (show gs)


-- ---------------------------------------------------------------------

