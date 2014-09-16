module DeleteDef.Dd1 where

--simple bind
c :: Integer
c = 5

remove5s :: [Integer] -> [Integer]
remove5s [] = []
remove5s (5:xs) = remove5s xs
remove5s (x:xs) =  x: (remove5s xs)
