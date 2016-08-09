module UTS4 where

type Foo = (  Int,    String  )

type Bar = String

getInt :: Foo -> Int
getInt (i, _) = i

getString :: Foo -> String
getString (_, s) = s

addOne :: Foo -> Foo
addOne (i, s) = (i+1, s)
