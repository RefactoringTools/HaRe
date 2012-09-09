module NewTypeIntro where

-------------------------------------------------------------------------------

--- This module implements a "data" to "newtype" conversion

-------------------------------------------------------------------------------

import Language.Haskell.Syntax
import SyntaxTermInstances
import StrategyLib

-- The main transformation function

newtypeIntro :: HsModule -> Maybe HsModule
newtypeIntro =  applyTP (full_tdTP (adhocTP idTP newtypeIntro1))

{-
   This rewrite rule looks for all data declarations which
   should be better newtype declarations. To do so, we need
   to find data declarations with one constructor application.
   In addition, the constructor application is required to
   have exactly one parameter (cf. Haskell 98 report).
-}

newtypeIntro1 :: HsDecl -> Maybe HsDecl
newtypeIntro1 (HsDataDecl s c n ps [cd@(HsConDecl _ _ [_])] ns) 
  = Just (HsNewTypeDecl s c n ps cd ns)
newtypeIntro1 x
  = Just x

-------------------------------------------------------------------------------
