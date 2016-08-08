{-# LANGUAGE CPP #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeSynonymInstances #-}
--------------------------------------------------------------------------------
-- Module      : Variables

-- |
--

-- ---------------------------------------------------------------------

module Language.Haskell.Refact.Utils.Variables
  (
  -- ** Variable analysis
    isFieldName
  , isClassName
  , isInstanceName
  , isDeclaredInRdr
  , FreeNames(..),DeclaredNames(..)
  , hsFreeAndDeclaredRdr
  , hsFreeAndDeclaredNameStrings
  , hsFreeAndDeclaredPNs
  -- , hsFreeAndDeclaredGhc
  , getDeclaredTypesRdr
  , getDeclaredVarsRdr
  , hsVisibleNamesRdr
  , hsFDsFromInsideRdr, hsFDNamesFromInsideRdr, hsFDNamesFromInsideRdrPure
  , hsVisibleDsRdr
  , rdrName2Name, rdrName2NamePure
  , eqRdrNamePure
  -- , rdrName2Name'

  -- ** Identifiers, expressions, patterns and declarations
  , FindEntity(..)
  , findNameInRdr
  , findNamesRdr
  , sameOccurrence
  , definedPNsRdr,definedNamesRdr
  , definingDeclsRdrNames,definingDeclsRdrNames',definingSigsRdrNames
  , definingTyClDeclsNames
  , definesRdr,definesDeclRdr
  , definesTypeSigRdr,definesSigDRdr

  , hsTypeVbls
  , hsNamessRdr
  , findLRdrName
  , locToNameRdr, locToNameRdrPure
  , locToRdrName
  ) where

import Control.Monad.State
import Data.List
import Data.Maybe
import Data.Monoid
-- import Debug.Trace

import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.Types

import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Utils


-- Modules from GHC
import qualified Bag           as GHC
import qualified GHC           as GHC
import qualified Name          as GHC
import qualified Outputable    as GHC
import qualified RdrName       as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import qualified Data.Map as Map

import Data.Generics.Strafunski.StrategyLib.StrategyLib hiding (liftIO,MonadPlus,mzero)

-- ---------------------------------------------------------------------

class (SYB.Data a, SYB.Typeable a) => FindEntity a where

  -- | Returns True is a syntax phrase, say a, is part of another
  -- syntax phrase, say b.
  -- NOTE: very important: only do a shallow check
  findEntity:: (SYB.Data b) => a -> b -> Bool

-- ---------------------------------------------------------------------

{-# DEPRECATED FindEntity "Can't use Renamed in GHC 8" #-}
instance FindEntity GHC.Name where

  findEntity n t = fromMaybe False res
   where
    res = SYB.somethingStaged SYB.Renamer Nothing (Nothing `SYB.mkQ` worker) t

    worker (name::GHC.Name)
      | n == name = Just True
    worker _ = Nothing


-- This instance does not make sense, it will only find the specific RdrName
-- where it was found, not any other instances of it.
instance FindEntity (GHC.Located GHC.RdrName) where

  findEntity ln t =
    case SYB.something (nameSybQuery checkRdr) t of
      Nothing -> False
      _       -> True
    where
      checkRdr :: GHC.Located GHC.RdrName -> Maybe Bool
      checkRdr n
        | sameOccurrence n ln = Just True
        | otherwise = Nothing

-- ---------------------------------------------------------------------

-- TODO: should the location be matched too in this case?
instance FindEntity (GHC.Located GHC.Name) where

  findEntity n t = fromMaybe False res
   where
    res = SYB.somethingStaged SYB.Renamer Nothing (Nothing `SYB.mkQ` worker) t

    worker (name::GHC.Located GHC.Name)
      | n == name = Just True
    worker _ = Nothing


-- ---------------------------------------------------------------------

instance FindEntity (GHC.LHsExpr GHC.RdrName) where

  findEntity e t = fromMaybe False res
   where
    res = SYB.something (Nothing `SYB.mkQ` worker) t

    worker (expr :: GHC.LHsExpr GHC.RdrName)
      | sameOccurrence e expr = Just True
    worker _ = Nothing

-- TODO: remove this instance
instance FindEntity (GHC.LHsExpr GHC.Name) where

  findEntity e t = fromMaybe False res
   where
    res = SYB.something (Nothing `SYB.mkQ` worker) t

    worker (expr :: GHC.LHsExpr GHC.Name)
      | sameOccurrence e expr = Just True
    worker _ = Nothing

-- ---------------------------------------------------------------------

instance FindEntity (GHC.Located (GHC.HsBindLR GHC.Name GHC.Name)) where
  findEntity e t = fromMaybe False res
   where
    res = SYB.somethingStaged SYB.Renamer Nothing (Nothing `SYB.mkQ` worker) t

    worker (expr::(GHC.Located (GHC.HsBindLR GHC.Name GHC.Name)))
      | sameOccurrence e expr = Just True
    worker _ = Nothing

instance FindEntity (GHC.Located (GHC.HsDecl GHC.Name)) where
  findEntity d t = fromMaybe False res
   where
    res = SYB.somethingStaged SYB.Renamer Nothing (Nothing `SYB.mkQ` worker) t

    worker (decl::(GHC.Located (GHC.HsDecl GHC.Name)))
      | sameOccurrence d decl = Just True
    worker _ = Nothing

-- ---------------------------------------------------------------------

-- TODO: AZ: pretty sure this can be simplified, depends if we need to
--          manage transformed stuff too though.

-- | Return True if syntax phrases t1 and t2 refer to the same one.
sameOccurrence :: (GHC.Located t) -> (GHC.Located t) -> Bool
sameOccurrence (GHC.L l1 _) (GHC.L l2 _)
 = l1 == l2


-- ---------------------------------------------------------------------

-- | For free variables
data FreeNames = FN { fn :: [GHC.Name] }

-- | For declared variables
data DeclaredNames = DN { dn :: [GHC.Name] }

instance Show FreeNames where
  show (FN ls) = "FN " ++ showGhcQual ls

instance Show DeclaredNames where
  show (DN ls) = "DN " ++ showGhcQual ls

instance Monoid FreeNames where
  mempty = FN []
  mappend (FN a) (FN b) = FN (a `mappend` b)

instance Monoid DeclaredNames where
  mempty = DN []
  mappend (DN a) (DN b) = DN (a `mappend` b)


emptyFD :: (FreeNames,DeclaredNames)
emptyFD = (FN [], DN [])

-- ---------------------------------------------------------------------
-- | True if the name is a field name
isFieldName :: GHC.Name -> Bool
isFieldName _n = error "undefined isFieldName"

-- ---------------------------------------------------------------------
-- | True if the name is a field name
isClassName :: GHC.Name -> Bool
isClassName _n = error "undefined isClassName"

-- ---------------------------------------------------------------------
-- | True if the name is a class instance
isInstanceName :: GHC.Name -> Bool
isInstanceName _n = error "undefined isInstanceName"


-- ---------------------------------------------------------------------
-- | Collect those type variables that are declared in a given syntax phrase t. In
-- the returned result, the first list is always be empty.
hsTypeVbls::(SYB.Data t) => t -> ([GHC.RdrName],[GHC.RdrName])
hsTypeVbls =ghead "hsTypeVbls".(applyTU (stop_tdTU (failTU `adhocTU` pnt)))
  where
    -- pnt (PNT (PN i (UniqueNames.S loc)) (Type _) _) = return ([], [(PN i (UniqueNames.S loc))])
    pnt n | GHC.rdrNameSpace n == GHC.tvName = return ([], [n])
    pnt _ = mzero


-------------------------------------------------------------------------------

isDeclaredInRdr :: NameMap -> GHC.Name -> [GHC.LHsDecl GHC.RdrName] -> Bool
isDeclaredInRdr nm name decls = nonEmptyList $ definingDeclsRdrNames nm [name] decls False True

-- ---------------------------------------------------------------------

-- | Collect the free and declared variables (in the GHC.Name format)
-- in a given syntax phrase t. In the result, the first list contains
-- the free variables, and the second list contains the declared
-- variables.
-- Expects RenamedSource
hsFreeAndDeclaredRdr :: (SYB.Data t) => NameMap -> t -> (FreeNames,DeclaredNames)
hsFreeAndDeclaredRdr nm t = res
  where
    fd = hsFreeAndDeclaredRdr' nm t
    (FN f,DN d) = fromMaybe mempty fd
    res = (FN (f \\ d),DN d)

hsFreeAndDeclaredRdr':: (SYB.Data t) => NameMap -> t -> Maybe (FreeNames,DeclaredNames)
hsFreeAndDeclaredRdr' nm t = do
      (FN f,DN d) <- hsFreeAndDeclared'
      let (f',d') = (nub f, nub d)
      return (FN f',DN d')
          -- hsFreeAndDeclared'=applyTU (stop_tdTU (failTU  `adhocTU` exp

   where
          hsFreeAndDeclared' :: Maybe (FreeNames,DeclaredNames)
          hsFreeAndDeclared' = applyTU (stop_tdTU (failTU
                                                      `adhocTU` expr
                                                      `adhocTU` pat
                                                      `adhocTU` bndrs
                                                      `adhocTU` binds
                                                      `adhocTU` bindList
                                                      `adhocTU` match
                                                      `adhocTU` stmts
                                                      `adhocTU` rhs
                                                      `adhocTU` ltydecl
                                                      `adhocTU` hstype
                                                       )) t

          -- expr --
#if __GLASGOW_HASKELL__ <= 710
          expr (GHC.L l (GHC.HsVar n))
#else
          expr (GHC.L l (GHC.HsVar (GHC.L _ n)))
#endif
            = return (FN [rdrName2NamePure nm (GHC.L l n)],DN [])

#if __GLASGOW_HASKELL__ <= 710
          expr (GHC.L _ (GHC.OpApp e1 (GHC.L l (GHC.HsVar n)) _ e2)) = do
#else
          expr (GHC.L _ (GHC.OpApp e1 (GHC.L l (GHC.HsVar (GHC.L _ n))) _ e2)) = do
