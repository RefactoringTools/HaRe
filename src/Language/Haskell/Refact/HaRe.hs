{-# LANGUAGE ScopedTypeVariables #-}
module Language.Haskell.Refact.HaRe
 (
 -- * Data Structures
   RefactSettings(..)
 , VerboseLevel (..)
 , defaultSettings
 , SimpPos
 -- ** Re-exported from ghc-mod
 , GM.Options
 , defaultOptions

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
import qualified Language.Haskell.GhcMod as GM (Options(..),defaultOptions)


