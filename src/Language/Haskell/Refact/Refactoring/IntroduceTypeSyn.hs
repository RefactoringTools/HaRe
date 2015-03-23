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
        (GHC.TySynonym (GHC.L _ ty)) -> do
          (refactoredMod@((_fp,ismod),(_,_toks',renamed')),_) <- applyRefac (doIntro name ty) RSAlreadyLoaded
          case (ismod) of
            False -> error "Introduce type synonym failed"
            True -> return ()
          return [refactoredMod]
        _ -> error "Given type is not type synonym"
    Nothing -> error "Given location does not correspond to type"
      

doIntro :: GHC.Name -> GHC.HsType GHC.Name -> RefactGhc ()
doIntro name ty =
  case ty of
    (GHC.HsTupleTy sort ts) -> error "Tuple type"
    (GHC.HsTyVar n) -> error "Type var"
    _ -> error "Unsupported type synonym"
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
  
                          

