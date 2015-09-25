{-# LANGUAGE ScopedTypeVariables #-}
module Language.Haskell.Refact.HaRe
 (
 -- * Data Structures
   RefactSettings(..)
 , VerboseLevel (..)
 , defaultSettings
 , SimpPos

 -- * Refactorings
 , ifToCase
 , duplicateDef
 , liftToTopLevel
 , liftOneLevel
 , demote
 , rename
 -- , swapArgs
 , roundTrip
 )
where

import Language.Haskell.Refact.Refactoring.Case
import Language.Haskell.Refact.Refactoring.DupDef
import Language.Haskell.Refact.Refactoring.MoveDef
import Language.Haskell.Refact.Refactoring.Renaming
-- import Language.Haskell.Refact.Refactoring.SwapArgs
import Language.Haskell.Refact.Refactoring.RoundTrip
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.Types


