module AddOneParameter.C1 where 

import AddOneParameter.D1

sumSquares1 (x:xs) = sq x + sumSquares1 xs

sumSquares1 [] = 0



