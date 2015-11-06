module LiftToTop3evel.Collapse1 where

collapse' _ _ [] = []
collapse' left space (t:ts) = new : collapse' right space rest
  where
    (_, leftInner)  = left
    rightInner      = leftInner   + symbolSize t
    right           = (rightInner, (rightOuter rightInner rights))
    (rights, rest)  = span space ts
    new             = (t, Bounds left right)

rightOuter rightInner rights      = rightInner  + symbolSize rights

data Bounds = Bounds (Int,Int) (Int,Int)
symbolSize t = 4

