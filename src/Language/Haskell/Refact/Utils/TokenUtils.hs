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
       , Positioning(..)
       , initTokenCache
       , getTokensFor
       , getTokensBefore
       , updateTokensForSrcSpan
       , treeStartEnd
       , insertSrcSpan
       , removeSrcSpan
       , getSrcSpanFor
       -- , getPathFor
       , retrieveTokens
       , addNewSrcSpanAndToksAfter
       , addToksAfterSrcSpan
       , addDeclToksAfterSrcSpan

       -- * Token Tree Selection
       , treeIdFromForestSpan
       , putToksInCache
       , removeToksFromCache
       , getTreeFromCache
       , replaceTreeInCache
       , syncAstToLatestCache

       -- * Token marking and re-alignment
       , tokenFileMark
       , markToken
       , isMarked
       , reAlignMarked

       -- * Utility
       , posToSrcSpan
       , posToSrcSpanTok

       -- * AST tie up
       , syncAST


       -- * Internal, for testing
       , splitForestOnSpan
       -- , lookupSrcSpan
       , invariantOk
       , invariant
       , mkTreeFromTokens
       , mkTreeFromSpanTokens
       , showForest
       , showTree
       , showSrcSpan
       , ghcSpanStartEnd
       , insertNodeAfter
       , retrievePrevLineToks
       , openZipperToNode
       , openZipperToSpan
       , forestSpanToSimpPos
       , forestSpanToGhcPos

       , ghcLineToForestLine
       , forestLineToGhcLine
       , forestPosVersionSet
       , forestPosVersionNotSet
       , forestSpanVersions
       , forestSpanVersionSet
       , forestSpanVersionNotSet
       , insertForestLineInSrcSpan
       , srcSpanToForestSpan
       , nullSpan
       , simpPosToForestSpan
       , showForestSpan

       -- * Based on Data.Tree
       , drawTreeEntry
       , drawTokenCache
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
       , divideComments
       , isWhiteSpace
       , notWhiteSpace
       , isComment
       , getSrcSpan
       , getIndentOffset
       , splitOnNewLn
       , tokenLen
       , newLnToken
       , newLinesToken
       , groupTokensByLine
       , reAlignToks
       , reSequenceToks
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
import qualified Data.Map as Map
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

-- |How new SrcSpans should be inserted in the Token tree, relative to
-- the prior span
data Positioning = PlaceAdjacent -- ^Only a single space between the
                   -- end of the prior span and the new one
                 | PlaceAbsolute Int Int -- ^Start at the specified
                   -- line and col
                 | PlaceOffset Int Int Int -- ^Line and Col offset for
                   -- start, num lines to add at the end
                   -- relative to the indent level of the prior span
                 | PlaceIndent Int Int Int -- ^Line and Col offset for
                   -- start, num lines to add at the end
                   -- relative to the indent level of the prior line
                 deriving (Show)

-- ---------------------------------------------------------------------

