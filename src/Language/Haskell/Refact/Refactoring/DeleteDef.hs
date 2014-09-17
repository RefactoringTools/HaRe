module Language.Haskell.Refact.Refactoring.DeleteDef where

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import qualified GHC 

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
          False -> error "The def deletion failed"
          True -> return ()
        return [refactoredMod]
    Nothing -> error "Invalid cursor position!"


--refactoredMod :: ApplyRefacResult = ((FilePath, Bool), ([Line], [PosToken], RenamedSource)), RenamedSource

doDeletion :: GHC.Located GHC.Name -> RefactGhc ()
doDeletion pn = do
  renamed  <- getRefactRenamed
  reallyDoDeletion pn renamed
  
reallyDoDeletion :: GHC.Located GHC.Name -> GHC.RenamedSource -> RefactGhc ()
reallyDoDeletion (GHC.L _ n) renamed = do
  renamed'<- everywhereMStaged SYB.Renamer (SYB.mkM delInMod) renamed
  logm $ SYB.showData SYB.Renamer 2 renamed'
  putRefactRenamed renamed'
  return ()
    where
      -- The definition to be deleted is at the top level
      delInMod :: (GHC.HsValBindsLR GHC.Name GHC.Name) -> RefactGhc (GHC.HsValBindsLR GHC.Name GHC.Name)
      delInMod (GHC.ValBindsOut tups sigs) =
        do
          --logm $ "\nIn delInMod\n" ++ SYB.showData SYB.Renamer 2 tups
          let newTups = [tups!!0]--removePNfromList tups
          logm $ SYB.showData SYB.Renamer 2 newTups
          return $ (GHC.ValBindsOut newTups sigs)
      {-removePNfromList [] = []
      removePNfromList (x@(_recFlag, bind) :xs) =
        if isPn bind
           then removePNfromList xs
        else x : removePNfromList xs
      isPn = SYB.everything (||) (False `SYB.mkQ` ncomp)
      ncomp name = n == name-}
