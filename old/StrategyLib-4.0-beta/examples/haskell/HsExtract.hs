module Main where

-------------------------------------------------------------------------------

-- An (incomplete) application extractor for Haskell.
-- First, redudant modules are discarded.
-- Then, dead code is eliminated from remaining modules.

-------------------------------------------------------------------------------

import HsFreeNames
import HsDeadCodeElim
import HsChaseImports
import Monad
import Language.Haskell.Syntax
import HsModuleCollection

-------------------------------------------------------------------------------

main
  = do putStrLn "\nHaskell application extraction:"
       hsIOwrapChasing (\x -> report x >>= extr >>= report >>= elim >>= report)
       putStrLn "Done.\n"
    where
       extr,elim :: ModuleCollection -> IO ModuleCollection
       extr = hsExtrAppl
       elim = hsElimDeadCode
	
-- Comment the following line to obtain intermediate reports:	
report ms = return ms	   
report ms
  = do putStrLn "\n== Report =="
       mapM worker ms
    where
      worker (n,i,m)
        = do (fn,dn) <- hsFreeAndDeclared m
             putStrLn $ "  Module "++n++":"
             putStrLn $ "    imports:           " ++ (show i) 
             putStrLn $ "    free names:        " ++ (show fn) 
             putStrLn $ "    declared names:    " ++ (show dn)
	     return (n,i,m)
	     
-------------------------------------------------------------------------------

