module GA3 where

zipperM :: [a] -> IO [(a, Integer)]
zipperM lst = do
  lst2 <- getOtherList
  return $ zip lst lst2

getOtherList = return [1..]
