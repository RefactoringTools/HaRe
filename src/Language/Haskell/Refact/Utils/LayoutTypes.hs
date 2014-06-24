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

data TokenLayout a = TL (Tree (Entry a))

type LayoutTree a = Tree (Entry a)

-- ---------------------------------------------------------------------


data Label = Label GHC.SrcSpan Layout [PosToken]


