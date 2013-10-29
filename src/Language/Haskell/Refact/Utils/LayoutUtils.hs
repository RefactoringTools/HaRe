{-# LANGUAGE TypeOperators #-}

module Language.Haskell.Refact.Utils.LayoutUtils
  (
    getLayoutFor
  , addDeclLayoutAfterSrcSpan
  , showLTOne
  ) where

import qualified GHC           as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.Layout
import Language.Haskell.Refact.Utils.LayoutTypes
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn

import Control.Lens.Getter
import Control.Lens.Zipper
import Data.Traversable

-- ---------------------------------------------------------------------

getLayoutFor :: GHC.SrcSpan -> TokenLayout -> LayoutTree Int
getLayoutFor sspan (TL layout) = getLayoutFor' sspan layout

getLayoutFor' :: GHC.SrcSpan -> LayoutTree a -> LayoutTree a
getLayoutFor' sspan tl@(Leaf ss _ _)
  | sspan == ss = tl
  | otherwise = error $ "getLayoutFor :" ++ (showGhc sspan) ++ " not in " ++ (showGhc tl)

getLayoutFor' sspan tl@(Group ss _ subs)
  | sspan == ss = tl
  | null subs        = error $ "getLayoutFor :" ++ (showGhc sspan) ++ " not in " ++ (showGhc tl)
  | length subs > 1  = error $ "getLayoutFor :" ++ (showGhc sspan) ++ " multiple in " ++ (showGhc tl)
  | otherwise = getLayoutFor' sspan sub
  where
    sub = getChildForSpan sspan subs

-- ---------------------------------------------------------------------

addDeclLayoutAfterSrcSpan :: (SYB.Data t) =>
     TokenLayout  -- ^TokenTree to be modified
  -> GHC.SrcSpan -- ^Preceding location for new tokens
  -> Positioning
  -> LayoutTree a -- ^New tokens to be added
  -> GHC.Located t  -- ^Declaration the tokens belong to, to be synced
  -> (TokenLayout, GHC.SrcSpan,GHC.Located t) -- ^ updated TokenTree ,SrcSpan location for
                               -- the new tokens in the TokenTree, and
                               -- updated AST element
addDeclLayoutAfterSrcSpan = undefined


-- ---------------------------------------------------------------------

{-
openZipperToSpan :: GHC.SrcSpan -> LayoutTree -> Top :>> LayoutTree
openZipperToSpan sspan lay = r
  where
    -- r = toZipper lay
    r = zipper lay
-}

openZipper :: GHC.SrcSpan -> Top :>> LayoutTree a -> Top :>> LayoutTree a
openZipper sspan z
  | getLoc (view focus z) == sspan = z
  | isLeaf (view focus z) = error $ "openZipperToSpan not found " ++ showGhc sspan ++ ":" ++ showLTOne (view focus z)
  | otherwise = openZipper sspan z'
  where
    (Group _ _ subs) = view focus z
    z' = zipper (getChildForSpan sspan subs)

-- ---------------------------------------------------------------------

getChildForSpan :: GHC.SrcSpan -> [LayoutTree a] -> LayoutTree a
getChildForSpan sspan subs = sub
  where
    sub = ghead "getChildForSpan" $ map snd $ filter (GHC.isSubspanOf sspan . fst) 
                                  $ map (\t -> (getLoc t,t)) subs

-- ---------------------------------------------------------------------

showLTOne :: LayoutTree a -> String
showLTOne (Leaf ss lay _toks) = "(Leaf "  ++ (showGhc ss) ++ " " ++ (show lay) ++ " " ++ "toks)"
showLTOne (Group ss lay subs) = "(Group " ++ (showGhc ss) ++ " " ++ (show lay) ++ " " ++ showGhc (map getLoc subs) ++ ")"

-- ---------------------------------------------------------------------

isLeaf :: LayoutTree a -> Bool
isLeaf (Leaf _ _ _) = True
isLeaf _            = False

-- ---------------------------------------------------------------------

-- experiments


