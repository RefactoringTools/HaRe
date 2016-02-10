{-# LANGUAGE CPP #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE UndecidableInstances #-} -- for GHC.DataId

--------------------------------------------------------------------------------
-- Module      : TypeUtils

-- Maintainer  : refactor-fp\@kent.ac.uk
-- |
--
-- This module contains a collection of program analysis and
-- transformation functions (the API) that work over the Type
-- Decorated AST. Most of the functions defined in the module are
-- taken directly from the API, but in some cases are modified to work
-- with the type decorated AST.
--
-- In particular some new functions have been added to make type
-- decorated AST traversals easier.
--
-- In HaRe, in order to preserve the comments and layout of refactored
-- programs, a refactoring modifies not only the AST but also the
-- token stream, and the program source after the refactoring is
-- extracted from the token stream rather than the AST, for the
-- comments and layout information is kept in the token steam instead
-- of the AST. As a consequence, a program transformation function
-- from this API modifies both the AST and the token stream (unless
-- explicitly stated). So when you build your own program
-- transformations, try to use the API to do the transformation, as
-- this can liberate you from caring about the token stream.
--
-- This type decorated API is still in development. Any suggestions
-- and comments are very much welcome.


--------------------------------------------------------------------------------
module Language.Haskell.Refact.Utils.Binds
   (
     hsBinds
   , getValBindSigs
   , HsValBinds(..)
 ) where

import Language.Haskell.GHC.ExactPrint.Utils

-- Modules from GHC
import qualified Bag           as GHC
import qualified GHC           as GHC
import qualified Outputable    as GHC

import Data.Generics

-- ---------------------------------------------------------------------

bindsFromDecls :: [GHC.LHsDecl name] -> GHC.HsValBinds name
bindsFromDecls ds = GHC.ValBindsIn (GHC.listToBag binds) sigs
  where
    binds = concatMap goBind ds
    goBind (GHC.L l (GHC.ValD d)) = [(GHC.L l d)]
    goBind _ = []

    sigs = concatMap goSig ds
    goSig (GHC.L l (GHC.SigD d)) = [(GHC.L l d)]
    goSig _ = []

-- ---------------------------------------------------------------------

getValBindSigs :: GHC.HsValBinds GHC.RdrName -> [GHC.LSig GHC.RdrName]
getValBindSigs binds = case binds of
    GHC.ValBindsIn  _  sigs -> sigs
    GHC.ValBindsOut _ _sigs -> []

emptyValBinds :: GHC.HsValBinds name
emptyValBinds = GHC.ValBindsIn (GHC.listToBag []) []

unionBinds :: [GHC.HsValBinds name] ->  GHC.HsValBinds name
unionBinds [] = emptyValBinds
unionBinds [x] = x
unionBinds (x1:x2:xs) = unionBinds ((mergeBinds x1 x2):xs)
  where
    mergeBinds :: GHC.HsValBinds name -> GHC.HsValBinds name -> GHC.HsValBinds name
    mergeBinds (GHC.ValBindsIn b1 s1) (GHC.ValBindsIn b2 s2) = (GHC.ValBindsIn (GHC.unionBags b1 b2) (s1++s2))
    mergeBinds (GHC.ValBindsOut b1 s1) (GHC.ValBindsOut b2 s2) = (GHC.ValBindsOut (b1++b2) (s1++s2))
    mergeBinds y1@(GHC.ValBindsIn _ _) y2@(GHC.ValBindsOut _  _) = mergeBinds y2 y1
    mergeBinds    (GHC.ValBindsOut _ _) (GHC.ValBindsIn _ _) = error $ "unionBinds:cannot merge ValBindsOut and ValBindsIn"

-- NOTE: ValBindsIn are found before the Renamer, ValBindsOut after

hsBinds :: (HsValBinds t name) => t -> [GHC.LHsBind name]
hsBinds t = case hsValBinds t of
  GHC.ValBindsIn binds _sigs -> GHC.bagToList binds
  GHC.ValBindsOut bs _sigs -> concatMap (\(_,b) -> GHC.bagToList b) bs

-- This class replaces the HsDecls one
class (Data t,Data name) => HsValBinds t name |  t -> name where

    -- | Return the binds that are directly enclosed in the
    -- given syntax phrase.
    -- hsValBinds :: t -> [GHC.LHsBind GHC.Name]
    hsValBinds :: t -> GHC.HsValBinds name

    -- | Return the type class definitions that are directly enclosed
    -- in the given syntax phrase. Note: only makes sense for
    -- GHC.RenamedSource
    hsTyDecls :: t -> [[GHC.LTyClDecl name]]


instance HsValBinds GHC.ParsedSource GHC.RdrName where
  hsValBinds (GHC.L _ (GHC.HsModule _ _ _ ds _ _)) = bindsFromDecls ds

  -- hsTyDecls (grp,_,_,_) = map GHC.group_tyclds (GHC.hs_tyclds grp)
  hsTyDecls (GHC.L _ (GHC.HsModule _ _ _ _ds _ _)) = []

instance HsValBinds GHC.RenamedSource GHC.Name where
  hsValBinds (grp,_,_,_) = (GHC.hs_valds grp)

  hsTyDecls (grp,_,_,_) = map GHC.group_tyclds (GHC.hs_tyclds grp)

instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.HsValBinds name) name where
  hsValBinds vb = vb
  hsTyDecls _ = []

instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.HsGroup name) name where
  hsValBinds grp = (GHC.hs_valds grp)

  hsTyDecls _ = []


#if __GLASGOW_HASKELL__ > 710
instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.Located (GHC.HsLocalBinds name)) name where
  hsValBinds (GHC.L _ b) = hsValBinds b
  hsTyDecls (GHC.L _ b)  = hsTyDecls b
#endif

instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.HsLocalBinds name) name where
  hsValBinds lb = case lb of
    GHC.HsValBinds b    -> b
    GHC.HsIPBinds _     -> emptyValBinds
    GHC.EmptyLocalBinds -> emptyValBinds

  hsTyDecls _ = []

instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.GRHSs name (GHC.LHsExpr name)) name where
  hsValBinds (GHC.GRHSs _ lb) = hsValBinds lb

  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.MatchGroup name (GHC.LHsExpr name)) name where
  hsValBinds (GHC.MG matches _ _ _) = hsValBinds matches

  hsTyDecls _ = []

-- ---------------------------------------------------------------------

#if __GLASGOW_HASKELL__ > 710
instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.Located [GHC.LMatch name (GHC.LHsExpr name)]) name where
    hsValBinds (GHC.L _ ms) = hsValBinds ms
    hsTyDecls  (GHC.L _ ms) = hsTyDecls  ms
#endif

instance (GHC.DataId name,Data name)
  => HsValBinds [GHC.LMatch name (GHC.LHsExpr name)] name where
  hsValBinds ms = unionBinds $ map (\m -> hsValBinds $ GHC.unLoc m) ms

  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.LMatch name (GHC.LHsExpr name)) name where
  hsValBinds m = hsValBinds $ GHC.unLoc m

  hsTyDecls _ = []

-- ---------------------------------------------------------------------


instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.Match name (GHC.LHsExpr name)) name where
  hsValBinds (GHC.Match _ _ _ grhs) = hsValBinds grhs

  hsTyDecls _ = []

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.HsBind name) name where
  hsValBinds (GHC.PatBind _p rhs _typ _fvs _) = hsValBinds rhs

  -- TODO: ++AZ++ added for compatibility with hsDecls.
#if __GLASGOW_HASKELL__ <= 710
  hsValBinds (GHC.FunBind _ _ matches _ _ _) = hsValBinds matches
#else
  hsValBinds (GHC.FunBind _ matches _ _ _) = hsValBinds matches
