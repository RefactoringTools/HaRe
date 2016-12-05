{-# LANGUAGE CPP #-}
module Language.Haskell.Refact.Utils.Transform
  (
    addSimpleImportDecl
  , wrapInLambda
  , wrapInPars
  , wrapInParsWithDPs
  , addNewLines
  , locate
  ) where

import qualified GHC as GHC
import qualified BasicTypes as GHC
import qualified Data.Map as Map
import Data.Data

import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Types

import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TypeUtils
import Language.Haskell.Refact.Utils.Synonyms
import Language.Haskell.Refact.Utils.ExactPrint

-- The goal of this module is to provide basic transformations of the ast and
-- annotations that are useful in multiple refactorings


--Takes in a string corresponding to the module name to be imported
--Adds the import declaration at the end of that module's imports 
addSimpleImportDecl :: String -> RefactGhc ()
addSimpleImportDecl modName = do
  let modNm' = GHC.mkModuleName modName
  parsed <- getRefactParsed
  newP <- addImportDecl parsed modNm' Nothing False False False Nothing False []
  currAnns <- fetchAnnsFinal
  putRefactParsed newP currAnns

--Takes in a lhs pattern and a rhs. Wraps those in a lambda and adds the annotations associated with the lambda. Returns the new located lambda expression

wrapInLambda :: String -> GHC.LPat GHC.RdrName -> ParsedGRHSs -> RefactGhc (GHC.LHsExpr GHC.RdrName)
wrapInLambda funNm varPat rhs = do
  match@(GHC.L l match') <- mkMatch varPat rhs
  --logm $ "Match: " ++ (SYB.showData SYB.Parser 3 match)
#if __GLASGOW_HASKELL__ <= 710
  let mg = GHC.MG [match] [] GHC.PlaceHolder GHC.Generated
#else
  lMatchLst <- locate [match]
  let mg = GHC.MG lMatchLst [] GHC.PlaceHolder GHC.Generated
#endif
  currAnns <- fetchAnnsFinal
  --logm $ "Anns :" ++ (show $ getAllAnns currAnns match)
  let l_lam = (GHC.L l (GHC.HsLam mg))
      key = mkAnnKey l_lam
      dp = [(G GHC.AnnLam, DP (0,0))]
      newAnn = annNone {annsDP = dp}
  setRefactAnns $ Map.insert key newAnn currAnns
  par_lam <- wrapInPars l_lam
  return par_lam

  --This function makes a match suitable for use inside of a lambda expression. Should change name or define it elsewhere to show that this is not a general-use function. 
mkMatch :: GHC.LPat GHC.RdrName -> GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc (GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))
mkMatch varPat rhs = do
#if __GLASGOW_HASKELL__ <= 710
  lMatch@(GHC.L l m) <- locate (GHC.Match Nothing [varPat] Nothing rhs)
#else
  lMatch@(GHC.L l m) <- locate (GHC.Match GHC.NonFunBindMatch [varPat] Nothing rhs)
#endif
  let dp = [(G GHC.AnnRarrow, DP (0,1))]
      newAnn = annNone {annsDP = dp, annEntryDelta = DP (0,-1)}
  zeroDP varPat
  addAnn lMatch newAnn
  return lMatch

wrapInParsWithDPs :: DeltaPos -> DeltaPos -> GHC.LHsExpr GHC.RdrName -> RefactGhc (GHC.LHsExpr GHC.RdrName)
wrapInParsWithDPs openDP closeDP expr = do
  newAst <- locate (GHC.HsPar expr)
  let dp = [(G GHC.AnnOpenP, openDP), (G GHC.AnnCloseP, closeDP)]
      newAnn = annNone {annsDP = dp}
  addAnn newAst newAnn
  return newAst


--Wraps a given expression in parenthesis and add the appropriate annotations, returns the modified ast chunk. 
wrapInPars :: GHC.LHsExpr GHC.RdrName -> RefactGhc (GHC.LHsExpr GHC.RdrName)
wrapInPars = wrapInParsWithDPs (DP (0,1)) (DP (0,0))
  
--Takes a piece of AST and adds an n row offset
addNewLines :: (Data a) => Int -> GHC.Located a -> RefactGhc ()
addNewLines n ast = do
  currAnns <- fetchAnnsFinal
  let key = mkAnnKey ast
      mv = Map.lookup key currAnns
  case mv of
    Nothing -> return ()
    Just v -> do
      let (DP (row,col)) = annEntryDelta v
          newDP = (DP (row+n,col))
          newAnn = v {annEntryDelta = newDP}
          newAnns = Map.insert key newAnn currAnns
      setRefactAnns newAnns
