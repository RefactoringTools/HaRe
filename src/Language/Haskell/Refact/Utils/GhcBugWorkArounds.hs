{-# LANGUAGE CPP #-}
-- | Provide workarounds for bugs detected in GHC, until they are
-- fixed in a later version

module Language.Haskell.Refact.Utils.GhcBugWorkArounds
    (
    getRichTokenStreamWA
    ) where

import qualified Bag                   as GHC
import qualified DynFlags              as GHC
import qualified ErrUtils              as GHC
import qualified FastString            as GHC
import qualified GHC                   as GHC
import qualified HscTypes              as GHC
import qualified Lexer                 as GHC
import qualified MonadUtils            as GHC
import qualified Outputable            as GHC
import qualified SrcLoc                as GHC
import qualified StringBuffer          as GHC

import Control.Exception
import Data.IORef
import Data.List.Utils
import System.Directory
import System.FilePath
import qualified Data.Map as Map

import Language.Haskell.Refact.Utils.GhcVersionSpecific


-- | Replacement for original 'getRichTokenStream' which will return
-- the tokens for a file processed by CPP.
-- See bug <http://ghc.haskell.org/trac/ghc/ticket/8265>
getRichTokenStreamWA :: GHC.GhcMonad m => GHC.Module -> m [(GHC.Located GHC.Token, String)]
getRichTokenStreamWA mod = do
  (sourceFile, source, flags) <- getModuleSourceAndFlags mod
  let startLoc = GHC.mkRealSrcLoc (GHC.mkFastString sourceFile) 1 1
  case GHC.lexTokenStream source startLoc flags of
    GHC.POk _ ts -> return $ GHC.addSourceToTokens startLoc source ts
    GHC.PFailed span err ->
        do
           strSrcBuf <- getPreprocessedSrc sourceFile
           case GHC.lexTokenStream strSrcBuf startLoc flags of
             GHC.POk _ ts ->
               do directiveToks <- GHC.liftIO $ getPreprocessorAsComments sourceFile
                  let toks = GHC.addSourceToTokens startLoc source ts
                  return $ mergeBy locFn toks directiveToks
                  -- return directiveToks
                  -- return toks
             GHC.PFailed span err ->
               do dflags <- GHC.getDynFlags
#if __GLASGOW_HASKELL__ > 704
                  throw $ GHC.mkSrcErr (GHC.unitBag $ GHC.mkPlainErrMsg dflags span err)
#else
                  throw $ GHC.mkSrcErr (GHC.unitBag $ GHC.mkPlainErrMsg        span err)
#endif

locFn (GHC.L l1 _,_) (GHC.L l2 _,_) = compare l1 l2

-- ---------------------------------------------------------------------

-- | The preprocessed files are placed in a temporary directory, with
-- a temporary name, and extension .hscpp. Each of these files has
-- three lines at the top identifying the original origin of the
-- files, which is ignored by the later stages of compilation except
-- to contextualise error messages.
getPreprocessedSrc ::
  GHC.GhcMonad m => FilePath -> m GHC.StringBuffer
getPreprocessedSrc srcFile = do
  df <- GHC.getSessionDynFlags
  d <- GHC.liftIO $ getTempDir df
  fileList <- GHC.liftIO $ getDirectoryContents d
  let suffix = "hscpp"

  let cppFiles = filter (\f -> getSuffix f == suffix) fileList
  origNames <- GHC.liftIO $ mapM getOriginalFile $ map (\f -> d </> f) cppFiles
  let tmpFile = head $ filter (\(o,_) -> o == srcFile) origNames
  buf <- GHC.liftIO $ GHC.hGetStringBuffer $ snd tmpFile

  -- strSrcWithHead <- GHC.liftIO $ readFile $ snd tmpFile
  -- let strSrc = unlines $ drop 3 $ lines strSrcWithHead
  -- let strSrcBuf = GHC.stringToStringBuffer strSrc

  return buf

-- ---------------------------------------------------------------------

getSuffix :: FilePath -> String
getSuffix fname = reverse $ fst $ break (== '.') $ reverse fname

-- | A GHC preprocessed file has the following comments at the top
-- @
-- # 1 "./test/testdata/BCpp.hs"
-- # 1 "<command-line>"
-- # 1 "./test/testdata/BCpp.hs"
-- @
-- This function reads the first line of the file and returns the
-- string in it.
-- NOTE: no error checking, will blow up if it fails
getOriginalFile :: FilePath -> IO (FilePath,FilePath)
getOriginalFile fname = do
  fcontents <- readFile fname
  let firstLine = head $ lines fcontents
  let (_,originalFname) = break (== '"') firstLine
  return $ (tail $ init $ originalFname,fname)

-- ---------------------------------------------------------------------

-- | Get the preprocessor directives as comment tokens from the
-- source.
getPreprocessorAsComments :: FilePath -> IO [(GHC.Located GHC.Token, String)]
getPreprocessorAsComments srcFile = do
  fcontents <- readFile srcFile
  let directives = filter (\(_lineNum,line) -> line /= [] && head line == '#') $ zip [1..] $ lines fcontents

  let mkTok (lineNum,line) = (GHC.L l (GHC.ITlineComment line),line)
       where
         start = GHC.mkSrcLoc (GHC.mkFastString srcFile) lineNum 1
         end   = GHC.mkSrcLoc (GHC.mkFastString srcFile) lineNum (length line)
         l = GHC.mkSrcSpan start end

  let toks = map mkTok directives
  return toks

-- ---------------------------------------------------------------------
-- Copied from the GHC source, since not exported

getModuleSourceAndFlags :: GHC.GhcMonad m => GHC.Module -> m (String, GHC.StringBuffer, GHC.DynFlags)
getModuleSourceAndFlags mod = do
  m <- GHC.getModSummary (GHC.moduleName mod)
  case GHC.ml_hs_file $ GHC.ms_location m of
    Nothing -> do dflags <- GHC.getDynFlags
#if __GLASGOW_HASKELL__ > 704
                  GHC.liftIO $ throwIO $ GHC.mkApiErr dflags (GHC.text "No source available for module " GHC.<+> GHC.ppr mod)
#else
                  GHC.liftIO $ throwIO $ GHC.mkApiErr        (GHC.text "No source available for module " GHC.<+> GHC.ppr mod)
#endif
                  -- error $ ("No source available for module " ++ showGhc mod)
    Just sourceFile -> do
        source <- GHC.liftIO $ GHC.hGetStringBuffer sourceFile
        return (sourceFile, source, GHC.ms_hspp_opts m)

-- return our temporary directory within tmp_dir, creating one if we
-- don't have one yet
getTempDir :: GHC.DynFlags -> IO FilePath
getTempDir dflags
  = do let ref = GHC.dirsToClean dflags
           tmp_dir = GHC.tmpDir dflags
       mapping <- readIORef ref
       case Map.lookup tmp_dir mapping of
           Nothing -> error "should already be a tmpDir"
           Just d -> return d