#endif
  hsValBinds other = error $ "hsValBinds (GHC.HsBind name) undefined for:" ++ (showGhc other)

  hsTyDecls _ = []

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.HsExpr name) name where
  hsValBinds (GHC.HsLet ds _) = hsValBinds ds
  hsValBinds x = error $ "TypeUtils.hsValBinds undefined for:" ++ showGhc x

  hsTyDecls _ = []

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.Stmt name (GHC.LHsExpr name)) name where
  hsValBinds (GHC.LetStmt ds) = hsValBinds ds
  hsValBinds other = error $ "hsValBinds (GHC.Stmt name) undefined for:" ++ (showGhc other)

  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LHsBinds name) name where
  hsValBinds binds = hsValBinds $ GHC.bagToList binds
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LHsBind name) name where
#if __GLASGOW_HASKELL__ <= 710
  hsValBinds (GHC.L _ (GHC.FunBind _ _ matches _ _ _)) = hsValBinds matches
#else
  hsValBinds (GHC.L _ (GHC.FunBind _ matches _ _ _)) = hsValBinds matches
#endif
  hsValBinds (GHC.L _ (GHC.PatBind _ rhs _ _ _))       = hsValBinds rhs
  hsValBinds (GHC.L _ (GHC.VarBind _ rhs _))           = hsValBinds rhs
  hsValBinds (GHC.L _ (GHC.AbsBinds _ _ _ _ binds))    = hsValBinds binds
  hsValBinds (GHC.L _ (GHC.PatSynBind _))      = error "hsValBinds: PaySynBind to implement"

  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.DataId name,Data name)
  => HsValBinds ([GHC.LHsBind name]) name where
  -- hsValBinds xs = concatMap hsValBinds xs -- As in original
  hsValBinds xs = GHC.ValBindsIn (GHC.listToBag xs) []

  hsTyDecls _ = []

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LHsExpr name) name where
  hsValBinds (GHC.L _ (GHC.HsLet binds _ex)) = hsValBinds binds
  hsValBinds _                               = emptyValBinds

  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LGRHS name (GHC.LHsExpr name)] name where
  hsValBinds xs = unionBinds $ map hsValBinds xs
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LGRHS name (GHC.LHsExpr name)) name where
  hsValBinds (GHC.L _ (GHC.GRHS stmts _expr)) = hsValBinds stmts
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LStmt name (GHC.LHsExpr name)] name where
  hsValBinds xs = unionBinds $ map hsValBinds xs
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LStmt name (GHC.LHsExpr name)) name where
  hsValBinds (GHC.L _ (GHC.LetStmt binds)) = hsValBinds binds
  hsValBinds _                             = emptyValBinds
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LPat name] name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LPat name) name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

-- ---------------------------------------------------------------------


instance HsValBinds (GHC.Name) GHC.Name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []


-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.SyntaxExpr name] name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.TyClGroup name) name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.TyClGroup name] name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [[GHC.LTyClDecl name]] name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LTyClDecl name] name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LTyClDecl name) name where
  hsValBinds _ = error $ "hsValBinds (GHC.LTyClDecl name) must pull out tcdMeths"
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LTyFamInstDecl name] name where
  hsValBinds _ = error $ "hsValBinds [GHC.LTyFamInstDecl name] must pull out tcdMeths"
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LDataFamInstDecl name] name where
  hsValBinds _ = error $ "hsValBinds [GHC.LDataFamInstDecl name] must pull out tcdMeths"
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.DataId name,Data name)
  => HsValBinds [GHC.LTyFamInstEqn name] name where
  hsValBinds _ = error $ "hsValBinds [GHC.LTyFamInstEqn name] must pull out tcdMeths"
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.LTyFamInstEqn name) name where
  hsValBinds _ = error $ "hsValBinds (GHC.LTyFamInstEqn name) must pull out tcdMeths"
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.HsDataDefn name) name where
  hsValBinds _ = error $ "hsValBinds (GHC.HsDataDefn name) must pull out tcdMeths"
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.HsTyPats name) name where
  hsValBinds _ = error $ "hsValBinds (GHC.HsTyPats name) must pull out tcdMeths"
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LInstDecl name] name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LInstDecl name) name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LHsType name] name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LHsType name) name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LSig name] name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

-- ---------------------------------------------------------------------
#if __GLASGOW_HASKELL__ > 710
instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LHsSigType name] name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LHsSigType name) name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LHsSigWcType name) name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []
#endif
-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LSig name) name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.HsIPBinds name) name where
  hsValBinds _ = emptyValBinds
  hsTyDecls _ = []

-- EOF

