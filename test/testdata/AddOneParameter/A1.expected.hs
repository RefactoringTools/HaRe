module AddOneParameter.A1 where

import AddOneParameter.C1

import AddOneParameter.D1

sumSq xs = sum (map (sq sq_f) xs) + sumSquares xs + sumSquares1 xs

main = sumSq [1..4]

