{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeFamilies       #-}
{-# LANGUAGE EmptyDataDecls     #-}
{-# LANGUAGE DeriveFoldable     #-}
{-# LANGUAGE DeriveFunctor      #-}
{-# LANGUAGE DeriveTraversable  #-}
-- |
--

module Language.Haskell.Refact.Utils.LayoutTypes (
    TokenLayout(..)
  , LayoutTree(..)
  , Layout(..)
  , RowOffset
  , ColOffset
  ) where

import GHC

import Data.Foldable
import Data.Traversable

import Language.Haskell.Refact.Utils.TypeSyn

-- ---------------------------------------------------------------------

data TokenLayout = TL (LayoutTree Int)

-- ---------------------------------------------------------------------
{-

The layout will have to have a tree structure

-}


type RowOffset = Int
type ColOffset = Int

data LayoutTree a = Group GHC.SrcSpan Layout [LayoutTree a]  -- Same as current
                                       -- TokenUtils internal tree node
                | Leaf  GHC.SrcSpan Layout [PosToken] -- Same as current
                                      -- TokenUtils leaf node
                deriving (Foldable,Traversable,Functor)

data Layout = Above
            | Offset RowOffset ColOffset
            | NoChange
            deriving (Show)


