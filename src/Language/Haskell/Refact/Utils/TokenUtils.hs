{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE UndecidableInstances #-}

-- |
--
-- This module contains an API to manage a token stream.
--
--

module Language.Haskell.Refact.Utils.TokenUtils(
       Entry(..)
       , Module(..)
       , initModule
       , getTokensFor
       , updateTokensForSrcSpan
       , treeStartEnd
       , insertSrcSpan
       , getSrcSpanFor
       , getPathFor
       , retrieveTokens

       , addNewSrcSpanAndToksAfter
       , addToksAfterSrcSpan

       -- * Utility
       , posToSrcSpan


       -- * AST tie up
       , syncAST


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
       , ghcSpanStartEnd
       , insertNodeAfter

       , ghcLineToForestLine
       , forestLineToGhcLine
       , insertForestLineInSrcSpan
       , srcSpanToForestSpan
       , nullSpan
       , simpPosToForestSpan
       , showForestSpan

       -- * Based on Data.Tree
       , drawTreeEntry
       , drawForestEntry
       , drawEntry

       -- * Moved from TokenUtils
       , showToks
       , tokenCol, tokenRow
       , tokenPos, tokenPosEnd
       , tokenCon
       , increaseSrcSpan
       , getLocatedStart
       , getLocatedEnd
       , getGhcLoc
       , getGhcLocEnd
       , getStartEndLoc
       , startEndLocGhc
       , realSrcLocFromTok
       , realSrcLocEndTok
       , splitToks
       , emptyList, nonEmptyList
       , startEndLocIncComments, startEndLocIncComments'
       , isComment
       , getSrcSpan
       , getIndentOffset
       , splitOnNewLn
       , tokenLen
       , newLnToken
       , newLinesToken
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
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn

import Data.List
import Data.Maybe
import Data.Tree
import qualified Data.Tree.Zipper as Z

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

{-

NOTE: To break a cyclical import, this definition is in its own file

-- TODO: turn this into a record, with named accessors
-- | An entry in the data structure for a particular srcspan.
data Entry = Entry GHC.SrcSpan -- ^The source span contained in this Node
                   [PosToken]  -- ^The tokens for the SrcSpan if subtree is empty
             deriving (Show)
-}

{-

Note : Need to

1. Re-locate tokens according to their surrounding context. i.e. match
   indent of enclosing structure, add leading/trailing newlines

2. Required by 1: Sync the SrcSpans to the AST, in the context of layout


-}

deriving instance Show Entry => Show (Entry)

-- ---------------------------------------------------------------------
-- ++AZ++ TODO: will we actuall need these?
-- | Operations on the structure
data Operations = OpAdded Entry          -- ^The entry that was added
                | OpRemoved Entry        -- ^The Entry that was removed
                | OpReplaced Entry Entry -- ^The first is old, second is new Entry


-- ---------------------------------------------------------------------

-- A data type for the line entries in a SrcSpan. This has the
-- following properties
--
-- 1. It can be converted to and from the underlying Int in the
--    original SrcSpan
-- 2. It allows the insertion of an arbitrary line as the start of a
--    new SrcSpan
-- 3. It has an ordering relation, which honours the inserts which
--    were made.
--
-- This is achieved by adding a field to the SrcSpan to indicate its
-- insert relationship, encoded as 0 for the original, 1 for the
-- first, 2 for the second and so on.
--
-- This field is converted to and from the original line by being
-- multiplied by a very large number and added to the original.
--
-- The guaranteed max value in Haskel for an Int is 2^29 - 1.
-- This evaluates to 536870911,or 536.8 million.
--
-- It is extremely unlikely that a source file will have more than a
-- million lines, or that we will have to insert more than 536
-- SrcSpans after a given one,so we will choose our constant as 10^6
forestConstant :: Int
forestConstant = 1000000

{-
This has been moved to TokenUtilsTypes

data ForestLine = ForestLine
                  { flInsertVersion :: Int
                  , flLine :: Int
                  } deriving (Eq,Show)
-}

-- | Extract an encoded ForestLine from a GHC line
ghcLineToForestLine :: Int -> ForestLine
ghcLineToForestLine line = ForestLine v l
  where
    l = mod line forestConstant
    v = div line forestConstant

forestLineToGhcLine :: ForestLine -> Int
forestLineToGhcLine fl = ((flInsertVersion fl) * forestConstant) + (flLine fl)

instance Ord ForestLine where
  -- Use line as the primary comparison, but break any ties with the version
  compare (ForestLine v1 l1) (ForestLine v2 l2) =
    if (l1 == l2)
      then compare v1 v2
      else compare l1 l2

-- |Strip out the version markers
forestSpanToSimpPos :: ForestSpan -> (SimpPos,SimpPos)
forestSpanToSimpPos ((ForestLine _ sr,sc),(ForestLine _ er,ec)) = ((sr,sc),(er,ec))

simpPosToForestSpan :: (SimpPos,SimpPos) -> ForestSpan
simpPosToForestSpan ((sr,sc),(er,ec))
    = ((ghcLineToForestLine sr,sc),(ghcLineToForestLine er,ec))

nullSpan :: ForestSpan
nullSpan = ((ForestLine 0 0,0),(ForestLine 0 0,0))

showForestSpan :: ForestSpan -> String
showForestSpan ((sr,sc),(er,ec))
  = show ((forestLineToGhcLine sr,sc),(forestLineToGhcLine er,ec))

-- ---------------------------------------------------------------------

insertForestLineInSrcSpan :: ForestLine -> GHC.SrcSpan -> GHC.SrcSpan
insertForestLineInSrcSpan fl@(ForestLine v l) sspan@(GHC.RealSrcSpan ss) = ss'
  where
    lineStart = forestLineToGhcLine fl
    lineEnd   = forestLineToGhcLine (ForestLine v (GHC.srcSpanEndLine ss))
    locStart = GHC.mkSrcLoc (GHC.srcSpanFile ss) lineStart (GHC.srcSpanStartCol ss)
    locEnd   = GHC.mkSrcLoc (GHC.srcSpanFile ss) lineEnd   (GHC.srcSpanEndCol ss)
    ss' = GHC.mkSrcSpan locStart locEnd

insertForestLineInSrcSpan _ ss = error $ "insertForestLineInSrcSpan: expecting a RealSrcSpan, got:" ++ (GHC.showPpr ss)

-- ---------------------------------------------------------------------

srcSpanToForestSpan :: GHC.SrcSpan -> ForestSpan
srcSpanToForestSpan sspan = ((ghcLineToForestLine startRow,startCol),(ghcLineToForestLine endRow,endCol))
  where
    (startRow,startCol) = getGhcLoc sspan
    (endRow,endCol) = getGhcLocEnd sspan

-- ---------------------------------------------------------------------

data Module = Module
        { mTypecheckedMod :: GHC.TypecheckedModule
        , mOrigTokenStream :: [PosToken]  -- ^Original Token stream for the current module
        , mTokenCache :: Tree Entry -- ^Any modifications to the token stream.
        }

-- Attempt 1. Build a Rose Tree from all SrcSpans in the file.

mkTree :: GHC.RenamedSource -> [PosToken] -> Forest Entry
mkTree renamed tokens = []

initModule :: GHC.TypecheckedModule -> [PosToken] -> Module
initModule typeChecked tokens
  = Module
      { mTypecheckedMod = typeChecked
      , mOrigTokenStream = tokens
      , mTokenCache = mkTreeFromTokens tokens
      }

-- Initially work with non-monadic code, can build it into the
-- RefactGhc monad later

-- ---------------------------------------------------------------------

-- |Get the (possible cached) tokens for a given source span, and
-- cache their being fetched.
-- NOTE: The SrcSpan may be one introduced by HaRe, rather than GHC.
-- TODO: consider returning an Either. Although in reality the error
--       should never happen
getTokensFor :: Module -> GHC.SrcSpan -> (Module,[PosToken])
getTokensFor modu sspan = (modu', tokens)
  where
     forest = if invariantOk (mTokenCache modu) -- TODO: remove this, expensive operation
               then mTokenCache modu
               else mTokenCache modu
     (forest',tree) = getSrcSpanFor forest (srcSpanToForestSpan sspan)
     modu' = modu { mTokenCache = forest' }

     tokens = retrieveTokens tree

-- ---------------------------------------------------------------------

-- |Replace the tokens for a given SrcSpan with new ones. The SrcSpan
-- will be inserted into the tree if it is not already there
updateTokensForSrcSpan :: Tree Entry -> GHC.SrcSpan -> [PosToken] -> Tree Entry
updateTokensForSrcSpan forest sspan toks = forest''
  where
    -- Make sure the sspan is in the tree
    (forest',node@(Node (Entry s _) _)) = getSrcSpanFor forest (srcSpanToForestSpan sspan)
    zf = openZipperToNode node $ Z.fromTree forest'
    -- ++AZ++ what if the given sourcespan is not a leaf node?
    --        Should wipe out the structure below, as no longer valid
    -- zf' = Z.setLabel (Entry s toks) zf
    zf' = Z.setTree (Node (Entry s toks) []) zf
    forest'' = Z.toTree zf'

-- ---------------------------------------------------------------------
-- |Retrieve a path to the tree containing a ForestSpan from the forest,
-- inserting it if not already present
getSrcSpanFor :: Tree Entry -> ForestSpan -> (Tree Entry, Tree Entry)
getSrcSpanFor forest sspan = (forest',tree)
  where
    forest' = insertSrcSpan forest sspan -- Will NO-OP if already there
    tree = case (lookupSrcSpan [forest'] sspan) of
             [x] -> x
             xx  -> error $ "TokenUtils.getSrcSpanFor("++ (show sspan) ++ "): got " ++ (show xx)

-- ---------------------------------------------------------------------
-- |Retrieve a path to the tree containing a SrcSpan from the forest,
-- or return an empty list if it is not present
getPathFor :: Tree Entry -> GHC.SrcSpan -> [Tree Entry]
getPathFor forest sspan = getPathFor' [] [forest] (srcSpanToForestSpan sspan)
  where
    getPathFor' :: [Tree Entry] -> Forest Entry -> ForestSpan -> [Tree Entry]
    getPathFor' path f ss  = res
      where
        (_,middle,_) = splitForestOnSpan f ss
        res = case middle of
           [m@(Node _ [])] -> if (ss == treeStartEnd m)
                                 then (path++middle) else []
           [Node _ sub] -> getPathFor' (path ++ middle) sub ss
           _   -> (path ++ middle)


-- ---------------------------------------------------------------------
-- |Insert a ForestSpan into the forest, if it is not there already.
-- Assumes the forest was populated with the tokens containing the
-- ForestSpan already
insertSrcSpan :: Tree Entry -> ForestSpan -> Tree Entry
insertSrcSpan forest sspan = forest'
  where
    z = openZipperToSpan sspan $ Z.fromTree forest
    forest' = if treeStartEnd (Z.tree z) == sspan
      then forest -- Already in, exactly
      else forest''
        where
          toks = if (Z.isLeaf z)
            then
              -- If we are at a leaf, retrieve the toks
              let (Entry _ t) = Z.label z in t
            else
              -- Have multiple sub-trees containing the tokens

              -- TODO: we are potentially discarding added info here,
              -- with sub SrcSpans having markers in them
              retrieveTokens $ Z.toTree z

          (tokStartPos,tokEndPos) = forestSpanToSimpPos sspan

          -- Tokens here, must introduce sub-spans with split, taking
          -- cognizance of start and end comments
          (startLoc,endLoc) = startEndLocIncComments' toks (tokStartPos,tokEndPos)

          -- (startToks,middleToks,endToks) = splitToks (startPos,endPos) toks
          (startToks,middleToks,endToks) = splitToks (startLoc,endLoc) toks
          subTree = [mkTreeFromTokens startToks,
                     mkTreeFromSpanTokens sspan middleToks,
                     mkTreeFromTokens endToks]

          (Entry _sspan _) = Z.label z

          z' = Z.setTree (Node (Entry _sspan []) subTree) z
          forest'' = Z.toTree z'



-- ---------------------------------------------------------------------

-- |Retrieve all the tokens at the leaves of the tree, in order
retrieveTokens :: Tree Entry -> [PosToken]
retrieveTokens forest = concat $ map (\t -> F.foldl accum [] t) [forest]
  where
    accum :: [PosToken] -> Entry -> [PosToken]
    accum acc (Entry _ toks) = acc ++ toks

-- ---------------------------------------------------------------------

-- |Add a new SrcSpan and Tokens after a given one in the token stream
-- and forest. This will be given a unique SrcSpan in return, which
-- specifically indexes into the forest.
addNewSrcSpanAndToksAfter ::
  Tree Entry -- ^The forest to update
  -> GHC.SrcSpan -- ^The new span comes after this one
  -> GHC.SrcSpan -- ^Existing span for the tokens
  -> [PosToken]  -- ^The new tokens belonging to the new SrcSpan
  -> (Tree Entry -- ^Updated forest with the new span
     , GHC.SrcSpan) -- ^Unique SrcSpan allocated in the forest to
                    -- identify this span in its position
addNewSrcSpanAndToksAfter forest oldSpan newSpan toks = (forest'',newSpan')
  where
    (forest',tree) = getSrcSpanFor forest (srcSpanToForestSpan oldSpan)

    (ghcl,c) = getGhcLoc newSpan
    (ForestLine v l) = ghcLineToForestLine ghcl
    newSpan' = insertForestLineInSrcSpan (ForestLine (v+1) l) newSpan

    prevToks = retrieveTokens tree
    toks' = reAlignToks prevToks toks

    newNode = Node (Entry (srcSpanToForestSpan newSpan') toks') []

    forest'' = insertNodeAfter tree newNode forest'

-- ---------------------------------------------------------------------

-- |Add new tokens after the given SrcSpan, constructing a new SrcSpan
-- in the process
addToksAfterSrcSpan ::
  Tree Entry -> GHC.SrcSpan -> [PosToken]
  -> (Tree Entry, GHC.SrcSpan)
addToksAfterSrcSpan forest oldSpan toks = (forest',newSpan')
  where
    (_,tree) = getSrcSpanFor forest (srcSpanToForestSpan oldSpan)
    prevToks = retrieveTokens tree

    toks'' = reAlignToks prevToks toks

    (startPos,endPos) = nonCommentSpan toks''

    newSpan = posToSrcSpan forest (startPos,endPos)
    (forest',newSpan') = addNewSrcSpanAndToksAfter forest oldSpan newSpan toks''
    -- (forest',newSpan') = (error $ "addToksAfterSrcSpan:(lineOffset,colOffset)=" ++ (show ((lineOffset,lineStart,tokenRow $ head toks,tokenRow $ head toks'',tokenRow newTokStart,colOffset))),oldSpan)

-- ---------------------------------------------------------------------

reAlignToks :: [PosToken] -> [PosToken] -> [PosToken]
reAlignToks prevToks toks = toks''
  where
    -- colStart = getIndentOffset prevToks (tokenPos $ glast "addToksAfterSrcSpan" prevToks)
    colStart  = tokenCol $ ghead "reAlignToks" $ dropWhile (\tok -> isComment tok || isEmpty tok) $ prevToks
    lineStart = (tokenRow (glast "reAlignToks" prevToks)) + 2

    newTokStart = ghead "reAlignToks" $ dropWhile (\tok -> isComment tok || isEmpty tok) $ toks
    -- lineOffset = lineStart - (tokenRow newTokStart)
    lineOffset = lineStart - (tokenRow $ ghead "reAlignToks" toks)
    colOffset  = colStart  - (tokenCol newTokStart)

    toks' = addOffsetToToks (lineOffset,colOffset) toks
    toks'' = toks' ++ [(newLinesToken 2 $ glast "reAlignToks" toks')]

-- ---------------------------------------------------------------------

-- |Extract the start and end position of a span, without any leading
-- or trailing comments
nonCommentSpan :: [PosToken] -> (SimpPos,SimpPos)
nonCommentSpan toks = (startPos,endPos)
  where
    startTok = ghead "nonCommentSpan" $ dropWhile (\tok -> isComment tok || isEmpty tok) $ toks
    endTok   = ghead "nonCommentSpan" $ dropWhile (\tok -> isComment tok || isEmpty tok) $ reverse toks

    startPos = tokenPos    startTok
    endPos   = tokenPosEnd endTok

-- ---------------------------------------------------------------------

-- |Convert a simple (start,end) position to a SrcSpan belonging to
-- the file in the tree
posToSrcSpan :: Tree Entry -> (SimpPos,SimpPos) -> GHC.SrcSpan
posToSrcSpan forest ((rs,cs),(re,ce)) = sspan
  where
    tok@(GHC.L l _,_) = ghead "posToSrcSpan"  $ retrieveTokens forest -- ++AZ++ Ouch, performance??
    sspan =  case l of
      GHC.RealSrcSpan ss ->
        let
          locStart = GHC.mkSrcLoc (GHC.srcSpanFile ss) rs cs
          locEnd   = GHC.mkSrcLoc (GHC.srcSpanFile ss) re ce
        in
          GHC.mkSrcSpan locStart locEnd
      _ -> error "posToSrcSpan: invalid SrcSpan in first tok"


-- ---------------------------------------------------------------------

-- |Insert a new node after the designated one in the tree
insertNodeAfter
  :: Tree Entry -> Tree Entry -> Tree Entry -> Tree Entry
insertNodeAfter oldNode newNode forest = forest'
  where
    -- (startPos,endPos) = treeStartEnd node
    zf = openZipperToNode oldNode $ Z.fromTree forest
    zp = gfromJust "insertNodeAfter" $ Z.parent zf
    tp = Z.tree zp

    -- now go through the children of the parent tree, and find the
    -- right spot for the new node
    (f,s) = break (\t -> treeStartEnd t == treeStartEnd oldNode) $ subForest tp
    (f',s') = (f++[ghead "insertNodeAfter" s],tail s) -- break does not include the found point
    subForest' = f' ++ [newNode] ++ s'

    tp' = tp { subForest = subForest' }
    forest' = Z.toTree $ Z.setTree tp' zp

-- ---------------------------------------------------------------------

-- |Open a zipper so that its focus is the given node
openZipperToNode
  :: Tree Entry
     -> Z.TreePos Z.Full Entry
     -> Z.TreePos Z.Full Entry
openZipperToNode node z
  = if treeStartEnd (Z.tree z) == treeStartEnd node
      then z
      else z'
        where
          -- go through all of the children to find the one that
          -- either is what we are looking for, or contains it
          childrenAsZ = map fromJust
                      $ iterate (\mz -> Z.next $ gfromJust "openZipperToNode" mz)
                      $ Z.firstChild z
          child = ghead "openZipperToNode" $ filter contains childrenAsZ
          -- focus of child either IS the node we care about, or contains it
          z' = if (treeStartEnd (Z.tree child)) == treeStartEnd node
                 then child
                 else openZipperToNode node child

          contains zn = (startPos <= nodeStart && endPos >= nodeEnd)
            where
              (startPos,endPos) = treeStartEnd $ Z.tree zn
              (nodeStart,nodeEnd) = treeStartEnd node

-- ---------------------------------------------------------------------

-- |Open a zipper so that its focus has the given SrcSpan in its subtree
openZipperToSpan
  :: ForestSpan
     -> Z.TreePos Z.Full Entry
     -> Z.TreePos Z.Full Entry
openZipperToSpan sspan z
  = if (treeStartEnd (Z.tree z) == sspan) || (Z.isLeaf z)
      then z
      else z'
        where
          -- go through all of the children to find the one that
          -- either is what we are looking for, or contains it

          childrenAsZ = go [] (Z.firstChild z)
          z' = case (filter contains childrenAsZ) of
            [] -> z -- Not in subtree, this is as good as it gets
            [x] -> -- exactly one, drill down
                   openZipperToSpan sspan x
            xs -> z -- Multiple, this is the spot

          contains zn = (startPos <= nodeStart && endPos >= nodeEnd)
            where
              (startPos,endPos) = treeStartEnd $ Z.tree zn
              (nodeStart,nodeEnd) = sspan


          go acc Nothing = acc
          go acc (Just zz) = go (acc ++ [zz]) (Z.next zz)

-- ---------------------------------------------------------------------

-- |Split a forest of trees into a (begin,middle,end) according to a
-- ForestSpan, such that no tokens are included in begin or end belonging
-- to the ForestSpan, and all of middle has some part of the ForestSpan
splitForestOnSpan :: Forest Entry -> ForestSpan
                  -> ([Tree Entry],[Tree Entry],[Tree Entry])
splitForestOnSpan forest sspan = (beginTrees,middleTrees,endTrees)
  where
    (spanStart,spanEnd) = sspan

    (beginTrees,rest)      = break (\t -> not $ inBeginTrees t) forest
    (middleTrees,endTrees) = break (\t ->       inEndTrees t) rest

    inBeginTrees tree = spanStart > treeEnd
      where
        (treeStart,treeEnd) = treeStartEnd tree

    inEndTrees tree = spanEnd <= treeStart
      where
        (treeStart,treeEnd) = treeStartEnd tree



{-

examples
  forest = [((1,1),(10,5)), ((100001,1),(10,5)), ((11,1),(14,3))]
  sspan = ((10,1),(11,5))

Should bring all of them
  Can we use starts only?

  Or, work from the front for begin, checking starts only, and back
  for end checking ends only

-}


-- ---------------------------------------------------------------------

-- | Look a SrcSpan up in the forest.
-- There are three possibilities
-- 1. It is not there
-- 2. It is there, exactly
-- 3. It is not there exactly, but is a sub-element of something that
--    is there. In this case return the smallest containing element.
-- This may be a list of trees, if the desired span crosses multiple
-- trees.
lookupSrcSpan :: Forest Entry -> ForestSpan -> [Tree Entry]
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
invariantOk :: Tree Entry -> Bool
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
--   4. The parent link for all sub-trees does exist, and actually points to the parent. 
-- NOTE: the tokens may extend before or after the SrcSpan, due to comments only
-- NOTE2: this will have to be revisited when edits to the tokens are made
invariant :: Tree Entry -> [String]
invariant forest = rsub
  where
    rsub = F.foldl checkOneTree [] [forest]

    checkOneTree :: [String] -> Tree Entry -> [String]
    checkOneTree acc tree = acc ++ r
      where
        r = checkNode [] tree

    checkNode :: [String] -> Tree Entry -> [String]
    checkNode acc node@(Node (Entry _sspan toks) sub) = acc ++ r ++ rinc ++ rsub
      where
        r = if (   emptyList toks && nonEmptyList sub) ||
               (nonEmptyList toks &&    emptyList sub)
              then []
              else ["FAIL: exactly one of toks or subforest must be empty: " ++ (prettyshow node)]
        rsub = foldl' checkNode [] sub

        rinc = checkInclusion node

    -- |Check invariant 2, assuming 1 ok
    checkInclusion      (Node _                    []) = []
    checkInclusion node@(Node (Entry sspan toks)  sub) = rs ++ rseq
      where
        (start,end) = treeStartEnd node
        subs = map treeStartEnd sub
        (sstart, _) = ghead "invariant" subs
        (_, send) = last subs

        rs = if (start == sstart) && (end == send)
               then []
               else ["FAIL: subForest start and end does not match entry: " ++ (prettyshow node)]

        rseq = checkSequence node subs

        checkSequence :: Tree Entry -> [ForestSpan] -> [String]
        checkSequence _ [] = []
        checkSequence _ [_x] = []
        checkSequence node ((s1,e1):s@(s2,e2):ss)
          = r ++ checkSequence node (s:ss)
          where
            -- r = if e1 <= s2
            r = if before e1 s2
                 then []
                 else ["FAIL: subForest not in order: " ++
                        show e1 ++ " not < " ++ show s2 ++
                        ":" ++ prettyshow node]

            before (ForestLine ve er,ec) (ForestLine vs sr,sc)
              = case (ve /= 0, vs /= 0) of
                 (False, False) -> (er,ec) <= (sr,sc) -- e.g. (10,3) <= (11,5)
                 (False, True)  -> True               -- e.g. (10,3) <= (100011,5)
                 (True, False)  -> True               -- e.g. (100010,3) <= (11,5)
                 (True, True)   -> if vs < ve         -- both have version, lowest wins 
                                    then False
                                    else True




-- ---------------------------------------------------------------------

-- |Get the start and end position of a Tree
-- treeStartEnd :: Tree Entry -> (SimpPos,SimpPos)
-- treeStartEnd (Node (Entry sspan _) _) = (getGhcLoc sspan,getGhcLocEnd sspan)
treeStartEnd :: Tree Entry -> ForestSpan
treeStartEnd (Node (Entry sspan _) _) = sspan

-- |Get the start and end position of a SrcSpan
-- spanStartEnd :: GHC.SrcSpan -> (SimpPos,SimpPos)
-- spanStartEnd sspan = (getGhcLoc sspan,getGhcLocEnd sspan)
spanStartEnd :: GHC.SrcSpan -> ForestSpan
spanStartEnd sspan = ((ghcLineToForestLine sr,sc),(ghcLineToForestLine er,ec))
  where
    ((sr,sc),(er,ec)) = (getGhcLoc sspan,getGhcLocEnd sspan)

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
drawEntry (Node (Entry sspan _toks) ts0) = (showForestSpan sspan) : drawSubTrees ts0
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
prettyshow (Node (Entry sspan toks) sub)
  = "Node (Entry " ++ (showForestSpan sspan) ++ " "
     ++ (prettyToks toks) ++ ") "
     ++ show (map prettyshow  sub)

prettyToks :: [PosToken] -> String
prettyToks [] = "[]"
prettyToks toks@[_x] = showToks toks
prettyToks toks@[_t1,_t2] = showToks toks
prettyToks toks = showToks [ghead "prettyToks" toks] ++ ".." ++ showToks [last toks]

-- ---------------------------------------------------------------------

-- |Make a tree representing a particular set of tokens
mkTreeFromTokens :: [PosToken] -> Tree Entry
mkTreeFromTokens [] = Node (Entry nullSpan []) []
mkTreeFromTokens toks = Node (Entry sspan toks) []
  where
   startLoc = tokenPos $ ghead "mkTreeFromTokens" toks
   endLoc   = tokenPosEnd $ last toks -- SrcSpans count from start of token, not end
   -- sspan    = GHC.RealSrcSpan $ GHC.mkRealSrcSpan startLoc endLoc
   (startLoc',endLoc') = nonCommentSpan toks
   sspan    = simpPosToForestSpan (startLoc',endLoc')


-- ---------------------------------------------------------------------

-- |Make a tree representing a particular set of tokens
mkTreeFromSpanTokens :: ForestSpan -> [PosToken] -> Tree Entry
mkTreeFromSpanTokens sspan toks = Node (Entry sspan toks) []

-- ---------------------------------------------------------------------

ghcSpanStartEnd sspan = (getGhcLoc sspan,getGhcLocEnd sspan)

-- ---------------------------------------------------------------------

-- |Synchronise a located AST fragment to use a newly created SrcSpan
-- in the token tree.
syncAST :: (SYB.Data t)
  => GHC.Located t -- ^The AST (or fragment)
  -> GHC.SrcSpan   -- ^The SrcSpan created in the Tree Entry
  -> Tree Entry    -- ^Existing token tree
  -> (GHC.Located t, Tree Entry) -- ^Updated AST and tokens
syncAST ast@(GHC.L l t) sspan forest = (ast',forest')
  where
    ast' = (GHC.L sspan t)
    forest' = forest

-- ---------------------------------------------------------------------

showSrcSpan :: GHC.SrcSpan -> String
showSrcSpan sspan = show (getGhcLoc sspan, (r,c))
  where
    (r,c) = getGhcLocEnd sspan

-- ---------------------------------------------------------------------
-- Next section is stuff brought over from LocUtils, to break cycles

showToks :: [PosToken] -> String
showToks toks = show $ map (\(t@(GHC.L _ tok),s) ->
                 ((getLocatedStart t, getLocatedEnd t),tok,s)) toks

instance Show (GHC.GenLocated GHC.SrcSpan GHC.Token) where
  show t@(GHC.L l tok) = show ((getLocatedStart t, getLocatedEnd t),tok)


-- ----------------------------------------------------------------------

-- |Get around lack of instance Eq when simply testing for empty list
emptyList [] = True
emptyList _  = False

nonEmptyList [] = False
nonEmptyList _  = True

-- ---------------------------------------------------------------------

getGhcLoc :: GHC.SrcSpan -> (Int, Int)
getGhcLoc (GHC.RealSrcSpan ss)  = (GHC.srcSpanStartLine ss, GHC.srcSpanStartCol ss)
getGhcLoc (GHC.UnhelpfulSpan _) = (-1,-1)

getGhcLocEnd :: GHC.SrcSpan -> (Int, Int)
getGhcLocEnd (GHC.RealSrcSpan ss)  = (GHC.srcSpanEndLine ss, GHC.srcSpanEndCol ss)
getGhcLocEnd (GHC.UnhelpfulSpan _) = (-1,-1)

getLocatedStart :: GHC.GenLocated GHC.SrcSpan t -> (Int, Int)
getLocatedStart (GHC.L l _) = getGhcLoc l

getLocatedEnd :: GHC.GenLocated GHC.SrcSpan t -> (Int, Int)
getLocatedEnd (GHC.L l _) = getGhcLocEnd l

-- ---------------------------------------------------------------------

-- | Get the start&end location of t in the token stream, then extend
-- the start and end location to cover the preceding and following
-- comments.
--
-- Note: what about trailing comment with interving white space, where
-- comment is "closer" to next non-comment token?
startEndLocIncComments::(SYB.Data t) => [PosToken] -> t -> (SimpPos,SimpPos)
startEndLocIncComments toks t = startEndLocIncComments' toks (getStartEndLoc t)


startEndLocIncComments' :: [PosToken] -> (SimpPos,SimpPos) -> (SimpPos,SimpPos)
startEndLocIncComments' toks (startLoc,endLoc) =
  let
    (begin,middle,end) = splitToks (startLoc,endLoc) toks

    lead = reverse $ takeWhile (\tok -> isComment tok || isEmpty tok) $ reverse begin
    lead' = if ((nonEmptyList lead) && (isEmpty $ head lead)) then (tail lead) else lead

    leadLine = if (nonEmptyList lead')
                 then reverse $ takeWhile (\tok -> tokenRow (head lead') <= tokenRow tok) $ reverse begin
                 else []

    lead'' = if (nonEmptyList lead' && nonEmptyList leadLine && not (isComment $ head leadLine))
               then dropWhile (\tok -> tokenRow tok == tokenRow (ghead "startEndLocIncComments 1" leadLine)) lead'
               else lead'

    -- trail = takeWhile (\tok -> isComment tok || isEmpty tok) $ end
    (trail,trailrest) = break (\tok -> not (isComment tok || isEmpty tok)) end

    -- If whitespace line gap between then end of the middle and the
    -- start of the tail is bigger than between the end of the trail
    -- and the start of the trailrest, then let the trail belong to
    -- the subsequent decl.

    -- trail' = if ((nonEmptyList trail) && (isEmpty $ last trail)) then (init trail) else trail

    trail'' = filter (\tok -> not $ isEmpty tok) trail

    endDiff = if (emptyList trailrest) || (emptyList trail'')
            then 1000
            else (tokenRow $ ghead "startEndLocIncComments 2" trailrest) - (tokenRow $ last trail'')

    startDiff = if (emptyList middle) || (emptyList trail'')
            then 1000
            else (tokenRow $ ghead "startEndLocIncComments 3" trail) - (tokenRow $ last middle)

    trail' = if (startDiff <= endDiff)
      then if ((nonEmptyList trail) && (isEmpty $ last trail))
              then (init trail) else trail
      else []

    middle' = lead'' ++ middle ++ trail'
  in
    -- error $ "startEndLocIncComments: (startDiff,endDiff)=" ++ (show (startDiff,endDiff)) -- ++AZ++
    -- error ( "startEndLocIncComments: (leadLine)=" ++ (show $ tokenRow (head lead')) ++  (showToks leadLine) ) -- ++AZ++
    if (emptyList middle')
      -- then error $ "startEndLocIncComments: (startLoc,endLoc) toks =" ++ (show (startLoc,endLoc)) ++ "," ++ (showToks toks)
      then ((0,0),(0,0))
      else ((tokenPos $ ghead "startEndLocIncComments 4" middle'),(tokenPosEnd $ last middle'))

{- ++AZ++ re-doing this ...
-- ts1 : lead in toks
-- ts2 : start of t to end of file
-- ts11 : reversed leading blank lines of t
-- ts12 : front of file to start of ts11

-- toks11 : front of file to start of blank lines before t
-- toks12 : blank lines, t, to end of file
-- toks12' : just the blank lines

-- ITsemi with ""
-- ITlineComment
-- isComment

  =let (startLoc,endLoc) = getStartEndLoc t
       (toks11,toks12)= let (ts1,ts2)    = break (\tok->tokenPos tok == startLoc) toks
                            -- (ts11, ts12) = break hasNewLn (reverse ts1)
                            (ts11, ts12) = break (\tok->tokenRow tok /= fst startLoc) (reverse ts1)
                        in (reverse ts12, reverse ts11++ts2)
       toks12'=takeWhile (\tok->tokenPos tok /=startLoc) toks12
       startLoc'=
         if all isWhite toks12'
           then  -- group the toks1 according to lines in a reverse order.
                 let  groupedToks = reverse $ groupTokensByLine toks11
                      -- empty lines right before t
                      -- emptyLns=takeWhile (all (\t->isWhiteSpace t || isNewLn t )) groupedToks
                      emptyLns=[] -- ++AZ++
                      lastComment=if length emptyLns <= 1  -- get the comment if there is any
                                    then takeWhile (all isWhite) $ takeWhile (any isComment) $ groupedToks -- dropWhile
                                             --  (all (\t->isWhiteSpace t || isNewLn t)) groupedToks
                                    else [] -- no comment
                      toks1'=if (not (emptyList lastComment)) then concat $ reverse (emptyLns ++ lastComment)
                                                 else []
                 in if (emptyList toks1')
                       then if (not (emptyList toks12'))
                              then (tokenPos (ghead "startEndLocIncComments"  toks12'))  --there is no comment before t
                              else startLoc
                       --there is a comment before t
                       else tokenPos (ghead "startEndLocIncComments"  toks1')
           else startLoc
       -- tokens after t
       toks2 = gtail "startEndLocIncComments1" $ dropWhile (\tok->(tokenPos tok) < endLoc) toks
       -- toks21 are those tokens that are in the same line with the last line of t
       (toks21,_tok22)= let (ts11, ts12) = break hasNewLn toks2
                       in (ts11 ++ if (emptyList ts12) then [] else [ghead "startEndLocIncComments" ts12],
                                                             gtail "startEndLocIncComments2" ts12)
    in if (emptyList toks21) then (startLoc',endLoc)  -- no following comments.
        else if all (\t->isWhite t {- || endsWithNewLn t -}) toks21 --get the following white tokens in the same
                                                              --line of the last token of t
               then (startLoc', tokenPos (last toks21))
               else (startLoc', endLoc)
-- ++AZ++ redoing end -}


{- ++original
{-get the start&end location of t in the token stream, then extend the start and end location to
  cover the preceding and folllowing comments.
-}
startEndLocIncComments::(Term t, StartEndLoc t,Printable t)=>[PosToken]->t->(SimpPos,SimpPos)
startEndLocIncComments toks t
  =let (startLoc,endLoc)=getStartEndLoc toks t
       (toks11,toks12)= let (ts1,ts2) = break (\t->tokenPos t == startLoc) toks
                            (ts11, ts12) = break hasNewLn (reverse ts1)
                        in (reverse ts12, reverse ts11++ts2)
       toks12'=takeWhile (\t->tokenPos t /=startLoc) toks12
       startLoc'=
         if all isWhite  toks12'
           then  -- group the toks1 according to lines in a reverse order.
                 let  groupedToks=reverse $ groupTokensByLine toks11
                      -- empty lines right before t
                      emptyLns=takeWhile (all (\t->isWhiteSpace t || isNewLn t )) groupedToks
                      lastComment=if length emptyLns <=1  -- get the comment if there is any
                                    then takeWhile (all isWhite) $ takeWhile (any isComment) $ dropWhile
                                               (all (\t->isWhiteSpace t || isNewLn t)) groupedToks
                                    else [] -- no comment
                      toks1'=if lastComment /=[] then concat $ reverse (emptyLns ++ lastComment)
                                                 else []
                 in if toks1'==[]
                       then if toks12'/=[]
                              then (tokenPos (ghead "startEndLocIncComments"  toks12'))  --there is no comment before t
                              else startLoc
                       --there is a comment before t
                       else tokenPos (ghead "startEndLocIncComments"  toks1')
           else startLoc
       -- tokens after t
       toks2=gtail "startEndLocIncComments1"  $ dropWhile (\t->tokenPos t/=endLoc) toks
       -- toks21 are those tokens that are in the same line with the last line of t
       (toks21,tok22)= let (ts11, ts12) = break hasNewLn toks2
                       in (ts11 ++ if ts12==[] then [] else [ghead "startEndLocIncComments" ts12],
                                                             gtail "startEndLocIncComments2" ts12)
    in if toks21==[] then (startLoc',endLoc)  -- no following comments.
        else if all (\t->isWhite t || endsWithNewLn t) toks21 --get the following white tokens in the same
                                                              --line of the last token of t
               then (startLoc', tokenPos (last toks21))
               else (startLoc', endLoc)
-}

-- ---------------------------------------------------------------------

-- |Add a constant line and column offset to a span of tokens
addOffsetToToks :: SimpPos -> [PosToken] -> [PosToken]
addOffsetToToks (r,c) toks = map (\t -> increaseSrcSpan (r,c) t) toks


increaseSrcSpan :: SimpPos -> PosToken -> PosToken
increaseSrcSpan (lineAmount,colAmount) posToken@(lt@(GHC.L l t), s) = (GHC.L newL t, s) where
        filename = fileNameFromTok posToken
        newL = GHC.mkSrcSpan (GHC.mkSrcLoc filename startLine startCol) (GHC.mkSrcLoc filename endLine endCol)
        (startLine, startCol) = add1 $ getLocatedStart lt
        (endLine, endCol)     = add1 $ getLocatedEnd   lt

        add1 :: (Int, Int) -> (Int, Int)
        add1 (x,y) = (x+lineAmount,y+colAmount)

-- ---------------------------------------------------------------------

-- isComment (t,(_,s))          = t==Comment || t ==NestedComment
isComment ((GHC.L _ (GHC.ITdocCommentNext _)),s)  = True
isComment ((GHC.L _ (GHC.ITdocCommentPrev _)),s)  = True
isComment ((GHC.L _ (GHC.ITdocCommentNamed _)),s) = True
isComment ((GHC.L _ (GHC.ITdocSection _ _)),s)    = True
isComment ((GHC.L _ (GHC.ITdocOptions _)),s)      = True
isComment ((GHC.L _ (GHC.ITdocOptionsOld _)),s)   = True
isComment ((GHC.L _ (GHC.ITlineComment _)),s)     = True
isComment ((GHC.L _ (GHC.ITblockComment _)),s)    = True
isComment ((GHC.L _ _),s)                         = False

isEmpty ((GHC.L _ (GHC.ITsemi)), "") = True
isEmpty _                           = False

--Some functions for fetching a specific field of a token
tokenCol (GHC.L l _,_) = c where (_,c) = getGhcLoc l

tokenRow (GHC.L l _,_) = r where (r,_) = getGhcLoc l

tokenPos :: (GHC.GenLocated GHC.SrcSpan t1, t) -> SimpPos
tokenPos (GHC.L l _,_)     = getGhcLoc l

tokenPosEnd :: (GHC.GenLocated GHC.SrcSpan t1, t) -> SimpPos
tokenPosEnd (GHC.L l _,_)     = getGhcLocEnd l

tokenCon (_,s)     = s

-- ---------------------------------------------------------------------

realSrcLocFromTok :: PosToken -> GHC.RealSrcLoc
realSrcLocFromTok (GHC.L (GHC.RealSrcSpan srcspan) _,_) = GHC.realSrcSpanStart srcspan
realSrcLocFromTok (GHC.L _ _,_) = GHC.mkRealSrcLoc (GHC.mkFastString "") 1 1

realSrcLocEndTok :: PosToken -> GHC.RealSrcLoc
realSrcLocEndTok (GHC.L (GHC.RealSrcSpan srcspan) _,_) = GHC.realSrcSpanEnd srcspan
realSrcLocEndTok (GHC.L _ _,_) = GHC.mkRealSrcLoc (GHC.mkFastString "") 1 1

fileNameFromTok :: PosToken -> GHC.FastString
fileNameFromTok (GHC.L (GHC.RealSrcSpan srcspan) _,_) = GHC.srcSpanFile srcspan
fileNameFromTok (GHC.L _ _,_) = GHC.mkFastString "f"

-- ---------------------------------------------------------------------

getStartEndLoc :: (SYB.Data t) => t -> (SimpPos,SimpPos)
getStartEndLoc t =
  -- error $ "getStartEndLoc:" ++ (SYB.showData SYB.Renamer 0 t)
  let
    ss = getSrcSpan t
  in
    case ss of
      Just l -> startEndLocGhc (GHC.L l ss)
      Nothing -> ((0,0),(0,0))

-- ---------------------------------------------------------------------

-- | Get the first SrcSpan found, in top down traversal
getSrcSpan::(SYB.Data t) => t -> Maybe GHC.SrcSpan
getSrcSpan t = res t
  where
    res = somethingStaged SYB.Renamer Nothing
            (Nothing
                    `SYB.mkQ` bind
                    `SYB.extQ` sig
                    `SYB.extQ` pnt
                    `SYB.extQ` sn
                    `SYB.extQ` literalInExp
                    `SYB.extQ` literalInPat
                    `SYB.extQ` importDecl
                    `SYB.extQ` ty
            )

    bind :: GHC.GenLocated GHC.SrcSpan (GHC.HsBind GHC.Name) -> Maybe GHC.SrcSpan
    bind (GHC.L l _)              = Just l

    sig :: (GHC.LSig GHC.Name) -> Maybe GHC.SrcSpan
    sig (GHC.L l _)              = Just l

    ty :: (GHC.LHsType GHC.Name) -> Maybe GHC.SrcSpan
    ty (GHC.L l _) = Just l

    pnt :: GHC.GenLocated GHC.SrcSpan GHC.Name -> Maybe GHC.SrcSpan
    pnt (GHC.L l _)              = Just l

    sn :: GHC.HsModule GHC.RdrName -> Maybe GHC.SrcSpan
    sn (GHC.HsModule (Just (GHC.L l _)) _ _ _ _ _) = Just l
    sn _ = Nothing

    literalInExp :: GHC.LHsExpr GHC.Name -> Maybe GHC.SrcSpan
    literalInExp (GHC.L l _) = Just l

    literalInPat :: GHC.LPat GHC.Name -> Maybe GHC.SrcSpan
    literalInPat (GHC.L l _) = Just l

    importDecl :: GHC.LImportDecl GHC.Name -> Maybe GHC.SrcSpan
    importDecl (GHC.L l _) = Just l

-- ---------------------------------------------------------------------

-- | Split the token stream into three parts: the tokens before the
-- startPos, the tokens between startPos and endPos, and the tokens
-- after endPos.
-- Note: The startPos and endPos refer to the startPos of a token only.
--       So a single token will have the same startPos and endPos
splitToks::(SimpPos, SimpPos)->[PosToken]->([PosToken],[PosToken],[PosToken])
splitToks (startPos, endPos) toks =
  let (toks1,toks2)   = break (\t -> tokenPos t >= startPos) toks
      (toks21,toks22) = break (\t -> tokenPos t >  endPos) toks2
  in
    (toks1,toks21,toks22)

{- ++AZ++ old, comlicated
   = -- trace ("splitToks" ++ (show (startPos,endPos)) ++ (showToks toks))
   (if (startPos, endPos) == (simpPos0, simpPos0)
       then error "Invalid token stream position!"
       else let startPos'= if startPos==simpPos0 then endPos   else startPos
                endPos'  = if endPos == simpPos0 then startPos else endPos
                (toks1, toks2) = break (\t -> tokenPos t == startPos') toks
                (toks21, toks22) = correctBreak startPos' endPos' toks1 toks2 toks

            -- in error ((showToks toks1) ++ "\n" ++ (showToks toks21) ++ "\n" ++ (showToks toks22))
            in      (toks1, toks21 {-++[ghead "splitToks" toks22]-}, toks22) )
  where
    correctBreak startPos' endPos' toks1 toks2 toks
      = if length toks2 == 0
           then let (toks1', toks2) = break (\t -> tokenPos t >= startPos') toks 
                in break (\t -> tokenPos t >= endPos') (drop 2 toks1++toks2)
           else (break (\t -> tokenPos t > endPos') toks2)
-}

-- ---------------------------------------------------------------------

startEndLocGhc :: GHC.Located b -> (SimpPos,SimpPos)
startEndLocGhc t@(GHC.L l _) =
  case l of
    (GHC.RealSrcSpan ss) ->
      ((GHC.srcSpanStartLine ss,GHC.srcSpanStartCol ss),
       (GHC.srcSpanEndLine ss,GHC.srcSpanEndCol ss))
    (GHC.UnhelpfulSpan _) -> ((0,0),(0,0))

-- | Get the indent of the line before, taking into account in-line
-- where, let, in and do tokens
getIndentOffset :: [PosToken] -> SimpPos -> Int
getIndentOffset [] _pos    = 1
getIndentOffset toks (0,0) = 1
getIndentOffset toks pos
  = let (ts1, ts2) = break (\t->tokenPos t >= pos) toks
    in if (emptyList ts2)
         then error "HaRe error: position does not exist in the token stream!"
         else let (sl,_) = splitOnNewLn $ reverse ts1
                -- sl is the reversed tokens of the previous line
                  sls = filter (\t -> tokenLen t > 0) sl
                  firstTok = (glast "getIndentOffset" sls)
              in if startLayout firstTok
                  then if (length sls > 1)
                          then tokenOffset (last $ init sls)
                          else 4 + tokenOffset firstTok
                  else tokenOffset firstTok

      where
        tokenOffset t = (tokenCol t) - 1

        startLayout ((GHC.L _ (GHC.ITdo)),_)    = True
        startLayout ((GHC.L _ (GHC.ITin)),_)    = True
        startLayout ((GHC.L _ (GHC.ITlet)),_)   = True
        startLayout ((GHC.L _ (GHC.ITwhere)),_) = True
        startLayout _  = False

-- ---------------------------------------------------------------------

splitOnNewLn :: [PosToken] -> ([PosToken],[PosToken])
splitOnNewLn xs = go [] xs
  -- ++AZ++ : TODO: is this simpler? : (toks1,toks2)=break (\x' -> tokenRow x /= tokenRow x') rtoks

  where
    go [] [] = ([],[])
    go ss [] = (ss,[])
    go [] xs = go [head xs] (tail xs)
    go ss xs
      | onSameLn (glast "splitOnNewLn" ss) (head xs) = go (ss ++ [head xs]) (tail xs)
      | otherwise = (ss,xs)

-- ---------------------------------------------------------------------

tokenLen (_,s)     = length s   --check this again! need to handle the tab key.
{-
lengthOfToks::[PosToken]->Int
lengthOfToks=length.(concatMap tokenCon)
-}

-- ---------------------------------------------------------------------

onSameLn :: PosToken -> PosToken -> Bool
onSameLn (GHC.L l1 _,_) (GHC.L l2 _,_) = r1 == r2
  where
    (r1,_) = getGhcLoc l1
    (r2,_) = getGhcLoc l2

-- ---------------------------------------------------------------------

newLnToken :: PosToken -> PosToken
newLnToken tok = newLinesToken 1 tok

-- ---------------------------------------------------------------------

newLinesToken :: Int -> PosToken -> PosToken
newLinesToken jump (GHC.L l _,_) = (GHC.L l' GHC.ITvocurly,"")
  where
   l' =  case l of
     GHC.RealSrcSpan ss ->
       let
         loc = GHC.mkSrcLoc (GHC.srcSpanFile ss) (jump + GHC.srcSpanEndLine ss) 1
       in
         GHC.mkSrcSpan loc loc
     _ -> l

-- ---------------------------------------------------------------------

-- EOF
