module LiftToToplevel.LiftInLambda where

foo :: IO [(Char,[Int])]
foo = do
  let
    xx = map (\b -> (b,(uses everythingStaged) declaredPns [b])) ['a','b']
  return xx

  where
    declaredPns = undefined
    everythingStaged = undefined

uses everythingStaged pns t2 = everythingStaged pns [1..10]

