module LiftToTopLevel.Signature where

foo a = baz
  where
    baz :: Int
    baz = x  + a

    x = 1

    y :: Int -> Int -> Int
    y a b = undefined


