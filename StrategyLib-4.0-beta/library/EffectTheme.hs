------------------------------------------------------------------------------ 
-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module is part of 'StrategyLib', a library of functional strategy
-- combinators, including combinators for generic traversal. This module
-- provides combinators to localize monadic effects.
--
------------------------------------------------------------------------------ 

module EffectTheme (
	-- * Replace one strategy monad by another
	mrunTP, mrunTU,
	-- * Add an effect to the strategy monad
	liftTP, liftTU,
	-- * Remove an effect from the strategy monad 
	unliftTP, unliftTU,
	-- * Localize specific effects
	-- ** Localize the partiality effect 
	guaranteeSuccessTP, guaranteeSuccessTU, 
	unsafeGuaranteeSuccessTP,
	-- ** Localize the state effect 
	localStateTP, localStateTU,
) where


import Monad
import MonadRun
import Control.Monad.Trans
import StrategyPrelude
import OverloadingTheme
import StrategyPrimitives


------------------------------------------------------------------------------

-- * Replace one strategy monad by another

-- The two monads are unrelated.
-- The first is run, and the resulting value is returned in the other.
-- We use the `run' function of one monad, and the `return' function
-- of the other.

-- | Replace the monad in a type-preserving strategy, given a monad
--   algebra (see 'MonadRun') for the monad that is replaced. The two 
--   monads are unrelated, so none of the effects in the monad that is
--   replaced carry over to the one that replaces it.
mrunTP 		:: (Monad m, Monad m', MonadRun s m) 
		=> (forall a . s a a) -> TP m -> TP m'
mrunTP alg	=  msubstTP (mrun alg)

-- | Replace the monad in a type-unifying strategy, given a monad
--   algebra (see 'MonadRun') for the monad that is replaced. The two 
--   monads are unrelated, so none of the effects in the monad that is
--   replaced carry over to the one that replaces it.
mrunTU 		:: (Monad m, Monad m', MonadRun s m) 
		=> s a a -> TU a m -> TU a m'
mrunTU alg	=  msubstTU (mrun alg)


------------------------------------------------------------------------------
-- * Add an effect to the strategy monad

-- | Add an effect to the monad in a type-preserving strategy. 
--   The monads are related by a monad transformer, so the effects of the
--   incoming monad are preserved in the result monad. We use the `lift'
--   function of the monad transformer.
liftTP	:: (Monad (t m), Monad m, MonadTrans t) => TP m -> TP (t m)
liftTP	= msubstTP lift

-- | Add an effect to the monad in a type-unifying strategy. 
--   The monads are related by a monad transformer, so the effects of the
--   incoming monad are preserved in the result monad. We use the `lift'
--   function of the monad transformer.
liftTU	:: (Monad (t m), Monad m, MonadTrans t) => TU a m -> TU a (t m)
liftTU	= msubstTU lift


------------------------------------------------------------------------------
-- * Remove an effect from the strategy monad 

-- | remove an effect from the monad of a type-preserving strategy.
--   The monads are related by a monad untransformer (see 'MonadUnTrans'),
--   so the effects of the incoming monad are preserved in the result
--   monad, except for the effect for which a monad algebra is supplied.
unliftTP 		:: (Monad (t m), Monad m, MonadUnTrans s t) 
			=> (forall a . s a a) -> TP (t m) -> TP m
unliftTP alg 		=  msubstTP (unlift alg)

-- | remove an effect from the monad of a type-unifying strategy.
--   The monads are related by a monad untransformer (see 'MonadUnTrans'),
--   so the effects of the incoming monad are preserved in the result
--   monad, except for the effect for which a monad algebra is supplied.
unliftTU 		:: (Monad (t m), Monad m, MonadUnTrans s t) 
			=> s a a -> TU a (t m) -> TU a m
unliftTU alg 		=  msubstTU (unlift alg)

-- Does not work:
-- unliftS alg 		=  msubstS (unlift alg)


------------------------------------------------------------------------------
-- * Localize specific effects

-- ** Localize the partiality effect 

-- Safe versions provide default to cope with Nothing.
-- Note the explicit universal quantification of this value
-- in the TP case.

-- | Localize the partiality effect in a type-preserving strategy. A
--   default value must be supplied to be used to recover from
--   failure. Since this default parameter is universally quantified,
--   only 'undefined' and 'error ...' can be used to instantiate it.
--   See also 'unsafeGuaranteeSuccessTP.
guaranteeSuccessTP :: (Monad (t m), Monad m, MonadUnTrans MaybeAlg t) 
      => (forall a . a)   -- ^ default value (Note: universally quantified!)
      -> TP (t m)         -- ^ type-preserving partial strategy
      -> TP m             -- ^ type-preserving strategy without partiality
guaranteeSuccessTP x s
  = unliftTP (MaybeAlg x id) s

-- | Localize the partiality effect in a type-unifying strategy. A
--   default value must be supplied to be used to recover from
--   failure. 
guaranteeSuccessTU :: (Monad (t m), Monad m, MonadUnTrans MaybeAlg t) 
           => a             -- ^ default value
           -> TU a (t m)    -- ^ type-preserving partial strategy
	   -> TU a m        -- ^ type-preserving strategy without partiality
guaranteeSuccessTU x s
  = unliftTU (MaybeAlg x id) s

-- Does not work:
-- guaranteeSuccessS :: (Monad (t m), Monad m, MonadUnTrans MaybeAlg t) 
--                   => a -> TU a (t m) -> TU a m
-- guaranteeSuccessS x s
--   = msubstS (unlift (MaybeAlg x id)) s

-- | Unsafe version of 'guaranteeSuccessTP'. This version uses uses `undefined'
--   to recover from failure. For the type-preserving case, this is the only
--   possible default value.
unsafeGuaranteeSuccessTP :: (Monad (t m), Monad m, MonadUnTrans MaybeAlg t) 
                         => TP (t m) -> TP m
unsafeGuaranteeSuccessTP s
  = guaranteeSuccessTP undefined s
  
-- | Unsafe version of 'guaranteeSuccessTU'. This version uses uses `undefined'
--   to recover from failure. Use 'guaranteeSuccessTU' instead.
unsafeGuaranteeSuccessTU :: (Monad (t m), Monad m, MonadUnTrans MaybeAlg t) 
                         => TU a (t m) -> TU a m
unsafeGuaranteeSuccessTU s
  = guaranteeSuccessTU undefined s

-- Does not work:
-- unsafeGuaranteeSuccessS s
--   = guaranteeSuccessS undefined s

------------------------------------------------------------------------------
-- ** Localize the state effect 

-- | Localize the state of a type-preserving strategy. The first argument
--   represents the initial state.  
localStateTP :: (Monad (t m), Monad m, MonadUnTrans (StateAlg s) t) 
             => s -> TP (t m) -> TP m 
localStateTP s
  = unliftTP (StateAlg s fst)

-- | Localize the state of a type-unifying strategy. The first argument
--   represents the initial state.  
localStateTU :: (Monad (t m), Monad m, MonadUnTrans (StateAlg s) t) 
             => s -> TU a (t m) -> TU a m 
localStateTU s
  = unliftTU (StateAlg s fst)

     
------------------------------------------------------------------------------
