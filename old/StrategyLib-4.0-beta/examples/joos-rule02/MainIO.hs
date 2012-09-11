module MainIO where

import Prelude
import Monad
import System
import StrategyLib
import ParseLib
import Datatypes
import Parser
import Instance



--- Main function for I/O and transformation ---------------------------------

mainIO f1 f2
  = do {
         str          <- readFile f1;
         (trafo,prog) <- pApply parseTestFile str;
         prog'        <- tApply trafo prog;
         str'         <- (return.show) prog';
         writeFile f2 str'
       }



--- Parsing transformation scripts -------------------------------------------

parseTestFile :: Parser (TrafoJoos, Program)
parseTestFile = do {
                  td <- parseTrafoDeclaration;
                  parseSymbol "in";
                  prog <- parseProgram;
                  return (td,prog)
                }


parseTrafoDeclaration :: Parser TrafoJoos
parseTrafoDeclaration =
 do { parseSymbol "declare";
      md <- parseMethodDecl;
      return (introduceJoos md)
    }
 +++
 do { parseSymbol "eliminate";
      return eliminateJoos
    }
 +++
 do { parseSymbol "extract";
      i <- parseIdentifier;
      return (extractJoos i)
    }


--- Report on result of parsing ----------------------------------------------

pApply p s
  = case okParses of
      []     -> Monad.fail "ERROR: parsing failed!!\n"
      [x]    -> putStrLn "Status: successful parse." >> return (fst x)
      (x:xs) -> putStrLn "WARNING: ambiguous parse." >> return (fst x)
    where okParses = filter (null.snd) (papply p s)



--- Report on result of transformation ---------------------------------------

tApply trafo prog
 =
   case trafo prog of
    Nothing    -> putStrLn "WARNING: refactoring failed."    >> return prog
    Just prog' -> putStrLn "Status: successful refactoring." >> return prog' 



--- Illustrative code for focus selection  -----------------------------------

selectStatement :: Term t => t -> Maybe Statement
selectStatement =  applyTU selectStatementStrategy
  where
    selectStatementStrategy :: TU Statement Maybe
    selectStatementStrategy =  
      (adhocTU failTU 
               (\stat -> case stat of
                           StatementFocus stat' -> Just stat'
                           _                    -> Nothing))
      `choiceTU`
      oneTU selectStatementStrategy

------------------------------------------------------------------------------

selectStatement' :: Term t => t -> Maybe Statement
selectStatement' =  selectFocus unwrapStatememt
 where
  unwrapStatememt (StatementFocus stat') = Just stat'
  unwrapStatememt _ = Nothing

------------------------------------------------------------------------------
