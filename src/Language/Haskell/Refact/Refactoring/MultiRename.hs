module Language.Haskell.Refact.Refactoring.MultiRename (multRename) where
import Language.Haskell.Refact.Refactoring.Renaming
import qualified Language.Haskell.GhcMod as GM (Options(..))
import Language.Haskell.Refact.API

multRename :: RefactSettings -> GM.Options -> FilePath -> String -> SimpPos -> IO [FilePath]
multRename set opts fp n pos = do
  rename set opts fp n pos
  {-putStrLn "Do you want to rename now? (y/n)"
  inStr <- getLine
  case inStr of
    "y" -> rename set opts fp n pos
    "n" -> return []  -}

