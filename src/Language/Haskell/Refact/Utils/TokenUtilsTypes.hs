-- |
--
-- This module contains types shared between TokenUtils and Monad, and
-- exists to break import cycles
--
--

module Language.Haskell.Refact.Utils.TokenUtilsTypes(
       -- * The cache of trees comprising the manipulated tokens
         TokenCache(..)
       , TreeId(..)
       , mainTid
       -- * Structure of each tree
       , Entry(..)
       , Layout(..)
       , RowOffset
       , ColOffset
       , Row
       , Col
       , ForestLine(..)
       , ForestPos
       , ForestSpan
       , Ppr(..)
       -- , HDoc(..)
       ) where

import Language.Haskell.Refact.Utils.TypeSyn
import Data.Tree
import qualified Data.Map as Map

import Outputable

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

Store it in some kind of tree structure.

Invariants:
  1. For each tree, either the rootLabel has a SrcSpan only, or the subForest /= [].
  2. The trees making up the subForest of a given node fully include the parent SrcSpan.
     i.e. the leaves contain all the tokens for a given SrcSpan.
  3. A given SrcSpan can only appear (or be included) in a single tree of the forest.

There are conflicting requirements for access to the tokens. On the
one hand the tokens need to be moved around (mainly in columns) to
support changing layout as e.g. a token is renamed. On the other, the
originals need to be preserved, so they can tie up with the positions
in the SrcSpans and for renaming.

Question: is the latter statement valid? ++AZ++

-}

-- TODO: turn this into a record, with named accessors
-- | An entry in the data structure for a particular srcspan.
data Entry = Entry !ForestSpan -- The source span contained in this
                                  -- Node
                   !Layout     -- ^How the sub-elements nest
                   ![PosToken] -- ^The tokens for the SrcSpan if
                               --  subtree is empty
           | Deleted !ForestSpan -- The source span has been deleted
                     SimpPos     -- ^The gap between this span end and
                                 --  the start of the next in the
                                 --  fringe of the tree.
--             deriving (Show)

type RowOffset = Int
type ColOffset = Int
type Row       = Int
type Col       = Int

data Layout = Above RowOffset ColOffset (Row,Col) (Row,Col) (RowOffset,ColOffset)
            -- ^ Initial Row and Col offset from token before the
            -- stacked list of items, the (r,c) of the first
            -- non-comment token, the (r,c) of the last non-comment
            -- token in the stacked list to be able to calculate the
            -- (RowOffset,ColOffset) between the last token and the
            -- start of the next item.
            | Offset RowOffset ColOffset
            | NoChange
            -- | Offset between the end of an 'Above' entry and the
            -- next one
            | EndOffset RowOffset ColOffset
            deriving (Show,Eq)


-- ---------------------------------------------------------------------

data ForestLine = ForestLine
                  { flSpanLengthChanged :: !Bool -- ^The length of the
                                                 -- span may have
                                                 -- changed due to
                                                 -- updated tokens.
                  , flTreeSelector  :: !Int
                  , flInsertVersion :: !Int
                  , flLine          :: !Int
                  } -- deriving (Eq)

instance Eq ForestLine where
  -- TODO: make this undefined, and patch all broken code to use the
  --       specific fun here directly instead.
  (ForestLine _ s1 v1 l1) == (ForestLine _ s2 v2 l2) = s1 == s2 && v1 == v2 && l1 == l2

instance Show ForestLine where
  show s = "(ForestLine " ++ (show $ flSpanLengthChanged s)
         ++ " " ++ (show $ flTreeSelector s)
         ++ " " ++ (show $ flInsertVersion s)
         ++ " " ++ (show $ flLine s)
         ++ ")"

instance Outputable ForestLine where
  ppr fl = text (show fl)

-- ---------------------------------------------------------------------

type ForestPos = (ForestLine,Int)


-- |Match a SrcSpan, using a ForestLine as the marker
type ForestSpan = (ForestPos,ForestPos)

-- ---------------------------------------------------------------------

data TreeId = TId !Int deriving (Eq,Ord,Show)

-- |Identifies the tree carrying the main tokens, not any work in
-- progress or deleted ones
mainTid :: TreeId
mainTid = TId 0

data TokenCache = TK
  { tkCache :: !(Map.Map TreeId (Tree Entry))
  , tkLastTreeId :: !TreeId
  }

-- ---------------------------------------------------------------------

-- |A data structure to make the ppr process visible
data Ppr = PprText Row Col [PosToken] -- ^Original row and col of the tokens
         | PprAbove RowOffset ColOffset (Row,Col) (RowOffset,ColOffset) [Ppr]
         -- ^ Offset of start of embedded parts, coords of last token
         | PprOffset RowOffset ColOffset [Ppr]

-- ---------------------------------------------------------------------
{-
infixl 6 `Hbeside`
infixl 6 `Habove`

-- |A structure to wrap the pretty print commands to make them
-- visible, since Doc constructors are not exported
data HDoc = Htext String
          | Hhcat [HDoc]
          | Hvcat [HDoc]
          | Hnest Int HDoc
          | HDoc `Hbeside` HDoc
          | HDoc `Habove` HDoc
          | Hempty
          deriving (Eq,Show)
-}
-- ---------------------------------------------------------------------

-- EOF
