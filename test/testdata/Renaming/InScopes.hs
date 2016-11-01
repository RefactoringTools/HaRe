module Renaming.InScopes where

-- based on https://github.com/RefactoringTools/HaRe/issues/41

-- renaming x to g should fail for a name clash, in all cases
f x = let g = 'g' in x

f1 x = do
  let g = 'g'
  return x

f2 x = x
  where
    g = 'g'

-- Renaming f to g should also fail, esp when the initial point is the function
-- definition for f
f3 x = y
  where
    g = f 'g'
    y = f2 x
