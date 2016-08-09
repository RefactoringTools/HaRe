module FunIn6 where

--Default parameters can be added to definition of functions and simple constants.

--In this example: add parameter 'y' to 'foo'

main :: IO Integer
main = do
  let foo y = return [1..4]

      foo_y = undefined
  x <- (foo foo_y)
  return (sum x)
