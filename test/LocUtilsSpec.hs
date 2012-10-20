module LocUtilsSpec (main, spec) where

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

  describe "startEndLocIncComments" $ do
    it "get start&end loc, including leading and trailing comments" $ do
      ((_,_,parsed), toks) <- parsedFileDeclareGhc
      let declsp = getDeclsP parsed
      let decls = filter isFunOrPatBindP declsp

      let decl = head $ drop 4 decls
      let (startPos,endPos) = startEndLocIncComments toks decl

      (GHC.showPpr decl) `shouldBe` "unD (B y) = y"

      (show $ getStartEndLoc decl) `shouldBe` "((19,1),(19,13))"

      (show (startPos,endPos)) `shouldBe` "((18,1),(20,1))"

  -- -------------------------------------------------------------------

  describe "updateToks" $ do
    it "needs a test or two" $ do
      pending "write this test"

  -- -------------------------------------------------------------------

  describe "splitToks" $ do
    it "Split the tokens into a front, middle and end" $ do
      ((_,renamed,_),toks) <- parsedFileCaseBGhc
      let Just expr = locToExp (4,7) (4,43) renamed :: Maybe (GHC.Located (GHC.HsExpr GHC.Name))
          (_front,middle,_back) = splitToks ((4,9),(4,36)) toks
      (showToks middle) `shouldBe`
               "[(((4,9),(4,11)),ITif,\"if\")," ++
               "(((4,12),(4,13)),IToparen,\"(\")," ++
               "(((4,13),(4,16)),ITvarid \"odd\",\"odd\")," ++
               "(((4,17),(4,18)),ITvarid \"x\",\"x\")," ++
               "(((4,18),(4,19)),ITcparen,\")\")," ++
               "(((4,20),(4,24)),ITthen,\"then\")," ++
               "(((4,25),(4,30)),ITstring \"Odd\",\"\\\"Odd\\\"\")," ++
               "(((4,31),(4,35)),ITelse,\"else\")," ++
               "(((4,36),(4,42)),ITstring \"Even\",\"\\\"Even\\\"\")]"
      (GHC.showRichTokenStream middle) `shouldBe` "\n\n\n         if (odd x) then \"Odd\" else \"Even\""

  -- -------------------------------------------------------------------

  describe "replaceToks" $ do
    it "Replaces a set of tokens in a token stream" $ do
      ((_,renamed,_),toks) <- parsedFileCaseBGhc
      let Just expr = locToExp (4,7) (4,43) renamed :: Maybe (GHC.Located (GHC.HsExpr GHC.Name))
          (front,middle,_back) = splitToks ((4,9),(4,36)) toks
      (showToks middle) `shouldBe`
               "[(((4,9),(4,11)),ITif,\"if\")," ++
               "(((4,12),(4,13)),IToparen,\"(\")," ++
               "(((4,13),(4,16)),ITvarid \"odd\",\"odd\")," ++
               "(((4,17),(4,18)),ITvarid \"x\",\"x\")," ++
               "(((4,18),(4,19)),ITcparen,\")\")," ++
               "(((4,20),(4,24)),ITthen,\"then\")," ++
               "(((4,25),(4,30)),ITstring \"Odd\",\"\\\"Odd\\\"\")," ++
               "(((4,31),(4,35)),ITelse,\"else\")," ++
               "(((4,36),(4,42)),ITstring \"Even\",\"\\\"Even\\\"\")]"
      (GHC.showRichTokenStream middle) `shouldBe` "\n\n\n         if (odd x) then \"Odd\" else \"Even\""
      (showToks [(head front)]) `shouldBe` "[(((1,1),(1,7)),ITmodule,\"module\")]"
      
      let newToks = replaceToks middle (4,17) (4,17) [(head front)]
      (showToks newToks) `shouldBe`
               "[(((4,9),(4,11)),ITif,\"if\")," ++
               "(((4,12),(4,13)),IToparen,\"(\")," ++
               "(((4,13),(4,16)),ITvarid \"odd\",\"odd\")," ++
               -- "(((4,17),(4,18)),ITvarid \"x\",\"x\")," ++
               "(((1,1),(1,7)),ITmodule,\"module\")," ++ 
               "(((4,18),(4,19)),ITcparen,\")\")," ++
               "(((4,20),(4,24)),ITthen,\"then\")," ++
               "(((4,25),(4,30)),ITstring \"Odd\",\"\\\"Odd\\\"\")," ++
               "(((4,31),(4,35)),ITelse,\"else\")," ++
               "(((4,36),(4,42)),ITstring \"Even\",\"\\\"Even\\\"\")]"


  -- -------------------------------------------------------------------

  describe "foo" $ do
    it "needs a test or two" $ do
      pending "write this test"

-- ---------------------------------------------------------------------
-- Helper functions

bFileName :: GHC.FastString
bFileName = GHC.mkFastString "./test/testdata/B.hs"

parsedFileBGhc :: IO (ParseResult,[PosToken])
parsedFileBGhc = parsedFileGhc "./test/testdata/B.hs"

caseBFileName :: GHC.FastString
caseBFileName = GHC.mkFastString "./test/testdata/Case/B.hs"

parsedFileCaseBGhc :: IO (ParseResult,[PosToken])
parsedFileCaseBGhc = parsedFileGhc "./test/testdata/Case/B.hs"

parsedFileMGhc :: IO (ParseResult,[PosToken])
parsedFileMGhc = parsedFileGhc "./test/testdata/M.hs"

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


comp :: RefactGhc String
comp = do
    s <- get
    modInfo@((_, _, mod), toks) <- parseSourceFileGhc "./test/testdata/B.hs"
    -- -- gs <- mapM GHC.showModule mod
    g <- GHC.getModuleGraph
    gs <- mapM GHC.showModule g
    GHC.liftIO (putStrLn $ "modulegraph=" ++ (show gs))
    put (s {rsStreamModified = True})
    -- return ()
    return (show gs)

-- ---------------------------------------------------------------------

parsedFileDeclareGhc :: IO (ParseResult,[PosToken])
parsedFileDeclareGhc = parsedFileGhc "./test/testdata/FreeAndDeclared/Declare.hs"
