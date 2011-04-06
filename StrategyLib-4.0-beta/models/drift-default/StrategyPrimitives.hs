{-----------------------------------------------------------------------------

 	          A LIBRARY OF FUNCTIONAL STRATEGY COMBINATORS

		                  StrategyLib

                   Ralf Laemmel                Joost Visser
               CWI & VU, Amsterdam         CWI & SIG, Amsterdam

This module is part of a library of functional strategy combinators,
including combinators for generic traversal. The generic function
representation that relies on a universal term representation is
defined in this module. The safety of the generic function combinators
is guaranteed by not exporting the data constructor MkTP.

-----------------------------------------------------------------------------} 

module StrategyPrimitives (

  Term,
  TP,         TU,       -- Note: MkTP is not exported, MkTU could be exported
  paraTP,     paraTU,
  applyTP,    applyTU,
  adhocTP,    adhocTU,
  msubstTP,   msubstTU,
  seqTP,      seqTU,
  passTP,     passTU,
  choiceTP,   choiceTU,
  mchoicesTP, mchoicesTU,
  allTP,      allTU, allTU',
  oneTP,      oneTU,
  anyTP,      anyTU, anyTU',
  someTP,     someTU, someTU',
  injTP

) where

import TermRep
import Monad
import Data.Monoid
import MonadicFunctions
import MonadRun


--- Strategy representation --------------------------------------------------

newtype TP m  	 = MkTP (TermRep -> m TermRep)
newtype TU a m	 = MkTU (TermRep -> m a)

unTP 		:: TP m -> TermRep -> m TermRep
unTP (MkTP f)	 = f

unTU 		:: TU a m -> TermRep -> m a
unTU (MkTU f)	 = f


--- Parametricially polymorphic strategies -----------------------------------

paraTP 		:: Monad m => (forall t. t -> m t) -> TP m
paraTP f	=  MkTP f

paraTU 		:: Monad m => (forall t. t -> m a) -> TU a m
paraTU f	=  MkTU f


--- Strategy application -----------------------------------------------------

applyTP 	:: (Monad m, Term t) => TP m -> t -> m t
applyTP s t	=  do { t' <- unTP s (explode t); return (implode t') }

applyTU 	:: (Monad m, Term t) => TU a m -> t -> m a
applyTU s t	=  unTU s (explode t)

