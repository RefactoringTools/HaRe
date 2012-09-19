module UtilsSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import qualified GHC        as GHC
import qualified GhcMonad   as GHC
import qualified Outputable as GHC
import qualified RdrName    as GHC
import qualified SrcLoc     as GHC

import Control.Monad.State
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.TypeSyn

main :: IO ()
main = hspec spec

spec :: Spec
spec = do

  describe "locToExp" $ do
    it "finds the largest leftmost expression contained in a given region #1" $ do
      modInfo@((_, _, mod), toks) <- parsedFileBGhc

      let exp = locToExp (7,7) (7,43) toks mod
      getLocatedStart exp `shouldBe` (7,9)
      getLocatedEnd   exp `shouldBe` (7,42)


    it "finds the largest leftmost expression contained in a given region #2" $ do
      modInfo@((_, _, mod), toks) <- parsedFileBGhc

      let exp = locToExp (7,7) (7,41) toks mod
      getLocatedStart exp `shouldBe` (7,12)
      getLocatedEnd   exp `shouldBe` (7,19)

  -- -------------------------------------------------------------------

  describe "locToPnt" $ do
    it "returns a pnt for a given source location, if it falls anywhere in an identifier" $ do
      modInfo@((_, _, mod), toks) <- parsedFileBGhc
      let res@(GHC.L _ n) = locToPNT "ignored" (7,0) mod
      getLocatedStart res `shouldBe` (7,1)
      GHC.showRdrName n `shouldBe` "foo"

    it "returns a pnt for a given source location, if it falls anywhere in an identifier #2" $ do
      modInfo@((_, _, mod), toks) <- parsedFileBGhc
      let res@(GHC.L _ n) = locToPNT "ignored" (23,6) mod
      GHC.showRdrName n `shouldBe` "bob"
      getLocatedStart res `shouldBe` (23,5)

    it "returns the default pnt for a given source location, if it does not fall in an identifier" $ do
      modInfo@((_, _, mod), toks) <- parsedFileBGhc
      let res@(GHC.L _ n) = locToPNT "ignored" (7,6) mod
      getLocatedStart res `shouldBe` (-1,-1)
      GHC.showRdrName n `shouldBe` "nothing"

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
      modInfo@((_, _, mod), toks) <- parsedFileBGhc
      let (Just (modname,modNameStr)) = getModuleName mod
      -- let modNameStr = "foo"
      modNameStr `shouldBe` "B"

    it "returns Nothing for the module name otherwise" $ do
      let modInfo@((_, _, mod), toks) = parsedFileNoMod
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
      map (\m -> GHC.moduleNameString $ GHC.ms_mod_name m) mg `shouldBe` (["B","C"])


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
      GHC.showPpr mg `shouldBe` "[NONREC\n    ModSummary {\n       ms_hs_date = Sat Sep 15 14:39:05 SAST 2012\n       ms_mod = main:C,\n       ms_textual_imps = [import (implicit) Prelude]\n       ms_srcimps = []\n    },\n NONREC\n    ModSummary {\n       ms_hs_date = Sat Sep 15 14:43:57 SAST 2012\n       ms_mod = main:B,\n       ms_textual_imps = [import (implicit) Prelude, import C,\n                          import Data.List]\n       ms_srcimps = []\n    }]"


  -- -------------------------------------------------------------------

  describe "runRefactGhc" $ do
    it "contains a State monad" $ do
      (_,s) <- runRefactGhcState comp
      (rsStreamAvailable s) `shouldBe` True
    it "contains the GhcT monad" $ do
      (r,_) <- runRefactGhcState comp
      r `shouldBe` ("[\"B                ( test/testdata/B.hs, test/testdata/B.o )\"," 
                   ++"\"C                ( test/testdata/C.hs, test/testdata/C.o )\"]")

-- ---------------------------------------------------------------------
-- Helper functions

parsedFileBGhc :: IO (ParseResult,[PosToken])
parsedFileBGhc = parsedFileGhc "./test/testdata/B.hs"

parsedFileMGhc :: IO (ParseResult,[PosToken])
parsedFileMGhc = parsedFileGhc "./test/testdata/M.hs"


{-
parsedFileBGhc :: IO (ParseResult,[PosToken])
parsedFileBGhc = do
  let
    fileName = "./test/testdata/B.hs"
    comp = do
       (p,toks) <- parseSourceFileGhc fileName -- Load the file first
       return (p,toks)
  (parseResult,_s) <- runRefactGhcState comp
  return parseResult
-}


parsedFileGhc :: String -> IO (ParseResult,[PosToken])
parsedFileGhc fileName = do
  let
    comp = do
       (p,toks) <- parseSourceFileGhc fileName -- Load the file first
       return (p,toks)
  (parseResult,_s) <- runRefactGhcState comp
  return parseResult


parseFileBGhc :: RefactGhc (ParseResult, [PosToken])
parseFileBGhc = parseSourceFileGhc fileName
  where
    fileName = "./test/testdata/B.hs"

parseFileMGhc :: RefactGhc (ParseResult, [PosToken])
parseFileMGhc = parseSourceFileGhc fileName
  where
    fileName = "./test/testdata/M.hs"

parsedFileNoMod = unsafeParseSourceFile fileName
  where
    fileName = "./test/testdata/NoMod.hs"


-- runRefactGhcState :: RefactGhc a -> IO RefactState
runRefactGhcState paramcomp = do
  let
     -- initialState = ReplState { repl_inputState = initInputState }
     initialState = RefSt
        { rsSettings = RefSet ["./test/testdata/"]
        , rsTokenStream = [] -- :: [PosToken]
        , rsStreamAvailable = False -- :: Bool
        -- , rsPosition = (-1,-1) -- :: (Int,Int)
        }
  (r,s) <- runRefactGhc paramcomp initialState
  return (r,s)


comp :: RefactGhc String
comp = do
    s <- get
    modInfo@((_, _, mod), toks) <- parseSourceFileGhc "./test/testdata/B.hs"
    -- -- gs <- mapM GHC.showModule mod
    g <- GHC.getModuleGraph
    gs <- mapM GHC.showModule g
    GHC.liftIO (putStrLn $ "modulegraph=" ++ (show gs))
    put (s {rsStreamAvailable = True})
    -- return ()
    return (show gs)

-- ---------------------------------------------------------------------

