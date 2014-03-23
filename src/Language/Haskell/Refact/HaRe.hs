module Language.Haskell.Refact.HaRe
 (
   ifToCase
 , duplicateDef
 , liftToTopLevel
 , liftOneLevel
 , demote
 , rename
 , swapArgs
 )
where

import Language.Haskell.Refact.Refactoring.Case
import Language.Haskell.Refact.Refactoring.DupDef
import Language.Haskell.Refact.Refactoring.MoveDef
import Language.Haskell.Refact.Refactoring.Renaming
import Language.Haskell.Refact.Refactoring.SwapArgs

