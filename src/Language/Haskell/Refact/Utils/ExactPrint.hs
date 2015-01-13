{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Language.Haskell.Refact.Utils.ExactPrint
  (
    resequenceAnnotations
  , uniqueSrcSpan
  ) where

import qualified Digraph       as GHC
import qualified FastString    as GHC
import qualified GHC
import qualified Outputable    as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import GHC.Generics

import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.GHC.ExactPrint.Utils
import Language.Haskell.Refact.Utils.TypeUtils
import Language.Haskell.Refact.Utils.Types

import Control.Applicative
import Control.Exception
import Control.Monad.Identity
import Control.Monad.State
import Data.List

import qualified Data.Map as Map

-- ---------------------------------------------------------------------

resequenceAnnotations :: (SYB.Data t) => GHC.Located t -> RefactGhc (GHC.Located t)
resequenceAnnotations t = do
  t1 <- insertUniqueSrcSpans t
  let aa = extractAnnsEP t1
  logm $ "resequenceAnnotations:annsEP=" ++ (show aa)
  logm $ "resequenceAnnotations:locatedConstr=" ++ (SYB.showConstr locatedConstructor)
  return t1

-- ---------------------------------------------------------------------

insertUniqueSrcSpans :: (SYB.Data t) => GHC.Located t -> RefactGhc (GHC.Located t)
insertUniqueSrcSpans t = do
  SYB.everywhereM (SYB.mkM newSrcSpan) t
  where
    newSrcSpan :: GHC.SrcSpan -> RefactGhc GHC.SrcSpan
    newSrcSpan _ = uniqueSrcSpan

-- ---------------------------------------------------------------------

extractAnnsEP :: forall t. (SYB.Data t) => t -> AnnsEP
extractAnnsEP t = Map.fromList as
  where
    sts = extractSrcSpanTypeRep t
    as = map (\k -> (k,Ann [] (DP (0,0)))) sts

extractSrcSpanTypeRep :: forall t. (SYB.Data t) => t -> [(GHC.SrcSpan,SYB.TypeRep)]
extractSrcSpanTypeRep  =
  generic
  where generic :: SYB.Data a => a -> [(GHC.SrcSpan,SYB.TypeRep)]
        generic t = if SYB.showConstr (SYB.toConstr t) == "L" -- SYB.toConstr t == locatedConstructor
                       then [ (ghead "extractAnnsEP" (SYB.gmapQi 0 getSrcSpan t), (SYB.gmapQi 1 getTypeRep t)) ]
                            ++ SYB.gmapQi 1 extractSrcSpanTypeRep t
                       else concat (SYB.gmapQ extractSrcSpanTypeRep t)

        getSrcSpan :: forall d. SYB.Data d => d -> [GHC.SrcSpan]
        getSrcSpan = SYB.mkQ [] getSrcSpan'
          where
            getSrcSpan' :: GHC.SrcSpan -> [GHC.SrcSpan]
            getSrcSpan' ss = [ss]

        getTypeRep :: forall d. SYB.Data d => d -> SYB.TypeRep
        getTypeRep = SYB.typeOf

{-
  -- | A generic query that processes the immediate subterms and returns a list
  -- of results.  The list is given in the same order as originally specified
  -- in the declaratoin of the data constructors.
  gmapQ :: (forall d. Data d => d -> u) -> a -> [u]
  gmapQ f = gmapQr (:) [] f


  -- | A generic query that processes one child by index (zero-based)
  gmapQi :: forall u. Int -> (forall d. Data d => d -> u) -> a -> u
  gmapQi i f x = case gfoldl k z x of { Qi _ q -> fromJust q }
    where
      k :: Data d => Qi u (d -> b) -> d -> Qi u b
      k (Qi i' q) a = Qi (i'+1) (if i==i' then Just (f a) else q)
      z :: g -> Qi q g
      z _           = Qi 0 Nothing

-}

{-
  generic
  where generic :: SYB.Data a => a -> String
        generic t = "(" ++ SYB.showConstr (SYB.toConstr t)
                 ++ space (concat (intersperse " " (SYB.gmapQ extractAnnsEP t))) ++ ")"

        space "" = ""
        space s  = ' ':s
-}

{-
extractAnnsEP t = Map.fromList ll
  where
    ls = SYB.everything (++) ([] `SYB.mkQ` getInfo) t
    ll = map (\(l,_,tr) -> ((l,tr),nullAnn)) ls
    nullAnn = Ann [] (DP (0,0))

    getInfo :: forall a. (SYB.Typeable a) => GHC.Located a -> [(GHC.SrcSpan,a,SYB.TypeRep)]
    getInfo (GHC.L l a) = [(l,a,SYB.typeOf a)]
-}

-- ---------------------------------------------------------------------

-- |The constructor for 'GHC.L'
locatedConstructor :: SYB.Constr
locatedConstructor = head (SYB.dataTypeConstrs (SYB.dataTypeOf (GHC.noLoc ())))

-- ---------------------------------------------------------------------

-- TODO: do we have to match the filename for GHC compare functions?
uniqueSrcSpan :: RefactGhc GHC.SrcSpan
uniqueSrcSpan = do
  s <- get
  col <- gets rsSrcSpanCol
  put s { rsSrcSpanCol = (col+1) }

  let pos = GHC.mkSrcLoc (GHC.mkFastString "HaRe") (-1) col
  return $ GHC.mkSrcSpan pos pos


-- ---------------------------------------------------------------------
