
import System.Console.CmdTheLine
import Control.Applicative       ( (<$>), (<*>) )
import System.IO

import qualified Language.Haskell.Refact.Case as GhcRefacCase

-- Based initially on http://elifrey.com/2012/07/23/CmdTheLine-Tutorial/

-- main = t1
main = run ( doRefac, info )


-- convertTerm :: Term (IO ())
-- convertTerm = convert <$> fmap process invert <*> output <*> filesExist files

-- ifToCase :: [String] -> IO ()


doRefac :: Term (IO ())
doRefac = GhcRefacCase.ifToCase <$> files


 -- Define the 0th positional argument, defaulting to the value '"world"' in
 -- absence.
filename :: Term String
filename = value $ pos 0 "world" posInfo { posName = "GREETED" }


t1 = GhcRefacCase.ifToCase ["./refactorer/B.hs","4","7","4","43"]

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


