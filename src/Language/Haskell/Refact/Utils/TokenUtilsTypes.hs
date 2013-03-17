-- |
--
-- This module contains types shared between TokenUtils and Monad, and
-- exists to break import cycles
--
--

module Language.Haskell.Refact.Utils.TokenUtilsTypes(
       Entry(..)
       , ForestLine(..)
       , ForestPos
       , ForestSpan
       , TreeId(..)
       , TokenCache(..)
       , mainTid
       ) where

import Language.Haskell.Refact.Utils.TypeSyn
import Data.Tree
import qualified Data.Map as Map

-- ---------------------------------------------------------------------

{-

Structure is to be indexed by SrcSpan.

Must be recursive, so if one srcspan is requested that contains a
modified sub-src span, the modified one is returned.

When initialising, split the tokens according to the binds, including
the leading and following comments. And perhaps a preamble and
postamble.

The token start and end loc does not necessarily coincide with the
associated srcloc, due to leading / trailing comments

SrcSpans are nested in one another according to the structure of the
AST.

Store it in some kind of tree structure, memoised.

Invariants:
  1. For each tree, either the rootLabel has a SrcSpan only, or the subForest /= [].
  2. The trees making up the subForest of a given node fully include the parent SrcSpan.
     i.e. the leaves contain all the tokens for a given SrcSpan.
  3. A given SrcSpan can only appear (or be included) in a single tree of the forest.

-}

-- TODO: turn this into a record, with named accessors
-- | An entry in the data structure for a particular srcspan.
data Entry = Entry ForestSpan -- ^The source span contained in this Node
                   [PosToken] -- ^The tokens for the SrcSpan if subtree is empty

-- ---------------------------------------------------------------------

data ForestLine = ForestLine
                  { flTreeSelector :: Int
                  , flInsertVersion :: Int
                  , flLine :: Int
                  } deriving (Eq)

instance Show ForestLine where
  show s = "(ForestLine " ++ (show $ flTreeSelector s) 
         ++ " " ++ (show $ flInsertVersion s)
         ++ " " ++ (show $ flLine s)
         ++ ")"


-- ---------------------------------------------------------------------

type ForestPos = (ForestLine,Int)


-- |Match a SrcSpan, using a ForestLine as the marker
type ForestSpan = (ForestPos,ForestPos)

-- ---------------------------------------------------------------------

data TreeId = TId Int deriving (Eq,Ord,Show)

-- |Identifies the tree carrying the main tokens, not any work in
-- progress or deleted ones
mainTid :: TreeId
mainTid = TId 0

data TokenCache = TK
  { tkCache :: Map.Map TreeId (Tree Entry)
  , tkLastTreeId :: TreeId
  }

-- ---------------------------------------------------------------------

-- EOF
