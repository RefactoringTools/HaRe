module TS2 where



getInt :: (String, Int) -> Int
getInt (_, i) = i

count :: String -> (Int, String)
count s = (length s, s)

mk :: Int -> String -> (String, Int)
mk i s = (s, i)
