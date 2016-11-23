module GA4 where

failBoundPrecon :: IO [String]
failBoundPrecon = do
  fileName <- getLine
  file <- readFile fileName
  return $ lines file
  
  
