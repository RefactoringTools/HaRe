module AddOneParameter.C1 where

import AddOneParameter.D1

sumSquares1 (x:xs) = (sq sq_f) x + sumSquares1 xs

sumSquares1 [] = 0