applyOnKids 	:: Monad m => ([TermRep] -> m [TermRep]) -> TP m
applyOnKids s	=  MkTP (\ t -> s (getChildren t) >>= \ks' ->
                                return (getConstr t ks'))

applyOnKidsTU 	:: ([TermRep] -> m a) -> TU a m
applyOnKidsTU s	=  MkTU (\ t -> s (getChildren t))



--- Strategy update ----------------------------------------------------------

adhocTP 	:: (Monad m, Term t) => TP m -> (t -> m t) -> TP m
adhocTP s f	=  MkTP (\u -> if applicable f u 
                               then do t <- f (implode u)
                                       return (explode t)
                               else (unTP s u) )

adhocTU	 	:: (Monad m, Term t) => TU a m -> (t -> m a) -> TU a m
adhocTU s f	=  MkTU (\u -> if applicable f u
                               then (f (implode u))
                               else (unTU s u) )


applicable 	:: Typeable a => (a -> b) -> TermRep -> Bool
applicable f u  =  case u `hasTypeOf` (undefined `withArgType` f) of
                     Just _  -> True
		     Nothing -> False
                   where withArgType :: a -> (a -> x) -> a
                         withArgType a f = a

-- Applicability of a monomorphic function to a universal term representation
-- is defined by comparing the type representation of the argument type of the
-- function with the type representation of the term representation at hand.


--- Effect manipulation ------------------------------------------------------

                                               -- Replace one monad by another
					       
msubstTP	:: (Monad m, Monad m') 
		=> (forall t . m t -> m' t) -> TP m -> TP m'
msubstTP e f	=  MkTP (\x -> e ((unTP f) x))

msubstTU	:: (Monad m, Monad m') 
		=> (m a -> m' a) -> TU a m -> TU a m'
msubstTU e f	=  MkTU (\x -> e ((unTU f) x))



--- Deterministic combinators ------------------------------------------------

    -- Type-preserving

seqTP 		:: Monad m => TP m -> TP m -> TP m
seqTP f g 	=  MkTP ((unTP f) `mseq` (unTP g))

passTP 		:: Monad m => TU a m -> (a -> TP m) -> TP m
passTP f g 	=  MkTP ((unTU f) `mlet` (\y -> unTP (g y)))

    -- Type-unifying

seqTU 		:: Monad m => TP m -> TU a m -> TU a m
seqTU f g	=  MkTU ((unTP f) `mseq` (unTU g))

passTU 		:: Monad m => TU a m -> (a -> TU b m) -> TU b m
passTU f g	=  MkTU ((unTU f) `mlet` (\y -> unTU (g y))) 


--- Combinators for partiality and non-determinism ---------------------------

    -- Type-preserving

choiceTP 	:: MonadPlus m => TP m -> TP m -> TP m
choiceTP f g	=  MkTP ((unTP f) `mchoice` (unTP g))

    -- Type-unifying

choiceTU 	:: MonadPlus m => TU a m -> TU a m -> TU a m
choiceTU f g	=  MkTU ((unTU f) `mchoice` (unTU g))

-- With localization of partiality:

mchoicesTP fs f		=  MkTP (\a -> mchoices (map unTP fs) (unTP f) a)

mchoicesTU fs f		=  MkTU (\a -> mchoices (map unTU fs) (unTU f) a)


--- Traversal combinators ----------------------------------------------------

    -- Type-preserving

-- Succeed for all children
allTP 		:: Monad m => TP m -> TP m
allTP s		=  applyOnKids (mapM (unTP s))

-- Succeed for one child; don't care about the other children
oneTP 		:: MonadPlus m => TP m -> TP m
oneTP s		=  applyOnKids (oneM (unTP s))

-- Succeed for as many children as possible
anyTP 		:: MonadPlus m => TP m -> TP m
anyTP s		=  applyOnKids (anyM (unTP s))

-- Succeed for as many children as possible but at least for one
someTP	 	:: MonadPlus m => TP m -> TP m
someTP s	=  applyOnKids (someM (unTP s))

-- Simulate injection
injTP           :: MonadPlus m => TP m -> TP m     
injTP s         =  MkTP (\t -> 
                          case (getChildren t) of 
                           [k] -> unTP s k >>= \k' ->
                                  return (getConstr t [k'])
                           _ -> mzero)                                  

    -- Helpers

oneM f []	= mzero
oneM f (x:xs)	= do { x' <- (f x); return (x':xs) }
                  `mplus`
		  do { xs' <- oneM f xs; return (x:xs') }

uniM f []	= mzero
uniM f (x:xs)	= do { x' <- (f x); () <- noneV f xs; return (x':xs) }
		  `mplus`
		  do { () <- noneV f [x]; xs' <- uniM f xs; return (x:xs') }

noneV f []	= return ()
noneV f (x:xs)  = ((f x >>= \_ -> return True) `mplus` (return False))
                  >>= \b -> if b then mzero
                                 else noneV f xs

anyM f []	= return []
anyM f (x:xs)	= do x'  <- ((f x) `mplus` (return x))
                     xs' <-  anyM f xs
                     return (x':xs')

someM f []	= mzero
someM f (x:xs)	= do { x'  <- f x; xs' <- anyM f xs; return (x':xs') }
                  `mplus`
                  do { xs' <- someM f xs; return (x:xs') }

    -- Type-unifying

allTU 		:: Monad m => (a -> a -> a) -> a -> TU a m -> TU a m
allTU op2 u s   =  applyOnKidsTU (foldM cons u)
		     where cons i c = do c' <- (unTU s c)
		                         return (i `op2` c')

allTU' 		:: (Monad m, Monoid a) => TU a m -> TU a m
allTU'		=  allTU mappend mempty

oneTU 		:: MonadPlus m => TU a m -> TU a m
oneTU s		=  applyOnKidsTU (foldr cons mzero)
		   where cons c i = (unTU s c) `mplus` i

anyTU		:: MonadPlus m => (a -> a -> a) -> a -> TU a m -> TU a m
anyTU op2 u s	=  applyOnKidsTU (foldM (anyTUcons op2 (unTU s)) u)

anyTU'		:: (MonadPlus m, Monoid a) => TU a m -> TU a m
anyTU' 		=  anyTU mappend mempty

someTU	 	:: MonadPlus m => (a -> a -> a) -> a -> TU a m -> TU a m
someTU op2 u s	=  applyOnKidsTU (someTUfold op2 u (unTU s))

someTU'	 	:: (Monoid a, MonadPlus m) => TU a m -> TU a m
someTU'		=  someTU mappend mempty


    -- Helpers

anyTUcons op2 f i c
  = do { c' <- f c; return (i `op2` c') }
       `mplus`
       return i

someTUfold op2 u f [] = mzero
someTUfold op2 u f (x:xs)
	= do c <- f x
             i <- (foldM (anyTUcons op2 f) u) xs
             return (i `op2` c)
             `mplus`
             someTUfold op2 u f xs


--- Illustration of type safety ----------------------------------------------

-- The safety of this model of strategies relies on hiding of MkTP. The
-- following term demonstrates unsafe use of the MkTP constructor. We catch a
-- universal representation which arose from a string and we throw it in for
-- the result of a type-preserving function. Clearly, if we attempt to apply
-- the inner type-preserving strategy to a Boolean constant, then we end up
-- with an implosion error.

brokenTerm	 = applyTU 
                     (MkTU (\u -> applyTP (MkTP (const (Just u))) True)) 
                     "BREAK"

-- If the paraTP constructor function is used instead, the resulting term
-- is not typable:
--
-- untypableTerm = applyTU 
--                  (MkTU (\u -> applyTP (paraTP (const (return u))) True)) 
--                  "BREAK"
--
-- Thus, by not exporting MkTP, safety is guaranteed.

------------------------------------------------------------------------------
