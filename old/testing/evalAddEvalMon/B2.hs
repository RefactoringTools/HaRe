module B2 where

import Control.Parallel.Strategies (rseq,rpar,runEval)

-- test when already import strategies the import doesn't change.

-- here we need to add rpar and runEval to the import list

qsort (x:xs) = lsort_2 ++ [x] ++ hsort
  where
    lsort = qsort (filter (<) x xs)
    hsort = qsort (filter (>=) x xs)    
    lsort_2
        =
            runEval
                (do lsort_2 <- rpar lsort
                    return lsort_2)