--- A simple system of mutually recursive datatypes --------------------------

module Datatypes where

import Data.Generics

data SortA = SortA1 SortB | SortA2 deriving (Show,Typeable,Data)
data SortB = SortB Integer SortA   deriving (Show,Typeable,Data)



------------------------------------------------------------------------------

