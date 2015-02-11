module Main where
   import Test.QuickCheck
   import St1

   prop_getStr :: Int -> String -> Bool
   prop_getStr i s = getStr (mkFoo i s) == s

   prop_getInt :: Int -> String -> Bool
   prop_getInt i s = getInt (mkFoo i s) == i

   prop_inc :: Int -> String -> Bool
   prop_inc i s = let foo = mkFoo i s in
      getInt (inc foo) == i+1

   prop_dec :: Int -> String -> Bool
   prop_dec i s = let foo = mkFoo i s in
      getInt (dec foo) == i-1

   main :: IO ()
   main = do
      quickCheck prop_getStr 
      quickCheck prop_getInt
      quickCheck prop_inc
      quickCheck prop_dec
