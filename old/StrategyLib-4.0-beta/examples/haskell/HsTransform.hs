module Main where

-------------------------------------------------------------------------------

--- This module provides a main function that pipelines all example 
--- transformations, and applies them to the input file specified at the
--- command line.

-------------------------------------------------------------------------------

import Language.Haskell.Syntax
import SyntaxTermInstances
import DoElim
import NewTypeIntro
import HsIOWrap
import IO

--- Main program --------------------------------------------------------------

main 
 = do hPutStrLn stderr "\nHaskell transformations:"
      hPutStrLn stderr "  * elimination of 'do' expressions"
      hPutStrLn stderr "  * conversion of data to newtype declarations"
      hsIOwrap (mpipe [doElim,newtypeIntro])
      hPutStrLn stderr "Done.\n"



--- Helpers -------------------------------------------------------------------

mpipe [] x	= return x
mpipe (f:fs) x  = f x >>= mpipe fs

-------------------------------------------------------------------------------

