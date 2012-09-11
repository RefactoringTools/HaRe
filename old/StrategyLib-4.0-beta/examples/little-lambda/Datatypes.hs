{-----------------------------------------------------------------------------

			Example: LITTLE LAMBDA

			     StrategyLib

                   Ralf Laemmel                Joost Visser
               CWI & VU, Amsterdam            CWI, Amsterdam

-----------------------------------------------------------------------------}

module Datatypes where

--- Grammar ------------------------------------------------------------------

data Type = TVar Identifier
          | Arrow Type Type
          deriving (Show,Eq)
data Expr = Var Identifier
          | Apply Expr Expr
          | Lambda Identifier Type Expr
          deriving (Show,Eq)

type Identifier = String

------------------------------------------------------------------------------
