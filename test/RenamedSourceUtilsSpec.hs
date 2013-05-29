module RenamedSourceUtilsSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import           TestUtils

import qualified Digraph    as GHC
import qualified FastString as GHC
import qualified GHC        as GHC
import qualified GhcMonad   as GHC
import qualified Name       as GHC
import qualified NameSet    as GHC
import qualified Outputable as GHC
import qualified RdrName    as GHC
import qualified SrcLoc     as GHC

import Control.Monad.State
import Data.Maybe
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.RenamedSourceUtils
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  setLogger
  hspec spec

spec :: Spec
spec = do

  describe "getFreeVariables" $ do
    it "gets the free variables for a given syntax element" $ do
      df <- getTestDynFlags
      (t, toks) <- parsedFileBGhc
      let renamed = fromJust $ GHC.tm_renamed_source t
      let fvs = getFreeVariables renamed
      (showGhcd df $ GHC.nameSetToList $ GHC.unionManyNameSets fvs) `shouldBe` "[TypeUtils.B.foo, TypeUtils.B.bob]"



-- ---------------------------------------------------------------------
-- Helper functions

bFileName :: GHC.FastString
bFileName = GHC.mkFastString "./test/testdata/TypeUtils/B.hs"

parsedFileBGhc :: IO (ParseResult,[PosToken])
parsedFileBGhc = parsedFileGhc "./test/testdata/TypeUtils/B.hs"

parsedFileMGhc :: IO (ParseResult,[PosToken])
parsedFileMGhc = parsedFileGhc "./test/testdata/M.hs"

parseFileBGhc :: RefactGhc (ParseResult, [PosToken])
parseFileBGhc = parseSourceFileTest fileName
  where
    fileName = "./test/testdata/B.hs"

parseFileMGhc :: RefactGhc (ParseResult, [PosToken])
parseFileMGhc = parseSourceFileTest fileName
  where
    fileName = "./test/testdata/M.hs"

parsedFileNoMod = parsedFileGhc fileName
  where
    fileName = "./test/testdata/NoMod.hs"


comp :: RefactGhc String
comp = do
    s <- get
    modInfo@(t, toks) <- parseSourceFileTest "./test/testdata/TypeUtils/B.hs"

    g <- GHC.getModuleGraph
    gs <- mapM GHC.showModule g
    GHC.liftIO (putStrLn $ "modulegraph=" ++ (show gs))

    let Just tm = rsModule s
    let tm' = tm {rsStreamModified = True}
    put (s {rsModule = Just tm'})
    return (show gs)

-- ---------------------------------------------------------------------

