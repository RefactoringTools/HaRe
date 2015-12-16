module MMP1 where

f :: Maybe Int -> Maybe Int
f Nothing = Nothing
f (Just i) = (Just (i + 1))
