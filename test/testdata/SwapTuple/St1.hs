module SwapTuple.St1 where
   import Control.Concurrent

   type Foo = (String, Int)

   mkFoo :: Int -> String -> Foo
   mkFoo i s = (s,i)

   getStr :: Foo -> String
   getStr foo = fst foo

   getInt :: Foo -> Int
   getInt (_,i) = i

   inc :: Foo -> Foo
   inc (s,i) = (s,i+1)

   dec :: Foo -> Foo
   dec (s,i) = (s, i-1)

   replaceMsg :: String -> Foo -> Foo
   replaceMsg s f = (s, (getInt f))

   replaceInt :: Foo -> Int -> Foo
   replaceInt f i = (getStr f, i)
   countDown :: Foo -> IO ()
   countDown foo = do
      putStrLn $ fst foo
      if (snd foo) <= 0 
         then 
            putStrLn "Exiting..."
         else do
            threadDelay 1000000
            countDown $ dec foo
