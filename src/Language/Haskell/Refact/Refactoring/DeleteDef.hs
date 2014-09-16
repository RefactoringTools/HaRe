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
  inscopes <- getRefactInscopes
  renamed  <- getRefactRenamed
  reallyDoDeletion pn inscopes renamed

reallyDoDeletion :: GHC.Located GHC.Name -> InScopes -> GHC.RenamedSource -> RefactGhc ()
reallyDoDeletion (GHC.L _ n) inscopes renamed = do
  renamed'<- everywhereMStaged SYB.Renamer (SYB.mkM delInMod) renamed
  putRefactRenamed renamed'
  return ()
    where
      -- The definition to be deleted is at the top level
      delInMod :: (GHC.HsValBindsLR GHC.Name GHC.Name) -> RefactGhc (GHC.HsValBindsLR GHC.Name GHC.Name)
      delInMod (GHC.ValBindsOut tups sigs) =
        do
          let newTups = removePNfromList tups
          logm $ "\n==========================================\n" ++ (SYB.showData SYB.Parser 2 newTups) ++ "\n"
          return $ (GHC.ValBindsOut newTups sigs)
      removePNfromList [] = []
      removePNfromList (x@(_recFlag, bind) :xs) =
        if isPn bind
           then removePNfromList xs
        else x : removePNfromList xs
      isPn = SYB.everything (||) (False `SYB.mkQ` ncomp)
      ncomp name = n == name
