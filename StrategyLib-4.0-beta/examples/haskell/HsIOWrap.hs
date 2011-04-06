module HsIOWrap where

-------------------------------------------------------------------------------

--- This module provides wrapper functions for analyses and transformations
--- that take care of file IO, parsing and pretty-printing.

-------------------------------------------------------------------------------

import System
import Language.Haskell.Syntax(HsModule,SrcLoc(..))
import Language.Haskell.Parser
import Language.Haskell.Pretty(prettyPrint)
import IO

--- Transformation wrapper ----------------------------------------------------

hsIOwrap transform
  = do [fin,fout] <- getArgs
       hPutStrLn stderr ("Reading file: "++fin)
       sin        <- readFile fin
       let pin    = parseWrap sin
       let Just pout = transform pin
       let sout = (prettyPrint pout)++"\n"
       hPutStrLn stderr ("Writing file: "++fout)
       writeFile fout sout
       
------------------------------------------------------------------------       
       
parseWrap :: String -> HsModule
parseWrap x = forceResult (parseModule x)

parseWrap' :: String -> Either HsModule String
parseWrap' x
        = case (parseModule x) of
            (ParseOk x)              -> Left x
            (ParseFailed _ msg)      -> Right msg

forceResult :: ParseResult a -> a
forceResult (ParseOk x)         = x
forceResult (ParseFailed _ msg) = error msg

-------------------------------------------------------------------------------
