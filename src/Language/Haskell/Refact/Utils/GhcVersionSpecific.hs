{-# LANGUAGE CPP #-}

-- |This module contains all the code that depends on a specific
-- version of GHC, and should be the only one requiring CPP
module Language.Haskell.Refact.Utils.GhcVersionSpecific
  (
    prettyprint
  , prettyprint2
  , ppType
  -- , lexStringToRichTokens
  -- , getDataConstructors
  , setGhcContext
  , showGhcQual
  )
  where

import qualified DynFlags      as GHC
import qualified GHC           as GHC
-- import qualified GHC.Paths     as GHC
-- import qualified Lexer         as GHC
import qualified Outputable    as GHC
-- import qualified StringBuffer  as GHC

-- import Language.Haskell.Refact.Utils.TypeSyn


-- ---------------------------------------------------------------------


prettyprint :: (GHC.Outputable a) => a -> String
#if __GLASGOW_HASKELL__ > 706
prettyprint x = GHC.renderWithStyle GHC.unsafeGlobalDynFlags (GHC.ppr x) (GHC.mkUserStyle GHC.neverQualify GHC.AllTheWay)
#elif __GLASGOW_HASKELL__ > 704
prettyprint x = GHC.renderWithStyle GHC.tracingDynFlags (GHC.ppr x) (GHC.mkUserStyle GHC.neverQualify GHC.AllTheWay)
#else
prettyprint x = GHC.renderWithStyle                     (GHC.ppr x) (GHC.mkUserStyle GHC.neverQualify GHC.AllTheWay)
#endif

-- ---------------------------------------------------------------------

prettyprint2 :: (GHC.Outputable a) => a -> String
#if __GLASGOW_HASKELL__ > 706
prettyprint2 x = GHC.renderWithStyle GHC.unsafeGlobalDynFlags (GHC.ppr x) (GHC.cmdlineParserStyle)
#elif __GLASGOW_HASKELL__ > 704
prettyprint2 x = GHC.renderWithStyle GHC.tracingDynFlags (GHC.ppr x) (GHC.cmdlineParserStyle)
#else
prettyprint2 x = GHC.renderWithStyle                     (GHC.ppr x) (GHC.cmdlineParserStyle)
#endif

-- ---------------------------------------------------------------------

ppType :: GHC.Type -> String
#if __GLASGOW_HASKELL__ > 706
ppType x = GHC.renderWithStyle GHC.unsafeGlobalDynFlags (GHC.pprParendType x) (GHC.mkUserStyle GHC.neverQualify GHC.AllTheWay)
#elif __GLASGOW_HASKELL__ > 704
ppType x = GHC.renderWithStyle GHC.tracingDynFlags (GHC.pprParendType x) (GHC.mkUserStyle GHC.neverQualify GHC.AllTheWay)
#else
ppType x = GHC.renderWithStyle                     (GHC.pprParendType x) (GHC.mkUserStyle GHC.neverQualify GHC.AllTheWay)
#endif

-- ---------------------------------------------------------------------

{-
getDataConstructors :: GHC.LHsDecl n -> [GHC.LConDecl n]
#if __GLASGOW_HASKELL__ > 704
getDataConstructors (GHC.L _ (GHC.TyClD (GHC.TyDecl _ _ (GHC.TyData _ _ _ _ cons _) _))) = cons
#else
getDataConstructors (GHC.L _ (GHC.TyClD (GHC.TyData _ _ _ _ _ _ cons _))) = cons
      -- TyClD - Type definitions
      -- GHC7.4.2: defines' decl@(GHC.L l (GHC.TyClD (GHC.TyData _ _ name _ _ _ cons _)))
      -- GHC7.6.3: defines' decl@(GHC.L l (GHC.TyClD (GHC.TyDecl _name _vars (GHC.TyData _ _ _ _ cons _) _fvs)))
#endif
getDataConstructors _ = []
-}

-- ---------------------------------------------------------------------

setGhcContext :: GHC.GhcMonad m => GHC.ModSummary -> m ()
#if __GLASGOW_HASKELL__ > 704
setGhcContext modSum = GHC.setContext [GHC.IIModule (GHC.moduleName $ GHC.ms_mod modSum)]
#else
setGhcContext modSum = GHC.setContext [GHC.IIModule (                 GHC.ms_mod modSum)]
#endif

-- ---------------------------------------------------------------------

showGhcQual :: (GHC.Outputable a) => a -> String
showGhcQual x = GHC.showSDocForUser GHC.unsafeGlobalDynFlags GHC.alwaysQualify $ GHC.ppr x

