module TestUtils 
       ( compareFiles
       , parsedFileGhc
       , runRefactGhcState
       , catchException
       ) where


import qualified GHC        as GHC
import qualified GhcMonad   as GHC
import qualified Outputable as GHC
import qualified RdrName    as GHC
import qualified SrcLoc     as GHC

import Control.Monad.State
import Data.Algorithm.Diff
import Exception
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn

-- ---------------------------------------------------------------------

compareFiles :: FilePath -> FilePath -> IO [(DI, [String])]
compareFiles fileA fileB = do
  astr <- readFile fileA
  bstr <- readFile fileB
  -- putStrLn $ "compareFiles " ++ (show $ lines astr) ++ "," ++ (show $ lines bstr) 
  return $ filter (\(c,_) -> c /= B) $ getGroupedDiff (lines astr) (lines bstr)

-- ---------------------------------------------------------------------

parsedFileGhc :: String -> IO (ParseResult,[PosToken])
parsedFileGhc fileName = do
  let
    comp = do
       (p,toks) <- parseSourceFileGhc fileName -- Load the file first
       return (p,toks)
  (parseResult,_s) <- runRefactGhcState comp
  return parseResult

-- ---------------------------------------------------------------------

runRefactGhcState :: RefactGhc t -> IO (t, RefactState)
runRefactGhcState paramcomp = do
  let
     -- initialState = ReplState { repl_inputState = initInputState }
     initialState = RefSt
        { rsSettings = RefSet ["./test/testdata/"]
        , rsUniqState = 1
        , rsTokenStream = [] -- :: [PosToken]
        , rsStreamModified = False -- :: Bool
        -- , rsPosition = (-1,-1) -- :: (Int,Int)
        }
  (r,s) <- runRefactGhc (initGhcSession >>paramcomp) initialState
  return (r,s)

-- ---------------------------------------------------------------------

catchException :: (IO t) -> IO (Maybe String)
catchException f = do
  res <- handle handler (f >> return Nothing)
  return res
  where
    handler:: SomeException -> IO (Maybe String)
    handler e = return (Just (show e))

-- EOF
  