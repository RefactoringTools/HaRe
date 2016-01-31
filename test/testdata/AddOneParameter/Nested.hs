module AddOneParameter.Nested(sumSquares) where

{- add parameter 'y' to 'sumSquares'. 'sumSquares_y_1' to be added to the
   export list -}

sumSquares (x:xs) = sq x + sumSquares xs + foo xs
  where foo a = sumSquares a + 1
sumSquares [] = 0

sq x = x ^ pow

pow =2
