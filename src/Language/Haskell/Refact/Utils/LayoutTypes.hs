{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeFamilies       #-}
{-# LANGUAGE EmptyDataDecls     #-}
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
import GHC.Generics

import qualified Data.Generics as SYB

import Language.Haskell.Refact.Utils.TypeSyn

-- ---------------------------------------------------------------------

data TokenLayout = TL LayoutTree

-- ---------------------------------------------------------------------
{-

The layout will have to have a tree structure

-}


type RowOffset = Int
type ColOffset = Int

data LayoutTree = Group GHC.SrcSpan Layout [LayoutTree]  -- Same as current
                                       -- TokenUtils internal tree node
                | Leaf  GHC.SrcSpan Layout [PosToken] -- Same as current
                                      -- TokenUtils leaf node
                -- deriving (SYB.Typeable,SYB.Data)

deriving instance SYB.Typeable GHC.Token

data Layout = Above
            | Offset RowOffset ColOffset
            | NoChange
            deriving (Show,SYB.Typeable,SYB.Data)


-- ---------------------------------------------------------------------

data D_Token
data C_Token

instance Datatype D_Token where
  datatypeName _ = "Token"
  moduleName   _ = "Token"

instance Constructor C_Token where
  conName _ = "" -- JPM: I'm not sure this is the right implementation...

instance Generic Token where
  type Rep Token = D1 D_Token (C1 C_Token (S1 NoSelector (Rec0 Token)))
  from x = M1 (M1 (M1 (K1 x)))
  to (M1 (M1 (M1 (K1 x)))) = x

