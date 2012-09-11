{-----------------------------------------------------------------------------

	         A LIBRARY OF FUNCTIONAL STRATEGY COMBINATORS

		                  StrategyLib

                   Ralf Laemmel                Joost Visser
               CWI & VU, Amsterdam            CWI, Amsterdam

This module is part of a library of functional strategy combinators,
including combinators for generic traversal. The universal term
representation on which the functional strategy representation relies
is defined in this module. Most users will not be concerned with any
of the entities defined here.

This particular model for term representation is based on a
contribution by John Meacham (john@repetae.net).

-----------------------------------------------------------------------------} 

{-# OPTIONS -fglasgow-exts #-}

module TermRep(module Data.Dynamic, module TermRep)  where

-- TermRep.hs Copyright (c) 2002 John Meacham
-- john@repetae.net

-- Changes by Joost Visser:
--   * desugared pattern guards to case expressions
--   * made liberal type annotations more specific
--   * commented-out instances for datatypes unknown to Hugs
--   * added some auxilliary functions 
--   * added instance for String that views strings as basic
--     datatypes, i.e. as having no children

import Data.Dynamic
import Maybe(fromJust)
import Complex
import qualified IO
--import IOExts

--- The universal term representation type -----------------------------------

-- a TermRep contains a Dynamicized term as well as a (lazily generated) list
-- of all its subchildren, and a constructor function to rebuild modified 
-- terms.

newtype TermRep = TermRep (Dynamic, [TermRep], ([TermRep] -> Dynamic))

--- The term interface -------------------------------------------------------


class Typeable t => Term t where
   explode :: t -> TermRep
   explode x = let dx = toDyn x in TermRep (dx, [], (\[] -> dx))

implode :: Typeable t => TermRep -> t
implode (TermRep (x,_,_)) = fromJust $ fromDynamic x

getChildren (TermRep (_,ks,_))   = ks
getConstr   (TermRep (_,_ ,c))   = \ks -> TermRep (c ks,ks,c)
getTypeRep t                     = typeOf t
hasTypeOf (TermRep (dx,_,_)) (x::t)
  = ((fromDynamic dx)::Maybe t)

--- Instances for basic types and basic type constructors --------------------

instance Show TermRep where
    show (TermRep (x,y,_)) = show x -- ++ "(" ++ show y ++ ")"

_tc_Rational = mkTyCon "Rational"
instance Typeable Rational where
    typeOf _ = mkTyConApp _tc_Rational []

instance Term String
instance Term Int
instance Term Char
instance Term Integer
instance Term Bool
instance Term Float
instance Term Double
instance Term Dynamic
instance Term Rational
instance Term ()
--instance Term a => Term (IORef a)
instance (Typeable a) => Term (IO a)
instance (Typeable a, Typeable b) => Term (a -> b)
instance Term Ordering
--instance Term IO.Handle
--instance Term IO.IOMode
--instance Term IO.BufferMode
--instance Term IO.SeekMode

{-
instance (RealFloat a, Term a) => Term (Complex a) where
    explode (x::t) = TermRep (toDyn x, f x, g) where
	f (a :+ b) = [explode a, explode b]
	--g xs | [x,y] <- fArgs xs = toDyn ((fDyn x :+ fDyn y)::t)
	g xs = case fArgs xs of [x,y] -> toDyn ((fDyn x :+ fDyn y)::t)
-}
	
fDyn :: Typeable a => Dynamic -> a
--fDyn x = fromJust $ fromDynamic x
fDyn x = fromDyn x (error "fDyn")

fArgs :: [TermRep] -> [Dynamic]
fArgs xs = map (\(TermRep (x,_,_)) -> x) xs

{- considering cons as node with two kids :
instance Term a => Term [a] where
    explode (x::[a]) = TermRep (toDyn x, f x, g x) where
	f (x:xs) = [explode x, explode xs]
	f [] = []
	g (_:_) [TermRep (x,_,_),TermRep (xs,_,_)] 
                = toDyn ((fDyn x: fDyn xs)::[a])
	g [] [] = toDyn ([]::[a])
-}

-- considering each element as a kid:
instance Term a => Term [a] where
    explode (x::[a]) = TermRep (toDyn x, f x, g x) where
	f xs    = map explode xs
	g _ ts  = toDyn ((map (\(TermRep (x,_,_)) -> fDyn x) ts)::[a])

instance (Term a,Term b) => Term (a,b) where
    explode (x::(a,b)) = TermRep (toDyn x, f x, g) where
	f (x,y) = [explode x, explode y]	
--	g xs | [x,y] <- fArgs xs = toDyn ((fDyn x,fDyn y)::t)
    	g xs = case fArgs xs of [x,y] -> toDyn ((fDyn x,fDyn y)::(a,b))
    

instance (Term a,Term b, Term c) => Term (a,b,c) where
    explode (x::(a,b,c)) = TermRep (toDyn x, f x, g) where
	f (x,y,z) = [explode x, explode y, explode z]	
--	g xs | [x,y,z] <- fArgs xs = toDyn ((fDyn x,fDyn y,fDyn z)::t)
	g xs = case fArgs xs of 
                 [x,y,z] -> toDyn ((fDyn x,fDyn y,fDyn z)::(a,b,c))

instance (Term a, Term b, Term c, Term d) => Term (a, b, c, d) where
    explode (x::(a,b,c,d)) = TermRep (toDyn x, f x, g) where
	f (x,y,z,a) = [explode x, explode y, explode z, explode a]	
	g xs = case fArgs xs of 
                 [x,y,z,a] -> toDyn ((fDyn x,fDyn y,fDyn z,fDyn a)::(a,b,c,d))

instance Term a => Term (Maybe a) where
    explode (x::(Maybe a)) = TermRep (toDyn x, f x, g x) where
	f (Just x) = [explode x]
	f Nothing = []
	g (Just _) xs = case fArgs xs of 
                          [x] -> toDyn ((Just (fDyn x))::(Maybe a))
	g Nothing [] = toDyn (Nothing::(Maybe a))

instance (Term a, Term b) => Term (Either a b) where
    explode (x::(Either a b)) = TermRep (toDyn x, f x, g x) where
	f (Left x) = [explode x]
	f (Right x) = [explode x]
	g (Left _) xs = case fArgs xs of 
                          [x] -> toDyn ((Left (fDyn x)) ::(Either a b))
	g (Right _) xs = case fArgs xs of 
                          [x] -> toDyn ((Right (fDyn x))::(Either a b))

--_tc_IORef = mkTyCon "IORef"
--instance Typeable a => Typeable (IORef a) where
--    typeOf _ = mkAppTy _tc_IORef 
--                       [typeOf ((undefined:: IORef a -> a) undefined)] 

------------------------------------------------------------------------------
