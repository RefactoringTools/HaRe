module DeleteDef.Dd3 where

add5 :: (Num a) => a -> a
add5 x = x+5

add5ToAll :: (Num a) => [a] -> [a]
add5ToAll lst = map add5 lst
