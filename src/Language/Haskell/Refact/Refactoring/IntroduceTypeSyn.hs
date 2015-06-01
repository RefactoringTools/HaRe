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
import FastString
import Lexer
import DynFlags
import StringBuffer
import Bag

introduceTypeSyn :: RefactSettings -> Cradle -> FilePath -> SimpPos -> String -> String -> IO [FilePath]
introduceTypeSyn settings cradle fileName (row,col) newName typeRep=
  runRefacSession settings cradle (comp fileName (row,col) newName typeRep)

comp ::FilePath -> SimpPos -> String -> String -> RefactGhc [ApplyRefacResult]
comp fileName (row,col) newName typeRep = do
  getModuleGhc fileName
  renamed <- getRefactRenamed
  parsed <- getRefactParsed
  m <- getModule
  (refactoredMod@((_fp,ismod),(_,_toks',renamed')),_) <- applyRefac (addSyn (row,col) newName typeRep fileName) RSAlreadyLoaded
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
      

addSyn :: SimpPos -> String -> String -> FilePath -> RefactGhc ()
addSyn (row, col) newName typeRep fileName = do
  renamed <- getRefactRenamed
  parsed <- getRefactParsed
  let maybePn = locToName (row,col) renamed
  case maybePn of
    Just _ -> error "Introduce type synonym failed value already defined at source location"
    Nothing -> do
      let fullStr = "type " ++ newName ++ " = " ++ typeRep
          (modName, str) = gfromJust "Tried to get mod name" $ getModuleName parsed
          buff = stringToStringBuffer fullStr
      modSum <- GHC.getModSummary modName
      let newSum = modSum {GHC.ms_hspp_buf = Just buff}
      typedMod <- GHC.parseModule newSum >>= GHC.typecheckModule
      let Just (group, _ , _ , _ ) = GHC.tm_renamed_source typedMod
          [[(GHC.L _ decl)]] = GHC.hs_tyclds group
          lsyn@(GHC.L _ syn) = GHC.td_synRhs $ GHC.tcdTyDefn decl
          names = GHC.hsExplicitTvs lsyn
{-TODO syn is the type synonym that needs to be inserted into the renamed AST -}
      error $ SYB.showData SYB.TypeChecker 3 syn
      --doIntro name syn
      return ()
      
doIntro :: GHC.Name -> GHC.HsType GHC.Name -> RefactGhc ()
doIntro name ty = do
  renamed <- getRefactRenamed
  let sigs = getTypeSigs renamed
  everywhereMStaged SYB.Renamer (SYB.mkM replaceTypeVar) sigs
  return ()
  where
    newTyVar = (GHC.HsTyVar name)    
    replaceTypeVar :: (GHC.LHsType GHC.Name) -> RefactGhc (GHC.LHsType GHC.Name)
    replaceTypeVar old@(GHC.L l oldTy)
      | compareHsType oldTy ty
      = do
           new <- worker l old
           return (GHC.L l newTyVar)
    replaceTypeVar x = return x
    worker loc old= do
      let str = GHC.getOccString name
          fastStr = fsLit str
          tok = (GHC.L loc (ITconid fastStr), str)
      (_, expr') <- putDeclToksForSpan loc old [tok]
      return ()
    

--TODO implement this 
compareHsType :: (GHC.HsType GHC.Name) -> (GHC.HsType GHC.Name) -> Bool
compareHsType (GHC.HsTyVar n1) (GHC.HsTyVar n2) = n1 == n2
compareHsType (GHC.HsTupleTy _ lst1) (GHC.HsTupleTy _ lst2) = compareTyList lst1 lst2
compareHsType _ _ = False

compareTyList :: [GHC.LHsType GHC.Name] -> [GHC.LHsType GHC.Name] -> Bool
compareTyList [] [] = True
compareTyList ((GHC.L _ ty1):rst1) ((GHC.L _ ty2):rst2) = (compareHsType ty1 ty2) && (compareTyList rst1 rst2)
compareTyList _ _ = False


getTypeSigs :: (SYB.Data t, SYB.Typeable t) => t -> [GHC.LSig GHC.Name]
getTypeSigs t =
  case res of
    Just a -> a
    Nothing -> error "No type signatures found in module"
  
  where res = somethingStaged SYB.Renamer Nothing (Nothing `SYB.mkQ` worker) t
        worker ((GHC.ValBindsOut _ lst):: GHC.HsValBinds GHC.Name) = Just lst
