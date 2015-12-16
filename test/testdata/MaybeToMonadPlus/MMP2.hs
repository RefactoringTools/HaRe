module MMP2 where

f :: Int -> Maybe String
f i =
  if (i == 0)
    then return (show i)
    else Nothing

f2 :: (Show a) => Maybe a -> IO ()
f2 m =
  case m of
  Nothing -> putStrLn "Something went wrong"
  (Just i) -> putStrLn $ "The result is: " ++ (show i)
  
