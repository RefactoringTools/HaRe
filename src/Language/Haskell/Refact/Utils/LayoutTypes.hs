-- |
--

module Language.Haskell.Refact.Utils.LayoutTypes (
    TokenLayout(..)
  , LayoutTree
  , Label(..)
  , Layout(..)
  , RowOffset
  , ColOffset
  ) where

import GHC

import Data.Tree

import Language.Haskell.Refact.Utils.TypeSyn

-- ---------------------------------------------------------------------

data TokenLayout = TL (Tree Label)

type LayoutTree = Tree Label

-- ---------------------------------------------------------------------


type RowOffset = Int
type ColOffset = Int

{-
data LayoutTree a = Group GHC.SrcSpan Layout [LayoutTree a]  -- Same as current
                                       -- TokenUtils internal tree node
                | Leaf  GHC.SrcSpan Layout [PosToken] -- Same as current
                                      -- TokenUtils leaf node
                deriving (Foldable,Traversable,Functor)
-}

data Label = Label GHC.SrcSpan Layout [PosToken]

data Layout = Above
            | Offset RowOffset ColOffset
            | NoChange
            deriving (Show)


