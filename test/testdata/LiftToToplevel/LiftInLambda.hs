module LiftToToplevel.LiftInLambda where

foo :: IO [(Char,[Int])]
foo = do
  let
    xx = map (\b -> (b,uses declaredPns [b])) ['a','b']
  return xx

  where
    uses pns t2 = everythingStaged pns [1..10]

    declaredPns = undefined
    everythingStaged = undefined

