module RefacIntroEvalDegree (refacDeepSeq) where

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

refacDeepSeq args = 
    do let fileName = args!!0
           beginRow = read (args!!1)::Int
           beginCol = read (args!!2)::Int
           endRow   = read (args!!3)::Int
           endCol   = read (args!!4)::Int

       (inscps, exps, mod, tokList) <- parseSourceFile fileName

       AbstractIO.putStrLn (show inscps)
           

       AbstractIO.putStrLn "refacDeepSeq Completed."