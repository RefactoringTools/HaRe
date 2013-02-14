module Ole where

{-f x = x + 1
-- function application
g x = f x

-- left section
lSec f = (f+)
-- right section
rSec f = (+f) -}

-- let expression with renamable variable on left- and right-hand-side (5)
h b = 
          let f = b in
          bob b + 42
             where bob x = 6
{-
-- lambda expression (1)
lam = \x -> x + x

-- case expression (2)
cas x = case x of
          Just j  -> j
          Nothing -> error "errorMessage"

-- if then else (3)
ite x = if x then g else (g)

-- pattern binding (4)
pat (Just x) = x
pat (Nothing) = f

-- where (6)
wher x = x + a
    where
      a = 2

-- data declaration (7)
data Foo = Bar Int
  deriving Show-}
