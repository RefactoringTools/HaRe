module SubFun3 where

--Any unused parameter to a definition can be removed.

--In this example: remove x. The brackets enclosing 'foo' will also be removed.

main :: IO Int
main = do
  let
    foo x = h + t where (h,t) = head $ zip [1..10] [3..10]
  return $ (foo 4) + (foo 5)
