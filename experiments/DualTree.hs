{-# LANGUAGE MultiParamTypeClasses #-}

module Main where

import Data.Tree.DUAL
import Data.Semigroup
import Data.Monoid.Action

main = putStrLn "hello"


data Transformation = T
                    deriving Show

data Span = Span (Int,Int) (Int,Int)
          deriving Show

data Prim = Str String
          deriving Show

data Annot = Ann String
           deriving Show
--                    d             u    a     l
type Foo = DUALTree Transformation Span Annot Prim

m1 :: Foo
m1 = leaf (Span (1,1) (1, 6)) (Str "module")


m2 :: Foo
m2 = leaf (Span (1,8) (1,11)) (Str "Foo")

ff d = applyD d m1

instance Semigroup Span where
  (Span p1 p2) <> (Span q1 q2) = (Span p1 q2)

instance Semigroup Transformation where
  T <> T = T

instance (Action Transformation Span) where
  act T s = s

--------------------------------------
{-

ff T 

  DUALTree {unDUALTree = Option {getOption = Just 
       (DUALTreeU {unDUALTreeU = 
          (Span (1,1) (1,6),
           Act T (DUALTreeU {unDUALTreeU = (Span (1,1) (1,6),Leaf (Span (1,1) (1,6)) (Str "module"))}))})}}

-}
