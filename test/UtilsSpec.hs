{-# LANGUAGE CPP #-}
module UtilsSpec (main, spec) where

import           Test.Hspec
-- import           Test.QuickCheck

import           TestUtils

import qualified GHC        as GHC
import qualified HscTypes   as GHC

import Control.Exception
import Control.Monad.State
import Data.Maybe

import qualified Language.Haskell.GhcMod.Internal as GM (mpModule)

import Language.Haskell.GHC.ExactPrint.Utils
import Language.Haskell.Refact.Refactoring.Renaming
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils
import Language.Haskell.Refact.Utils.Utils

import System.Directory

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do

  describe "locToExp on ParsedSource" $ do
    it "finds the largest leftmost expression contained in a given region #1" $ do
      (t, _toks,_) <- ct $ parsedFileGhc "./TypeUtils/B.hs"
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let (Just expr) = locToExp (7,7) (7,43) parsed :: Maybe (GHC.Located (GHC.HsExpr GHC.RdrName))
      getLocatedStart expr `shouldBe` (7,9)
      getLocatedEnd   expr `shouldBe` (7,42)

    it "finds the largest leftmost expression contained in a given region #2" $ do
      -- ((_, _, mod), toks) <- parsedFileBGhc
      (t, _toks,_) <- ct $ parsedFileGhc "./TypeUtils/B.hs"
      let modu = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let (Just expr) = locToExp (7,7) (7,41) modu :: Maybe (GHC.Located (GHC.HsExpr GHC.RdrName))
      getLocatedStart expr `shouldBe` (7,12)
      getLocatedEnd   expr `shouldBe` (7,19)

    it "finds the largest leftmost expression in RenamedSource" $ do
      -- ((_, renamed, _), toks) <- parsedFileBGhc
      (t, _toks,_) <- ct $ parsedFileGhc "./TypeUtils/B.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t

      let (Just expr) = locToExp (7,7) (7,41) renamed :: Maybe (GHC.Located (GHC.HsExpr GHC.Name))
      getLocatedStart expr `shouldBe` (7,12)
      getLocatedEnd   expr `shouldBe` (7,19)

  describe "locToExp on RenamedSource" $ do
    it "finds the largest leftmost expression contained in a given region #1" $ do
      -- ((_, Just renamed, _), toks) <- parsedFileBGhc
      (t, _toks,_) <- ct $ parsedFileGhc "./TypeUtils/B.hs"
      let renamed = fromJust $ GHC.tm_renamed_source t

      let (Just expr) = locToExp (7,7) (7,43) renamed :: Maybe (GHC.Located (GHC.HsExpr GHC.Name))
      getLocatedStart expr `shouldBe` (7,9)
      getLocatedEnd   expr `shouldBe` (7,42)

  -- -------------------------------------------------------------------

  describe "loading a file" $ do
    it "loads a file having the LANGUAGE CPP pragma" $ do
      (_t, toks,_) <- ct $ parsedFileGhc "./BCpp.hs"

      origStr <- readFile "./test/testdata/BCpp.hs"
      let toksStr = (GHC.showRichTokenStream toks)
      (show $ compareStrings toksStr origStr) `shouldBe` "[]"

  -- -----------------------------------

    it "loads a series of files based on cabal1" $ do

      currentDir <- getCurrentDirectory
      -- currentDir `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe"
      setCurrentDirectory "./test/testdata/cabal/cabal1"
      -- d <- getCurrentDirectory
      -- d `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe/test/testdata/cabal/cabal1"
      -- cradle <- findCradle
      -- (show cradle) `shouldBe` ""

      let settings = defaultSettings { rsetEnabledTargets = (True,True,False,False)
                                     -- , rsetVerboseLevel = Debug
                                     }

      r <- rename settings testOptions "./src/Foo/Bar.hs" "baz1" (3, 1)
      -- r <- rename logTestSettings cradle "./src/Foo/Bar.hs" "baz1" (3, 1)
      setCurrentDirectory currentDir

      r' <- mapM makeRelativeToCurrentDirectory r

      (show r') `shouldBe` "[\"./src/Foo/Bar.hs\","
                          ++"\"src/main.hs\"]"


  -- -----------------------------------

    it "loads a series of files based on cabal2, which has 2 exe" $ do

      currentDir <- getCurrentDirectory
      -- currentDir `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe"
      setCurrentDirectory "./test/testdata/cabal/cabal2"
      -- d <- getCurrentDirectory
      -- d `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe/test/testdata/cabal/cabal1"

      let settings = defaultSettings { rsetEnabledTargets = (True,True,True,True)
                                     -- , rsetVerboseLevel = Debug
                                     }

      let handler = [Handler handler1]
          handler1 :: GHC.SourceError -> IO [String]
          handler1 e = do
             setCurrentDirectory currentDir
             return [show e]

      r <- catches (rename settings testOptions "./src/Foo/Bar.hs" "baz1" (3, 1)) handler
      setCurrentDirectory currentDir

      r' <- mapM makeRelativeToCurrentDirectory r

      (show r') `shouldBe` "[\"./src/Foo/Bar.hs\","++
                            "\"src/main1.hs\","++
                            "\"src/main2.hs\"]"

  -- -----------------------------------

    it "loads a series of files based on cabal3, which has a lib and an exe" $ do

      currentDir <- getCurrentDirectory
      -- currentDir `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe"
      setCurrentDirectory "./test/testdata/cabal/cabal3"
      -- d <- getCurrentDirectory
      -- d `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe/test/testdata/cabal/cabal3"
      -- cradle <- findCradle
      -- (show cradle) `shouldBe` ""
      -- (cradleCurrentDir cradle) `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe/test/testdata/cabal/cabal3"

      let settings = defaultSettings { rsetEnabledTargets = (True,True,True,True)
                                     -- , rsetVerboseLevel = Debug
                                     }

      let handler = [Handler handler1]
          handler1 :: GHC.SourceError -> IO [String]
          handler1 e = do
             setCurrentDirectory currentDir
             return [show e]

      r <- catches (rename settings testOptions "./src/main1.hs" "baz1" (7, 1)) handler
      setCurrentDirectory currentDir

      r' <- mapM makeRelativeToCurrentDirectory r

      (show r') `shouldBe` "[\"./src/main1.hs\"]"


  -- -----------------------------------
{- TODO: this test fails on travis, due to missing hspec-discover
    it "renames in HaRe Utils 1" $ do

      currentDir <- getCurrentDirectory
      -- currentDir `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe"
      setCurrentDirectory "./"
      -- d <- getCurrentDirectory
      -- d `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe"
      cradle <- findCradle
      -- (show cradle) `shouldBe` ""
      -- (cradleCurrentDir cradle) `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe"

      let settings = defaultSettings { rsetEnabledTargets = (True,True,True,True)
                                     -- , rsetVerboseLevel = Debug
                                     }

      let handler = [Handler handler1]
          handler1 :: GHC.SourceError -> IO [String]
          handler1 e = do
             setCurrentDirectory currentDir
             return [show e]

      r <- catches (rename settings cradle "./src/Language/Haskell/Refact/Utils.hs" "clientModsAndFiles1" (473, 6)) handler
      setCurrentDirectory currentDir

      r' <- mapM makeRelativeToCurrentDirectory r

      (show r') `shouldBe`
          "[\"./src/Language/Haskell/Refact/Utils.hs\","++
           "\"./src/Language/Haskell/Refact/Renaming.hs\","++
           "\"./src/Language/Haskell/Refact/MoveDef.hs\","++
           "\"./src/Language/Haskell/Refact/DupDef.hs\","++
           "\"./src/Language/Haskell/Refact/Renaming.hs\","++
           "\"./src/Language/Haskell/Refact/MoveDef.hs\","++
           "\"./src/Language/Haskell/Refact/DupDef.hs\","++
           "\"test/UtilsSpec.hs\","++
           "\"./src/Language/Haskell/Refact/Renaming.hs\","++
           "\"./src/Language/Haskell/Refact/MoveDef.hs\","++
           "\"./src/Language/Haskell/Refact/DupDef.hs\"]"
-}

  -- -----------------------------------
{-
    it "renames in HaRe Utils 2" $ do

      currentDir <- getCurrentDirectory
      -- currentDir `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe"
      setCurrentDirectory "./"
      -- d <- getCurrentDirectory
      -- d `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe"
      cradle <- findCradle
      -- (show cradle) `shouldBe` ""
      -- (cradleCurrentDir cradle) `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe"

      let settings = defaultSettings { rsetEnabledTargets = (True,True,True,True)
                                     , rsetVerboseLevel = Debug
                                     }

      let handler = [Handler handler1]
          handler1 :: GHC.SourceError -> IO [String]
          handler1 e = do
             setCurrentDirectory currentDir
             return [show e]

      r <- catches (rename settings cradle "./test/UtilsSpec.hs" "parsed" (41, 10)) handler
      setCurrentDirectory currentDir

      r' <- mapM makeRelativeToCurrentDirectory r

      (show r') `shouldBe`
          "[\"./src/Language/Haskell/Refact/Utils.hs\","++
           "\"./src/Language/Haskell/Refact/Renaming.hs\","++
           "\"./src/Language/Haskell/Refact/MoveDef.hs\","++
           "\"./src/Language/Haskell/Refact/DupDef.hs\","++
           "\"./src/Language/Haskell/Refact/Renaming.hs\","++
           "\"./src/Language/Haskell/Refact/MoveDef.hs\","++
           "\"./src/Language/Haskell/Refact/DupDef.hs\","++
           "\"test/UtilsSpec.hs\","++
           "\"./src/Language/Haskell/Refact/Renaming.hs\","++
           "\"./src/Language/Haskell/Refact/MoveDef.hs\","++
           "\"./src/Language/Haskell/Refact/DupDef.hs\"]"
-}
  -- -----------------------------------
{-
  -- This test does not work properly on Travis, missing hspec-discover
    it "renames in HaRe Utils 3" $ do

      currentDir <- getCurrentDirectory
      -- currentDir `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe"
      setCurrentDirectory "./"
      -- d <- getCurrentDirectory
      -- d `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe"
      cradle <- findCradle
      -- (show cradle) `shouldBe` ""
      -- (cradleCurrentDir cradle) `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe"

      let settings = defaultSettings { rsetEnabledTargets = (True,True,True,True)
                                     -- , rsetVerboseLevel = Debug
                                     }

      let handler = [Handler handler1]
          handler1 :: GHC.SourceError -> IO [String]
          handler1 e = do
             setCurrentDirectory currentDir
             return [show e]

      r <- catches (rename settings cradle "./test/UtilsSpec.hs" "parsed" (41, 11)) handler
      setCurrentDirectory currentDir

      r' <- mapM makeRelativeToCurrentDirectory r

      (show r') `shouldBe`
          "[\"test/UtilsSpec.hs\"]"
-}
  -- -------------------------------------------------------------------

  describe "sameOccurrence" $ do
    it "checks that a given syntax element is the same occurrence as another" $ do
      pending -- "write this test"

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
      (t, _toks,_) <- ct $ parsedFileGhc "./TypeUtils/B.hs"
      let modu = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      let (Just (_modname,modNameStr)) = getModuleName modu
      -- let modNameStr = "foo"
      modNameStr `shouldBe` "TypeUtils.B"

    it "returns Nothing for the module name otherwise" $ do
      -- modInfo@((_, _, mod), toks) <- parsedFileNoMod
      (t, _toks,_) <- parsedFileNoMod
      let modu = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      getModuleName modu `shouldBe` Nothing

  -- -------------------------------------------------------------------

  describe "modIsExported" $ do
    it "needs a test or two" $ do
      pending  -- "write this test"

  -- -------------------------------------------------------------------

  describe "clientModsAndFiles" $ do
    it "can only be called in a live RefactGhc session" $ do
      pending  -- "write this test"

    ------------------------------------

    it "gets modules which directly or indirectly import a module #1" $ do
      -- TODO: harvest this commonality
      -- (t, toks,tgt) <- ct $ parsedFileGhc "./M.hs"
      let
        comp = do
         -- (_p,_toks) <- parseSourceFileTest "./M.hs"  -- Load the main file first
         -- loadModuleGraphGhc $ Just ["./M.hs"]
         -- getModuleGhc "./M3.hs"
         getModuleGhc "./S1.hs"
         tm <- getRefactTargetModule
         -- g <- clientModsAndFiles $ GHC.mkModuleName "S1"
         g <- clientModsAndFiles tm
         return g
      (mg,_s) <- ct $ runRefactGhc comp [Left "./M.hs"] initialState testOptions
      -- (mg,_s) <- ct $ runRefactGhc comp [Left "./M.hs"] initialLogOnState testOptions
      showGhc (map GM.mpModule mg) `shouldBe` "[Main, M3, M2]"

    ------------------------------------

    it "gets modules which directly or indirectly import a module #2" $ do
      -- (t,toks,tgt) <- ct $ parsedFileGhc "./M.hs"
      let
        comp = do
         -- (_p,_toks) <- parseSourceFileTest "./M.hs" -- Load the main file first
         -- loadModuleGraphGhc $ Just ["./M.hs"]
         getModuleGhc "./M3.hs"
         tm <- getRefactTargetModule
         -- g <- clientModsAndFiles $ GHC.mkModuleName "M3"
         g <- clientModsAndFiles tm
         return g
      (mg,_s) <- ct $ runRefactGhc comp [Left "./M.hs"] initialState testOptions
      showGhc (map GM.mpModule mg) `shouldBe` "[Main]"

    ------------------------------------

    it "gets modules which import a module in different cabal targets" $ do
      currentDir <- getCurrentDirectory
      -- currentDir `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe"
      setCurrentDirectory "./test/testdata/cabal/cabal2"
      -- d <- getCurrentDirectory
      -- d `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe/test/testdata/cabal/cabal2"
      -- cradle <- findCradle
      -- (show cradle) `shouldBe` ""
      -- (cradleCurrentDir cradle) `shouldBe` "/home/alanz/mysrc/github/alanz/HaRe/test/testdata/cabal/cabal2"

      let
        comp = do
         initGhcSession [Left "./src/main1.hs"]
         getModuleGhc "./src/Foo/Bar.hs" -- Load the file first
         tm <- getRefactTargetModule
         -- g <- clientModsAndFiles $ GHC.mkModuleName "Foo.Bar"
         g <- clientModsAndFiles tm
         return g
      -- (mg,_s) <- runRefactGhcState comp
      -- (mg,_s) <- runRefactGhc comp tgt (initialState { rsModule = initRefactModule t }) testOptions
      (mg,_s) <- runRefactGhc comp [Left "./src/main1.hs"] (initialState { rsModule = Nothing }) testOptions
      showGhc (map GM.mpModule mg) `shouldBe` "[Main, Main]"

      setCurrentDirectory currentDir

  -- -------------------------------------------------------------------

  describe "serverModsAndFiles" $ do
    it "can only be called in a live RefactGhc session" $ do
      pending  -- "write this test"

    it "gets modules which are directly or indirectly imported by a module #1" $ do
      -- (t,toks,tgt) <- ct $ parsedFileGhc "./M.hs"
      let
        comp = do
         -- (_p,_toks) <- parseFileMGhc -- Load the main file first
         g <- serverModsAndFiles $ GHC.mkModuleName "S1"
         return g
      -- (mg,_s) <- ct $ runRefactGhcState comp
      (mg,_s) <- ct $ runRefactGhc comp [Left "./M.hs"] initialState testOptions
      -- (mg,_s) <- ct $ runRefactGhc comp tgt (initialLogOnState { rsModule = initRefactModule t }) testOptions
      showGhc (map GHC.ms_mod mg) `shouldBe` "[]"

    it "gets modules which are directly or indirectly imported by a module #2" $ do
      -- (t,toks,tgt) <- ct $ parsedFileGhc "./M3.hs"
      let
        comp = do
         -- (_p,_toks) <- parseFileMGhc -- Load the main file first
         g <- serverModsAndFiles $ GHC.mkModuleName "M3"
         return g
      -- (mg,_s) <- ct $ runRefactGhcState comp
      (mg,_s) <- ct $ runRefactGhc comp [Left "./M3.hs"] initialState testOptions
      showGhc (map GHC.ms_mod mg) `shouldBe` "[M2, S1]"


  -- -------------------------------------------------------------------
{-
  describe "getCurrentModuleGraph" $ do
    it "gets the module graph for the currently loaded modules" $ do
      let
        comp = do
         (_p,_toks) <- parseFileBGhc -- Load the file first
         g <- getCurrentModuleGraph
         return g
      (mg,_s) <- runRefactGhcState comp
      map (\m -> GHC.moduleNameString $ GHC.ms_mod_name m) mg `shouldBe` (["TypeUtils.B","TypeUtils.C"])
      map (\m -> show $ GHC.ml_hs_file $ GHC.ms_location m) mg `shouldBe` (["Just \"./test/testdata/TypeUtils/B.hs\""
                                                                           ,"Just \"./test/testdata/TypeUtils/C.hs\""])


    it "gets the updated graph, after a refactor" $ do
      pending -- "write this test"
-}
  -- -------------------------------------------------------------------
{-
  describe "sortCurrentModuleGraph" $ do
    it "needs a test or two" $ do
      let
        comp = do
         (_p,_toks) <- parseFileBGhc -- Load the file first
         g <- sortCurrentModuleGraph
         return g
      (mg,_s) <- runRefactGhcState comp
      (showGhc $ map (\m -> GHC.ms_mod m) (GHC.flattenSCCs mg)) `shouldBe` "[main:TypeUtils.C, main:TypeUtils.B]"
-}
  -- -------------------------------------------------------------------

  describe "getModuleGhc" $ do
    it "retrieves a module from an existing module graph #1" $ do
      -- (t,toks,tgt) <- ct $ parsedFileGhc "./M.hs"
      let
        comp = do
          -- loadModuleGraphGhc $ Just ["./M.hs"]
          -- getModuleGhc "./test/testdata/S1.hs"
          getModuleGhc "./S1.hs"
          pr <- getTypecheckedModule
          tm <- getRefactTargetModule
          -- g <- clientModsAndFiles $ GHC.mkModuleName "S1"
          g <- clientModsAndFiles tm

          return (pr,g)

      ( (t, mg), _s) <- ct $ runRefactGhc comp [Left "./M.hs"] initialState testOptions
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      (show $ getModuleName parsed) `shouldBe` "Just (ModuleName \"S1\",\"S1\")"
      showGhc (map GM.mpModule mg) `shouldBe` "[Main, M3, M2]"

    -- ---------------------------------

    it "loads the module and dependents if no existing module graph" $ do
      -- (t,toks,tgt) <- ct $ parsedFileGhc "./S1.hs"
      let
        comp = do
          getModuleGhc "./S1.hs"
          pr <- getTypecheckedModule
          tm <- getRefactTargetModule
          -- g <- clientModsAndFiles $ GHC.mkModuleName "S1"
          g <- clientModsAndFiles tm

          return (pr,g)
      ((t, mg ), _s) <- ct $ runRefactGhc comp [Left "./S1.hs"] initialState testOptions
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

      (show $ getModuleName parsed) `shouldBe` "Just (ModuleName \"S1\",\"S1\")"
      showGhc (map GM.mpModule mg) `shouldBe` "[Main, M3, M2]"

    -- ---------------------------------

    it "retrieves a module from an existing module graph #2" $ do
      -- (t,toks,tgt) <- ct $ parsedFileGhc "./test/testdata/DupDef/Dd2.hs"
      let
        comp = do
          -- loadModuleGraphGhc $ Just ["./DupDef/Dd2.hs"]
          getModuleGhc "./DupDef/Dd1.hs"
          pr <- getTypecheckedModule
          tm <- getRefactTargetModule
          -- g <- clientModsAndFiles $ GHC.mkModuleName "DupDef.Dd1"
          g <- clientModsAndFiles tm

          return (pr,g)
      ((t, mg), _s) <- ct $ runRefactGhc comp [Left "DupDef/Dd2.hs"] initialState testOptions
      let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t
      (show $ getModuleName parsed) `shouldBe` "Just (ModuleName \"DupDef.Dd1\",\"DupDef.Dd1\")"
      showGhc (map GM.mpModule mg) `shouldBe` "[DupDef.Dd2, DupDef.Dd3]"


  -- -------------------------------------------------------------------

  describe "runRefactGhc" $ do
    it "contains a State monad" $ do
      -- (t,toks,tgt) <- ct $ parsedFileGhc "./test/testdata/TypeUtils/B.hs"
      let
       comp = do
        s <- get
        -- (_t, _toks) <- parseSourceFileTest "./test/testdata/TypeUtils/B.hs"

        g <- GHC.getModuleGraph
        gs <- mapM GHC.showModule g
        -- GHC.liftIO (putStrLn $ "modulegraph=" ++ (show gs))

        put (s {rsUniqState = 100})
        return (show gs)

      -- (_,s) <- runRefactGhcState comp
      (_,s) <- ct $ runRefactGhc comp [Left "TypeUtils/B.hs"] (initialState { rsModule = Nothing }) testOptions
      (rsUniqState s) `shouldBe` 100

    it "contains the GhcT monad" $ do
      -- (t,toks,tgt) <- ct $ parsedFileGhc "./test/testdata/TypeUtils/B.hs"
      let
       comp = do
        s <- get
        -- (_t, _toks) <- parseSourceFileTest "./test/testdata/TypeUtils/B.hs"

        g <- GHC.getModuleGraph
        gs <- mapM GHC.showModule g
        -- GHC.liftIO (putStrLn $ "modulegraph=" ++ (show gs))

        put (s {rsUniqState = 100})
        return (show gs)

      -- (r,_) <- runRefactGhcState comp
      (r,_) <- ct $ runRefactGhc comp [Left "TypeUtils/B.hs"] (initialState { rsModule = Nothing }) testOptions
      r `shouldBe` ("[\"TypeUtils.C      ( TypeUtils/C.hs, nothing )\","
                   ++"\"TypeUtils.B      ( TypeUtils/B.hs, nothing )\"]")

  -- -------------------------------------------------------------------

  describe "RefactFlags" $ do
    it "puts the RefactDone flag through its paces" $ do
      (t,_toks,tgt) <- ct $ parsedFileGhc "./FreeAndDeclared/DeclareTypes.hs"
      let
        comp = do
          v1 <- getRefactDone
          clearRefactDone
          v2 <- getRefactDone
          setRefactDone
          v3 <- getRefactDone

          return (v1,v2,v3)
      -- ((v1',v2',v3'), _s) <- runRefactGhcState comp
      ((v1',v2',v3'), _s) <- runRefactGhc comp tgt (initialState { rsModule = initRefactModule t }) testOptions

      (show (v1',v2',v3')) `shouldBe` "(False,False,True)"


-- ---------------------------------------------------------------------
-- Helper functions

-- bFileName :: GHC.FastString
-- bFileName = GHC.mkFastString "./test/testdata/TypeUtils/B.hs"

-- parsedFileBGhc :: IO (ParseResult,[PosToken],Targets)
-- parsedFileBGhc = ct $ parsedFileGhc "./TypeUtils/B.hs"

-- parsedFileMGhc :: IO (ParseResult,[PosToken],Targets)
-- parsedFileMGhc = parsedFileGhc "./test/testdata/M.hs"

-- parseFileBGhc :: RefactGhc (ParseResult, [PosToken],Targets)
-- parseFileBGhc = parseSourceFileTest fileName
--   where
--     fileName = "./test/testdata/TypeUtils/B.hs"

-- parseFileMGhc :: RefactGhc (ParseResult, [PosToken],Targets)
-- parseFileMGhc = parseSourceFileTest fileName
--   where
--     fileName = "./M.hs"

parsedFileNoMod :: IO (ParseResult,[PosToken],Targets)
parsedFileNoMod = ct $ parsedFileGhc "./NoMod.hs"



-- ---------------------------------------------------------------------

