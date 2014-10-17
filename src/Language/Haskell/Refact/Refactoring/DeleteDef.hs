{-# LANGUAGE ScopedTypeVariables #-}
module Language.Haskell.Refact.Refactoring.DeleteDef where

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB
import BasicTypes
import qualified GHC 
import Control.Monad
import Control.Monad.State
import Language.Haskell.GhcMod
import Language.Haskell.Refact.API
import Data.Generics.Strafunski.StrategyLib.StrategyLib

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
        logm $ "DeleteDef.comp: before isPNUsed"
        pnIsUsed <- isPNUsed n modName fileName
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


isPNUsed :: GHC.Name -> GHC.ModuleName -> FilePath -> RefactGhc Bool
isPNUsed pn modName filePath = do
  renamed <- getRefactRenamed
  pnUsedLocally <- pnUsedInScope pn renamed
  if pnUsedLocally
     then return True
    else do
      isPNUsedInClients pn modName

pnUsedInScope :: (SYB.Data t) => GHC.Name -> t -> RefactGhc Bool
pnUsedInScope pn t' = do
  res <- applyTU (stop_tdTUGhc (failTU `adhocTU`
                                bind `adhocTU`
                                var)) t'
  --logm $ "Res: " ++ (showGhc res)
  return $ (length res) > 0
  where
    var ((GHC.HsVar pn) :: GHC.HsExpr GHC.Name) = do
      logm $ "Found var"
      return [pn]
    var _ = return mzero
    bind ((GHC.FunBind (GHC.L _ pn) _ _ _ _ _) :: GHC.HsBindLR GHC.Name GHC.Name) = do
      logm "FoundBinding"
      return []
    bind _ = return mzero
isPNUsedInLocal :: GHC.Name -> GHC.ModuleName -> FilePath -> RefactGhc Bool
isPNUsedInLocal pn modName filePath = do
  modSum <- GHC.getModSummary modName
  let tm = ([filePath],modSum)
  return False
      
isPNUsedInClients :: GHC.Name -> GHC.ModuleName -> RefactGhc Bool
isPNUsedInClients pn modName = do
        pnIsExported <- isExported pn
        if pnIsExported
          then do clients <- clientModsAndFiles modName
                  logm $ "DeleteDef : clients: " ++ (showGhc clients)
                  res <- foldM (pnUsedInClientScope pn) False clients
                  return res
          else do return False
                  
pnUsedInClientScope :: GHC.Name -> Bool -> TargetModule -> RefactGhc Bool
pnUsedInClientScope name b mod@(fps, _sum) = do
  void $ activateModule mod
  isInScope <- isInScopeAndUnqualifiedGhc (nameToString name) Nothing
  logm $ "The module file path: " ++ (show fps) ++ "\n is pn in scope: " ++ (show isInScope)
  return (b || isInScope)

doDeletion :: GHC.Located GHC.Name -> RefactGhc ()
doDeletion (GHC.L _ n) = do
  renamed <- getRefactRenamed
  void $ rmDecl n True renamed
  return ()
