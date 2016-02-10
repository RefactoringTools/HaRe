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
  , isDeclaredIn,isDeclaredInRdr
  , FreeNames(..),DeclaredNames(..)
  , hsFreeAndDeclaredPNsOld
  , hsFreeAndDeclaredRdr
  , hsFreeAndDeclaredNameStrings
  , hsFreeAndDeclaredPNs
  , hsFreeAndDeclaredGhc
  , getDeclaredTypes
  , getDeclaredTypesRdr
  , getFvs, getFreeVars, getDeclaredVars
  , hsVisiblePNs, hsVisiblePNsRdr, hsVisibleNames, hsVisibleNamesRdr
  , hsFDsFromInsideRdr, hsFDNamesFromInsideRdr, hsFDNamesFromInsideRdrPure
  , hsFDsFromInside, hsFDNamesFromInside
  , hsVisibleDs, hsVisibleDsRdr
  , rdrName2Name, rdrName2NamePure
  , eqRdrNamePure
  , rdrName2Name'

  -- ** Identifiers, expressions, patterns and declarations
  , FindEntity(..)
  , sameOccurrence
  , definedPNs, definedPNsRdr,definedNamesRdr
  , definingDeclsRdrNames,definingDeclsRdrNames',definingSigsRdrNames
  , definingDeclsNames, definingDeclsNames', definingSigsNames
  , definingTyClDeclsNames
  , defines
  , definesRdr,definesDeclRdr
  , definesTypeSig,definesTypeSigRdr,definesSigDRdr
  , definesP
  , allNames

  , hsTypeVbls
  , hsPNs, hsNamess, hsNamessRdr
  , findLRdrName
  , locToName, locToRdrName
  ) where

import Control.Monad.State
import Data.List
import Data.Maybe
import Data.Monoid

import Language.Haskell.Refact.Utils.Binds
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.Types

import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Utils


-- Modules from GHC
import qualified Bag           as GHC
import qualified GHC           as GHC
import qualified Name          as GHC
import qualified NameSet       as GHC
import qualified Outputable    as GHC
import qualified RdrName       as GHC
import qualified UniqSet       as GHC

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
{-
-- This is not precise enough, RdrNames are ambiguous
instance FindEntity GHC.RdrName where

  findEntity n t = fromMaybe False res
   where
    res = SYB.something (Nothing `SYB.mkQ` worker) t

    worker (name::GHC.RdrName)
      | n == name = Just True
    worker _ = Nothing
-}
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
-- | Collect the identifiers (in PName format) in a given syntax phrase.

