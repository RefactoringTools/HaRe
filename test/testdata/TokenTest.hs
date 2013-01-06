module TokenTest where

-- Test new style token manager

bob a b = x
  where x = 3

bib a b = x
  where 
    x = 3


bab a b =
  let bar = 3
  in     b + bar

foo x y =
  do c <- getChar
     return c




