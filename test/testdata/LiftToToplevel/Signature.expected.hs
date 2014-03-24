module LiftToTopLevel.Signature where

foo a = (baz x a)
  where
    x = 1




baz :: Int -> Int -> Int
baz x a= x  + a

