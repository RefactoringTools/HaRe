module SimpleIn1 where

import PreludeBuiltin

f :: [a] -> a
f y@(z:zs) = if y == [] then error "blah" else zs


hd x = (case x of
            (x : _) -> x
            [] -> error "Prelude.head: empty list")
tl x = tail x
