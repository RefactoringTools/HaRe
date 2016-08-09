module MMP3 where

dv :: Int -> Maybe Int -> Maybe Int
dv _ Nothing = Nothing
dv i (Just v) = case i of
  0 -> Nothing
  n -> (Just (v `div` n))
