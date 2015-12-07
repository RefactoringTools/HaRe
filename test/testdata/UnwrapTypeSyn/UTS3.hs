module UTS3 where

type Foo = String

type Bar = (Int, Int)

addSpaces :: Foo -> Bar -> Foo
addSpaces str (row, col) = str ++ (take row rows) ++ (take col cols)
  where rows = repeat '\n'
        cols = repeat ' '
