
import Renaming.ExportedType

-- renaming must distinguish between type name and constructor name
foo :: MyType -> Bool
foo (MyType 0) = True
foo (MyType _) = False

main = putStrLn "hello"
