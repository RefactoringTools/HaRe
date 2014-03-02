{-# LANGUAGE ParallelListComp #-}
module Layout.PArr where

blah xs ys = [ (x, y) | x <- xs | y <- ys ]

-- bar = [: 1, 2 .. 3 :]

foo = 'a'
