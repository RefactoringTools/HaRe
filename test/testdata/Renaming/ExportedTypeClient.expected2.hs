
import Renaming.ExportedType

-- renaming must distinguish between type name and constructor name
foo :: MyType -> Bool
foo (NewType 0) = True
foo (NewType _) = False

main = putStrLn "hello"
