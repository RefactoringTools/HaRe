------------------------------------------------------------------------------
-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module is part of 'StrategyLib', a library of functional strategy
-- combinators, including combinators for generic traversal. This module 
-- indicates how some strategy combinators could be denoted via infix
-- combinators.

-----------------------------------------------------------------------------}

module StrategyInfix where

import StrategyPrelude
import OverloadingTheme

infixl 1  >>>, >>>=, >>>-
infixl 2  -+

-- | Sequential composition
(>>>) 		:: Strategy s m => TP m -> s m -> s m
s >>> s'	= s `seqS` s'

-- | Sequential composition with value passing
(>>>=) 		:: Strategy s m => TU a m -> (a -> s m) -> s m
s >>>= s'	= s `passS` s'

-- | Sequential composition, ignoring value from first strategy
(>>>-) 		:: Strategy s m => TU a m -> s m -> s m
s >>>- s'	= s `passS` \_ -> s'

-- | Dynamic type-case
(-+) 		:: StrategyApply s m t x => s m -> (t -> m x) -> s m
s -+ f          = s `adhocS` f

{-
tst :: TP Maybe
tst = idTP >>> failS -+ f -+ f

f (x::Char) = return x

mytest :: Maybe Char
mytest = applyTP tst 'a'

mytest2 :: Maybe Bool 
mytest2 = applyTP tst True
-}
