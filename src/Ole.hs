module Ole where

f x = x + 1
-- function application
g x = f x

-- left section
lSec f = (f+)
-- right section
rSec f = (+f)

-- let expression with renamable variable on left- and right-hand-side
h x = do
          let f = x
          f + f

-- lambda expression
lam = \x -> x + x

-- case expression
cas x = case x of
          Just j  -> j
          Nothing -> error "errorMessage"

-- if then else
ite x = if x then g else (g)

-- pattern binding
pat (Just m) = f
pat (Nothing) = f

