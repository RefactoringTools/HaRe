module AddOneParameter.FunIn6 where

--Default parameters can be added to definition of functions and simple constants.

--In this example: add parameter 'y' to 'foo'

main :: IO Integer
main = do
  let foo = return [1..4]
  x <- foo
  return (sum x)
