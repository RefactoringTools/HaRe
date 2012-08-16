module B where
-- Test for refactor of if to case

foo x = if (odd x) then "Odd" else "Even"

foo' x = case (odd x) of
  True -> "Odd"
  False -> "Even"

main = do
  putStrLn $ show $ foo 5

mary = [1,2,3]

