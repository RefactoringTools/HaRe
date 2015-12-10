module Language.Haskell.Refact.Refactoring.MaybeToMonadPlus where

import Language.Haskell.Refact.API
import qualified Language.Haskell.GhcMod as GM
import qualified Language.Haskell.GhcMod.Internal as GM
import System.Directory

maybeToMonadPlus :: RefactSettings -> GM.Options -> FilePath -> SimpPos -> String -> IO [FilePath]
maybeToMonadPlus settings cradle fileName pos funNm = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings cradle (comp absFileName pos funNm)

comp :: FilePath -> SimpPos -> String -> RefactGhc [ApplyRefacResult]
comp fileName (row,col) funNm = do
  return []
