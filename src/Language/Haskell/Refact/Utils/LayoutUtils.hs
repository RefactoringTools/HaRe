{-# LANGUAGE TypeOperators #-}

module Language.Haskell.Refact.Utils.LayoutUtils
  (
    getLayoutFor
  -- , addDeclLayoutAfterSrcSpan
  , showLTOne
  -- , openZipper
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

import Data.Tree

import qualified Data.Tree.Zipper as Z

import qualified Language.Haskell.Refact.Utils.TokenUtils      as U
import qualified Language.Haskell.Refact.Utils.TokenUtilsTypes as U

-- ---------------------------------------------------------------------

getLayoutFor :: GHC.SrcSpan -> TokenLayout -> LayoutTree
getLayoutFor sspan (TL layout) = getLayoutFor' sspan layout

getLayoutFor' :: GHC.SrcSpan -> LayoutTree -> LayoutTree
-- getLayoutFor' sspan tl@(Leaf ss _ _)
getLayoutFor' sspan tl@(Node (U.Entry ss _ _) [])
  | sspan == (fs ss) = tl
  | otherwise = error $ "getLayoutFor :" ++ (showGhc sspan) ++ " not in " ++ (showGhc tl)

-- getLayoutFor' sspan tl@(Group ss _ subs)
getLayoutFor' sspan tl@(Node (U.Entry ss _ []) subs)
  | sspan == (fs ss) = tl
  | null subs        = error $ "getLayoutFor :" ++ (showGhc sspan) ++ " not in " ++ (showGhc tl)
  | length subs > 1  = error $ "getLayoutFor :" ++ (showGhc sspan) ++ " multiple in " ++ (showGhc tl)
  | otherwise = getLayoutFor' sspan sub
  where
    sub = getChildForSpan sspan subs

-- ---------------------------------------------------------------------

{-
addDeclLayoutAfterSrcSpan :: (SYB.Data t) =>
     LayoutTree  -- ^TokenTree to be modified
  -> GHC.SrcSpan -- ^Preceding location for new tokens
  -> U.Positioning
  -> LayoutTree -- ^New tokens to be added
  -> GHC.Located t  -- ^Declaration the tokens belong to, to be synced
  -> (TokenLayout, GHC.SrcSpan,GHC.Located t) -- ^ updated TokenTree ,SrcSpan location for
                               -- the new tokens in the TokenTree, and
                               -- updated AST element
addDeclLayoutAfterSrcSpan tl oldSpan pos layout t = (tl'',newSpan,t')
  where
    (tl',newSpan) = addLayoutAfterSrcSpan tl oldSpan pos layout
    (t',tl'') = syncAST t newSpan tl'
-}

-- ---------------------------------------------------------------------
{-
-- |Add new tokens after the given SrcSpan, constructing a new SrcSpan
-- in the process
addLayoutAfterSrcSpan ::
  LayoutTree  -- ^TokenTree to be modified
  -> GHC.SrcSpan -- ^Preceding location for new tokens
  -> U.Positioning
  -> LayoutTree -- ^New tokens to be added
  -> (LayoutTree, GHC.SrcSpan) -- ^ updated TokenTree and SrcSpan location for
                               -- the new tokens in the TokenTree
addLayoutAfterSrcSpan lt oldSpan pos layout = (lt',newSpan')
  where
    tree = getSrcSpanFor lt oldSpan

    toks'' = placeLayoutForSpan lt oldSpan tree pos layout

    (startPos,endPos) = U.nonCommentSpan toks''

    newSpan = U.posToSrcSpanTok mkZeroToken (startPos,endPos)

    (lt',newSpan') = addNewSrcSpanAndToksAfter lt oldSpan newSpan pos layout
-}
-- ---------------------------------------------------------------------

getSrcSpanFor = undefined
placeLayoutForSpan = undefined
addNewSrcSpanAndToksAfter = undefined

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
{-
openZipper :: GHC.SrcSpan
     -> Z.TreePos Z.Full Label
     -> Z.TreePos Z.Full Label
openZipper sspan z
  | getLoc (Z.tree z) == sspan = z
  | otherwise = openZipper sspan child
  where
    child = ghead "openZipper" $ filter (GHC.isSubspanOf sspan . getLoc . Z.tree) childrenAsZ
    childrenAsZ = getChildrenAsZ z
-}
-- ---------------------------------------------------------------------
{-
getChildrenAsZ :: Z.TreePos Z.Full a -> [Z.TreePos Z.Full a]
getChildrenAsZ z = go [] (Z.firstChild z)
  where
    go acc Nothing = acc
    go acc (Just zz) = go (acc ++ [zz]) (Z.next zz)
-}

-- ---------------------------------------------------------------------

-- TODO: need to make ForestLine version of isSubspanof
getChildForSpan :: GHC.SrcSpan -> [LayoutTree] -> LayoutTree
getChildForSpan sspan subs = sub
  where
    sub = ghead "getChildForSpan" $ map snd $ filter (GHC.isSubspanOf sspan . fst) 
                                  $ map (\t -> (fs $ getLoc t,t)) subs

-- ---------------------------------------------------------------------

showLTOne :: LayoutTree -> String
-- showLTOne (Leaf ss lay _toks) = "(Leaf "  ++ (showGhc ss) ++ " " ++ (show lay) ++ " " ++ "toks)"
-- showLTOne (Group ss lay subs) = "(Group " ++ (showGhc ss) ++ " " ++ (show lay) ++ " " ++ showGhc (map getLoc subs) ++ ")"
showLTOne (Node (U.Entry ss lay _toks) []) = "(Leaf "  ++ (showGhc ss) ++ " " ++ (show lay) ++ " " ++ "toks)"
showLTOne (Node (U.Entry ss lay []) subs) = "(Group " ++ (showGhc ss) ++ " " ++ (show lay) ++ " " ++ showGhc (map getLoc subs) ++ ")"


-- ---------------------------------------------------------------------

isLeaf :: LayoutTree -> Bool
isLeaf (Node _ []) = True
isLeaf _            = False

-- ---------------------------------------------------------------------

-- experiments


