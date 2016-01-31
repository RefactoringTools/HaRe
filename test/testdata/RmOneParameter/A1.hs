module RmOneParameter.A1 where
 
import RmOneParameter.D1

sumSq xs ys= sum (map sq xs) + sumSquares xs ys

main = sumSq [1..4]

