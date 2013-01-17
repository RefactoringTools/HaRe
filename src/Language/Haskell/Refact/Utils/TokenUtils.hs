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
       , treeStartEnd
       , insertSrcSpan
       , getSrcSpanFor
       , retrieveTokens

       -- * Internal, for testing
       , splitForestOnSpan
       , lookupSrcSpan
       , invariantOk
       , invariant
       , mkTreeFromTokens
       , mkTreeFromSpanTokens
       , showForest
       , showTree
       , showSrcSpan

       -- * Based on Data.Tree
       , drawTreeEntry
       , drawForestEntry
       , drawEntry
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

-- TODO: turn this into a record, with named accessors
-- | An entry in the data structure for a particular srcspan.
data Entry = Entry GHC.SrcSpan -- ^The source span contained in this Node
                   [PosToken]  -- ^The tokens for the SrcSpan if subtree is empty
                   (Maybe (Tree Entry)) -- ^Parent Node if it exists
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
      , mTokenCache = [mkTreeFromTokens tokens]
      }

-- Initially work with non-monadic code, can build it into the
-- RefactGhc monad later

-- ---------------------------------------------------------------------

-- | Get the (possible cached) tokens for a given source span, and
-- cache their being fetched.
-- NOTE: The SrcSpan may be one introduced by HaRe, rather than GHC.
-- TODO: consider returning an Either. Although in reality the error
--       should never happen
getTokensFor :: Module -> GHC.SrcSpan -> (Module,[PosToken])
getTokensFor modu sspan = (modu', tokens)
  where
     forest = if invariantOk (mTokenCache modu) -- TODO: remove this, expensive operation
               then mTokenCache modu
               else []
     (forest',tree) = getSrcSpanFor forest sspan
     modu' = modu { mTokenCache = forest' }

     tokens = retrieveTokens [tree]

-- ---------------------------------------------------------------------
-- |Retrieve a tree containing a SrcSpan from the forest, inserting it
-- if not already present
getSrcSpanFor :: Forest Entry -> GHC.SrcSpan -> (Forest Entry, Tree Entry)
getSrcSpanFor forest sspan = (forest',tree)
  where
    forest' = insertSrcSpan forest sspan -- Will NO-OP if already there
    [tree]  = lookupSrcSpan forest' sspan

-- ---------------------------------------------------------------------
-- |Insert a SrcSpan into the forest, if it is not there already.
-- Assumes the forest was populated with the tokens containing the
-- SrcSpan already
insertSrcSpan :: Forest Entry -> GHC.SrcSpan -> Forest Entry
insertSrcSpan forest sspan = forest'
  where
    startPos = getGhcLoc sspan
    endPos   = getGhcLocEnd sspan

    (begin,middle,end) = splitForestOnSpan forest sspan
    forest' = case middle of
     []  -> error $ "forest does not contain span: " ++ (show (startPos,endPos))
     [x] -> if treeStartEnd x == (startPos,endPos)
              then forest   -- Already in the tree
              else forest'' -- Need to check the subtree
               where
                 (Node (Entry _sspan toks mp) sub) = x
                 forest'' = if (emptyList sub)
                   then begin ++ [(Node (Entry _sspan   [] mp) subTree)] ++ end
                   else begin ++ [(Node (Entry _sspan toks mp)    sub')] ++ end
                          where
                            sub' = insertSrcSpan sub sspan

                            -- Tokens here, must introduce sub-spans
                            -- with split, taking cognizance of start
                            -- and end comments
                            (startLoc,endLoc) = startEndLocIncComments' toks (startPos,endPos)

                            -- (startToks,middleToks,endToks) = splitToks (startPos,endPos) toks
                            (startToks,middleToks,endToks) = splitToks (startLoc,endLoc) toks
                            {-
                            subTree = [mkTreeFromTokens startToks,
                                       mkTreeFromTokens middleToks,
                                       mkTreeFromTokens endToks]
                            -}
                            subTree = [mkTreeFromTokens startToks,
                                       mkTreeFromSpanTokens sspan middleToks,
                                       mkTreeFromTokens endToks]

     _  ->  forest'' -- TODO: Multiple, Need to insert a new span "above" these.
                     --       Hmm. is this possible?
       where
         forest'' = forest


-- ---------------------------------------------------------------------

-- |Retrieve all the tokens at the leaves of the tree, in order
retrieveTokens :: Forest Entry -> [PosToken]
-- retrieveTokens forest = F.foldl accum [] forest
retrieveTokens forest = concat $ map (\t -> F.foldl accum [] t) forest
-- retrieveTokens forest =F.foldl accum [] forest
  where
    accum :: [PosToken] -> Entry -> [PosToken]
    accum acc (Entry _ toks _) = acc ++ toks

    -- accum :: [PosToken] -> Tree Entry -> [PosToken]
    -- accum acc (Node (Entry _ toks _) _) = acc ++ toks

-- ---------------------------------------------------------------------

-- |Split a forest of trees into a (begin,middle,end) according to a
-- SrcSpan, such that no tokens are included in begin or end belonging
-- to the SrcSpan, and all of middle has some part of the SrcSpan
splitForestOnSpan :: Forest Entry -> GHC.SrcSpan
                  -> ([Tree Entry],[Tree Entry],[Tree Entry])
splitForestOnSpan forest sspan = (beginTrees,middleTrees,endTrees)
  where
    start = getGhcLoc sspan
    end   = getGhcLocEnd sspan

    (beginTrees,rest)      = break inSpan forest
    (middleTrees,endTrees) = break (\t -> not $ inSpan t) rest

    inSpan tree = inStart || inMiddle || inEnd
      where
        (treeStart,treeEnd) = treeStartEnd tree
        inStart  = start >= treeStart && start <= treeEnd
        inMiddle = start <= treeStart && end   >= treeEnd
        inEnd    = end   >= treeStart && end   <= treeEnd

-- ---------------------------------------------------------------------

-- | Look a SrcSpan up in the forest.
-- There are three possibilities
-- 1. It is not there
-- 2. It is there, exactly
-- 3. It is not there exactly, but is a sub-element of something that
--    is there. In this case return the smallest containing element.
-- This may be a list of trees, if the desired span crosses multiple
-- trees.
lookupSrcSpan :: Forest Entry -> GHC.SrcSpan -> [Tree Entry]
lookupSrcSpan forest sspan = res
  where
    -- Assuming invariants hold, the forest is sorted,
    -- So, move through trees until ones containing the span are
    -- found.
    -- If it is contained in a single tree, drill into it to find the
    -- smallest set of trees containing the span

    (_,middle,_) = splitForestOnSpan forest sspan
    res = case middle of
           [Node _  []] -> middle
           [Node _ sub] -> lookupSrcSpan sub sspan
           _   -> middle


-- ---------------------------------------------------------------------

-- |Utility function to either return True or throw an error to report the problem
invariantOk :: Forest Entry -> Bool
invariantOk forest = ok
  where
    inv = invariant forest
    ok = case inv of
           [] -> True
           _  -> error $ "Token Tree invariant fails:" ++ (intercalate "\n" inv)

-- ---------------------------------------------------------------------
-- |Check the invariant for the token cache. Returns list of any errors found.
-- Invariants:
--   1. For each tree, either the rootLabel has a SrcSpan only, or the subForest /= [].
--   2a. The trees making up the subForest of a given node fully include the parent SrcSpan.
--        i.e. the leaves contain all the tokens for a given SrcSpan.
--   2b. The subForest is in SrcSpan order
--   3. A given SrcSpan can only appear (or be included) in a single tree of the forest.
-- NOTE: the tokens may extend before or after the SrcSpan, due to comments only
-- NOTE2: this will have to be revisited when edits to the tokens are made
invariant :: Forest Entry -> [String]
invariant forest = rforest ++ rsub
  where
    rforest = checkForest $ map treeStartEnd forest
      where
        checkForest [] = []
        checkForest [_x] = []
        checkForest ((_s1,e1):s@(s2,_e2):ss)
          = r ++ checkForest (s:ss)
          where
            r = if e1 <= s2
                 then []
                 else ["FAIL: forest not in order: " ++
                        show e1 ++ " not < " ++ show s2]


    rsub = F.foldl checkOneTree [] forest

    checkOneTree :: [String] -> Tree Entry -> [String]
    checkOneTree acc tree = acc ++ r
      where
        r = checkNode [] tree

    checkNode :: [String] -> Tree Entry -> [String]
    checkNode acc node@(Node (Entry _sspan toks _mp) sub) = acc ++ r ++ rinc ++ rsub
      where
        r = if (   emptyList toks && nonEmptyList sub) ||
               (nonEmptyList toks &&    emptyList sub)
              then []
              else ["FAIL: exactly one of toks or subforest must be empty: " ++ (prettyshow node)]
        rsub = foldl' checkNode [] sub

        rinc = checkInclusion node

    -- |Check invariant 2, assuming 1 ok
    checkInclusion      (Node _                    []) = []
    checkInclusion node@(Node (Entry sspan toks mp)  sub) = rs ++ rseq
      where
        (start,end) = treeStartEnd node
        subs = map treeStartEnd sub
        (sstart, _) = head subs
        (_, send) = last subs

        rs = if (start == sstart) && (end == send)
               then []
               else ["FAIL: subForest start and end does not match entry: " ++ (prettyshow node)]

        rseq = checkSequence node subs

        checkSequence _ [] = []
        checkSequence _ [_x] = []
        checkSequence node ((s1,e1):s@(s2,e2):ss)
          = r ++ checkSequence node (s:ss)
          where
            r = if e1 <= s2
                 then []
                 else ["FAIL: subForest not in order: " ++
                        show e1 ++ " not < " ++ show s2 ++
                        ":" ++ prettyshow node]

-- ---------------------------------------------------------------------

-- |Get the start and end position of a Tree
treeStartEnd :: Tree Entry -> (SimpPos,SimpPos)
treeStartEnd (Node (Entry sspan _ _) _) = (getGhcLoc sspan,getGhcLocEnd sspan)

-- ---------------------------------------------------------------------
{-
-- showForest :: Forest Entry -> String
showForest forest = map (showSubTree 0) forest
  where
    -- showSubTree :: Int -> Tree Entry -> String
    showSubTree indent tree@(Node (Entry sspan toks mp) sub)
      = (take indent (repeat ' '))
        ++ (show (getGhcLoc sspan, getGhcLocEnd sspan)) ++ " "
        ++ (case toks of
             [] -> showSubTree (indent+2) sub
             _  -> "toks")
-}

showForest :: [Tree Entry] -> [String]
showForest forest = map showTree forest

-- ---------------------------------------------------------------------
-- | Neat 2-dimensional drawing of a tree.
drawTreeEntry :: Tree Entry -> String
drawTreeEntry  = unlines . drawEntry

-- | Neat 2-dimensional drawing of a forest.
drawForestEntry :: Forest Entry -> String
drawForestEntry  = unlines . map drawTreeEntry

drawEntry :: Tree Entry -> [String]
drawEntry (Node (Entry sspan _toks _mp) ts0) = (showSrcSpan sspan) : drawSubTrees ts0
  where
    drawSubTrees [] = []
    drawSubTrees [t] =
        "|" : shift "`- " "   " (drawEntry t)
    drawSubTrees (t:ts) =
        "|" : shift "+- " "|  " (drawEntry t) ++ drawSubTrees ts

    shift first other = zipWith (++) (first : repeat other)

-- ---------------------------------------------------------------------

showTree :: Tree Entry -> String
showTree = prettyshow

-- |Represent a tree in a more concise/pretty way
prettyshow :: Tree Entry -> String
prettyshow (Node (Entry sspan toks _mp) sub)
  = "Node (Entry " ++ (showSrcSpan sspan) ++ " "
     ++ (prettyToks toks) ++ ") "
     ++ show (map prettyshow  sub)

prettyToks :: [PosToken] -> String
prettyToks [] = "[]"
prettyToks toks@[_x] = showToks toks
prettyToks toks@[_t1,_t2] = showToks toks
prettyToks toks = showToks [head toks] ++ ".." ++ showToks [last toks]

-- ---------------------------------------------------------------------

-- |Make a tree representing a particular set of tokens
mkTreeFromTokens :: [PosToken] -> Tree Entry
mkTreeFromTokens [] = Node (Entry GHC.noSrcSpan [] Nothing) []
mkTreeFromTokens toks = Node (Entry sspan toks Nothing) []
  where
   startLoc = realSrcLocFromTok $ head toks
   endLoc   = realSrcLocFromTok $ last toks -- SrcSpans count from start of token, not end
   sspan    = GHC.RealSrcSpan $ GHC.mkRealSrcSpan startLoc endLoc

-- ---------------------------------------------------------------------

-- |Make a tree representing a particular set of tokens
mkTreeFromSpanTokens :: GHC.SrcSpan -> [PosToken] -> Tree Entry
mkTreeFromSpanTokens sspan toks = Node (Entry sspan toks Nothing) []

-- ---------------------------------------------------------------------

showSrcSpan :: GHC.SrcSpan -> String
showSrcSpan sspan = show (getGhcLoc sspan, (r,c))
  where
    (r,c) = getGhcLocEnd sspan

-- EOF
