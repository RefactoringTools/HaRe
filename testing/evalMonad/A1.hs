module A1 where

f n 
  | n <= 1    = 1
  | otherwise = n1 + n2 + 1
      where
       n1 = f (n-1)
       n2 = f (n-2)


n1_2 = "bob"

