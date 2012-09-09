------------------------------------------------------------------------------
-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module is part of 'StrategyLib', a library of functional strategy
-- combinators, including combinators for generic traversal. This module
-- provides combinators which allow one to use strategies to construct
-- generic containers.

------------------------------------------------------------------------------

module ContainerTheme (
	module ContainerTheme,
) where

import StrategyPrelude 
import Control.Monad
import Data.Monoid

------------------------------------------------------------------------------
-- * Pointwise function update

-- | Pointwise modification of monomorphic functions
modify :: Eq x => (x -> y) -> x -> y -> (x -> y)
modify f x y = \x' -> if x == x' then y else f x'

-- | Pointwise modification of type-preserving strategies
modifyTP :: (MonadPlus m, Eq t, Term t) => TP m -> t -> m t -> TP m
modifyTP f t = adhocTP f . modify (applyTP f) t

-- | Pointwise modification of type-unifying strategies
modifyTU :: (MonadPlus m, Eq t, Term t) => TU a m -> t -> m a -> TU a m
modifyTU f t = adhocTU f . modify (applyTU f) t

------------------------------------------------------------------------------
-- * Generic Set (not observable)

-- | Type of generic sets
type GSet = TU () Maybe

-- | Empty generic set.
emptyGSet	:: GSet
emptyGSet	=  failTU

-- | Completely filled generic set
fullGSet	:: GSet
fullGSet	=  constTU mempty

-- | Add an element to a generic set
addGSet 	:: (Eq t, Term t) => t -> GSet -> GSet
addGSet t s 	=  modifyTU s t (return mempty)

-- | Remove an element from a generic set
removeGSet	:: (Eq t, Term t) => t -> GSet -> GSet
removeGSet t s  =  modifyTU s t mzero

-- | Test whether a given element is contained in a generic set
containsGSet 	:: (Eq t, Term t) => t -> GSet -> Bool
containsGSet t s=  maybe False (const True) (applyTU s t)

------------------------------------------------------------------------------
-- * Generic Map (not observable)

-- | Type of generic maps
type GMap value = TU value Maybe

-- | Empty generic map
emptyGMap	:: GMap v
emptyGMap	=  failTU

-- | Remove an element from a generic map (my key)
removeGMap	:: (Eq t, Term t) => t -> GMap v -> GMap v
removeGMap t s  =  modifyTU s t mzero

-- | Test whether an element with given key is contained in a generic map
containsGMap 	:: (Eq t, Term t) => t -> GMap v -> Bool
containsGMap t s=  maybe False (const True) (applyTU s t)

-- | Add an entry with given key and value to a generic map
putGMap 	:: (Eq t, Term t) => t -> v -> GMap v -> GMap v
putGMap t v s	=  modifyTU s t (return v)

-- | Obtain the value for a given key from a generic map
getGMap 	:: (Eq t, Term t) => t -> GMap v -> Maybe v
getGMap t s	=  applyTU s t


------------------------------------------------------------------------------
--- Generic List (observable per type) ---------------------------------------

type GList = (Integer -> TP Maybe,Integer)

sizeGList (_,i)	= i
indxGList (f,_) = f

emptyGList	:: GList
emptyGList	=  (const failTP,0)

addGList	:: Term t => t -> GList -> GList 
addGList t l	=  (modify f s e,s+1)
                   where s  = sizeGList l
		         f  = indxGList l
                         e = monoTP (const (return t))	
			 	 
putGList	:: Term t => Integer -> t -> GList -> GList 
putGList i t l	=  if i < s then (modify f i e,s)
                            else l
                   where s  = sizeGList l
		         f  = indxGList l
                         e = monoTP (const (return t))	
			 	 
getGList	:: Term t => Integer -> GList -> Maybe t 
getGList i l	=  if i < s then applyTP (f i) undefined
                            else Nothing
                   where f  = indxGList l
		         s  = sizeGList l
	
mapGListTP 	:: TP Maybe -> GList -> GList
mapGListTP s l	=  (nth (map forElem [0..size-1]),size)
                   where forElem   :: Integer -> TP Maybe
		         forElem i =  (indxGList l i) `seqTP` s
			 size = sizeGList l
			 
mapGListTU 	:: Term t => (t -> ()) -> TU a Maybe -> GList -> [Maybe a]
mapGListTU g s l=  map forElem [0..size-1]
                   where forElem i 
		           = applyTU ((indxGList l i) `seqTU` s) t
			 size = sizeGList l
			 (t,()) = (undefined,g t)	
			  
elemsGList 	:: Term t => (t -> ()) -> GList -> [t]
elemsGList g l	=  filterJust (map forElem [0..size-1])
                   where forElem i 
		           = applyTP (indxGList l i) t
			 size = sizeGList l
			 (t,()) = (error "NOTERM",g t)	 
			 filterJust as	= map unJust (filter isJust as)
                         unJust (Just t) = t
                         isJust (Just _) = True
                         isJust Nothing  = False

-- Variation on !! but now for Integer iso Int
nth             :: [a] -> Integer -> a
nth (x:_)  0       = x
nth (_:xs) n | n>0 = nth xs (n-1)
nth (_:_)  _       = error "ContainterTheme.nth: negative index"
nth []     _       = error "ContainerTheme.nth: index too large"

------------------------------------------------------------------------------
--- Assign unique codes to terms of any type ---------------------------------

type Coder 		=  (Int,TU Int Maybe)

noCode 			:: Coder
noCode 			=  (0,failTU)

getCode 		:: Term x => Coder -> x -> Maybe Int
getCode (_,s) 		=  applyTU s

setCode 		:: (Term x, Eq x) => Coder -> x -> Int -> Coder
setCode (i,s) x i' 	=  (i,modifyTU s x (return i'))

nextCode 		:: Coder -> (Int,Coder)
nextCode (i,s) 		=  (i,(i+1,s))

enCode 			:: (Term x, Eq x) => Coder -> x -> Coder
enCode c x 		=  maybe gen found (getCode c x)
  			   where
                             gen = let (i,c') = nextCode c 
                                   in setCode c' x i
                             found = const c

------------------------------------------------------------------------------
