module Main where

import Bottom
import DeadModule

main :: IO ()
main = putStr ""

top = liveFun1 1 (liveFun2 2)

liveFun2 liveVar
 = liveFun3 liveVar
   where
     liveFun3 x = x
     deadFun3 y = y


