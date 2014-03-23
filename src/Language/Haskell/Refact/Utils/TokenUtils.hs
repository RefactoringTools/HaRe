{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE StandaloneDeriving   #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

-- |
--
-- This module contains an API to manage a token stream.
--
-- This API is used internally by MonadFunctions and the other utility
-- modules, it should probably never be used directly in a refactoring.

module Language.Haskell.Refact.Utils.TokenUtils(
       -- * Creating
        initTokenCache
       , initTokenCacheLayout
       , mkTreeFromTokens
       , mkTreeFromSpanTokens

       -- * Operations at 'TokenCache' level
       , putToksInCache
       , putDeclToksInCache
       , replaceTokenInCache
       , removeToksFromCache
       , getTreeFromCache
       , replaceTreeInCache
       , syncAstToLatestCache

       -- * Operations at 'Tree' 'Entry' level
       , getTokensFor
       , getTokensForNoIntros
       , getTokensBefore
       , replaceTokenForSrcSpan
       , updateTokensForSrcSpan
       , insertSrcSpan
       , removeSrcSpan
       , getSrcSpanFor
       , getSrcSpanForDeep
       , addNewSrcSpanAndToksAfter
       , addToksAfterSrcSpan
       , addDeclToksAfterSrcSpan
       , syncAST
       , indentDeclToks
       , Positioning(..)

       -- * Retrieving tokens
       , retrieveTokensFinal
       -- , retrieveTokensPpr
       -- , renderPpr
       , adjustLinesForDeleted
       , retrieveTokensInterim
       , retrieveTokens' -- temporary for debug

       -- * Token Tree Selection
       , treeIdFromForestSpan

       -- * Token marking and re-alignment
       , reAlignMarked

       -- * Utility
       , posToSrcSpan
       , posToSrcSpanTok
       , fileNameFromTok
       , treeStartEnd
       , spanStartEnd
       , sf
       , fs
       , forestSpanFromEntry
       , combineSpans

       -- * A token stream with last tokens first, and functions to manipulate it
       , ReversedToks(..)
       , reverseToks
       , unReverseToks
       , reversedToks

       -- * Internal, for testing
       , placeToksForSpan
       , limitPrevToks
       , reIndentToks
       , reAlignOneLine
       , reAlignToks
       , splitForestOnSpan
       , spanContains
       , containsStart, containsMiddle, containsEnd
       , doSplitTree, splitSubtree, splitSubToks
       , nonCommentSpan
       -- , lookupSrcSpan
       , invariantOk
       , invariant
       , showForest
       , showTree
       , showSrcSpan
       , showSrcSpanF
       , ghcSpanStartEnd
       , insertNodeAfter
       , retrievePrevLineToks
       , getTreeSpansAsList
       , openZipperToNode
       , openZipperToNodeDeep
       , openZipperToSpan
       , openZipperToSpanDeep
       , openZipperToSpanAdded
       , openZipperToSpanOrig
       , forestSpanToSimpPos
       , forestSpanToGhcPos

       , ghcLineToForestLine
       , stripForestLineFromGhc
       , forestLineToGhcLine
       , forestSpanToSrcSpan
       , forestPosVersionSet
       , forestPosVersionNotSet
       , forestSpanLenChanged
       , forestSpanVersions
       , forestSpanVersionSet
       , forestSpanVersionNotSet
       , insertForestLineInSrcSpan
       , insertLenChangedInSrcSpan
       , insertVersionsInSrcSpan
       , srcSpanToForestSpan
       , nullSpan,nullPos
       , simpPosToForestSpan
       , srcPosToSimpPos
       , showForestSpan
       , deleteGapsToks
       -- , deleteGapsToks'
       , calcEndGap
       , stripForestLines

       -- * Based on Data.Tree
       , drawTreeEntry
       , drawTokenCache
       , drawTokenCacheDetailed
       , drawForestEntry
       , drawEntry
       , drawTreeCompact

       ) where

import qualified FastString    as GHC
import qualified GHC           as GHC
import qualified SrcLoc        as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import qualified Data.Foldable as F

import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.LayoutTypes
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn

import Data.Bits
import Data.List
import Data.Tree
import qualified Data.Map as Map
import qualified Data.Tree.Zipper as Z


-- import Debug.Trace
-- debug = flip trace

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
{-

NOTE: Token stream has zero-length string tokens in it,

  ITvocurly
  ITsemi
  ITvccurly

These are inserted by GHC at points where a '{', ';' or '}' belongs in
the code, were it not implied by layout.

This can perhaps be used to choose appropriate token boundaries.

-}


deriving instance Show         Entry

instance Ord LayoutTree where
  compare (Node a _) (Node b _) = compare (forestSpanFromEntry a) (forestSpanFromEntry b)

instance Eq Entry where
  (Entry fs1 lay1 toks1) == (Entry fs2 lay2 toks2)
    = fs1 == fs2 && lay1 == lay2
   && (show toks1) == (show toks2)

  (Deleted fs1 pg1 lay1) == (Deleted fs2 pg2 lay2)
    = fs1 == fs2 && pg1 == pg2 && lay1 == lay2

  (==) _ _ = False

-- ---------------------------------------------------------------------

-- |Keep track of when tokens are reversed, to avoid confusion
data ReversedToks = RT [PosToken]
                    deriving (Show)

reverseToks :: [PosToken] -> ReversedToks
reverseToks toks = RT $ reverse toks

unReverseToks :: ReversedToks -> [PosToken]
unReverseToks (RT toks) = reverse toks

reversedToks :: ReversedToks -> [PosToken]
reversedToks (RT toks) = toks


-- |How new SrcSpans should be inserted in the Token tree, relative to
-- the prior span
data Positioning = PlaceAdjacent -- ^Only a single space between the
                   -- end of the prior span and the new one
                 | PlaceAbsolute !Int !Int -- ^Start at the specified
                   -- line and col
                 | PlaceAbsCol !Int !Int !Int -- ^Line offset and
                                              -- absolute Col. Mainly
                                              -- for forcing start at
                                              -- left margin, number
                                              -- of lines to add at
                                              -- the end
                 | PlaceOffset !Int !Int !Int -- ^Line and Col offset for
                   -- start, num lines to add at the end
                   -- relative to the indent level of the prior span
                 | PlaceIndent !Int !Int !Int -- ^Line and Col offset for
                   -- start, num lines to add at the end
                   -- relative to the indent level of the prior line
                 deriving (Show)

-- ---------------------------------------------------------------------

{-
-- ++AZ++ TODO: will we actually need these?
-- | Operations on the structure
data Operations = OpAdded Entry          -- ^The entry that was added
                | OpRemoved Entry        -- ^The Entry that was removed
                | OpReplaced Entry Entry -- ^The first is old, second is new Entry

-}

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
-- 4. It can keep track of tokens that have been removed from the main
--    AST, which can be edited outside of it and then inserted again
--
-- This is achieved by adding two fields to the SrcSpan, one to
-- indicate which AST fragment it is in, and the other to indicate its
-- insert relationship, encoded as 0 for the original, 1 for the
-- first, 2 for the second and so on.
--
-- This field is converted to and from the original line by being
-- multiplied by a very large number and added to the original.
--
-- The guaranteed max value in Haskell for an Int is 2^29 - 1.
-- This evaluates to 536,870,911,or 536.8 million.
--
-- However, as pointed out on #haskell, the GHC compiler (which this
-- implemtation explicitly targets) provides the full 32 bits (at
-- least, can be 64), so we have
--   maxBound :: Int = 2,147,483,647
--
-- Schema:max pos value is 0x7fffffff (31 bits)
-- 1 bit for LenChanged
-- 5 bits for tree    : 32 values
-- 5 bits for version : 32 values
-- 20 bits for line number: 1048576 values

forestLineMask,forestVersionMask,forestTreeMask,forestLenChangedMask :: Int
forestLineMask =          0xfffff -- bottom 20 bits
forestVersionMask    =  0x1f00000 -- next 5 bits
forestTreeMask       = 0x3e000000 -- next 5 bits
forestLenChangedMask = 0x40000000 -- top (non-sign) bit

forestVersionShift :: Int
forestVersionShift = 20

forestTreeShift :: Int
forestTreeShift    = 25

{-
This has been moved to TokenUtilsTypes

data ForestLine = ForestLine
                  { flSpanLengthChanged :: Bool -- ^The length of the
                                                -- span may have
                                                -- changed due to
                                                -- updated tokens.
                  , flTreeSelector :: Int
                  , flInsertVersion :: Int
                  , flLine :: Int
                  } deriving (Eq)
-}

-- | Extract an encoded ForestLine from a GHC line
ghcLineToForestLine :: Int -> ForestLine
ghcLineToForestLine l = ForestLine ch tr v l'
  where
    l' =  l .&. forestLineMask
    v  = shiftR (l .&. forestVersionMask) forestVersionShift
    tr = shiftR (l .&. forestTreeMask)    forestTreeShift
    ch = (l .&. forestLenChangedMask) /= 0

-- TODO: check that the components are in range
forestLineToGhcLine :: ForestLine -> Int
forestLineToGhcLine fl =  (if (flSpanLengthChanged fl) then forestLenChangedMask else 0)
                        + (shiftL (flTreeSelector  fl) forestTreeShift)
                        + (shiftL (flInsertVersion fl) forestVersionShift)
                        + (flLine fl)

forestSpanToSrcSpan :: ForestSpan -> GHC.SrcSpan
forestSpanToSrcSpan ((fls,sc),(fle,ec)) = sspan
  where
    lineStart = forestLineToGhcLine fls
    lineEnd   = forestLineToGhcLine fle
    locStart = GHC.mkSrcLoc (GHC.mkFastString "foo") lineStart sc
    locEnd   = GHC.mkSrcLoc (GHC.mkFastString "foo") lineEnd   ec
    sspan = GHC.mkSrcSpan locStart locEnd


instance Ord ForestLine where
  -- Use line as the primary comparison, but break any ties with the
  -- version
  -- Tree is ignored, as it is only a marker on the topmost element
  -- Ignore sizeChanged flag, it will only be relevant in the
  -- invariant check
  compare (ForestLine _sc1 _ v1 l1) (ForestLine _sc2 _ v2 l2) =
         if (l1 == l2)
           then compare v1 v2
           else compare l1 l2

-- |Gets the version numbers
forestSpanVersions :: ForestSpan -> (Int,Int)
forestSpanVersions ((ForestLine _ _ sv _,_),(ForestLine _ _ ev _,_)) = (sv,ev)

-- |Gets the AST tree numbers
forestSpanAstVersions :: ForestSpan -> (Int,Int)
forestSpanAstVersions ((ForestLine _ trs _ _,_),(ForestLine _ tre _ _,_)) = (trs,tre)

-- |Gets the SpanLengthChanged flags
forestSpanLenChangedFlags :: ForestSpan -> (Bool,Bool)
forestSpanLenChangedFlags ((ForestLine chs _ _ _,_),(ForestLine che _ _ _,_)) = (chs,che)

-- |Checks if the version is non-zero in either position
forestSpanVersionSet :: ForestSpan -> Bool
forestSpanVersionSet ((ForestLine _ _ sv _,_),(ForestLine _ _ ev _,_)) = sv /= 0 || ev /= 0

-- |Checks if the version is zero in both positions
forestSpanVersionNotSet :: ForestSpan -> Bool
forestSpanVersionNotSet ((ForestLine _ _ sv _,_),(ForestLine _ _ ev _,_)) = sv == 0 && ev == 0

-- |Checks if the version is non-zero
forestPosVersionSet :: ForestPos -> Bool
forestPosVersionSet (ForestLine _ _ v _,_) = v /= 0

-- |Checks if the AST version is non-zero
forestPosAstVersionSet :: ForestPos -> Bool
forestPosAstVersionSet (ForestLine _ tr _ _,_) = tr /= 0

-- |Checks if the version is zero
forestPosVersionNotSet :: ForestPos -> Bool
forestPosVersionNotSet (ForestLine _ _ v _,_) = v == 0

forestSpanLenChanged :: ForestSpan -> Bool
forestSpanLenChanged (s,e) = (forestPosLenChanged s) || (forestPosLenChanged e)

forestPosLenChanged :: ForestPos -> Bool
forestPosLenChanged (ForestLine ch _ _ _,_) = ch

-- |Puts a TreeId into a forestSpan
treeIdIntoForestSpan :: TreeId -> ForestSpan -> ForestSpan
treeIdIntoForestSpan (TId sel) ((ForestLine chs _ sv sl,sc),(ForestLine che _ ev el,ec))
  = ((ForestLine chs sel sv sl,sc),(ForestLine che sel ev el,ec))


-- |Strip out the version markers
forestSpanToSimpPos :: ForestSpan -> (SimpPos,SimpPos)
forestSpanToSimpPos ((ForestLine _ _ _ sr,sc),(ForestLine _ _ _ er,ec)) = ((sr,sc),(er,ec))

-- |Strip out the version markers
forestSpanToGhcPos :: ForestSpan -> (SimpPos,SimpPos)
forestSpanToGhcPos ((fls,sc),(fle,ec))
  = ((forestLineToGhcLine fls,sc),(forestLineToGhcLine fle,ec))


simpPosToForestSpan :: (SimpPos,SimpPos) -> ForestSpan
simpPosToForestSpan ((sr,sc),(er,ec))
    = ((ghcLineToForestLine sr,sc),(ghcLineToForestLine er,ec))

srcPosToSimpPos :: (Int,Int) -> (Int,Int)
srcPosToSimpPos (sr,c) = (l,c)
  where
    (ForestLine _ _ _ l) = ghcLineToForestLine sr

forestSpanStart :: ForestSpan -> ForestPos
forestSpanStart (start,_) = start

forestSpanEnd :: ForestSpan -> ForestPos
forestSpanEnd (_,end) = end

nullSpan :: ForestSpan
nullSpan = (nullPos,nullPos)

nullPos :: ForestPos
nullPos = (ForestLine False 0 0 0,0)

showForestSpan :: ForestSpan -> String
showForestSpan ((sr,sc),(er,ec))
  = show ((flToNum sr,sc),(flToNum er,ec))
  where
    flToNum (ForestLine ch tr v l) = (if ch then 10000000000::Integer else 0)
                                   + ((fromIntegral tr) * 100000000::Integer)
                                   + ((fromIntegral v)  *   1000000::Integer)
                                   + (fromIntegral l)

-- ---------------------------------------------------------------------

