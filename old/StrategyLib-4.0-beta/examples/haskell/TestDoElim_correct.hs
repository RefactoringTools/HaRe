module TestDoElim where
main
  = putStrLn "Hello World" >>
      let hello = "Hello" in
        let ok world
              = let again = "Again" in
                  putStrLn (hello ++ " " ++ world ++ " " ++ again)
            ok _ = fail "Error: pattern-match failure in do-expression."
          in return "World" >>= ok
