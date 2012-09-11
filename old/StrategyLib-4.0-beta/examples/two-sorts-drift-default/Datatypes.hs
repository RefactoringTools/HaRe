--- A simple system of mutually recursive datatypes --------------------------

module Datatypes where

data SortA = SortA1 SortB | SortA2 deriving Show
data SortB = SortB Integer SortA   deriving Show

------------------------------------------------------------------------------

