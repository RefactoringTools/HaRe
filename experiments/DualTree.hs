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

data Up = Up Span String
        deriving Show

data Span = Span (Int,Int) (Int,Int)
          deriving Show

data Annot = Ann String
           deriving Show

data Prim = Str [PosToken]
          deriving Show


--                            d            u    a     l
type SourceTree = DUALTree Transformation Up Annot Prim

{-
-- m1 :: SourceTree
m1 = do
  moduleToks <- basicTokenise "module"
  return $ leaf (Up (Span (1,1) (1, 6)) "module ") (Str moduleToks)

-- m2 :: SourceTree
m2 = do
  moduleToks <- basicTokenise "module"
  return $ leaf (Up (Span (1,8) (1,11)) "SourceTree") (Str "SourceTree")

ff d = applyD d m1
-}


instance Semigroup Span where
  (Span p1 p2) <> (Span q1 q2) = (Span p1 q2)

-- TODO: combine the strings according to the relative spans.
instance Semigroup Up where
  (Up sp1 str1) <> (Up sp2 str2) = (Up (sp1 <> sp2) (str1 <> str2))

instance Semigroup Transformation where
  (T n1) <> (T n2) = T (n1 + n2)

instance (Action Transformation Up) where
  act AsIs s = s
  act (T n) (Up span s) = (Up span s)


{-

m1 <> m2

DUALTree {unDUALTree = Option {getOption = Just (DUALTreeU {unDUALTreeU = 
   (Span (1,1) (1,11),
    Concat (DUALTreeU {unDUALTreeU = (Span (1,1) (1,6),Leaf (Span (1,1) (1,6)) (Str "module"))} 
        :| [DUALTreeU {unDUALTreeU = (Span (1,8) (1,11),Leaf (Span (1,8) (1,11)) (Str "Foo"))}]))})}}


-}


------------------------------------------------------------------------
{-

ff T 

  DUALTree {unDUALTree = Option {getOption = Just 
       (DUALTreeU {unDUALTreeU = 
          (Span (1,1) (1,6),
           Act T (DUALTreeU {unDUALTreeU = (Span (1,1) (1,6),Leaf (Span (1,1) (1,6)) (Str "module"))}))})}}

-}

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

build :: LayoutTree -> SourceTree
build (T.Node (Deleted _sspan  _pg _eg) _ ) = empty
build (T.Node (Entry sspan lay [])  ts0)   = mconcat $ map build ts0
build (T.Node (Entry sspan lay toks) _ts)  = leaf (Up (mkSpan sspan) (removeOffsetToks toks)) (Str toks)

-- ---------------------------------------------------------------------

mkSpan :: ForestSpan -> Span
mkSpan ss = Span s e
  where
   (s,e) = forestSpanToSimpPos ss

-- ---------------------------------------------------------------------

removeOffsetToks :: [PosToken] -> String
removeOffsetToks [] = ""
removeOffsetToks toks = str
  where
    ro' = tokenRow $ head toks
    co' = tokenCol $ head toks
    toks' = addOffsetToToks (-ro',-co') toks
    str = GHC.showRichTokenStream toks'
