module UtilsSpec (main, spec) where

import           Test.Hspec
import           Test.QuickCheck

import qualified GHC      as GHC
import qualified GhcMonad as GHC
import qualified RdrName  as GHC
import qualified SrcLoc   as GHC

import Control.Monad.State
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.LocUtils

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  
  describe "locToExp" $ do
    it "finds the largest leftmost expression contained in a given region #1" $ do
      let modInfo@((_, _, mod), toks) = parsedFileB

      let exp = locToExp (4,7) (4,43) toks mod
      getLocatedStart exp `shouldBe` (4,9)
      getLocatedEnd   exp `shouldBe` (4,42)


    it "finds the largest leftmost expression contained in a given region #2" $ do
      let modInfo@((_, _, mod), toks) = parsedFileB

      let exp = locToExp (4,7) (4,41) toks mod
      getLocatedStart exp `shouldBe` (4,12)
      getLocatedEnd   exp `shouldBe` (4,19)

  -- -------------------------------------------------------------------

  describe "locToPnt" $ do
    it "returns a pnt for a given source location, if it falls anywhere in an identifier" $ do
      let modInfo@((_, _, mod), toks) = parsedFileB
      let res@(GHC.L _ n) = locToPNT "ignored" (4,0) mod
      getLocatedStart res `shouldBe` (4,1)
      GHC.showRdrName n `shouldBe` "foo"    

    it "returns a pnt for a given source location, if it falls anywhere in an identifier #2" $ do
      let modInfo@((_, _, mod), toks) = parsedFileB
      let res@(GHC.L _ n) = locToPNT "ignored" (18,6) mod
      GHC.showRdrName n `shouldBe` "bob"    
      getLocatedStart res `shouldBe` (18,5)

    it "returns the default pnt for a given source location, if it does not fall in an identifier" $ do
      let modInfo@((_, _, mod), toks) = parsedFileB
      let res@(GHC.L _ n) = locToPNT "ignored" (4,5) mod
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
      let modInfo@((_, _, mod), toks) = parsedFileB
      getModuleName mod `shouldBe` (Just "B")

    it "returns Nothing for the module name otherwise" $ do
      let modInfo@((_, _, mod), toks) = parsedFileNoMod
      getModuleName mod `shouldBe` Nothing

  -- -------------------------------------------------------------------

  describe "modIsExported" $ do
    it "needs a test or two" $ do
    pending "write this test"

  -- -------------------------------------------------------------------

  describe "runRefactGhc" $ do
    it "contains a State monad" $ do
      (_,s) <- runRefactGhcState comp
      (rsPosition s) `shouldBe` (123,456)
    it "contains the GhcT monad" $ do
      (r,_) <- runRefactGhcState comp
      r `shouldBe` "[\"B                ( old/refactorer/B.hs, old/refactorer/B.o )\"]"


-- ---------------------------------------------------------------------
-- Helper functions

parsedFileB = unsafeParseSourceFile fileName 
  where
    fileName = "./test/testdata/B.hs"

parsedFileNoMod = unsafeParseSourceFile fileName
  where
    fileName = "./test/testdata/NoMod.hs"


-- runRefactGhcState :: RefactGhc a -> IO RefactState
runRefactGhcState comp' = do
  let
     -- initialState = ReplState { repl_inputState = initInputState }
     initialState = RefSt 
	{ rsTokenStream = [] -- :: [PosToken]
	, rsStreamAvailable = False -- :: Bool
	, rsPosition = (-1,-1) -- :: (Int,Int)
        }
  (r,s) <- runRefactGhc initialState comp
  return (r,s)

-- comp :: RefactGhc ()
comp = do
    s <- get
    modInfo@((_, _, mod), toks) <- parseSourceFileGhc "./old/refactorer/B.hs"
    -- -- gs <- mapM GHC.showModule mod
    g <- GHC.getModuleGraph
    gs <- mapM GHC.showModule g
    GHC.liftIO (putStrLn $ "modulegraph=" ++ (show gs))
    put (s {rsPosition = (123,456)})
    -- return ()
    return (show gs)
