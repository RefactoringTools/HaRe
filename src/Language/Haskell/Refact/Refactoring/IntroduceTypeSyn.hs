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
import Unique
import Lexer
import DynFlags
import StringBuffer
import Bag
import SrcLoc
import Outputable

introduceTypeSyn :: RefactSettings -> Cradle -> FilePath -> SimpPos -> String -> String -> IO [FilePath]
introduceTypeSyn settings cradle fileName (row,col) newName typeRep=
  runRefacSession settings cradle (comp fileName (row,col) newName typeRep)

comp ::FilePath -> SimpPos -> String -> String -> RefactGhc [ApplyRefacResult]
comp fileName (row,col) newName typeRep = do
  getModuleGhc fileName
  renamed <- getRefactRenamed
  m <- getModule
  (refactoredMod@((_fp,ismod),(_,_toks',renamed')),_) <- applyRefac (addSyn (row,col) newName typeRep fileName) RSAlreadyLoaded
  case ismod of
    False -> error "Introduce type synonym failed"
    True -> return ()
  return [refactoredMod]
  {-let (Just (modName,_)) = getModuleName parsed
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
    Nothing -> error "Given location does not correspond to type"-}
      

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
          GHC.L _ syn = GHC.td_synRhs $ GHC.tcdTyDefn decl
          name = mkName newName
{-TODO syn is the type synonym that needs to be inserted into the renamed AST -}
      --error $ SYB.showData SYB.TypeChecker 3 syn
      addTypeDecl fullStr (row, col) decl
      doIntro name syn 
      return ()

mkName :: String -> GHC.Name
mkName str = GHC.mkSystemName unique occ
  where unique = getUnique $ fsLit str
        occ = GHC.mkTyVarOcc str

addTypeDecl :: String -> SimpPos -> GHC.TyClDecl GHC.Name -> RefactGhc ()
addTypeDecl declStr (row,col) decl = do
  --TODO the fast strings in the srclocs should have module information
  r@(group,id,lie,ds) <- getRefactRenamed
  dflags <- getDynFlags
  let srcLoc = mkRealSrcLoc (fsLit declStr) row col
      buff = stringToStringBuffer declStr
      pres = Lexer.lexTokenStream buff srcLoc dflags
  case pres of
    Lexer.POk pstate toks -> do 
      let l1 = mkSrcLoc (fsLit "") row col
          l2 = mkSrcLoc (fsLit "") row (col + (length declStr))
          span = mkSrcSpan l1 l2
          ldecl = (GHC.L span decl)
          posTokens = GHC.addSourceToTokens srcLoc buff toks
          tyclds = GHC.hs_tyclds group
          newR = (group {GHC.hs_tyclds = tyclds ++ [[ldecl]]}, id, lie, ds)
--      putRefactRenamed newR
--      error $ SYB.showData SYB.Renamer 3 ldecl
--      error $ show posTokens
      void $ putToksForSpan span posTokens    
      return ()
    Lexer.PFailed _ msg -> error $ "Lexer error: " ++  (showSDoc dflags msg)

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

adjustPosTokens :: [PosToken] -> Int -> Int -> [PosToken]
adjustPosTokens [] _ _ = []
adjustPosTokens (((GHC.L l t), str):rst) row col = (new:rest)
  where rest = adjustPosTokens rst row col
        new = ((GHC.L new_span t), str)
        new_span = updateSrcSpan l row col

updateSrcLoc :: RealSrcLoc -> Int -> Int -> RealSrcLoc
updateSrcLoc old_loc row col = mkRealSrcLoc fs new_row new_col
  where fs = srcLocFile old_loc
        new_row = row + (srcLocLine old_loc)
        new_col = col + (srcLocCol old_loc)

updateSrcSpan :: SrcSpan -> Int -> Int -> SrcSpan
updateSrcSpan span row col = mkSrcSpan start end
  where start = wrapSrcLoc $ updateSrcLoc (unwrapSrcLoc $ srcSpanStart span) row col
        end = wrapSrcLoc $ updateSrcLoc (unwrapSrcLoc $ srcSpanEnd span) row col

unwrapSrcLoc :: SrcLoc -> RealSrcLoc
unwrapSrcLoc loc =
  case loc of
    RealSrcLoc rl -> rl
    UnhelpfulLoc _ -> error "Given unhelpful source location."

wrapSrcLoc :: RealSrcLoc -> SrcLoc
wrapSrcLoc rl = RealSrcLoc rl
