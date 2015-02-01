{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Language.Haskell.Refact.Utils.ExactPrint
  (
    resequenceAnnotations
  , uniqueSrcSpan
  , addAnnKeywords
  , setOffsets
  , setOffset
  , deleteAnnotations
  , setLocatedDp
  , extractAnnsEP
  ) where

import qualified FastString    as GHC
import qualified GHC
--import qualified Outputable    as GHC

import qualified Data.Generics as SYB
--import qualified GHC.SYB.Utils as SYB

import Language.Haskell.Refact.Utils.Monad
--import Language.Haskell.Refact.Utils.MonadFunctions
--import Language.Haskell.Refact.Utils.TypeSyn
--import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.GHC.ExactPrint.Utils

import Control.Monad.State
import Data.List

import qualified Data.Map as Map

-- ---------------------------------------------------------------------

resequenceAnnotations :: (SYB.Data t)
                      => GHC.Located t -> RefactGhc ((GHC.Located t),AnnsEP)
resequenceAnnotations t = do
  t1 <- insertUniqueSrcSpans t
  let aa = extractAnnsEP t1
      bb = uniqueSpansOnly aa
  logm $ "resequenceAnnotations:annsEP=" ++ (show aa)
  -- logm $ "resequenceAnnotations:locatedConstr=" ++ (SYB.showConstr locatedConstructor)
  return (t1,bb)

-- ---------------------------------------------------------------------

insertUniqueSrcSpans :: (SYB.Data t) => GHC.Located t -> RefactGhc (GHC.Located t)
insertUniqueSrcSpans t = do
  SYB.everywhereM (SYB.mkM newSrcSpan) t
  where
    newSrcSpan :: GHC.SrcSpan -> RefactGhc GHC.SrcSpan
    newSrcSpan ss = if ss == GHC.noSrcSpan
                      then uniqueSrcSpan
                      else return ss

-- ---------------------------------------------------------------------

uniqueSpansOnly :: AnnsEP -> AnnsEP
uniqueSpansOnly anns
  = Map.fromList $ filter (\((ss,_),_) -> isUniqueSrcSpan ss) $ Map.toList anns

-- ---------------------------------------------------------------------

-- TODO: do we have to match the filename for GHC compare functions?
uniqueSrcSpan :: RefactGhc GHC.SrcSpan
uniqueSrcSpan = do
  s <- get
  col <- gets rsSrcSpanCol
  put s { rsSrcSpanCol = (col+1) }

  let pos = GHC.mkSrcLoc (GHC.mkFastString "HaRe") (-1) col
  return $ GHC.mkSrcSpan pos pos

isUniqueSrcSpan :: GHC.SrcSpan -> Bool
isUniqueSrcSpan ss = srcSpanStartLine ss == -1

-- ---------------------------------------------------------------------

-- |Get the map of (SrcSpan,AnnConName) with empty annotations
extractAnnsEP :: forall t. (SYB.Data t) => t -> AnnsEP
extractAnnsEP t = Map.fromList as
  where
    sts = extractSrcSpanConName t
    as = map (\k -> (k,Ann [] (DP (0,0)))) sts


extractSrcSpanConName :: forall t. (SYB.Data t) => t -> [(GHC.SrcSpan,AnnConName)]
extractSrcSpanConName  =
  generic
  where generic :: (SYB.Data a) => a -> [(GHC.SrcSpan,AnnConName)]
        generic t = if SYB.showConstr (SYB.toConstr t) == "L" -- SYB.toConstr t == locatedConstructor
                       then [ (ghead "extractAnnsEP" (SYB.gmapQi 0 getSrcSpan t), (SYB.gmapQi 1 getConName t)) ]
                            ++ SYB.gmapQi 1 extractSrcSpanConName t
                       else concat (SYB.gmapQ extractSrcSpanConName t)

        getSrcSpan :: forall d. SYB.Data d => d -> [GHC.SrcSpan]
        getSrcSpan = SYB.mkQ [] getSrcSpan'
          where
            getSrcSpan' :: GHC.SrcSpan -> [GHC.SrcSpan]
            getSrcSpan' ss = [ss]

        getConName :: forall d. SYB.Data d => d -> AnnConName
        getConName = annGetConstr


-- ---------------------------------------------------------------------

addAnnKeywords :: AnnsEP -> String -> [(KeywordId,[DeltaPos])] -> AnnsFinal
addAnnKeywords anns conName ks = r
  where
    -- First find the first srcspan having the conName
    ((ss,_),_) = ghead "addAnnKeywords" $ filter (\((_ss,s),_) -> unConName s == conName) $ Map.toList anns
    -- Then add the annotations
    r = Map.fromList $ map (\(kw,dps) -> ((ss,kw),dps)) ks

-- ---------------------------------------------------------------------

-- |Update the DeltaPos for the given
setOffsets :: AnnsEP -> [((GHC.SrcSpan,AnnConName),DeltaPos)] -> AnnsEP
setOffsets anne kvs = foldl' setOffset anne kvs

-- |Update the DeltaPos for the given
setOffset :: AnnsEP -> ((GHC.SrcSpan,AnnConName),DeltaPos) -> AnnsEP
setOffset anne (k,v) = case
  Map.lookup k anne of
    Nothing         -> Map.insert k (Ann [] v) anne
    Just (Ann cs _) -> Map.insert k (Ann cs v) anne

-- ---------------------------------------------------------------------

-- | Delete an annotation
deleteAnnotation :: (GHC.SrcSpan, KeywordId) -> AnnsFinal -> AnnsFinal
deleteAnnotation = Map.delete

deleteAnnotations :: [(GHC.SrcSpan, KeywordId)] -> AnnsFinal -> AnnsFinal
deleteAnnotations vs anne = foldr deleteAnnotation anne vs

-- -------------------------

setLocatedDp :: (SYB.Data a) => AnnsEP -> GHC.Located a -> DeltaPos -> AnnsEP
setLocatedDp aane (GHC.L l v) dp = setOffset aane ((l,annGetConstr v),dp)

-- ---------------------------------------------------------------------
{-
-- |The constructor for 'GHC.L'
locatedConstructor :: SYB.Constr
locatedConstructor = head (SYB.dataTypeConstrs (SYB.dataTypeOf (GHC.noLoc ())))
-}

-- ---------------------------------------------------------------------
