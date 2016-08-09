module UTS2 where

type Foo = (  Int,    String  )

type Bar = String

getInt :: Foo -> Int
getInt (i, _) = i
