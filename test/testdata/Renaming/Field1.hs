module Field1 where

--Rename field name 'pointx' to 'pointx1'

data Point = Pt {pointx, pointy :: Float} deriving Show

absPoint :: Point -> Float
absPoint p = sqrt (pointx p * pointx p +
                  pointy p * pointy p)