-- | Replace any ForestLine flags already in a SrcSpan with the given ones
insertForestLineInSrcSpan :: ForestLine -> GHC.SrcSpan -> GHC.SrcSpan
insertForestLineInSrcSpan fl@(ForestLine ch tr v _l) (GHC.RealSrcSpan ss) = ss'
  where
    lineStart = forestLineToGhcLine fl
    (_,(ForestLine _ _ _ le,_)) = srcSpanToForestSpan (GHC.RealSrcSpan ss)
    lineEnd   = forestLineToGhcLine (ForestLine ch tr v le)
    locStart = GHC.mkSrcLoc (GHC.srcSpanFile ss) lineStart (GHC.srcSpanStartCol ss)
    locEnd   = GHC.mkSrcLoc (GHC.srcSpanFile ss) lineEnd   (GHC.srcSpanEndCol ss)
    ss' = GHC.mkSrcSpan locStart locEnd

insertForestLineInSrcSpan _ _ss = error $ "insertForestLineInSrcSpan: expecting a RealSrcSpan, got:" -- ++ (showGhc ss)

-- ---------------------------------------------------------------------

insertVersionsInSrcSpan :: Int -> Int -> GHC.SrcSpan -> GHC.SrcSpan
insertVersionsInSrcSpan vs ve rss@(GHC.RealSrcSpan ss) = ss'
  where
    (chs,che) = forestSpanLenChangedFlags $ srcSpanToForestSpan rss
    (trs,tre) = forestSpanAstVersions $ srcSpanToForestSpan rss
    lineStart = forestLineToGhcLine (ForestLine chs trs vs (GHC.srcSpanStartLine ss))
    lineEnd   = forestLineToGhcLine (ForestLine che tre ve (GHC.srcSpanEndLine ss))
    locStart = GHC.mkSrcLoc (GHC.srcSpanFile ss) lineStart (GHC.srcSpanStartCol ss)
    locEnd   = GHC.mkSrcLoc (GHC.srcSpanFile ss) lineEnd   (GHC.srcSpanEndCol ss)
    ss' = GHC.mkSrcSpan locStart locEnd

insertVersionsInSrcSpan _ _ _ss = error $ "insertVersionsInSrcSpan: expecting a RealSrcSpan, got:" -- ++ (showGhc ss)

-- ---------------------------------------------------------------------

insertLenChangedInSrcSpan :: Bool -> Bool -> GHC.SrcSpan -> GHC.SrcSpan
insertLenChangedInSrcSpan chs che rss@(GHC.RealSrcSpan ss) = ss'
  where
    (sl,_sc) = getGhcLoc rss
    (el,_ec) = getGhcLocEnd rss
    sl' = if chs then sl .|. forestLenChangedMask
                 else sl .&. (complement forestLenChangedMask)

    el' = if che then el .|. forestLenChangedMask
                 else el .&. (complement forestLenChangedMask)

    locStart =  GHC.mkSrcLoc (GHC.srcSpanFile ss) sl' (GHC.srcSpanStartCol ss)
    locEnd    = GHC.mkSrcLoc (GHC.srcSpanFile ss) el' (GHC.srcSpanEndCol   ss)

    -- (vs,ve)   = forestSpanVersions $ srcSpanToForestSpan rss
    -- (trs,tre) = forestSpanAstVersions $ srcSpanToForestSpan rss
    -- lineStart = forestLineToGhcLine (ForestLine chs trs vs (GHC.srcSpanStartLine ss))
    -- lineEnd   = forestLineToGhcLine (ForestLine che tre ve (GHC.srcSpanEndLine ss))
    -- locStart  = GHC.mkSrcLoc (GHC.srcSpanFile ss) lineStart (GHC.srcSpanStartCol ss)
    -- locEnd    = GHC.mkSrcLoc (GHC.srcSpanFile ss) lineEnd   (GHC.srcSpanEndCol ss)
    ss' = GHC.mkSrcSpan locStart locEnd

insertLenChangedInSrcSpan _ _ _ss = error $ "insertVersionsInSrcSpan: expecting a RealSrcSpan, got:" -- ++ (showGhc ss)

-- ---------------------------------------------------------------------

insertVersionsInForestSpan :: Int -> Int -> ForestSpan -> ForestSpan
insertVersionsInForestSpan vsNew veNew ((ForestLine chs trs _vs ls,cs),(ForestLine che tre _ve le,ce))
  = ((ForestLine chs trs vsNew ls,cs),(ForestLine che tre veNew le,ce))

-- ---------------------------------------------------------------------

insertLenChangedInForestSpan :: Bool -> ForestSpan -> ForestSpan
insertLenChangedInForestSpan chNew ((ForestLine _chs trs vs ls,cs),(ForestLine _che tre ve le,ce))
  = ((ForestLine chNew trs vs ls,cs),(ForestLine chNew tre ve le,ce))

-- ---------------------------------------------------------------------

srcSpanToForestSpan :: GHC.SrcSpan -> ForestSpan
srcSpanToForestSpan sspan = ((ghcLineToForestLine startRow,startCol),(ghcLineToForestLine endRow,endCol))
  where
    (startRow,startCol) = getGhcLoc sspan
    (endRow,endCol)     = getGhcLocEnd sspan

-- --------------------------------------------------------------------

forestSpanFromEntry :: Entry -> ForestSpan
forestSpanFromEntry (Entry   ss _ _) = ss
forestSpanFromEntry (Deleted ss _ _) = ss

putForestSpanInEntry :: Entry -> ForestSpan -> Entry
putForestSpanInEntry (Entry   _ss lay toks) ssnew = (Entry ssnew lay toks)
putForestSpanInEntry (Deleted _ss pg eg) ssnew = (Deleted ssnew pg eg)

-- --------------------------------------------------------------------

treeIdFromForestSpan :: ForestSpan -> TreeId
treeIdFromForestSpan ((ForestLine _ tr _ _,_),(ForestLine _ _ _ _,_)) = TId tr

-- ---------------------------------------------------------------------
{-
data Module = Module
        { mTypecheckedMod :: GHC.TypecheckedModule
        , mOrigTokenStream :: [PosToken]  -- ^Original Token stream for the current module
        , mTokenCache :: Tree Entry -- ^Any modifications to the token stream.
        }

initModule :: GHC.TypecheckedModule -> [PosToken] -> Module
initModule typeChecked tokens
  = Module
      { mTypecheckedMod = typeChecked
      , mOrigTokenStream = tokens
      , mTokenCache = mkTreeFromTokens tokens
      }
-}

-- Initially work with non-monadic code, can build it into the
-- RefactGhc monad later

initTokenCache :: [PosToken] -> TokenCache
initTokenCache toks = TK (Map.fromList [((TId 0),(mkTreeFromTokens toks))]) (TId 0)

initTokenCacheLayout :: Tree Entry -> TokenCache
initTokenCacheLayout tree = TK (Map.fromList [((TId 0),tree)]) (TId 0)

-- ---------------------------------------------------------------------

treeIdIntoTree :: TreeId -> Tree Entry -> Tree Entry
treeIdIntoTree tid (Node (Entry fspan lay toks) subTree) = tree'
  where
    fs' = treeIdIntoForestSpan tid fspan
    tree' = Node (Entry fs' lay toks) subTree
treeIdIntoTree tid (Node (Deleted fspan pg eg) subTree) = tree'
  where
    fs' = treeIdIntoForestSpan tid fspan
    tree' = Node (Deleted fs' pg eg) subTree

-- ---------------------------------------------------------------------

stash :: TokenCache -> Tree Entry -> TokenCache
stash tk oldTree = tk'
  where
    (TId lastTreeId) = tkLastTreeId tk
    lastTreeId' = TId (lastTreeId + 1)
    oldTree' = treeIdIntoTree lastTreeId' oldTree
    cache' = Map.insert lastTreeId' oldTree' (tkCache tk)
    tk' = tk {tkLastTreeId = lastTreeId', tkCache = cache' }

-- ---------------------------------------------------------------------

replaceTokenInCache :: TokenCache -> GHC.SrcSpan -> PosToken -> TokenCache
replaceTokenInCache tk sspan tok = tk'
  where
   forest = getTreeFromCache sspan tk
   forest' = replaceTokenForSrcSpan forest sspan tok
   tk' = replaceTreeInCache sspan forest' tk

-- ---------------------------------------------------------------------

