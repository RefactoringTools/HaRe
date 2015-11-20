{-# LANGUAGE ScopedTypeVariables #-}
module Language.Haskell.Refact.Refactoring.IntroduceTypeSyn where

import qualified Data.Generics as SYB
import GHC.SYB.Utils
import qualified GHC
import qualified Name as GHC
import qualified RdrName as GHC
import Control.Monad
import Language.Haskell.GhcMod
import Language.Haskell.Refact.API
import Data.Generics.Strafunski.StrategyLib.StrategyLib
import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Parsers
import qualified Language.Haskell.GhcMod as GM
import qualified Language.Haskell.GhcMod.Internal as GM
--import Language.Haskell.TokenUtils.GHC.Layout (newNameTok)
import FastString
import Unique
import Lexer
import DynFlags
import StringBuffer
import Bag
import SrcLoc
import Outputable

introduceTypeSyn :: RefactSettings -> GM.Options -> FilePath -> SimpPos -> String -> String -> IO [FilePath]
introduceTypeSyn settings opts fileName (row,col) newName typeRep=
  runRefacSession settings opts (comp fileName (row,col) newName typeRep)

comp ::FilePath -> SimpPos -> String -> String -> RefactGhc [ApplyRefacResult]
comp fileName (row,col) newName typeRep = do
  (refRes@((_fp,ismod), _),()) <- applyRefac (addSyn (row,col) newName typeRep fileName) (RSFile fileName)
  case ismod of
    RefacUnmodifed -> error "Introduce type synonym failed"
    RefacModified -> return ()
  return [refRes]
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
    Just _ -> error "Introduce type synonym failed value already defined at given source location"
    Nothing -> do
      flags <- GHC.getSessionDynFlags
      let fullStr = "type " ++ newName ++ " = " ++ typeRep
          (modName, str) = gfromJust "Tried to get mod name" $ getModuleName parsed
          buff = stringToStringBuffer fullStr
          eTypeSyn = parseDecl flags fileName fullStr
      case eTypeSyn of
        Left _ -> error "Failed to parse new type synonym."
        Right (ann, decl@(GHC.L _ (GHC.TyClD inDecl))) -> do
          logm $ "Decl looks like: " ++ (showGhc decl)
          newParsed <- addDecl parsed Nothing ([decl], (Just ann))
          logm $ "Ann from parsing: " ++ (show ann)
          (liftT getAnnsT) >>= putRefactParsed newParsed
          let (GHC.L _ declName) = GHC.tcdLName inDecl
              (GHC.L _ declRHS) = GHC.tcdRhs inDecl
          updateTypeDecs declName declRHS ann


updateTypeDecs :: GHC.RdrName -> GHC.HsType GHC.RdrName -> Anns -> RefactGhc ()
updateTypeDecs synName ty newAnns = do
  parsed <- getRefactParsed
  newParsed <- everywhereButMStaged Parser (SYB.mkQ False skipSig) (SYB.mkM replaceSig) parsed  
  (liftT getAnnsT) >>= putRefactParsed newParsed
  --parsedFin <- getRefactParsed
  --logm $ "Final parsed AST:\n" ++ (showData Parser 2 parsedFin)
  --anns <- liftT getAnnsT
  --logm $ "Anns:\n" ++ (show anns)
  return ()
  where
    skipSig :: (GHC.LHsDecl GHC.RdrName) -> Bool
    skipSig sig@(GHC.L _ (GHC.TyClD syn@(GHC.SynDecl (GHC.L _ name) _ _ _)))
      | name == synName = True
    skipSig x = False
{-
   When we replace the signature we also need to modify the annotations.

   The traversal is going to need to work over GHC.LHsDecl rather than LHsType because we are going to need to be able to look up the annotations and that requires creating a key:

-- |Make an unwrapped @AnnKey@ for the @LHsDecl@ case, a normal one otherwise.
mkAnnKey :: (Data a) => GHC.Located a -> AnnKey


-}
    replaceSig :: (GHC.LHsType GHC.RdrName) -> RefactGhc (GHC.LHsType GHC.RdrName)
    replaceSig old@(GHC.L l oldTy)
      | compareHsType oldTy ty
      = do
          currAnns <- fetchAnnsFinal
          let correctSig = (GHC.L l (GHC.HsTyVar synName))
              sigStr     = exactPrint 
          return correctSig
    replaceSig x = return x
        
compareHsType :: (Eq name) => (GHC.HsType name) -> (GHC.HsType name) -> Bool
compareHsType (GHC.HsTyVar n1) (GHC.HsTyVar n2) = n1 == n2
compareHsType (GHC.HsTupleTy _ lst1) (GHC.HsTupleTy _ lst2) = compareTyList lst1 lst2
compareHsType _ _ = False

compareTyList :: (Eq name) => [GHC.LHsType name] -> [GHC.LHsType name] -> Bool
compareTyList [] [] = True
compareTyList ((GHC.L _ ty1):rst1) ((GHC.L _ ty2):rst2) = (compareHsType ty1 ty2) && (compareTyList rst1 rst2)
compareTyList _ _ = False

{-
mkName :: String -> GHC.Name
mkName str = GHC.mkSystemName unique occ
  where unique = getUnique $ fsLit str
        occ = GHC.mkTyVarOcc str

addTypeDecl :: String -> SimpPos -> GHC.TyClDecl GHC.Name -> RefactGhc ()
addTypeDecl declStr loc@(row,col) decl = do
  --TODO the fast strings in the srclocs should have module information
  renamed@(group, _ ,_ ,_) <- getRefactRenamed
  parsed <- getRefactParsed
  let (modName, str) = gfromJust "Tried to get mod name" $ getModuleName parsed
      newToks = basicTokenise declStr
      (startLoc, endLoc) = getStartEndLoc decl
--  error $ SYB.showData SYB.Renamer 3 decl
--  error $ show newToks
  void $ addToksAfterPos (startLoc,endLoc) (PlaceOffset row col 1) newToks

    
  return $ () -- (GHC.hs_tyclds group) ++ [decl]
  {-r@(group,id,lie,ds) <- getRefactRenamed
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
    Lexer.PFailed _ msg -> error $ "Lexer error: " ++  (showSDoc dflags msg)-}

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
-}
