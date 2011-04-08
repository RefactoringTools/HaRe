-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Generics.Instances
-- Copyright   :  (c) The University of Glasgow, CWI 2001--2004
-- License     :  BSD-style (see the file libraries/base/LICENSE)
-- 
-- Maintainer  :  libraries@haskell.org
-- Stability   :  experimental
-- Portability :  non-portable (uses Data.Generics.Basics)
--
-- \"Scrap your boilerplate\" --- Generic programming in Haskell 
-- See <http://www.cs.vu.nl/boilerplate/>. The present module
-- instantiates the class Data for Prelude-like datatypes.
-- (This module does not export anything. It really just defines instances.)
--
-----------------------------------------------------------------------------

module Data.Generics.Instances 

where


------------------------------------------------------------------------------

import Data.Generics.Basics

import Data.Typeable




 
------------------------------------------------------------------------------
--
--	Instances of the Data class for Prelude-like types.
--	We define top-level definitions for representations.
--
------------------------------------------------------------------------------


falseConstr  = mkConstr boolDataType "False" [] Prefix
trueConstr   = mkConstr boolDataType "True"  [] Prefix
boolDataType = mkDataType "Prelude.Bool" [falseConstr,trueConstr]


instance Data Bool where
  toConstr False = falseConstr
  toConstr True  = trueConstr
  gunfold k z c  = case constrIndex c of
                     1 -> z False
                     2 -> z True
                     _ -> error "gunfold"
  dataTypeOf _ = boolDataType


------------------------------------------------------------------------------


charType = mkStringType "Prelude.Char"

instance Data Char where
  toConstr x = mkStringConstr charType [x]
  gunfold k z c = case constrRep c of
                    (StringConstr [x]) -> z x
                    _ -> error "gunfold"
  dataTypeOf _ = charType


------------------------------------------------------------------------------


floatType = mkFloatType "Prelude.Float"

instance Data Float where
  toConstr x = mkFloatConstr floatType (realToFrac x)
  gunfold k z c = case constrRep c of
                    (FloatConstr x) -> z (realToFrac x)
                    _ -> error "gunfold"
  dataTypeOf _ = floatType


------------------------------------------------------------------------------


doubleType = mkFloatType "Prelude.Double"

instance Data Double where
  toConstr = mkFloatConstr floatType
  gunfold k z c = case constrRep c of
                    (FloatConstr x) -> z x
                    _ -> error "gunfold"
  dataTypeOf _ = doubleType


------------------------------------------------------------------------------


intType = mkIntType "Prelude.Int"

instance Data Int where
  toConstr x = mkIntConstr intType (fromIntegral x)
  gunfold k z c = case constrRep c of
                    (IntConstr x) -> z (fromIntegral x)
                    _ -> error "gunfold"
  dataTypeOf _ = intType


------------------------------------------------------------------------------


integerType = mkIntType "Prelude.Integer"

instance Data Integer where
  toConstr = mkIntConstr integerType
  gunfold k z c = case constrRep c of
                    (IntConstr x) -> z x
                    _ -> error "gunfold"
  dataTypeOf _ = integerType


------------------------------------------------------------------------------


------------------------------------------------------------------------------


nilConstr    = mkConstr listDataType "[]" [] Prefix
consConstr   = mkConstr listDataType "(:)" [] Infix
listDataType = mkDataType "Prelude.[]" [nilConstr,consConstr]

instance Data a => Data [a] where
  gfoldl f z []     = z []
  gfoldl f z (x:xs) = z (:) `f` x `f` xs
  toConstr []    = nilConstr
  toConstr (_:_) = consConstr
  gunfold k z c = case constrIndex c of
                    1 -> z []
                    2 -> k (k (z (:)))
                    _ -> error "gunfold"
  dataTypeOf _ = listDataType
  dataCast1 f  = gcast1 f

--
-- The gmaps are given as an illustration.
-- This shows that the gmaps for lists are different from list maps.
--
  gmapT  f   []     = []
  gmapT  f   (x:xs) = (f x:f xs)
  gmapQ  f   []     = []
  gmapQ  f   (x:xs) = [f x,f xs]
  gmapM  f   []     = return []
  gmapM  f   (x:xs) = f x >>= \x' -> f xs >>= \xs' -> return (x':xs')


