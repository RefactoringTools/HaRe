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
import qualified Language.Haskell.GhcMod as GM
import qualified Language.Haskell.GhcMod.Internal as GM

deleteDef :: RefactSettings -> GM.Options -> FilePath -> SimpPos -> IO [FilePath]
deleteDef settings cradle fileName (row,col) =
  runRefacSession settings cradle (comp fileName (row,col))

comp ::FilePath -> SimpPos -> RefactGhc [ApplyRefacResult]
comp fileName (row,col) = do
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
          (refRes@((_fp,ismod), _),()) <- applyRefac (doDeletion pn) RSAlreadyLoaded
          case (ismod) of
            RefacUnmodifed -> do
              error "The def deletion failed"
            RefacModified -> return ()
          return [refRes]
    Nothing -> error "Invalid cursor position!"


isPNUsed :: GHC.Name -> GHC.ModuleName -> FilePath -> RefactGhc Bool
isPNUsed pn modName filePath = do
  renamed <- getRefactRenamed
  pnUsedLocally <- pnUsedInScope pn renamed
  if pnUsedLocally
     then return True
    else do
    let modPath = GM.ModulePath{GM.mpModule = modName, GM.mpPath = filePath} in
      isPNUsedInClients pn modPath

pnUsedInScope :: (SYB.Data t) => GHC.Name -> t -> RefactGhc Bool
pnUsedInScope pn t' = do
  res <- applyTU (stop_tdTU (failTU `adhocTU` bind `adhocTU` var)) t'
  return $ (length res) > 0
    where
      bind ((GHC.FunBind (GHC.L l name) _ match _ _ _) :: GHC.HsBindLR GHC.Name GHC.Name)
        | name == pn = do
            logm $ "Found Binding at: " ++ (showGhc l) 
            return []
      bind other = mzero
      var ((GHC.HsVar name) :: GHC.HsExpr GHC.Name)
        | name == pn = do
            logm $ "Found var"
            return [pn]
      var other = mzero
                  
     
isPNUsedInClients :: GHC.Name -> GM.ModulePath -> RefactGhc Bool
isPNUsedInClients pn modPath = do
        pnIsExported <- isExported pn
        if pnIsExported
          then do clients <- clientModsAndFiles modPath
                  logm $ "DeleteDef : clients: " ++ (showGhc clients)
                  res <- foldM (pnUsedInClientScope pn) False clients
                  return res
          else do return False
                  
pnUsedInClientScope :: GHC.Name -> Bool -> TargetModule -> RefactGhc Bool
pnUsedInClientScope name b mod = do
  getTargetGhc mod
  isInScope <- isInScopeAndUnqualifiedGhc (nameToString name) Nothing
  logm $ "The module file path: " ++ (show (GM.mpPath mod)) ++ "\n is pn in scope: " ++ (show isInScope)
  return (b || isInScope)

doDeletion :: GHC.Located GHC.Name -> RefactGhc ()
doDeletion (GHC.L _ n) = do
  renamed <- getRefactRenamed
  void $ rmDecl n True renamed
  return ()
