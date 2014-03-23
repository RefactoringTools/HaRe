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

data TokenLayout = TL (Tree Entry)

type LayoutTree = Tree Entry

-- ---------------------------------------------------------------------


data Label = Label GHC.SrcSpan Layout [PosToken]


