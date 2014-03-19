{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Language.Haskell.Refact.Utils.DualTree (
    layoutTreeToSourceTree
  , retrieveLinesFromLayoutTree
  , retrieveLines
  , renderLines
  , renderSourceTree
  , SourceTree
  , Line(..)
  , Source(..)
  , renderLinesFromLayoutTree
  ) where

import qualified GHC        as GHC
import qualified Outputable as GHC

import Control.Monad.State
import qualified Data.Tree as T

import Language.Haskell.Refact.Utils.LayoutTypes
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn

-- ----------
import Data.Tree.DUAL
import Data.Semigroup
import Data.Monoid.Action
import qualified Data.List.NonEmpty as NE
import qualified Data.Tree.DUAL.Internal as I

-- ---------------------------------------------------------------------

data DeletedSpan = DeletedSpan Span RowOffset SimpPos
              deriving (Show,Eq)

-- TODO: We are not actually using any of these
data Transformation = TAbove ColOffset EndOffset (Row,Col) (Row,Col) EndOffset
                    deriving Show

{-
transform :: Transformation -> Prim -> Prim
transform AsIs p = p
transform (T _n)                       (PToks s) = (PToks s)
transform (TAbove _co _bo _p1 _p2 _eo) (PToks s) = (PToks s)
transform (TDeleted _sspan _ro _p)     (PToks s) = (PToks s)
transform TAdded                       (PToks s) = (PToks s)
-}

-- | The value that bubbles up. This is the Span occupied by the
-- subtree, together with a string representation of the subtree. The
-- origin of the string is the start of the span.

data Up = Up Span Alignment (NE.NonEmpty Line) [DeletedSpan]
        | UDeleted [DeletedSpan]
        deriving Show

data Span = Span (Row,Col) (Row,Col)
          deriving (Show,Eq)

data Line = Line Row Col RowOffset Source LineOpt [PosToken]

data Alignment = ANone | AVertical
               deriving (Show,Eq)

instance Show Line where
  show (Line r c o f s toks) = "(" ++ show r ++ " " ++ show c ++ " " ++ show o
          ++ " " ++ show f
          ++ " " ++ show s ++ "\"" ++ GHC.showRichTokenStream toks ++ "\")"

data Source = SOriginal
            | SAdded
            | SWasAdded
            deriving (Show,Eq)

data LineOpt = ONone
             -- | This line needs to be grouped with the next in terms
             -- of layout, so any column offsets need to be propagated
             | OGroup
             deriving (Show,Eq)

data Annot = Ann String
           | ADeleted ForestSpan RowOffset SimpPos
           | ASubtree ForestSpan
           deriving Show

data Prim = PToks [PosToken]
          | PDeleted ForestSpan RowOffset SimpPos
          deriving Show

-- | The main data structure for this module
type SourceTree = DUALTree Transformation Up Annot Prim


instance Semigroup Span where
  (Span p1 _p2) <> (Span _q1 q2) = (Span p1 q2)

instance Semigroup Up where
  u1 <> u2 = combineUps u1 u2


instance Semigroup Transformation where
 (TAbove co1 bo1 p11 _p21 _eo1) <> (TAbove _co2 _bo2 _p12 p22 eo2)
    =  (TAbove co1 bo1 p11 p22 eo2)


instance (Action Transformation Up) where
  act (TAbove _co _bo _p1 _p2 _eo) (Up sspan _a s ds) = (Up sspan a' s' ds)
    where
      a' = AVertical
      s' = NE.map (\(Line r c o ss _f toks) -> (Line r c o ss OGroup toks)) s

  act (TAbove _co _bo _p1 _p2 _eo) (UDeleted ds) = UDeleted ds

-- ---------------------------------------------------------------------

instance GHC.Outputable SourceTree where
  ppr (I.DUALTree ot)
      = case getOption ot of
             Nothing -> GHC.text "Nothing"
             Just t  -> GHC.ppr t

instance GHC.Outputable (I.DUALTreeU Transformation Up Annot Prim) where
  ppr (I.DUALTreeU (u,t)) = GHC.parens $ GHC.ppr u GHC.<> GHC.comma GHC.$$ GHC.ppr t

instance GHC.Outputable (I.DUALTreeNE Transformation Up Annot Prim) where
  ppr (I.Leaf u l)   = GHC.parens $ GHC.hang (GHC.text "Leaf")   1 (GHC.ppr u GHC.$$ GHC.ppr l)
  ppr (I.LeafU u)    = GHC.parens $ GHC.hang (GHC.text "LeafU")  1 (GHC.ppr u)
  ppr (I.Concat dts) = GHC.parens $ GHC.hang (GHC.text "Concat") 1 (GHC.ppr dts)
  ppr (I.Act d t)    = GHC.parens $ GHC.hang (GHC.text "Act")    1 (GHC.ppr d GHC.$$ GHC.ppr t)
  ppr (I.Annot a t)  = GHC.parens $ GHC.hang (GHC.text "Annot")  1 (GHC.ppr a GHC.$$ GHC.ppr t)

instance GHC.Outputable Prim where
  ppr (PToks toks) = GHC.parens $ GHC.text "PToks" GHC.<+> GHC.text (show toks)
  ppr (PDeleted ss pg p) = GHC.parens $ GHC.text "PDeleted" GHC.<+> GHC.ppr ss
                               GHC.<+> GHC.ppr pg GHC.<+> GHC.ppr p

instance GHC.Outputable Transformation where
  ppr (TAbove co bo p1 p2 eo)  = GHC.parens $ GHC.text "TAbove" GHC.<+> GHC.ppr co
                              GHC.<+> GHC.ppr bo
                              GHC.<+> GHC.ppr p1  GHC.<+> GHC.ppr p2
                              GHC.<+> GHC.ppr eo

instance GHC.Outputable EndOffset where
  ppr None = GHC.text "None"
  ppr (SameLine co)     = GHC.parens $ GHC.text "SameLine" GHC.<+> GHC.ppr co
  ppr (FromAlignCol rc) = GHC.parens $ GHC.text "FromAlignCol" GHC.<+> GHC.ppr rc

instance GHC.Outputable Annot where
  ppr (Ann str) = GHC.parens $ GHC.text "Ann" GHC.<+> GHC.text str
  ppr (ADeleted ss pg p) = GHC.parens $ GHC.text "ADeleted" GHC.<+> GHC.ppr ss
                           GHC.<+> GHC.ppr pg GHC.<+> GHC.ppr p
  ppr (ASubtree ss)      = GHC.parens $ GHC.text "ASubtree" GHC.<+> GHC.ppr ss

instance GHC.Outputable Up where
  ppr (Up ss a ls ds) = GHC.parens $ GHC.hang (GHC.text "Up") 1
                                 ((GHC.ppr ss GHC.<+> GHC.ppr a) GHC.$$ GHC.ppr ls GHC.$$ GHC.ppr ds)
  ppr (UDeleted d)  = GHC.parens $ GHC.text "UDeleted" GHC.<+> GHC.ppr d

instance GHC.Outputable Alignment where
  ppr ANone     = GHC.text "ANone"
  ppr AVertical = GHC.text "AVertical"

instance GHC.Outputable DeletedSpan where
  ppr (DeletedSpan ss ro p) = GHC.parens $ (GHC.text "DeletedSpan")
                               GHC.<+> GHC.ppr ss GHC.<+> GHC.ppr ro
                               GHC.<+> GHC.ppr p


instance GHC.Outputable Span where
  ppr (Span sp ep) = GHC.parens $ GHC.text "Span" GHC.<+> GHC.ppr sp GHC.<+> GHC.ppr ep

instance (GHC.Outputable a) => GHC.Outputable (NE.NonEmpty a) where
  -- ppr (x NE.:| xs) = GHC.parens $ GHC.hang (GHC.text "NonEmpty") 1 (GHC.ppr (x:xs))
  ppr (x NE.:| xs) = (GHC.ppr (x:xs))

instance GHC.Outputable Line where
  ppr (Line r c o s f str) = GHC.parens $ GHC.text "Line" GHC.<+> GHC.ppr r
                         GHC.<+> GHC.ppr c GHC.<+> GHC.ppr o
                         GHC.<+> GHC.ppr s GHC.<+> GHC.ppr f
                         GHC.<+> GHC.text ("\"" ++ (GHC.showRichTokenStream str) ++ "\"")
                         -- GHC.<+> GHC.text (show str) -- ++AZ++ debug

instance GHC.Outputable Source where
  ppr SOriginal = GHC.text "SOriginal"
  ppr SAdded    = GHC.text "SAdded"
  ppr SWasAdded = GHC.text "SWasAdded"

instance GHC.Outputable LineOpt where
  ppr ONone  = GHC.text "ONone"
  ppr OGroup = GHC.text "OGroup"

-- ---------------------------------------------------------------------

renderLinesFromLayoutTree :: LayoutTree -> String
renderLinesFromLayoutTree = renderLines . retrieveLinesFromLayoutTree

-- ---------------------------------------------------------------------

retrieveLinesFromLayoutTree :: LayoutTree -> [Line]
retrieveLinesFromLayoutTree = retrieveLines . layoutTreeToSourceTree

-- ---------------------------------------------------------------------

retrieveLines :: SourceTree -> [Line]
retrieveLines srcTree
  = case getU srcTree of
         Nothing -> []
         Just (Up _ss _a str _ds) -> NE.toList str
         Just (UDeleted _) -> []

-- ---------------------------------------------------------------------

renderSourceTree :: SourceTree -> String
renderSourceTree srcTree = r
  where
    r = case getU srcTree of
         Nothing -> ""
         Just (Up _ss _a str _ds) -> renderLines $ NE.toList str
         Just (UDeleted _) -> ""

-- ---------------------------------------------------------------------

renderLines :: [Line] -> String
renderLines ls = res
  where
    (_,(_,res)) = runState (go 0 ls) ((1,1),"")

    go _ [] = do return ()
    go ci ((Line r c _o _f _s str):ls') = do
      newPos r (c+ci)
      addString (GHC.showRichTokenStream str)
      -- addString (GHC.showRichTokenStream $ reAlignMarked str)
      -- addString (GHC.showRichTokenStream $ reAlignMarked str)
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

layoutTreeToSourceTree :: LayoutTree -> SourceTree

-- TODO: simplify by getting rid of PDeleted, and use leafU
layoutTreeToSourceTree (T.Node (Deleted sspan  pg eg) _)
  = leaf (UDeleted [(DeletedSpan (fs2s sspan) pg eg)]) (PDeleted sspan pg eg)

layoutTreeToSourceTree (T.Node (Entry sspan NoChange [])  ts0)
  = annot (ASubtree sspan) (mconcatl $ map layoutTreeToSourceTree ts0)

--  TODO: only apply TAbove if the subs go on to the next line
layoutTreeToSourceTree (T.Node (Entry sspan (Above bo p1 p2 eo) [])  ts0)
  = case (numLines ts0) of
     0 -> annot (ASubtree sspan) (mconcatl $ map layoutTreeToSourceTree ts0)
     _ -> annot (ASubtree sspan)
           (applyD (TAbove co bo p1 p2 eo) subs)
  where
    subs = (mconcatl $ map layoutTreeToSourceTree ts0)
    co = 0
    numLines :: [T.Tree Entry] -> Int
    numLines [] = 0
    numLines sts = l - f
      where
        ((f,_),_    ) = forestSpanToSimpPos $ treeStartEnd $ head sts
        (_    ,(l,_)) = forestSpanToSimpPos $ treeStartEnd $ last sts

layoutTreeToSourceTree (T.Node (Entry sspan _lay toks) _ts) = leaf (mkUp sspan toks) (PToks toks)

-- -------------------------------------

-- We use the foldl version to get a more bushy tree, else the ppr of
-- it is very hard to follow
mconcatl :: (Monoid a) => [a] -> a
mconcatl = foldl mappend mempty

-- ---------------------------------------------------------------------

fs2s :: ForestSpan -> Span
fs2s ss = Span sp ep
  where
    (sp,ep) = forestSpanToSimpPos ss

-- ---------------------------------------------------------------------

mkUp :: ForestSpan -> [PosToken] -> Up
mkUp sspan toks = Up ss a ls []
  where
    a = ANone
    s = if forestSpanVersionSet sspan then SAdded else SOriginal
    ss = mkSpan sspan
    -- toksByLine = groupTokensByLine $ reAlignMarked toks
    toksByLine = groupTokensByLine toks

    ls = NE.fromList $ concatMap (mkLinesFromToks s) toksByLine

-- ---------------------------------------------------------------------

-- TODO: What if the toks comprise multiple lines, e.g. in a block comment?
mkLinesFromToks :: Source -> [PosToken] -> [Line]
mkLinesFromToks _ [] = []
mkLinesFromToks s toks = [Line ro co 0 s f toks']
  where
    f = ONone
    ro' = tokenRow $ head toks
    co' = tokenCol $ head toks
    (ro,co) = srcPosToSimpPos (tokenRow $ head toks, tokenCol $ head toks)
    toks' = addOffsetToToks (-ro',-co') toks

-- ---------------------------------------------------------------------

-- | Combine the 'U' annotations as they propagate from the leafs to
-- be cached at the root of the tree. This is the heart of the
-- DualTree functionality
combineUps :: Up -> Up -> Up
combineUps (UDeleted d1) (UDeleted d2)  = UDeleted (d1 <> d2)

combineUps (UDeleted d1) (Up sp2 a2 l2 d2) = (Up sp2 a2 l (d1 <> d2))
  where
    l = adjustForDeleted d1 l2

combineUps (Up sp1 a1 l1 d1) (UDeleted d2) = (Up sp1 a1 l1 (d1 <> d2))

combineUps (Up sp1 _a1 l1 d1) (Up sp2 _a2 l2 d2) = (Up (sp1 <> sp2) a l (d1 <> d2))
  where
    a = ANone

    l2' = adjustForDeleted d1 l2

    (Line _ _ o2 _ _ _) = NE.head l2'
    --         1    0
    l2'' = if o1 == o2
            then l2'
            else NE.fromList $ map (\(Line r c f aa ff s) -> (Line (r + (o1-f)) c (o1-f) aa ff s)) (NE.toList l2')

    (Line r1 c1  o1 ss1 ff1 s1) = NE.last l1
    (Line r2 c2 _o2 ss2 ff2 s2) = NE.head l2''

    l = if r1 == r2
         then NE.fromList $ (NE.init l1) ++ m ++ ll
         else NE.fromList $ (NE.toList l1) ++ rest

    s2' = addOffsetToToks (0,c2 - c1) s2

    s1' = s1 ++ s2'
    ff' = if ff1 == OGroup || ff2 == OGroup then OGroup else ONone
    m' = [Line r1 c1 o1 ss1 ff' s1']

    -- 'o' takes account of any length change due to tokens being
    --     replaced by others of different length
    odiff = sum $ map (\t@(_,s) -> (length s) - (tokenColEnd t - tokenCol t)) $ filter (not.isComment) s1

    st1 = GHC.showRichTokenStream s1
    st2 = GHC.showRichTokenStream (s1 ++ s2')
    st3 = drop (length st1) st2
    st4 = takeWhile (==' ') st3
    oo = length (st1++st4)
    coo = c1 + oo
    o = coo - c2

    (m,ll) = if (ss1 /= ss2) && (length s1 == 1 && (tokenLen $ head s1) == 0)
          then ([NE.last l1],map (\(Line r c f aa ff s) -> (Line (r+1) (c + o) (f+1) aa ff s)) (NE.toList l2''))
          else if ff' == OGroup
                 then (m',addOffsetToGroup o (NE.tail l2''))
                 else (m',                   (NE.tail l2''))

    -- rest = if ff2 == OGroup
    rest = if ff2 == OGroup && ff1 == OGroup
            then addOffsetToGroup odiff (NE.toList l2'')
            else NE.toList l2''

    addOffsetToGroup _off [] = []
    addOffsetToGroup _off (ls@((Line _r _c _f _aa ONone _s):_)) = ls
    addOffsetToGroup  off ((Line r c f aa OGroup s):ls)
               = (Line r (c+off) f aa OGroup s) : addOffsetToGroup off ls

{-


Should be 7 7 0 on second line

    (Up
      (Span (5, 7) (7, 19)) ANone
      [(Line 5 7 0 SOriginal OGroup \"let park = 3\"),
       (Line 7 5 0 SOriginal OGroup \"let expr = 2\")]
      []),

combining (where "park" was originally "parsed" i.e. 2 letters shorter

  [((Up
      (Span (5, 7) (5, 21)) ANone
      [(Line 5 7 0 SOriginal OGroup \"let park = 3\")]
      []),

   ((Up
      (Span (7, 7) (7, 19)) ANone
      [(Line 7 7 0 SOriginal OGroup \"let expr = 2\")]
      []),















--------------------------------------------------------

((((36,23),(41,25)),ITblockComment \" ++AZ++ : hsBinds does not re

(Up
   (Span (31, 23) (34,
                   72)) ANone
   [(Line 31 23 0 SOriginal ONone \"-- renamed <- getRefactRenamed\"),
    (Line 32 23 0 SOriginal OGroup \"let renamed = undefined\"),
    (Line 33 23 0 SOriginal OGroup \"let declsr = hsBinds renamed\"),
    (Line 34 23 0 SOriginal OGroup \"let (before,parent,after) = divideDecls declsr pn\"),
    (Line 35 23 0 SOriginal OGroup \"-- error (\"liftToMod:(before,parent,after)=\" ++ (showGhc (before,parent,after))) -- ++AZ++\"),
    (Line 36 23 0 SOriginal OGroup \"{- ++AZ++ : hsBinds does not return class or instance definitions
                      when (isClassDecl $ ghead \"liftToMod\" parent)
                            $ error \"Sorry, the refactorer cannot lift a definition from a class declaration!\"
                      when (isInstDecl $ ghead \"liftToMod\" parent)
                            $ error \"Sorry, the refactorer cannot lift a definition from an instance declaration!\"
                      -}\")]
    [])

------------------------

(Up
    (Span (42, 23) (43,
                    79)) ANone
    [(Line 42 23 0 SOriginal OGroup \"let liftedDecls = definingDeclsNames [n] parent True True\"),
     (Line 43 27 0 SOriginal OGroup \"declaredPns = nub $ concatMap definedPNs liftedDecls\")]
    [])
-}
{-

(Line
r1 = 10
c1 = 3
o1 = 0
ss1 = SOriginal
ff1 = ONone
s1 = \"g2 <- getCurrentModuleGraph\")

(Line
r2 = 11
c2 = 3
o2 = 0
ss2 = SOriginal
ff2 = OGroup
s2 = \"let scc = topSortModuleGraph False g2 Nothing\")

---
(Up
   (Span (9, 3) (11, 47)) ANone
   [(Line 9 3 0 SOriginal ONone \"-- g <- GHC.getModuleGraph\"),
    (Line 10 3 0 SOriginal ONone \"g2 <- getCurrentModuleGraph\"),
    (Line 11 4 0 SOriginal OGroup \"let scc = topSortModuleGraph False g2 Nothing\")]
   [])

-------------------------

Up1
(Up
  (Span (9, 3) (10, 29)) ANone
  [(Line 9 3 0 SOriginal ONone \"-- g <- GHC.getModuleGraph\"),
   (Line 10 3 0 SOriginal ONone \"g2 <- getCurrentModuleGraph\")]
  [])

Up2
(Up
  (Span (11, 3) (11, 47)) ANone
  [(Line 11 3 0 SOriginal OGroup \"let scc = topSortModuleGraph False g2 Nothing\")]
  [])

-}

{-

((o,st1,st3)=(0,"x y= sq x + sq y where"," sq x= x^pow"))

(Line
r1 = 7
c1 = 12
o1 = 0
ss1 = SOriginal
ff1 = ONone
s1 = \"x y= square x + square y where\")

(Line
r2 = 7
c2 = 35
o2 = 0
ss2 = SOriginal
ff2 = OGroup
s2 = \"square x= x^pow\")

------------------------

(Up
  (Span (7, 12) (9, 40)) ANone
  [(Line 7 12 0 SOriginal OGroup \"x y= square x + square y where square x= x^pow\"),
   (Line 8 -5 0 SOriginal OGroup \"--There is a comment.\"),
   (Line 9 27 0 SOriginal OGroup \"pow=2\")]
  [])

-------------
Up1
(Up
  (Span (7, 12) (7, 34)) ANone
  [(Line 7 12 0 SOriginal ONone \"x y= square x + square y where\")]
  [])

Up2
(Up
  (Span (7, 35) (9, 40)) AVertical
  [(Line 7 35 0 SOriginal OGroup \"square x= x^pow\"),
   (Line 8 3 0 SOriginal OGroup \"--There is a comment.\"),
   (Line 9 35 0 SOriginal OGroup \"pow=2\")]
  [])


-}



-- -------------------------------------

adjustForDeleted :: [DeletedSpan] -> NE.NonEmpty Line -> NE.NonEmpty Line
adjustForDeleted d1 l2 = l
  where
    deltaL = calcDelta d1
    l = NE.map go l2

    go (Line r c o SOriginal f str) =  Line (r - deltaL) c  o SOriginal f str
    go (Line r c o SWasAdded f str) =  Line (r - deltaL) c  o SWasAdded f str
    go (Line r c o SAdded    f str) =  Line  r           c  o SWasAdded f str

-- -------------------------------------

calcDelta :: [DeletedSpan] -> RowOffset
calcDelta d1 = deltaL
  where
    deltaL = case d1 of
              [] -> 0
              _  -> (-1) + (sum $ map calcDelta' d1)

    calcDelta' :: DeletedSpan -> RowOffset
    calcDelta' (DeletedSpan (Span (rs,_cs) (re,_ce)) pg (rd,_cd)) = r + 1
      where
        ol = re - rs
        eg = rd
        r = (pg + ol + eg) - (max pg eg)


-- ---------------------------------------------------------------------

mkSpan :: ForestSpan -> Span
mkSpan ss = Span s e
  where
   (s,e) = forestSpanToSimpPos ss

-- ---------------------------------------------------------------------
