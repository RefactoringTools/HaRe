module AddOneParameter.A2 where

import AddOneParameter.C2

import AddOneParameter.D2

sumSq xs = sum (map (sq sq_f) xs) + sumSquares xs + sumSquares1 xs

sq_f_2  = 2

main = sumSq [1..4]

