module Language.Haskell.Refact.Refactoring.UnwrapTypeSyn where

import qualified Language.Haskell.GhcMod as GM
import qualified Language.Haskell.GhcMod.Internal as GM
import Language.Haskell.Refact.API
import qualified GHC
import qualified Name as GHC
import qualified RdrName as GHC
import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.GHC.ExactPrint.Transform
import qualified Data.Generics as SYB
import GHC.SYB.Utils
import System.Directory
import qualified Language.Haskell.Refact.Refactoring.DeleteDef as DelDef
import qualified Data.List as List
import qualified Data.Map as Map
import qualified GHC.SYB.Utils as SYB

unwrapTypeSyn :: RefactSettings -> GM.Options -> FilePath -> SimpPos -> String -> IO [FilePath]
unwrapTypeSyn settings opts fileName pos synName = do
  absFileName <- canonicalizePath fileName
  let comp1 = comp absFileName pos synName
      comp2 = DelDef.comp absFileName pos
  runMultRefacSession settings opts [comp1,comp2]

{-
1. Get RHS definition of type synonym
2. Traversal to find uses of synonym in primary module, replace uses of synonym with RHS
3. Same as step 2 but in client modules
4. delete synonym definition
-}

comp :: FilePath -> SimpPos -> String -> RefactGhc [ApplyRefacResult]
comp fileName (row,col) synName = do
  parseSourceFileGhc fileName
  (rdrName, decl, relevantAnns) <- getTypeAndAnns fileName (row,col) synName                      
  (refRes@((fp,ismod), _),isExported) <- applyRefac' False (doReplace rdrName decl relevantAnns) (RSFile fileName)
  case ismod of
    RefacUnmodifed -> error "Unwrap type synonym failed"
    RefacModified -> return [refRes]

-- synName is the name of the synonym to remove
-- lDecl is the RHS of that synonym
-- tyAnns are the annotations from the RHS of the synonym
doReplace :: GHC.RdrName -> (GHC.LHsType GHC.RdrName) -> Anns -> RefactGhc Bool
doReplace synName lDecl@(GHC.L l dec) tyAnns = do
  parsed <- getRefactParsed
  newParsed <- everywhereMStaged Parser (SYB.mkM replaceSig) parsed
  currAnns <- fetchAnnsFinal
  let rhsAnns = lookupAllAnns currAnns l
      diffAnns = (Map.difference currAnns rhsAnns)
  putRefactParsed newParsed diffAnns
  setRefactAnns diffAnns
  return False
  where replaceSig :: (GHC.LHsType GHC.RdrName) -> RefactGhc (GHC.LHsType GHC.RdrName)
        replaceSig old@(GHC.L l2 (GHC.HsTyVar name)) = do
          if name == synName
            then do
               newDec <- everywhereMStaged Parser (SYB.mkM updateLocations) lDecl
               currAnns <- fetchAnnsFinal
               let k = (mkAnnKey newDec)
                   (Just decAnn) = Map.lookup k currAnns
                   -- Setting the delta pos to (0,0) here to prevent one extra space following the colon in the type signature
                   newAnns = Map.insert k (decAnn{annEntryDelta = (DP (0,0))}) currAnns
               setRefactAnns newAnns
               return newDec
            else return old
        replaceSig x = return x
        updateLocations :: (GHC.LHsType GHC.RdrName) -> RefactGhc (GHC.LHsType GHC.RdrName)
        updateLocations lTy@(GHC.L l ty) = do
          newSpn <- liftT uniqueSrcSpanT
          currAnns <- fetchAnnsFinal
          let annKey = mkAnnKey lTy
              mAnn = Map.lookup annKey currAnns
              res = (GHC.L newSpn ty)
          case mAnn of
            Nothing -> return ()
            (Just ann) -> do
              let newKey = mkAnnKey res
              setRefactAnns (Map.insert newKey ann currAnns)
          return res
        updateLocations x = return x

{- With more complex RHS types just replacing the root's location is not sufficient.
   I will have to decend the AST piece get new 
-}

getTypeAndAnns :: FilePath -> SimpPos -> String -> RefactGhc (GHC.RdrName, GHC.LHsType GHC.RdrName, Anns)
getTypeAndAnns fileName (row,col) synName = do
  parsed <- getRefactParsed
  let maybePn = locToRdrName (row,col) parsed
  case maybePn of
    Nothing -> error "Indicated position does not correspond with a type synonym"
    Just name@(GHC.L _ nm) -> do
      synRhs@(GHC.L l _) <- getRhs name
      anns <- fetchAnnsFinal
      let rhsAnns = lookupAllAnns anns l
      return (nm, synRhs, rhsAnns)

getRhs :: (GHC.Located GHC.RdrName) -> RefactGhc (GHC.LHsType GHC.RdrName)
getRhs (GHC.L l name) = do
  (GHC.L _ parsed) <- getRefactParsed
  let decs = GHC.hsmodDecls parsed
      (before, (dec: after)) = break isDecl decs
  return $ getSynRhs dec
  where
    isDecl :: (GHC.LHsDecl GHC.RdrName) -> Bool
    isDecl (GHC.L _ (GHC.TyClD synDec)) = if compareNames synName name
                                          then True
                                          else False
      where (GHC.L _ synName) = GHC.tcdLName synDec
    getSynRhs :: (GHC.LHsDecl GHC.RdrName) -> (GHC.LHsType GHC.RdrName)
    getSynRhs (GHC.L _ (GHC.TyClD synDec@(GHC.SynDecl _ _ _ _))) = GHC.tcdRhs synDec
    getSynRhs _ = error "getSynRhs was called with a non type synonym ast chunk."

compareNames :: (GHC.HasOccName a, GHC.HasOccName b) => a -> b -> Bool
compareNames nm1 nm2 = let occ1 = GHC.occName nm1
                           occ2 = GHC.occName nm2 in
                       occ1 == occ2
