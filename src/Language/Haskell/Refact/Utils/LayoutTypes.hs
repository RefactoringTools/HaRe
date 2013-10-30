-- |
--

module Language.Haskell.Refact.Utils.LayoutTypes (
    TokenLayout(..)
  , LayoutTree
  , Label(..)
  ) where

import GHC

import Data.Tree

import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TokenUtilsTypes

-- ---------------------------------------------------------------------

data TokenLayout = TL (Tree Label)

type LayoutTree = Tree Label

-- ---------------------------------------------------------------------


{-
data LayoutTree a = Group GHC.SrcSpan Layout [LayoutTree a]  -- Same as current
                                       -- TokenUtils internal tree node
                | Leaf  GHC.SrcSpan Layout [PosToken] -- Same as current
                                      -- TokenUtils leaf node
                deriving (Foldable,Traversable,Functor)
-}

data Label = Label GHC.SrcSpan Layout [PosToken]