putToksInCache :: TokenCache -> GHC.SrcSpan -> [PosToken] -> (TokenCache,GHC.SrcSpan)
putToksInCache tk sspan toks = (tk'',newSpan)
  where
   forest = getTreeFromCache sspan tk
   (forest',newSpan,oldTree) = updateTokensForSrcSpan forest sspan toks
   tk' = replaceTreeInCache sspan forest' tk
   tk'' = stash tk' oldTree

-- ---------------------------------------------------------------------

putDeclToksInCache :: (SYB.Data t) =>
    TokenCache -> GHC.SrcSpan -> [PosToken] -> GHC.Located t
 -> (TokenCache,GHC.SrcSpan,GHC.Located t)
putDeclToksInCache tk sspan toks t = (tk'',newSpan,t')
  where
   forest = getTreeFromCache sspan tk
   (forest',newSpan,oldTree) = updateTokensForSrcSpan forest sspan toks
   (t',forest'') = syncAST t newSpan forest'

   tk' = replaceTreeInCache sspan forest'' tk
   tk'' = stash tk' oldTree

-- ---------------------------------------------------------------------

removeToksFromCache :: TokenCache -> GHC.SrcSpan -> TokenCache
removeToksFromCache tk sspan = tk''
  where
    forest = getTreeFromCache sspan tk
    (forest',oldTree) = removeSrcSpan forest (srcSpanToForestSpan sspan)
    tk' = replaceTreeInCache sspan forest' tk
    tk'' = stash tk' oldTree

-- ---------------------------------------------------------------------

getTreeFromCache :: GHC.SrcSpan -> TokenCache -> Tree Entry
getTreeFromCache sspan tk = (tkCache tk) Map.! tid
  where
    tid = treeIdFromForestSpan $ srcSpanToForestSpan sspan

-- ---------------------------------------------------------------------

replaceTreeInCache :: GHC.SrcSpan -> Tree Entry -> TokenCache -> TokenCache
replaceTreeInCache sspan tree tk = tk'
  where
    tid = treeIdFromForestSpan $ srcSpanToForestSpan sspan
    -- tree' = treeIdIntoTree tid tree
    tree' = putTidInTree tid tree
    tk' = tk {tkCache = Map.insert tid tree' (tkCache tk) }

putTidInTree :: TreeId -> Tree Entry -> Tree Entry
putTidInTree tid (Node (Deleted fspan pg eg) subs) = (Node (Deleted fs' pg eg) subs)
  where fs' = treeIdIntoForestSpan tid fspan
putTidInTree tid (Node (Entry fspan lay toks) subs) = tree'
  where
    subs' = map (putTidInTree tid) subs
    fs' = treeIdIntoForestSpan tid fspan
    tree' = Node (Entry fs' lay toks) subs'

-- ---------------------------------------------------------------------

-- |Assuming most recent operation has stashed the old tokens, sync
-- the given AST to the most recent stash entry
syncAstToLatestCache :: (SYB.Data t) => TokenCache -> GHC.Located t -> GHC.Located t
syncAstToLatestCache tk t = t'
  -- = error $ "syncAstToLatestCache:pos=" ++ (show pos)
  -- = error $ "syncAstToLatestCache:fs=" ++ (show fs)
  -- = error $ "syncAstToLatestCache:sspan=" ++ (show sspan)
  where
    mainForest = (tkCache tk) Map.! mainTid
    forest@(Node (Entry fspan _ _) _) = (tkCache tk) Map.! (tkLastTreeId tk)
    pos = forestSpanToGhcPos fspan
    sspan = posToSrcSpan mainForest pos
    (t',_) = syncAST t sspan forest

-- ---------------------------------------------------------------------

-- |Get the (possible cached) tokens for a given source span, and
-- cache their being fetched.
-- NOTE: The SrcSpan may be one introduced by HaRe, rather than GHC.
getTokensFor :: Bool -> Tree Entry -> GHC.SrcSpan -> (Tree Entry,[PosToken])
getTokensFor checkInvariant forest sspan = (forest'', tokens)
  where
     forest' = if (not checkInvariant) || invariantOk forest -- short
                                 -- circuit eval
               then forest
               else error $ "getTokensFor:invariant failed:" ++ (show $ invariant forest)
     (forest'',tree) = getSrcSpanFor forest' (srcSpanToForestSpan sspan)

     tokens = retrieveTokensInterim tree

-- ---------------------------------------------------------------------

-- |Get the (possible cached) tokens for a given source span, and
-- cache their being fetched.
-- NOTE: The SrcSpan may be one introduced by HaRe, rather than GHC.
getTokensForNoIntros :: Bool -> Tree Entry -> GHC.SrcSpan -> (Tree Entry,[PosToken])
getTokensForNoIntros checkInvariant forest sspan = (forest', tokens')
  where
    (forest',tokens) = getTokensFor checkInvariant forest sspan
    -- (lead,rest) = break (not . isWhiteSpaceOrIgnored) tokens
    (lead,rest) = break (not . isIgnoredNonComment) tokens
    tokens' = (filter (not . isIgnored) lead) ++ rest

-- ---------------------------------------------------------------------

-- |Get the tokens preceding a given 'SrcSpan'
getTokensBefore :: Tree Entry -> GHC.SrcSpan -> (Tree Entry,ReversedToks)
getTokensBefore forest sspan = (forest', prevToks')
  where
    (forest',tree@(Node (Entry _s _ _) _)) = getSrcSpanFor forest (srcSpanToForestSpan sspan)

    z = openZipperToSpan (srcSpanToForestSpan sspan) $ Z.fromTree forest'

    prevToks = case (retrievePrevLineToks z) of
                 RT [] -> reverseToks $ retrieveTokensInterim tree
                 xs -> xs

    (_,rtoks) = break (\t->tokenPos t < (getGhcLoc sspan)) $ reversedToks prevToks
    prevToks' = RT rtoks

-- ---------------------------------------------------------------------

-- |Replace a single token in a token tree, without changing the
-- structure of the tree
-- NOTE: the GHC.SrcSpan may have been used to select the appropriate
-- forest in the first place, and is required to select the correct
-- span in the tree, due to the ForestLine annotations that may be present

-- TODO: work at the token level, not the sspan level
-- TODO: Use start of token span only, with length 1.
replaceTokenForSrcSpan :: Tree Entry -> GHC.SrcSpan -> PosToken -> Tree Entry
replaceTokenForSrcSpan forest sspan tok = forest'
  where
    (GHC.L tl _,_) = tok
    -- First open to the sspan, making use of any Forestline annotations
    z = openZipperToSpanDeep (srcSpanToForestSpan sspan) $ Z.fromTree forest

    -- Then drill down to the specific subtree containing the token
    -- z' = openZipperToSpan (srcSpanToForestSpan tl) z
    z' = z -- No, pass in original token span as sspan.

    -- Note: with LayoutTree, the full tree matching the AST has been
    -- built, still need to drill down to the nearest enclosing span
    (tspan,lay,toks) = case Z.tree z' of
       (Node (Entry ss ly tks) []) -> (ss,ly,tks)
       (Node (Entry _ _ _nullToks) _sub) -> error $ "replaceTokenForSrcSpan:tok pos" ++ (showForestSpan $ sf sspan) ++ " expecting tokens, found: " ++ (show $ Z.tree z')
       (Node (Deleted _ _ _) _sub)       -> error $ "replaceTokenForSrcSpan:tok pos" ++ (showForestSpan $ sf sspan) ++ " expecting Entry, found: " ++ (show $ Z.tree z')

    ((row,col),_) = forestSpanToSimpPos $ srcSpanToForestSpan tl
    toks' = replaceTokNoReAlign toks (row,col) tok

    zf = Z.setTree (Node (Entry tspan lay toks') []) z'
    forest' = Z.toTree zf

    -- forest' = forest

-- ---------------------------------------------------------------------

-- |Replace the tokens for a given SrcSpan with new ones. The SrcSpan
-- will be inserted into the tree if it is not already there.
-- If the SrcSpan changes size, replace the SrcSpan with a new one
-- (marked), and return it, as well as the old one
-- TODO: What about trailing comments? Preserve or replace?
updateTokensForSrcSpan :: Tree Entry -> GHC.SrcSpan -> [PosToken] -> (Tree Entry,GHC.SrcSpan,Tree Entry)
updateTokensForSrcSpan forest sspan toks = (forest'',newSpan,oldTree)
  where
    (forest',tree@(Node (Entry _s _ _) _)) = getSrcSpanFor forest (srcSpanToForestSpan sspan)
    prevToks = retrieveTokensInterim tree

    -- endComments = reverse $ takeWhile isWhiteSpace $ reverse toks
    -- startComments = takeWhile isWhiteSpace $ toks

    endComments   = reverse $ takeWhile isWhiteSpaceOrIgnored $ reverse toks
    startComments = takeWhile isWhiteSpaceOrIgnored $ toks

    newTokStart = if (emptyList prevToks)
                   then mkZeroToken
                   else ghead "updateTokensForSrcSpan.1" prevToks

    toks'' = if (nonEmptyList startComments || nonEmptyList endComments)
      then -- toks have comments, discard originals
           reIndentToks (PlaceAbsolute (tokenRow newTokStart) (tokenCol newTokStart)) prevToks toks
      else -- Must reuse any pre-existing start or end comments, and
           -- resync the tokens across all three.
        let
           -- origEndComments = reverse $ takeWhile isWhiteSpace $ reverse prevToks
           -- origStartComments = takeWhile isWhiteSpace $ prevToks
           origEndComments   = reverse $ takeWhile isWhiteSpaceOrIgnored $ reverse prevToks
           origStartComments = takeWhile isWhiteSpaceOrIgnored $ prevToks
           -- core = reIndentToks (PlaceAbsolute (tokenRow newTokStart) (tokenCol newTokStart)) prevToks toks
           ((startRow,startCol),_) = forestSpanToGhcPos $ srcSpanToForestSpan sspan
           core = reIndentToks (PlaceAbsolute startRow startCol) prevToks toks
           trail = if (emptyList origEndComments)
            then []
            else addOffsetToToks (lineOffset,colOffset) origEndComments
              where
                lineOffset = 0 -- tokenRow (head origEndComments) - tokenRow (head origEndComments)
                colOffset = 0 -- tokenCol (head origEndComments)

           toks' = origStartComments ++ core ++ trail
        in toks'

    (startPos,endPos) = nonCommentSpan toks''

    -- if the original sspan had a ForestLine version, preserve it
    (((ForestLine _chs _trs vs _),_),(ForestLine _che _tre ve _,_)) = srcSpanToForestSpan sspan
    -- Note: adding one to end version, so invariant won't fail
    -- newSpan = insertVersionsInSrcSpan vs ve $ posToSrcSpan forest (startPos,endPos) 
    newSpan = insertLenChangedInSrcSpan True True
            $ insertVersionsInSrcSpan vs ve $ posToSrcSpan forest (startPos,endPos) 

    zf = openZipperToNode tree $ Z.fromTree forest'

    zf' = Z.setTree (Node (Entry (srcSpanToForestSpan newSpan) NoChange toks'') []) zf
    forest'' = Z.toTree zf'
    -- forest'' = error $ "updateTokensForSrcSpan: toks''=" ++ (show toks'') -- ++AZ++
    -- forest'' = error $ "updateTokensForSrcSpan: (posToSrcSpan forest (startPos,endPos))=" ++ (showGhc $ posToSrcSpan forest (startPos,endPos)) -- ++AZ++
    -- forest'' = error $ "updateTokensForSrcSpan: tree=" ++ (show tree) -- ++AZ++
    -- (forest'',newSpan') = addNewSrcSpanAndToksAfter forest sspan newSpan pos toks''

    oldTree = tree

-- ---------------------------------------------------------------------
-- |Retrieve a path to the tree containing a ForestSpan from the forest,
-- inserting it if not already present
getSrcSpanFor :: Tree Entry -> ForestSpan -> (Tree Entry, Tree Entry)
getSrcSpanFor forest sspan = (forest',tree)
  where
    forest' = insertSrcSpan forest sspan -- Will NO-OP if already
                                         -- there
    z = openZipperToSpan sspan $ Z.fromTree forest'
    tree = Z.tree z

-- ---------------------------------------------------------------------
-- |Retrieve a path to the tree containing a ForestSpan from the forest,
-- inserting it if not already present.
-- In the case where there is a nested series of spans as in an
-- 'Above' layout, return the deepest one
getSrcSpanForDeep :: Tree Entry -> ForestSpan -> (Tree Entry, Tree Entry)
getSrcSpanForDeep forest sspan = (forest',tree)
  where
    forest' = insertSrcSpan forest sspan -- Will NO-OP if already
                                         -- there
    z = openZipperToSpanDeep sspan $ Z.fromTree forest'

    tree = Z.tree z

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
      -- else error $ "insertSrcSpan:span not in tree " ++ show sspan

      else if (Z.isLeaf z)
        then  -- TODO: This should be in splitSubToks
          let
            -- If we are at a leaf, retrieve the toks
            (Entry _ _ toks) = Z.label z

            (tokStartPos,tokEndPos) = forestSpanToSimpPos sspan

            -- Tokens here, must introduce sub-spans with split, taking
            -- cognizance of start and end comments
            -- TODO: does startEndLocIncComments' give the same boundary
            --       if approached from one side as the other?
            (startLoc,endLoc) = startEndLocIncComments' toks (tokStartPos,tokEndPos)

            (startToks,middleToks,endToks) = splitToks (startLoc,endLoc) toks
            -- tree1 = if (emptyList $ filter (\t -> not $ isEmpty t) startToks)
            tree1 = if (nonCommentSpan startToks == ((0,0),(0,0)))
                       then []
                       else [mkTreeFromTokens startToks]
            tree2 = [mkTreeFromSpanTokens sspan middleToks]
            -- tree3 = if (emptyList $ filter (\t -> not $ isEmpty t) endToks)
            tree3 = if (nonCommentSpan endToks == ((0,0),(0,0)))
                       then []
                       else [mkTreeFromTokens endToks]

            subTree = tree1 ++ tree2 ++ tree3
            subTree' = filter (\t -> treeStartEnd t /= nullSpan) subTree
            -- (Entry sspan2 _ _) = Z.label z
            sspan2 = case Z.label z of
              (Entry ss _ _) -> ss
              (Deleted ss _ _) -> ss


            -- z' = Z.setTree (Node (Entry sspan2 NoChange []) subTree') z
            z' = case Z.label z of
              (Entry _ _ _) -> Z.setTree (Node (Entry sspan2 NoChange []) subTree') z
              (Deleted _ _ _) -> Z.setTree (Node (Entry sspan2 NoChange []) subTreeD) z
                where
                  (tb,tm,te) = splitSubToks (Z.tree z) sspan
                  subTreeD = tb ++ tm ++ te

            forest'' = Z.toTree z'
          in forest''
        else
          let
            (before,middle,end) = doSplitTree (Z.tree z) sspan
            newTree = case middle of
                        [x] -> x
                        _xs -> (Node (Entry sspan NoChange []) middle)
            subTree' = before ++ [newTree] ++ end
            (Entry sspan2 _ _) = Z.label z

            z' = Z.setTree (Node (Entry sspan2 NoChange []) subTree') z
            forest'' = Z.toTree z'
          in
            forest''
            -- error $ "insertSrcSpan:(before,middle,end)=" ++ (show (before,middle,end)) -- ++AZ++
            -- forest'' = error $ "insertSrcSpan:(startToks,endToks)=" ++ (show (startToks,endToks)) -- ++AZ++
            -- forest'' = error $ "insertSrcSpan:(Z.toTree z')=" ++ (show (Z.toTree z')) -- ++AZ++
            -- forest'' = error $ "insertSrcSpan:(startLoc,endLoc)=" ++ (show (startLoc,endLoc)) -- ++AZ++
            -- forest'' = error $ "insertSrcSpan:(tokStartPos,tokEndPos,toks)=" ++ (show (tokStartPos,tokEndPos,toks)) -- ++AZ++


-- ---------------------------------------------------------------------

doSplitTree ::
  Tree Entry -> ForestSpan
  -> ([Tree Entry], [Tree Entry], [Tree Entry])
doSplitTree tree@(Node (Deleted _ss _ _)   []) sspan = splitSubToks tree sspan -- ++AZ+ What is correct?
doSplitTree tree@(Node (Entry _ss _ _toks) []) sspan = splitSubToks tree sspan
doSplitTree tree                               sspan = (b'',m'',e'')
 -- error $ "doSplitTree:(sspan,tree,(b1,m1,e1))=" ++ (show (sspan,tree,(b1,m1,e1)))
  where
    (b1,m1,e1) = splitSubtree tree sspan
    (b,m,e) = case m1 of
      [] -> -- NOTE: This may have happened through a span being
            --       deleted from the tree
            -- Hence, correct solution is to kick it up a level and
            -- rebuild using tokens etc
             error $ "doSplitTree:no middle:(tree,sspan,b1,m1,e1)=" ++ (show (tree,sspan,b1,m1,e1))
      [x] -> -- only one tree
             doSplitTree x sspan

      xx  -> -- more than one tree
        (b',m',e')
          where
            (bb,mb,_eb) = case (doSplitTree (ghead "doSplitTree.2" xx) sspan) of
                           (x,y,[]) -> (x,y,[])
                           xxx -> error $ "doSplitTree:eb populated:" ++ (show (sspan,tree,xxx))

            -- ( bb,mb,[]) = doSplitTree (ghead "doSplitTree.2" xx) sspan

            ( [],me,ee) = doSplitTree (glast "doSplitTree.2" xx) sspan
            -- ( bbb,me,ee) = doSplitTree (glast "doSplitTree.2" xx) sspan
            mm = tail $ init xx -- xx = (head xx) ++ mm ++ (last xx)

            b' = bb
            m' = mb ++ mm ++ me
            e' = ee
    (b'',m'',e'') = (b1++b,m,e++e1)


-- ---------------------------------------------------------------------

-- TODO: The Bool is horrible
mkTreeListFromTokens :: [PosToken] -> ForestSpan -> Bool -> [Tree Entry]
mkTreeListFromTokens  [] _sspan _ = []
mkTreeListFromTokens toks sspan useOriginalSpan = res
  where
   (Node (Entry tspan NoChange treeToks) sub) = mkTreeFromTokens toks

   ((ForestLine chs ts vs  _, _),(ForestLine che te ve  _, _)) = sspan
   ((ForestLine   _  _  _ ls,cs),(ForestLine   _  _  _ le,ce)) = tspan

   span' = ((ForestLine chs ts vs ls, cs),(ForestLine che te ve le, ce))

   res = if nonCommentSpan toks == ((0,0),(0,0))
     then []
     else if useOriginalSpan
            then [(Node (Entry sspan NoChange treeToks) sub)]
            else [(Node (Entry span' NoChange treeToks) sub)]

-- ---------------------------------------------------------------------

splitSubToks ::
  Tree Entry
  -> (ForestPos, ForestPos)
  -> ([Tree Entry], [Tree Entry], [Tree Entry])
splitSubToks n@(Node (Deleted (treeStart,treeEnd) _pg _eg) []) (sspanStart,sspanEnd) = (b',m',e')
  where
    egs = (0,0) -- TODO: calculate this
    ege = (0,0) -- TODO: calculate this
    pg = 0      -- TODO: calculate this
    b' = if sspanStart > treeStart
           then [Node (Deleted (treeStart,treeStart) pg egs) []]
           else []
    m' = [n]
    e' = if treeEnd > sspanEnd
           then [Node (Deleted (sspanEnd,treeEnd) pg ege) []]
           else []

splitSubToks tree sspan = (b',m',e')
                          -- error $ "splitSubToks:(sspan,tree)=" ++ (show (sspan,tree))
  where
    (Node (Entry ss@(treeStart,treeEnd) _lay toks)  []) = tree
    (sspanStart,sspanEnd) = sspan
    -- TODO: ignoring comment boundaries to start

    -- There are three possibilities
    --  1. The span starts only in these tokens
    --  2. The span starts and ends in these tokens
    --  3. The span ends only in these tokens
    (b',m',e') = case (containsStart ss sspan,containsEnd ss sspan) of
      (True, False) -> (b'',m'',e'') -- Start only
                       -- error $ "splitSubToks:StartOnly:(sspan,tree,(b'',m''))=" ++ (show (sspan,tree,(b'',m'')))
        where
         (_,toksb,toksm) = splitToks (forestSpanToSimpPos (nullPos,sspanStart)) toks
--         b'' = if (emptyList toksb) then [] else [Node (Entry (treeStart, sspanEnd) toksb) []]
         b'' = if (emptyList toksb || nonCommentSpan toksb == ((0,0),(0,0)))
                 then []
                 else [mkTreeFromTokens toksb] -- Need to get end from actual toks
         m'' = let
                (ForestLine _ch _ts _v le,ce) = sspanEnd
                tl =
                  if (treeStart == sspanStart) -- Eq does not compare all flags
                    then mkTreeListFromTokens toksm (treeStart, treeEnd) False
                    else mkTreeListFromTokens toksm (sspanStart,treeEnd) False
                _tl' = if emptyList tl
                 then []
                 else [Node (Entry (st,(ForestLine ch ts v le,ce)) lay tk) []]
                   where [Node (Entry (st,(ForestLine ch ts v _l,_c)) lay tk) []] = tl
               in
                -- tl'
                tl
         e'' = []

      (True, True) -> (b'',m'',e'') -- Start and End
        where
         -- (toksb,toksm,tokse) = splitToks (forestSpanToSimpPos (treeStart,treeEnd)) toks
         (toksb,toksm,tokse) = splitToks (forestSpanToSimpPos (sspanStart,sspanEnd)) toks
         b'' = mkTreeListFromTokens toksb (treeStart,  sspanStart) False
         m'' = mkTreeListFromTokens toksm (sspanStart, sspanEnd)   True
         e'' = mkTreeListFromTokens tokse (sspanEnd,   treeEnd)    False

      (False,True) -> (b'',m'',e'') -- End only
        where
         (_,toksm,tokse) = splitToks (forestSpanToSimpPos (nullPos,sspanEnd)) toks
         b'' = []
         m'' = let -- If the last span is changed, make sure it stays
                   -- as it was
                tl = mkTreeListFromTokens toksm (treeStart,sspanEnd) False
                tl' = if emptyList tl
                 then []
                 else [Node (Entry (st,sspanEnd) lay tk) []]
                   where [Node (Entry (st,_en) lay tk) []] = mkTreeListFromTokens toksm (treeStart,sspanEnd) False
                in
                 tl'
         e'' = mkTreeListFromTokens tokse (sspanEnd,treeEnd) False

      (False,False) -> if (containsMiddle ss sspan)
                        then ([],[tree],[])
                        else error $ "splitSubToks: error (ss,sspan)=" ++ (show (ss,sspan))

-- ---------------------------------------------------------------------

-- |True if the start of the second param lies in the span of the first
containsStart :: ForestSpan -> ForestSpan -> Bool
containsStart (nodeStart,nodeEnd) (startPos,_endPos)
  = (startPos >= nodeStart && startPos <= nodeEnd)

-- |True if the start of the second param lies before the first, and
-- ends after or on the second
containsMiddle :: ForestSpan -> ForestSpan -> Bool
containsMiddle   (nodeStart,nodeEnd) (startPos,endPos)
  = (startPos <= nodeStart) && (endPos >= nodeEnd)

-- |True if the end of the second param lies in the span of the first
containsEnd :: ForestSpan -> ForestSpan -> Bool
containsEnd   (nodeStart,nodeEnd) (_startPos,endPos)
  = (endPos >= nodeStart && endPos <= nodeEnd)

-- ---------------------------------------------------------------------

-- |Split a given tree into a possibly empty part that lies before the
-- srcspan, the part that is wholly included in the srcspan and the
-- part the lies outside of it at the end.
splitSubtree ::
  Tree Entry -> ForestSpan
  -> ([Tree Entry], [Tree Entry], [Tree Entry])
splitSubtree tree sspan = (before,middle,end)
                          -- error $ "splitSubtree:(sspan,tree,middle',end')=" ++ (show (sspan,tree,middle',end'))
  where
    containsStart'  t = containsStart  (treeStartEnd t) sspan
    containsMiddle' t = containsMiddle (treeStartEnd t) sspan
    containsEnd'    t = containsEnd    (treeStartEnd t) sspan

    cond t = containsStart' t || containsMiddle' t || containsEnd' t

    (Node _entry children) = tree
    (before,rest)   = break (\x -> cond x) children
    (endr,middler)  = break (\x -> cond x) $ reverse rest

    (middle,end) = (reverse middler,reverse endr)



-- ---------------------------------------------------------------------

-- | Removes a ForestSpan and its tokens from the forest.
removeSrcSpan :: Tree Entry -> ForestSpan
  -> (Tree Entry,Tree Entry) -- ^Updated forest, removed span
removeSrcSpan forest sspan = (forest'', delTree)
  where
    forest' = insertSrcSpan forest sspan -- Make sure span is actually
                                         -- in the tree
    z = openZipperToSpan sspan $ Z.fromTree forest'
    zp = gfromJust "removeSrcSpan" $ Z.parent z

    ((pg,_),eg) = calcPriorAndEndGap forest' sspan

    pt = Z.tree zp

    subTree = map (\t -> if (treeStartEnd t == sspan) then (Node (Deleted sspan pg eg) []) else t) $ subForest pt

    z' = Z.setTree (pt { subForest = subTree}) zp
    forest'' = Z.toTree z'

    delTree = Z.tree z
    -- forest'' = error $ "removeSrcSpan: forest'=" ++ drawTreeCompact forest'

-- ---------------------------------------------------------------------

-- |For a span about to be deleted, calculate the gap between the end
-- of the span being deleted and the start of the next one, at a token
-- level.
calcPriorAndEndGap :: Tree Entry -> ForestSpan -> (SimpPos,SimpPos)
calcPriorAndEndGap tree sspan = (pg,eg)
  where
    ((spanStartRow,spanStartCol),(spanRow,spanCol)) = forestSpanToSimpPos sspan
    (spanStart,spanEnd) = sspan
    entries = retrieveTokens' tree
    -- NOTE: the entries are the fringe of the tree, the sspan in
       -- question may be represented by several entries
    (before,rest)    = span  (\e -> (forestSpanStart $ forestSpanFromEntry e) < spanStart) entries
    (rafter,rmiddle) = break (\e -> (forestSpanEnd $ forestSpanFromEntry e) <= spanEnd) $ reverse rest
    _middle = reverse rmiddle
    after = reverse rafter
    -- last element of before should be the sspan we care about, first
    -- of after is the one we are looking for.

    -- NOTE: `after` may contain zero or more Deleted segments in the
    -- front. These get merged later in mergeDeletes
    (tokRow,tokCol) = if emptyList after
        then (spanRow + 2,spanCol)
        else (r,c)
            where
                (r,c) = case ghead ("calcEndGap:after="++(show after)) after of
                    (Entry _ _ toks) -> (tokenRow t,tokenCol t)
                        where t = ghead "calcEndGap" toks
                    (Deleted ss _ _) -> fst $ forestSpanToSimpPos ss

    eg = (tokRow - spanRow, tokCol - spanCol)
    -- eg = error $ "calcEndGap: (sspan,(before,middle,after))=" ++ (show (sspan,(_before,middle,after)))

    (tokRowPg,tokColPg) = if emptyList before
        then (spanStartRow - 1,spanStartCol)
        else (r,c)
            where
                (r,c) = case glast ("calcEndGap:before="++(show before)) before of
                    (Entry _ _ toks) -> (tokenRow t,tokenCol t)
                        where t = glast "calcEndGap pg" toks
                    (Deleted ss _ _) -> snd $ forestSpanToSimpPos ss

    -- TODO: what about comments before the span? spanStartRow may be off
    pg = (spanStartRow - tokRowPg, spanStartCol - tokColPg)
    -- pg = error $ "calcPriorAndEndGap : (tokRowPg,tokColPg):" ++ (show $ ((tokRowPg,tokColPg),(spanStartRow,spanStartCol)))
    -- pg = error $ "calcPriorAndEndGap : (head before):" ++ (show $ last before)


-- ---------------------------------------------------------------------

-- TODO: delete this, superseded by calcPriorAndEndGap
-- |For a span about to be deleted, calculate the gap between the end
-- of the span being deleted and the start of the next one, at a token
-- level.
calcEndGap :: Tree Entry -> ForestSpan -> SimpPos
calcEndGap tree sspan = gap
  where
    (_sspanStart,(spanRow,spanCol)) = forestSpanToSimpPos sspan
    (spanStart,spanEnd) = sspan
    entries = retrieveTokens' tree
    -- NOTE: the entries are the fringe of the tree, the sspan in
       -- question may be represented by several entries
    (_before,rest)   = span  (\e -> (forestSpanStart $ forestSpanFromEntry e) < spanStart) entries
    (rafter,rmiddle) = break (\e -> (forestSpanEnd $ forestSpanFromEntry e) <= spanEnd) $ reverse rest
    _middle = reverse rmiddle
    after = reverse rafter
    -- last element of before should be the sspan we care about, first
    -- of after is the one we are looking for.

    -- NOTE: `after` may contain zero or more Deleted segments in the
    -- front. These get merged later in mergeDeletes
    (tokRow,tokCol) = if emptyList after
        then (spanRow + 2,spanCol)
        else (r,c)
            where
                (r,c) = case ghead ("calcEndGap:after="++(show after)) after of
                    (Entry _ _ toks) -> (tokenRow t,tokenCol t)
                        where t = ghead "calcEndGap" toks
                    (Deleted ss _ _) -> fst $ forestSpanToSimpPos ss

    gap = (tokRow - spanRow, tokCol - spanCol)
    -- gap = error $ "calcEndGap: (sspan,(before,middle,after))=" ++ (show (sspan,(_before,middle,after)))

-- ---------------------------------------------------------------------

-- |Retrieve all the tokens at the leaves of the tree, in order.
-- Marked tokens are re-aligned, and gaps are closed.
retrieveTokensFinal :: Tree Entry -> [PosToken]
retrieveTokensFinal forest = monotonicLineToks $ stripForestLines $ reAlignMarked
                      $ deleteGapsToks $ retrieveTokens' forest

-- ---------------------------------------------------------------------

{-
-- |Retrieve the tokens in a ppr format, so they can be rendered
retrieveTokensPpr :: Tree Entry -> [Ppr]
retrieveTokensPpr forest = pps'''
  where
    -- forest' = adjustLinesForDeleted forest
    (pps,_,lastLine) = retrieveTokensPpr' ([],Original,[]) forest
    pps'   = pps ++ (mkPprFromLineToks lastLine)
    pps''  = mergeDeletesPpr pps'
    pps''' = adjustPprForDeleted pps''

retrieveTokensPpr' :: ([Ppr],PprOrigin,[PosToken]) -> Tree Entry -> ([Ppr],PprOrigin,[PosToken])

retrieveTokensPpr' acc (Node (Deleted _sspan _pg ( 0,_cd) ) _) = acc
retrieveTokensPpr' acc (Node (Deleted  sspan  pg (rd,_cd) ) _) = acc'
  where
    (ac,o,curLineToks) = acc
    ll = mkPprFromLineToksSrc o curLineToks
    ((rs,cs),(re,_ce)) = forestSpanToSimpPos sspan
    ol = re - rs
    acc' = (ac ++ ll ++ [PprDeleted rs cs pg ol rd],o,[])

retrieveTokensPpr' acc (Node (Entry _sspan NoChange     []) subs)
  = foldl' retrieveTokensPpr' acc subs

retrieveTokensPpr' acc (Node (Entry _sspan (Above so _ (r,c) eo) []) subs) = acc'
  where
    (ac,_o,curLineToks) = acc
    (sss,o2,cl2) = foldl' retrieveTokensPpr' ([],Original,[]) subs
    cl2Acc = mkPprFromLineToksSrc o2 cl2
    ll = mkPprFromLineToks curLineToks
    acc' = (ac ++ ll ++ [PprAbove so (r,c) eo (normaliseColumns (sss++cl2Acc))],o2,[])

retrieveTokensPpr' (acc,oi,curLineToks) (Node (Entry sspan _     toks) []) = (acc++accNew,o,curLineToks')
  where
    o = if (forestSpanVersionSet sspan) then Added else Original
    oi' = if o == Added || oi == Added then Added else Original
    toksByLine = groupTokensByLine toks
    (accNew,curLineToks') = case curLineToks of
      [] -> case toksByLine of
              [] -> ([],[])
              [x] -> ([],x)
              xs -> (concatMap (mkPprFromLineToksSrc o) (init xs),last xs)

      _  -> case toksByLine of
              [] -> ([],[])
              [x] -> if (toksOnSameLine (last curLineToks) (head x))
                       then ([],curLineToks ++ x)
                       else (mkPprFromLineToksSrc oi curLineToks,x)
              (x:xs) -> if (toksOnSameLine (last curLineToks) (head x))
                          then ((mkPprFromLineToksSrc oi' (curLineToks++x)) ++ concatMap (mkPprFromLineToksSrc o) (  init xs),last xs)
                          else ((mkPprFromLineToksSrc oi   curLineToks    ) ++ concatMap (mkPprFromLineToksSrc o) (x:init xs),last xs)

-- Keep -Wall happy
retrieveTokensPpr' _acc n@(Node (Entry _sspan (Above _so _ (_r,_c) _eo) _toks) _subs)
  = error $ "retrieveTokensPpr': Above entry with toks:" ++ (show n)
-- retrieveTokensPpr' _acc n@(Node (Entry _sspan (Offset _r _c) _toks) _subs)
--   = error $ "retrieveTokensPpr': Offset entry with toks:" ++ (show n)
retrieveTokensPpr' _acc n@(Node (Entry _sspan (NoChange) _toks) _subs)
  = error $ "retrieveTokensPpr': NoChange entry with toks:" ++ (show n)
-}

{-
mkPprFromLineToks :: [PosToken] -> [Ppr]
mkPprFromLineToks toks = mkPprFromLineToksSrc Original toks

mkPprFromLineToksSrc :: PprOrigin -> [PosToken] -> [Ppr]
mkPprFromLineToksSrc _ [] = []
mkPprFromLineToksSrc o toks = [PprText ro co o str]
  where
    ro' = tokenRow $ head toks
    co' = tokenCol $ head toks
    (ro,co) = srcPosToSimpPos (tokenRow $ head toks, tokenCol $ head toks)
    toks' = addOffsetToToks (-ro',-co') toks
    str = GHC.showRichTokenStream toks'


-- | The PprAbove construct needs all the starting columns to be reset to zero
normaliseColumns :: [Ppr] -> [Ppr]
normaliseColumns [] = []
normaliseColumns ps = ps'
  where
    offset = case (head ps) of
      PprText    _r c _ _   -> c - 1
      PprDeleted _r c _ _ _ -> c - 1
      _              -> 0
    ps' = map removeOffset ps

    removeOffset (PprText r c o toks)   = (PprText r (c - offset) o toks)
    removeOffset (PprDeleted r c p l e) = (PprDeleted r (c - offset) p l e)
    removeOffset x = x
-}
-- ---------------------------------------------------------------------
{-
adjustPprForDeleted :: [Ppr] -> [Ppr]
adjustPprForDeleted [] = []
adjustPprForDeleted pps = pps'
  where
    (_,pps') = foldl' go ((0,0),[]) pps

    go :: ((Int,Int),[Ppr]) -> Ppr -> ((Int,Int),[Ppr])
    go ((ro,co),acc) (PprText r c Original str) = ((ro,  co),acc++[PprText (r-ro) (c-co) Original str])
    go ((ro,co),acc) (PprText r c Added    str) = ((ro-1,co),acc++[PprText (r   ) (c   ) Added  str])
    -- go ((ro,co),acc) (PprDeleted r c rd) = ((ro - rd,co),acc)
    go ((ro,co),acc) (PprDeleted r c pg l eg)
        = ((ro + (pg + l + eg) - (max pg eg),co),acc++[PprDeleted r c pg l eg])
           -- NOTE: see below for derivation of the above calc
    go ((ro,co),acc) (PprAbove so p1 eo subs) = ((ro',co'),acc++[PprAbove so' p1' eo' subs'])
      where
        so' = so
        p1' = p1
        eo' = eo
        ((ro',co'),subs') = foldl' go ((ro,co),[]) subs
-}
{-

Case 1

Code is
----
3:data D = A | B String | C
4:
5:ff :: Int -> Int  <<<line to be deleted
6:ff y = y + zz
7:  where
8:    zz = 1
-----
PprDeleted 5 1 2 0 1
So pg is 2 (5 - 3)
    l is 0 (5 - 5)
   eg is 1 (6 - 5)

New location needs to be 5, so
ro needs to be 1

-------------

Case 2

Code is
----
 5:ff :: Int -> Int
 6:ff y = y + zz      <<<line to be deleted
 7:  where            <<<line to be deleted
 8:    zz = 1         <<<line to be deleted
 9:
10:x = 3
-----
PprDeleted 6 1 1 2 2
So pg is 1 ( 6 - 5)
    l is 2 ( 8 - 6)
   eg is 2 (10 - 8)

New location needs to be 7, so
ro needs to be 3

so (pg - 1) + (l + 1) or pg + l


-------------

Case 3

Code is
----
 4:ff :: Int -> Int
 5:
 6:ff y = y + zz      <<<line to be deleted
 7:  where            <<<line to be deleted
 8:    zz = 1         <<<line to be deleted
 9:
10:x = 3
-----
PprDeleted 6 1 2 2 2
So pg is 2 ( 6 - 4)
    l is 2 ( 8 - 6)
   eg is 2 (10 - 8)

New location needs to be 6, so
ro needs to be 4

so (pg - 1) + (l + 1) or pg + l

=================================

First principles.

We have
 sr : last non-blank line before deletion area
 dr : first non-blank line after deletion area

 fd : first line of deletion area
 ld : last line of deletion area

We need to calculate the offset to bring dr to have the same end
gap as for the original.

      Case 1   Case 2  Case 3
 sr    3         5       4
 fd    5         6       6
 ld    5         8       8
 dr    6        10      10

 pg    2         1       2
 eg    1         2       2

 np    5         7       6
 ro    1         3       4

i.e. we need to apply the largest of (pg,eg)  to the original sr.

so
  np = sr + max(pg,eg)

  ro = dr - np

Hence

  ro = dr - sr - max(pg,eg)

In PprDeleted, dr - sr is same as (pg + l + eg)

  ro = (pg + l + eg) - max(pg,eg)

-}

-- ---------------------------------------------------------------------
{-
mergeDeletesPpr :: [Ppr] -> [Ppr]
mergeDeletesPpr [] = []
mergeDeletesPpr ((PprDeleted r1 c1 pg1 l1 eg1):(PprDeleted _r _c pg2 l2 eg2):ps)
  = (PprDeleted r1 c1 pg1 (l1 + eg1 + pg2 + l2 - 1) eg2) : mergeDeletesPpr ps
-}
{-
The total gap taken up by each delete is pg+l+eg.

We have
  pg1 + l1 + eg1 + pg2 + l2 + eg2

The combined span has
  pg1 + (l1 + eg1 + pg2 + l2) + eg2

Why do we need the (-1)? TBD

pg1 : fb - sr
eg1 : dr - lb
 l1 : lb - fb
sum: (fb - sr) + (dr - lb) + (lb - fb)
  = -sr + dr  -- fb and lb cancels out
  = dr - sr
so we have (dr1 - sr1) + (dr2 - sr2)
bu, dr1 == sr2
so (dr1 - sr1 + dr2 - dr1)
or dr2 - sr1
-}
{-
mergeDeletesPpr (p:ps) = p : mergeDeletesPpr ps
-}
-- ---------------------------------------------------------------------
{-
getPprStartRow :: Ppr -> Row
getPprStartRow (PprText r _ _ _) = r
getPprStartRow (PprDeleted r _ _ _ _) = r
getPprStartRow (PprAbove _ _ _ []) = error "getPprStartRow: PprAbove with no subs"
getPprStartRow (PprAbove _ _ _ subs) = getPprStartRow $ head subs

getPprEndRow :: Ppr -> Row
getPprEndRow (PprText r _ _ _) = r
getPprEndRow (PprDeleted r _ _ _ _) = r
getPprEndRow (PprAbove _ _ _ []) = error "getPprEndRow: PprAbove with no subs"
getPprEndRow (PprAbove _ _ _ subs) = getPprEndRow $ last subs
-}

-- ---------------------------------------------------------------------

-- TODO: deprecated, doing this at the Ppr level now
adjustLinesForDeleted :: Tree Entry -> Tree Entry
adjustLinesForDeleted forest = forest'
  where
    (_,forest') = go (0,0) forest

    go :: (Int,Int) -> Tree Entry -> ((Int,Int),Tree Entry)
    go (ro,co) (n@(Node (Entry _ss _lay _toks) [])) = ((ro,co),applyOffsetToTreeShallow (ro,co) n)
    go (ro,co) (n@(Node (Deleted _ _ (gr,_gc)) _nullSubs))   = ((ro-gr,co),n)
    go (ro,co) (n@(Node (Entry _ss _lay []) _subs)) = ((ro',co'),Node (Entry ss lay []) subs')
      where
        (Node (Entry ss lay []) subs) = applyOffsetToTreeShallow (ro,co) n
        ((ro',co'),subs') = foldl' go' ((ro,co),[]) subs

    go (_ro,_co) (n@(Node (Entry _ss _lay _toks) _subs))
      = error $ "adjustLinesForDeleted: Entry with toks and subs:" ++ (show n)

    go' ((ro,co),acc) tree = ((ro',co'),acc++[tree'])
      where
        ((ro',co'),tree') = go (ro,co) tree

-- ---------------------------------------------------------------------

applyOffsetToTreeShallow :: (Int,Int) -> Tree Entry -> Tree Entry
applyOffsetToTreeShallow (ro,co) (Node (Entry sspan lay toks) subs)
  = (Node (Entry sspan' lay toks') subs')
  where
    sspan' = addOffsetToForestSpan (ro,co) sspan
    toks' = addOffsetToToks (ro,co) toks
    subs' = subs
applyOffsetToTreeShallow _ n@(Node (Deleted _ _ _) _) = n

-- ---------------------------------------------------------------------
{-
renderPpr :: [Ppr] -> String
renderPpr ps = res
  where
    (_,(_,res)) = runState (go 0 ps) ((1,1),"")

    go _ [] = return ()

    go ci (ppt@(PprText _rt _ct _ _toks):ppa@(PprAbove so (_,_cc) eo _subs):ps') = do
      renderPprText ci ppt
      addOffset so
      (_,c) <- getRC
      renderPprAbove c ppa
      (cr,_cc) <- getRC
      -- addOffset eo
      if ps' /= []
       then
         case eo of
           FromAlignCol (ero,eco) -> newPos (cr+ero) (ci+eco)
           SameLine _ -> addOffset eo
           None       -> return ()
       else return ()
      -- (r',c') <- getRC
      -- addDebugString $ "(eo:" ++ show (ci,(r',c')) ++ ")" -- ++AZ++ debug
      go ci ps'

    go ci (p@(PprText _rt _ct _ _toks):ps') = do
      renderPprText ci p
      go ci ps'

    go ci ((PprDeleted _ _ _ _ _):ps') = go ci ps'

    go _ pps = error $ "renderPpr: unmatched in go:" ++ (show pps)

    ------------------------------------

    renderPprAbove _ci (PprAbove _ _ _   []) = return ()
    renderPprAbove  ci (PprAbove _ _ _ subs) = go ci subs

    renderPprAbove _ ppr = error $ "renderPprAbove:unexpected ppr:" ++ (show ppr)

    ------------------------------------

    -- renderPprText :: Col -> Ppr -> String
    renderPprText ci (PprText rt ct _ str) = do
      -- (r',c') <- getRC
      -- addDebugString $ "(op" ++ (show (ci,(r',c'),(rt,ct))) ++ ")"  -- ++AZ++ for debugging
      newPos rt (ci + ct)
      -- (r,c) <- getRC
      -- addDebugString $ "(np:" ++ (show (r,c)) ++ ")"  -- ++AZ++ for debugging
      addString str
      -- addDebugString $ "(fp:" ++ (show (r,c)) ++ ")"  -- ++AZ++ for debugging

    renderPprText _ ppr = error $ "renderPprText:unexpected ppr:" ++ (show ppr)

    ------------------------------------

    addOffset None = return ()
    addOffset (SameLine co) = do
      (r,c) <- getRC
      newPos r (c+co)
    addOffset (FromAlignCol (ro,co)) = do
      (r,c) <- getRC
      newPos (r+ro) (c+co)

    newPos newRow newCol = do
      (oldRow',oldCol) <- getRC

      -- Allow for out of order additions that result from additions
      -- to the tree. Will break the invariant.
      let oldRow = if oldRow' <= newRow then oldRow' else (newRow - 1)
      putRC (oldRow,oldCol)

      if oldRow == newRow
        then addString (take (newCol - oldCol) $ repeat ' ')
        else
          addString ( (take (newRow - oldRow) $ repeat '\n') ++
                      (take (newCol - 1) $ repeat ' ') )
      checkInvariant $ "newPos:" ++ (show (newRow,newCol))


    -- Check invariant
    --  1. r == number of '\n' + 1
    --  2. c == number of chars in last line.
    --     We assume the c val refers to positions between characters
    --     of output.
    checkInvariant str = do
{-
      ((r,c),cur) <- get
      let ll = 1 + (length $ filter (=='\n') cur)
      let lc = 1 + (length $ takeWhile (/='\n') $ reverse cur)
      if r /= ll
        then error $ "renderPpr.newPos: r /= ll :" ++ (show (r,ll,cur,str))
        else return ()
      if c /= lc
        then error $ "renderPpr.newPos: c /= lc :" ++ (show (c,lc,cur,str))
        else return ()
-}
      return ()

    -- State operations ----------------

    getRC = do
      (rc,_) <- get
      return rc

    putRC (r,c) = do
      (_,str) <- get
      put ((r,c),str)

    addString [] = return ()
    addString str = do
      ((r,c),curr) <- get
      let ll = (length $ filter (=='\n') str)
      let c'' = (length $ takeWhile (/='\n') $ reverse str)


      let (r',c') = case ll of
                     0 -> (r,c + c'')
                     _ -> (r + ll, c'' + 1)
      put ((r',c'),curr++str)

      checkInvariant $ "addString" ++ show str

    addDebugString str = do
      ((r,c),curr) <- get
      put ((r,c),curr++str)
-}

-- ---------------------------------------------------------------------

-- |Retrieve all the tokens at the leaves of the tree, in order. No
-- adjustments are made to address gaps or re-alignment of the tokens
retrieveTokensInterim :: Tree Entry -> [PosToken]
retrieveTokensInterim forest = monotonicLineToks $ stripForestLines {-  reAlignMarked -}
                             $ concat $ map (\t -> F.foldl accum [] t) [forest]
  where
    accum :: [PosToken] -> Entry -> [PosToken]
    accum acc (Entry _ _ [])   = acc
    accum acc (Entry _ _ toks) = acc ++ toks
    accum acc (Deleted _ _ _)  = acc


retrieveTokens' :: Tree Entry -> [Entry]
retrieveTokens' forest = mergeDeletes $ concat $ map (\t -> F.foldl accum [] t) [forest]
  where
    accum :: [Entry] -> Entry -> [Entry]
    accum acc   (Entry _ _ [])    = acc
    accum acc e@(Entry _ _ _toks) = acc ++ [e]
    accum acc e@(Deleted _ _ _)   = acc ++ [e]

-- |Merge adjacent Deleted entries
mergeDeletes :: [Entry] -> [Entry]
mergeDeletes [] = []
mergeDeletes [x] = [x]
mergeDeletes ((Deleted ss1 pg1 (r1,_)):(Deleted ss2 _ (r2,c2)):xs) = (Deleted ss pg1 o):xs
  where
    (start,_) = ss1
    (_, end) = ss2
    ss = (start,end)
    o = (r1+r2,c2)
mergeDeletes (x:xs) = x:mergeDeletes xs

-- ---------------------------------------------------------------------

-- | Process the leaf nodes of a tree to remove all deleted spans
deleteGapsToks :: [Entry] -> [PosToken]
deleteGapsToks toks = goDeleteGapsToks (0,0) toks

goDeleteGapsToks :: SimpPos -> [Entry] -> [PosToken]
goDeleteGapsToks      _ []                    = []
goDeleteGapsToks offset [Entry _ _ t]         = map (increaseSrcSpan offset) t
goDeleteGapsToks      _ [Deleted _ _ _]       = []
goDeleteGapsToks offset (Deleted _ _ _:ts)    = goDeleteGapsToks offset ts
goDeleteGapsToks offset [Entry _ _ t,Deleted _ _ _] = map (increaseSrcSpan offset) t
goDeleteGapsToks offset (Entry _ _ t1:e@(Entry _ _ _):ts) = (map (increaseSrcSpan offset) t1) ++goDeleteGapsToks offset (e:ts)
goDeleteGapsToks (fr,fc) (Entry ss _lay1 t1:Deleted _ _ eg:t2:ts)
  = t1' ++ goDeleteGapsToks offset' (t2:ts)
  where
    -- TODO: use actual first and last toks, may be comments
    -- TODO: what about deletion within a line?

    (deltaR,_deltaC) = eg
    (_,(sr,_sc)) = forestSpanToSimpPos ss
    ((dr,_dc),_) = forestSpanToSimpPos $ forestSpanFromEntry t2
    offset' = (fr + (sr - dr) + deltaR, fc)

    t1' = map (increaseSrcSpan (fr,fc)) t1

{-
--
-- | Process the leaf nodes of a tree to remove all deleted spans
deleteGapsToks' :: [Entry] -> [(SimpPos,String,ForestSpan,[PosToken])]
deleteGapsToks' toks = goDeleteGapsToks' (0,0) toks

goDeleteGapsToks' :: SimpPos -> [Entry] -> [(SimpPos,String,ForestSpan,[PosToken])]
goDeleteGapsToks'      _  []                    = [((0,0),  "N",nullSpan, [])]
goDeleteGapsToks' offset  [Entry ss _ t]        = [(offset,"E1",ss,map (increaseSrcSpan offset) t)]
goDeleteGapsToks'      _  [Deleted _ _]         = [((0,0),  "D1",nullSpan, [])]
goDeleteGapsToks' offset  (Deleted _ _:ts)      = (offset, "D0",nullSpan, []):goDeleteGapsToks' offset ts
goDeleteGapsToks' offset  [Entry ss _ t,Deleted _ _] = [(offset,"[ED]",ss,map (increaseSrcSpan offset) t)]
goDeleteGapsToks' offset  (Entry ss _ t1:e@(Entry _ _ _):ts) =(offset,"EE", ss, (map (increaseSrcSpan offset) t1)):goDeleteGapsToks' offset (e:ts)
goDeleteGapsToks' (fr,fc) (Entry ss _ t1:Deleted _ _:t2:ts)
  = ((fr,fc),"ED",ss,t1') : goDeleteGapsToks' offset' (t2:ts)
  where
    -- TODO: use actual first and last toks, may be comments
    -- TODO: what about deletion within a line?
    (_,(sr,_sc)) = forestSpanToSimpPos ss
    ((dr,_dc),_) = forestSpanToSimpPos $ forestSpanFromEntry t2
    offset' = (fr + sr - dr + 2, fc)
    -- offset' = (fr + sr - dr + 1, fc)

    t1' = map (increaseSrcSpan (fr,fc)) t1

--
-}

-- ---------------------------------------------------------------------

-- |Starting from a point in the zipper, retrieve all tokens backwards
-- until the line changes for a non-comment/non-empty token or
-- beginning of file.
retrievePrevLineToks :: Z.TreePos Z.Full Entry -> ReversedToks
retrievePrevLineToks z = RT res' -- error $ "retrievePrevLineToks:done notWhite=" ++ (show (done notWhite)) -- ++AZ++
  where
    -- Assuming the zipper has been opened to the span we care about,
    -- we will start with the tokens in the current tree, and work
    -- back.
    -- prevToks = retrieveTokens $ Z.tree z
    prevToks = retrieveTokensInterim $ Z.tree z

    -- Next one is the usual one
    -- res' = reverse $ (concat (go z)) ++ prevToks
    res' =  reverse $ concat $ reverse (prevToks : (go z))


    -- res' =  (reverse prevToks) ++ (concat (go z))

    -- res' = error $ "retrievePrevLineToks:res'=" ++ (show (dropWhile (\tok -> isWhiteSpace tok || tokenRow tok < endLine) res))
    -- res' = error $ "retrievePrevLineToks:prevToks=" ++ (show prevToks)
    -- res' = error $ "retrievePrevLineToks:prevToks=" ++ (show res)
    -- res' = error $ "retrievePrevLineToks:(prevToks : (go z))=" ++ (show (prevToks : (go z)))
    -- res' = error $ "retrievePrevLineToks:(prevToks : (go z))=" ++ (show $ concat $ reverse (prevToks : (go z)))

    -- TODO:  ++AZ++ what is this actually doing?
    go :: Z.TreePos Z.Full Entry -> [[PosToken]]
    go zz
      | not (Z.isRoot zz) = toks : (go $ gfromJust "retrievePrevLineToks" (Z.parent zz))
      | otherwise = [toks]
      where
        toks = concat $ reverse $ map retrieveTokensInterim $ Z.before zz
        -- toks = concat $ map retrieveTokensInterim $ Z.before zz


-- ---------------------------------------------------------------------

stripForestLines :: [PosToken] -> [PosToken]
stripForestLines toks = map doOne toks
  where
    doOne (GHC.L l t,s) = (GHC.L l' t,s)
      where
       ((ForestLine _ _ _ ls,_),(_,_)) = srcSpanToForestSpan l
       l' = insertForestLineInSrcSpan (ForestLine False 0 0 ls) l

-- ---------------------------------------------------------------------

stripForestLineFromGhc :: GHC.SrcSpan -> GHC.SrcSpan
stripForestLineFromGhc l = l'
  where
    ((ForestLine _ _ _ ls,_),(_,_)) = srcSpanToForestSpan l
    l' = insertForestLineInSrcSpan (ForestLine False 0 0 ls) l

-- ---------------------------------------------------------------------

reAlignMarked :: [PosToken] -> [PosToken]
reAlignMarked toks = concatMap alignOne $ groupTokensByLine toks
  where
    -- alignOne toksl = unmarked ++ (reAlignToks marked)
    alignOne toksl = unmarked ++ (reAlignOneLine marked)
     where
       (unmarked,marked) = break isMarked toksl

-- ---------------------------------------------------------------------

-- | Some tokens are marked if they belong to identifiers which have
-- been renamed. When the renaming takes place, no layout adjustment
-- is done. This function adjusts the spacing for the rest of the line
-- to match as far as possible the original spacing, except for the
-- name change.
reAlignOneLine :: [PosToken] -> [PosToken]
reAlignOneLine toks = go (0,0) toks
  where
    go _ [] = []
    go (l,c) (t:ts) = (increaseSrcSpan (l,c) t') : (go (l,c') ts)
      where
        (t',dc) = adjustToken t
        c' = c + dc

    adjustToken tt@(_,"") = (tt,0)
    adjustToken tt@(lt@(GHC.L _ t),s) = ((GHC.L newL t,s),deltac)
      where
        (sl,sc) = getLocatedStart lt
        (el,ec) = getLocatedEnd   lt
        deltac = (length s) - (ec - sc)

        filename = fileNameFromTok tt
        newL = GHC.mkSrcSpan (GHC.mkSrcLoc filename sl sc)
                             (GHC.mkSrcLoc filename el (ec + deltac))


reAlignToks :: [PosToken] -> [PosToken]
reAlignToks [] = []
reAlignToks [t] = [t]
reAlignToks (tok1@(_,""):ts) = tok1 : reAlignToks ts
reAlignToks (tok1@((GHC.L l1 _t1),_s1):tok2@((GHC.L l2 t2),s2):ts)
  = tok1:reAlignToks (tok2':ts)
   where
     ((_sr1,_sc1),(er1,ec1)) = (getGhcLoc l1,getGhcLocEnd l1)
     (( sr2, sc2),(er2,ec2)) = (getGhcLoc l2,getGhcLocEnd l2)

     ((sr,sc),(er,ec)) = if (er1 == sr2 && ec1 >= sc2)
              then ((sr2,ec1+1),(er2,ec1+1 + tokenLen tok2))
              else ((sr2,sc2),(er2,ec2))

     fname = case l2 of
               GHC.RealSrcSpan ss -> GHC.srcSpanFile ss
               _ -> GHC.mkFastString "foo"
     l2' = GHC.mkRealSrcSpan (GHC.mkRealSrcLoc fname sr sc)
                             (GHC.mkRealSrcLoc fname er ec)
     tok2' = ((GHC.L (GHC.RealSrcSpan l2') t2),s2)

-- ---------------------------------------------------------------------

-- |Add a new SrcSpan and Tokens after a given one in the token stream
-- and forest. This will be given a unique SrcSpan in return, which
-- specifically indexes into the forest.
addNewSrcSpanAndToksAfter ::
  Tree Entry -- ^The forest to update
  -> GHC.SrcSpan -- ^The new span comes after this one
  -> GHC.SrcSpan -- ^Existing span for the tokens
  -> Positioning
  -> [PosToken]  -- ^The new tokens belonging to the new SrcSpan
  -> (Tree Entry -- Updated forest with the new span
     , GHC.SrcSpan) -- ^Unique SrcSpan allocated in the forest to
                    -- identify this span in its position
addNewSrcSpanAndToksAfter forest oldSpan newSpan pos toks = (forest'',newSpan')
  where
    (forest',tree) = getSrcSpanForDeep forest (srcSpanToForestSpan oldSpan)

    (ghcl,_c) = getGhcLoc newSpan
    (ForestLine ch tr v l) = ghcLineToForestLine ghcl
    newSpan' = insertForestLineInSrcSpan (ForestLine ch tr (v+1) l) newSpan

    toks' = placeToksForSpan forest' oldSpan tree pos toks

    newNode = Node (Entry (srcSpanToForestSpan newSpan') NoChange toks') []

    forest'' = insertNodeAfter tree newNode forest'

-- ---------------------------------------------------------------------

placeToksForSpan ::
  Tree Entry
  -> GHC.SrcSpan
  -> Tree Entry
  -> Positioning
  -> [PosToken]
  -> [PosToken]
placeToksForSpan forest oldSpan tree pos toks = toks'
  where
    z = openZipperToSpanDeep (srcSpanToForestSpan oldSpan) $ Z.fromTree forest
    prevToks = case (retrievePrevLineToks z) of
                 RT [] -> reverseToks $ retrieveTokensInterim tree
                 xs -> xs

    prevToks' = limitPrevToks prevToks oldSpan
    toks' = reIndentToks pos (unReverseToks prevToks') toks
    -- toks' = error $ "placeToksForSpan: prevToks'=" ++ (show prevToks')
    -- toks' = error $ "placeToksForSpan: prevToks=" ++ (show prevToks)

-- ---------------------------------------------------------------------

-- |Add new tokens after the given SrcSpan, constructing a new SrcSpan
-- in the process
addToksAfterSrcSpan ::
  Tree Entry  -- ^TokenTree to be modified
  -> GHC.SrcSpan -- ^Preceding location for new tokens
  -> Positioning
  -> [PosToken] -- ^New tokens to be added
  -> (Tree Entry, GHC.SrcSpan) -- ^ updated TokenTree and SrcSpan location for
                               -- the new tokens in the TokenTree
addToksAfterSrcSpan forest oldSpan pos toks = (forest',newSpan')
  where
    (fwithspan,tree) = getSrcSpanForDeep forest (srcSpanToForestSpan oldSpan)

    toks'' = placeToksForSpan fwithspan oldSpan tree pos toks

    (startPos,endPos) = nonCommentSpan toks''

    newSpan = posToSrcSpan forest (startPos,endPos)

    (forest',newSpan') = addNewSrcSpanAndToksAfter forest oldSpan newSpan pos toks

-- ---------------------------------------------------------------------

limitPrevToks :: ReversedToks -> GHC.SrcSpan -> ReversedToks
limitPrevToks prevToks sspan = reverseToks prevToks''
  where
    ((ForestLine _ _ _ startRow,_startCol),(ForestLine _ _ _ endRow,_)) = srcSpanToForestSpan sspan

    -- Make sure the toks do not extend past where we are
    prevToks' = dropWhile (\t -> tokenRow t > endRow) $ unReverseToks prevToks

    -- Only use the toks for the given oldspan
    -- prevToks'' = dropWhile (\t -> tokenPos t < (startRow,startCol)) prevToks'
    prevToks'' = dropWhile (\t -> tokenRow t < startRow) prevToks'

-- ---------------------------------------------------------------------

-- |Add new tokens belonging to an AST fragment after a given SrcSpan,
-- and re-sync the AST fragment to match the new location
addDeclToksAfterSrcSpan :: (SYB.Data t) =>
     Tree Entry  -- ^TokenTree to be modified
  -> GHC.SrcSpan -- ^Preceding location for new tokens
  -> Positioning
  -> [PosToken] -- ^New tokens to be added
  -> GHC.Located t  -- ^Declaration the tokens belong to, to be synced
  -> (Tree Entry, GHC.SrcSpan,GHC.Located t) -- ^ updated TokenTree ,SrcSpan location for
  -- -> (Tree Entry, GHC.SrcSpan,t) -- ^ updated TokenTree ,SrcSpan location for
                               -- the new tokens in the TokenTree, and
                               -- updated AST element
addDeclToksAfterSrcSpan forest oldSpan pos toks t = (forest'',newSpan,t')
  where
    (forest',newSpan) = addToksAfterSrcSpan forest oldSpan pos toks
    (t',forest'') = syncAST t newSpan forest'

-- ---------------------------------------------------------------------


reIndentToks :: Positioning -> [PosToken] -> [PosToken] -> [PosToken]
reIndentToks _ _ [] = []
reIndentToks pos prevToks toks = toks''
  -- = error $ "reIndentToks:(pos,prevToks)=" ++ (show (pos,prevToks)) -- ++AZ++
  -- = error $ "reIndentToks:((isComment lastTok),(tokenRow lastNonCommentTok),lastTokEndLine)=" ++ (show ((isComment lastTok),(tokenRow lastNonCommentTok),lastTokEndLine))
  where
    newTokStart = ghead "reIndentToks.1"
                $ dropWhile (\tok -> isComment tok || isEmpty tok) $ toks

    firstTok = ghead "reIndentToks.2" toks
    lastTok  = glast "reIndentToks.1" prevToks

    lastNonCommentTok = ghead "reIndentToks.3"
                      $ dropWhile (\tok -> isComment tok || isEmpty tok) $ reverse prevToks

    prevOffset = getIndentOffset prevToks (tokenPos (glast "reIndentToks.2" prevToks))

    (lastTokEndLine,_) = tokenPosEnd lastTok


    (lineOffset,colOffset,endNewlines) = case pos of
      PlaceAdjacent -> (lineOffset',colOffset',0)
        where
          colStart  = (tokenColEnd (lastTok)) + 1
          lineStart = (tokenRow    (lastTok))

          lineOffset' = lineStart - (tokenRow firstTok)
          colOffset'  = colStart  - (tokenCol newTokStart)

      PlaceAbsolute row col -> (lineOffset', colOffset', 0)
        where
          lineOffset' = row - (tokenRow firstTok)
          colOffset'  = col - (tokenCol firstTok)

      PlaceAbsCol rowIndent col numLines -> (lineOffset', colOffset', numLines)
        where
          colOffset'  = col - (tokenCol firstTok)
          lineStart = (tokenRow (lastTok)) -- + 1

          lineOffset' = rowIndent + lineStart - (tokenRow firstTok)

      PlaceOffset rowIndent colIndent numLines -> (lineOffset',colOffset',numLines)
        where
          -- TODO: Should this not be prevOffset?
          colStart  = tokenCol $ ghead "reIndentToks.4"
                    $ dropWhile isWhiteSpaceOrIgnored prevToks
          -- colStart = prevOffset
          -- colStart = error $ "reIndentToks:prevToks=" ++ (show prevToks)

          lineStart = (tokenRow (lastTok)) -- + 1
          -- lineStart = error $ "reIndentToks:PlaceOffset:lastTok=" ++ show lastTok
          -- lineStart = error $ "reIndentToks:PlaceOffset:firstTok=" ++ show firstTok

          lineOffset' = rowIndent + lineStart - (tokenRow firstTok)
          colOffset'  = colIndent + colStart  - (tokenCol newTokStart)
          -- colOffset'  = error $ "reIndentToks:placeOffset lineOffset=" ++ show lineOffset

      PlaceIndent rowIndent colIndent numLines -> (lineOffset',colOffset',numLines)
        where
          colStart = prevOffset
          lineStart = if ((isComment lastTok) && (tokenRow lastNonCommentTok /= lastTokEndLine))
              then (tokenRow (lastTok)) + 1
              else (tokenRow (lastTok))

          lineOffset' = rowIndent + lineStart - (tokenRow firstTok)
          colOffset'  = colIndent + colStart  - (tokenCol newTokStart) + 1 -- ++AZ++ Why +1?

    toks'  = addOffsetToToks (lineOffset,colOffset) toks
    toks'' = if endNewlines > 0
               -- then toks' ++ [(newLinesToken endNewlines $ glast "reIndentToks.3" toks')]
               then toks' ++ [(newLinesToken (endNewlines - 1) $ glast "reIndentToks.3" toks')]
               else toks'

-- ---------------------------------------------------------------------

-- |Extract the start and end position of a span, without any leading
-- or trailing comments
nonCommentSpan :: [PosToken] -> (SimpPos,SimpPos)
nonCommentSpan [] = ((0,0),(0,0))
nonCommentSpan toks = (startPos,endPos)
  where
    stripped = dropWhile isIgnoredNonComment $ toks
    (startPos,endPos) = case stripped of
      [] -> ((0,0),(0,0))
      _ -> (tokenPos startTok,tokenPosEnd endTok)
       where
        startTok = ghead "nonCommentSpan.1" $ dropWhile isIgnoredNonComment $ toks
        endTok   = ghead "nonCommentSpan.2" $ dropWhile isIgnoredNonComment $ reverse toks

-- ---------------------------------------------------------------------

-- |Convert a simple (start,end) position to a SrcSpan belonging to
-- the file in the tree
posToSrcSpan :: Tree Entry -> (SimpPos,SimpPos) -> GHC.SrcSpan
posToSrcSpan forest ((rs,cs),(re,ce)) = sspan
  where
    (GHC.L l _,_) = ghead "posToSrcSpan"  $ retrieveTokensInterim forest -- ++AZ++ Ouch, performance??
    sspan =  case l of
      GHC.RealSrcSpan ss ->
        let
          locStart = GHC.mkSrcLoc (GHC.srcSpanFile ss) rs cs
          locEnd   = GHC.mkSrcLoc (GHC.srcSpanFile ss) re ce
        in
          GHC.mkSrcSpan locStart locEnd
      _ -> error "posToSrcSpan: invalid SrcSpan in first tok"

-- ---------------------------------------------------------------------

-- |Convert a simple (start,end) position to a SrcSpan belonging to
-- the file in the given token
posToSrcSpanTok :: PosToken -> (SimpPos,SimpPos) -> GHC.SrcSpan
posToSrcSpanTok tok ((rs,cs),(re,ce)) = sspan
  where
    (GHC.L l _,_) = tok
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
    zf = openZipperToNodeDeep oldNode $ Z.fromTree forest

    zp = gfromJust ("insertNodeAfter:" ++ (show (oldNode,newNode,forest))) $ Z.parent zf
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
--  NOTE: the node must already be in the tree
openZipperToNode
  :: Tree Entry
     -> Z.TreePos Z.Full Entry
     -> Z.TreePos Z.Full Entry
openZipperToNode (Node (Entry sspan _ _) _) z
  = openZipperToSpan sspan z
openZipperToNode (Node (Deleted sspan _ _) _) z
  = openZipperToSpan sspan z

-- |Open a zipper so that its focus is the given node
--  NOTE: the node must already be in the tree
openZipperToNodeDeep
  :: Tree Entry
     -> Z.TreePos Z.Full Entry
     -> Z.TreePos Z.Full Entry
openZipperToNodeDeep (Node (Entry sspan _ _) _) z
  = openZipperToSpanDeep sspan z
openZipperToNodeDeep (Node (Deleted sspan _ _) _) z
  = openZipperToSpanDeep sspan z


getChildrenAsZ :: Z.TreePos Z.Full a -> [Z.TreePos Z.Full a]
getChildrenAsZ z = go [] (Z.firstChild z)
  where
    go acc Nothing = acc
    go acc (Just zz) = go (acc ++ [zz]) (Z.next zz)

-- ---------------------------------------------------------------------

-- |Does the first span contain the second? Takes cognisance of the
-- various flags a ForestSpan can have.
-- NOTE: This function relies on the Eq instance for ForestLine
spanContains :: ForestSpan -> ForestSpan -> Bool
spanContains span1 span2 = (startPos <= nodeStart && endPos >= nodeEnd)
    where
        -- TODO: This looks like a no-op?
        (tvs,_tve) = forestSpanVersions $ span1
        (nvs,_nve) = forestSpanVersions $ span2
        (startPos,endPos)   = insertVersionsInForestSpan tvs tvs span1
        (nodeStart,nodeEnd) = insertVersionsInForestSpan nvs nvs span2

-- ---------------------------------------------------------------------

-- |Open a zipper so that its focus has the given SrcSpan in its
-- subtree, or the location where the SrcSpan should go, if it is not
-- in the tree
openZipperToSpan
  :: ForestSpan
     -> Z.TreePos Z.Full Entry
     -> Z.TreePos Z.Full Entry
openZipperToSpan sspan z
  | hasVersions = openZipperToSpanAdded sspan z
  | otherwise   = openZipperToSpanOrig sspan z
  where
    (vs,_ve) = forestSpanVersions sspan
    hasVersions = vs /= 0


-- ---------------------------------------------------------------------

-- |Open a zipper so that its focus has the given SrcSpan in its
-- subtree, or the location where the SrcSpan should go, if it is not
-- in the tree
openZipperToSpanOrig
  :: ForestSpan
     -> Z.TreePos Z.Full Entry
     -> Z.TreePos Z.Full Entry
openZipperToSpanOrig sspan z
  = if (treeStartEnd (Z.tree z) == sspan) || (Z.isLeaf z)
      then z
      else z'
        where
          -- go through all of the children to find the one that
          -- either is what we are looking for, or contains it

          -- childrenAsZ = go [] (Z.firstChild z)
          childrenAsZ = getChildrenAsZ z
          z' = case (filter contains childrenAsZ) of
            [] -> z -- Not directly in a subtree, this is as good as
                    -- it gets
            [x] -> -- exactly one, drill down
                   openZipperToSpan sspan x

            xx  -> case (filter (\zt -> (treeStartEnd $ Z.tree zt) == sspan) xx) of 
                    [] -> -- more than one matches, see if we can get
                          -- rid of the ones that have been lengthened
                          case (filter (not .forestSpanLenChanged . treeStartEnd . Z.tree) xx) of
                            [] -> z -- we tried...
                            [w] -> openZipperToSpan sspan w
                            -- ww -> error $ "openZipperToSpan:can't resolve:(sspan,ww)="++(show (sspan,ww))
                            ww -> -- more than one candidate, break
                                  -- the tie on version match
                                  case (filter (\zt -> matchVersions sspan zt) ww) of
                                     [v] -> openZipperToSpan sspan v
                                     _   -> error $ "openZipperToSpan:can't resolve:(sspan,ww)="++(show (sspan,map (\zt -> treeStartEnd $ Z.tree zt) ww))
                    [y] -> openZipperToSpan sspan y
                    yy -> -- Multiple, check if we can separate out by
                          -- version
                          case (filter (\zt -> (fst $ forestSpanVersions $ treeStartEnd $ Z.tree zt) == (fst $ forestSpanVersions sspan)) xx) of
                           -- [] -> z
                           [] -> error $ "openZipperToSpan:no version match:(sspan,yy)=" ++ (show (sspan,yy)) -- ++AZ++
                           [w] -> openZipperToSpan sspan w
                           _ww -> error $ "openZipperToSpan:multiple version match:" ++ (show (sspan,yy)) -- ++AZ++

          contains zn = spanContains (treeStartEnd $ Z.tree zn) sspan

          matchVersions span1 z2 = isMatch
            where
              span2 = treeStartEnd $ Z.tree z2
              isMatch = forestSpanVersions span1 == forestSpanVersions span2

-- ---------------------------------------------------------------------

-- |Open a zipper so that its focus has the given SrcSpan in its
-- subtree, or the location where the SrcSpan should go, if it is not
-- in the tree.
-- In the case of an 'Above' layout with the same SrcSpan below,
-- return that instead
openZipperToSpanDeep
  :: ForestSpan
     -> Z.TreePos Z.Full Entry
     -> Z.TreePos Z.Full Entry
openZipperToSpanDeep sspan z = zf
  where
    z' = openZipperToSpan sspan z

    zf = case Z.tree z' of
           (Node (Entry _ (Above _ _ _ _) _) _) ->
                case getChildrenAsZ z' of
                  []  -> z'
                  [x] -> if (treeStartEnd (Z.tree x) == sspan) then x else z'
                  _   -> z'
           _ -> z'


-- ---------------------------------------------------------------------

-- |Open a zipper to a SrcSpan that has been added in the tree, and
-- thus does not necessarily fall in the logical hierarchy of the tree
openZipperToSpanAdded
  :: ForestSpan
     -> Z.TreePos Z.Full Entry
     -> Z.TreePos Z.Full Entry
openZipperToSpanAdded sspan z = zf
  where
    treeAsList = getTreeSpansAsList $ Z.tree z

    -- True if first span contains the second
    myMatch (((ForestLine _ _ vs1 rs1),cs1),((ForestLine _ _ ve1 re1),ce1))
            (((ForestLine _ _ vs2 rs2),cs2),((ForestLine _ _ ve2 re2),ce2))
      = vs1 == vs2 && ve1 == ve2 && ((rs1,cs1) <= (rs2,cs2)) && ((re1,ce1) >= (re2,ce2))
    tl2 = dropWhile (\(_,s) -> not (myMatch s sspan)) $ reverse treeAsList

    fff [] _ = []
    fff acc@((cd,_cs):_) (v,sspan') = if v < cd then (v,sspan'):acc
                                               else acc

    tl3 = foldl' fff [(head tl2)] tl2
    -- tl3 now contains the chain of ForestSpans to open in order in the zipper

    zf = foldl' (flip openZipperToSpanOrig) z $ map snd tl3

-- ---------------------------------------------------------------------

getTreeSpansAsList :: Tree Entry -> [(Int,ForestSpan)]
getTreeSpansAsList = getTreeSpansAsList' 0

getTreeSpansAsList' :: Int -> Tree Entry -> [(Int,ForestSpan)]
getTreeSpansAsList' level (Node (Deleted sspan  _pg _eg )  _  )   = [(level,sspan)]
getTreeSpansAsList' level (Node (Entry sspan _lay _toks) ts0) = (level,sspan)
                       : (concatMap (getTreeSpansAsList' (level + 1)) ts0)


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

    inBeginTrees tree = spanStart >= treeEnd
      where
        (_treeStart,treeEnd) = treeStartEnd tree

    inEndTrees tree = spanEnd <= treeStart
      where
        (treeStart,_treeEnd) = treeStartEnd tree



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

{-
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
-}

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
--   5. There are no nullSpan entries in the tree
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
    checkNode _acc (Node (Deleted _sspan _ _) []) = []
    checkNode _acc node@(Node (Deleted _sspan _ _) _sub)
         = ["FAIL: deleted node with subtree: " ++ (prettyshow node)]
    checkNode acc node@(Node (Entry sspan _lay toks) sub) = acc ++ r ++ rinc ++ rsubs ++ rnull
      where
        r = if (   emptyList toks && nonEmptyList sub) ||
               (nonEmptyList toks &&    emptyList sub)
              then []
              else ["FAIL: exactly one of toks or subforest must be empty: " ++ (prettyshow node)]
        rsubs = foldl' checkNode [] sub

        rinc = checkInclusion node

        rnull = if (sspan == nullSpan)
                 then ["FAIL: null SrcSpan in tree: " ++ (prettyshow node)]
                 else []

    -- |Check invariant 2, assuming 1 ok
    --  NOTE: check that the subtree spans do not go outside the node
    --  span, they do not need to completely fill it, because some may
    --  have been removed during manipulation
    checkInclusion      (Node _                    []) = []
    checkInclusion      (Node (Deleted _ _ _)       _) = []
    checkInclusion node@(Node (Entry _sspan _lay _toks)  sub) = rs ++ rseq
      where
        (start,end) = treeStartEnd node
        subs = map treeStartEnd sub
        (sstart, _) = ghead "invariant" subs
        (_, send) = last subs
        -- Do not count any custom added srcspans at the end for this
        -- test
        -- TODO: is this a reasonable approach?

        rs = if ((start <= sstart) &&
                ((end >= send) || (forestPosVersionSet send) || (forestPosAstVersionSet send)))
                || (forestPosLenChanged start)
                || (forestPosLenChanged sstart)
                || (forestPosLenChanged send)

               then []
               else ["FAIL: subForest start and end does not match entry: " ++ (prettyshow node)]
               -- else ["FAIL: subForest start and end does not match entry: " ++ (show node)]

        rseq = checkSequence node subs

        checkSequence :: Tree Entry -> [ForestSpan] -> [String]
        checkSequence _ [] = []
        checkSequence _ [_x] = []
        checkSequence node' ((_s1,e1):s@(s2,_e2):ss)
          = r ++ checkSequence node' (s:ss)
          where
            -- r = if e1 <= s2
            r = if (before e1 s2) || (sizeChanged e1) {- ++AZ++ -} || (sizeChanged s2)
                 then []
                 else ["FAIL: subForest not in order: " ++
                        show e1 ++ " not < " ++ show s2 ++
                        ":" ++ prettyshow node']

            -- |Compare end of one span with beginning of another
            before (ForestLine _chs _trs ve er,ec) (ForestLine _che _tre vs sr,sc)
              = case (ve /= 0, vs /= 0) of
                 (False, False) -> (er,ec) <= (sr,sc) -- e.g. (10,3) <= (11,5)
                 (False, True)  -> True               -- e.g. (10,3) <= (100011,5)
                 (True, False)  -> True               -- e.g. (100010,3) <= (11,5)
                 (True, True)   -> if vs < ve         -- both have version, lowest wins 
                                    then False
                                    else True

            sizeChanged (ForestLine ch _ _ _,_) = ch

{-
     cs    ce
     True  _ -> True
     False _ -> before

-}

-- ---------------------------------------------------------------------

-- |Get the start and end position of a Tree
-- treeStartEnd :: Tree Entry -> (SimpPos,SimpPos)
-- treeStartEnd (Node (Entry sspan _) _) = (getGhcLoc sspan,getGhcLocEnd sspan)
treeStartEnd :: Tree Entry -> ForestSpan
treeStartEnd (Node (Entry sspan _ _) _) = sspan
treeStartEnd (Node (Deleted sspan _ _) _) = sspan

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

-- |Call drawTreeEntry on the entire token cache
drawTokenCache :: TokenCache -> String
drawTokenCache tk = Map.foldlWithKey' doOne "" (tkCache tk)
  where
    doOne :: String -> TreeId -> Tree Entry -> String
    doOne s key val = s ++ "tree " ++ (show key) ++ ":\n"
                        ++ (drawTreeEntry val)

-- ---------------------------------------------------------------------

-- |Call drawTreeEntry on the entire token cache
drawTokenCacheDetailed :: TokenCache -> String
drawTokenCacheDetailed tk = Map.foldlWithKey' doOne "" (tkCache tk)
  where
    doOne :: String -> TreeId -> Tree Entry -> String
    doOne s key val = s ++ "tree " ++ (show key) ++ ":\n"
                        ++ (show val)

-- ---------------------------------------------------------------------
-- | Neat 2-dimensional drawing of a tree.
drawTreeEntry :: Tree Entry -> String
drawTreeEntry  = unlines . drawEntry

-- | Neat 2-dimensional drawing of a forest.
drawForestEntry :: Forest Entry -> String
drawForestEntry  = unlines . map drawTreeEntry

drawEntry :: Tree Entry -> [String]
drawEntry (Node (Deleted sspan  _pg eg )  _ ) = [(showForestSpan sspan) ++ (show eg) ++ "D"]
drawEntry (Node (Entry sspan lay _toks) ts0) = ((showForestSpan sspan) ++ (showLayout lay)): drawSubTrees ts0
  where
    drawSubTrees [] = []
    drawSubTrees [t] =
        "|" : shft "`- " "   " (drawEntry t)
    drawSubTrees (t:ts) =
        "|" : shft "+- " "|  " (drawEntry t) ++ drawSubTrees ts

    shft first other = zipWith (++) (first : repeat other)

showLayout :: Layout -> String
showLayout NoChange       = ""
showLayout (Above so p1 (r,c) eo) = "(Above "++ show so ++ " " ++ show p1 ++ " " ++ show (r,c) ++ " " ++ show eo ++ ")"
-- showLayout (Offset r c)   = "(Offset " ++ show r ++ " " ++ show c ++ ")"

-- ---------------------------------------------------------------------

drawTreeCompact :: Tree Entry -> String
drawTreeCompact = unlines . drawTreeCompact' 0

drawTreeCompact' :: Int -> Tree Entry -> [String]
drawTreeCompact' level (Node (Deleted sspan _pg eg )  _  ) = [(show level) ++ ":" ++ (showForestSpan sspan) ++ (show eg) ++ "D"]
drawTreeCompact' level (Node (Entry sspan lay _toks) ts0) = ((show level) ++ ":" ++ (showForestSpan sspan) ++ (showLayout lay))
                                                          : (concatMap (drawTreeCompact' (level + 1)) ts0)

-- ---------------------------------------------------------------------

showTree :: Tree Entry -> String
showTree = prettyshow

-- |Represent a tree in a more concise/pretty way
prettyshow :: Tree Entry -> String
prettyshow (Node (Deleted sspan _pg eg) _nullSubs)
  = "Node (Deleted " ++ (showForestSpan sspan) ++ " " ++ (show eg) ++ ")"
prettyshow (Node (Entry sspan _lay toks) sub)
  = "Node (Entry " ++ (showForestSpan sspan) ++ " "
     ++ (prettyToks toks) ++ ") "
     -- ++ show (map prettyshow sub)
     ++ "[" ++ intercalate "," (map prettyshow sub) ++ "]"

prettyToks :: [PosToken] -> String
prettyToks [] = "[]"
prettyToks toks@[_x] = showToks toks
prettyToks toks@[_t1,_t2] = showToks toks
prettyToks toks = showToks [ghead "prettyToks" toks] ++ ".." ++ showToks [last toks]

-- ---------------------------------------------------------------------

-- |Make a tree representing a particular set of tokens
mkTreeFromTokens :: [PosToken] -> Tree Entry
mkTreeFromTokens []   = Node (Entry nullSpan NoChange []) []
mkTreeFromTokens toks = Node (Entry sspan NoChange toks) []
  where
   (startLoc',endLoc') = nonCommentSpan toks
   sspan    = if (startLoc',endLoc') == ((0,0),(0,0))
     then error $ "mkTreeFromTokens:null span for:" ++ (show toks)
     else simpPosToForestSpan (startLoc',endLoc')

-- ---------------------------------------------------------------------

-- |Make a tree representing a particular set of tokens
mkTreeFromSpanTokens :: ForestSpan -> [PosToken] -> Tree Entry
mkTreeFromSpanTokens sspan toks = Node (Entry sspan NoChange toks) []

-- ---------------------------------------------------------------------

ghcSpanStartEnd :: GHC.SrcSpan -> ((Int, Int), (Int, Int))
ghcSpanStartEnd sspan = (getGhcLoc sspan,getGhcLocEnd sspan)

-- ---------------------------------------------------------------------

-- |Synchronise a located AST fragment to use a newly created SrcSpan
-- in the token tree.
-- TODO: Should this indent the tokens as well?
syncAST :: (SYB.Data t)
  => GHC.Located t -- ^The AST (or fragment)
  -> GHC.SrcSpan   -- ^The SrcSpan created in the Tree Entry
  -> Tree Entry    -- ^Existing token tree
  -> (GHC.Located t, Tree Entry) -- ^Updated AST and tokens
syncAST ast@(GHC.L l _t) sspan forest = (GHC.L sspan xx,forest')
  where
    forest' = forest

    (( sr, sc),( _er, _ec)) = ghcSpanStartEnd l
    ((nsr,nsc),(_ner,_nec)) = ghcSpanStartEnd sspan

    rowOffset = nsr - sr
    colOffset = nsc - sc

    -- TODO: take cognizance of the ForestLines encoded in srcspans
    -- when calculating the offsets etc
    syncSpan s  = addOffsetToSpan (rowOffset,colOffset) s

    (GHC.L _s xx) = everywhereStaged SYB.Renamer (
              SYB.mkT hsbindlr
              `SYB.extT` sig
              `SYB.extT` ty
              `SYB.extT` name
              `SYB.extT` lhsexpr
              `SYB.extT` lpat
              `SYB.extT` limportdecl
              `SYB.extT` lmatch
              ) ast

    hsbindlr (GHC.L s b)    = (GHC.L (syncSpan s) b) :: GHC.Located (GHC.HsBindLR GHC.Name GHC.Name)
    sig (GHC.L s n)         = (GHC.L (syncSpan s) n) :: GHC.LSig GHC.Name
    ty (GHC.L s typ)        = (GHC.L (syncSpan s) typ) :: (GHC.LHsType GHC.Name)
    name (GHC.L s n)        = (GHC.L (syncSpan s) n) :: GHC.Located GHC.Name
    lhsexpr (GHC.L s e)     = (GHC.L (syncSpan s) e) :: GHC.LHsExpr GHC.Name
    lpat (GHC.L s p)        = (GHC.L (syncSpan s) p) :: GHC.LPat GHC.Name
    limportdecl (GHC.L s n) = (GHC.L (syncSpan s) n) :: GHC.LImportDecl GHC.Name
    lmatch (GHC.L s m)      = (GHC.L (syncSpan s) m) :: GHC.LMatch GHC.Name

-- ---------------------------------------------------------------------

-- | indent the tree and tokens by the given offset, and sync the AST
-- to the tree too.
indentDeclToks :: (SYB.Data t)
  => GHC.Located t -- ^The AST (or fragment)
  -> Tree Entry    -- ^Existing token tree
  -> Int           -- ^ (signed) number of columns to indent/dedent
  -> (GHC.Located t, Tree Entry) -- ^Updated AST and tokens
indentDeclToks decl@(GHC.L sspan _) forest offset = (decl',forest'')
  where
    -- make sure the span is in the forest
    (forest',tree) = getSrcSpanFor forest (srcSpanToForestSpan sspan)

    z = openZipperToSpan (srcSpanToForestSpan sspan) $ Z.fromTree forest'

    tree' = go tree
    -- The invariant will fail if we do not propagate this change
    -- upward. But it needs to sync with the AST, which we do not have
    -- the upward version of.
    -- Instead, set the lengthChanged flag, in the parent.

    -- sss = forestSpanFromEntry entry
    -- sss' = insertLenChangedInForestSpan True sss
    -- tree'' = Node (putForestSpanInEntry entry sss') subs

    markLenChanged (Node entry subs) = (Node entry' subs)
      where
        sss = forestSpanFromEntry entry
        sss' = insertLenChangedInForestSpan True sss
        entry' = putForestSpanInEntry entry sss'

    z' = Z.setTree tree' z
    -- forest'' = Z.toTree (Z.setTree tree'' z)

    forest'' = case Z.parent z' of
                Nothing  -> Z.toTree (Z.setTree (markLenChanged $ Z.tree z' ) z' )
                Just z'' -> Z.toTree (Z.setTree (markLenChanged $ Z.tree z'') z'')


    (decl',_) = syncAST decl (addOffsetToSpan off sspan) tree

    off = (0,offset)

    -- Pretty sure this could be a fold of some kind
    go (Node (Deleted ss pg eg) sub) = (Node (Deleted (addOffsetToForestSpan off ss) pg eg) sub)
    go (Node (Entry ss lay [])  sub) = (Node (Entry (addOffsetToForestSpan off ss) lay []) (map go sub))
    go (Node (Entry ss lay toks) []) = (Node (Entry (addOffsetToForestSpan off ss) lay (addOffsetToToks off toks)) [])
    go n = error $ "indentDeclToks:strange node:" ++ (show n)

-- ---------------------------------------------------------------------

addOffsetToForestSpan :: (Int,Int) -> ForestSpan -> ForestSpan
addOffsetToForestSpan (lineOffset,colOffset) fspan = fspan'
  where
    ((ForestLine sch str sv sl,sc),(ForestLine ech etr ev el,ec)) = fspan
    fspan' = ((ForestLine sch str sv (sl+lineOffset),sc+colOffset),
              (ForestLine ech etr ev (el+lineOffset),ec+colOffset))

-- ---------------------------------------------------------------------

addOffsetToSpan :: (Int,Int) -> GHC.SrcSpan -> GHC.SrcSpan
addOffsetToSpan (lineOffset,colOffset) sspan = sspan'
  where
   sspan' =  case sspan of
     GHC.RealSrcSpan ss ->
       let
         locStart = GHC.mkSrcLoc (GHC.srcSpanFile ss) (lineOffset + GHC.srcSpanStartLine ss) (colOffset + GHC.srcSpanStartCol ss) 
         locEnd   = GHC.mkSrcLoc (GHC.srcSpanFile ss) (lineOffset + GHC.srcSpanEndLine ss)  (colOffset + GHC.srcSpanEndCol ss) 
       in
         GHC.mkSrcSpan locStart locEnd
     _ -> sspan

-- ---------------------------------------------------------------------

showSrcSpan :: GHC.SrcSpan -> String
showSrcSpan sspan = show (getGhcLoc sspan, (r,c))
  where
    (r,c) = getGhcLocEnd sspan

showSrcSpanF :: GHC.SrcSpan -> String
showSrcSpanF sspan = show (((chs,trs,vs,ls),cs),((che,tre,ve,le),ce))
  where
    ((ForestLine chs trs vs ls,cs),(ForestLine che tre ve le,ce)) = srcSpanToForestSpan sspan
    -- chsn = if chs then 1 else 0
    -- chen = if che then 1 else 0


-- ---------------------------------------------------------------------

sf :: GHC.SrcSpan -> ForestSpan
sf = srcSpanToForestSpan

fs :: ForestSpan -> GHC.SrcSpan
fs = forestSpanToSrcSpan


-- | ForestSpan version of GHC combineSrcSpans
combineSpans :: ForestSpan -> ForestSpan -> ForestSpan
combineSpans fs1 fs2 = fs'
  where
    [lowFs,highFs] = sort [fs1,fs2]
    ((ForestLine  chls  trls  vls  lls ,cls),(ForestLine _chle _trle _vle _lle,_cle)) = lowFs
    ((ForestLine _chhs _trhs _vhs _lhs,_chs),(ForestLine  chhe  trhe  vhe  lhe, che)) = highFs

    fs' = ((ForestLine chls trls vls lls,cls),(ForestLine chhe trhe vhe lhe,che))

{-
-- | Combines two 'SrcSpan' into one that spans at least all the characters
-- within both spans. Assumes the "file" part is the same in both inputs
combineSrcSpans :: SrcSpan -> SrcSpan -> SrcSpan
combineSrcSpans (UnhelpfulSpan _) r = r -- this seems more useful
combineSrcSpans l (UnhelpfulSpan _) = l
combineSrcSpans (RealSrcSpan span1) (RealSrcSpan span2)
    = RealSrcSpan (combineRealSrcSpans span1 span2)

-- | Combines two 'SrcSpan' into one that spans at least all the characters
-- within both spans. Assumes the "file" part is the same in both inputs
combineRealSrcSpans :: RealSrcSpan -> RealSrcSpan -> RealSrcSpan
combineRealSrcSpans span1 span2
 = if line_start == line_end
   then if col_start == col_end
        then SrcSpanPoint     file line_start col_start
        else SrcSpanOneLine   file line_start col_start col_end
   else      SrcSpanMultiLine file line_start col_start line_end col_end
  where
    (line_start, col_start) = min (srcSpanStartLine span1, srcSpanStartCol span1)
                                  (srcSpanStartLine span2, srcSpanStartCol span2)
    (line_end, col_end)     = max (srcSpanEndLine span1, srcSpanEndCol span1)
                                  (srcSpanEndLine span2, srcSpanEndCol span2)
    file = srcSpanFile span1


-}

-- EOF
