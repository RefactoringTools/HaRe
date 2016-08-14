module Language.Haskell.Refact.Refactoring.GenApplicative where

import Language.Haskell.Refact.API
import qualified Language.Haskell.GhcMod as GM
import qualified GHC as GHC
import System.Directory


genApplicative :: RefactSettings -> GM.Options -> FilePath -> String -> IO [FilePath]
genApplicative settings cradle fileName funNm = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings cradle (comp absFileName funNm)

comp :: FilePath -> String -> RefactGhc [ApplyRefacResult]
comp fileName funNm = do
  (refRes@((_fp,ismod),_), ()) <- applyRefac (doGenApplicative fileName funNm) (RSFile fileName)
  case ismod of
    RefacUnmodifed -> error "Generalise to Applicative failed"
    RefacModified -> return ()
  return [refRes]

doGenApplicative :: FilePath -> String -> RefactGhc ()
doGenApplicative fileName funNm = undefined
  
