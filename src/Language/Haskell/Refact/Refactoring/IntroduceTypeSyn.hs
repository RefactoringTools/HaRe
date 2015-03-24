{-# LANGUAGE ScopedTypeVariables #-}
module Language.Haskell.Refact.Refactoring.IntroduceTypeSyn where

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB
import qualified GHC
import qualified Name as GHC
import qualified RdrName as GHC
import Control.Monad
import Language.Haskell.GhcMod
import Language.Haskell.Refact.API
import Data.Generics.Strafunski.StrategyLib.StrategyLib
import Language.Haskell.TokenUtils.GHC.Layout (newNameTok)

introduceTypeSyn :: RefactSettings -> Cradle -> FilePath -> SimpPos -> IO [FilePath]
introduceTypeSyn settings cradle fileName (row,col) =
  runRefacSession settings cradle (comp fileName (row,col))

comp ::FilePath -> SimpPos -> RefactGhc [ApplyRefacResult]
comp fileName (row,col) = do
  getModuleGhc fileName
  renamed <- getRefactRenamed
  parsed <- getRefactParsed
  m <- getModule
  let (Just (modName,_)) = getModuleName parsed
      maybePn = locToType (row, col) renamed
  case maybePn of
    Just pn@(GHC.TyDecl (GHC.L _ name) _ tyDefn _) ->
      case tyDefn of
        (GHC.TySynonym (GHC.L _ ty)) -> do
          (refactoredMod@((_fp,ismod),(_,_toks',renamed')),_) <- applyRefac (doIntro name ty) RSAlreadyLoaded
          case (ismod) of
            False -> error "Introduce type synonym failed"
            True -> return ()
          return [refactoredMod]
        _ -> error "Given type is not type synonym"
    Nothing -> error "Given location does not correspond to type"
      

doIntro :: GHC.Name -> GHC.HsType GHC.Name -> RefactGhc ()
doIntro name ty = do
  renamed <- getRefactRenamed
  case ty of
    (GHC.HsTupleTy sort ts) -> error "Tuple type"
    (GHC.HsTyVar n) -> do
      renamed <- getRefactRenamed
      let sigs = getTypeSigs renamed
      everywhereMStaged SYB.Renamer (SYB.mkM replaceTypeVar) sigs
      return ()
    _ -> error "Unsupported type synonym"
  where
    newTyVar = (GHC.HsTyVar name)    
    replaceTypeVar :: (GHC.LHsType GHC.Name) -> RefactGhc (GHC.LHsType GHC.Name)
    replaceTypeVar (GHC.L l oldTy@(GHC.HsTyVar n))
      | compareTyVar oldTy ty
      = do
        worker l Nothing
        return (GHC.L l newTyVar)
    replaceTypeVar x = return x
    worker :: GHC.SrcSpan -> Maybe (GHC.ModuleName, GHC.OccName) -> RefactGhc ()
    worker l mmo = do
      let newTok = newNameTok False l name
      replaceToken l (markToken $ newTok)
      return ()
      

--TODO implement this 
compareTyVar :: (GHC.HsType GHC.Name) -> (GHC.HsType GHC.Name) -> Bool
compareTyVar t1 t2 = True

getTypeSigs :: (SYB.Data t, SYB.Typeable t) => t -> [GHC.LSig GHC.Name]
getTypeSigs t =
  case res of
    Just a -> a
    Nothing -> error "No type signatures found in module"
  
  where res = somethingStaged SYB.Renamer Nothing (Nothing `SYB.mkQ` worker) t
        worker ((GHC.ValBindsOut _ lst):: GHC.HsValBinds GHC.Name) = Just lst
      {-
      do
      logm $ "TypeSyn.comp: Inside nothing branch"
      validName <- isValidTypeName synonym
      unless validName (error "The new type name either conflicts with an existing identifier or is not a valid type name.")
      validType <- isValidType typeStr
      unless validType (error "The type string is not a valid type description")
      return []

isValidType :: String -> RefactGhc Bool
isValidType typeDesc = do
  ty <- GHC.exprType typeDesc
  logm $ "TypeSyn.isValidType: typeDesc is: " ++ showGhc ty
  return True

isValidTypeName :: String -> RefactGhc Bool
isValidTypeName newName = do
  renamed <- getRefactRenamed
  res <- applyTU (stop_tdTUGhc (failTU `adhocTU` named)) renamed
  return $ (isConId newName) && (res==(0::Int))
  where named (decl@(GHC.TyDecl (GHC.L l name) _ _ _)::GHC.TyClDecl GHC.Name) =
          if (GHC.getOccString name) == newName
          then return (1::Int)
          else return (0::Int)
  -}
  
                          