------------------------------------------------------------------------------


nothingConstr = mkConstr maybeDataType "Nothing" [] Prefix
justConstr    = mkConstr maybeDataType "Just"    [] Prefix
maybeDataType = mkDataType "Prelude.Maybe" [nothingConstr,justConstr]

instance Data a => Data (Maybe a) where
  gfoldl f z Nothing  = z Nothing
  gfoldl f z (Just x) = z Just `f` x
  toConstr Nothing  = nothingConstr
  toConstr (Just _) = justConstr
  gunfold k z c = case constrIndex c of
                    1 -> z Nothing
                    2 -> k (z Just)
                    _ -> error "gunfold"
  dataTypeOf _ = maybeDataType
  dataCast1 f  = gcast1 f


------------------------------------------------------------------------------


ltConstr         = mkConstr orderingDataType "LT" [] Prefix
eqConstr         = mkConstr orderingDataType "EQ" [] Prefix
gtConstr         = mkConstr orderingDataType "GT" [] Prefix
orderingDataType = mkDataType "Prelude.Ordering" [ltConstr,eqConstr,gtConstr]

instance Data Ordering where
  gfoldl f z LT  = z LT
  gfoldl f z EQ  = z EQ
  gfoldl f z GT  = z GT
  toConstr LT  = ltConstr
  toConstr EQ  = eqConstr
  toConstr GT  = gtConstr
  gunfold k z c = case constrIndex c of
                    1 -> z LT
                    2 -> z EQ
                    3 -> z GT
                    _ -> error "gunfold"
  dataTypeOf _ = orderingDataType


------------------------------------------------------------------------------


leftConstr     = mkConstr eitherDataType "Left"  [] Prefix
rightConstr    = mkConstr eitherDataType "Right" [] Prefix
eitherDataType = mkDataType "Prelude.Either" [leftConstr,rightConstr]

instance (Data a, Data b) => Data (Either a b) where
  gfoldl f z (Left a)   = z Left  `f` a
  gfoldl f z (Right a)  = z Right `f` a
  toConstr (Left _)  = leftConstr
  toConstr (Right _) = rightConstr
  gunfold k z c = case constrIndex c of
                    1 -> k (z Left)
                    2 -> k (z Right)
                    _ -> error "gunfold"
  dataTypeOf _ = eitherDataType
  dataCast2 f  = gcast2 f


------------------------------------------------------------------------------


--
-- A last resort for functions
--

instance (Data a, Data b) => Data (a -> b) where
  toConstr _   = error "toConstr"
  gunfold _ _  = error "gunfold"
  dataTypeOf _ = mkNorepType "Prelude.(->)"
  dataCast2 f  = gcast2 f


------------------------------------------------------------------------------


tuple0Constr = mkConstr tuple0DataType "()" [] Prefix
tuple0DataType = mkDataType "Prelude.()" [tuple0Constr]

instance Data () where
  toConstr ()   = tuple0Constr
  gunfold k z c | constrIndex c == 1 = z ()  
  gunfold _ _ _ = error "gunfold"
  dataTypeOf _  = tuple0DataType


------------------------------------------------------------------------------


tuple2Constr = mkConstr tuple2DataType "(,)" [] Infix
tuple2DataType = mkDataType "Prelude.(,)" [tuple2Constr]

instance (Data a, Data b) => Data (a,b) where
  gfoldl f z (a,b) = z (,) `f` a `f` b
  toConstr (a,b) = tuple2Constr
  gunfold k z c | constrIndex c == 1 = k (k (z (,)))
  gunfold _ _ _ = error "gunfold"
  dataTypeOf _  = tuple2DataType
  dataCast2 f   = gcast2 f


------------------------------------------------------------------------------


tuple3Constr = mkConstr tuple3DataType "(,,)" [] Infix
tuple3DataType = mkDataType "Prelude.(,)" [tuple3Constr]

