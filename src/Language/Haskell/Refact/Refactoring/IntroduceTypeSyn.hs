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
import Language.Haskell.GHC.ExactPrint.Types
import qualified Language.Haskell.GhcMod as GM
import qualified Language.Haskell.GhcMod.Internal as GM
import FastString
import Unique
import Lexer
import DynFlags
import StringBuffer
import Bag
import SrcLoc
import Outputable
import qualified Data.Map as Map
import qualified SrcLoc as Loc

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
          logm $ "Decl looks like: " ++ (showData Parser 3 decl)
          newParsed <- addDecl parsed Nothing ([decl], (Just ann))
          logm $ "Ann from parsing: " ++ (show ann)
          (liftT getAnnsT) >>= putRefactParsed newParsed
          let (GHC.L _ declName) = GHC.tcdLName inDecl
              (GHC.L _ declRHS) = GHC.tcdRhs inDecl
          updateTypeDecs declName declRHS


updateTypeDecs :: GHC.RdrName -> GHC.HsType GHC.RdrName ->  RefactGhc ()
updateTypeDecs synName ty = do
  parsed <- getRefactParsed
  newParsed <- everywhereButMStaged Parser (SYB.mkQ False skipSig) (SYB.mkM replaceSig) parsed  
  (liftT getAnnsT) >>= putRefactParsed newParsed
  return ()
  where
    skipSig :: (GHC.LHsDecl GHC.RdrName) -> Bool
    skipSig sig@(GHC.L _ (GHC.TyClD syn@(GHC.SynDecl (GHC.L _ name) _ _ _)))
      | name == synName = True
    skipSig x = False

    replaceSig :: (GHC.LHsType GHC.RdrName) -> RefactGhc (GHC.LHsType GHC.RdrName)
    replaceSig old@(GHC.L l oldTy)
      | compareHsType oldTy ty
      = do
          currAnns <- fetchAnnsFinal
          let oldKey = mkAnnKey old
              (Just oldAnn) = Map.lookup oldKey currAnns
              correctSig = (GHC.L l (GHC.HsTyVar synName))
              relevantAnns = lookupAllAnns currAnns l
              newKey = mkAnnKey correctSig
              newAnn = oldAnn{annsDP = [((G GHC.AnnVal),(DP (0,0)))]}
              finalAnns = Map.insert newKey newAnn (Map.difference currAnns relevantAnns)          
          setRefactAnns finalAnns
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
