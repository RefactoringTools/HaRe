module Language.Haskell.Refact.Refactoring.UnwrapTypeSyn where

import qualified Language.Haskell.GhcMod as GM
import qualified Language.Haskell.GhcMod.Internal as GM
import Language.Haskell.Refact.API
import qualified GHC
import qualified Name as GHC
import qualified RdrName as GHC


unwrapTypeSyn :: RefactSettings -> GM.Options -> FilePath -> SimpPos -> String -> IO [FilePath]
unwrapTypeSyn settings opts fileName pos synName = runRefacSession settings opts (comp fileName pos synName)

comp :: FilePath -> SimpPos -> String -> RefactGhc [ApplyRefacResult]
comp fileName (row,col) synName = do
  (refRes@((_fp,ismod), _),()) <- applyRefac (delSyn fileName (row,col) synName) (RSFile fileName)
  case ismod of
    RefacUnmodifed -> error "Unwrap type synonym failed"
    RefacModified -> return ()
  return [refRes]

delSyn :: FilePath -> SimpPos -> String -> RefactGhc ()
delSyn fileName (row,col) synName = do
  parsed <- getRefactParsed
  let maybePn = locToName (row,col) parsed
  case maybePn of
    Nothing -> error "Indicated position does not correspond with a type synonym"
    Just name -> do
      {-
1. Get RHS definition of type synonym
2. Traversal to find uses of synonym in primary module, replace uses of synonym with RHS
3. Same as step 2 but in client modules
4. delete synonym definition
-}
      synRhs <- getRhs name
      return ()
  return ()

getRhs :: (GHC.Located GHC.Name) -> RefactGhc (GHC.LHsType GHC.RdrName)
getRhs (GHC.L l name) = do
  parsed <- getRefactParsed
  
  where
    getSynRhs :: (GHC.TyClDecl name) -> RefactGhc (GHC.LHsType name)
    getSynRhs (GHC.SynDecl _ _ rhs _) = return rhs
