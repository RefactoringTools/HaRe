module Renaming.ExportedType where

-- Same constructor name as the type name, check we can choose the right one in a client module
data MyType = MyType Int
