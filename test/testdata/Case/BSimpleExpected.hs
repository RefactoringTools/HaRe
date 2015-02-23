module BSimpleExpected where
-- Test for refactor of if to case

foo x = case (odd x) of
            True  -> "Odd"
            False -> "Even"

