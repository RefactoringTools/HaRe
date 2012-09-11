module Main where

import MainIO
import System

main = do 
         [f1,f2] <- getArgs
         mainIO f1 f2
