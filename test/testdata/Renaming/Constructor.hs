module Constructor where

-- Should be able to rename AType to MyType, as they are in different name
-- spaces
data MyType = AType Int | YourType Bool

foo :: MyType -> Bool
foo (AType i)   = i > 0
foo (YourType b) = b
