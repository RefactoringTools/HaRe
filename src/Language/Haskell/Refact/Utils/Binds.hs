{- # LANGUAGE CPP # -}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FunctionalDependencies #-}
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
     -- HasDecls(..)

     hsBinds
   , replaceBinds
   , getValBindSigs
   , emptyValBinds
   , HsValBinds(..)
 ) where

-- import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.GHC.ExactPrint.Utils
-- import Language.Haskell.Refact.Utils.Types

-- Modules from GHC
import qualified Bag           as GHC
import qualified GHC           as GHC
import qualified Outputable    as GHC
import qualified SrcLoc        as GHC

-- import qualified Data.Generics as SYB
-- import qualified GHC.SYB.Utils as SYB

-- import Control.Monad
import Data.Generics
-- import Data.Ratio
-- import qualified Data.Map as Map

-- ---------------------------------------------------------------------
{-
-- TODO: Move this class to ghc-exactprint Transform module
class (Data t) => HasDecls t where

    -- | Return the HsDecls that are directly enclosed in the
    -- given syntax phrase. They are always returned in the wrapped HsDecl form,
    -- even if orginating in local decls.
    hsDecls :: t -> Transform [GHC.LHsDecl GHC.RdrName]

    -- | Replace the directly enclosed decl list by the given
    --  decl list. Runs in the ghc-exactprint Transform Monad to be able to
    --  update list order annotations.
    replaceDecls :: t -> [GHC.LHsDecl GHC.RdrName] -> Transform t

-- ---------------------------------------------------------------------

instance HasDecls GHC.ParsedSource where
  hsDecls (GHC.L _ (GHC.HsModule _mn _exps _imps decls _ _)) = return decls
  replaceDecls m@(GHC.L l (GHC.HsModule mn exps imps _decls deps haddocks)) decls
    = do
        modifyAnnsT (captureOrder m decls)
        return (GHC.L l (GHC.HsModule mn exps imps decls deps haddocks))

-- ---------------------------------------------------------------------

instance HasDecls (GHC.MatchGroup GHC.RdrName (GHC.LHsExpr GHC.RdrName)) where
  hsDecls (GHC.MG matches _ _ _) = hsDecls matches

  replaceDecls (GHC.MG matches a r o) newDecls
    = do
        matches' <- (replaceDecls matches newDecls)
        return (GHC.MG matches' a r o)

-- ---------------------------------------------------------------------

instance HasDecls [GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)] where
  hsDecls ms = do
    ds <- mapM hsDecls ms
    return (concat ds)

  replaceDecls [] _        = error "empty match list in replaceDecls [GHC.LMatch GHC.Name]"
  replaceDecls ms newDecls
    = do
        -- ++AZ++: TODO: this one looks dodgy
        m' <- (replaceDecls (ghead "replaceDecls" ms) newDecls)
        return (m':tail ms)

-- ---------------------------------------------------------------------

instance HasDecls (GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)) where
  hsDecls (GHC.L l (GHC.Match _ _ _ grhs)) = hsDecls grhs

  replaceDecls m@(GHC.L l (GHC.Match mf p t (GHC.GRHSs rhs binds))) newBinds
    = do
        -- Need to throw in a fresh where clause if the binds were empty,
        -- in the annotations.
        newBinds2 <- case binds of
          GHC.EmptyLocalBinds -> do
            let
              addWhere mkds =
                case Map.lookup (mkAnnKey m) mkds of
                  Nothing -> error "wtf"
                  Just ann -> Map.insert (mkAnnKey m) ann1 mkds
                    where
                      ann1 = ann { annsDP = annsDP ann ++ [(G GHC.AnnWhere,DP (1,2))]
                                 }
            modifyKeywordDeltasT addWhere
            newBinds' <- mapM pushDeclAnnT newBinds
            modifyAnnsT (captureOrderAnnKey (mkAnnKey m) newBinds')
            modifyAnnsT (\ans -> setPrecedingLinesDecl ans (ghead "LMatch.replaceDecls" newBinds') 1 4)
            return newBinds'

          _ -> do
            -- ++AZ++ TODO: move the duplicate code out of the case statement
            newBinds' <- mapM pushDeclAnnT newBinds
            modifyAnnsT (captureOrderAnnKey (mkAnnKey m) newBinds')
            -- modifyAnnsT (\ans -> setPrecedingLinesDecl ans (ghead "LMatch.replaceDecls.2" newBinds') 1 4)
            return newBinds'

        binds' <- replaceDecls binds newBinds2
        return (GHC.L l (GHC.Match mf p t (GHC.GRHSs rhs binds')))

-- ---------------------------------------------------------------------

instance HasDecls (GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName)) where
  hsDecls (GHC.GRHSs _ lb) = hsDecls lb

  replaceDecls (GHC.GRHSs rhss b) new
    = do
        b' <- (replaceDecls b new)
        return (GHC.GRHSs rhss b')

-- ---------------------------------------------------------------------

instance HasDecls (GHC.HsLocalBinds GHC.RdrName) where
  hsDecls lb = case lb of
    GHC.HsValBinds (GHC.ValBindsIn bs sigs) -> do
      bds <- mapM wrapDeclT (GHC.bagToList bs)
      sds <- mapM wrapSigT sigs
      -- ++AZ++ TODO: return in annotated order
      return (bds ++ sds)
    GHC.HsValBinds (GHC.ValBindsOut _ _) -> error $ "hsDecls.ValbindsOut not valid"
    GHC.HsIPBinds _     -> return []
    GHC.EmptyLocalBinds -> return []

  replaceDecls (GHC.HsValBinds _b) new
    = do
        let decs = GHC.listToBag $ concatMap decl2Bind new
        let sigs = concatMap decl2Sig new
        return (GHC.HsValBinds (GHC.ValBindsIn decs sigs))

  replaceDecls (GHC.HsIPBinds _b) _new    = error "undefined replaceDecls HsIPBinds"

  replaceDecls (GHC.EmptyLocalBinds) new
    = do
        -- newBinds <- mapM decl2BindT new
        -- newSigs  <- mapM decl2SigT  new
        let newBinds = map decl2Bind new
            newSigs  = map decl2Sig  new
        ans <- getAnnsT
        logTr $ "replaceDecls:newBinds=" ++ showAnnData ans 0 newBinds
        let decs = GHC.listToBag $ concat newBinds
        let sigs = concat newSigs
        return (GHC.HsValBinds (GHC.ValBindsIn decs sigs))

-- ---------------------------------------------------------------------

instance HasDecls (GHC.LHsExpr GHC.RdrName) where
  hsDecls (GHC.L _ (GHC.HsLet decls _ex)) = hsDecls decls
  hsDecls _                               = return []

  replaceDecls (GHC.L l (GHC.HsLet decls ex)) newDecls
    = do
        decls' <- (replaceDecls decls newDecls)
        return (GHC.L l (GHC.HsLet decls' ex))
  replaceDecls old _new = error $ "replaceDecls (GHC.LHsExpr GHC.RdrName) undefined for:" ++ (showGhc old)

-- ---------------------------------------------------------------------

instance HasDecls (GHC.LHsBinds GHC.RdrName) where
  hsDecls binds = hsDecls $ GHC.bagToList binds
  replaceDecls old _new = error $ "replaceDecls (GHC.LHsBinds name) undefined for:" ++ (showGhc old)

-- ---------------------------------------------------------------------

instance HasDecls [GHC.LHsBind GHC.RdrName] where
  hsDecls bs = mapM wrapDeclT bs

  replaceDecls bs newDecls
    = do
        return bs

-- ---------------------------------------------------------------------

instance HasDecls (GHC.LHsBind GHC.RdrName) where
  hsDecls (GHC.L _ (GHC.FunBind _ _ matches _ _ _)) = hsDecls matches
  hsDecls (GHC.L _ (GHC.PatBind _ rhs _ _ _))       = hsDecls rhs
  hsDecls (GHC.L _ (GHC.VarBind _ rhs _))           = hsDecls rhs
  hsDecls (GHC.L _ (GHC.AbsBinds _ _ _ _ binds))    = hsDecls binds
  hsDecls (GHC.L _ (GHC.PatSynBind _))      = error "hsDecls: PatSynBind to implement"


  replaceDecls (GHC.L l (GHC.FunBind a b matches c d e)) newDecls
    = do
        matches' <- (replaceDecls matches newDecls)
        return (GHC.L l (GHC.FunBind a b matches' c d e))
  replaceDecls (GHC.L l (GHC.PatBind a rhs b c d)) newDecls
    = do
        rhs' <- (replaceDecls rhs newDecls)
        return (GHC.L l (GHC.PatBind a rhs' b c d))
  replaceDecls (GHC.L l (GHC.VarBind a rhs b)) newDecls
    = do
        rhs' <- (replaceDecls rhs newDecls)
        return (GHC.L l (GHC.VarBind a rhs' b))
  replaceDecls (GHC.L l (GHC.AbsBinds a b c d binds)) newDecls
    = do
        binds' <- (replaceDecls binds newDecls)
        return (GHC.L l (GHC.AbsBinds a b c d binds'))
  replaceDecls (GHC.L _ (GHC.PatSynBind _)) _ = error "replaceDecls: PatSynBind to implement"

-- ---------------------------------------------------------------------

instance HasDecls (GHC.LHsDecl GHC.RdrName) where
  hsDecls (GHC.L l (GHC.ValD d)) = hsDecls (GHC.L l d)
  -- hsDecls (GHC.L l (GHC.SigD d)) = hsDecls (GHC.L l d)
  hsDecls _                      = return []

  replaceDecls (GHC.L l (GHC.ValD d)) newDecls = do
    (GHC.L l1 d1) <- replaceDecls (GHC.L l d) newDecls
    return (GHC.L l1 (GHC.ValD d1))
  -- replaceDecls (GHC.L l (GHC.SigD d)) newDecls = do
  --   (GHC.L l1 d1) <- replaceDecls (GHC.L l d) newDecls
  --   return (GHC.L l1 (GHC.SigD d1))
  replaceDecls d _  = error $ "LHsDecl.replaceDecls:not implemented"
-}
-- =====================================================================
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

declsFromBinds :: GHC.HsValBinds name -> [GHC.LHsDecl name]
declsFromBinds (GHC.ValBindsIn bs sigs) = ds
  where
    sigds = map (\(GHC.L l s) -> (GHC.L l (GHC.SigD s))) sigs
    binds = map (\(GHC.L l s) -> (GHC.L l (GHC.ValD s))) (GHC.bagToList bs)

    ds = GHC.sortLocated (sigds ++ binds)
declsFromBinds (GHC.ValBindsOut _ _) = error "declsFromBinds:ValBindsOut"

-- ---------------------------------------------------------------------

getValBindSigs :: GHC.HsValBinds GHC.RdrName -> [GHC.LSig GHC.RdrName]
getValBindSigs binds = case binds of
    GHC.ValBindsIn  _  sigs -> sigs
    GHC.ValBindsOut _ _sigs -> []
{-
getValBindSigs :: GHC.HsValBinds GHC.Name -> [GHC.LSig GHC.Name]
getValBindSigs binds = case binds of
    GHC.ValBindsIn  _ sigs -> sigs
    GHC.ValBindsOut _ sigs -> sigs
-}

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

replaceBinds :: (HsValBinds t name) => t -> [GHC.LHsBind name] -> t
-- replaceBinds t bs = replaceValBinds t (GHC.ValBindsIn (GHC.listToBag bs) [])
replaceBinds t bs =
  if isName then error $ "replaceBinds:GHC.ValBindsOut:need to work in rec flag"
                  -- replaceValBinds t (GHC.ValBindsOut (GHC.listToBag bs) sigs)
            else replaceValBinds t (GHC.ValBindsIn (GHC.listToBag bs) sigs)
  where
    isName :: Bool
    isName = case cast bs :: Maybe [GHC.LHsBind GHC.Name] of
      Just _ -> True
      Nothing -> False
    sigs = case hsValBinds t of
      GHC.ValBindsIn  _ s -> s
      GHC.ValBindsOut _ _ -> [] -- Should never happen

-- This class replaces the HsDecls one
class (Data t,Data name) => HsValBinds t name |  t -> name where

    -- | Return the binds that are directly enclosed in the
    -- given syntax phrase.
    -- hsValBinds :: t -> [GHC.LHsBind GHC.Name]
    hsValBinds :: t -> GHC.HsValBinds name

    -- | Replace the directly enclosed bind list by the given
    --  bind list. Note: This function does not modify the
    --  token stream.
    -- replaceBinds :: t -> [GHC.LHsBind GHC.Name] -> t
    replaceValBinds :: t -> GHC.HsValBinds name -> t

    -- | Return True if the specified identifier is declared in the
    -- given syntax phrase.
    -- isDeclaredIn :: GHC.Name -> t -> Bool

    -- | Return the type class definitions that are directly enclosed
    -- in the given syntax phrase. Note: only makes sense for
    -- GHC.RenamedSource
    hsTyDecls :: t -> [[GHC.LTyClDecl name]]


instance HsValBinds GHC.ParsedSource GHC.RdrName where
  hsValBinds (GHC.L _ (GHC.HsModule _ _ _ ds _ _)) = bindsFromDecls ds

  replaceValBinds (GHC.L l (GHC.HsModule mn exps imps ds deps hm)) binds =
    (GHC.L l (GHC.HsModule mn exps imps ds2 deps hm))
    where
      isSig (GHC.L _ (GHC.SigD _)) = True
      isSig _ = False

      isVal (GHC.L _ (GHC.ValD _)) = True
      isVal _ = False

      no_ds = filter (\d -> not (isSig d || isVal d)) ds
      ds' = declsFromBinds binds
      ds2 = GHC.sortLocated (ds' ++ no_ds)

  -- hsTyDecls (grp,_,_,_) = map GHC.group_tyclds (GHC.hs_tyclds grp)
  hsTyDecls (GHC.L _ (GHC.HsModule _ _ _ _ds _ _)) = []

instance HsValBinds GHC.RenamedSource GHC.Name where
  hsValBinds (grp,_,_,_) = (GHC.hs_valds grp)

  replaceValBinds (grp,imps,exps,docs) binds = (grp',imps,exps,docs)
    where
      grp' = grp {GHC.hs_valds = binds}

  hsTyDecls (grp,_,_,_) = map GHC.group_tyclds (GHC.hs_tyclds grp)

instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.HsValBinds name) name where
  hsValBinds vb = vb
  replaceValBinds _old new = new
  hsTyDecls _ = []

instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.HsGroup name) name where
  hsValBinds grp = (GHC.hs_valds grp)

  replaceValBinds (GHC.HsGroup b s t i d f de fo w a r v doc) binds
    = (GHC.HsGroup b' s t i d f de fo w a r v doc)
       where b' = replaceValBinds b binds
  hsTyDecls _ = []

instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.HsLocalBinds name) name where
  hsValBinds lb = case lb of
    GHC.HsValBinds b    -> b
    GHC.HsIPBinds _     -> emptyValBinds
    GHC.EmptyLocalBinds -> emptyValBinds

  replaceValBinds (GHC.HsValBinds _b) new    = (GHC.HsValBinds new)
  replaceValBinds (GHC.HsIPBinds _b) _new    = error "undefined replaceValBinds HsIPBinds"
  replaceValBinds (GHC.EmptyLocalBinds) new  = (GHC.HsValBinds new)

  hsTyDecls _ = []

instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.GRHSs name (GHC.LHsExpr name)) name where
  hsValBinds (GHC.GRHSs _ lb) = hsValBinds lb

  replaceValBinds (GHC.GRHSs rhss b) new = (GHC.GRHSs rhss (replaceValBinds b new))

  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.MatchGroup name (GHC.LHsExpr name)) name where
  hsValBinds (GHC.MG matches _ _ _) = hsValBinds matches

  replaceValBinds (GHC.MG matches a r o) newBinds
               = (GHC.MG (replaceValBinds matches newBinds) a r o)

  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.DataId name,Data name)
  => HsValBinds [GHC.LMatch name (GHC.LHsExpr name)] name where
  hsValBinds ms = unionBinds $ map (\m -> hsValBinds $ GHC.unLoc m) ms

  replaceValBinds [] _        = error "empty match list in replaceValBinds [GHC.LMatch GHC.Name]"
  replaceValBinds ms newBinds = (replaceValBinds (ghead "replaceValBinds" ms) newBinds):(tail ms)

  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.LMatch name (GHC.LHsExpr name)) name where
  hsValBinds m = hsValBinds $ GHC.unLoc m

  replaceValBinds (GHC.L l m) newBinds = (GHC.L l (replaceValBinds m newBinds))

  hsTyDecls _ = []

-- ---------------------------------------------------------------------


instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.Match name (GHC.LHsExpr name)) name where
  hsValBinds (GHC.Match _ _ _ grhs) = hsValBinds grhs

  replaceValBinds (GHC.Match mf p t (GHC.GRHSs rhs _binds)) newBinds
    = (GHC.Match mf p t (GHC.GRHSs rhs binds'))
      where
        binds' = (GHC.HsValBinds newBinds)

  hsTyDecls _ = []

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.HsBind name) name where
  hsValBinds (GHC.PatBind _p rhs _typ _fvs _) = hsValBinds rhs

  -- TODO: ++AZ++ added for compatibility with hsDecls.
  hsValBinds (GHC.FunBind _ _ matches _ _ _) = hsValBinds matches
  hsValBinds other = error $ "hsValBinds (GHC.HsBind name) undefined for:" ++ (showGhc other)

  replaceValBinds (GHC.PatBind p (GHC.GRHSs rhs _binds) typ fvs pt) newBinds
    = (GHC.PatBind p (GHC.GRHSs rhs binds') typ fvs pt)
      where
        binds' = (GHC.HsValBinds newBinds)
  replaceValBinds x _newBinds
      = error $ "replaceValBinds (GHC.HsBind name) undefined for:" ++ (showGhc x)

  hsTyDecls _ = []

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.HsExpr name) name where
  hsValBinds (GHC.HsLet ds _) = hsValBinds ds
  hsValBinds x = error $ "TypeUtils.hsValBinds undefined for:" ++ showGhc x

  replaceValBinds (GHC.HsLet binds ex) new = (GHC.HsLet (replaceValBinds binds new) ex)
  replaceValBinds old _new = error $ "undefined replaceValBinds (GHC.HsExpr name) for:" ++ (showGhc old)

  hsTyDecls _ = []

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.Stmt name (GHC.LHsExpr name)) name where
  hsValBinds (GHC.LetStmt ds) = hsValBinds ds
  hsValBinds other = error $ "hsValBinds (GHC.Stmt name) undefined for:" ++ (showGhc other)
  replaceValBinds (GHC.LetStmt ds) new = (GHC.LetStmt (replaceValBinds ds new))
  replaceValBinds old _new = error $ "replaceValBinds (GHC.Stmt name) undefined for:" ++ (showGhc old)

  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LHsBinds name) name where
  hsValBinds binds = hsValBinds $ GHC.bagToList binds
  replaceValBinds old _new = error $ "replaceValBinds (GHC.LHsBinds name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LHsBind name) name where
  hsValBinds (GHC.L _ (GHC.FunBind _ _ matches _ _ _)) = hsValBinds matches
  hsValBinds (GHC.L _ (GHC.PatBind _ rhs _ _ _))       = hsValBinds rhs
  hsValBinds (GHC.L _ (GHC.VarBind _ rhs _))           = hsValBinds rhs
  hsValBinds (GHC.L _ (GHC.AbsBinds _ _ _ _ binds))    = hsValBinds binds
  hsValBinds (GHC.L _ (GHC.PatSynBind _))      = error "hsValBinds: PaySynBind to implement"


  replaceValBinds (GHC.L l (GHC.FunBind a b matches c d e)) newBinds
               = (GHC.L l (GHC.FunBind a b (replaceValBinds matches newBinds) c d e))
  replaceValBinds (GHC.L l (GHC.PatBind a rhs b c d)) newBinds
               = (GHC.L l (GHC.PatBind a (replaceValBinds rhs newBinds) b c d))
  replaceValBinds (GHC.L l (GHC.VarBind a rhs b)) newBinds
               = (GHC.L l (GHC.VarBind a (replaceValBinds rhs newBinds) b))
  replaceValBinds (GHC.L l (GHC.AbsBinds a b c d binds)) newBinds
               = (GHC.L l (GHC.AbsBinds a b c d (replaceValBinds binds newBinds)))
  replaceValBinds (GHC.L _ (GHC.PatSynBind _)) _ = error "replaceValBind: PatSynBind to implement"

  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.DataId name,Data name)
  => HsValBinds ([GHC.LHsBind name]) name where
  -- hsValBinds xs = concatMap hsValBinds xs -- As in original
  hsValBinds xs = GHC.ValBindsIn (GHC.listToBag xs) []

  replaceValBinds _old (GHC.ValBindsIn b _sigs) = GHC.bagToList b
  replaceValBinds _old (GHC.ValBindsOut rbinds _sigs) = GHC.bagToList $ GHC.unionManyBags $ map (\(_,b) -> b) rbinds

  -- replaceValBinds old new = error ("replaceValBinds (old,new)=" ++ (showGhc (old,new)))

  hsTyDecls _ = []

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LHsExpr name) name where
  hsValBinds (GHC.L _ (GHC.HsLet binds _ex)) = hsValBinds binds
  hsValBinds _                               = emptyValBinds

  replaceValBinds (GHC.L l (GHC.HsLet binds ex)) newBinds
     = (GHC.L l (GHC.HsLet (replaceValBinds binds newBinds) ex))
  replaceValBinds old _new = error $ "replaceValBinds (GHC.LHsExpr name) undefined for:" ++ (showGhc old)

  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LGRHS name (GHC.LHsExpr name)] name where
  hsValBinds xs = unionBinds $ map hsValBinds xs
  replaceValBinds _old _new = error $ "replaceValBinds [GHC.LGRHS name] undefined for:" -- ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LGRHS name (GHC.LHsExpr name)) name where
  hsValBinds (GHC.L _ (GHC.GRHS stmts _expr)) = hsValBinds stmts
  replaceValBinds _old _new = error $ "replaceValBinds (GHC.LHGRHS name) undefined for:" -- ++ (showGhc _old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LStmt name (GHC.LHsExpr name)] name where
  hsValBinds xs = unionBinds $ map hsValBinds xs
  replaceValBinds old _new = error $ "replaceValBinds [GHC.LStmt name] undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LStmt name (GHC.LHsExpr name)) name where
  hsValBinds (GHC.L _ (GHC.LetStmt binds)) = hsValBinds binds
  hsValBinds _                             = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds (GHC.LStmt name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LPat name] name where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds (GHC.LPat name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LPat name) name where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds (GHC.LPat name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------


instance HsValBinds (GHC.Name) GHC.Name where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds (GHC.Name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []


-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.SyntaxExpr name] name where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds (GHC.SyntaxExpr name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.TyClGroup name) name where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds (GHC.TyClGroup name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.TyClGroup name] name where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds [GHC.TyClGroup name] undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [[GHC.LTyClDecl name]] name where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds [[GHC.LTyClDecl name]] undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LTyClDecl name] name where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds [GHC.LTyClDecl name] undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LTyClDecl name) name where
  hsValBinds _ = error $ "hsValBinds (GHC.LTyClDecl name) must pull out tcdMeths"
  replaceValBinds old _new = error $ "replaceValBinds (GHC.LTyClDecl name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LTyFamInstDecl name] name where
  hsValBinds _ = error $ "hsValBinds [GHC.LTyFamInstDecl name] must pull out tcdMeths"
  replaceValBinds old _new = error $ "replaceValBinds [GHC.LTyFamInstDecl name] undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LDataFamInstDecl name] name where
  hsValBinds _ = error $ "hsValBinds [GHC.LDataFamInstDecl name] must pull out tcdMeths"
  replaceValBinds old _new = error $ "replaceValBinds [GHC.LDataFamInstDecl name] undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.DataId name,Data name)
  => HsValBinds [GHC.LTyFamInstEqn name] name where
  hsValBinds _ = error $ "hsValBinds [GHC.LTyFamInstEqn name] must pull out tcdMeths"
  replaceValBinds _old _new = error $ "replaceValBinds [GHC.LTyFamInstEqn name] undefined for:"
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.DataId name,Data name)
  => HsValBinds (GHC.LTyFamInstEqn name) name where
  hsValBinds _ = error $ "hsValBinds (GHC.LTyFamInstEqn name) must pull out tcdMeths"
  replaceValBinds _old _new = error $ "replaceValBinds (GHC.LTyFamInstEqn name) undefined for:"
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.HsDataDefn name) name where
  hsValBinds _ = error $ "hsValBinds (GHC.HsDataDefn name) must pull out tcdMeths"
  replaceValBinds old _new = error $ "replaceValBinds (GHC.HsDataDefn name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.HsTyPats name) name where
  hsValBinds _ = error $ "hsValBinds (GHC.HsTyPats name) must pull out tcdMeths"
  replaceValBinds old _new = error $ "replaceValBinds (GHC.HsTyPats name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LInstDecl name] name where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds [GHC.LInstDecl name] undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LInstDecl name) name where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds (GHC.LInstDecl name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LHsType name] name where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds (GHC.LHsType name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LHsType name) name where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds (GHC.LHsType name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds [GHC.LSig name] name where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds [GHC.LSig name] undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.LSig name) name where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds (GHC.LSig name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------
{-
instance HsValBinds [GHC.LFamInstDecl name] where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds [GHC.LFamInstDecl name] undefined for:" ++ (showGhc old)
  hsTyDecls _ = []
-}
-- ---------------------------------------------------------------------
{-
instance HsValBinds (GHC.LFamInstDecl name) where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds (GHC.LFamInstDecl name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []
-}

-- ---------------------------------------------------------------------

instance (GHC.OutputableBndr name,GHC.DataId name,Data name)
  => HsValBinds (GHC.HsIPBinds name) name where
  hsValBinds _ = emptyValBinds
  replaceValBinds old _new = error $ "replaceValBinds (GHC.HsIPBinds name) undefined for:" ++ (showGhc old)
  hsTyDecls _ = []

-- ---------------------------------------------------------------------
