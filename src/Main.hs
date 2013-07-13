{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}


import System.Console.CmdTheLine
import Control.Applicative       ( (<$>), (<*>) )
import System.IO

import Language.Haskell.Refact.Utils.Monad
import qualified Language.Haskell.Refact.Case as GhcRefacCase

-- Based initially on http://elifrey.com/2012/07/23/CmdTheLine-Tutorial/

main :: IO ()
-- main = run ( doRefac, info )
main = run ( doIfToCase, info )


-- convertTerm :: Term (IO ())
-- convertTerm = convert <$> fmap process invert <*> output <*> filesExist files

-- ifToCase :: [String] -> IO ()


doRefac :: Term (IO ())
doRefac = GhcRefacCase.doIfToCase <$> files

doIfToCase :: Term (IO ())
doIfToCase = GhcRefacCase.ifToCase <$> settings <*> mainFile <*> thisFile <*> startPos <*> endPos

mainFile = undefined
thisFile = undefined
startPos = undefined
endPos = undefined


 -- Define a flag argument under the names '--silent' and '-s'
--  silent :: Term Bool
 -- silent = value . flag $ optInfo [ "silent", "s" ]

-- defaultOpt :: ArgVal a => a -> a -> OptInfo -> Arg
-- defaultOpt def v ai is as opt except if it is present and no value is assigned on the command line, def is the result. 


settings :: Term (Maybe RefactSettings)
settings = value $ opt (Just defaultSettings) (optInfo [ "s", "settings"])

instance ArgVal (Maybe RefactSettings) where
  converter = just

instance ArgVal RefactSettings where
  converter = (pRefactSettings,ppRefactSettings)

pRefactSettings :: ArgParser RefactSettings
pRefactSettings _s = Right (RefSet ["."] False)

ppRefactSettings :: ArgPrinter RefactSettings
ppRefactSettings = undefined

 -- Define the 0th positional argument, defaulting to the value '"world"' in
 -- absence.
filename :: Term String
filename = value $ pos 0 "world" posInfo { posName = "GREETED" }


t1 = GhcRefacCase.doIfToCase ["./refactorer/B.hs","4","7","4","43"]

-- ---------------------------------------------------------------------
-- Command line processing

filesInfo :: PosInfo
filesInfo = posInfo
  { posName = "FILE"
  , posDoc  = "A list of files to read in. If empty, read from stdin."
  }

filesArg :: Arg [String]
filesArg = posAny [] filesInfo

files :: Term [String]
files = value filesArg

output :: Term (Maybe String)
output = value $ opt Nothing (optInfo [ "o", "out" ])
       { optDoc = "The path to a file to write output to.  If absent, write "
               ++ "to stdout."
       }

info :: TermInfo
info = defTI -- The default TermInfo
  { termName = "ghc-hare"
  , version  = "0.x.x.x"
  , termDoc  = "Haskell RefactorerConvert plain text pgm files to ascii art."
  }


