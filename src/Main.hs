{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}


import System.Console.CmdTheLine
import Data.Maybe
import Control.Applicative       ( (<$>), (<*>) )
import qualified Text.PrettyPrint as PP

import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.DupDef
import qualified Language.Haskell.Refact.Case as GhcRefacCase

-- Based initially on http://elifrey.com/2012/07/23/CmdTheLine-Tutorial/

-- ---------------------------------------------------------------------

instance ArgVal (Maybe RefactSettings) where
   converter = just

instance ArgVal (Maybe SimpPos) where
  converter = just

instance ArgVal RefactSettings where
  converter = (pRefactSettings,ppRefactSettings)
    where
        pRefactSettings :: ArgParser RefactSettings
        pRefactSettings _s = Right (RefSet ["."] False)

        ppRefactSettings :: ArgPrinter RefactSettings
        ppRefactSettings s = PP.text (show s)


instance ArgVal SimpPos where
  converter = (pSimpPos, ppSimpPos)
    where
        pSimpPos :: ArgParser SimpPos
        pSimpPos s = res
          where
            res = case ((fmap fst . listToMaybe . reads) s) of
              Nothing -> Left $ PP.text "Expecting (row,col)"
              Just r -> Right r

        ppSimpPos :: ArgPrinter SimpPos
        -- ppSimpPos = error "ppSimpPos undefined"
        ppSimpPos s = PP.text (show s)


-- ---------------------------------------------------------------------
-- command line argument types

mainFile :: Term (Maybe FilePath)
mainFile = value $ opt Nothing (optInfo ["m","main"])
     { optName = "main"
     , optDoc  = "The Haskell main file, if there is one"
     , optSec  = "OPTSEC"
     }


thisFile :: Term FilePath
thisFile = required $ pos 0 Nothing posInfo
    { posName = "file"
    , posDoc = "The file originating the refactoring."
    }

startRow :: Int -> Term Int
startRow p = required $ pos p Nothing posInfo
    { posName = "startline"
    , posDoc = "The line of the start of the refactoring."
    }

startCol :: Int -> Term Int
startCol p = required $ pos p Nothing posInfo
    { posName = "startcol"
    , posDoc = "The col of the start of the refactoring."
    }

endRow :: Int -> Term Int
endRow p = required $ pos p Nothing posInfo
    { posName = "endline"
    , posDoc = "The line of the end of the refactoring."
    }

endCol :: Int -> Term Int
endCol p = required $ pos p Nothing posInfo
    { posName = "endcol"
    , posDoc = "The col of the end of the refactoring."
    }

newName :: Int -> Term String
newName p = required $ pos p Nothing posInfo
    { posName = "newname"
    , posDoc = "The new name."
    }


settings :: Term (Maybe RefactSettings)
settings = value $ opt (Just defaultSettings) (optInfo [ "s", "settings"])

-- ---------------------------------------------------------------------

-- 'input' is a common option. We set its 'optSec' field to 'comOpts' so
-- that it is placed under that section instead of the default '"OPTIONS"'
-- section, which we will reserve for command-specific options.
input :: Term (Maybe String)
input = value $ opt Nothing (optInfo [ "input", "i" ])
      { optName = "INPUT"
      , optDoc = "For specifying input on the command line. If present, "
               ++ "input is not read form standard-in."
      , optSec = comOpts
      }


-- ---------------------------------------------------------------------

main :: IO ()
main = runChoice defaultTerm [ ifToCaseTerm, duplicateDefTerm ]

defaultTerm :: (Term a, TermInfo)
defaultTerm = ( ret $ const (helpFail Pager Nothing) <$> input
              , info
              )
  where
    info :: TermInfo
    info = defTI'
      { termName = "ghc-hare"
      , version  = "0.x.x.x"
      , termDoc  = doc
      }


ifToCaseTerm :: (Term (IO ()), TermInfo)
ifToCaseTerm = (doIfToCase, info)
  where

    doIfToCase :: Term (IO ())
    doIfToCase = ifToCase <$> settings <*> mainFile <*> thisFile
               <*> startRow 1 <*> startCol 2 <*> endRow 3 <*> endCol 4

    ifToCase s m f sr sc er ec
      = GhcRefacCase.ifToCase s m f (sr,sc) (er,ec)

    info :: TermInfo
    info = defTI'
      { termName = "iftocase"
      , version  = "0.x.x.x"
      , termDoc  = doc
      }

-- ---------------------------------------------------------------------

-- duplicateDef :: Maybe RefactSettings -> Maybe FilePath -> FilePath -> String -> SimpPos -> IO ()
-- duplicateDef settings maybeMainFile fileName newName (row,col) =

duplicateDefTerm :: (Term (IO ()), TermInfo)
duplicateDefTerm = (doDupDef,info)
  where
    doDupDef :: Term (IO ())
    doDupDef = dupDef <$> settings <*> mainFile <*> thisFile <*> newName 1 <*> startRow 2 <*> startCol 3

    dupDef s m f nn r c = duplicateDef s m f nn (r,c)

    info :: TermInfo
    info = defTI'
      { termName = "dupdef"
      , version  = "0.x.x.x"
      , termDoc  = doc
      }

-- ---------------------------------------------------------------------

doc :: String
doc = "Haskell Refactorer"


-- The heading under which to place common options.
comOpts :: String
comOpts = "COMMON OPTIONS"

-- A modified default 'TermInfo' to be shared by commands.
defTI' :: TermInfo
defTI' = defTI
  { man =
      [ S comOpts
      , P "These options are common to all commands."
      , S "MORE HELP"
      , P "Use '$(mname) $(i,COMMAND) --help' for help on a single command."
      , S "BUGS"
      , P "Email bug reports to <foo@bar.com>"
      ]
  , stdOptSec = comOpts
  }