{-
-- ++AZ++ TODO: will we actuall need these?
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
-- The encoding will be 
--   bottom 6 digits : the original source line
--   next 2 : the InsertVersion
--   top 2 : the AST identifier.
-- This gives us up to 99 insert versions and 20 different ASTs
--  NOTE: suspect the AST limit may prove problematic
--
forestConstant :: Int
forestConstant = 1000000

forestTreeConstant :: Int
forestTreeConstant = 100*forestConstant

forestVersionDivisor :: Int
forestVersionDivisor = 100

maxForestVersion :: Int
maxForestVersion = 99

maxASTTree :: Int
maxASTTree = 20

{-
This has been moved to TokenUtilsTypes

data ForestLine = ForestLine
                  { flTreeSelector :: Int
                  , flInsertVersion :: Int
                  , flLine :: Int
                  } deriving (Eq,Show)
-}

-- | Extract an encoded ForestLine from a GHC line
ghcLineToForestLine :: Int -> ForestLine
ghcLineToForestLine l = ForestLine tr v l'
  where
    l' = (mod l forestConstant)
    v  = (div l forestConstant) `mod` forestVersionDivisor
    tr = (div l forestTreeConstant)

forestLineToGhcLine :: ForestLine -> Int
forestLineToGhcLine fl = ((flTreeSelector  fl) * forestTreeConstant
                        + (flInsertVersion fl) * forestConstant)
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
  compare (ForestLine _ v1 l1) (ForestLine _ v2 l2) =
    if (l1 == l2)
      then compare v1 v2
      else compare l1 l2

-- |Gets the version numbers
forestSpanVersions :: ForestSpan -> (Int,Int)
forestSpanVersions ((ForestLine _ sv _,_),(ForestLine _ ev _,_)) = (sv,ev)

-- |Gets the AST tree numbers
forestSpanAstVersions :: ForestSpan -> (Int,Int)
forestSpanAstVersions ((ForestLine trs _ _,_),(ForestLine tre _ _,_)) = (trs,tre)

-- |Checks if the version is non-zero in either position
forestSpanVersionSet :: ForestSpan -> Bool
forestSpanVersionSet ((ForestLine _ sv _,_),(ForestLine _ ev _,_)) = sv /= 0 || ev /= 0

-- |Checks if the version is zero in both positions
forestSpanVersionNotSet :: ForestSpan -> Bool
forestSpanVersionNotSet ((ForestLine _ sv _,_),(ForestLine _ ev _,_)) = sv == 0 && ev == 0

-- |Checks if the version is non-zero
forestPosVersionSet :: ForestPos -> Bool
forestPosVersionSet (ForestLine _ v _,_) = v /= 0

-- |Checks if the version is zero
forestPosVersionNotSet :: ForestPos -> Bool
forestPosVersionNotSet (ForestLine _ v _,_) = v == 0

-- |Puts a TreeId into a forestSpan
treeIdIntoForestSpan :: TreeId -> ForestSpan -> ForestSpan
treeIdIntoForestSpan (TId sel) ((ForestLine _ sv sl,sc),(ForestLine _ ev el,ec))
  = ((ForestLine sel sv sl,sc),(ForestLine sel ev el,ec))


-- |Strip out the version markers
forestSpanToSimpPos :: ForestSpan -> (SimpPos,SimpPos)
forestSpanToSimpPos ((ForestLine _ _ sr,sc),(ForestLine _ _ er,ec)) = ((sr,sc),(er,ec))

-- |Strip out the version markers
forestSpanToGhcPos :: ForestSpan -> (SimpPos,SimpPos)
forestSpanToGhcPos ((fls,sc),(fle,ec))
  = ((forestLineToGhcLine fls,sc),(forestLineToGhcLine fle,ec))


simpPosToForestSpan :: (SimpPos,SimpPos) -> ForestSpan
simpPosToForestSpan ((sr,sc),(er,ec))
    = ((ghcLineToForestLine sr,sc),(ghcLineToForestLine er,ec))

nullSpan :: ForestSpan
nullSpan = ((ForestLine 0 0 0,0),(ForestLine 0 0 0,0))

showForestSpan :: ForestSpan -> String
showForestSpan ((sr,sc),(er,ec))
  = show ((forestLineToGhcLine sr,sc),(forestLineToGhcLine er,ec))

-- ---------------------------------------------------------------------

insertForestLineInSrcSpan :: ForestLine -> GHC.SrcSpan -> GHC.SrcSpan
insertForestLineInSrcSpan fl@(ForestLine tr v _l) (GHC.RealSrcSpan ss) = ss'
  where
    lineStart = forestLineToGhcLine fl
    lineEnd   = forestLineToGhcLine (ForestLine tr v (GHC.srcSpanEndLine ss))
    locStart = GHC.mkSrcLoc (GHC.srcSpanFile ss) lineStart (GHC.srcSpanStartCol ss)
    locEnd   = GHC.mkSrcLoc (GHC.srcSpanFile ss) lineEnd   (GHC.srcSpanEndCol ss)
    ss' = GHC.mkSrcSpan locStart locEnd

insertForestLineInSrcSpan _ ss = error $ "insertForestLineInSrcSpan: expecting a RealSrcSpan, got:" ++ (GHC.showPpr ss)

-- ---------------------------------------------------------------------

insertVersionsInSrcSpan :: Int -> Int -> GHC.SrcSpan -> GHC.SrcSpan
insertVersionsInSrcSpan vs ve rss@(GHC.RealSrcSpan ss) = ss'
  where
    (trs,tre) = forestSpanAstVersions $ srcSpanToForestSpan rss
    lineStart = forestLineToGhcLine (ForestLine trs vs (GHC.srcSpanStartLine ss))
    lineEnd   = forestLineToGhcLine (ForestLine tre ve (GHC.srcSpanEndLine ss))
    locStart = GHC.mkSrcLoc (GHC.srcSpanFile ss) lineStart (GHC.srcSpanStartCol ss)
    locEnd   = GHC.mkSrcLoc (GHC.srcSpanFile ss) lineEnd   (GHC.srcSpanEndCol ss)
    ss' = GHC.mkSrcSpan locStart locEnd

insertVersionsInSrcSpan _ _ ss = error $ "insertVersionsInSrcSpan: expecting a RealSrcSpan, got:" ++ (GHC.showPpr ss)

-- ---------------------------------------------------------------------

srcSpanToForestSpan :: GHC.SrcSpan -> ForestSpan
srcSpanToForestSpan sspan = ((ghcLineToForestLine startRow,startCol),(ghcLineToForestLine endRow,endCol))
  where
    (startRow,startCol) = getGhcLoc sspan
    (endRow,endCol) = getGhcLocEnd sspan

-- --------------------------------------------------------------------

treeIdFromForestSpan :: ForestSpan -> TreeId
treeIdFromForestSpan ((ForestLine tr _ _,_),(ForestLine _ _ _,_)) = TId tr

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


-- ---------------------------------------------------------------------

treeIdIntoTree :: TreeId -> Tree Entry -> Tree Entry
treeIdIntoTree tid tree@(Node (Entry fs toks) subTree) = tree'
  where
    fs' = treeIdIntoForestSpan tid fs
    tree' = Node (Entry fs' toks) subTree

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

putToksInCache :: TokenCache -> GHC.SrcSpan -> [PosToken] -> (TokenCache,GHC.SrcSpan)
putToksInCache tk sspan toks = (tk'',newSpan)
  where
   forest = getTreeFromCache sspan tk
   (forest',newSpan,oldTree) = updateTokensForSrcSpan forest sspan toks
   tk' = replaceTreeInCache sspan forest' tk
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
    tree' = treeIdIntoTree tid tree
    tk' = tk {tkCache = Map.insert tid tree' (tkCache tk) }

-- ---------------------------------------------------------------------

