module LiftToToplevel.PatBindIn4 where

-- Issue https://github.com/RefactoringTools/HaRe/issues/42
-- liftToTopLevel of a should fail.
-- Alternatively, it should result in something like
{-
f x = a x
a x = fst (x, x)
b x = snd (x, x)
-}

f x = let (a, b) = (x, x) in a
