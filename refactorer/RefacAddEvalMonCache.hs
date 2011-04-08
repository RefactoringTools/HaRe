module RefacAddEvalMonCache (refacAddEvalMonCache) where

import PrettyPrint
import PosSyntax
import Maybe
import TypedIds
import UniqueNames hiding (srcLoc)
import PNT 
import TiPNT 
import List  
import RefacUtils
import PFE0 (findFile)
import MUtils(( # ))
import AbstractIO
import Debug.Trace
import RefacMvDefBtwMod (addImport)
import LocalSettings


refacAddEvalMonCache args 
  = do
       let fileName     = args!!0
           beginRow     = read (args!!1)::Int
           beginCol     = read (args!!2)::Int  
           endRow       = read (args!!3)::Int
           endCol       = read (args!!4)::Int
       AbstractIO.putStrLn "refacAddEvalMonCache"
              
       (inscps, exps, mod, tokList) <- parseSourceFile fileName
       
       let res = locToPat (beginRow, beginCol) (endRow, endCol) tokList mod 

       if res /= defaultPat
         then do AbstractIO.writeFile evalFilePath (show res)
                 AbstractIO.putStrLn "RefacAddEvalMonCache Completed."
         else error "Please select a pattern binding!"
         
