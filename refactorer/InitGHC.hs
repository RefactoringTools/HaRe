module InitGHC(initGHC) where

import Prelude hiding (putStrLn)
import System.IO.Unsafe
import AbstractIO (putStrLn)
import Maybe
import List  
import TypeCheck
import RefacUtils 

initGHC filenames
 = do 
      AbstractIO.putStrLn $ ghcInit filenames
      