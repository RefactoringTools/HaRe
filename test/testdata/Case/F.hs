module F where
-- Test for refactor of if to case

foo x = if (odd x)
          then do
            bob x 1
          else do
            bob x 2

bob x y = x + y
