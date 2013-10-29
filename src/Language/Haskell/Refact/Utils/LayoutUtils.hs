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
import Data.Tree

-- ---------------------------------------------------------------------

getLayoutFor :: GHC.SrcSpan -> TokenLayout -> LayoutTree
getLayoutFor sspan (TL layout) = getLayoutFor' sspan layout

getLayoutFor' :: GHC.SrcSpan -> LayoutTree -> LayoutTree
-- getLayoutFor' sspan tl@(Leaf ss _ _)
getLayoutFor' sspan tl@(Node (Label ss _ _) [])
  | sspan == ss = tl
  | otherwise = error $ "getLayoutFor :" ++ (showGhc sspan) ++ " not in " ++ (showGhc tl)

-- getLayoutFor' sspan tl@(Group ss _ subs)
getLayoutFor' sspan tl@(Node (Label ss _ []) subs)
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
  -> LayoutTree -- ^New tokens to be added
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
{-
openZipper :: GHC.SrcSpan -> Top :>> LayoutTree -> Top :>> LayoutTree
openZipper sspan z
  | getLoc (view focus z) == sspan = z
  | isLeaf (view focus z) = error $ "openZipperToSpan not found " ++ showGhc sspan ++ ":" ++ showLTOne (view focus z)
  | otherwise = openZipper sspan z'
  where
    (Group _ _ subs) = view focus z
    z' = zipper (getChildForSpan sspan subs)
-}
-- ---------------------------------------------------------------------

getChildForSpan :: GHC.SrcSpan -> [LayoutTree] -> LayoutTree
getChildForSpan sspan subs = sub
  where
    sub = ghead "getChildForSpan" $ map snd $ filter (GHC.isSubspanOf sspan . fst) 
                                  $ map (\t -> (getLoc t,t)) subs

-- ---------------------------------------------------------------------

showLTOne :: LayoutTree -> String
-- showLTOne (Leaf ss lay _toks) = "(Leaf "  ++ (showGhc ss) ++ " " ++ (show lay) ++ " " ++ "toks)"
-- showLTOne (Group ss lay subs) = "(Group " ++ (showGhc ss) ++ " " ++ (show lay) ++ " " ++ showGhc (map getLoc subs) ++ ")"
showLTOne (Node (Label ss lay _toks) []) = "(Leaf "  ++ (showGhc ss) ++ " " ++ (show lay) ++ " " ++ "toks)"
showLTOne (Node (Label ss lay []) subs) = "(Group " ++ (showGhc ss) ++ " " ++ (show lay) ++ " " ++ showGhc (map getLoc subs) ++ ")"


-- ---------------------------------------------------------------------

isLeaf :: LayoutTree -> Bool
isLeaf (Node _ []) = True
isLeaf _            = False

-- ---------------------------------------------------------------------

-- experiments


