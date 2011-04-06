module Recursive where

{-+
This module defines a general class for converting to/from a recursive type
and its underlying structure.
-}

class Rec rec struct | rec->struct where
  rec    :: struct -> rec
  struct :: rec    -> struct

  mapRec :: (struct->struct) -> rec -> rec
  mapRec f = rec . f . struct
