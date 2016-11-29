module GA2 where
import Text.ParserCombinators.Parsec

parseStr :: CharParser () String 
parseStr = char '"' *> (many1 (noneOf "\"")) <* char '"'

objEntry :: CharParser () (String, String)
objEntry = do
  spaces
  str <- parseStr
  spaces
  char ':'
  spaces
  i <- many1 digit
  spaces
  return (str, i)
