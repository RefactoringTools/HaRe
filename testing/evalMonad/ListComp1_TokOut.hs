module ListComp1 where



qsort xs = [ (x,y) | x <- qsort (filter <) xs, y <- qsort filter (>=) xs ]