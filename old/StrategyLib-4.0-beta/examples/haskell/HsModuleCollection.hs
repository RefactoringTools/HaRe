module HsModuleCollection where

import Language.Haskell.Syntax (HsModule)

type ModuleName = String
type Module = (ModuleName,[ModuleName],HsModule)
type ModuleCollection = [Module]
