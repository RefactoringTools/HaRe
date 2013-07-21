------------------------------------------------------------------------------

module MainIO where

import StrategyLib hiding (replaceFocus)
import VarsAnalyses
import Extraction
import ParseLib (papply)
import Datatypes
import Parser

------------------------------------------------------------------------------

mainIO = pWrap parseClassDeclaration performExtraction (return.show)

pWrap parser trafo pper f1 f2
  = do s  <- readFile f1
       t  <- pApply parser s
       t' <- trafo t
       s' <- pper t'
       writeFile f2 s'

pApply p s
  = case okParses of
      []     -> fail "Parse failed!!\n"
      [x]    -> putStrLn "Status: successful parse." >> return (fst x)
      (x:xs) -> putStrLn "WARNING: ambiguous parse." >> return (fst x)
    where okParses = filter (null.snd) (papply p s)
      
performExtraction t
  = case extractMethod t of
       Just t'  -> putStrLn "Status: successful extraction." >> return t'
       Nothing  -> putStrLn "WARNING: extraction failed." >> return t

