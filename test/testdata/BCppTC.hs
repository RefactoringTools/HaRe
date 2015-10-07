{-

A normal comment, to check if we can still pick up the CPP directive after it.

-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE CPP #-}
-- Check that we can parse a file which requires CPP
module BCppTC where

bob :: Int -> Int -> Int
#if __GLASGOW_HASKELL__ > 704
bob x y = x + y
#else
bob x y = x + y * 2
#endif

