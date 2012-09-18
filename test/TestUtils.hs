module TestUtils 
       (
       compareFiles
       ) where

import Data.Algorithm.Diff

compareFiles :: FilePath -> FilePath -> IO [(DI, [String])]
compareFiles fileA fileB = do
  astr <- readFile fileA
  bstr <- readFile fileB
  -- putStrLn $ "compareFiles " ++ (show $ lines astr) ++ "," ++ (show $ lines bstr) 
  return $ filter (\(c,_) -> c /= B) $ getGroupedDiff (lines astr) (lines bstr)

  