#endif
              efed <- hsFreeAndDeclaredRdr' nm [e1,e2]
              fd   <- addFree (rdrName2NamePure nm (GHC.L l n)) efed
              return fd

          expr (GHC.L _ ((GHC.HsLam (GHC.MG matches _ _ _))) :: GHC.LHsExpr GHC.RdrName) =
             hsFreeAndDeclaredRdr' nm matches

          expr (GHC.L _ ((GHC.HsLet decls e)) :: GHC.LHsExpr GHC.RdrName) =
            do
              (FN df,DN dd) <- hsFreeAndDeclaredRdr' nm decls
              (FN ef,_)  <- hsFreeAndDeclaredRdr' nm e
              return (FN (df `union` (ef \\ dd)),DN [])

#if __GLASGOW_HASKELL__ <= 710
          expr (GHC.L _ (GHC.RecordCon ln _ e)) = do
#else
          expr (GHC.L _ (GHC.RecordCon ln _ _ e)) = do
#endif
            fd <- (hsFreeAndDeclaredRdr' nm e)
            addFree (rdrName2NamePure nm ln) fd   --Need Testing

          expr (GHC.L _ (GHC.EAsPat ln e)) = do
            fd <- (hsFreeAndDeclaredRdr' nm e)
            addFree (rdrName2NamePure nm ln) fd

          expr _ = mzero


          -- rhs --
          rhs ((GHC.GRHSs g ds) :: GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName))
            = do (FN df,DN dd) <- hsFreeAndDeclaredRdr' nm g
                 (FN ef,DN ed) <- hsFreeAndDeclaredRdr' nm ds
                 return (FN $ df ++ ef, DN $ dd ++ ed)


          -- pat --
          pat :: GHC.LPat GHC.RdrName -> Maybe (FreeNames,DeclaredNames)
          pat (GHC.L _ (GHC.WildPat _)) = mzero
#if __GLASGOW_HASKELL__ <= 710
          pat (GHC.L l (GHC.VarPat n))
#else
          pat (GHC.L l (GHC.VarPat (GHC.L _ n)))
#endif
            = return (FN [],DN [rdrName2NamePure nm (GHC.L l n)])
          pat (GHC.L _ (GHC.AsPat ln p)) = do
            let (f,DN d) = fromMaybe mempty $ hsFreeAndDeclaredRdr' nm p
            return (f,DN (rdrName2NamePure nm ln:d))

          pat (GHC.L _ (GHC.ParPat p)) = pat p
          pat (GHC.L _ (GHC.BangPat p)) = pat p
          pat (GHC.L _ (GHC.ListPat ps _ _)) = do
            fds <- mapM pat ps
            return $ mconcat fds
          pat (GHC.L _ (GHC.TuplePat ps _ _)) = do
            fds <- mapM pat ps
            return $ mconcat fds
          pat (GHC.L _ (GHC.PArrPat ps _)) = do
            fds <- mapM pat ps
            return $ mconcat fds
          pat (GHC.L _ (GHC.ConPatIn n det)) = do
            (FN f,DN d) <- details det
            return $ (FN [rdrName2NamePure nm n],DN d) <> (FN [],DN f)
          pat (GHC.L _ (GHC.ViewPat e p _)) = do
            fde <- hsFreeAndDeclaredRdr' nm e
            fdp <- pat p
            return $ fde <> fdp
          -- pat (GHC.QuasiQuotePat _)
          pat (GHC.L _ (GHC.LitPat _)) = return emptyFD
#if __GLASGOW_HASKELL__ <= 710
          pat (GHC.L _ (GHC.NPat _ _ _)) = return emptyFD
          pat (GHC.L _ (GHC.NPlusKPat n _ _ _)) = return (FN [],DN [rdrName2NamePure nm n])
#else
          pat (GHC.L _ (GHC.NPat _ _ _ _)) = return emptyFD
          pat (GHC.L _ (GHC.NPlusKPat n _ _ _ _ _)) = return (FN [],DN [rdrName2NamePure nm n])
#endif
          pat (GHC.L _ _p@(GHC.SigPatIn p b)) = do
            fdp <- pat p
            (FN fb,DN _db) <- hsFreeAndDeclaredRdr' nm b
            -- error $ "pat.SigPatIn:(b,fb,db)" ++ showGhc (b,fb,db)
            return $ fdp <> (FN fb,DN [])
          pat (GHC.L _ (GHC.SigPatOut p _)) = pat p
          pat (GHC.L l (GHC.CoPat _ p _)) = pat (GHC.L l p)

          pat (GHC.L _ (GHC.LazyPat p)) = pat p

          pat (GHC.L _ (GHC.ConPatOut {})) = error $ "hsFreeAndDeclaredRdr'.pat:impossible: ConPatOut"

#if __GLASGOW_HASKELL__ <= 710
          pat (GHC.L _ (GHC.SplicePat (GHC.HsSplice _ e))) = hsFreeAndDeclaredRdr' nm e
#else
          pat (GHC.L _ (GHC.SplicePat (GHC.HsQuasiQuote {})))     = return (FN [], DN [])
          pat (GHC.L _ (GHC.SplicePat (GHC.HsTypedSplice _ e)))   = hsFreeAndDeclaredRdr' nm e
          pat (GHC.L _ (GHC.SplicePat (GHC.HsUntypedSplice _ e))) = hsFreeAndDeclaredRdr' nm e
#endif

#if __GLASGOW_HASKELL__ <= 710
          pat (GHC.L _ (GHC.QuasiQuotePat _)) = return (FN [], DN [])
#endif

          -- pat p = error $ "hsFreeAndDeclaredRdr'.pat:unimplemented:" ++ (showGhc p)

          -- ---------------------------

          details :: GHC.HsConPatDetails GHC.RdrName -> Maybe (FreeNames,DeclaredNames)
          details (GHC.PrefixCon  args) = do
            -- logm $ "hsFreeAndDeclaredGhc.details:args=" ++ (showGhc args)
            fds <- mapM pat args
            return $ mconcat fds
          details (GHC.RecCon recf) =
            recfields recf
          details (GHC.InfixCon arg1 arg2) = do
            fds <- mapM pat [arg1,arg2]
            return $ mconcat fds

          -- Note: this one applies to HsRecFields in LPats
          recfields :: (GHC.HsRecFields GHC.RdrName (GHC.LPat GHC.RdrName)) -> Maybe (FreeNames,DeclaredNames)
          recfields (GHC.HsRecFields fields _) = do
            let args = map (\(GHC.L _ (GHC.HsRecField _ arg _)) -> arg) fields
            fds <- mapM pat args
            return $ mconcat fds

          -- -----------------------

#if __GLASGOW_HASKELL__ <= 710
          bndrs :: GHC.HsWithBndrs GHC.RdrName (GHC.LHsType GHC.RdrName) -> Maybe (FreeNames,DeclaredNames)
          bndrs (GHC.HsWB thing _ _ _) = do
            (FN ft,DN _dt) <- hsFreeAndDeclaredRdr' nm thing
            return (FN ft,DN [])
#else
          bndrs :: GHC.LHsSigWcType GHC.RdrName -> Maybe (FreeNames,DeclaredNames)
          bndrs (GHC.HsIB _ (GHC.HsWC _ _ ty)) = do
            (FN ft,DN _dt) <- hsFreeAndDeclaredRdr' nm ty
            -- return (FN dt,DN [])
            return (FN ft,DN [])
#endif

          -- ---------------------------

          bindList (ds :: [GHC.LHsBind GHC.RdrName])
            =do (FN f,DN d) <- recurseList ds
                return (FN (f\\d),DN d)

          -- match and patBind, same type--
#if __GLASGOW_HASKELL__ <= 710
          binds ((GHC.FunBind ln _ (GHC.MG matches _ _ _) _ _fvs _) :: GHC.HsBind GHC.RdrName)
#else
          binds ((GHC.FunBind ln (GHC.MG matches _ _ _) _ _fvs _) :: GHC.HsBind GHC.RdrName)
#endif
            = do
                (FN pf,_pd) <- hsFreeAndDeclaredRdr' nm matches
                let n = rdrName2NamePure nm ln
                return (FN (pf \\ [n]) ,DN [n])

          -- patBind --
          binds (GHC.PatBind pat' prhs _ _ds _) =
            do
              (FN pf,DN pd) <- hsFreeAndDeclaredRdr' nm pat'
              (FN rf,DN rd) <- hsFreeAndDeclaredRdr' nm prhs
              return (FN $ pf `union` (rf \\ pd),DN $ pd ++ rd)

          binds _ = mzero

          match ((GHC.Match _fn pats _mtype mrhs) :: GHC.Match GHC.RdrName (GHC.LHsExpr GHC.RdrName))
            = do
              (FN pf,DN pd) <- hsFreeAndDeclaredRdr' nm pats
              (FN rf,DN rd) <- hsFreeAndDeclaredRdr' nm mrhs
              return (FN (pf `union` (rf \\ (pd `union` rd))),DN [])

          -- stmts --
#if __GLASGOW_HASKELL__ <= 710
          stmts ((GHC.BindStmt pat' expre _bindOp _failOp) :: GHC.Stmt GHC.RdrName (GHC.LHsExpr GHC.RdrName)) = do
#else
          stmts ((GHC.BindStmt pat' expre _bindOp _failOp _) :: GHC.Stmt GHC.RdrName (GHC.LHsExpr GHC.RdrName)) = do
#endif
            -- TODO ++AZ++ : Not sure it is meaningful to pull
            --               anything out of bindOp/failOp
            (FN pf,DN pd)  <- hsFreeAndDeclaredRdr' nm pat'
            (FN ef,_ed) <- hsFreeAndDeclaredRdr' nm expre
            let sf1 = []
            return (FN $ pf `union` ef `union` (sf1\\pd),DN []) -- pd) -- Check this

          stmts ((GHC.LetStmt binds') :: GHC.Stmt GHC.RdrName (GHC.LHsExpr GHC.RdrName)) =
            hsFreeAndDeclaredRdr' nm binds'

          stmts _ = mzero

          -- tycldecls -----------------

          ltydecl :: GHC.TyClDecl GHC.RdrName -> Maybe (FreeNames,DeclaredNames)

          ltydecl (GHC.FamDecl fd) = hsFreeAndDeclaredRdr' nm fd
          ltydecl (GHC.SynDecl ln _bndrs _rhs _fvs)
              = return (FN [],DN [rdrName2NamePure nm ln])
#if __GLASGOW_HASKELL__ <= 710
          ltydecl (GHC.DataDecl ln _bndrs defn _fvs) = do
              let dds = map (rdrName2NamePure nm) $ concatMap (GHC.con_names . GHC.unLoc) $ GHC.dd_cons defn
#else
          ltydecl (GHC.DataDecl ln _bndrs defn _c _fvs) = do
              let dds = map (rdrName2NamePure nm) $ concatMap (GHC.getConNames . GHC.unLoc) $ GHC.dd_cons defn
#endif
              return (FN [],DN (rdrName2NamePure nm ln:dds))
          ltydecl (GHC.ClassDecl _ctx ln _tyvars
                           _fds _sigs meths ats atds _docs _fvs) = do
             (_,md) <- hsFreeAndDeclaredRdr' nm meths
             (_,ad) <- hsFreeAndDeclaredRdr' nm ats
             (_,atd) <- hsFreeAndDeclaredRdr' nm atds
             return (FN [],DN [rdrName2NamePure nm ln] <> md <> ad <> atd)

          ------------------------------

          hstype :: GHC.LHsType GHC.RdrName -> Maybe (FreeNames,DeclaredNames)
#if __GLASGOW_HASKELL__ <= 710
          hstype (GHC.L _ (GHC.HsForAllTy _ _ _ _ typ)) = hsFreeAndDeclaredRdr' nm typ
#else
          hstype (GHC.L _ (GHC.HsForAllTy _ typ)) = hsFreeAndDeclaredRdr' nm typ
#endif
#if __GLASGOW_HASKELL__ <= 710
          hstype (GHC.L l (GHC.HsTyVar n)) = return (FN [rdrName2NamePure nm (GHC.L l n)],DN [])
#else
          hstype (GHC.L _ (GHC.HsTyVar n)) = return (FN [rdrName2NamePure nm n],DN [])
#endif
          hstype (GHC.L _ (GHC.HsAppTy t1 t2)) = recurseList [t1,t2]
          hstype (GHC.L _ (GHC.HsFunTy t1 t2)) = recurseList [t1,t2]
          hstype (GHC.L _ (GHC.HsListTy typ)) = hsFreeAndDeclaredRdr' nm typ
          hstype (GHC.L _ (GHC.HsPArrTy typ)) = hsFreeAndDeclaredRdr' nm typ
          hstype (GHC.L _ (GHC.HsTupleTy _ typs)) = recurseList typs
          hstype (GHC.L _ (GHC.HsOpTy t1 _ t2)) = recurseList [t1,t2]
          hstype (GHC.L _ (GHC.HsParTy typ)) = hsFreeAndDeclaredRdr' nm typ
          hstype (GHC.L _ (GHC.HsIParamTy _ typ)) = hsFreeAndDeclaredRdr' nm typ
          hstype (GHC.L _ (GHC.HsEqTy t1 t2)) = recurseList [t1,t2]
          hstype (GHC.L _ (GHC.HsKindSig t1 t2)) = recurseList [t1,t2]
#if __GLASGOW_HASKELL__ <= 710
          hstype (GHC.L _ (GHC.HsQuasiQuoteTy _)) = return emptyFD
#endif
          hstype (GHC.L _ (GHC.HsSpliceTy _ _)) = return (FN [],DN [])
          hstype (GHC.L _ (GHC.HsDocTy _ typ)) = hsFreeAndDeclaredRdr' nm typ
          hstype (GHC.L _ (GHC.HsBangTy _ typ)) = hsFreeAndDeclaredRdr' nm typ
          hstype (GHC.L _ (GHC.HsRecTy cons)) = recurseList cons
          hstype (GHC.L _ (GHC.HsCoreTy _)) = return emptyFD
          hstype (GHC.L _ (GHC.HsExplicitListTy _ typs)) = recurseList typs
          hstype (GHC.L _ (GHC.HsExplicitTupleTy _ typs)) = recurseList typs
          hstype (GHC.L _ (GHC.HsTyLit _)) = return emptyFD
#if __GLASGOW_HASKELL__ <= 710
          hstype (GHC.L _ (GHC.HsWrapTy _ typ)) = hsFreeAndDeclaredRdr' nm typ
#endif
#if __GLASGOW_HASKELL__ <= 710
          hstype (GHC.L _ (GHC.HsWildcardTy)) = error "To implement: hstype, HsWildcardTy"
          hstype (GHC.L _ (GHC.HsNamedWildcardTy _)) = error "To implement: HsNamedWildcardTy"
#else
          hstype (GHC.L _ (GHC.HsWildCardTy _)) = error "To implement: hstype, HsWildcardTy"
#endif
#if __GLASGOW_HASKELL__ > 710
          hstype (GHC.L _ (GHC.HsQualTy (GHC.L _ ctxt) ty)) = recurseList (ty:ctxt)
          hstype (GHC.L _ (GHC.HsAppsTy as)) = do
            fds <- mapM doApp as
            return $ mconcat fds
            where
              doApp (GHC.L _ (GHC.HsAppInfix n)) = return (FN [rdrName2NamePure nm n],DN [])
              doApp (GHC.L _ (GHC.HsAppPrefix ty)) = hstype ty
#endif

          -- ---------------------------------

          recurseList xs = do
            fds <- mapM (hsFreeAndDeclaredRdr' nm) xs
            return $ mconcat fds

          ------------------------------

          addFree :: GHC.Name -> (FreeNames,DeclaredNames)
                  -> Maybe (FreeNames,DeclaredNames)
          addFree free (FN fr,de) = return (FN $ [free] `union` fr, de)

          -- hsFreeAndDeclaredList :: (SYB.Data t) => [t] -> Maybe (FreeNames,DeclaredNames)
          -- hsFreeAndDeclaredList l = do
          --   fds <- mapM (hsFreeAndDeclaredRdr' nm) l
          --   let
          --     unionF (FN a) (FN b) = FN (a `union` b)
          --     unionD (DN a) (DN b) = DN (a `union` b)
          --   return (foldr unionF mempty (map fst fds),
          --           foldr unionD mempty (map snd fds))


-- |The same as `hsFreeAndDeclaredPNs` except that the returned
-- variables are in the String format.
hsFreeAndDeclaredNameStrings::(SYB.Data t)
  => t -> RefactGhc ([String],[String])
hsFreeAndDeclaredNameStrings t = do
  (f1,d1) <- hsFreeAndDeclaredPNs t
  return ((nub.map showGhc) f1, (nub.map showGhc) d1)


-- | Return the free and declared Names in the given syntax fragment. The syntax
-- fragment MUST be parameterised by RdrName, else the empty list will be
-- returned.
hsFreeAndDeclaredPNs :: (SYB.Data t) => t -> RefactGhc ([GHC.Name],[GHC.Name])
hsFreeAndDeclaredPNs t = do
  -- (FN f,DN d) <- hsFreeAndDeclaredGhc t
  nm <- getRefactNameMap
  let (FN f,DN d) = hsFreeAndDeclaredRdr nm t
  return (f,d)

-- ---------------------------------------------------------------------

-- |Get the names of all types declared in the given declaration
-- getDeclaredTypesRdr :: GHC.LTyClDecl GHC.RdrName -> RefactGhc [GHC.Name]
getDeclaredTypesRdr :: GHC.LHsDecl GHC.RdrName -> RefactGhc [GHC.Name]
getDeclaredTypesRdr (GHC.L _ (GHC.TyClD decl)) = do
  nm <- getRefactNameMap
  case decl of
#if __GLASGOW_HASKELL__ <= 710
    (GHC.FamDecl (GHC.FamilyDecl _ ln _ _)) -> return [rdrName2NamePure nm ln]
#else
    (GHC.FamDecl (GHC.FamilyDecl _ ln _ _ _)) -> return [rdrName2NamePure nm ln]
#endif
    (GHC.SynDecl ln  _ _ _) -> return [rdrName2NamePure nm ln]
#if __GLASGOW_HASKELL__ <= 710
    (GHC.DataDecl ln _ defn _) -> do
      let dds = concatMap (GHC.con_names . GHC.unLoc) $ GHC.dd_cons defn
#else
    (GHC.DataDecl ln _ defn _ _) -> do
      let dds = concatMap (GHC.getConNames . GHC.unLoc) $ GHC.dd_cons defn
#endif
      let ddns = map (rdrName2NamePure nm) dds
      return $ [rdrName2NamePure nm ln] ++ ddns

    (GHC.ClassDecl _ ln _vars _fds sigs meths ats _atdefs _ _fvs) -> do
      -- msn <- getMsn meths
      let msn = getDeclaredVarsRdr nm (map wrapDecl $ GHC.bagToList meths)
      let fds = map (GHC.fdLName . GHC.unLoc) ats
          fds' = map (rdrName2NamePure nm) fds
      return $ nub $ [rdrName2NamePure nm ln] ++ ssn ++ msn ++ fds' -- ++ asn
      where
        getLSig :: GHC.LSig GHC.RdrName -> [GHC.Name]
#if __GLASGOW_HASKELL__ <= 710
        getLSig (GHC.L _ (GHC.TypeSig ns _ _))  = map (rdrName2NamePure nm) ns
#else
        getLSig (GHC.L _ (GHC.TypeSig ns _))  = map (rdrName2NamePure nm) ns
#endif
#if __GLASGOW_HASKELL__ <= 710
        getLSig (GHC.L _ (GHC.GenericSig ns _)) = map (rdrName2NamePure nm) ns
#else
        getLSig (GHC.L _ (GHC.ClassOpSig _ ns _)) = map (rdrName2NamePure nm) ns
#endif
        getLSig (GHC.L _ (GHC.IdSig _n)) = []
        getLSig (GHC.L _ (GHC.InlineSig ln2 _)) = [rdrName2NamePure nm ln2]
        getLSig (GHC.L _ (GHC.SpecSig ln2 _ _)) = [rdrName2NamePure nm ln2]
        getLSig (GHC.L _ (GHC.SpecInstSig _ _)) = []
        getLSig (GHC.L _ (GHC.FixSig _)) = []
#if __GLASGOW_HASKELL__ <= 710
        getLSig (GHC.L _ (GHC.PatSynSig _ _ _ _ _)) = error "To implement: getLSig PatSynSig"
#else
        getLSig (GHC.L _ (GHC.PatSynSig _ _)) = error "To implement: getLSig PatSynSig"
#endif
        getLSig (GHC.L _ (GHC.MinimalSig _ _)) = error "To implement: getLSig PatSynSig"

        ssn = concatMap getLSig sigs
getDeclaredTypesRdr _ = return []

-- ---------------------------------------------------------------------

-- | Return True if the specified Name ocuurs in the given syntax phrase.
findNameInRdr :: (SYB.Data t) => NameMap -> GHC.Name -> t -> Bool
findNameInRdr nm pn t = findNamesRdr nm [pn] t

-- ---------------------------------------------------------------------

-- | Return True if any of the specified PNames ocuur in the given syntax phrase.
findNamesRdr :: (SYB.Data t) => NameMap -> [GHC.Name] -> t -> Bool
findNamesRdr nm pns t =
  isJust $ SYB.something (inName) t
    where
      -- r = (SYB.everythingStaged SYB.Parser mappend mempty (inName) t)

      checker :: GHC.Located GHC.RdrName -> Maybe Bool
      checker ln
         | elem (GHC.nameUnique (rdrName2NamePure nm ln)) uns = Just True
      checker _ = Nothing

      inName :: (SYB.Typeable a) => a -> Maybe Bool
      inName = nameSybQuery checker

      uns = map GHC.nameUnique pns

-- ---------------------------------------------------------------------

definedPNsRdr :: GHC.LHsDecl GHC.RdrName -> [GHC.Located GHC.RdrName]
#if __GLASGOW_HASKELL__ <= 710
definedPNsRdr (GHC.L _ (GHC.ValD (GHC.FunBind pname _ _ _ _ _)))   = [pname]
#else
definedPNsRdr (GHC.L _ (GHC.ValD (GHC.FunBind pname _ _ _ _)))   = [pname]
#endif
definedPNsRdr (GHC.L _ (GHC.ValD (GHC.PatBind p _rhs _ty _fvs _))) = (hsNamessRdr p)
-- VarBind will never occur in ParsedSource
-- TODO: what about GHC.AbsBinds?
definedPNsRdr  _ = []

-- ---------------------------------------------------------------------

definedNamesRdr :: NameMap -> GHC.LHsDecl GHC.RdrName -> [GHC.Name]
definedNamesRdr nameMap bind = map (rdrName2NamePure nameMap) (definedPNsRdr bind)

-- ---------------------------------------------------------------------

-- |Find those declarations(function\/pattern binding) which define
-- the specified GHC.Names. incTypeSig indicates whether the
-- corresponding type signature will be included.
definingDeclsRdrNames::
            NameMap
            ->[GHC.Name]   -- ^ The specified identifiers.
            ->[GHC.LHsDecl GHC.RdrName] -- ^ A collection of declarations.
            ->Bool       -- ^ True means to include the type signature.
            ->Bool       -- ^ True means to look at the local declarations as well.
            ->[GHC.LHsDecl GHC.RdrName]  -- ^ The result.
definingDeclsRdrNames nameMap pns ds _incTypeSig recursive = concatMap defining ds
-- ++AZ++:TODO: now we are processing decls again, reinstate incTypeSig function
  where
   defining decl
     = if recursive
        then SYB.everythingStaged SYB.Parser (++) [] ([]  `SYB.mkQ` definesDecl `SYB.extQ` definesBind)  decl
        else definesDecl decl
     where
      definesDecl :: (GHC.LHsDecl GHC.RdrName) -> [GHC.LHsDecl GHC.RdrName]
#if __GLASGOW_HASKELL__ <= 710
      definesDecl decl'@(GHC.L _ (GHC.ValD (GHC.FunBind _ _ _ _ _ _)))
#else
      definesDecl decl'@(GHC.L _ (GHC.ValD (GHC.FunBind _ _ _ _ _)))
#endif
        | any (\n -> definesDeclRdr nameMap n decl') pns = [decl']

      definesDecl decl'@(GHC.L _l (GHC.ValD (GHC.PatBind _p _rhs _ty _fvs _)))
        | any (\n -> definesDeclRdr nameMap n decl') pns = [decl']

      definesDecl _ = []

      definesBind :: (GHC.LHsBind GHC.RdrName) -> [GHC.LHsDecl GHC.RdrName]
      definesBind (GHC.L l b) = definesDecl (GHC.L l (GHC.ValD b))

-- ---------------------------------------------------------------------

-- |Find those declarations(function\/pattern binding) which define
-- the specified GHC.Names. incTypeSig indicates whether the corresponding type
-- signature will be included.
definingDeclsRdrNames' :: (SYB.Data t)
            => NameMap
            -> [GHC.Name]   -- ^ The specified identifiers.
            -> t            -- ^ A collection of declarations.
            -> [GHC.LHsDecl GHC.RdrName]  -- ^ The result.
definingDeclsRdrNames' nameMap pns ds = defining ds
  where
   defining decl
     = SYB.everythingStaged SYB.Renamer (++) [] ([]  `SYB.mkQ` defines' `SYB.extQ` definesBind) decl
     where
      defines' :: (GHC.LHsDecl GHC.RdrName) -> [GHC.LHsDecl GHC.RdrName]
      defines' decl'@(GHC.L _ (GHC.ValD (GHC.FunBind{})))
        | any (\n -> definesDeclRdr nameMap n decl') pns = [decl']

      defines' decl'@(GHC.L _l (GHC.ValD (GHC.PatBind _p _rhs _ty _fvs _)))
        | any (\n -> definesDeclRdr nameMap n decl') pns = [decl']

      defines' _ = []

      definesBind :: (GHC.LHsBind GHC.RdrName) -> [GHC.LHsDecl GHC.RdrName]
      definesBind (GHC.L l b) = defines' (GHC.L l (GHC.ValD b))

-- ---------------------------------------------------------------------

-- |Find those type signatures for the specified GHC.Names.
definingSigsRdrNames :: (SYB.Data t) =>
            NameMap
            ->[GHC.Name] -- ^ The specified identifiers.
            ->t        -- ^ A collection of declarations.
            ->[GHC.LSig GHC.RdrName]  -- ^ The result.
definingSigsRdrNames nameMap pns ds = def ds
  where
   def decl
     -- = SYB.everythingStaged SYB.Renamer (++) [] ([]  `SYB.mkQ` inSig) decl
     = SYB.everything (++) ([]  `SYB.mkQ` inSig `SYB.extQ` inSigDecl) decl
     where
      inSigDecl :: GHC.LHsDecl GHC.RdrName -> [GHC.LSig GHC.RdrName]
      inSigDecl (GHC.L l (GHC.SigD s)) = inSig (GHC.L l s)
      inSigDecl _ = []

      inSig :: (GHC.LSig GHC.RdrName) -> [GHC.LSig GHC.RdrName]
#if __GLASGOW_HASKELL__ <= 710
      inSig (GHC.L l (GHC.TypeSig ns t p))
       | defines' ns /= [] = [(GHC.L l (GHC.TypeSig (defines' ns) t p))]
#else
      inSig (GHC.L l (GHC.TypeSig ns t))
       | defines' ns /= [] = [(GHC.L l (GHC.TypeSig (defines' ns) t))]
#endif
      inSig _ = []

      defines' :: [GHC.Located GHC.RdrName] -> [GHC.Located GHC.RdrName]
      defines' p
        -- = filter (\(GHC.L _ n) -> n `elem` pns) p
        = let
             isDefined :: GHC.Located GHC.RdrName -> [GHC.Located GHC.RdrName]
             isDefined ln = if (rdrName2NamePure nameMap ln) `elem` pns
                              then [ln]
                              else []
          in concatMap isDefined p

-- ---------------------------------------------------------------------

-- |Find those declarations which define the specified GHC.Names.
definingTyClDeclsNames:: (SYB.Data t)
            => NameMap
            -> [GHC.Name]   -- ^ The specified identifiers.
            -> t -- ^ A collection of declarations.
            ->[GHC.LTyClDecl GHC.RdrName]  -- ^ The result.
definingTyClDeclsNames nm pns t = defining t
  where
   defining decl
     = SYB.everythingStaged SYB.Parser (++) []
                   ([]  `SYB.mkQ` defines'
                        `SYB.extQ` definesDecl) decl
     where
      defines' :: (GHC.LTyClDecl GHC.RdrName) -> [GHC.LTyClDecl GHC.RdrName]
#if __GLASGOW_HASKELL__ <= 710
      defines' decl'@(GHC.L _ (GHC.FamDecl (GHC.FamilyDecl _ pname _ _)))
#else
      defines' decl'@(GHC.L _ (GHC.FamDecl (GHC.FamilyDecl _ pname _ _ _)))
#endif
        | elem (GHC.nameUnique $ rdrName2NamePure nm pname) uns = [decl']
        | otherwise = []

      defines' decl'@(GHC.L _ (GHC.SynDecl pname _ _ _))
        | elem (GHC.nameUnique $ rdrName2NamePure nm pname) uns = [decl']
        | otherwise = []

#if __GLASGOW_HASKELL__ <= 710
      defines' decl'@(GHC.L _ (GHC.DataDecl pname _ _ _))
#else
      defines' decl'@(GHC.L _ (GHC.DataDecl pname _ _ _ _))
#endif
        | elem (GHC.nameUnique $ rdrName2NamePure nm pname) uns = [decl']
        | otherwise = []

      defines' decl'@(GHC.L _ (GHC.ClassDecl _ pname _ _ _ _ _ _ _ _))
        | elem (GHC.nameUnique $ rdrName2NamePure nm pname) uns = [decl']
        | otherwise = []

      definesDecl (GHC.L l (GHC.TyClD d)) = defines' (GHC.L l d)
      definesDecl _ = []

      uns = map (\n -> GHC.nameUnique n) pns

-- ---------------------------------------------------------------------

-- | Return True if the function\/pattern binding defines the
-- specified identifier.
definesRdr :: NameMap -> GHC.Name -> GHC.LHsBind GHC.RdrName -> Bool
#if __GLASGOW_HASKELL__ <= 710
definesRdr nm  nin (GHC.L _ (GHC.FunBind ln _ _ _ _ _))
#else
definesRdr nm nin (GHC.L _ (GHC.FunBind ln _ _ _ _))
#endif
  = GHC.nameUnique (rdrName2NamePure nm ln) == GHC.nameUnique nin
definesRdr nm n (GHC.L _ (GHC.PatBind p _rhs _ty _fvs _))
  = elem n (map (rdrName2NamePure nm) (hsNamessRdr p))
definesRdr _ _ _= False

-- |Unwraps a LHsDecl and calls definesRdr on the result if a HsBind or calls clsDeclDefinesRdr if a TyClD
definesDeclRdr :: NameMap -> GHC.Name -> GHC.LHsDecl GHC.RdrName -> Bool
definesDeclRdr nameMap nin (GHC.L l (GHC.ValD d)) = definesRdr nameMap nin (GHC.L l d)
definesDeclRdr nameMap nin (GHC.L l (GHC.TyClD ty)) = clsDeclDefinesRdr nameMap nin ty
definesDeclRdr _ _ _ = False

-- | Return True of the type class declaration defines the
-- specified identifier
clsDeclDefinesRdr :: NameMap -> GHC.Name -> GHC.TyClDecl GHC.RdrName -> Bool
clsDeclDefinesRdr nameMap nin (GHC.SynDecl (GHC.L ln nm) _ty _rhs _) =
  case Map.lookup ln nameMap of
    Nothing -> False
    Just n  -> GHC.nameUnique n == GHC.nameUnique nin
clsDeclDefinesRdr _ _ _ = False

-- ---------------------------------------------------------------------

-- | Return True if the declaration defines the type signature of the
-- specified identifier.
definesTypeSigRdr :: NameMap -> GHC.Name -> GHC.Sig GHC.RdrName -> Bool
#if __GLASGOW_HASKELL__ <= 710
definesTypeSigRdr nameMap pn (GHC.TypeSig names _typ _)
#else
definesTypeSigRdr nameMap pn (GHC.TypeSig names _typ)
#endif
  = elem (GHC.nameUnique pn) (map (GHC.nameUnique . rdrName2NamePure nameMap) names)
-- definesTypeSigRdr _ _  _ = False
definesTypeSigRdr _ _  x = error $ "definesTypeSigRdr : got " ++ SYB.showData SYB.Parser 0 x

-- |Unwraps a LHsDecl and calls definesRdr on the result if a Sig
definesSigDRdr :: NameMap -> GHC.Name -> GHC.LHsDecl GHC.RdrName -> Bool
definesSigDRdr nameMap nin (GHC.L _ (GHC.SigD d)) = definesTypeSigRdr nameMap nin d
definesSigDRdr _ _ _ = False

-- ---------------------------------------------------------------------

-- |Get all the names in the given syntax element
hsNamessRdr :: (SYB.Data t) => t -> [GHC.Located GHC.RdrName]
hsNamessRdr t = nub $ fromMaybe [] r
  where
     r = (SYB.everythingStaged SYB.Parser mappend mempty (inName) t)

     checker :: GHC.Located GHC.RdrName -> Maybe [GHC.Located GHC.RdrName]
     checker x = Just [x]

     inName :: (SYB.Typeable a) => a -> Maybe [GHC.Located GHC.RdrName]
     inName = nameSybQuery checker

-- ---------------------------------------------------------------------

-- |Does the given 'GHC.Name' appear as a 'GHC.Located' 'GHC.RdrName' anywhere in 't'?
findLRdrName :: (SYB.Data t) => NameMap -> GHC.Name -> t -> Bool
findLRdrName nm n t = isJust $ SYB.something isMatch t
  where
    checker :: GHC.Located GHC.RdrName -> Maybe Bool
    checker x
      | GHC.nameUnique (rdrName2NamePure nm x) == GHC.nameUnique n = Just True
      | otherwise = Nothing

    isMatch :: (SYB.Typeable a) => a -> Maybe Bool
    isMatch = nameSybQuery checker

-- ---------------------------------------------------------------------


getDeclaredVarsRdr :: NameMap -> [GHC.LHsDecl GHC.RdrName] -> [GHC.Name]
getDeclaredVarsRdr nm bs = concatMap vars bs
  where
      vars :: (GHC.LHsDecl GHC.RdrName) -> [GHC.Name]
#if __GLASGOW_HASKELL__ <= 710
      vars (GHC.L _ (GHC.ValD (GHC.FunBind ln _ _ _ _fvs _)))   = [rdrName2NamePure nm ln]
#else
      vars (GHC.L _ (GHC.ValD (GHC.FunBind ln _ _ _ _fvs)))   = [rdrName2NamePure nm ln]
#endif
      vars (GHC.L _ (GHC.ValD (GHC.PatBind p _rhs _ty _fvs _))) = (map (rdrName2NamePure nm) $ hsNamessRdr p)
      vars _ = []

--------------------------------------------------------------------------------
-- | Same as `hsVisiblePNsRdr' except that the returned identifiers are
-- in String format.
hsVisibleNamesRdr:: (SYB.Data t2)
  => GHC.Name -> t2 -> RefactGhc [String]
hsVisibleNamesRdr e t = do
    nm <- getRefactNameMap
    (DN d) <- hsVisibleDsRdr nm e t
    return ((nub . map showGhc) d)

------------------------------------------------------------------------

-- | Given a 'Name' n and a syntax phrase t, if n occurs in t, then return those
-- variables which are declared in t and accessible to n, otherwise
-- return [].
hsVisibleDsRdr :: (SYB.Data t)
             => NameMap -> GHC.Name -> t -> RefactGhc DeclaredNames
hsVisibleDsRdr nm e t = do
  -- logm $ "hsVisibleDsRdr:(e,t)=" ++ (SYB.showData SYB.Renamer 0 (e,t))
  (DN d) <- res
  return (DN (nub d))
  where
    -- TODO: this is effectively a recursive descent approach, where
    --       each syntax element processor knows exactly what it needs
    --       in terms of sub-elements. Hence as an optimisation,
    --       consider calling the relevent element directly, instead
    --       of looping back into the main function.
    res = (const err -- (DN [])
          `SYB.extQ` parsed
          `SYB.extQ` lvalbinds
          `SYB.extQ` valbinds
          `SYB.extQ` lhsdecls
          `SYB.extQ` lhsdecl
          `SYB.extQ` lhsbindslr
          `SYB.extQ` hsbinds
          `SYB.extQ` hsbind
          `SYB.extQ` hslocalbinds
          `SYB.extQ` lmatch
          `SYB.extQ` grhss
          `SYB.extQ` lgrhs
          `SYB.extQ` lexpr
          `SYB.extQ` tyclgroups
          `SYB.extQ` tyclgroup
          `SYB.extQ` tycldeclss
          `SYB.extQ` tycldecls
          `SYB.extQ` tycldecl
          `SYB.extQ` instdecls
          `SYB.extQ` instdecl
          `SYB.extQ` lhstype
          `SYB.extQ` lsigs
          `SYB.extQ` lsig
          `SYB.extQ` lstmts
          `SYB.extQ` lstmt
          `SYB.extQ` lpats
          `SYB.extQ` lpat
#if __GLASGOW_HASKELL__ > 710
          `SYB.extQ` ibndrs
          `SYB.extQ` lsigty
#endif
          ) t

    -- err2 = error $ "hsVisibleDsRdr:err2:no match for:" ++ (SYB.showData SYB.Renamer 0 t)

    parsed :: GHC.ParsedSource -> RefactGhc DeclaredNames
    parsed p
      | findNameInRdr nm e p = do
         -- dfds <- mapM (hsVisibleDsRdr nm e) $ GHC.hsmodDecls $ GHC.unLoc p
         logm $ "hsVisibleDsRdr parsedSource:decls starting"
         dfds <- mapM (declFun ( hsVisibleDsRdr nm e) ) $ GHC.hsmodDecls $ GHC.unLoc p
         logm $ "hsVisibleDsRdr parsedSource:decls done"
         return $ mconcat dfds
    parsed _ = return (DN [])

    lvalbinds :: (GHC.Located (GHC.HsLocalBinds GHC.RdrName)) -> RefactGhc DeclaredNames
    lvalbinds (GHC.L _ (GHC.HsValBinds vb)) = valbinds vb
    lvalbinds (GHC.L _ (GHC.HsIPBinds _))   = return (DN [])
    lvalbinds (GHC.L _ GHC.EmptyLocalBinds) = return (DN [])

    valbinds :: (GHC.HsValBinds GHC.RdrName) -> RefactGhc DeclaredNames
    valbinds vb@(GHC.ValBindsIn bindsBag sigs)
      | findNameInRdr nm e vb = do
          fdsb <- mapM (hsVisibleDsRdr nm e) $ GHC.bagToList bindsBag
          fdss <- mapM (hsVisibleDsRdr nm e) sigs
          return $ mconcat fdss <> mconcat fdsb
    valbinds vb@(GHC.ValBindsOut _binds _sigs)
      | findNameInRdr nm e vb = do
          logm $ "hsVisibleDsRdr valbinds:ValBindsOut:impossible for RdrName"
          return (DN [])

    valbinds _ = do
      logm $ "hsVisibleDsRdr nm.valbinds:not matched"
      return (DN [])

    lhsdecls :: [GHC.LHsDecl GHC.RdrName] -> RefactGhc DeclaredNames
    lhsdecls ds
      | findNameInRdr nm e ds = do
         dfds <- mapM (declFun ( hsVisibleDsRdr nm e) ) ds
         return $ mconcat dfds
    lhsdecls _ = return (DN [])

    lhsdecl :: GHC.LHsDecl GHC.RdrName -> RefactGhc DeclaredNames
    lhsdecl (GHC.L l dd) = do
        logm $ "hsVisibleDsRdr.lhsdecl"
        case dd of
            GHC.TyClD d       -> hsVisibleDsRdr nm e (GHC.L l d)
            GHC.InstD d       -> hsVisibleDsRdr nm e (GHC.L l d)
            GHC.DerivD d      -> hsVisibleDsRdr nm e (GHC.L l d)
            GHC.ValD d        -> hsVisibleDsRdr nm e (GHC.L l d)
            GHC.SigD d        -> hsVisibleDsRdr nm e (GHC.L l d)
            GHC.DefD d        -> hsVisibleDsRdr nm e (GHC.L l d)
            GHC.ForD d        -> hsVisibleDsRdr nm e (GHC.L l d)
            GHC.WarningD d    -> hsVisibleDsRdr nm e (GHC.L l d)
            GHC.AnnD d        -> hsVisibleDsRdr nm e (GHC.L l d)
            GHC.RuleD d       -> hsVisibleDsRdr nm e (GHC.L l d)
            GHC.VectD d       -> hsVisibleDsRdr nm e (GHC.L l d)
            GHC.SpliceD d     -> hsVisibleDsRdr nm e (GHC.L l d)
            GHC.DocD d        -> hsVisibleDsRdr nm e (GHC.L l d)
            GHC.RoleAnnotD d  -> hsVisibleDsRdr nm e (GHC.L l d)
#if __GLASGOW_HASKELL__ < 711
            GHC.QuasiQuoteD d -> hsVisibleDsRdr nm e (GHC.L l d)
#endif

    lhsbindslr :: GHC.LHsBinds GHC.RdrName -> RefactGhc DeclaredNames
    lhsbindslr bs = do
      fds <- mapM (hsVisibleDsRdr nm e) $ GHC.bagToList bs
      return $ mconcat fds

    hsbinds :: [GHC.LHsBind GHC.RdrName] -> RefactGhc DeclaredNames
    hsbinds ds
      | findNameInRdr nm e ds = do
        fds <- mapM (hsVisibleDsRdr nm e) ds
        return $ mconcat fds
    hsbinds _ = return (DN [])

    hsbind :: (GHC.LHsBind GHC.RdrName) -> RefactGhc DeclaredNames
#if __GLASGOW_HASKELL__ <= 710
    hsbind ((GHC.L _ (GHC.FunBind _n _ (GHC.MG matches _ _ _) _ _ _)))
#else
    hsbind ((GHC.L _ (GHC.FunBind _n (GHC.MG (GHC.L _ matches) _ _ _) _ _ _)))
#endif
      | findNameInRdr nm e matches = do
          fds <- mapM (hsVisibleDsRdr nm e) matches
          logm $ "hsVisibleDsRdr.hsbind:fds=" ++ show fds
          return $ mconcat fds
    hsbind _ = do
      -- logm $ "hsVisibleDsRdr.hsbind:miss"
      return (DN [])


    hslocalbinds :: (GHC.HsLocalBinds GHC.RdrName) -> RefactGhc DeclaredNames
    hslocalbinds (GHC.HsValBinds binds)
      | findNameInRdr nm e binds = hsVisibleDsRdr nm e binds
    hslocalbinds (GHC.HsIPBinds binds)
      | findNameInRdr nm e binds = hsVisibleDsRdr nm e binds
    hslocalbinds (GHC.EmptyLocalBinds) = return (DN [])
    hslocalbinds _ = return (DN [])

    lmatch :: (GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)) -> RefactGhc DeclaredNames
    lmatch (GHC.L _ (GHC.Match _fn pats _mtyp rhs))
      | findNameInRdr nm e pats = do
           logm $ "hsVisibleDsRdr nm.lmatch:in pats="
           return (DN []) -- TODO: extend this
      | findNameInRdr nm e rhs = do
           logm $ "hsVisibleDsRdr nm.lmatch:doing rhs"
           let (pf,pd) = hsFreeAndDeclaredRdr nm pats
           logm $ "hsVisibleDsRdr nm.lmatch:(pf,pd)=" ++ (show (pf,pd))
           (    rd) <- hsVisibleDsRdr nm e rhs
           return (pd <> rd)
    lmatch _ =return  (DN [])

    grhss :: (GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName)) -> RefactGhc DeclaredNames
    grhss (GHC.GRHSs guardedRhss lstmts')
      | findNameInRdr nm e guardedRhss = do
          logm "hsVisibleDsRdr nm.grhss:about to do grhss"
          fds <- mapM (hsVisibleDsRdr nm e) guardedRhss
          logm "hsVisibleDsRdr nm.grhss:grhss done"
          return $ mconcat fds
      | findNameInRdr nm e lstmts' = do
          logm "hsVisibleDsRdr nm.grhss:about to do lstmts"
          hsVisibleDsRdr nm e lstmts'
    grhss _ = return (DN [])

    lgrhs :: GHC.LGRHS GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc DeclaredNames
    lgrhs (GHC.L _ (GHC.GRHS guards ex))
      | findNameInRdr nm e guards = logm "hsVisibleDsRdr nm.lgrhs.guards" >> hsVisibleDsRdr nm e guards
      | findNameInRdr nm e ex     = logm "hsVisibleDsRdr nm.lgrhs.ex"     >> hsVisibleDsRdr nm e ex
    lgrhs _ = return (DN [])


    lexpr :: GHC.LHsExpr GHC.RdrName -> RefactGhc DeclaredNames
#if __GLASGOW_HASKELL__ <= 710
    lexpr (GHC.L l (GHC.HsVar n))
#else
    lexpr (GHC.L l (GHC.HsVar (GHC.L _ n)))
#endif
      | findNameInRdr nm e n  = do
        logm $ "hsVisibleDsRdr.lexpr.HsVar entity found"
        return (DN [rdrName2NamePure nm (GHC.L l n)])
    lexpr (GHC.L _ (GHC.HsLet lbinds expr))
      | findNameInRdr nm e lbinds || findNameInRdr nm e expr  = do
        logm $ "hsVisibleDsRdr.lexpr.HsLet entity found"
        let (_,lds) = hsFreeAndDeclaredRdr nm lbinds
        let (_,eds) = hsFreeAndDeclaredRdr nm expr
        return $ lds <> eds

    lexpr expr
      | findNameInRdr nm e expr = do
        logm $ "hsVisibleDsRdr nm.lexpr.(e,expr):" ++ (showGhc (e,expr))
        let (FN efs,_)         = hsFreeAndDeclaredRdr nm expr
        let (FN _eefs,DN eeds) = hsFreeAndDeclaredRdr nm e
        logm $ "hsVisibleDsRdr nm.lexpr done"
        -- return (DN e1fs <> DN eofs <> DN e2fs)
        return (DN (efs \\ eeds))

    lexpr x = do
      logm $ "hsVisibleDsRdr.lexpr:miss for:" ++ SYB.showData SYB.Parser 0 x
      return (DN [])

    -- ---------------------------------

    tyclgroups :: [GHC.TyClGroup GHC.RdrName] -> RefactGhc DeclaredNames
    tyclgroups tgrps
      | findNameInRdr nm e tgrps = do
        fds <- mapM (hsVisibleDsRdr nm e) tgrps
        return $ mconcat fds
    tyclgroups _ = return (DN [])

    tyclgroup :: GHC.TyClGroup GHC.RdrName -> RefactGhc DeclaredNames
    tyclgroup (GHC.TyClGroup tyclds _roles)
      | findNameInRdr nm e tyclds = do
        fds <- mapM (hsVisibleDsRdr nm e) tyclds
        return $ mconcat fds
    tyclgroup _ = return (DN [])

    tycldeclss :: [[GHC.LTyClDecl GHC.RdrName]] -> RefactGhc DeclaredNames
    tycldeclss tcds
      | findNameInRdr nm e tcds = do
        fds <- mapM (hsVisibleDsRdr nm e) tcds
        return $ mconcat fds
    tycldeclss _ = return (DN [])

    tycldecls :: [GHC.LTyClDecl GHC.RdrName] -> RefactGhc DeclaredNames
    tycldecls tcds
      | findNameInRdr nm e tcds = do
        logm $ "hsVisibleDsRdr.tycldecls"
        fds <- mapM (hsVisibleDsRdr nm e) tcds
        logm $ "hsVisibleDsRdr.tycldecls done"
        return $ mconcat fds
    tycldecls _ = return (DN [])

    tycldecl :: GHC.LTyClDecl GHC.RdrName -> RefactGhc DeclaredNames
    tycldecl tcd
      | findNameInRdr nm e tcd = do
        logm $ "hsVisibleDsRdr.tycldecl"
        let (_,ds) = hsFreeAndDeclaredRdr nm tcd
        logm $ "hsVisibleDsRdr.tycldecl done"
        return ds
    tycldecl _ = return (DN [])

    -- ---------------------------------

    instdecls :: [GHC.LInstDecl GHC.RdrName] -> RefactGhc DeclaredNames
    instdecls ds
      | findNameInRdr nm e ds = do
        fds <- mapM (hsVisibleDsRdr nm e) ds
        return $ mconcat fds
    instdecls _ = return (DN [])

    instdecl :: GHC.LInstDecl GHC.RdrName -> RefactGhc DeclaredNames
    instdecl (GHC.L _ (GHC.ClsInstD (GHC.ClsInstDecl polytyp binds sigs tyfaminsts dfaminsts _)))
      | findNameInRdr nm e polytyp    = hsVisibleDsRdr nm e polytyp
      | findNameInRdr nm e binds      = hsVisibleDsRdr nm e binds
      | findNameInRdr nm e sigs       = hsVisibleDsRdr nm e sigs
      | findNameInRdr nm e tyfaminsts = hsVisibleDsRdr nm e tyfaminsts
      | findNameInRdr nm e dfaminsts  = hsVisibleDsRdr nm e dfaminsts
      | otherwise = return (DN [])
    instdecl (GHC.L _ (GHC.DataFamInstD (GHC.DataFamInstDecl _ln pats defn _)))
      | findNameInRdr nm e pats = hsVisibleDsRdr nm e pats
      | findNameInRdr nm e defn = hsVisibleDsRdr nm e defn
      | otherwise = return (DN [])
    instdecl (GHC.L _ (GHC.TyFamInstD (GHC.TyFamInstDecl eqn _)))
      | findNameInRdr nm e eqn = hsVisibleDsRdr nm e eqn
      | otherwise = return (DN [])

    lhstype :: GHC.LHsType GHC.RdrName -> RefactGhc DeclaredNames
#if __GLASGOW_HASKELL__ <= 710
    lhstype tv@(GHC.L l (GHC.HsTyVar n))
#else
    lhstype tv@(GHC.L l (GHC.HsTyVar (GHC.L _ n)))
#endif
      | findNameInRdr nm e tv = return (DN [rdrName2NamePure nm (GHC.L l n)])
      | otherwise       = return (DN [])
    lhstype (GHC.L _ (GHC.HsForAllTy {}))
        = return (DN [])
    lhstype (GHC.L _ (GHC.HsFunTy{})) = return (DN [])
    lhstype ty = do
      logm $ "lshtype: TypeUtils 1588" ++ SYB.showData SYB.Renamer 0 ty
      return (DN [])

    -- -----------------------

    lsigs :: [GHC.LSig GHC.RdrName] -> RefactGhc DeclaredNames
    lsigs ss = do
      fds <- mapM (hsVisibleDsRdr nm e) ss
      return $ mconcat fds

    -- -----------------------

    lsig :: GHC.LSig GHC.RdrName -> RefactGhc DeclaredNames
#if __GLASGOW_HASKELL__ <= 710
    lsig (GHC.L _ (GHC.TypeSig _ns typ _))
#else
    lsig (GHC.L _ (GHC.TypeSig _ns typ))
#endif
      | findNameInRdr nm e typ = hsVisibleDsRdr nm e typ
#if __GLASGOW_HASKELL__ <= 710
    lsig (GHC.L _ (GHC.GenericSig _n typ))
#else
    lsig (GHC.L _ (GHC.ClassOpSig _ _n (GHC.HsIB _ typ)))
#endif
      | findNameInRdr nm e typ = hsVisibleDsRdr nm e typ
    lsig (GHC.L _ (GHC.IdSig _)) = return (DN [])
    lsig (GHC.L _ (GHC.InlineSig _ _)) = return (DN [])
    lsig (GHC.L _ (GHC.SpecSig _n typ _))
      | findNameInRdr nm e typ = hsVisibleDsRdr nm e typ
    lsig (GHC.L _ (GHC.SpecInstSig _ _)) = return (DN [])

    lsig _ = return (DN [])

    -- -----------------------

    lstmts :: [GHC.LStmt GHC.RdrName (GHC.LHsExpr GHC.RdrName)] -> RefactGhc DeclaredNames
    lstmts ds
      | findNameInRdr nm e ds = do
        fds <- mapM (hsVisibleDsRdr nm e) ds
        return $ mconcat fds
    lstmts _ = return (DN [])

    -- -----------------------

    lstmt :: GHC.LStmt GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc DeclaredNames
#if __GLASGOW_HASKELL__ <= 710
    lstmt (GHC.L _ (GHC.LastStmt ex _)) = hsVisibleDsRdr nm e ex
#else
    lstmt (GHC.L _ (GHC.LastStmt ex _ _)) = hsVisibleDsRdr nm e ex
#endif
#if __GLASGOW_HASKELL__ <= 710
    lstmt (GHC.L _ (GHC.BindStmt pa ex _ _)) = do
#else
    lstmt (GHC.L _ (GHC.BindStmt pa ex _ _ _)) = do
#endif
      fdp <- hsVisibleDsRdr nm e pa
      fde <- hsVisibleDsRdr nm e ex
      return (fdp <> fde)
    lstmt (GHC.L _ (GHC.BodyStmt ex _ _ _)) = hsVisibleDsRdr nm e ex

    lstmt (GHC.L _ (GHC.LetStmt bs)) = hsVisibleDsRdr nm e bs
#if __GLASGOW_HASKELL__ <= 710
    lstmt (GHC.L _ (GHC.ParStmt ps _ _)) = hsVisibleDsRdr nm e ps
#else
    lstmt (GHC.L _ (GHC.ParStmt ps _ _ _)) = hsVisibleDsRdr nm e ps
#endif
#if __GLASGOW_HASKELL__ <= 710
    lstmt (GHC.L _ (GHC.TransStmt _ stmts _ using mby _ _ _)) = do
#else
    lstmt (GHC.L _ (GHC.TransStmt _ stmts _ using mby _ _ _ _)) = do
#endif
      fds <- hsVisibleDsRdr nm e stmts
      fdu <- hsVisibleDsRdr nm e using
      fdb <- case mby of
        Nothing -> return (DN [])
        Just ex -> hsVisibleDsRdr nm e ex
      return $ fds <> fdu <> fdb
#if __GLASGOW_HASKELL__ <= 710
    lstmt (GHC.L _ (GHC.RecStmt stmts _ _ _ _ _ _ _ _)) = hsVisibleDsRdr nm e stmts
#else
    lstmt (GHC.L _ (GHC.RecStmt stmts _ _ _ _ _ _ _ _ _)) = hsVisibleDsRdr nm e stmts
#endif

#if __GLASGOW_HASKELL__ > 710
    lstmt (GHC.L _ (GHC.ApplicativeStmt {})) = return mempty
#endif
    -- lstmt _ = return (DN [])

    -- -----------------------

    lpats :: [GHC.LPat GHC.RdrName] -> RefactGhc DeclaredNames
    lpats ps
      | findNameInRdr nm e ps = do
        fds <- mapM (hsVisibleDsRdr nm e) ps
        return $ mconcat fds
    lpats _ = return (DN [])

    -- -----------------------

    lpat :: GHC.LPat GHC.RdrName -> RefactGhc DeclaredNames
    lpat (GHC.L _ (GHC.WildPat _)) = return (DN [])
#if __GLASGOW_HASKELL__ <= 710
    lpat (GHC.L l (GHC.VarPat n))
#else
    lpat (GHC.L l (GHC.VarPat (GHC.L _ n)))
#endif
      = return (DN [rdrName2NamePure nm (GHC.L l n)])
    lpat (GHC.L _ (GHC.AsPat ln p)) = do
      (DN dp) <- lpat p
      return (DN (rdrName2NamePure nm ln:dp))

    lpat (GHC.L _ (GHC.ParPat p)) = lpat p
    lpat (GHC.L _ (GHC.BangPat p)) = lpat p
    lpat (GHC.L _ (GHC.ListPat ps _ _)) = do
      fds <- mapM lpat ps
      return $ mconcat fds
    lpat (GHC.L _ (GHC.TuplePat ps _ _)) = do
      fds <- mapM lpat ps
      return $ mconcat fds
    lpat (GHC.L _ (GHC.PArrPat ps _)) = do
      fds <- mapM lpat ps
      return $ mconcat fds
    lpat (GHC.L _ (GHC.ConPatIn n det)) = do
      -- logm $ "hsFreeAndDeclaredGhc.lpat.ConPatIn:details=" ++ (SYB.showData SYB.Renamer 0 det)
      (DN d) <- details det
      return $ (DN (rdrName2NamePure nm n:d))
    -- lpat (GHC.ConPatOut )
    lpat (GHC.L _ (GHC.ViewPat ex p _)) = do
      fde <- hsVisibleDsRdr nm e ex
      fdp <- lpat p
      return $ fde <> fdp
    -- lpat (GHC.QuasiQuotePat _)
    lpat (GHC.L _ (GHC.LitPat _)) = return (DN [])
#if __GLASGOW_HASKELL__ <= 710
    lpat (GHC.L _ (GHC.NPat _ _ _)) = return (DN [])
    lpat (GHC.L _ (GHC.NPlusKPat n _ _ _)) = return (DN [rdrName2NamePure nm n])
#else
    lpat (GHC.L _ (GHC.NPat _ _ _ _)) = return (DN [])
    lpat (GHC.L _ (GHC.NPlusKPat n _ _ _ _ _)) = return (DN [rdrName2NamePure nm n])
#endif
    lpat (GHC.L _ _p@(GHC.SigPatIn p b)) = do
      dp <- lpat p
      db <- hsVisibleDsRdr nm e b
      -- error $ "lpat.SigPatIn:(b,fb,db)" ++ showGhc (b,fb,db)
      return $ dp <> db
    lpat (GHC.L _ (GHC.SigPatOut p _)) = lpat p
    lpat (GHC.L l (GHC.CoPat _ p _)) = lpat (GHC.L l p)

    lpat (GHC.L _ (GHC.LazyPat p)) = lpat p
    lpat (GHC.L _ (GHC.ConPatOut {})) = error $ "hsFreeAndDeclared.lpat:impossible GHC.ConPatOut"
#if __GLASGOW_HASKELL__ <= 710
    lpat (GHC.L _ (GHC.QuasiQuotePat _)) = return mempty
    lpat (GHC.L _ (GHC.SplicePat (GHC.HsSplice _ expr))) = hsVisibleDsRdr nm e expr
#else
    lpat (GHC.L _ (GHC.SplicePat (GHC.HsTypedSplice _ expr)))   = hsVisibleDsRdr nm e expr
    lpat (GHC.L _ (GHC.SplicePat (GHC.HsUntypedSplice _ expr))) = hsVisibleDsRdr nm e expr
    lpat (GHC.L _ (GHC.SplicePat (GHC.HsQuasiQuote {})))        = return mempty
#endif

    -- ---------------------------

    details :: GHC.HsConPatDetails GHC.RdrName -> RefactGhc DeclaredNames
    details (GHC.PrefixCon  args) = do
      -- logm $ "hsFreeAndDeclaredGhc.details:args=" ++ (showGhc args)
      fds <- mapM lpat args
      return $ mconcat fds
    details (GHC.RecCon recf) =
      recfields recf
    details (GHC.InfixCon arg1 arg2) = do
      fds <- mapM lpat [arg1,arg2]
      return $ mconcat fds

    -- Note: this one applies to HsRecFields in LPats
    recfields :: (GHC.HsRecFields GHC.RdrName (GHC.LPat GHC.RdrName)) -> RefactGhc DeclaredNames
    recfields (GHC.HsRecFields fields _) = do
      let args = map (\(GHC.L _ (GHC.HsRecField _ arg _)) -> arg) fields
      fds <- mapM lpat args
      return $ mconcat fds

    -- -----------------------
#if __GLASGOW_HASKELL__ > 710
    ibndrs :: GHC.LHsSigWcType GHC.RdrName -> RefactGhc DeclaredNames
    ibndrs (GHC.HsIB _ (GHC.HsWC _ _ ty)) = hsVisibleDsRdr nm e ty

    lsigty :: GHC.LHsSigType GHC.RdrName -> RefactGhc DeclaredNames
    lsigty (GHC.HsIB _ ty) = hsVisibleDsRdr nm e ty
#endif
    -- -----------------------

    err = error $ "hsVisibleDsRdr nm:no match for:" ++ (SYB.showData SYB.Parser 0 t)

-- ---------------------------------------------------------------------

-- |`hsFDsFromInsideRdr` is different from `hsFreeAndDeclaredPNs` in
-- that: given an syntax phrase t, `hsFDsFromInsideRdr` returns not only
-- the declared variables that are visible from outside of t, but also
-- those declared variables that are visible to the main expression
-- inside t.
-- NOTE: Expects to be given ParsedSource
hsFDsFromInsideRdr :: (SYB.Data t)
                  => NameMap ->  t -> (FreeNames,DeclaredNames)
hsFDsFromInsideRdr nm t = hsFDsFromInsideRdr' t
   where
     hsFDsFromInsideRdr' :: (SYB.Data t) => t -> (FreeNames,DeclaredNames)
     hsFDsFromInsideRdr' t1 = (FN $ nub f', DN $ nub d')
       where
          r1 = applyTU (once_tdTU (failTU  `adhocTU` parsed
                                           `adhocTU` decl
                                           `adhocTU` match
                                           `adhocTU` expr
                                           `adhocTU` stmts )) t1
          -- let (f',d') = fromMaybe ([],[]) r1
          (FN f',DN d') = fromMaybe (FN [],DN []) r1
          -- (FN f',DN d') = r1

     parsed :: GHC.ParsedSource -> Maybe (FreeNames,DeclaredNames)
     parsed p = return $ hsFreeAndDeclaredRdr nm p

     -- ----------------------

     match :: GHC.Match GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> Maybe (FreeNames,DeclaredNames)
     match (GHC.Match _fn pats _type rhs) = do
       let (FN pf, DN pd) = hsFreeAndDeclaredRdr nm pats
           (FN rf, DN rd) = hsFreeAndDeclaredRdr nm rhs
       return (FN $ nub (pf `union` (rf \\ pd)),
               DN $ nub (pd `union` rd))

     -- ----------------------

     decl :: GHC.HsBind GHC.RdrName -> Maybe (FreeNames,DeclaredNames)
#if __GLASGOW_HASKELL__ <= 710
     decl (GHC.FunBind (GHC.L _ _) _ (GHC.MG matches _ _ _) _ _ _) = do
#else
     decl (GHC.FunBind (GHC.L _ _) (GHC.MG (GHC.L _ matches) _ _ _) _ _ _) = do
#endif
       let
         fds = map hsFDsFromInsideRdr' matches
         -- error (show $ nameToString n)
       return (FN $ nub (concat $ map (fn . fst) fds), DN $ nub (concat $ map (dn . snd) fds))

     decl ((GHC.PatBind p rhs _ _ _) :: GHC.HsBind GHC.RdrName) = do
       let
         (FN pf, DN pd) = hsFreeAndDeclaredRdr nm p
         (FN rf, DN rd) = hsFreeAndDeclaredRdr nm rhs
       return
           (FN $ nub (pf `union` (rf \\ pd)),
            DN $ nub (pd `union` rd))

     decl ((GHC.VarBind p rhs _) :: GHC.HsBind GHC.RdrName) = do
       let
         (FN pf, DN pd) = hsFreeAndDeclaredRdr nm p
         (FN rf, DN rd) = hsFreeAndDeclaredRdr nm rhs
       return
           (FN $ nub (pf `union` (rf \\ pd)),
            DN $ nub (pd `union` rd))

     decl _ = mzero

     -- ----------------------

     expr ((GHC.HsLet decls e) :: GHC.HsExpr GHC.RdrName) = do
       let
         (FN df,DN dd) = hsFreeAndDeclaredRdr nm decls
         (FN ef,_)     = hsFreeAndDeclaredRdr nm e
       return (FN $ nub (df `union` (ef \\ dd)), DN $ nub dd)

     expr ((GHC.HsLam (GHC.MG matches _ _ _)) :: GHC.HsExpr GHC.RdrName) =
       return $ hsFreeAndDeclaredRdr nm matches

     expr ((GHC.HsCase e (GHC.MG matches _ _ _)) :: GHC.HsExpr GHC.RdrName) = do
       let
         (FN ef,_)     = hsFreeAndDeclaredRdr nm e
         (FN df,DN dd) = hsFreeAndDeclaredRdr nm matches
       return (FN $ nub (df `union` (ef \\ dd)), DN $ nub dd)

     expr _ = return (FN [],DN [])

#if __GLASGOW_HASKELL__ <= 710
     stmts ((GHC.BindStmt pat e1 e2 e3) :: GHC.Stmt GHC.RdrName (GHC.LHsExpr GHC.RdrName)) = do
#else
     stmts ((GHC.BindStmt pat e1 e2 e3 _) :: GHC.Stmt GHC.RdrName (GHC.LHsExpr GHC.RdrName)) = do
#endif
       let
         (FN pf,DN pd)  = hsFreeAndDeclaredRdr nm pat
         (FN ef,DN _ed) = hsFreeAndDeclaredRdr nm e1
         (FN df,DN dd)  = hsFreeAndDeclaredRdr nm [e2,e3]
       return
           (FN $ nub (pf `union` (((ef \\ dd) `union` df) \\ pd)), DN $ nub (pd `union` dd))

     stmts ((GHC.LetStmt binds) :: GHC.Stmt GHC.RdrName (GHC.LHsExpr GHC.RdrName)) =
       return $ hsFreeAndDeclaredRdr nm binds

     stmts _ = return (FN [],DN [])


-- ---------------------------------------------------------------------

-- | The same as `hsFDsFromInside` except that the returned variables
-- are in the String format
hsFDNamesFromInsideRdr ::(SYB.Data t) => t -> RefactGhc ([String],[String])
hsFDNamesFromInsideRdr t = do
  nm <- getRefactNameMap
  return (hsFDNamesFromInsideRdrPure nm t)
  -- (FN f,DN d) <- hsFDsFromInsideRdr nm t
  -- return ((nub.map showGhc) f, (nub.map showGhc) d)

-- | The same as `hsFDsFromInside` except that the returned variables
-- are in the String format
hsFDNamesFromInsideRdrPure :: (SYB.Data t) => NameMap -> t -> ([String],[String])
hsFDNamesFromInsideRdrPure nm t = ((nub.map showGhc) f, (nub.map showGhc) d)
  where
    (FN f,DN d) = hsFDsFromInsideRdr nm t

-- ---------------------------------------------------------------------

rdrName2Name :: GHC.Located GHC.RdrName -> RefactGhc GHC.Name
rdrName2Name ln = do
  nameMap <- getRefactNameMap
  return (rdrName2NamePure nameMap ln)

rdrName2NamePure :: NameMap -> GHC.Located GHC.RdrName -> GHC.Name
rdrName2NamePure _nameMap (GHC.L _ (GHC.Exact n)) = n
rdrName2NamePure nameMap (GHC.L lrn _) =
  fromMaybe (error $ "rdrName2NamePure: no name found for" ++ showGhc lrn)
  -- fromMaybe (error $ "rdrName2NamePure: no name found for (lrn,e,nameMap)=" ++ showGhc (lrn,e,nameMap))
             (Map.lookup lrn nameMap)

eqRdrNamePure :: NameMap -> GHC.Located GHC.RdrName -> GHC.Name -> Bool
eqRdrNamePure nameMap rn n
  = GHC.nameUnique (rdrName2NamePure nameMap rn) == GHC.nameUnique n

-- ---------------------------------------------------------------------

-- |Find the identifier(in GHC.Name format) whose start position is
-- (row,col) in the file specified by the fileName, and returns
-- `Nothing` if such an identifier does not exist.
locToNameRdr :: (SYB.Data t)
                     => SimpPos          -- ^ The row and column number
                     -> t                -- ^ The syntax phrase, parameterised by RdrName
                     -> RefactGhc (Maybe GHC.Name)  -- ^ The result
locToNameRdr pos t = do
   nm <- getRefactNameMap
   let mn = locToRdrName pos t
   return $ fmap (rdrName2NamePure nm) mn

-- |Find the identifier(in GHC.Name format) whose start position is
-- (row,col) in the file specified by the fileName, and returns
-- `Nothing` if such an identifier does not exist.
locToNameRdrPure :: (SYB.Data t)
                    => NameMap
                    -> SimpPos         -- ^ The row and column number
                    -> t               -- ^ The syntax phrase, parameterised by RdrName
                    -> Maybe GHC.Name  -- ^ The result
locToNameRdrPure nm pos t =
  let mn = locToRdrName pos t
  in fmap (rdrName2NamePure nm) mn

-- |Find the identifier(in GHC.RdrName format) whose start position is
-- (row,col) in the file specified by the fileName, and returns
-- `Nothing` if such an identifier does not exist.
locToRdrName::(SYB.Data t)
                    =>SimpPos          -- ^ The row and column number
                    ->t                -- ^ The syntax phrase
                    -> Maybe (GHC.Located GHC.RdrName)  -- ^ The result
locToRdrName (row,col) t = locToName' (row,col) t


-- |Worker for both locToName and locToRdrName.
-- NOTE: provides for FunBind MatchGroups where only the first name is
-- retained in the AST

locToName':: forall a t.(SYB.Data t, SYB.Data a)
                    =>SimpPos          -- ^ The row and column number
                    ->t                -- ^ The syntax phrase
                    -> Maybe (GHC.Located a)  -- ^ The result
locToName' (row,col) t = res1
     where
        res1 :: Maybe (GHC.Located a)
        res1 = SYB.something (nameSybQuery checker) t

        checker pnt =
          -- trace ("locToName':pnt=" ++ show (GHC.getLoc pnt)) $
          if inScope pnt
             then Just pnt
             else Nothing

        -- ++AZ++:TODO: Is inScope actually required?
        inScope :: GHC.Located e -> Bool
        inScope (GHC.L l _) =
          case l of
            (GHC.UnhelpfulSpan _) -> False
            (GHC.RealSrcSpan ss)  ->
              -- (GHC.srcSpanFile ss == fileName) &&
              (GHC.srcSpanStartLine ss <= row) &&
              (GHC.srcSpanEndLine ss   >= row) &&
              (col >= (GHC.srcSpanStartCol ss)) &&
              (col <= (GHC.srcSpanEndCol   ss))

-- EOF
