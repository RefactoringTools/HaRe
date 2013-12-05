{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}

module Main where

import qualified FastString as GHC
import qualified GHC        as GHC
import qualified Lexer      as GHC

import qualified GHC.SYB.Utils as SYB

import Control.Monad.State
import Data.List
import Data.Maybe
import qualified Data.Tree as T

import Language.Haskell.Refact.Utils.GhcBugWorkArounds
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.Layout
import Language.Haskell.Refact.Utils.LayoutTypes
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

-- ----------
import Data.Tree.DUAL
import Data.Semigroup
import Data.Monoid.Action
import qualified Data.List.NonEmpty as NE

import TestUtils

-- ---------------------------------------------------------------------

main = foo

data Transformation = AsIs
                    | T Integer
                    deriving Show

instance Num Transformation where
  fromInteger n = T n


transform :: Transformation -> Prim -> Prim
transform AsIs p = p
-- transform (T n) (Str s) = (Str (s++"(T"++ (show n) ++")"))
transform (T n) (Str s) = (Str s)

-- | The value that bubbles up. This is the Span occupied by the
-- subtree, together with a string representation of the subtree. The
-- origin of the string is the start of the span.

data Up = Up Span (NE.NonEmpty Line)
        deriving Show

data Span = Span (Row,Col) (Row,Col)
          deriving Show

data Line = Line Row Col String
          deriving Show

data Annot = Ann String
           deriving Show

data Prim = Str [PosToken]
          deriving Show


type SourceTree = DUALTree Transformation Up Annot Prim


instance Semigroup Span where
  (Span p1 _p2) <> (Span _q1 q2) = (Span p1 q2)

-- TODO: combine the strings according to the relative spans.
instance Semigroup Up where
  u1 <> u2 = combineUps u1 u2

instance Semigroup Transformation where
  (T n1) <> (T n2) = T (n1 + n2)

instance (Action Transformation Up) where
  act AsIs s = s
  act (T n) (Up span s) = (Up span s)

-- ---------------------------------------------------------------------


foo = do
  -- (t,toks) <-  parsedFileGhc "./test/testdata/Layout/Lift.hs"
  (t,toks) <-  parsedFileGhc "./test/testdata/Layout/Bare.hs"
  let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

  let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

  let layout = allocTokens parsed toks
  putStrLn (drawTreeEntry layout)
  putStrLn (drawTreeCompact layout)

  let srcTree = build layout

  putStrLn (show srcTree)
  putStrLn ""
  putStrLn (show $ flatten srcTree)
  putStrLn ""
  putStrLn (show $ getU srcTree)


-- ---------------------------------------------------------------------

roundTrip :: FilePath -> IO (Bool,String)
roundTrip fname = do
  (t,toks) <-  parsedFileGhc fname
  let parsed = GHC.pm_parsed_source $ GHC.tm_parsed_module t

  let origSource = (GHC.showRichTokenStream $ bypassGHCBug7351 toks)

  let layout = allocTokens parsed toks

  let srcTree = build layout
  let (Just (Up span str)) = getU srcTree

  let r = renderLines $ NE.toList str
  return (r == origSource,r)

-- ---------------------------------------------------------------------

renderLines :: [Line] -> String
renderLines ls = res
  where
    (_,(_,res)) = runState (go 0 ls) ((1,1),"")

    go _ [] = do return ()
    go ci ((Line r c str):ls') = do
      newPos r (c+ci)
      addString str
      go ci ls'

    -- State operations ----------------

    getRC = do
      (rc,_) <- get
      return rc

    putRC (r,c) = do
      (_,str) <- get
      put ((r,c),str)

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

    addString [] = return ()
    addString str = do
      ((r,c),curr) <- get
      let ll = (length $ filter (=='\n') str)
      let c'' = (length $ takeWhile (/='\n') $ reverse str)


      let (r',c') = case ll of
                     0 -> (r,c + c'')
                     _ -> (r + ll, c'' + 1)
      put ((r',c'),curr++str)

      -- checkInvariant $ "addString" ++ show str

    addDebugString str = do
      ((r,c),curr) <- get
      put ((r,c),curr++str)

-- ---------------------------------------------------------------------

build :: LayoutTree -> SourceTree
build (T.Node (Deleted _sspan  _pg _eg) _ ) = empty
build (T.Node (Entry sspan lay [])  ts0)   = mconcat $ map build ts0
build (T.Node (Entry sspan lay toks) _ts)  = leaf (mkUp sspan toks) (Str toks)

-- ---------------------------------------------------------------------

mkUp :: ForestSpan -> [PosToken] -> Up
mkUp sspan toks = Up ss ls
  where
    ss = mkSpan sspan
    ls = NE.fromList $ mkLinesFromToks toks

-- ---------------------------------------------------------------------

mkLinesFromToks :: [PosToken] -> [Line]
mkLinesFromToks [] = []
mkLinesFromToks toks = [Line ro co str]
  where
    ro' = tokenRow $ head toks
    co' = tokenCol $ head toks
    (ro,co) = srcPosToSimpPos (tokenRow $ head toks, tokenCol $ head toks)
    toks' = addOffsetToToks (-ro',-co') toks
    str = GHC.showRichTokenStream toks'

-- ---------------------------------------------------------------------

combineUps :: Up -> Up -> Up
combineUps (Up sp1 l1) (Up sp2 l2) = (Up (sp1 <> sp2) l)
  where
    (Span (sr1,sc1) (er1,ec1)) = sp1
    (Span (sr2,sc2) (er2,ec2)) = sp2
    -- Assumptions
    --  1. The first character of (head str1) is at (sr1,sc1)
    --  2. The first character of (head str2) is at (sr2,sc2)

    l1l@(Line r1 c1 s1) = NE.last l1
    l2f@(Line r2 c2 s2) = NE.head l2

    l = if r1 == r2
         then NE.fromList $ (NE.init l1) ++ m ++ (NE.tail l2)
         else NE.fromList $ (NE.toList l1) ++ (NE.toList l2)

    m = [Line r1 c1 (s1 ++ gap ++ s2)]
    gap = take (c2 - (c1 + length s1)) $ repeat ' '

-- ---------------------------------------------------------------------

mkSpan :: ForestSpan -> Span
mkSpan ss = Span s e
  where
   (s,e) = forestSpanToSimpPos ss

-- ---------------------------------------------------------------------

toksToUpStr :: [PosToken] -> [String]
toksToUpStr = lines . removeOffsetToks

-- ---------------------------------------------------------------------

removeOffsetToks :: [PosToken] -> String
removeOffsetToks [] = ""
removeOffsetToks toks = str
  where
    ro' = tokenRow $ head toks
    co' = tokenCol $ head toks
    toks' = addOffsetToToks (-ro',-co') toks
    str = GHC.showRichTokenStream toks'

-- ---------------------------------------------------------------------

normaliseColumns :: [Line] -> [Line]
normaliseColumns [] = []
normaliseColumns ps = ps'
  where
    offset = case (head ps) of
      Line    _r c _   -> c - 1
      _                -> 0
    ps' = map remove ps

    remove (Line r c str) = (Line r (c - offset) str)
    remove x = x

-- ---------------------------------------------------------------------
