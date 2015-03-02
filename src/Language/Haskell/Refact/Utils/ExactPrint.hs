{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE RankNTypes #-}
module Language.Haskell.Refact.Utils.ExactPrint
  (
    resequenceAnnotations
  , uniqueSrcSpan
  , addAnnKeywords
  , setOffsets
  , setOffset
  , setLocatedOffsets
  , deleteAnnotation
  , setLocatedDp
  , extractAnnsEP
  , mergeAnns
  , deleteAnnotations
  , replace
  , mkKey
  , setColRec
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
import Data.Monoid
import Debug.Trace

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
  = Map.filterWithKey (\(AnnKey ss _) _ -> isUniqueSrcSpan ss) anns

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
    as :: [(AnnKey, Annotation)]
    as = map (\k -> (k, annNone)) sts

{-
++AZ++ Temporarily commenting this output
locFold :: forall r b . (SYB.Data b) => (r -> r -> r) -> (forall a . (SYB.Data a) => GHC.Located a -> r) ->  r -> b -> r
locFold f g v nil = generic v
  where generic :: b -> r
        generic t =
          if SYB.showConstr (SYB.toConstr t) == "L" -- SYB.toConstr t == locatedConstructor
            then
              g (GHC.L
                (ghead "extractAnns" (SYB.gmapQi 0 getSrcSpan t))
                (SYB.gmapQi 1 id t))
                `f` SYB.gmapQi 1 generic t
             else foldr f nil (SYB.gmapQ generic t)
        getSrcSpan :: forall d. SYB.Data d => d -> [GHC.SrcSpan]
        getSrcSpan = SYB.mkQ [] getSrcSpan'
          where
            getSrcSpan' :: GHC.SrcSpan -> [GHC.SrcSpan]
            getSrcSpan' ss = [ss]
-}

extractSrcSpanConName :: forall t. (SYB.Data t) => t -> [AnnKey]
extractSrcSpanConName  =
  generic
  where generic :: (SYB.Data a) => a -> [AnnKey]
        generic t =
          if SYB.showConstr (SYB.toConstr t) == "L" -- SYB.toConstr t == locatedConstructor
            then [ AnnKey
                    (ghead "extractAnns" (SYB.gmapQi 0 getSrcSpan t))
                    (SYB.gmapQi 1 getConName t)
                 ]
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
addAnnKeywords anns conName ks = Map.insert (AnnKey ss conName) (annNone {anns = ks}) anns
  where
    -- First find the first srcspan having the conName
    -- MP: First in what sense?
    AnnKey ss _ = ghead "addAnnKeywords" $ filter (\(AnnKey _ s) -> s == conName) $ Map.keys anns

-- ---------------------------------------------------------------------

-- |Update the DeltaPos for the given annotation keys
setOffsets :: Anns -> [(AnnKey,(DeltaPos, LineChanged, Col, ColOffset))] -> Anns
setOffsets anne kvs = foldl' setOffset anne kvs

-- |Update the DeltaPos for the given annotation key/val
setOffset :: Anns -> (AnnKey, (DeltaPos, LineChanged, Col, ColOffset)) -> Anns
setOffset anne (k,(dp, nl, sc, col)) = case
  Map.lookup k anne of
    Nothing               -> Map.insert k (Ann dp nl sc col []) anne
    Just (Ann _ _ _ _ ks) -> Map.insert k (Ann dp nl sc col ks) anne

-- |Update the DeltaPos for the given annotation keys
setLocatedOffsets :: (SYB.Data a) => Anns -> [(GHC.Located a,(DeltaPos, LineChanged, Col, ColOffset))] -> Anns
setLocatedOffsets anne kvs = foldl' setLocatedDp anne kvs

setLocatedDp :: (SYB.Data a) => Anns -> (GHC.Located a, (DeltaPos, LineChanged, Col, ColOffset)) ->  Anns
setLocatedDp aane (loc, (dp, nl, sc, col)) = setOffset aane ((mkKey loc),(dp, nl, sc, col))

-- ---------------------------------------------------------------------

-- | Replaces an old expression with a new expression
replace :: AnnKey -> AnnKey -> Anns -> Maybe Anns
replace old new as = do
  oldan <- Map.lookup old as
  newan <- Map.lookup new as
  let newan' = Ann
                { ann_entry_delta  = ann_entry_delta oldan
                , ann_original_nl  = ann_original_nl oldan
                , ann_original_col = ann_original_col oldan
                , ann_delta        = ann_delta oldan
                , anns             = moveAnns (anns oldan) (anns newan)
                }
  return . Map.delete old . Map.insert new newan' $ as

mkKey :: (SYB.Data a) => GHC.Located a -> AnnKey
mkKey (GHC.L l s) = AnnKey l (annGetConstr s)


-- | Shift the first output annotation into the correct place
moveAnns :: [(KeywordId, DeltaPos)] -> [(KeywordId, DeltaPos)] -> [(KeywordId, DeltaPos)]
moveAnns [] xs        = xs
moveAnns ((_, dp): _) ((kw, _):xs) = (kw,dp) : xs


-- | Delete an annotation
deleteAnnotation :: AnnKey -> KeywordId -> Anns -> Anns
deleteAnnotation k kw =
  Map.adjust (\(s@Ann{anns}) -> s { anns = filter (\x -> fst x /= kw) anns}) k

mergeAnns :: Anns -> Anns -> Anns
mergeAnns = Map.unionWith (<>)

deleteAnnotations :: [(AnnKey, KeywordId)] -> Anns -> Anns
deleteAnnotations vs anne = foldr (uncurry deleteAnnotation) anne vs

-- -------------------------

-- | Recursively change the col offsets
setColRec :: (SYB.Data a) => (Int -> Int) -> a -> (Anns -> Anns)
setColRec f loc = transform loc
  where
    transform :: SYB.Data a => a -> (Anns -> Anns)
    transform t =
          if SYB.showConstr (SYB.toConstr t) == "L" -- SYB.toConstr t == locatedConstructor
            then setCol f (ghead "hereh" $ SYB.gmapQi 0 getSrcSpan t)
                          (SYB.gmapQi 1 getConName t)
                  . SYB.gmapQi 1 transform t
            else foldr (.) id (SYB.gmapQ transform t)
    getSrcSpan :: forall d. SYB.Data d => d -> [GHC.SrcSpan]
    getSrcSpan = SYB.mkQ [] getSrcSpan'
      where
        getSrcSpan' :: GHC.SrcSpan -> [GHC.SrcSpan]
        getSrcSpan' ss = [ss]

    getConName :: forall d. SYB.Data d => d -> AnnConName
    getConName = annGetConstr

setCol :: (Int -> Int) -> GHC.SrcSpan -> AnnConName -> (Anns -> Anns)
setCol f ss cn anns =
  let key = AnnKey ss cn
      res = Map.adjust (\s -> s { ann_delta = f (ann_delta s) }) key anns in
      res



-- ---------------------------------------------------------------------
{-
-- |The constructor for 'GHC.L'
locatedConstructor :: SYB.Constr
locatedConstructor = head (SYB.dataTypeConstrs (SYB.dataTypeOf (GHC.noLoc ())))
-}

-- ---------------------------------------------------------------------
