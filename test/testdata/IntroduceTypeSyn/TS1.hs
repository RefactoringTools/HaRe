module TS1 where

type Foo = (String, Int)

getInt :: (String, Int) -> Int
getInt (_, i) = i
