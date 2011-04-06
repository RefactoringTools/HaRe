--- Main module for TwoSorts example -----------------------------------------

module Main where

import StrategyLib
import Datatypes

--- Test case: Apply idTP to an integer --------------------------------------

test1 = (applyTP idTP 1)::Maybe Integer

--- Test case: Increment when faced with an integer --------------------------

strat2 :: Monad m => TP m
strat2  = adhocTP idTP (\x -> return (x + 1::Integer))
test2   = applyTP strat2 1 :: Maybe Integer

--- Test case: Negate when faced with a Boolean ------------------------------

strat3 :: Monad m => TP m
strat3  = adhocTP idTP (return . not)
test3   = applyTP strat3 True :: Maybe Bool

--- Test case: Increment all integers one can find ---------------------------

term4   = SortA1 (SortB 1 (SortA1 (SortB 2 (SortA1 (SortB 3 SortA2)))))
strat4 :: Monad m => TP m
strat4  = full_tdTP strat2
test4   = applyTP strat4 term4 :: Maybe SortA

------------------------------------------------------------------------------

main = writeFile "Test.log"
                 (  show test1 ++ "\n"
                 ++ show test2 ++ "\n"
                 ++ show test3 ++ "\n"
                 ++ show test4 ++ "\n"
                 )
