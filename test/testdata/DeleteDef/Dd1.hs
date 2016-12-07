module DeleteDef.Dd1 where

--simple bind
c :: Integer
c = 5

remove5s :: [Integer] -> [Integer]
remove5s [] = []
remove5s (5:xs) = remove5s xs
remove5s (x:xs) =  x: (remove5s xs)

funcWithLet :: (Num a) => a -> a
funcWithLet x = let c = 12 in
  c * x

funcWithWhere :: (Num a) => a -> a
funcWithWhere x = x + c
  where c = 12

fact :: Integer -> Integer
fact 0 = 1
fact n = n * fact (n - 1)