-- TODO:AZ pretty sure this is not doing what we want
hsPNs::(SYB.Data t)=> t -> [PName]
hsPNs t = (nub.ghead "hsPNs") res
  where
     res = SYB.everythingStaged SYB.Parser (++) [] ([] `SYB.mkQ` inPnt) t

     inPnt (pname :: GHC.RdrName) = return [(PN pname)]

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
-- ++AZ++ see if we can get away with one only..
isDeclaredIn :: (HsValBinds t GHC.Name) => GHC.Name -> t -> Bool
isDeclaredIn name t = nonEmptyList $ definingDeclsNames [name] (hsBinds t) False True

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
                                                      `adhocTU` pattern
                                                      `adhocTU` binds
                                                      `adhocTU` bindList
                                                      `adhocTU` match
                                                      `adhocTU` stmts
                                                      `adhocTU` rhs
                                                      `adhocTU` ltydecl
                                                       )) t

          -- expr --
          expr (GHC.L l (GHC.HsVar n))
            = return (FN [rdrName2NamePure nm (GHC.L l n)],DN [])

          expr (GHC.L _ (GHC.OpApp e1 (GHC.L l (GHC.HsVar n)) _ e2)) = do
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

          expr (GHC.L _ (GHC.RecordCon ln _ e)) = do
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
          pattern (GHC.L _ (GHC.AsPat ln pat)) = do
            let (f,DN d) = fromMaybe mempty $ hsFreeAndDeclaredRdr' nm pat
            return (f,DN (rdrName2NamePure nm ln:d))

          pattern (GHC.L l (GHC.VarPat n))
            = return (FN [],DN [rdrName2NamePure nm (GHC.L l n)])
          -- It seems all the GHC pattern match syntax elements end up
          -- with GHC.VarPat

          pattern _ = mzero
          -- pattern _ = return ([],[])

          bindList (ds :: [GHC.LHsBind GHC.RdrName])
            =do (FN f,DN d) <- hsFreeAndDeclaredList ds
                return (FN (f\\d),DN d)
          -- bindList _ = mzero

          -- match and patBind, same type--
          binds ((GHC.FunBind ln _ (GHC.MG matches _ _ _) _ _fvs _) :: GHC.HsBind GHC.RdrName)
            = do
                (FN pf,_pd) <- hsFreeAndDeclaredRdr' nm matches
                let n = rdrName2NamePure nm ln
                return (FN (pf \\ [n]) ,DN [n])

          -- patBind --
          binds (GHC.PatBind pat prhs _ _ds _) =
            do
              (FN pf,DN pd) <- hsFreeAndDeclaredRdr' nm pat
              (FN rf,DN rd) <- hsFreeAndDeclaredRdr' nm prhs
              return (FN $ pf `union` (rf \\ pd),DN $ pd ++ rd)

          binds _ = mzero

          match ((GHC.Match _fn pats _mtype mrhs) :: GHC.Match GHC.RdrName (GHC.LHsExpr GHC.RdrName))
            = do
              (FN pf,DN pd) <- hsFreeAndDeclaredRdr' nm pats
              (FN rf,DN rd) <- hsFreeAndDeclaredRdr' nm mrhs
              return (FN (pf `union` (rf \\ (pd `union` rd))),DN [])

          -- stmts --
          stmts ((GHC.BindStmt pat expre _bindOp _failOp) :: GHC.Stmt GHC.RdrName (GHC.LHsExpr GHC.RdrName)) = do
            -- TODO ++AZ++ : Not sure it is meaningful to pull
            --               anything out of bindOp/failOp
            (FN pf,DN pd)  <- hsFreeAndDeclaredRdr' nm pat
            (FN ef,_ed) <- hsFreeAndDeclaredRdr' nm expre
            let sf1 = []
            return (FN $ pf `union` ef `union` (sf1\\pd),DN []) -- pd) -- Check this

          stmts ((GHC.LetStmt binds') :: GHC.Stmt GHC.RdrName (GHC.LHsExpr GHC.RdrName)) =
            hsFreeAndDeclaredRdr' nm binds'

          stmts _ = mzero

          -- tycldecls -----------------

          ltydecl :: GHC.LTyClDecl GHC.RdrName -> Maybe (FreeNames,DeclaredNames)

          ltydecl (GHC.L _ (GHC.FamDecl fd)) = hsFreeAndDeclaredRdr' nm fd
          ltydecl (GHC.L _ (GHC.SynDecl ln _bndrs _rhs _fvs))
              = return (FN [],DN [rdrName2NamePure nm ln])
          ltydecl (GHC.L _ (GHC.DataDecl ln _bndrs defn _fvs)) = do
              let dds = map (rdrName2NamePure nm) $ concatMap (GHC.con_names . GHC.unLoc) $ GHC.dd_cons defn
              return (FN [],DN (rdrName2NamePure nm ln:dds))
          ltydecl (GHC.L _ (GHC.ClassDecl _ctx ln _tyvars
                           _fds _sigs meths ats atds _docs _fvs)) = do
             (_,md) <- hsFreeAndDeclaredRdr' nm meths
             (_,ad) <- hsFreeAndDeclaredRdr' nm ats
             (_,atd) <- hsFreeAndDeclaredRdr' nm atds
             return (FN [],DN [rdrName2NamePure nm ln] <> md <> ad <> atd)

          ------------------------------

          addFree :: GHC.Name -> (FreeNames,DeclaredNames)
                  -> Maybe (FreeNames,DeclaredNames)
          addFree free (FN fr,de) = return (FN $ [free] `union` fr, de)

          hsFreeAndDeclaredList :: (SYB.Data t) => [t] -> Maybe (FreeNames,DeclaredNames)
          hsFreeAndDeclaredList l = do
            fds <- mapM (hsFreeAndDeclaredRdr' nm) l
            let
              unionF (FN a) (FN b) = FN (a `union` b)
              unionD (DN a) (DN b) = DN (a `union` b)
            return (foldr unionF mempty (map fst fds),
                    foldr unionD mempty (map snd fds))


-- ---------------------------------------------------------------------
-- | Collect the free and declared variables (in the GHC.Name format)
-- in a given syntax phrase t. In the result, the first list contains
-- the free variables, and the second list contains the declared
-- variables.
-- Expects RenamedSource
hsFreeAndDeclaredPNsOld:: (SYB.Data t) => t -> ([GHC.Name],[GHC.Name])
hsFreeAndDeclaredPNsOld t = res
  where
    fd = hsFreeAndDeclaredPNs' t
    (f,d) = fromMaybe ([],[]) fd
    res = (f \\ d, d)

hsFreeAndDeclaredPNs':: (SYB.Data t) => t -> Maybe ([GHC.Name],[GHC.Name])
hsFreeAndDeclaredPNs' t = do
      (f,d) <- hsFreeAndDeclared'
      let (f',d') = (nub f, nub d)
      -- return (f' \\ d',d')
      return (f',d')
          -- hsFreeAndDeclared'=applyTU (stop_tdTU (failTU  `adhocTU` exp

   where

          hsFreeAndDeclared' = applyTU (stop_tdTU (failTU
                                                      `adhocTU` expr
                                                      `adhocTU` pattern
                                                      `adhocTU` binds
                                                      `adhocTU` bindList
                                                      `adhocTU` match
                                                      `adhocTU` stmts
                                                      `adhocTU` rhs
                                                       )) t

          -- expr --
          expr (GHC.HsVar n) = return ([n],[])

          expr (GHC.OpApp e1 (GHC.L _ (GHC.HsVar n)) _ e2) = do
              efed <- hsFreeAndDeclaredPNs' [e1,e2]
              fd   <- addFree n efed
              return fd

          expr ((GHC.HsLam (GHC.MG matches _ _ _)) :: GHC.HsExpr GHC.Name) =
             hsFreeAndDeclaredPNs' matches

          expr ((GHC.HsLet decls e) :: GHC.HsExpr GHC.Name) =
            do
              (df,dd) <- hsFreeAndDeclaredPNs' decls
              (ef,_)  <- hsFreeAndDeclaredPNs' e
              return ((df `union` (ef \\ dd)),[])

          expr (GHC.RecordCon (GHC.L _ n) _ e) = do
            fd <- (hsFreeAndDeclaredPNs' e)
            addFree n fd   --Need Testing

          expr (GHC.EAsPat (GHC.L _ n) e) = do
            fd <- (hsFreeAndDeclaredPNs' e)
            addFree n fd

          expr _ = mzero


          -- rhs --
          rhs ((GHC.GRHSs g ds) :: GHC.GRHSs GHC.Name (GHC.LHsExpr GHC.Name))
            = do (df,dd) <- hsFreeAndDeclaredPNs' g
                 (ef,ed) <- hsFreeAndDeclaredPNs' ds
                 return (df ++ ef, dd ++ ed)


          -- pat --
          pattern (GHC.AsPat (GHC.L _ n) pat) = do
            (f,d) <- hsFreeAndDeclaredPNs' pat
            return (f,n:d)

          pattern (GHC.VarPat n) = return ([],[n])
          -- It seems all the GHC pattern match syntax elements end up
          -- with GHC.VarPat

          pattern _ = mzero
          -- pattern _ = return ([],[])

          bindList (ds :: [GHC.LHsBind GHC.Name])
            =do (f,d) <- hsFreeAndDeclaredList ds
                return (f\\d,d)
          -- bindList _ = mzero

          -- match and patBind, same type--
          binds ((GHC.FunBind (GHC.L _ n) _ (GHC.MG matches _ _ _) _ _fvs _) :: GHC.HsBind GHC.Name)
            = do
                (pf,_pd) <- hsFreeAndDeclaredPNs' matches

                return (pf \\ [n] ,[n])

          -- patBind --
          binds (GHC.PatBind pat prhs _ ds _) =
            do
              (pf,pd) <- hsFreeAndDeclaredPNs' pat
              (rf,rd) <- hsFreeAndDeclaredPNs' prhs
              return (pf `union` (rf \\pd),pd ++ GHC.uniqSetToList ds ++ rd)

          binds _ = mzero

          match ((GHC.Match _fn pats _mtype mrhs) :: GHC.Match GHC.Name (GHC.LHsExpr GHC.Name))
            = do
              (pf,pd) <- hsFreeAndDeclaredPNs' pats
              (rf,rd) <- hsFreeAndDeclaredPNs' mrhs
              return ((pf `union` (rf \\ (pd `union` rd))),[])

          -- stmts --
          stmts ((GHC.BindStmt pat expre _bindOp _failOp) :: GHC.Stmt GHC.Name (GHC.LHsExpr GHC.Name)) = do
            -- TODO ++AZ++ : Not sure it is meaningful to pull
            --               anything out of bindOp/failOp
            (pf,pd)  <- hsFreeAndDeclaredPNs' pat
            (ef,_ed) <- hsFreeAndDeclaredPNs' expre
            let sf1 = []
            return (pf `union` ef `union` (sf1\\pd),[]) -- pd) -- Check this

          stmts ((GHC.LetStmt binds') :: GHC.Stmt GHC.Name (GHC.LHsExpr GHC.Name)) =
            hsFreeAndDeclaredPNs' binds'

          stmts _ = mzero


          addFree :: GHC.Name -> ([GHC.Name],[GHC.Name])
                  -> Maybe ([GHC.Name],[GHC.Name])
          addFree free (fr,de) = return ([free] `union` fr, de)

          hsFreeAndDeclaredList l=do fds<-mapM hsFreeAndDeclaredPNs' l
                                     return (foldr union [] (map fst fds),
                                             foldr union [] (map snd fds))



-- |The same as `hsFreeAndDeclaredPNs` except that the returned
-- variables are in the String format.
hsFreeAndDeclaredNameStrings::(SYB.Data t,GHC.Outputable t)
  => t -> RefactGhc ([String],[String])
hsFreeAndDeclaredNameStrings t = do
  (f1,d1) <- hsFreeAndDeclaredPNs t
  return ((nub.map showGhc) f1, (nub.map showGhc) d1)


hsFreeAndDeclaredPNs :: (SYB.Data t) => t -> RefactGhc ([GHC.Name],[GHC.Name])
hsFreeAndDeclaredPNs t = do
  -- logm $ "hsFreeAndDeclaredPNs:t=" ++ (showGhc t)
  (FN f,DN d) <- hsFreeAndDeclaredGhc t
  return (f,d)

-- ---------------------------------------------------------------------

-- | Collect the free and declared variables (in the GHC.Name format)
-- in a given syntax phrase t. In the result, the first list contains
-- the free variables, and the second list contains the declared
-- variables.
-- TODO: use GHC.NameSet instead of lists for FreeNames/DeclaredNames
-- NOTE: The GHC fvs fields only carry non-GHC values, as they are
-- used in the renaming process
-- hsFreeAndDeclaredGhc :: (SYB.Data t,GHC.Outputable t)
hsFreeAndDeclaredGhc :: (SYB.Data t)
                     => t -> RefactGhc (FreeNames,DeclaredNames)
hsFreeAndDeclaredGhc t = do
  -- logm $ "hsFreeAndDeclaredGhc:t=" ++ showGhc t
  -- logm $ "hsFreeAndDeclaredGhc:t=" ++ SYB.showData SYB.Renamer 0 t
  (FN f,DN d) <- res
  let f' = nub f
  let d' = nub d
  -- logm $ "hsFreeAndDeclaredGhc:res=" ++ showGhc (f',d')
  return (FN (f' \\ d'), DN d')

  where
    res = (const err
          `SYB.extQ` renamed
          `SYB.extQ` lhsbind
          `SYB.extQ` hsbind
          `SYB.extQ` lhsbinds
          `SYB.extQ` lhsbindslrs
          `SYB.extQ` lhsbindslr
          `SYB.extQ` hslocalbinds
          `SYB.extQ` hsvalbinds
          `SYB.extQ` lpats
          `SYB.extQ` lpat
          `SYB.extQ` bndrs
          `SYB.extQ` ltydecls
          `SYB.extQ` ltydecl
          -- `SYB.extQ` lfaminstdecls
          -- `SYB.extQ` lfaminstdecl
          `SYB.extQ` lsigs
          `SYB.extQ` lsig
          `SYB.extQ` lexprs
          `SYB.extQ` lexpr
          `SYB.extQ` expr
          `SYB.extQ` name
          `SYB.extQ` lstmts
          `SYB.extQ` lstmt
          `SYB.extQ` lhstype
          `SYB.extQ` hstype
          `SYB.extQ` grhs_s
          `SYB.extQ` grhs
          `SYB.extQ` grhsss
          `SYB.extQ` grhss
          `SYB.extQ` matchgroup
          `SYB.extQ` lmatches
          `SYB.extQ` lmatch
          `SYB.extQ` hsrecordbinds
          `SYB.extQ` hsrecordbind
          ) t

    -- -----------------------

    renamed :: GHC.RenamedSource ->  RefactGhc (FreeNames,DeclaredNames)
    renamed (g,_i,_e,_d) = do
      (FN gf,DN gd) <- hsFreeAndDeclaredGhc $ GHC.hs_valds g
      let tds = concatMap getDeclaredTypes $ concatMap GHC.group_tyclds (GHC.hs_tyclds g)
      logm $ "hsFreeAndDeclaredGhc.renamed:(gf,gd,tds)=" ++ showGhc (gf,gd,tds)
      -- return $ gfds <> (FN [],DN tds)
      return $ (FN (gf \\ tds), DN (gd++tds))

    -- -----------------------

    lhsbinds :: [GHC.LHsBind GHC.Name] -> RefactGhc (FreeNames,DeclaredNames)
    lhsbinds bs = do
      (FN f,DN d) <- recurseList bs
      let r = (FN (f \\ d),DN d)
      -- logm $ "hsFreeAndDeclaredGhc.hsbinds:r=" ++ (show r)
      return r

    lhsbind :: GHC.LHsBind GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    lhsbind (GHC.L _ b) = hsFreeAndDeclaredGhc b

    -- -----------------------

    hsbind :: GHC.HsBind GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    hsbind b@(GHC.FunBind _n _ (GHC.MG matches _ _ _) _ _ _) = do
        -- logm $ "hsFreeAndDeclaredGhc.hsbind:b=" ++ (showGhc b)
        let d = GHC.collectHsBindBinders b
        (fp,_dp) <- hsFreeAndDeclaredGhc matches
        -- logm $ "hsFreeAndDeclaredGhc.hsbind:(fp,_dp)=" ++ (show (fp,_dp))
        -- logm $ "hsFreeAndDeclaredGhc.hsbind:(d)=" ++ (showGhc (d))
        let r = (fp,DN []) <> (FN [],DN d)
        -- logm $ "hsFreeAndDeclaredGhc.hsbind:r=" ++ (show (r))
        return $ r
    hsbind b@(GHC.PatBind pa rhs _ _ _) = do
        -- logm $ "hsFreeAndDeclaredGhc.hsbind.PatBind:b=" ++ (showGhc b)
        let d = GHC.collectHsBindBinders b
        (FN fr,DN _dr) <- hsFreeAndDeclaredGhc rhs
        (fp,_) <- lpat pa
        -- logm $ "hsFreeAndDeclaredGhc.hsbind.PatBind:f=" ++ (showGhc fr)
        return $ (fp,DN []) <> (FN fr,DN d)
    hsbind b = do
        -- logm $ "hsFreeAndDeclaredGhc.hsbind:b=" ++ (showGhc b)
        let d = GHC.collectHsBindBinders b
        return (FN [],DN d)

    -- -----------------------

    lhsbindslrs :: [GHC.LHsBindsLR GHC.Name GHC.Name] -> RefactGhc (FreeNames,DeclaredNames)
    lhsbindslrs bs = recurseList bs

    -- -----------------------

    lhsbindslr :: GHC.LHsBindsLR GHC.Name GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    lhsbindslr bs = do
      hsFreeAndDeclaredGhc $ GHC.bagToList bs

    hslocalbinds :: GHC.HsLocalBinds GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    hslocalbinds (GHC.HsValBinds binds) = hsFreeAndDeclaredGhc binds
    hslocalbinds (GHC.HsIPBinds binds)  = hsFreeAndDeclaredGhc binds
    hslocalbinds GHC.EmptyLocalBinds    = return emptyFD


    hsvalbinds :: GHC.HsValBinds GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    hsvalbinds (GHC.ValBindsIn binds sigs) = do
      bfds <- hsFreeAndDeclaredGhc binds
      sfds <- hsFreeAndDeclaredGhc sigs
      return $ bfds <> sfds
    hsvalbinds (GHC.ValBindsOut binds sigs) = do
      bfds <- hsFreeAndDeclaredGhc $ map snd binds
      sfds <- hsFreeAndDeclaredGhc sigs
      return $ bfds <> sfds

    -- -----------------------

    lpats :: [GHC.LPat GHC.Name] -> RefactGhc (FreeNames,DeclaredNames)
    lpats xs = recurseList xs

    -- -----------------------

    lpat :: GHC.LPat GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    lpat lp@(GHC.L _ p) = do
      -- logm $ "hsFreeAndDeclaredGhc.lpat:" ++ (showGhc lp)
      let
        d = GHC.collectPatBinders lp

      (FN f,DN _dn) <- pat p
      -- logm $ "hsFreeAndDeclaredGhc.lpat:(fn,dn)=" ++ (showGhc (fn,dn))
      return (FN f,DN d)

    pat :: GHC.Pat GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    pat (GHC.WildPat _) = return emptyFD
    pat (GHC.VarPat n) = return (FN [],DN [n])
    pat (GHC.LazyPat (GHC.L _ p)) = pat p
    pat (GHC.AsPat (GHC.L _ n) (GHC.L _ p)) = do
      fd <- pat p
      return $ (FN [], DN [n]) <> fd
    pat (GHC.ParPat (GHC.L _ p)) = pat p
    pat (GHC.BangPat (GHC.L _ p)) = pat p
    pat (GHC.ListPat ps _ _) = do
      fds <- mapM pat $ map GHC.unLoc ps
      return $ mconcat fds
    pat (GHC.TuplePat ps _ _) = do
      fds <- mapM pat $ map GHC.unLoc ps
      return $ mconcat fds
    pat (GHC.PArrPat ps _) = do
      fds <- mapM pat $ map GHC.unLoc ps
      return $ mconcat fds
    pat (GHC.ConPatIn (GHC.L _ n) det) = do
      -- logm $ "hsFreeAndDeclaredGhc.pat.ConPatIn:details=" ++ (SYB.showData SYB.Renamer 0 det)
      (FN f,DN _d) <- details det
      return $ (FN [n],DN []) <> (FN [],DN f)
    -- pat (GHC.ConPatOut )
    pat (GHC.ViewPat e (GHC.L _ p) _) = do
      fde <- hsFreeAndDeclaredGhc e
      fdp <- pat p
      return $ fde <> fdp
    -- pat (GHC.QuasiQuotePat _)
    pat (GHC.LitPat _) = return emptyFD
    pat (GHC.NPat _ _ _) = return emptyFD
    pat (GHC.NPlusKPat (GHC.L _ n) _ _ _) = return (FN [],DN [n])
    pat _p@(GHC.SigPatIn (GHC.L _ p) b) = do
      fdp <- pat p
      (FN fb,DN _db) <- hsFreeAndDeclaredGhc b
      return $ fdp <> (FN fb,DN [])
    pat (GHC.SigPatOut (GHC.L _ p) _) = pat p
    pat (GHC.CoPat _ p _) = pat p

    pat p = error $ "hsFreeAndDeclaredGhc.pat:unimplemented:" ++ (showGhc p)

    details :: GHC.HsConPatDetails GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    details (GHC.PrefixCon  args) = do
      -- logm $ "hsFreeAndDeclaredGhc.details:args=" ++ (showGhc args)
      fds <- mapM pat $ map GHC.unLoc args
      return $ mconcat fds
    details (GHC.RecCon recf) =
      recfields recf
    details (GHC.InfixCon arg1 arg2) = do
      fds <- mapM pat $ map GHC.unLoc [arg1,arg2]
      return $ mconcat fds

    -- Note: this one applies to HsRecFields in LPats
    recfields :: (GHC.HsRecFields GHC.Name (GHC.LPat GHC.Name)) -> RefactGhc (FreeNames,DeclaredNames)
    recfields (GHC.HsRecFields fields _) = do
      let args = map (\(GHC.L _ (GHC.HsRecField _ (GHC.L _ arg) _)) -> arg) fields
      fds <- mapM pat args
      return $ mconcat fds

    -- -----------------------

    bndrs :: GHC.HsWithBndrs GHC.Name (GHC.LHsType GHC.Name) -> RefactGhc (FreeNames,DeclaredNames)
    bndrs (GHC.HsWB (GHC.L _ thing) _ _ _) = do
      (_ft,DN dt) <- hsFreeAndDeclaredGhc thing
      -- logm $ "hsFreeAndDeclaredGhc.bndrs (_ft,dt)=" ++ show (_ft,DN dt)
      return (FN dt,DN [])
    -- -----------------------

    ltydecls :: [GHC.LTyClDecl GHC.Name] -> RefactGhc (FreeNames,DeclaredNames)
    ltydecls ds = do
      fds <- mapM hsFreeAndDeclaredGhc ds
      return $ mconcat fds

    ltydecl :: GHC.LTyClDecl GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    -- ltydecl (GHC.L _ (GHC.ForeignType (GHC.L _ n) _)) = return (FN [],DN [n])

    -- ltydecl (GHC.L _ (GHC.TyFamily _ (GHC.L _ n) _bndrs _)) = return (FN [],DN [n])
    ltydecl (GHC.L _ (GHC.FamDecl fd)) = hsFreeAndDeclaredGhc fd
    ltydecl (GHC.L _ (GHC.SynDecl (GHC.L _ n) _bndrs _rhs fvs))
        = return (FN (GHC.nameSetElems fvs),DN [n])
    ltydecl (GHC.L _ (GHC.DataDecl (GHC.L _ n) _bndrs defn fvs)) = do
        let dds = map GHC.unLoc $ concatMap (GHC.con_names . GHC.unLoc) $ GHC.dd_cons defn
        logm $ "hsFreeAndDeclaredGhc.ltydecl:(n,dds)" ++ showGhc (n,dds)
        return (FN (GHC.nameSetElems fvs),DN (n:dds))
    ltydecl (GHC.L _ (GHC.ClassDecl _ctx (GHC.L _ n) _tyvars
                     _fds _sigs meths ats atds _docs fvs)) = do
       -- logm $ "hsFreeAndDeclaredGhc.ltydecl.ClassDecl.meths"
       (_,md) <- hsFreeAndDeclaredGhc meths
       -- logm $ "hsFreeAndDeclaredGhc.ltydecl.ClassDecl.ats"
       (_,ad) <- hsFreeAndDeclaredGhc ats
       -- logm $ "hsFreeAndDeclaredGhc.ltydecl.ClassDecl.atds"
       (_,atd) <- hsFreeAndDeclaredGhc atds
       -- logm $ "hsFreeAndDeclaredGhc.ltydecl.ClassDecl.done"
       return (FN (GHC.nameSetElems fvs),DN [n] <> md <> ad <> atd)
{-
FamDecl -- type/data family T :: *->*
  tcdFam :: FamilyDecl name

SynDecl  -- type declaration
  tcdLName :: Located name
  tcdTyVars :: LHsTyVarBndrs name
  tcdRhs :: LHsType name
  tcdFVs :: PostRn name NameSet

DataDecl
  tcdLName :: Located name
  tcdTyVars :: LHsTyVarBndrs name
  tcdDataDefn :: HsDataDefn name
  tcdFVs :: PostRn name NameSet

ClassDecl
  tcdCtxt :: LHsContext name
  tcdLName :: Located name
  tcdTyVars :: LHsTyVarBndrs name
  tcdFDs :: [Located (FunDep (Located name))]
  tcdSigs :: [LSig name]
  tcdMeths :: LHsBinds name
  tcdATs :: [LFamilyDecl name]
  tcdATDefs :: [LTyFamDefltEqn name]
  tcdDocs :: [LDocDecl]
  tcdFVs :: PostRn name NameSet


-}

    -- ---------------------------------
{-
    lfaminstdecls :: [GHC.LFamInstDecl GHC.Name] -> RefactGhc (FreeNames,DeclaredNames)
    lfaminstdecls ds = do
      fds <- mapM hsFreeAndDeclaredGhc ds
      return $ mconcat fds

    lfaminstdecl :: GHC.LFamInstDecl GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    lfaminstdecl _f@(GHC.L _ (GHC.FamInstDecl (GHC.L _ n) _pats _defn fvs)) = do
      -- logm $ "hsFreeAndDeclaredGhc.lfaminstdecl:" ++ showGhc _f
      return (FN (GHC.nameSetElems fvs), DN [n])
-}
    -- -----------------------

    lsigs :: [GHC.LSig GHC.Name] -> RefactGhc (FreeNames,DeclaredNames)
    lsigs ss = do
      fds <- mapM hsFreeAndDeclaredGhc ss
      return $ mconcat fds

    -- -----------------------

    lsig :: GHC.LSig GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    lsig (GHC.L _ (GHC.TypeSig ns typ _)) = do
      tfds <- hsFreeAndDeclaredGhc typ
      return $ (FN [],DN (map GHC.unLoc ns)) <> tfds
    lsig (GHC.L _ (GHC.GenericSig n typ)) = do
      tfds <- hsFreeAndDeclaredGhc typ
      return $ (FN [],DN (map GHC.unLoc n)) <> tfds
    lsig (GHC.L _ (GHC.IdSig _)) = return emptyFD
    lsig (GHC.L _ (GHC.InlineSig _ _)) = return emptyFD
    lsig (GHC.L _ (GHC.SpecSig n typ _)) = do
      tfds <- hsFreeAndDeclaredGhc typ
      return $ (FN [],DN [GHC.unLoc n]) <> tfds
    lsig (GHC.L _ (GHC.SpecInstSig _ _)) = return emptyFD
    lsig (GHC.L _ (GHC.FixSig _)) = return emptyFD
    lsig (GHC.L _ (GHC.PatSynSig _ _ _ _ _)) = error "lsig: PatSynSig: toImplement"
    lsig (GHC.L _ (GHC.MinimalSig _ _)) = error "lsig FixSig: toImplement"

    -- -----------------------

    lexprs :: [GHC.LHsExpr GHC.Name] -> RefactGhc (FreeNames,DeclaredNames)
    lexprs es = recurseList es

    -- -----------------------

    lexpr :: GHC.LHsExpr GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    lexpr (GHC.L _ e) = hsFreeAndDeclaredGhc e

    -- -----------------------

    expr :: GHC.HsExpr GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    expr ((GHC.HsVar n)) = return (FN [n],DN [])

    expr ((GHC.HsIPVar _)) = return emptyFD

    expr ((GHC.HsOverLit _)) = return emptyFD

    expr ((GHC.HsLit _)) = return emptyFD

    expr ((GHC.HsLam mg)) = hsFreeAndDeclaredGhc mg

    expr ((GHC.HsLamCase _ mg)) = hsFreeAndDeclaredGhc mg

    expr ((GHC.HsApp e1 e2)) = do
      fde1 <- hsFreeAndDeclaredGhc e1
      fde2 <- hsFreeAndDeclaredGhc e2
      return $ fde1 <> fde2

    expr ((GHC.OpApp e1 eop _fix e2)) = do
      fde1 <- hsFreeAndDeclaredGhc e1
      fdeop <- hsFreeAndDeclaredGhc eop
      fde2 <- hsFreeAndDeclaredGhc e2
      return $ fde1 <> fdeop <> fde2

    expr ((GHC.NegApp e _)) = hsFreeAndDeclaredGhc e

    expr ((GHC.HsPar e)) = hsFreeAndDeclaredGhc e

    expr ((GHC.SectionL e1 e2)) = do
      fde1 <- hsFreeAndDeclaredGhc e1
      fde2 <- hsFreeAndDeclaredGhc e2
      return $ fde1 <> fde2

    expr ((GHC.SectionR e1 e2)) = do
      fde1 <- hsFreeAndDeclaredGhc e1
      fde2 <- hsFreeAndDeclaredGhc e2
      return $ fde1 <> fde2

    expr ((GHC.ExplicitTuple args _boxity)) = do
      let argse = concatMap bb args
          bb (GHC.L _ (GHC.Missing _)) = []
          bb (GHC.L _ (GHC.Present a)) = [a]

      fds <- mapM hsFreeAndDeclaredGhc argse
      return $ mconcat fds

    expr ((GHC.HsCase e body)) = do
       fdes <- hsFreeAndDeclaredGhc e
       fdbs <- hsFreeAndDeclaredGhc body
       return $ fdes <> fdbs

    expr ((GHC.HsIf _ms e1 e2 e3)) = do
      fde1 <- hsFreeAndDeclaredGhc e1
      fde2 <- hsFreeAndDeclaredGhc e2
      fde3 <- hsFreeAndDeclaredGhc e3
      return $ fde1 <> fde2 <> fde3

    expr ((GHC.HsMultiIf _typ rhs))
      = hsFreeAndDeclaredGhc rhs

    expr ((GHC.HsLet binds e)) = do
      fdb <- hsFreeAndDeclaredGhc binds
      fde <- hsFreeAndDeclaredGhc e
      return $ fdb <> fde

    expr ((GHC.HsDo _ctx stmts _typ))
      = hsFreeAndDeclaredGhc stmts

    expr ((GHC.ExplicitList _ _ es))
      = hsFreeAndDeclaredGhc es

    expr ((GHC.ExplicitPArr _typ es))
      = hsFreeAndDeclaredGhc es

    expr ((GHC.RecordCon (GHC.L _ n) _typ binds)) = do
      fdb <- hsFreeAndDeclaredGhc binds
      return $ (FN [],DN [n]) <> fdb

    expr ((GHC.RecordUpd e1 binds _cons _typ1 _typ2)) = do
      fde <- hsFreeAndDeclaredGhc e1
      fdb <- hsFreeAndDeclaredGhc binds
      return $ fde <> fdb

    expr ((GHC.ExprWithTySig e _typ _))
      = hsFreeAndDeclaredGhc e

    expr ((GHC.ExprWithTySigOut e _typ))
      = hsFreeAndDeclaredGhc e

    expr ((GHC.ArithSeq _ _typ as)) = do
      fds <- case as of
        GHC.From e -> hsFreeAndDeclaredGhc e
        GHC.FromThen e1 e2      -> recurseList [e1,e2]
        GHC.FromTo e1 e2        -> recurseList [e1,e2]
        GHC.FromThenTo e1 e2 e3 -> recurseList [e1,e2,e3]
      return fds

    expr ((GHC.PArrSeq _typ as))
      = hsFreeAndDeclaredGhc as

    expr ((GHC.HsSCC _ _ e))
      = hsFreeAndDeclaredGhc e

    expr ((GHC.HsCoreAnn _ _ e))
      = hsFreeAndDeclaredGhc e

    expr ((GHC.HsBracket (GHC.ExpBr b)))
      = hsFreeAndDeclaredGhc b
    expr ((GHC.HsBracket (GHC.PatBr b)))
      = hsFreeAndDeclaredGhc b
    expr ((GHC.HsBracket (GHC.DecBrL b)))
      = hsFreeAndDeclaredGhc b
    expr ((GHC.HsBracket (GHC.DecBrG b)))
      = hsFreeAndDeclaredGhc b
    expr ((GHC.HsBracket (GHC.TypBr b)))
      = hsFreeAndDeclaredGhc b
    expr ((GHC.HsBracket (GHC.VarBr _ n)))
      = return (FN [],DN [n])
    expr ((GHC.HsBracket (GHC.TExpBr _)))
      = error "expr: GHC.HsBracket (GHC.TExpBr), to implement"

    expr ((GHC.HsRnBracketOut b _ps))
      = hsFreeAndDeclaredGhc b

    expr ((GHC.HsTcBracketOut b _ps))
      = hsFreeAndDeclaredGhc b

    expr ((GHC.HsSpliceE _ (GHC.HsSplice _ e)))
      = hsFreeAndDeclaredGhc e

    expr ((GHC.HsQuasiQuoteE _q))
      = return emptyFD

    expr ((GHC.HsProc pa cmd)) = do
      fdp <- hsFreeAndDeclaredGhc pa
      fdc <- hsFreeAndDeclaredGhc cmd
      return $ fdp <> fdc

    expr ((GHC.HsStatic e)) = hsFreeAndDeclaredGhc e

    expr ((GHC.HsArrApp e1 e2 _typ _atyp _)) = do
      fd1 <- hsFreeAndDeclaredGhc e1
      fd2 <- hsFreeAndDeclaredGhc e2
      return $ fd1 <> fd2

    expr ((GHC.HsArrForm e1 _fix cmds)) = do
      fd1 <- hsFreeAndDeclaredGhc e1
      fdc <- hsFreeAndDeclaredGhc cmds
      return $ fd1 <> fdc

    expr ((GHC.HsTick _ e))
      = hsFreeAndDeclaredGhc e

    expr ((GHC.HsBinTick _ _ e))
      = hsFreeAndDeclaredGhc e

    expr ((GHC.HsTickPragma _ _ e))
      = hsFreeAndDeclaredGhc e

    expr ((GHC.EWildPat)) = return emptyFD

    expr ((GHC.EAsPat (GHC.L _ n) e)) = do
      fde <- hsFreeAndDeclaredGhc e
      return $ (FN [],DN [n]) <> fde

    expr ((GHC.EViewPat e1 e2)) = do
      fd1 <- hsFreeAndDeclaredGhc e1
      fd2 <- hsFreeAndDeclaredGhc e2
      return $ fd1 <> fd2

    expr ((GHC.ELazyPat e))
      = hsFreeAndDeclaredGhc e

    expr ((GHC.HsType typ))
      = hsFreeAndDeclaredGhc typ

    expr ((GHC.HsWrap _wrap e))
      = hsFreeAndDeclaredGhc e

    expr ((GHC.HsUnboundVar _)) = return emptyFD

    -- -----------------------

    name :: GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    name n = return (FN [],DN [n])

    -- -----------------------
    lstmts :: [GHC.LStmt GHC.Name (GHC.LHsExpr GHC.Name)] -> RefactGhc (FreeNames,DeclaredNames)
    lstmts ss = recurseList ss


    lstmt :: GHC.LStmt GHC.Name (GHC.LHsExpr GHC.Name) -> RefactGhc (FreeNames,DeclaredNames)
    lstmt (GHC.L _ (GHC.LastStmt e _)) = hsFreeAndDeclaredGhc e
    lstmt (GHC.L _ (GHC.BindStmt pa e _ _)) = do
      fdp <- hsFreeAndDeclaredGhc pa
      fde <- hsFreeAndDeclaredGhc e
      return (fdp <> fde)
    lstmt (GHC.L _ (GHC.BodyStmt e _ _ _)) = hsFreeAndDeclaredGhc e
    -- lstmt (GHC.L _ (GHC.ExprStmt e _ _ _)) = hsFreeAndDeclaredGhc e

    lstmt (GHC.L _ (GHC.LetStmt bs)) = hsFreeAndDeclaredGhc bs
    lstmt (GHC.L _ (GHC.ParStmt ps _ _)) = hsFreeAndDeclaredGhc ps
    lstmt (GHC.L _ (GHC.TransStmt _ stmts _ using mby _ _ _)) = do
      fds <- hsFreeAndDeclaredGhc stmts
      fdu <- hsFreeAndDeclaredGhc using
      fdb <- case mby of
        Nothing -> return emptyFD
        Just e -> hsFreeAndDeclaredGhc e
      return $ fds <> fdu <> fdb
    lstmt (GHC.L _ (GHC.RecStmt stmts _ _ _ _ _ _ _ _)) = hsFreeAndDeclaredGhc stmts

    -- -----------------------

    lhstype :: GHC.LHsType GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    lhstype (GHC.L _ typ) = hstype typ

    -- -----------------------

    hstype :: GHC.HsType GHC.Name -> RefactGhc (FreeNames,DeclaredNames)
    hstype (GHC.HsForAllTy _ _ _ _ typ) = hsFreeAndDeclaredGhc typ
    hstype (GHC.HsTyVar n) = return (FN [],DN [n])
    hstype (GHC.HsAppTy t1 t2) = recurseList [t1,t2]
    hstype (GHC.HsFunTy t1 t2) = recurseList [t1,t2]
    hstype (GHC.HsListTy typ) = hsFreeAndDeclaredGhc typ
    hstype (GHC.HsPArrTy typ) = hsFreeAndDeclaredGhc typ
    hstype (GHC.HsTupleTy _ typs) = recurseList typs
    hstype (GHC.HsOpTy t1 _ t2) = recurseList [t1,t2]
    hstype (GHC.HsParTy typ) = hsFreeAndDeclaredGhc typ
    hstype (GHC.HsIParamTy _ typ) = hsFreeAndDeclaredGhc typ
    hstype (GHC.HsEqTy t1 t2) = recurseList [t1,t2]
    hstype (GHC.HsKindSig t1 t2) = recurseList [t1,t2]
    hstype (GHC.HsQuasiQuoteTy _) = return emptyFD
    hstype (GHC.HsSpliceTy _ _) = return (FN [],DN [])
    hstype (GHC.HsDocTy _ typ) = hsFreeAndDeclaredGhc typ
    hstype (GHC.HsBangTy _ typ) = hsFreeAndDeclaredGhc typ
    hstype (GHC.HsRecTy cons) = recurseList cons
    hstype (GHC.HsCoreTy _) = return emptyFD
    hstype (GHC.HsExplicitListTy _ typs) = recurseList typs
    hstype (GHC.HsExplicitTupleTy _ typs) = recurseList typs
    hstype (GHC.HsTyLit _) = return emptyFD
    hstype (GHC.HsWrapTy _ typ) = hsFreeAndDeclaredGhc typ
    hstype (GHC.HsWildcardTy) = error "To implement: hstype, HsWildcardTy"
    hstype (GHC.HsNamedWildcardTy _) = error "To implement: HsNamedWildcardTy"



    -- -----------------------

    grhs_s :: [GHC.LGRHS GHC.Name (GHC.LHsExpr GHC.Name)] -> RefactGhc (FreeNames,DeclaredNames)
    grhs_s gs = recurseList gs

    -- -----------------------

    grhs :: GHC.LGRHS GHC.Name (GHC.LHsExpr GHC.Name) -> RefactGhc (FreeNames,DeclaredNames)
    grhs (GHC.L _ (GHC.GRHS stmts e)) = do
      fds <- hsFreeAndDeclaredGhc stmts
      fde <- hsFreeAndDeclaredGhc e
      return $ fds <> fde

    -- -----------------------

    grhsss :: [GHC.GRHSs GHC.Name (GHC.LHsExpr GHC.Name)] -> RefactGhc (FreeNames,DeclaredNames)
    grhsss gs = recurseList gs

    -- -----------------------

    grhss :: GHC.GRHSs GHC.Name (GHC.LHsExpr GHC.Name) -> RefactGhc (FreeNames,DeclaredNames)
    grhss (GHC.GRHSs g binds) = do
      (fg,_dg) <- hsFreeAndDeclaredGhc g
      fdb <- hsFreeAndDeclaredGhc binds
      return $  (fg,DN[]) <> fdb

    -- -----------------------

    matchgroup :: GHC.MatchGroup GHC.Name (GHC.LHsExpr GHC.Name) -> RefactGhc (FreeNames,DeclaredNames)
    matchgroup (GHC.MG matches _ _ _) = recurseList matches

    -- -----------------------

    lmatches :: [GHC.LMatch GHC.Name (GHC.LHsExpr GHC.Name)] -> RefactGhc (FreeNames,DeclaredNames)
    lmatches ms = recurseList ms

    -- -----------------------

    lmatch :: GHC.LMatch GHC.Name (GHC.LHsExpr GHC.Name) -> RefactGhc (FreeNames,DeclaredNames)
    lmatch (GHC.L _ _m@(GHC.Match _fn pats _ rhs)) = do
      (fp,DN dp) <- recurseList pats
      (FN fr,DN dr) <- hsFreeAndDeclaredGhc rhs
      let r = (fp,DN []) <> (FN (fr \\ (dr ++ dp)), DN [])
      return $ r

    -- -----------------------

    hsrecordbinds :: (GHC.HsRecordBinds GHC.Name) -> RefactGhc (FreeNames,DeclaredNames)
    hsrecordbinds (GHC.HsRecFields fields _) = recurseList fields

    hsrecordbind :: (GHC.HsRecField GHC.Name (GHC.LHsExpr GHC.Name)) -> RefactGhc (FreeNames,DeclaredNames)
    hsrecordbind (GHC.HsRecField (GHC.L _ n) arg _) = do
      fda <- hsFreeAndDeclaredGhc arg
      return $ (FN [n],DN []) <> fda

    -- -----------------------

    err = do
      logm $ "hsFreeAndDeclaredGhc:not matched:"
               ++ show (annGetConstr t) ++ ":"
               ++ (SYB.showData SYB.Renamer 0 t)
      return emptyFD

    -- ---------------------------------

    recurseList xs = do
      fds <- mapM hsFreeAndDeclaredGhc xs
      return $ mconcat fds


-- ---------------------------------------------------------------------

-- |Get the names of all types declared in the given declaration
-- getDeclaredTypesRdr :: GHC.LTyClDecl GHC.RdrName -> RefactGhc [GHC.Name]
getDeclaredTypesRdr :: GHC.LHsDecl GHC.RdrName -> RefactGhc [GHC.Name]
getDeclaredTypesRdr (GHC.L _ (GHC.TyClD decl)) = do
  nm <- getRefactNameMap
  case decl of
    (GHC.FamDecl (GHC.FamilyDecl _ ln _ _)) -> return [rdrName2NamePure nm ln]
    (GHC.SynDecl ln  _ _ _) -> return [rdrName2NamePure nm ln]
    (GHC.DataDecl ln _ defn _) -> do
      let dds = concatMap (GHC.con_names . GHC.unLoc) $ GHC.dd_cons defn
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
        getLSig (GHC.L _ (GHC.TypeSig ns _ _))  = map (rdrName2NamePure nm) ns
        getLSig (GHC.L _ (GHC.GenericSig ns _)) = map (rdrName2NamePure nm) ns
        getLSig (GHC.L _ (GHC.IdSig _n)) = []
        getLSig (GHC.L _ (GHC.InlineSig ln2 _)) = [rdrName2NamePure nm ln2]
        getLSig (GHC.L _ (GHC.SpecSig ln2 _ _)) = [rdrName2NamePure nm ln2]
        getLSig (GHC.L _ (GHC.SpecInstSig _ _)) = []
        getLSig (GHC.L _ (GHC.FixSig _)) = []
        getLSig (GHC.L _ (GHC.PatSynSig _ _ _ _ _)) = error "To implement: getLSig PatSynSig"
        getLSig (GHC.L _ (GHC.MinimalSig _ _)) = error "To implement: getLSig PatSynSig"

        ssn = concatMap getLSig sigs
        -- msn = getDeclaredVars $ hsBinds meths
getDeclaredTypesRdr _ = return []

-- |Get the names of all types declared in the given declaration
getDeclaredTypes :: GHC.LTyClDecl GHC.Name -> [GHC.Name]
getDeclaredTypes (GHC.L _ (GHC.FamDecl (GHC.FamilyDecl _ (GHC.L _ n) _ _))) = [n]
getDeclaredTypes (GHC.L _ (GHC.SynDecl (GHC.L _ n)  _ _ _)) = [n]
getDeclaredTypes (GHC.L _ (GHC.DataDecl (GHC.L _ n) _ defn _)) = n:dds
  where dds = map GHC.unLoc $ concatMap (GHC.con_names . GHC.unLoc) $ GHC.dd_cons defn
getDeclaredTypes (GHC.L _ (GHC.ClassDecl _ (GHC.L _ n) _vars _fds sigs meths _ats _atdefs _ _fvs))
  = nub $ [n] ++ ssn ++ msn -- ++ asn
  where
    getLSig :: GHC.LSig GHC.Name -> [GHC.Name]
    getLSig (GHC.L _ (GHC.TypeSig ns _ _)) = map GHC.unLoc ns
    getLSig (GHC.L _ (GHC.GenericSig ns _)) = map GHC.unLoc ns
    getLSig (GHC.L _ (GHC.IdSig _n)) = []
    getLSig (GHC.L _ (GHC.InlineSig (GHC.L _ n2) _)) = [n2]
    getLSig (GHC.L _ (GHC.SpecSig (GHC.L _ n2) _ _)) = [n2]
    getLSig (GHC.L _ (GHC.SpecInstSig _ _)) = []
    getLSig (GHC.L _ (GHC.FixSig _)) = []
    getLSig (GHC.L _ (GHC.PatSynSig _ _ _ _ _)) = error "To implement: getLSig PatSynSig"
    getLSig (GHC.L _ (GHC.MinimalSig _ _)) = error "To implement: getLSig PatSynSig"

    ssn = concatMap getLSig sigs
    msn = getDeclaredVars $ hsBinds meths

-- ---------------------------------------------------------------------

-- | Return the list of identifiers (in PName format) defined by a
-- function\/pattern binding.
definedPNs :: GHC.LHsBind GHC.Name -> [GHC.Name]
definedPNs (GHC.L _ (GHC.FunBind (GHC.L _ pname) _ _ _ _ _)) = [pname]
definedPNs (GHC.L _ (GHC.PatBind p _rhs _ty _fvs _))         = (hsNamess p)
definedPNs (GHC.L _ (GHC.VarBind pname _rhs _))              = [pname]

-- AbsBinds and ValBinds will never occur in ParsedSource
definedPNs  _ = []

definedPNsRdr :: GHC.LHsDecl GHC.RdrName -> [GHC.Located GHC.RdrName]
definedPNsRdr (GHC.L _ (GHC.ValD (GHC.FunBind pname _ _ _ _ _)))   = [pname]
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
      definesDecl decl'@(GHC.L _ (GHC.ValD (GHC.FunBind _ _ _ _ _ _)))
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
      defines' decl'@(GHC.L _ (GHC.ValD (GHC.FunBind _ _ _ _ _ _)))
        | any (\n -> definesDeclRdr nameMap n decl') pns = [decl']

      defines' decl'@(GHC.L _l (GHC.ValD (GHC.PatBind _p _rhs _ty _fvs _)))
        | any (\n -> definesDeclRdr nameMap n decl') pns = [decl']

      defines' _ = []

      definesBind :: (GHC.LHsBind GHC.RdrName) -> [GHC.LHsDecl GHC.RdrName]
      definesBind (GHC.L l b) = defines' (GHC.L l (GHC.ValD b))

-- ---------------------------------------------------------------------

-- |Find those declarations(function\/pattern binding) which define
-- the specified GHC.Names. incTypeSig indicates whether the
-- corresponding type signature will be included.
definingDeclsNames::
            [GHC.Name]   -- ^ The specified identifiers.
            ->[GHC.LHsBind GHC.Name] -- ^ A collection of declarations.
            ->Bool       -- ^ True means to include the type signature.
            ->Bool       -- ^ True means to look at the local declarations as well.
            ->[GHC.LHsBind GHC.Name]  -- ^ The result.
definingDeclsNames pns ds _incTypeSig recursive = concatMap defining ds
  where
   defining decl
     = if recursive
        then SYB.everythingStaged SYB.Renamer (++) [] ([]  `SYB.mkQ` defines') decl
        else defines' decl
     where
      defines' :: (GHC.LHsBind GHC.Name) -> [GHC.LHsBind GHC.Name]
      defines' decl'@(GHC.L _ (GHC.FunBind (GHC.L _ pname) _ _ _ _ _))
        |isJust (find (==(pname)) pns) = [decl']

      defines' decl'@(GHC.L _l (GHC.PatBind p _rhs _ty _fvs _))
        |(hsNamess p) `intersect` pns /= [] = [decl']

      defines' _ = []

-- |Find those declarations(function\/pattern binding) which define
-- the specified GHC.Names. incTypeSig indicates whether the
-- corresponding type signature will be included.
definingDeclsNames':: (SYB.Data t)
            => [GHC.Name]   -- ^ The specified identifiers.
            -> t            -- ^ A collection of declarations.
            ->[GHC.LHsBind GHC.Name]  -- ^ The result.
definingDeclsNames' pns t = defining t
  where
   defining decl
     = SYB.everythingStaged SYB.Renamer (++) [] ([]  `SYB.mkQ` defines') decl
     where
      defines' :: (GHC.LHsBind GHC.Name) -> [GHC.LHsBind GHC.Name]
      defines' decl'@(GHC.L _ (GHC.FunBind (GHC.L _ pname) _ _ _ _ _))
        |isJust (find (==(pname)) pns) = [decl']

      defines' decl'@(GHC.L _l (GHC.PatBind p _rhs _ty _fvs _))
        |(hsNamess p) `intersect` pns /= [] = [decl']

      defines' _ = []

-- ---------------------------------------------------------------------

-- |Find those type signatures for the specified GHC.Names.
definingSigsNames :: (SYB.Data t) =>
            [GHC.Name] -- ^ The specified identifiers.
            ->t        -- ^ A collection of declarations.
            ->[GHC.LSig GHC.Name]  -- ^ The result.
definingSigsNames pns ds = def ds
  where
   def decl
     = SYB.everythingStaged SYB.Renamer (++) [] ([]  `SYB.mkQ` inSig) decl
     where
      inSig :: (GHC.LSig GHC.Name) -> [GHC.LSig GHC.Name]
      inSig (GHC.L l (GHC.TypeSig ns t p))
       | defines' ns /= [] = [(GHC.L l (GHC.TypeSig (defines' ns) t p))]
      inSig _ = []

      defines' (p::[GHC.Located GHC.Name])
        = filter (\(GHC.L _ n) -> n `elem` pns) p

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
      inSig (GHC.L l (GHC.TypeSig ns t p))
       | defines' ns /= [] = [(GHC.L l (GHC.TypeSig (defines' ns) t p))]
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
            => [GHC.Name]   -- ^ The specified identifiers.
            -> t -- ^ A collection of declarations.
            ->[GHC.LTyClDecl GHC.Name]  -- ^ The result.
definingTyClDeclsNames pns t = defining t
  where
   defining decl
     = SYB.everythingStaged SYB.Renamer (++) []
                   ([]  `SYB.mkQ` defines') decl
     where
      defines' :: (GHC.LTyClDecl GHC.Name) -> [GHC.LTyClDecl GHC.Name]
      defines' decl'@(GHC.L _ (GHC.FamDecl (GHC.FamilyDecl _ (GHC.L _ pname) _ _)))
        |isJust (find (==(pname)) pns) = [decl']
        | otherwise = []

      defines' decl'@(GHC.L _ (GHC.SynDecl (GHC.L _ pname) _ _ _))
        |isJust (find (==(pname)) pns) = [decl']
        | otherwise = []

      defines' decl'@(GHC.L _ (GHC.DataDecl (GHC.L _ pname) _ _ _))
        |isJust (find (==(pname)) pns) = [decl']
        | otherwise = []

      defines' decl'@(GHC.L _ (GHC.ClassDecl _ (GHC.L _ pname) _ _ _ _ _ _ _ _))
        |isJust (find (==(pname)) pns) = [decl']
        | otherwise = []

-- ---------------------------------------------------------------------

-- | Return True if the function\/pattern binding defines the
-- specified identifier.
defines:: GHC.Name -> GHC.LHsBind GHC.Name -> Bool
defines n (GHC.L _ (GHC.FunBind (GHC.L _ pname) _ _ _ _ _))
 = GHC.nameUnique pname == GHC.nameUnique n
defines n (GHC.L _ (GHC.PatBind p _rhs _ty _fvs _))
 = elem (GHC.nameUnique n) (map GHC.nameUnique $ hsNamess p)
defines _ _= False

-- | Return True if the function\/pattern binding defines the
-- specified identifier.
definesRdr :: NameMap -> GHC.Name -> GHC.LHsBind GHC.RdrName -> Bool
definesRdr nameMap nin (GHC.L _ (GHC.FunBind (GHC.L ln _pname) _ _ _ _ _)) =
  case Map.lookup ln nameMap of
    Nothing -> False
    Just n ->  GHC.nameUnique n == GHC.nameUnique nin
definesRdr nameMap n (GHC.L _ (GHC.PatBind p _rhs _ty _fvs _)) =
  elem n (map (rdrName2NamePure nameMap) (hsNamessRdr p))
definesRdr _ _ _= False

-- |Unwraps a LHsDecl and calls definesRdr on the result if a HsBind
definesDeclRdr :: NameMap -> GHC.Name -> GHC.LHsDecl GHC.RdrName -> Bool
definesDeclRdr nameMap nin (GHC.L l (GHC.ValD d)) = definesRdr nameMap nin (GHC.L l d)
definesDeclRdr _ _ _ = False


definesP::PName -> HsDeclP ->Bool
definesP pn (GHC.L _ (GHC.ValD (GHC.FunBind (GHC.L _ pname) _ _ _ _ _)))
 = PN pname == pn
definesP pn (GHC.L _ (GHC.ValD (GHC.PatBind p _rhs _ty _fvs _)))
 = elem pn (hsPNs p)
definesP _ _= False

-- ---------------------------------------------------------------------

-- | Return True if the declaration defines the type signature of the
-- specified identifier.
definesTypeSig :: GHC.Name -> GHC.LSig GHC.Name -> Bool
definesTypeSig pn (GHC.L _ (GHC.TypeSig names _typ _)) = elem (GHC.nameUnique pn) $ map (\(GHC.L _ n)->GHC.nameUnique n) names
definesTypeSig _  _ = False

-- | Return True if the declaration defines the type signature of the
-- specified identifier.
definesTypeSigRdr :: NameMap -> GHC.Name -> GHC.Sig GHC.RdrName -> Bool
definesTypeSigRdr nameMap pn (GHC.TypeSig names _typ _)
  = elem (GHC.nameUnique pn) (map (GHC.nameUnique . rdrName2NamePure nameMap) names)
-- definesTypeSigRdr _ _  _ = False
definesTypeSigRdr _ _  x = error $ "definesTypeSigRdr : got " ++ SYB.showData SYB.Parser 0 x

-- |Unwraps a LHsDecl and calls definesRdr on the result if a Sig
definesSigDRdr :: NameMap -> GHC.Name -> GHC.LHsDecl GHC.RdrName -> Bool
definesSigDRdr nameMap nin (GHC.L _ (GHC.SigD d)) = definesTypeSigRdr nameMap nin d
definesSigDRdr _ _ _ = False

-- ---------------------------------------------------------------------

-- |Find all Located Names in the given Syntax phrase.
allNames::(SYB.Data t)
       =>t                      -- ^ The syntax phrase
       ->[GHC.Located GHC.Name] -- ^ The result
allNames t
  = res
       where
        res = SYB.everythingStaged SYB.Parser (++) []
            ([] `SYB.mkQ` worker `SYB.extQ` workerBind `SYB.extQ` workerExpr) t

        worker (pnt :: (GHC.Located GHC.Name))
          = [pnt]
        -- worker _ = []

        workerBind (GHC.L l (GHC.VarPat name) :: (GHC.Located (GHC.Pat GHC.Name)))
          = [(GHC.L l name)]
        workerBind _ = []

        workerExpr ((GHC.L l (GHC.HsVar name)) :: (GHC.Located (GHC.HsExpr GHC.Name)))
          = [(GHC.L l name)]
        workerExpr _ = []



-- ---------------------------------------------------------------------

-- |Get all the names in the given syntax element
hsNamess :: (SYB.Data t) => t -> [GHC.Name]
hsNamess t = nub $ concat res
  where
     res = SYB.everythingStaged SYB.Renamer (++) [] ([] `SYB.mkQ` inName) t

     inName (pname :: GHC.Name) = return [pname]

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
      vars (GHC.L _ (GHC.ValD (GHC.FunBind ln _ _ _ _fvs _)))   = [rdrName2NamePure nm ln]
      vars (GHC.L _ (GHC.ValD (GHC.PatBind p _rhs _ty _fvs _))) = (hsNamess p)
      vars _ = []

getDeclaredVars :: [GHC.LHsBind GHC.Name] -> [GHC.Name]
getDeclaredVars bs = concatMap vars bs
  where
      vars :: (GHC.LHsBind GHC.Name) -> [GHC.Name]
      vars (GHC.L _ (GHC.FunBind (GHC.L _ pname) _ _ _ _fvs _)) = [pname]
      vars (GHC.L _ (GHC.PatBind p _rhs _ty _fvs _))            = (hsNamess p)
      vars _ = []

-- ---------------------------------------------------------------------
-- |Experiment with GHC fvs stuff
getFvs :: [GHC.LHsBind GHC.Name] -> [([GHC.Name], GHC.NameSet)]
getFvs bs = concatMap binds bs
  where
      binds :: (GHC.LHsBind GHC.Name) -> [([GHC.Name],GHC.NameSet)]
      binds (GHC.L _ (GHC.FunBind (GHC.L _ pname) _ _ _ fvs _)) = [([pname],     fvs)]
      binds (GHC.L _ (GHC.PatBind p _rhs _ty fvs _))            = [((hsNamess p),fvs)]
      binds _ = []

getFreeVars :: [GHC.LHsBind GHC.Name] -> [GHC.Name]
getFreeVars bs = concatMap binds bs
  where
      binds :: (GHC.LHsBind GHC.Name) -> [GHC.Name]
      binds (GHC.L _ (GHC.FunBind (GHC.L _ _pname) _ _ _ fvs _)) = (GHC.nameSetElems fvs)
      binds (GHC.L _ (GHC.PatBind _p _rhs _ty fvs _))            = (GHC.nameSetElems fvs)
      binds _ = []

------------------------------------------------------------------------

-- | Given syntax phrases e and t, if e occurs in t, then return those
-- variables which are declared in t and accessible to e, otherwise
-- return [].
hsVisiblePNs :: (FindEntity e,HsValBinds t GHC.Name,GHC.Outputable e)
             => e -> t -> RefactGhc [GHC.Name]
hsVisiblePNs e t = do
  (DN d) <- hsVisibleDs e t
  return d

--------------------------------------------------------------------------------
-- | Same as `hsVisiblePNs' except that the returned identifiers are
-- in String format.
hsVisibleNames:: (FindEntity t1,HsValBinds t2 GHC.Name,GHC.Outputable t1)
  => t1 -> t2 -> RefactGhc [String]
hsVisibleNames e t = do
    d <- hsVisiblePNs e t
    return ((nub . map showGhc) d)

--------------------------------------------------------------------------------
-- | Same as `hsVisiblePNs' except that the returned identifiers are
-- in String format.
hsVisibleNamesRdr:: (FindEntity t1,SYB.Data t2,GHC.Outputable t1)
  => t1 -> t2 -> RefactGhc [String]
hsVisibleNamesRdr e t = do
    nm <- getRefactNameMap
    d <- hsVisiblePNsRdr nm e t
    return ((nub . map showGhc) d)

------------------------------------------------------------------------

-- | Given syntax phrases e and t, if e occurs in t, then return those
-- variables which are declared in t and accessible to e, otherwise
-- return [].
hsVisiblePNsRdr :: (FindEntity e,SYB.Data t,GHC.Outputable e)
             => NameMap -> e -> t -> RefactGhc [GHC.Name]
hsVisiblePNsRdr nm e t = do
  (DN d) <- hsVisibleDsRdr nm e t
  return d

------------------------------------------------------------------------

-- | Given syntax phrases e and t, if e occurs in t, then return those
-- variables which are declared in t and accessible to e, otherwise
-- return [].
hsVisibleDsRdr :: (FindEntity e, GHC.Outputable e,SYB.Data t)
             => NameMap -> e -> t -> RefactGhc DeclaredNames
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
          ) t

    -- err2 = error $ "hsVisibleDsRdr:err2:no match for:" ++ (SYB.showData SYB.Renamer 0 t)

    parsed :: GHC.ParsedSource -> RefactGhc DeclaredNames
    parsed p
      | findEntity e p = do
         -- dfds <- mapM (hsVisibleDsRdr nm e) $ GHC.hsmodDecls $ GHC.unLoc p
         logm $ "hsVisibleDsRdr parsedSource:decls starting"
         dfds <- mapM (declFun ( hsVisibleDsRdr nm e) ) $ GHC.hsmodDecls $ GHC.unLoc p
         logm $ "hsVisibleDsRdr parsedSource:decls done"
         return $ mconcat dfds
    parsed _ = return (DN [])

    valbinds :: (GHC.HsValBindsLR GHC.RdrName GHC.RdrName) -> RefactGhc DeclaredNames
    valbinds vb@(GHC.ValBindsIn bindsBag sigs)
      | findEntity e vb = do
          fdsb <- mapM (hsVisibleDsRdr nm e) $ hsBinds bindsBag
          fdss <- mapM (hsVisibleDsRdr nm e) sigs
          return $ mconcat fdss <> mconcat fdsb
    valbinds vb@(GHC.ValBindsOut _binds _sigs)
      | findEntity e vb = do
          logm $ "hsVisibleDsRdr valbinds:ValBindsOut:impossible for RdrName"
          return (DN [])

    valbinds _ = do
      logm $ "hsVisibleDsRdr nm.valbinds:not matched"
      return (DN [])

    lhsdecls :: [GHC.LHsDecl GHC.RdrName] -> RefactGhc DeclaredNames
    lhsdecls ds
      | findEntity e ds = do
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

    lhsbindslr :: GHC.LHsBindsLR GHC.RdrName GHC.RdrName -> RefactGhc DeclaredNames
    lhsbindslr bs = do
      fds <- mapM (hsVisibleDsRdr nm e) $ GHC.bagToList bs
      return $ mconcat fds

    hsbinds :: [GHC.LHsBind GHC.RdrName] -> RefactGhc DeclaredNames
    hsbinds ds
      | findEntity e ds = do
        fds <- mapM (hsVisibleDsRdr nm e) ds
        return $ mconcat fds
    hsbinds _ = return (DN [])

    hsbind :: (GHC.LHsBind GHC.RdrName) -> RefactGhc DeclaredNames
    hsbind ((GHC.L _ (GHC.FunBind _n _ (GHC.MG matches _ _ _) _ _ _)))
      | findEntity e matches = do
          fds <- mapM (hsVisibleDsRdr nm e) matches
          logm $ "hsVisibleDsRdr.hsbind:fds=" ++ show fds
          return $ mconcat fds
    hsbind _ = do
      logm $ "hsVisibleDsRdr.hsbind:miss"
      return (DN [])

    hslocalbinds :: (GHC.HsLocalBinds GHC.RdrName) -> RefactGhc DeclaredNames
    hslocalbinds (GHC.HsValBinds binds)
      | findEntity e binds = hsVisibleDsRdr nm e binds
    hslocalbinds (GHC.HsIPBinds binds)
      | findEntity e binds = hsVisibleDsRdr nm e binds
    hslocalbinds (GHC.EmptyLocalBinds) = return (DN [])
    hslocalbinds _ = return (DN [])

    lmatch :: (GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)) -> RefactGhc DeclaredNames
    lmatch (GHC.L _ (GHC.Match _fn pats _mtyp rhs))
      | findEntity e pats = do
           logm $ "hsVisibleDsRdr nm.lmatch:in pats="
           return (DN []) -- TODO: extend this
      | findEntity e rhs = do
           logm $ "hsVisibleDsRdr nm.lmatch:doing rhs"
           let (pf,pd) = hsFreeAndDeclaredRdr nm pats
           logm $ "hsVisibleDsRdr nm.lmatch:(pf,pd)=" ++ (show (pf,pd))
           (    rd) <- hsVisibleDsRdr nm e rhs
           return (pd <> rd)
    lmatch _ =return  (DN [])

    grhss :: (GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName)) -> RefactGhc DeclaredNames
    grhss (GHC.GRHSs guardedRhss lstmts)
      | findEntity e guardedRhss = do
          logm "hsVisibleDsRdr nm.grhss:about to do grhss"
          fds <- mapM (hsVisibleDsRdr nm e) guardedRhss
          logm "hsVisibleDsRdr nm.grhss:grhss done"
          return $ mconcat fds
      | findEntity e lstmts = do
          logm "hsVisibleDsRdr nm.grhss:about to do lstmts"
          hsVisibleDsRdr nm e lstmts
    grhss _ = return (DN [])

    lgrhs :: GHC.LGRHS GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc DeclaredNames
    lgrhs (GHC.L _ (GHC.GRHS guards ex))
      | findEntity e guards = logm "hsVisibleDsRdr nm.lgrhs.guards" >> hsVisibleDsRdr nm e guards
      | findEntity e ex     = logm "hsVisibleDsRdr nm.lgrhs.ex"     >> hsVisibleDsRdr nm e ex
    lgrhs _ = return (DN [])


    lexpr :: GHC.LHsExpr GHC.RdrName -> RefactGhc DeclaredNames
    lexpr (GHC.L l (GHC.HsVar n))
      | findEntity e n  = do
        logm $ "hsVisibleDsRdr.lexpr.HsVar entity found"
        return (DN [rdrName2NamePure nm (GHC.L l n)])
    lexpr (GHC.L _ (GHC.HsLet lbinds expr))
      | findEntity e lbinds || findEntity e expr  = do
        logm $ "hsVisibleDsRdr.lexpr.HsLet entity found"
        let (_,lds) = hsFreeAndDeclaredRdr nm lbinds
        let (_,eds) = hsFreeAndDeclaredRdr nm expr
        return $ lds <> eds

    lexpr expr
      | findEntity e expr = do
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
      | findEntity e tgrps = do
        fds <- mapM (hsVisibleDsRdr nm e) tgrps
        return $ mconcat fds
    tyclgroups _ = return (DN [])

    tyclgroup :: GHC.TyClGroup GHC.RdrName -> RefactGhc DeclaredNames
    tyclgroup (GHC.TyClGroup tyclds _roles)
      | findEntity e tyclds = do
        fds <- mapM (hsVisibleDsRdr nm e) tyclds
        return $ mconcat fds
    tyclgroup _ = return (DN [])

    tycldeclss :: [[GHC.LTyClDecl GHC.RdrName]] -> RefactGhc DeclaredNames
    tycldeclss tcds
      | findEntity e tcds = do
        fds <- mapM (hsVisibleDsRdr nm e) tcds
        return $ mconcat fds
    tycldeclss _ = return (DN [])

    tycldecls :: [GHC.LTyClDecl GHC.RdrName] -> RefactGhc DeclaredNames
    tycldecls tcds
      | findEntity e tcds = do
        logm $ "hsVisibleDsRdr.tycldecls"
        fds <- mapM (hsVisibleDsRdr nm e) tcds
        logm $ "hsVisibleDsRdr.tycldecls done"
        return $ mconcat fds
    tycldecls _ = return (DN [])

    tycldecl :: GHC.LTyClDecl GHC.RdrName -> RefactGhc DeclaredNames
    tycldecl tcd
      | findEntity e tcd = do
        logm $ "hsVisibleDsRdr.tycldecl"
        let (_,ds) = hsFreeAndDeclaredRdr nm tcd
        logm $ "hsVisibleDsRdr.tycldecl done"
        return ds
    tycldecl _ = return (DN [])

    -- ---------------------------------

    instdecls :: [GHC.LInstDecl GHC.RdrName] -> RefactGhc DeclaredNames
    instdecls ds
      | findEntity e ds = do
        fds <- mapM (hsVisibleDsRdr nm e) ds
        return $ mconcat fds
    instdecls _ = return (DN [])

    instdecl :: GHC.LInstDecl GHC.RdrName -> RefactGhc DeclaredNames
    instdecl (GHC.L _ (GHC.ClsInstD (GHC.ClsInstDecl polytyp binds sigs tyfaminsts dfaminsts _)))
      | findEntity e polytyp    = hsVisibleDsRdr nm e polytyp
      | findEntity e binds      = hsVisibleDsRdr nm e binds
      | findEntity e sigs       = hsVisibleDsRdr nm e sigs
      | findEntity e tyfaminsts = hsVisibleDsRdr nm e tyfaminsts
      | findEntity e dfaminsts  = hsVisibleDsRdr nm e dfaminsts
      | otherwise = return (DN [])
    instdecl (GHC.L _ (GHC.DataFamInstD (GHC.DataFamInstDecl _ln pats defn _)))
      | findEntity e pats = hsVisibleDsRdr nm e pats
      | findEntity e defn = hsVisibleDsRdr nm e defn
      | otherwise = return (DN [])
    instdecl (GHC.L _ (GHC.TyFamInstD (GHC.TyFamInstDecl eqn _)))
      | findEntity e eqn = hsVisibleDsRdr nm e eqn
      | otherwise = return (DN [])

    lhstype :: GHC.LHsType GHC.RdrName -> RefactGhc DeclaredNames
    lhstype tv@(GHC.L l (GHC.HsTyVar n))
      | findEntity e tv = return (DN [rdrName2NamePure nm (GHC.L l n)])
      | otherwise       = return (DN [])
    lhstype (GHC.L _ (GHC.HsForAllTy _ _ _bndrs _ctxt _typ))
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
    lsig (GHC.L _ (GHC.TypeSig _ns typ _))
      | findEntity e typ = hsVisibleDsRdr nm e typ
    lsig (GHC.L _ (GHC.GenericSig _n typ))
      | findEntity e typ = hsVisibleDsRdr nm e typ
    lsig (GHC.L _ (GHC.IdSig _)) = return (DN [])
    lsig (GHC.L _ (GHC.InlineSig _ _)) = return (DN [])
    lsig (GHC.L _ (GHC.SpecSig _n typ _))
      | findEntity e typ = hsVisibleDsRdr nm e typ
    lsig (GHC.L _ (GHC.SpecInstSig _ _)) = return (DN [])

    lsig _ = return (DN [])

    -- -----------------------

    lstmts :: [GHC.LStmt GHC.RdrName (GHC.LHsExpr GHC.RdrName)] -> RefactGhc DeclaredNames
    lstmts ds
      | findEntity e ds = do
        fds <- mapM (hsVisibleDsRdr nm e) ds
        return $ mconcat fds
    lstmts _ = return (DN [])

    -- -----------------------

    lstmt :: GHC.LStmt GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc DeclaredNames
    lstmt (GHC.L _ (GHC.LastStmt ex _)) = hsVisibleDsRdr nm e ex
    lstmt (GHC.L _ (GHC.BindStmt pa ex _ _)) = do
      fdp <- hsVisibleDsRdr nm e pa
      fde <- hsVisibleDsRdr nm e ex
      return (fdp <> fde)
    lstmt (GHC.L _ (GHC.BodyStmt ex _ _ _)) = hsVisibleDsRdr nm e ex
    -- lstmt (GHC.L _ (GHC.ExprStmt e _ _ _)) = hsFreeAndDeclaredGhc e

    lstmt (GHC.L _ (GHC.LetStmt bs)) = hsVisibleDsRdr nm e bs
    lstmt (GHC.L _ (GHC.ParStmt ps _ _)) = hsVisibleDsRdr nm e ps
    lstmt (GHC.L _ (GHC.TransStmt _ stmts _ using mby _ _ _)) = do
      fds <- hsVisibleDsRdr nm e stmts
      fdu <- hsVisibleDsRdr nm e using
      fdb <- case mby of
        Nothing -> return (DN [])
        Just ex -> hsVisibleDsRdr nm e ex
      return $ fds <> fdu <> fdb
    lstmt (GHC.L _ (GHC.RecStmt stmts _ _ _ _ _ _ _ _)) = hsVisibleDsRdr nm e stmts
    -- lstmt _ = return (DN [])

    -- -----------------------

    err = error $ "hsVisibleDsRdr nm:no match for:" ++ (SYB.showData SYB.Parser 0 t)


------------------------------------------------------------------------

-- | Given syntax phrases e and t, if e occurs in t, then return those
-- variables which are declared in t and accessible to e, otherwise
-- return [].
hsVisibleDs :: (FindEntity e, GHC.Outputable e
               ,SYB.Data t,HsValBinds t GHC.Name)
             => e -> t -> RefactGhc DeclaredNames
hsVisibleDs e t = do
  -- logm $ "hsVisibleDs:(e,t)=" ++ (SYB.showData SYB.Renamer 0 (e,t))
  (DN d) <- res
  return (DN (nub d))
  where
    -- TODO: this is effectively a recursive descent approach, where
    --       each syntax element processor knows exactly what it needs
    --       in terms of sub-elements. Hence as an optimisation,
    --       consider calling the relevent element directly, instead
    --       of looping back into the main function.
    res = (const err -- (DN [])
          `SYB.extQ` renamed
          `SYB.extQ` valbinds
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
          ) t

    renamed :: GHC.RenamedSource -> RefactGhc DeclaredNames
    renamed (g,_i,_ex,_d)
      | findEntity e g = do
         dfds <- hsVisibleDs e $ GHC.hs_valds g
         -- logm $ "hsVisibleDs.renamedSource:valds done"
         tfds <- hsVisibleDs e $ GHC.hs_tyclds g
         -- logm $ "hsVisibleDs.renamedSource:tyclds done"
         ifds <- hsVisibleDs e $ GHC.hs_instds g
         -- logm $ "hsVisibleDs.renamedSource:instds done"
         return $ dfds <> tfds <> ifds
    renamed _ = return (DN [])

    valbinds :: (GHC.HsValBindsLR GHC.Name GHC.Name) -> RefactGhc DeclaredNames
    valbinds vb@(GHC.ValBindsIn bindsBag sigs)
      | findEntity e vb = do
          fdsb <- mapM (hsVisibleDs e) $ hsBinds bindsBag
          fdss <- mapM (hsVisibleDs e) sigs
          return $ mconcat fdss <> mconcat fdsb
    valbinds vb@(GHC.ValBindsOut binds sigs)
      | findEntity e vb = do
          -- logm $ "hsVisibleDs.valbinds:ValBindsOut"
          fdsb <- mapM (hsVisibleDs e) $ map snd binds
          fdss <- mapM (hsVisibleDs e) sigs
          return $ mconcat fdss <> mconcat fdsb

    valbinds _ = do
      -- logm $ "hsVisibleDs.valbinds:not matched"
      return (DN [])

    lhsbindslr :: GHC.LHsBindsLR GHC.Name GHC.Name -> RefactGhc DeclaredNames
    lhsbindslr bs = do
      fds <- mapM (hsVisibleDs e) $ GHC.bagToList bs
      return $ mconcat fds

    hsbinds :: [GHC.LHsBind GHC.Name] -> RefactGhc DeclaredNames
    hsbinds ds
      | findEntity e ds = do
        fds <- mapM (hsVisibleDs e) ds
        return $ mconcat fds
    hsbinds _ = return (DN [])

    hsbind :: (GHC.LHsBind GHC.Name) -> RefactGhc DeclaredNames
    hsbind ((GHC.L _ (GHC.FunBind _n _ (GHC.MG matches _ _ _) _ _ _)))
      | findEntity e matches = do
          fds <- mapM (hsVisibleDs e) matches
          -- logm $ "hsVisibleDs.hsbind:fds=" ++ show fds
          return $ mconcat fds
    hsbind _ = return (DN [])

    hslocalbinds :: (GHC.HsLocalBinds GHC.Name) -> RefactGhc DeclaredNames
    hslocalbinds (GHC.HsValBinds binds)
      | findEntity e binds = hsVisibleDs e binds
    hslocalbinds (GHC.HsIPBinds binds)
      | findEntity e binds = hsVisibleDs e binds
    hslocalbinds (GHC.EmptyLocalBinds) = return (DN [])
    hslocalbinds _ = return (DN [])

    lmatch :: (GHC.LMatch GHC.Name (GHC.LHsExpr GHC.Name)) -> RefactGhc DeclaredNames
    lmatch (GHC.L _ (GHC.Match _fn pats _mtyp rhs))
      | findEntity e pats = do
           -- logm $ "hsVisibleDs.lmatch:in pats="
           return (DN []) -- TODO: extend this
      | findEntity e rhs = do
           -- logm $ "hsVisibleDs.lmatch:doing rhs"
           (_pf,pd) <- hsFreeAndDeclaredGhc pats
           -- logm $ "hsVisibleDs.lmatch:(pf,pd)=" ++ (show (pf,pd))
           (    rd) <- hsVisibleDs e rhs
           return (pd <> rd)
    lmatch _ =return  (DN [])

    grhss :: (GHC.GRHSs GHC.Name (GHC.LHsExpr GHC.Name)) -> RefactGhc DeclaredNames
    grhss (GHC.GRHSs guardedRhss lstmts)
      | findEntity e guardedRhss = do
          -- logm "hsVisibleDs.grhss:about to do grhss"
          fds <- mapM (hsVisibleDs e) guardedRhss
          -- logm "hsVisibleDs.grhss:grhss done"
          return $ mconcat fds
      | findEntity e lstmts = do
          -- logm "hsVisibleDs.grhss:about to do lstmts"
          hsVisibleDs e lstmts
    grhss _ = return (DN [])

    lgrhs :: GHC.LGRHS GHC.Name (GHC.LHsExpr GHC.Name) -> RefactGhc DeclaredNames
    lgrhs (GHC.L _ (GHC.GRHS guards ex))
      | findEntity e guards = hsVisibleDs e guards
      | findEntity e ex     = hsVisibleDs e ex
    lgrhs _ = return (DN [])


    lexpr :: GHC.LHsExpr GHC.Name -> RefactGhc DeclaredNames
    lexpr (GHC.L _ (GHC.HsVar n))
      | findEntity e n  = return (DN [n])
    lexpr (GHC.L _ (GHC.HsLet lbinds expr))
      | findEntity e lbinds || findEntity e expr  = do
        (_,lds) <- hsFreeAndDeclaredGhc lbinds
        (_,eds) <- hsFreeAndDeclaredGhc expr
        return $ lds <> eds

    lexpr expr
      | findEntity e expr = do
        -- logm $ "hsVisibleDs.lexpr.(e,expr):" ++ (showGhc (e,expr))
        (FN efs,_)         <- hsFreeAndDeclaredGhc expr
        (FN _eefs,DN eeds) <- hsFreeAndDeclaredGhc e
        -- logm $ "hsVisibleDs.lexpr done"
        -- return (DN e1fs <> DN eofs <> DN e2fs)
        return (DN (efs \\ eeds))

    lexpr _ = return (DN [])

    -- ---------------------------------

    tyclgroups :: [GHC.TyClGroup GHC.Name] -> RefactGhc DeclaredNames
    tyclgroups tgrps
      | findEntity e tgrps = do
        fds <- mapM (hsVisibleDs e) tgrps
        return $ mconcat fds
    tyclgroups _ = return (DN [])

    tyclgroup :: GHC.TyClGroup GHC.Name -> RefactGhc DeclaredNames
    tyclgroup (GHC.TyClGroup tyclds _roles)
      | findEntity e tyclds = do
        fds <- mapM (hsVisibleDs e) tyclds
        return $ mconcat fds
    tyclgroup _ = return (DN [])

    tycldeclss :: [[GHC.LTyClDecl GHC.Name]] -> RefactGhc DeclaredNames
    tycldeclss tcds
      | findEntity e tcds = do
        fds <- mapM (hsVisibleDs e) tcds
        return $ mconcat fds
    tycldeclss _ = return (DN [])

    tycldecls :: [GHC.LTyClDecl GHC.Name] -> RefactGhc DeclaredNames
    tycldecls tcds
      | findEntity e tcds = do
        -- logm $ "hsVisibleDs.tycldecls"
        fds <- mapM (hsVisibleDs e) tcds
        return $ mconcat fds
    tycldecls _ = return (DN [])

    tycldecl :: GHC.LTyClDecl GHC.Name -> RefactGhc DeclaredNames
    tycldecl tcd
      | findEntity e tcd = do
        -- logm $ "hsVisibleDs.tycldecl"
        (_,ds) <- hsFreeAndDeclaredGhc tcd
        return ds
    tycldecl _ = return (DN [])

    -- ---------------------------------

    instdecls :: [GHC.LInstDecl GHC.Name] -> RefactGhc DeclaredNames
    instdecls ds
      | findEntity e ds = do
        fds <- mapM (hsVisibleDs e) ds
        return $ mconcat fds
    instdecls _ = return (DN [])

    instdecl :: GHC.LInstDecl GHC.Name -> RefactGhc DeclaredNames
    instdecl (GHC.L _ (GHC.ClsInstD (GHC.ClsInstDecl polytyp binds sigs tyfaminsts dfaminsts _)))
      | findEntity e polytyp    = hsVisibleDs e polytyp
      | findEntity e binds      = hsVisibleDs e binds
      | findEntity e sigs       = hsVisibleDs e sigs
      | findEntity e tyfaminsts = hsVisibleDs e tyfaminsts
      | findEntity e dfaminsts  = hsVisibleDs e dfaminsts
      | otherwise = return (DN [])
    instdecl (GHC.L _ (GHC.DataFamInstD (GHC.DataFamInstDecl _ln pats defn _)))
      | findEntity e pats = hsVisibleDs e pats
      | findEntity e defn = hsVisibleDs e defn
      | otherwise = return (DN [])
    instdecl (GHC.L _ (GHC.TyFamInstD (GHC.TyFamInstDecl eqn _)))
      | findEntity e eqn = hsVisibleDs e eqn
      | otherwise = return (DN [])

    lhstype :: GHC.LHsType GHC.Name -> RefactGhc DeclaredNames
    lhstype tv@(GHC.L _ (GHC.HsTyVar n))
      | findEntity e tv = return (DN [n])
      | otherwise       = return (DN [])
    lhstype (GHC.L _ (GHC.HsForAllTy _ _ _bndrs _ctxt _typ))
        = return (DN [])
    lhstype (GHC.L _ (GHC.HsFunTy{})) = return (DN [])
    lhstype _ty = do
      -- logm $ "lshtype: TypeUtils 1588" ++ SYB.showData SYB.Renamer 0 _ty
      return (DN [])

    -- -----------------------

    lsigs :: [GHC.LSig GHC.Name] -> RefactGhc DeclaredNames
    lsigs ss = do
      fds <- mapM (hsVisibleDs e) ss
      return $ mconcat fds

    -- -----------------------

    lsig :: GHC.LSig GHC.Name -> RefactGhc DeclaredNames
    lsig (GHC.L _ (GHC.TypeSig _ns typ _))
      | findEntity e typ = hsVisibleDs e typ
    lsig (GHC.L _ (GHC.GenericSig _n typ))
      | findEntity e typ = hsVisibleDs e typ
    lsig (GHC.L _ (GHC.IdSig _)) = return (DN [])
    lsig (GHC.L _ (GHC.InlineSig _ _)) = return (DN [])
    lsig (GHC.L _ (GHC.SpecSig _n typ _))
      | findEntity e typ = hsVisibleDs e typ
    lsig (GHC.L _ (GHC.SpecInstSig _ _)) = return (DN [])

    lsig _ = return (DN [])

    -- -----------------------

    err = error $ "hsVisibleDs:no match for:" ++ (SYB.showData SYB.Renamer 0 t)

-- ---------------------------------------------------------------------

-- |`hsFDsFromInsideRdr` is different from `hsFreeAndDeclaredPNs` in
-- that: given an syntax phrase t, `hsFDsFromInsideRdr` returns not only
-- the declared variables that are visible from outside of t, but also
-- those declared variables that are visible to the main expression
-- inside t.
-- NOTE: Expects to be given RenamedSource
hsFDsFromInsideRdr:: (SYB.Data t)
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
     decl (GHC.FunBind (GHC.L _ _) _ (GHC.MG matches _ _ _) _ _ _) = do
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

     stmts ((GHC.BindStmt pat e1 e2 e3) :: GHC.Stmt GHC.RdrName (GHC.LHsExpr GHC.RdrName)) = do
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

-- |`hsFDsFromInside` is different from `hsFreeAndDeclaredPNs` in
-- that: given an syntax phrase t, `hsFDsFromInside` returns not only
-- the declared variables that are visible from outside of t, but also
-- those declared variables that are visible to the main expression
-- inside t.
-- NOTE: Expects to be given RenamedSource
hsFDsFromInside:: (SYB.Data t) => t-> RefactGhc ([GHC.Name],[GHC.Name])
hsFDsFromInside t = do
   r <- hsFDsFromInside' t
   return r
   where
     hsFDsFromInside' :: (SYB.Data t) => t -> RefactGhc ([GHC.Name],[GHC.Name])
     hsFDsFromInside' t1 = do
          r1 <- applyTU (once_tdTU (failTU  `adhocTU` renamed
                                            `adhocTU` decl
                                            `adhocTU` match
                                            `adhocTU` expr
                                            `adhocTU` stmts )) t1
          let (f',d') = r1
          return (nub f', nub d')

     renamed :: GHC.RenamedSource -> RefactGhc ([GHC.Name],[GHC.Name])
     renamed ((grp,_,_,_)::GHC.RenamedSource)
        = hsFreeAndDeclaredPNs $ GHC.hs_valds grp

     match :: GHC.Match GHC.Name (GHC.LHsExpr GHC.Name) -> RefactGhc ([GHC.Name],[GHC.Name])
     match ((GHC.Match _fn pats _type rhs):: GHC.Match GHC.Name (GHC.LHsExpr GHC.Name)) = do
       (pf, pd) <- hsFreeAndDeclaredPNs pats
       (rf, rd) <- hsFreeAndDeclaredPNs rhs
       return (nub (pf `union` (rf \\ pd)),
               nub (pd `union` rd))

     -- ----------------------

     decl :: GHC.HsBind GHC.Name -> RefactGhc ([GHC.Name],[GHC.Name])
     decl ((GHC.FunBind (GHC.L _ _) _ (GHC.MG matches _ _ _) _ _ _) :: GHC.HsBind GHC.Name) =
       do
         fds <- mapM hsFDsFromInside' matches
         -- error (show $ nameToString n)
         return (nub (concatMap fst fds), nub (concatMap snd fds))

     decl ((GHC.PatBind p rhs _ _ _) :: GHC.HsBind GHC.Name) =
       do
         (pf, pd) <- hsFreeAndDeclaredPNs p
         (rf, rd) <- hsFreeAndDeclaredPNs rhs
         return
           (nub (pf `union` (rf \\ pd)),
            nub (pd `union` rd))

     decl ((GHC.VarBind p rhs _) :: GHC.HsBind GHC.Name) =
       do
         (pf, pd) <- hsFreeAndDeclaredPNs p
         (rf, rd) <- hsFreeAndDeclaredPNs rhs
         return
           (nub (pf `union` (rf \\ pd)),
            nub (pd `union` rd))

     decl _ = return ([],[])

     -- ----------------------

     expr ((GHC.HsLet decls e) :: GHC.HsExpr GHC.Name) =
       do
         (df,dd) <- hsFreeAndDeclaredPNs decls
         (ef,_)  <- hsFreeAndDeclaredPNs e
         return (nub (df `union` (ef \\ dd)), nub dd)

     expr ((GHC.HsLam (GHC.MG matches _ _ _)) :: GHC.HsExpr GHC.Name) =
       hsFreeAndDeclaredPNs matches

     expr ((GHC.HsCase e (GHC.MG matches _ _ _)) :: GHC.HsExpr GHC.Name) =
       do
         (ef,_)  <- hsFreeAndDeclaredPNs e
         (df,dd) <- hsFreeAndDeclaredPNs matches
         return (nub (df `union` (ef \\ dd)), nub dd)

     expr _ = mzero

     stmts ((GHC.BindStmt pat e1 e2 e3) :: GHC.Stmt GHC.Name (GHC.LHsExpr GHC.Name)) =
       do
         (pf,pd)  <- hsFreeAndDeclaredPNs pat
         (ef,_ed) <- hsFreeAndDeclaredPNs e1
         (df,dd)  <- hsFreeAndDeclaredPNs [e2,e3]
         return
           (nub (pf `union` (((ef \\ dd) `union` df) \\ pd)), nub (pd `union` dd))

     stmts ((GHC.LetStmt binds) :: GHC.Stmt GHC.Name (GHC.LHsExpr GHC.Name)) =
       hsFreeAndDeclaredPNs binds

     stmts _ = mzero



-- | The same as `hsFDsFromInside` except that the returned variables
-- are in the String format
hsFDNamesFromInside::(SYB.Data t) => t -> RefactGhc ([String],[String])
hsFDNamesFromInside t = do
  (f,d) <- hsFDsFromInside t
  return
    ((nub.map showGhc) f, (nub.map showGhc) d)

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

rdrName2Name' :: GHC.Located GHC.RdrName -> RefactGhc GHC.Name
rdrName2Name' (GHC.L l rdr) = do
  renamed <- getRefactRenamed
  let mn = locToName (getGhcLoc l) renamed
  return (GHC.unLoc $ gfromJust ("rdrName2Name':failed for:" ++ showGhc (GHC.L l rdr)) mn)

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
locToName::(SYB.Data t)
                    =>SimpPos          -- ^ The row and column number
                    ->t                -- ^ The syntax phrase
                    -> Maybe (GHC.Located GHC.Name)  -- ^ The result
locToName (row,col) t = locToName' (row,col) t

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

locToName':: forall a t.(SYB.Data t, SYB.Data a, Eq a)
                    =>SimpPos          -- ^ The row and column number
                    ->t                -- ^ The syntax phrase
                    -> Maybe (GHC.Located a)  -- ^ The result
locToName' (row,col) t = res1
     where
        res1 :: Maybe (GHC.Located a)
        res1 = SYB.something (nameSybQuery checker) t

        checker pnt =
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
