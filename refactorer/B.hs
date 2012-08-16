module B where
-- Test for refactor of if to case

foo x = if (odd x) then "Odd" else "Even"

main = do
  putStrLn $ show $ foo 5
  