module Constructor where

-- Should be able to rename AType to MyType, as they are in different name
-- spaces
data MyType = MyType Int | YourType Bool

foo :: MyType -> Bool
foo (MyType i)   = i > 0
foo (YourType b) = b
