{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances    #-}
module Language.Haskell.Refact.Utils.Types
       (
        ApplyRefacResult
       , RefacResult(..)
       -- *
       , TreeId(..)
       , mainTid
       , TokenCache(..)
       , SimpPos
       , SimpSpan
       , NameMap

       ) where

import qualified GHC        as GHC
import qualified Name       as GHC
import qualified Outputable as GHC

import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Utils

import qualified Data.Map as Map


-- ---------------------------------------------------------------------
-- | The result of a refactoring is the file, a flag as to whether it
-- was modified, and the updated AST
type ApplyRefacResult = ((FilePath, RefacResult), (Anns,GHC.ParsedSource))

data RefacResult = RefacModified | RefacUnmodifed
                 deriving (Show,Ord,Eq)

-- ---------------------------------------------------------------------

data TreeId = TId !Int deriving (Eq,Ord,Show)

-- |Identifies the tree carrying the main tokens, not any work in
-- progress or deleted ones
mainTid :: TreeId
mainTid = TId 0

data TokenCache a = TK
  { tkCache :: !(Map.Map TreeId a)
  , tkLastTreeId :: !TreeId
  } deriving (Show)

type SimpPos = (Int,Int) -- Line, column
type SimpSpan = (SimpPos,SimpPos)

-- ---------------------------------------------------------------------

type NameMap = Map.Map GHC.SrcSpan GHC.Name

-- instance GHC.Outputable NameMap where
--   ppr nm = GHC.text "NameMap" GHC.<+> GHC.hcat (map one $ Map.toList nm)
--     where
--       one (s,n) = GHC.text (showGhc (s,n,GHC.nameUnique n))
