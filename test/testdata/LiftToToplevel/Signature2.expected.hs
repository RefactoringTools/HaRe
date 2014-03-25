module LiftToTopLevel.Signature2 where

{- Lifting baz to the top level should bring in xx and a as parameters,
   and update the signature to include these
-}
foo a = (baz xx a)
  where
    xx :: (Num t) => t -> t -> t
    xx p1 p2 = p1 + p2




baz:: (Num t) => (t -> t -> t) -> t ->t
baz xx a = xx 1 a

