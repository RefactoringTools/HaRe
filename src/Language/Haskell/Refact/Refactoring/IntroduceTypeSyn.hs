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
        (GHC.TySynonym (GHC.L _ ty)) -> error $ show (SYB.typeOf ty)
        _ -> error "Given type is not simple type synonym"
    Nothing -> error "Given location does not correspond to type"
      
      
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
  
                          

