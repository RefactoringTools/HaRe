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
import System.Directory

deleteDef :: RefactSettings -> GM.Options -> FilePath -> SimpPos -> IO [FilePath]
deleteDef settings cradle fileName (row,col) = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings cradle (comp absFileName (row,col))

comp ::FilePath -> SimpPos -> RefactGhc [ApplyRefacResult]
comp fileName (row,col) = do
  parseSourceFileGhc fileName
  renamed <- getRefactRenamed
  parsed <- getRefactParsed
  targetModule <- getRefactTargetModule
  m <- getModule
  let (Just (modName,_)) = getModuleName parsed
  let maybePn = locToName (row, col) renamed
  case maybePn of
    Just pn@(GHC.L _ n) ->
      do
        logm $ "DeleteDef.comp: before isPNUsed"
        pnIsUsedLocal <- isPNUsed n targetModule fileName
        clients <- clientModsAndFiles targetModule
        logm $ "DeleteDef: Clients: " ++ (show clients)
        pnUsedClients <- isPNUsedInClients n targetModule
        if (pnIsUsedLocal || pnUsedClients)
           then error "The def to be deleted is still being used"
          else do
          logm $ "Result of is used: " ++ (show pnIsUsedLocal) ++ " pnUsedClients: " ++ (show pnUsedClients)
          (refRes@((_fp,ismod), _),()) <- applyRefac (doDeletion pn) RSAlreadyLoaded
          {-case (ismod) of
            RefacUnmodifed -> do
              error "The def deletion failed"
            RefacModified -> return ()
          return [refRes]-}
          return [refRes]
    Nothing -> error "Invalid cursor position!"


isPNUsed :: GHC.Name -> GM.ModulePath -> FilePath -> RefactGhc Bool
isPNUsed pn modPath filePath = do
  renamed <- getRefactRenamed
  pnUsedLocally <- pnUsedInScope pn renamed
  if pnUsedLocally
     then return True
    else return False

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
  parsed <- getRefactParsed
  void $ rmDecl n True parsed
  return ()
