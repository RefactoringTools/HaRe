module Language.Haskell.Refact.Refactoring.DeleteDef where

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB
import BasicTypes
import qualified GHC 
import Control.Monad
import Language.Haskell.GhcMod
import Language.Haskell.Refact.API

deleteDef :: RefactSettings -> Cradle -> FilePath -> SimpPos -> IO [FilePath]
deleteDef settings cradle fileName (row,col) =
  runRefacSession settings cradle (comp fileName (row,col))

comp ::FilePath -> SimpPos -> RefactGhc [ApplyRefacResult]
comp fileName (row,col) = do
  getModuleGhc fileName
  renamed <- getRefactRenamed
  parsed <- getRefactParsed
  let (Just (modName,_)) = getModuleName parsed
  let maybePn = locToName (row, col) renamed
  case maybePn of
    Just pn ->
      do
        (refactoredMod@((_fp,ismod),(_,_toks',renamed')),_) <- applyRefac (doDeletion pn) (RSFile fileName)
        case (ismod) of
          False -> do
            error "The def deletion failed"
          True -> return ()
        return [refactoredMod]
    Nothing -> error "Invalid cursor position!"
    
doDeletion :: GHC.Located GHC.Name -> RefactGhc ()
doDeletion (GHC.L _ n) = do
  renamed <- getRefactRenamed
  void $ rmDecl n True renamed
  return ()
