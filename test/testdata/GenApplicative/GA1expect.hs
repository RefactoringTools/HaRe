module GA1 where
import Text.ParserCombinators.Parsec

parseStr :: CharParser () String
parseStr = char '"' *> (many1 (noneOf "\"")) <* char '"'
