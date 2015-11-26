module Language.Haskell.Refact.Refactoring.UnwrapTypeSyn where

import qualified Language.Haskell.GhcMod as GM
import qualified Language.Haskell.GhcMod.Internal as GM
import Language.Haskell.Refact.API

unwrapTypeSyn :: RefactSettings -> GM.Options -> FilePath -> String -> IO [FilePath]
unwrapTypeSyn settings opts fileName synName = undefined
