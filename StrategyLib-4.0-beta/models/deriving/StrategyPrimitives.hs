{-----------------------------------------------------------------------------

A model of functional strategies using Data.Generics as of >= GHC 6.2.
(The version of Data.Generics as of GHC 6.0 is not applicable here.)
Strategy application, strategy update, and traversal are different from
the original Strafunski model. Most other combinators (seqT?, ...) are
retained as is.

-----------------------------------------------------------------------------} 

module StrategyPrimitives (

  Term,
  TP,         TU,
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
import Data.Generics
import Control.Monad
import Data.Monoid
import MonadicFunctions
import MonadRun


--- Strategy representation --------------------------------------------------

newtype Monad m =>
        TP m =
               MkTP (forall x. Data x => x -> m x)

newtype Monad m =>
        TU a m =
                 MkTU (forall x. Data x => x -> m a)

unTP (MkTP f)	 = f
unTU (MkTU f)	 = f



--- Parametricially polymorphic strategies -----------------------------------

paraTP 		:: Monad m => (forall t. t -> m t) -> TP m
paraTP f	=  MkTP f

paraTU 		:: Monad m => (forall t. t -> m a) -> TU a m
paraTU f	=  MkTU f


--- Strategy application -----------------------------------------------------

applyTP         :: (Monad m, Data x) => TP m -> x -> m x
applyTP         =  unTP

applyTU 	:: (Monad m, Data x) => TU a m -> x -> m a
applyTU         =  unTU



--- Strategy update ----------------------------------------------------------

adhocTP :: (Monad m, Data t) => TP m -> (t -> m t) -> TP m
adhocTP s f = MkTP (unTP s `extM` f)

adhocTU :: (Monad m, Data t) => TU a m -> (t -> m a) -> TU a m
adhocTU s f = MkTU (unTU s `extQ` f)



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
allTP 	   :: Monad m => TP m -> TP m
allTP s    =  MkTP (gmapM (applyTP s))


-- Succeed for one child; don't care about the other children
oneTP 	   :: MonadPlus m => TP m -> TP m
oneTP s	   =  MkTP (gmapMo (applyTP s))


-- Succeed for as many children as possible
anyTP      :: MonadPlus m => TP m -> TP m
anyTP s    =  allTP (s `choiceTP` paraTP return)


-- Succeed for as many children as possible but at least for one
someTP	   :: MonadPlus m => TP m -> TP m
someTP s   =  MkTP (gmapMp (applyTP s))


-- Simulate injection
injTP      :: MonadPlus m => TP m -> TP m     
injTP s    =  (MkTU (return . glength))
              `passTP`
              (\x -> if x == 1 then allTP s else paraTP (const mzero))


    -- Type-unifying

allTU 		:: Monad m => (a -> a -> a) -> a -> TU a m -> TU a m
allTU op2 u s   =  MkTU (\x -> fold (gmapQ (applyTU s) x))
  where
    fold l = foldM op2' u l
    op2' x c = c >>= \y -> return (x `op2` y)


allTU' 		:: (Monad m, Monoid a) => TU a m -> TU a m
allTU'		=  allTU mappend mempty


oneTU 		:: MonadPlus m => TU a m -> TU a m
oneTU s		=  MkTU (\x -> fold (gmapQ (applyTU s) x))
  where
    fold [] = mzero
    fold (h:t) = (h >>= \x -> return x)
                 `mplus`
                 fold t


anyTU		:: MonadPlus m => (a -> a -> a) -> a -> TU a m -> TU a m
anyTU op2 u s   =  allTU op2 u (s `choiceTU` paraTU (const (return u)))


anyTU'		:: (MonadPlus m, Monoid a) => TU a m -> TU a m
anyTU' 		=  anyTU mappend mempty


someTU	 	:: MonadPlus m => (a -> a -> a) -> a -> TU a m -> TU a m
someTU op2 u s	=  MkTU (\x -> fold False (gmapQ (applyTU s) x))
  where
    fold False [] = mzero
    fold True  [] = return u
    fold b (h:t)  = (h >>= \x -> fold True t >>= \y -> return (x `op2` y))
                    `mplus`
                    fold b t

someTU'	 	:: (Monoid a, MonadPlus m) => TU a m -> TU a m
someTU'		=  someTU mappend mempty
