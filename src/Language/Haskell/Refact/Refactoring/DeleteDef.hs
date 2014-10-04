module Language.Haskell.Refact.Refactoring.DeleteDef where

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB
import BasicTypes
import qualified GHC 
import Control.Monad
import Control.Monad.State
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
  m <- getModule
  let (Just (modName,_)) = getModuleName parsed
  let maybePn = locToName (row, col) renamed
  case maybePn of
    Just pn@(GHC.L _ n) ->
      do
        pnIsUsed <- isPNUsed n modName
        if pnIsUsed
           then error "The def to be deleted is still being used"
          else do
          logm $ "Result of is used: " ++ (show pnIsUsed)
          (refactoredMod@((_fp,ismod),(_,_toks',renamed')),_) <- applyRefac (doDeletion pn) RSAlreadyLoaded
          case (ismod) of
            False -> do
              error "The def deletion failed"
            True -> return ()
          return [refactoredMod]
    Nothing -> error "Invalid cursor position!"
    
isPNUsed :: GHC.Name -> GHC.ModuleName -> RefactGhc Bool
isPNUsed pn modName = do
        --before this should check if pn is used in currentModule
        pnIsExported <- isExported pn
        if pnIsExported
          then do clients <- clientModsAndFiles modName
                  logm $ "DeleteDef : clients: " ++ (showGhc clients)
                  if (length clients) == 0
                     then do return False
                    else do
                       res <- foldM (pnUsedInScope pn) False clients
                       return res
          else do return False
                  

pnUsedInScope :: GHC.Name -> Bool -> TargetModule -> RefactGhc Bool
pnUsedInScope name b mod@(fps, _sum) = do
  void $ activateModule mod
  isInScope <- isInScopeAndUnqualifiedGhc (nameToString name) Nothing
  logm $ "The module file path: " ++ (show fps) ++ "\n is pn in scope: " ++ (show isInScope)
  return (b || isInScope)

doDeletion :: GHC.Located GHC.Name -> RefactGhc ()
doDeletion (GHC.L _ n) = do
  renamed <- getRefactRenamed
  void $ rmDecl n True renamed
  return ()
