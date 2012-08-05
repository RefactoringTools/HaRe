module SimpleIn1 where



f x@[] = case x of
            []     -> error "head:empty list"
            (x:xs) -> x

f_1 x@[]
    =   case x of
            [] -> 0
            (x : xs) -> 1

g :: [Int] -> Int
g (x:xs) = x + head ( tail xs)

