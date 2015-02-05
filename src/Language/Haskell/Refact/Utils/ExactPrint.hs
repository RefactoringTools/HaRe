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
  , deleteAnnotation
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
                      => GHC.Located t -> RefactGhc ((GHC.Located t),Anns)
resequenceAnnotations t = do
  t1 <- insertUniqueSrcSpans t
  let aa = extractAnnsEP t1
      bb = uniqueSpansOnly aa
  logm $ "resequenceAnnotations:annsEP=" ++ (show aa)
  -- logm $ "resequenceAnnotations:locatedConstr=" ++ (SYB.showConstr locatedConstructor)
  return (t1,bb)

-- ---------------------------------------------------------------------

-- | Replace empty source spans with a unique SrcSpan which is used as
-- a key. It doesn't matter what it is.
insertUniqueSrcSpans :: (SYB.Data t) => GHC.Located t -> RefactGhc (GHC.Located t)
insertUniqueSrcSpans t = do
  SYB.everywhereM (SYB.mkM newSrcSpan) t
  where
    newSrcSpan :: GHC.SrcSpan -> RefactGhc GHC.SrcSpan
    newSrcSpan ss = if ss == GHC.noSrcSpan
                      then uniqueSrcSpan
                      else return ss

-- ---------------------------------------------------------------------
-- | Filter annotations to get ones corresponding to SrcSpans.
uniqueSpansOnly :: Anns -> Anns
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
extractAnnsEP :: forall t. (SYB.Data t) => t -> Anns
extractAnnsEP t = Map.fromList as
  where
    sts = extractSrcSpanConName t
    as :: [((GHC.SrcSpan, AnnConName), (Annotation, [(KeywordId, DeltaPos)]))]
    as = map (\k -> (k,(Ann [] (DP (0,0)) 0 , []))) sts

extractSrcSpanConName :: forall t. (SYB.Data t) => t -> [(GHC.SrcSpan,AnnConName)]
extractSrcSpanConName  =
  generic
  where generic :: (SYB.Data a) => a -> [(GHC.SrcSpan,AnnConName)]
        generic t = if SYB.showConstr (SYB.toConstr t) == "L" -- SYB.toConstr t == locatedConstructor
                       then [ (ghead "extractAnns" (SYB.gmapQi 0 getSrcSpan t), (SYB.gmapQi 1 getConName t)) ]
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

addAnnKeywords :: Anns -> AnnConName -> [(KeywordId, DeltaPos)] -> Anns
addAnnKeywords anns conName ks = Map.insert (ss, conName) (annNone, ks) anns
  where
    -- First find the first srcspan having the conName
    ((ss,_),_) = ghead "addAnnKeywords" $ filter (\((_ss,s),_) -> s == conName) $ Map.toList anns

-- ---------------------------------------------------------------------

-- |Update the DeltaPos for the given comments
setOffsets :: Anns -> [((GHC.SrcSpan,AnnConName),DeltaPos)] -> Anns
setOffsets anne kvs = foldl' setOffset anne kvs

-- |Update the DeltaPos for the given comment set
setOffset :: Anns -> ((GHC.SrcSpan,AnnConName),DeltaPos) -> Anns
setOffset anne (k,v) = case
  Map.lookup k anne of
    Nothing         -> Map.insert k (Ann [] v 0, []) anne
    Just (Ann cs _ c, ks) -> Map.insert k (Ann cs v c, ks) anne

-- ---------------------------------------------------------------------

-- | Delete an annotation
deleteAnnotation :: (GHC.SrcSpan, AnnConName) -> KeywordId -> Anns -> Anns
deleteAnnotation k kw = Map.adjust (\(a,xs) -> (a, filter (\x -> fst x /= kw) xs)) k

--deleteAnnotations :: [(GHC.SrcSpan, KeywordId)] -> Anns -> Anns
--deleteAnnotations vs anne = foldr deleteAnnotation anne vs

-- -------------------------

setLocatedDp :: (SYB.Data a) => Anns -> GHC.Located a -> DeltaPos -> Anns
setLocatedDp aane (GHC.L l v) dp = setOffset aane ((l,annGetConstr v),dp)

-- ---------------------------------------------------------------------
{-
-- |The constructor for 'GHC.L'
locatedConstructor :: SYB.Constr
locatedConstructor = head (SYB.dataTypeConstrs (SYB.dataTypeOf (GHC.noLoc ())))
-}

-- ---------------------------------------------------------------------