-- |Assuming most recent operation has stashed the old tokens, sync
-- the given AST to the most recent stash entry
syncAstToLatestCache :: (SYB.Data t) => TokenCache -> GHC.Located t -> GHC.Located t
syncAstToLatestCache tk t = t'
  -- = error $ "syncAstToLatestCache:pos=" ++ (show pos)
  -- = error $ "syncAstToLatestCache:fs=" ++ (show fs)
  where
    mainForest = (tkCache tk) Map.! mainTid
    forest@(Node (Entry fs _) _) = (tkCache tk) Map.! (tkLastTreeId tk)
    pos = forestSpanToGhcPos fs
    sspan = posToSrcSpan mainForest pos
    (t',_) = syncAST t sspan forest

-- ---------------------------------------------------------------------

-- |Get the (possible cached) tokens for a given source span, and
-- cache their being fetched.
-- NOTE: The SrcSpan may be one introduced by HaRe, rather than GHC.
-- TODO: consider returning an Either. Although in reality the error
--       should never happen
getTokensFor :: Tree Entry -> GHC.SrcSpan -> (Tree Entry,[PosToken])
getTokensFor forest sspan = (forest'', tokens)
  where
     forest' = if invariantOk forest -- TODO: remove this, expensive operation
               then forest
               else error $ "getTokensFor:invariant failed:" ++ (show $ invariant forest)
     (forest'',tree) = getSrcSpanFor forest' (srcSpanToForestSpan sspan)

     tokens = retrieveTokens tree

-- ---------------------------------------------------------------------

-- |Get the (possible cached) tokens for a given source span, and
-- cache their being fetched.
-- NOTE: The SrcSpan may be one introduced by HaRe, rather than GHC.
-- TODO: consider returning an Either. Although in reality the error
--       should never happen
getTokensBefore :: Tree Entry -> GHC.SrcSpan -> (Tree Entry,[PosToken])
getTokensBefore forest sspan = (forest', prevToks')
  where
    (forest',tree@(Node (Entry _s _) _)) = getSrcSpanFor forest (srcSpanToForestSpan sspan)
    -- prevToks = retrieveTokens tree

    z = openZipperToSpan (srcSpanToForestSpan sspan) $ Z.fromTree forest'

    prevToks = case (retrievePrevLineToks z) of
                 [] -> retrieveTokens tree
                 xs -> xs

    (_,rtoks) = break (\t->tokenPos t < (getGhcLoc sspan)) $ reverse prevToks
    prevToks' = reverse rtoks
    -- prevToks' = prevToks

-- ---------------------------------------------------------------------

-- |Replace the tokens for a given SrcSpan with new ones. The SrcSpan
-- will be inserted into the tree if it is not already there
-- TODO: What about the change in size of the SrcSpan? Solution is to
-- replace the SrcSpan with a new one (marked), and return it, as well
-- as the old one
updateTokensForSrcSpan :: Tree Entry -> GHC.SrcSpan -> [PosToken] -> (Tree Entry,GHC.SrcSpan,Tree Entry)
updateTokensForSrcSpan forest sspan toks = (forest'',newSpan,oldTree)
  where
    (forest',tree@(Node (Entry _s _) _)) = getSrcSpanFor forest (srcSpanToForestSpan sspan)
    prevToks = retrieveTokens tree

    newTokStart = ghead "reIndentToks" prevToks
    toks'' = reIndentToks (PlaceAbsolute (tokenRow newTokStart) (tokenCol newTokStart)) prevToks toks

    (startPos,endPos) = nonCommentSpan toks''

    -- if the original sspan had a ForestLine version, preserve it
    (((ForestLine trs vs _),_),(ForestLine tre ve _,_)) = srcSpanToForestSpan sspan
    -- newPosSpan = ((ForestLine vs sl,sc),(ForestLine ve el,ec))
    newSpan = insertVersionsInSrcSpan vs ve $ posToSrcSpan forest (startPos,endPos) 

    zf = openZipperToNode tree $ Z.fromTree forest'

    zf' = Z.setTree (Node (Entry (srcSpanToForestSpan newSpan) toks'') []) zf
    forest'' = Z.toTree zf'
    -- forest'' = error $ "updateTokensForSrcSpan: toks''=" ++ (show toks'') -- ++AZ++
    -- forest'' = error $ "updateTokensForSrcSpan: (posToSrcSpan forest (startPos,endPos))=" ++ (GHC.showPpr $ posToSrcSpan forest (startPos,endPos)) -- ++AZ++
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

{-
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
-}

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
          -- TODO: does startEndLocIncComments' give the same boundary
          --       if approached from one side as the other?
          (startLoc,endLoc) = startEndLocIncComments' toks (tokStartPos,tokEndPos)

          -- (startToks,middleToks,endToks) = splitToks (startPos,endPos) toks
          (startToks,middleToks,endToks) = splitToks (startLoc,endLoc) toks
          subTree = [mkTreeFromTokens startToks,
                     mkTreeFromSpanTokens sspan middleToks,
                     mkTreeFromTokens endToks]
          subTree' = filter (\t -> treeStartEnd t /= nullSpan) subTree
          (Entry _sspan _) = Z.label z

          z' = Z.setTree (Node (Entry _sspan []) subTree') z
          forest'' = Z.toTree z'

-- ---------------------------------------------------------------------

-- | Removes a ForestSpan and its tokens from the forest.
-- TODO: should it store the removed span somewhere else?

removeSrcSpan :: Tree Entry -> ForestSpan 
  -> (Tree Entry,Tree Entry) -- ^Updated forest, removed span
removeSrcSpan forest sspan = (forest'', delTree)
  where
    forest' = insertSrcSpan forest sspan -- Make sure span is actually
                                         -- in the tree
    z = openZipperToSpan sspan $ Z.fromTree forest'
    zp = gfromJust "removeSrcSpan" $ Z.parent z

    pt = Z.tree zp
    subTree = filter (\t -> not (treeStartEnd t == sspan)) $ subForest pt

    z' = Z.setTree (pt { subForest = subTree}) zp
    forest'' = Z.toTree z'
    -- forest'' = error $ "removeSrcSpan: initial tree\n" ++ (drawTreeEntry forest) -- ++AZ++
    -- forest'' = error $ "removeSrcSpan: after insertSrcSpan\n" ++ (drawTreeEntry forest') -- ++AZ++

    delTree = Z.tree z

-- ---------------------------------------------------------------------

-- |Retrieve all the tokens at the leaves of the tree, in order
-- TODO: ++AZ++ run through the tokens and trigger re-alignment in all
-- rows with tokenFileMark in a filename for a token
retrieveTokens :: Tree Entry -> [PosToken]
retrieveTokens forest = reAlignMarked $ concat $ map (\t -> F.foldl accum [] t) [forest]
  where
    accum :: [PosToken] -> Entry -> [PosToken]
    accum acc (Entry _ toks) = acc ++ toks

-- ---------------------------------------------------------------------

-- |Starting from a point in the zipper, retrieve all tokens backwards
-- until the line changes for a non-comment/non-empty token or
-- beginning of file.

retrievePrevLineToks :: Z.TreePos Z.Full Entry -> [PosToken]
retrievePrevLineToks z = res' -- error $ "retrievePrevLineToks:done notWhite=" ++ (show (done notWhite)) -- ++AZ++
  where
    -- Assuming the zipper has been opened to the span we care about,
    -- we will start with the tokens in the current tree, and work
    -- back.
    prevToks = retrieveTokens $ Z.tree z
    nonWhiteToks = filter notWhiteSpace prevToks

    endLine = tokenRow $ glast "retrievePrevLineToks" nonWhiteToks

    notWhite = filter notWhiteSpace $ concat $ go z

    -- Now keep moving back intil done
    done toks = endLine /= (tokenRow $ ghead "retrievePrevLineToks"
                                     $ filter notWhiteSpace toks)

    -- res = concat $ dropWhile (\toks -> (emptyList toks) || (done toks)) $ reverse (prevToks : (go z))
    res' = concat $ reverse (prevToks : (go z))
    -- res' = dropWhile (\tok -> isWhiteSpace tok || tokenRow tok < endLine) res
    -- res' = error $ "retrievePrevLineToks:res'=" ++ (show (dropWhile (\tok -> isWhiteSpace tok || tokenRow tok < endLine) res))
    -- res' = error $ "retrievePrevLineToks:prevToks=" ++ (show prevToks)
    -- res' = error $ "retrievePrevLineToks:prevToks=" ++ (show res)
    -- res' = error $ "retrievePrevLineToks:(prevToks : (go z))=" ++ (show (prevToks : (go z)))

    go :: Z.TreePos Z.Full Entry -> [[PosToken]]
    go z
      | not (Z.isRoot z) = toks : (go $ gfromJust "retrievePrevLineToks" (Z.parent z))
      | otherwise = [toks]
      where
        toks = concatMap retrieveTokens $ Z.before z




-- ---------------------------------------------------------------------

-- |Used as a marker in the filename part of the SrcSpan on modified
-- tokens, to trigger re-alignment when retrieving the tokens.
tokenFileMark :: GHC.FastString
tokenFileMark = GHC.mkFastString "HaRe"

-- |Mark a token so that it can be use to trigger layout checking
-- later when the toks are retrieved
markToken :: PosToken -> PosToken
markToken tok = tok'
  where
      (GHC.L l t,s) = tok
      tok' = (GHC.L (GHC.RealSrcSpan l') t,s)

      l' = case l of
            GHC.RealSrcSpan ss ->
                 GHC.mkRealSrcSpan
                      (GHC.mkRealSrcLoc tokenFileMark (GHC.srcSpanStartLine ss)  (GHC.srcSpanStartCol ss))
                      (GHC.mkRealSrcLoc tokenFileMark (GHC.srcSpanEndLine ss)  (GHC.srcSpanEndCol ss))

            _ -> error $ "markToken: expecting a real SrcSpan, got" ++ (GHC.showPpr l)


-- |Does a token have the file mark in it
isMarked :: PosToken -> Bool
isMarked (GHC.L l _,_) =
  case l of
    GHC.RealSrcSpan ss -> GHC.srcSpanFile ss == tokenFileMark
    _                  -> False

-- ---------------------------------------------------------------------

reAlignMarked :: [PosToken] -> [PosToken]
reAlignMarked toks = concatMap alignOne $ groupTokensByLine toks
  where
    alignOne toksl = unmarked ++ (reAlignToks marked)
     where
       (unmarked,marked) = break isMarked toksl

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
  -> (Tree Entry -- ^Updated forest with the new span
     , GHC.SrcSpan) -- ^Unique SrcSpan allocated in the forest to
                    -- identify this span in its position
addNewSrcSpanAndToksAfter forest oldSpan newSpan pos toks = (forest'',newSpan')
  where
    (forest',tree) = getSrcSpanFor forest (srcSpanToForestSpan oldSpan)

    (ghcl,_c) = getGhcLoc newSpan
    (ForestLine tr v l) = ghcLineToForestLine ghcl
    newSpan' = insertForestLineInSrcSpan (ForestLine tr (v+1) l) newSpan

    -- TODO: this is the same as before, merge it
    z = openZipperToSpan (srcSpanToForestSpan oldSpan) $ Z.fromTree forest'
    prevToks = case (retrievePrevLineToks z) of
                 [] -> retrieveTokens tree
                 xs -> xs

    toks' = reIndentToks pos prevToks toks

    newNode = Node (Entry (srcSpanToForestSpan newSpan') toks') []

    forest'' = insertNodeAfter tree newNode forest'

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
    (fwithspan,tree) = getSrcSpanFor forest (srcSpanToForestSpan oldSpan)

    z = openZipperToSpan (srcSpanToForestSpan oldSpan) $ Z.fromTree fwithspan

    prevToks = case (retrievePrevLineToks z) of
                 [] -> retrieveTokens tree
                 xs -> xs
    (_,(ForestLine _ _ endRow,_))       = srcSpanToForestSpan oldSpan

    -- prevToks' = takeWhile (\t -> tokenRow t < endRow) prevToks
    prevToks' = reverse $ dropWhile (\t -> tokenRow t > endRow) $ reverse  prevToks

    toks'' = reIndentToks pos prevToks' toks

    (startPos,endPos) = nonCommentSpan toks''

    newSpan = posToSrcSpan forest (startPos,endPos)
    -- TODO: expensive reIndentToks being done twice now
    (forest',newSpan') = addNewSrcSpanAndToksAfter forest oldSpan newSpan pos toks''
    -- (forest',newSpan') = (error $ "addToksAfterSrcSpan:(toks'')=" ++ (showToks toks''),oldSpan)
    -- (forest',newSpan') = (error $ "addToksAfterSrcSpan:(prevToks)=" ++ (showToks prevToks),oldSpan)
    -- (forest',newSpan') = (error $ "addToksAfterSrcSpan:(lineOffset,colOffset)=" ++ (show ((lineOffset,lineStart,tokenRow $ head toks,tokenRow $ head toks'',tokenRow newTokStart,colOffset))),oldSpan)

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
reIndentToks pos prevToks toks = toks''
  where
    newTokStart = ghead "reIndentToks"
                $ dropWhile (\tok -> isComment tok || isEmpty tok) $ toks

    prevOffset = getIndentOffset prevToks (tokenPos (glast "reIndentToks1" prevToks))

    (lineOffset,colOffset,endNewlines) = case pos of
      PlaceAdjacent -> (lineOffset',colOffset',0)
        where
          colStart  = (tokenColEnd (glast "reIndentToks" prevToks)) + 1
          lineStart = (tokenRow    (glast "reIndentToks" prevToks))

          lineOffset' = lineStart - (tokenRow $ ghead "reIndentToks" toks)
          colOffset'  = colStart  - (tokenCol newTokStart)

      PlaceAbsolute row col -> (lineOffset', colOffset', 0)
        where
          lineOffset' = row - (tokenRow $ ghead "reIndentToks" toks)
          colOffset'  = col - (tokenCol $ ghead "reIndentToks" toks)

      PlaceOffset rowIndent colIndent numLines -> (lineOffset',colOffset',numLines)
        where
          colStart  = tokenCol $ ghead "reIndentToks"
                    $ dropWhile isWhiteSpace prevToks
          lineStart = (tokenRow (glast "reIndentToks" prevToks)) -- + 1

          lineOffset' = rowIndent + lineStart - (tokenRow $ ghead "reIndentToks" toks)
          colOffset'  = colIndent + colStart  - (tokenCol newTokStart)

      PlaceIndent rowIndent colIndent numLines -> (lineOffset',colOffset',numLines)
        where
          colStart = prevOffset
          lineStart = (tokenRow (glast "reIndentToks" prevToks)) -- + 1

          lineOffset' = rowIndent + lineStart - (tokenRow $ ghead "reIndentToks" toks)
          colOffset'  = colIndent + colStart  - (tokenCol newTokStart) + 1 -- ++AZ++ Why +1?

    toks'  = addOffsetToToks (lineOffset,colOffset) toks
    toks'' = if endNewlines > 0
               then toks' ++ [(newLinesToken endNewlines $ glast "reIndentToks" toks')]
               else toks'

-- ---------------------------------------------------------------------

-- |Extract the start and end position of a span, without any leading
-- or trailing comments
nonCommentSpan :: [PosToken] -> (SimpPos,SimpPos)
nonCommentSpan toks = (startPos,endPos)
  where
    -- startTok = ghead "nonCommentSpan" $ dropWhile (\tok -> isComment tok || isEmpty tok) $ toks
    -- endTok   = ghead "nonCommentSpan" $ dropWhile (\tok -> isComment tok || isEmpty tok) $ reverse toks

    startTok = ghead "nonCommentSpan" $ dropWhile isWhiteSpace $ toks
    endTok   = ghead "nonCommentSpan" $ dropWhile isWhiteSpace $ reverse toks

    startPos = tokenPos    startTok
    endPos   = tokenPosEnd endTok

-- ---------------------------------------------------------------------

-- |Convert a simple (start,end) position to a SrcSpan belonging to
-- the file in the tree
posToSrcSpan :: Tree Entry -> (SimpPos,SimpPos) -> GHC.SrcSpan
posToSrcSpan forest ((rs,cs),(re,ce)) = sspan
  where
    (GHC.L l _,_) = ghead "posToSrcSpan"  $ retrieveTokens forest -- ++AZ++ Ouch, performance??
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
  -- = error $ "openZipperToNode:(treeStartEnd (Z.tree z),z)="++(show (treeStartEnd (Z.tree z),z)) -- ++AZ++
  = if treeStartEnd (Z.tree z) == treeStartEnd node
      then z
      else z'
        where
          -- go through all of the children to find the one that
          -- either is what we are looking for, or contains it
          childrenAsZ = map (\j -> gfromJust "openZipperToNode" j)
                      $ iterate (\mz -> Z.next $ gfromJust ("openZipperToNode:" ++ (show z)) mz)
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

-- |Open a zipper so that its focus has the given SrcSpan in its
-- subtree, or the location where the SrcSpan should go, if it is not
-- in the tree
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
            -- _xs -> z -- Multiple, this is the spot
            xx  -> case (filter (\zt -> (treeStartEnd $ Z.tree zt) == sspan) xx) of 
                    -- [] -> error $ "openZipperToSpan: no matching subtree:(sspan,xx)=" ++ (show (sspan,xx)) -- ++AZ++ 
                    [y] -> openZipperToSpan sspan y
                    yy -> -- Multiple, check if we can separate out
                             -- by version
                          case (filter (\zt -> (forestSpanVersions $ treeStartEnd $ Z.tree zt) == (forestSpanVersions sspan)) xx) of
                           -- [] -> z
                           [] -> error $ "openZipperToSpan:no version match:(sspan,yy)=" ++ (show (sspan,yy)) -- ++AZ++
                           [w] -> openZipperToSpan sspan w
                           -- _ww -> z
                           ww -> error $ "openZipperToSpan:multiple version match:" ++ (show ww) -- ++AZ++
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
    checkNode acc node@(Node (Entry sspan toks) sub) = acc ++ r ++ rinc ++ rsubs ++ rnull
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
    checkInclusion      (Node _                    []) = []
    checkInclusion node@(Node (Entry _sspan _toks)  sub) = rs ++ rseq
      where
        (start,end) = treeStartEnd node
        subs = map treeStartEnd sub
        (sstart, _) = ghead "invariant" subs
        (_, send) = last subs
        -- Do not count any custom added srcspans at the end for this
        -- test
        -- TODO: is this a reasonable approach?

        rs = if (start == sstart) && ((end == send) || (forestPosVersionSet send))
               then []
               else ["FAIL: subForest start and end does not match entry: " ++ (prettyshow node)]

        rseq = checkSequence node subs

        checkSequence :: Tree Entry -> [ForestSpan] -> [String]
        checkSequence _ [] = []
        checkSequence _ [_x] = []
        checkSequence node' ((_s1,e1):s@(s2,_e2):ss)
          = r ++ checkSequence node' (s:ss)
          where
            -- r = if e1 <= s2
            r = if before e1 s2
                 then []
                 else ["FAIL: subForest not in order: " ++
                        show e1 ++ " not < " ++ show s2 ++
                        ":" ++ prettyshow node']

            before (ForestLine trs ve er,ec) (ForestLine tre vs sr,sc)
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

-- |Call drawTreeEntry on the entire token cache
drawTokenCache :: TokenCache -> String
drawTokenCache tk = Map.foldlWithKey' doOne "" (tkCache tk)
  where
    doOne :: String -> TreeId -> Tree Entry -> String
    doOne s key val = s ++ "tree " ++ (show key) ++ ":\n"
                        ++ (drawTreeEntry val)

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
   -- startLoc = tokenPos $ ghead "mkTreeFromTokens" toks
   -- endLoc   = tokenPosEnd $ last toks -- SrcSpans count from start of token, not end
   -- sspan    = GHC.RealSrcSpan $ GHC.mkRealSrcSpan startLoc endLoc
   (startLoc',endLoc') = nonCommentSpan toks
   sspan    = simpPosToForestSpan (startLoc',endLoc')


-- ---------------------------------------------------------------------

-- |Make a tree representing a particular set of tokens
mkTreeFromSpanTokens :: ForestSpan -> [PosToken] -> Tree Entry
mkTreeFromSpanTokens sspan toks = Node (Entry sspan toks) []

-- ---------------------------------------------------------------------

ghcSpanStartEnd :: GHC.SrcSpan -> ((Int, Int), (Int, Int))
ghcSpanStartEnd sspan = (getGhcLoc sspan,getGhcLocEnd sspan)

-- ---------------------------------------------------------------------

-- |Synchronise a located AST fragment to use a newly created SrcSpan
-- in the token tree.
syncAST :: (SYB.Data t)
  => GHC.Located t -- ^The AST (or fragment)
  -- => t -- ^The AST (or fragment)
  -> GHC.SrcSpan   -- ^The SrcSpan created in the Tree Entry
  -> Tree Entry    -- ^Existing token tree
  -> (GHC.Located t, Tree Entry) -- ^Updated AST and tokens
  -- -> (t, Tree Entry) -- ^Updated AST and tokens
-- syncAST (GHC.L _l t) sspan forest = (ast',forest')
syncAST ast@(GHC.L l _t) sspan forest = (GHC.L sspan xx,forest')
  where
    -- ast' = (GHC.L sspan t)
    forest' = forest

    ((ForestLine _ _ startRow,startCol),_)       = srcSpanToForestSpan l
    ((ForestLine _ _ newStartRow,newStartCol),_) = srcSpanToForestSpan sspan

    rowOffset = newStartRow - startRow
    colOffset = newStartCol - startCol

    -- TODO: take cognizance of the ForestLines encoded in srcspans
    -- when calculating the offsets etc
    syncSpan s = addOffsetToSpan (rowOffset,colOffset) s
    -- syncSpan s = s

    (GHC.L _s xx) = everywhereStaged SYB.Renamer (
              SYB.mkT hsbindlr
              `SYB.extT` sig
              `SYB.extT` ty
              `SYB.extT` name
              `SYB.extT` lhsexpr
              `SYB.extT` lpat
              `SYB.extT` limportdecl
              ) ast

    hsbindlr (GHC.L s b) = (GHC.L (syncSpan s) b) :: GHC.Located (GHC.HsBindLR GHC.Name GHC.Name)
    sig (GHC.L s n) = (GHC.L (syncSpan s) n) :: GHC.LSig GHC.Name
    ty (GHC.L s typ) =  (GHC.L (syncSpan s) typ) :: (GHC.LHsType GHC.Name)
    name (GHC.L s n) = (GHC.L (syncSpan s) n) :: GHC.Located GHC.Name
    lhsexpr (GHC.L s e) = (GHC.L (syncSpan s) e) :: GHC.LHsExpr GHC.Name
    lpat (GHC.L s p) = (GHC.L (syncSpan s) p) :: GHC.LPat GHC.Name
    limportdecl (GHC.L s n) = (GHC.L (syncSpan s) n) :: GHC.LImportDecl GHC.Name

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

-- ---------------------------------------------------------------------
-- Next section is stuff brought over from LocUtils, to break cycles

showToks :: [PosToken] -> String
showToks toks = show $ map (\(t@(GHC.L _ tok),s) ->
                 ((getLocatedStart t, getLocatedEnd t),tok,s)) toks

instance Show (GHC.GenLocated GHC.SrcSpan GHC.Token) where
  show t@(GHC.L _l tok) = show ((getLocatedStart t, getLocatedEnd t),tok)


-- ----------------------------------------------------------------------

-- |Get around lack of instance Eq when simply testing for empty list
emptyList :: [t] -> Bool
emptyList [] = True
emptyList _  = False

nonEmptyList :: [t] -> Bool
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
startEndLocIncComments::(SYB.Data t) => [PosToken] -> t -> (SimpPos,SimpPos)
startEndLocIncComments toks t = startEndLocIncComments' toks (getStartEndLoc t)


startEndLocIncComments' :: [PosToken] -> (SimpPos,SimpPos) -> (SimpPos,SimpPos)
startEndLocIncComments' toks (startLoc,endLoc) =
  let
    (begin,middle,end) = splitToks (startLoc,endLoc) toks

    -- (leadinr,leadr) = break (\tok -> not (isComment tok || isEmpty tok)) $ reverse begin
    (leadinr,leadr) = break notWhiteSpace  $ reverse begin
    leadr' = filter (\t -> not (isEmpty t)) leadr
    prevLine  = if (emptyList leadr') then 0 else (tokenRow $ ghead "startEndLocIncComments'1" leadr')
    firstLine = if (emptyList middle) then 0 else (tokenRow $ ghead "startEndLocIncComments'1" middle)
    (_,leadComments) = divideComments prevLine firstLine $ reverse leadinr


    -- (trail,trailrest) = break (\tok -> not (isComment tok || isEmpty tok)) end
    (trail,trailrest) = break notWhiteSpace end
    trail' = filter (\t -> not (isEmpty t)) trail
    lastLine = if (emptyList middle)    then    0 else (tokenRow $ glast "startEndLocIncComments'2" middle)
    nextLine = if (emptyList trailrest) then 1000 else (tokenRow $ ghead "startEndLocIncComments'2" trailrest)
    (trailComments,_) =  divideComments lastLine nextLine trail'

    middle' = leadComments ++ middle ++ trailComments
  in
    if (emptyList middle')
      then ((0,0),(0,0))
      else ((tokenPos $ ghead "startEndLocIncComments 4" middle'),(tokenPosEnd $ last middle'))
      -- else error $ "startEndLocIncComments: (prevLine,firstLine) reverse leadr =" ++ (show (prevLine,firstLine)) ++ "," ++ (showToks $ reverse leadr)

-- ---------------------------------------------------------------------

-- |Split a set of comment tokens into the ones that belong with the startLine
-- and those that belong with the endLine
divideComments :: Int -> Int -> [PosToken] -> ([PosToken],[PosToken])
divideComments startLine endLine toks = (first,second)
 -- error $ "divideComments:groupGaps=" ++ (show groupGaps)
 -- error $ "divideComments:(firsts,seconds)=" ++ (show (firsts,seconds))
  where
    groups = groupBy groupByAdjacent toks
    groupLines = map (\ts -> ((tokenRow $ ghead "divideComments" ts,tokenRow $ glast "divideComments" ts),ts)) groups
    groupLines' = [((startLine,startLine),[])] ++ groupLines ++ [((endLine,endLine),[])]
    groupGaps = go [] groupLines'
    -- groupGaps is now a list of gaps followed by the tokens. The
    -- last gap has an empty token list, since there is one more gap
    -- than token groups

    -- e.g [(0,[comments1]),(3,[comments2]),(1,[]) captures
    --  ---------------------
    --      b + bar -- ^trailing comment
    --
    --
    -- -- leading comment
    -- foo x y =
    -- ----------------------

    biggest = maximum $ map fst groupGaps

    (firsts,seconds) = break (\(g,_) -> g >= biggest) groupGaps

    first = concatMap snd firsts
    second = concatMap snd seconds

    -- Helpers
    groupByAdjacent :: PosToken -> PosToken -> Bool
    groupByAdjacent a b = 1 + tokenRow a == tokenRow b

    go :: [(Int,[PosToken])] -> [((Int,Int),[PosToken])] -> [(Int,[PosToken])]
    go acc []  = acc
    go acc [_x] = acc
    go acc (((_s1,e1),_t1):b@((s2,_e2),t2):xs) = go (acc ++ [((s2 - e1),t2)] ) (b:xs)


-- ---------------------------------------------------------------------

-- |Add a constant line and column offset to a span of tokens
addOffsetToToks :: SimpPos -> [PosToken] -> [PosToken]
addOffsetToToks (r,c) toks = map (\t -> increaseSrcSpan (r,c) t) toks


increaseSrcSpan :: SimpPos -> PosToken -> PosToken
increaseSrcSpan (lineAmount,colAmount) posToken@(lt@(GHC.L _l t), s) = (GHC.L newL t, s) where
        filename = fileNameFromTok posToken
        newL = GHC.mkSrcSpan (GHC.mkSrcLoc filename startLine startCol) (GHC.mkSrcLoc filename endLine endCol)
        (startLine, startCol) = add1 $ getLocatedStart lt
        (endLine, endCol)     = add1 $ getLocatedEnd   lt

        add1 :: (Int, Int) -> (Int, Int)
        add1 (x,y) = (x+lineAmount,y+colAmount)

-- ---------------------------------------------------------------------

isWhiteSpace :: PosToken -> Bool
isWhiteSpace tok = isComment tok || isEmpty tok

notWhiteSpace :: PosToken -> Bool
notWhiteSpace tok = not (isWhiteSpace tok)

-- ---------------------------------------------------------------------

isComment :: PosToken -> Bool
isComment ((GHC.L _ (GHC.ITdocCommentNext _)),_s)  = True
isComment ((GHC.L _ (GHC.ITdocCommentPrev _)),_s)  = True
isComment ((GHC.L _ (GHC.ITdocCommentNamed _)),_s) = True
isComment ((GHC.L _ (GHC.ITdocSection _ _)),_s)    = True
isComment ((GHC.L _ (GHC.ITdocOptions _)),_s)      = True
isComment ((GHC.L _ (GHC.ITdocOptionsOld _)),_s)   = True
isComment ((GHC.L _ (GHC.ITlineComment _)),_s)     = True
isComment ((GHC.L _ (GHC.ITblockComment _)),_s)    = True
isComment ((GHC.L _ _),_s)                         = False

isEmpty :: PosToken -> Bool
isEmpty ((GHC.L _ (GHC.ITsemi)), "") = True
isEmpty _                           = False

--Some functions for fetching a specific field of a token
tokenCol :: PosToken -> Int
tokenCol (GHC.L l _,_) = c where (_,c) = getGhcLoc l

tokenColEnd :: PosToken -> Int
tokenColEnd (GHC.L l _,_) = c where (_,c) = getGhcLocEnd l

tokenRow :: PosToken -> Int
tokenRow (GHC.L l _,_) = r where (r,_) = getGhcLoc l

tokenPos :: (GHC.GenLocated GHC.SrcSpan t1, t) -> SimpPos
tokenPos (GHC.L l _,_)     = getGhcLoc l

tokenPosEnd :: (GHC.GenLocated GHC.SrcSpan t1, t) -> SimpPos
tokenPosEnd (GHC.L l _,_)     = getGhcLocEnd l

-- TODO: badly named function
tokenCon :: PosToken -> String
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
                    `SYB.mkQ`  bind
                    `SYB.extQ` sig
                    `SYB.extQ` pnt
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
startEndLocGhc (GHC.L l _) =
  case l of
    (GHC.RealSrcSpan ss) ->
      ((GHC.srcSpanStartLine ss,GHC.srcSpanStartCol ss),
       (GHC.srcSpanEndLine ss,  GHC.srcSpanEndCol ss))
    (GHC.UnhelpfulSpan _) -> ((0,0),(0,0))

-- ---------------------------------------------------------------------

-- | Get the indent of the line before, taking into account in-line
-- where, let, in and do tokens
getIndentOffset :: [PosToken] -> SimpPos -> Int
getIndentOffset [] _pos    = 1
getIndentOffset _toks (0,0) = 1
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
splitOnNewLn toks = go [] toks
  -- ++AZ++ : TODO: is this simpler? : (toks1,toks2)=break (\x' -> tokenRow x /= tokenRow x') rtoks

  where
    go [] [] = ([],[])
    go ss [] = (ss,[])
    go [] xs = go [head xs] (tail xs)
    go ss xs
      | onSameLn (glast "splitOnNewLn" ss) (head xs) = go (ss ++ [head xs]) (tail xs)
      | otherwise = (ss,xs)


-- ---------------------------------------------------------------------

tokenLen :: PosToken -> Int
tokenLen (_,s)     = length s   --check this again! need to handle the tab key.

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

groupTokensByLine :: [PosToken] -> [[PosToken]]
groupTokensByLine [] = []
groupTokensByLine (xs) = let x = head xs
                             (xs', xs'') = break (\x' -> tokenRow x /= tokenRow x') xs
                      in case xs'' of
                        [] -> [xs']
                        _ ->  (xs'++ [ghead "groupTokensByLine" xs''])
                                : groupTokensByLine (gtail "groupTokensByLine" xs'')


-- ---------------------------------------------------------------------

-- | Make sure all tokens have at least one space between them
-- TODO: pretty sure this can be simplified
reAlignToks :: [PosToken] -> [PosToken]
reAlignToks [] = []
reAlignToks [t] = [t]
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

-- |Adjust token stream to cater for changes in token length due to
-- token renaming
reSequenceToks :: [PosToken] -> [PosToken]
reSequenceToks toks = toks

-- ---------------------------------------------------------------------

-- EOF