instance (Data a, Data b, Data c) => Data (a,b,c) where
  gfoldl f z (a,b,c) = z (,,) `f` a `f` b `f` c
  toConstr (a,b,c) = tuple3Constr
  gunfold k z c | constrIndex c == 1 = k (k (k (z (,,))))
  gunfold _ _ _ = error "gunfold"
  dataTypeOf _  = tuple3DataType


------------------------------------------------------------------------------


tuple4Constr = mkConstr tuple4DataType "(,,,)" [] Infix
tuple4DataType = mkDataType "Prelude.(,,,)" [tuple4Constr]

instance (Data a, Data b, Data c, Data d)
         => Data (a,b,c,d) where
  gfoldl f z (a,b,c,d) = z (,,,) `f` a `f` b `f` c `f` d
  toConstr (a,b,c,d) = tuple4Constr
  gunfold k z c = case constrIndex c of
                    1 -> k (k (k (k (z (,,,)))))
                    _ -> error "gunfold"
  dataTypeOf _ = tuple4DataType


------------------------------------------------------------------------------


tuple5Constr = mkConstr tuple5DataType "(,,,,)" [] Infix
tuple5DataType = mkDataType "Prelude.(,,,,)" [tuple5Constr]

instance (Data a, Data b, Data c, Data d, Data e)
         => Data (a,b,c,d,e) where
  gfoldl f z (a,b,c,d,e) = z (,,,,) `f` a `f` b `f` c `f` d `f` e
  toConstr (a,b,c,d,e) = tuple5Constr
  gunfold k z c = case constrIndex c of
                    1 -> k (k (k (k (k (z (,,,,))))))
                    _ -> error "gunfold"
  dataTypeOf _ = tuple5DataType


------------------------------------------------------------------------------


tuple6Constr = mkConstr tuple6DataType "(,,,,,)" [] Infix
tuple6DataType = mkDataType "Prelude.(,,,,,)" [tuple6Constr]

instance (Data a, Data b, Data c, Data d, Data e, Data f)
         => Data (a,b,c,d,e,f) where
  gfoldl f z (a,b,c,d,e,f') = z (,,,,,) `f` a `f` b `f` c `f` d `f` e `f` f'
  toConstr (a,b,c,d,e,f) = tuple6Constr
  gunfold k z c = case constrIndex c of
                    1 -> k (k (k (k (k (k (z (,,,,,)))))))
                    _ -> error "gunfold"
  dataTypeOf _ = tuple6DataType


------------------------------------------------------------------------------


tuple7Constr = mkConstr tuple7DataType "(,,,,,,)" [] Infix
tuple7DataType = mkDataType "Prelude.(,,,,,,)" [tuple7Constr]

instance (Data a, Data b, Data c, Data d, Data e, Data f, Data g)
         => Data (a,b,c,d,e,f,g) where
  gfoldl f z (a,b,c,d,e,f',g) =
    z (,,,,,,) `f` a `f` b `f` c `f` d `f` e `f` f' `f` g
  toConstr  (a,b,c,d,e,f,g) = tuple7Constr
  gunfold k z c = case constrIndex c of
                    1 -> k (k (k (k (k (k (k (z (,,,,,,))))))))
                    _ -> error "gunfold"
  dataTypeOf _ = tuple7DataType


------------------------------------------------------------------------------


instance Data TypeRep where
  toConstr _   = error "toConstr"
  gunfold _ _  = error "gunfold"
  dataTypeOf _ = mkNorepType "Data.Typeable.TypeRep"


------------------------------------------------------------------------------


instance Data TyCon where
  toConstr _   = error "toConstr"
  gunfold _ _  = error "gunfold"
  dataTypeOf _ = mkNorepType "Data.Typeable.TyCon"


------------------------------------------------------------------------------


    
instance Data DataType where
  toConstr _   = error "toConstr"
  gunfold _ _  = error "gunfold"
  dataTypeOf _ = mkNorepType "Data.Generics.Basics.DataType"


------------------------------------------------------------------------------


instance Typeable a => Data (IO a) where
  toConstr _   = error "toConstr"
  gunfold _ _  = error "gunfold"
  dataTypeOf _ = mkNorepType "GHC.IOBase.IO"


------------------------------------------------------------------------------

