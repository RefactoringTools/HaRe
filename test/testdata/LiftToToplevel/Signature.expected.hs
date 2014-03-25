module LiftToTopLevel.Signature where

foo a = (baz x a)
  where
    x = 1

    y :: Int -> Int -> Int
    y a b = undefined




baz:: Int -> Int ->Int
baz x a= x  + a

