module TestDoElim where

main = do putStrLn "Hello World"
          let hello =  "Hello"
	  world     <- return "World"
	  do let again = "Again"
	     putStrLn (hello++" "++world++" "++again)
