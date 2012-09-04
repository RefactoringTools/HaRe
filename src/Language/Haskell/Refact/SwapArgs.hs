module Language.Haskell.Refact.SwapArgs (swapArgs) where

import qualified Data.Generics.Schemes as SYB
import qualified Data.Generics.Aliases as SYB
import qualified GHC.SYB.Utils         as SYB

import qualified GHC
import qualified DynFlags              as GHC
import qualified Outputable            as GHC
import qualified MonadUtils            as GHC
import qualified RdrName               as GHC
import qualified OccName               as GHC
 
import GHC.Paths ( libdir )
import Control.Monad
import Control.Monad.State
import Data.Data
-----------------

import Language.Haskell.Refact.Utils 
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.Monad

swapArgs :: [String] -> IO () -- For now
swapArgs args
  = do let fileName = args!!0              
           row = (read (args!!1)::Int)
           col = (read (args!!2)::Int)	
       modInfo@((_, _, mod), toks) <- parseSourceFile fileName 
       -- putStrLn $ showParsedModule mod
       let pnt = locToPNT fileName (row, col) mod  
       putStrLn "l" -- $ show [fileName, beginPos, endPos]

showParsedModule p = SYB.showData SYB.Parser 0 (GHC.pm_parsed_source p)
