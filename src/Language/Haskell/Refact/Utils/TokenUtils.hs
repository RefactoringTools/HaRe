-- |
--
-- This module contains an API to manage a token stream.
--
-- Its status is currently highly exploratory, and may disappear.
--

module Language.Haskell.Refact.Utils.TokenUtils(
       Entry(..)
       , Module(..)
       , initModule
       , getTokensFor

       -- * Internal, for testing
       , lookupSrcSpan
       , invariant
       , mkTreeFromTokens
       ) where

import qualified BasicTypes    as GHC
import qualified DynFlags      as GHC
import qualified FastString    as GHC
import qualified GHC           as GHC
import qualified GHC.Paths     as GHC
import qualified HsSyn         as GHC
import qualified Lexer         as GHC
import qualified Module        as GHC
import qualified MonadUtils    as GHC
import qualified Outputable    as GHC
import qualified RdrName       as GHC
import qualified SrcLoc        as GHC
import qualified StringBuffer  as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import qualified Data.Foldable as F

import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn

import Data.List
import Data.Tree

-- ---------------------------------------------------------------------

{-

Structure is to be indexed by SrcSpan.

Memo-ised.

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

-- | An entry in the data structure for a particular srcspan.
data Entry = Entry GHC.SrcSpan [PosToken]
             deriving (Show)


-- | Operations on the structure
data Operations = OpAdded Entry          -- ^The entry that was added
                | OpRemoved Entry        -- ^The Entry that was removed
                | OpReplaced Entry Entry -- ^The first is old, second is new Entry


data Module = Module
        { mTypecheckedMod :: GHC.TypecheckedModule
        , mOrigTokenStream :: [PosToken]  -- ^Original Token stream for the current module
        , mTokenCache :: Forest Entry -- ^Any modifications to the token stream. 
        }

-- Attempt 1. Build a Rose Tree from all SrcSpans in the file.

mkTree :: GHC.RenamedSource -> [PosToken] -> Forest Entry
mkTree renamed tokens = []

initModule :: GHC.TypecheckedModule -> [PosToken] -> Module
initModule typeChecked tokens
  = Module
      { mTypecheckedMod = typeChecked
      , mOrigTokenStream = tokens
      , mTokenCache = []
      }

-- Initially work with non-monadic code, can build it into the
-- RefactGhc monad later

-- ---------------------------------------------------------------------

-- | Get the (possible cached) tokens for a given source span, and
-- cache their being fetched.
getTokensFor :: Module -> GHC.SrcSpan -> (Module,[PosToken])
getTokensFor modu span = (modu', tokens)
  where
     modu' = modu
     tokens = []

-- ---------------------------------------------------------------------

-- | Look a SrcSpan up in the forest.
-- There are three possibilities
-- 1. It is not there
-- 2. It is there, exactly
-- 3. It is not there exactly, but is a sub-element of something that
-- is there. In this case return the smallest containing element.
lookupSrcSpan :: Forest Entry -> GHC.SrcSpan -> Maybe Entry
lookupSrcSpan forest span = res
  where
    res = Nothing


-- ---------------------------------------------------------------------
-- |Check the invariant for the token cache. Returns list of any errors found.
-- Invariants:
--   1. For each tree, either the rootLabel has a SrcSpan only, or the subForest /= [].
--   2. The trees making up the subForest of a given node fully include the parent SrcSpan.
--      i.e. the leaves contain all the tokens for a given SrcSpan.
--   3. A given SrcSpan can only appear (or be included) in a single tree of the forest.
invariant :: Forest Entry -> [String]
invariant forest = res
  where
    res = F.foldl checkOneTree [] forest

    checkOneTree :: [String] -> Tree Entry -> [String]
    checkOneTree acc tree = acc ++ r
      where
        -- r = F.foldl checkNode [] tree
        r = checkNode [] tree

    checkNode :: [String] -> Tree Entry -> [String]
    checkNode acc node@(Node (Entry span toks)  sub) = acc ++ r ++ rsub
      where
        r = if (emptyList toks && nonEmptyList sub) || (nonEmptyList toks && emptyList sub)
              then []
              else ["FAIL: exactly one of toks or subforest must be empty: " ++ (prettyshow node)]
        rsub = foldl' checkNode [] sub

-- ---------------------------------------------------------------------

-- |Represent a tree in a more concise/pretty way
prettyshow :: Tree Entry -> String
prettyshow (Node (Entry span toks) sub)
  = "Node (Entry " ++ (show span) ++ " " ++ (show toks) ++ ") " ++ (show sub)

-- ---------------------------------------------------------------------

-- |Make a tree representing a particular set of tokens
mkTreeFromTokens :: [PosToken] -> Tree Entry
mkTreeFromTokens [] = Node (Entry GHC.noSrcSpan []) []
mkTreeFromTokens toks = Node (Entry span toks) []
  where
   startLoc = realSrcLocFromTok $ head toks
   endLoc   = realSrcLocEndTok $ last toks
   span     = GHC.RealSrcSpan $ GHC.mkRealSrcSpan startLoc endLoc

-- EOF
