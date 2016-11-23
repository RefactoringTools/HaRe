module GA4 where

failBoundPrecon :: IO [String]
failBoundPrecon = do
  fileName <- getLine
  file <- readFile fileName
  return $ lines file
  
failOrderPrecon :: IO (Int,Int)
failOrderPrecon = do
  b <- getB
  a <- getA
  return (a,b)

getA = return 1
getB = return 2
