{-# LANGUAGE CPP #-}
{-# LANGUAGE StandaloneDeriving   #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE ScopedTypeVariables  #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

-- |
--

module Language.Haskell.Refact.Utils.Layout (
    initTokenLayout
  , nullTokenLayout
  , allocTokens
  , retrieveTokens
  , getLoc

  -- * For testing
  , addEndOffsets
  ) where

import qualified Bag           as GHC
import qualified ForeignCall   as GHC
import qualified GHC           as GHC

import Outputable

import qualified GHC.SYB.Utils as SYB

import Data.List
import Data.Tree
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.LayoutTypes
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn

-- import qualified Data.Tree.Zipper as Z

-- ---------------------------------------------------------------------

-- | Extract the layout-sensitive parts of the GHC AST.

-- The layout keywords are `let`, `where`, `of` and `do`. The
-- expressions introduced by them need to be kept indented at the same
-- level.

{-

AST Items for layout keywords.

(gleaned from Parser.y.pp in the ghc sources)

`let`


@
  HsLet
    HsLet (HsLocalBinds id) (LHsExpr id) :: HsExpr id
              ^^keep aligned

  LetStmt
    LetStmt (HsLocalBindsLR idL idR) :: StmtLR idL idR
                ^^keep aligned
@

`where`

@
  HsModule
    -- not relevant to layout

  ClassDecl :: TyClDecl
    ClassDecl ....

  ClsInstD :: InstDecl
    ClsInstD typ binds sigs [fam_insts]
            ^^the binds, sigs, fam_insts should all align

  GRHSs
    GRHS [LStmt id] (LHsExpr id)
           ^^keep aligned

  TyDecl ::  TyClDecl
    TyDecl name vars defn fvs
                      ^^keep aligned
      [The `where` is in the defn]

  FamInstDecl
    FamInstDecl tycon pats defn fvs
                            ^^keep aligned
      [The `where` is in the defn]
@

`of`

@
  HsCase :: HsExpr
    HsCase (LHsExpr id) (MatchGroup id)
                           ^^keep aligned
@

`do`

@
  DoExpr :: HsExpr
    HsDo (HsStmtContext Name) [LStmt id] PostTcType
                                 ^^keep aligned
@
-}

-- Pretty print combinators of interest
--
-- ($$) :: Doc -> Doc -> Doc
--
--   Above, except that if the last line of the first argument stops at
--   least one position before the first line of the second begins,
--   these two lines are overlapped.
--
--
-- ($+$) :: Doc -> Doc -> Doc
--
--   Above, with no overlapping.
--
--
-- nest :: Int -> Doc -> Doc
--
--   Nest (or indent) a document by a given number of positions
--   (which may also be negative)
--
--
-- hang :: Doc -> Int -> Doc -> Doc
--
--   hang d1 n d2 = sep [d1, nest n d2]
--


-- ---------------------------------------------------------------------

deriving instance Show Label

instance Outputable (Tree Entry) where
  ppr (Node label subs) = hang (text "Node") 2 (vcat [ppr label,ppr subs])

instance Outputable Entry where
  ppr (Entry sspan lay toks) = text "Entry" <+> ppr sspan <+> ppr lay <+> text (show toks)
  ppr (Deleted sspan pg eg)     = text "Deleted" <+> ppr sspan <+> ppr pg <+> ppr eg

instance Outputable Layout where
  ppr (Above so p1 p2 oe)   = text "Above" <+> ppr so <+> ppr p1 <+> ppr p2 <+> ppr oe
  -- ppr (Offset r c)    = text "Offset" <+> ppr r <+> ppr c
  ppr (NoChange)      = text "NoChange"
  -- ppr (EndOffset r c) = text "EndOffset" <+> ppr r <+> ppr c

instance Outputable PprOrigin where
  ppr Original = text "Original"
  ppr Added    = text "Added"

instance Outputable Ppr where
  ppr (PprText r c o str) = text "PprText" <+> ppr r <+> ppr c <+> ppr o
                        <+> text "\"" <> text str <> text "\""
  ppr (PprAbove so rc erc pps) = hang (text "PprAbove" <+> ppr so <+> ppr rc <+> ppr erc)
                                           2 (ppr pps)
  -- ppr (PprOffset ro co pps)       = hang (text "PprOffset" <+> ppr ro <+> ppr co)
  --                                          2 (ppr pps)
  ppr (PprDeleted ro co lb l la)     = text "PprDeleted" <+> ppr ro <+> ppr co
                                           <+> ppr lb <+> ppr l <+> ppr la
                                         --  <+> ppr n

instance Outputable EndOffset where
  ppr None               = text "None"
  ppr (SameLine co)      = text "SameLine" <+> ppr co
  ppr (FromAlignCol off) = text "FromAlignCol" <+> ppr off

-- ---------------------------------------------------------------------

initTokenLayout :: GHC.ParsedSource -> [PosToken] -> LayoutTree
initTokenLayout parsed toks = (allocTokens parsed toks)

nullTokenLayout :: TokenLayout
-- nullTokenLayout = TL (Leaf nullSrcSpan NoChange [])
nullTokenLayout = TL (Node (Entry (sf nullSrcSpan) NoChange []) [])

-- ---------------------------------------------------------------------

-- TODO: bring in startEndLocIncComments'
allocTokens :: GHC.ParsedSource -> [PosToken] -> LayoutTree
allocTokens (GHC.L _l (GHC.HsModule maybeName maybeExports imports decls _warns _haddocks)) toks = r
  where
    (nameLayout,toks1) =
      case maybeName of
        Nothing -> ([],toks)
        Just (GHC.L ln _modName) -> ((makeLeafFromToks s1) ++ [makeLeaf ln NoChange modNameToks],toks')
          where
            (s1,modNameToks,toks') = splitToksIncComments (ghcSpanStartEnd ln) toks

    (exportLayout,toks2) =
      case maybeExports of
        Nothing -> ([],toks1)
        Just exps -> ((makeLeafFromToks s2) ++ (makeLeafFromToks expToks),toks2')
          where
            (s2,expToks,toks2') = splitToksForList exps toks1

    (importLayout,toks3) =
      case imports of
        [] -> ([],toks2)
        is -> ((makeLeafFromToks s3) ++ (makeLeafFromToks impToks),toks3')
          where
            (s3,impToks,toks3') = splitToksForList is toks2

    (declLayout,toks4) =
      case decls of
        [] -> ([],toks3)
        is -> ((makeLeafFromToks s4) ++ allocDecls is declToks ++ (makeLeafFromToks toks4'),[])
          where
            (s4,declToks,toks4') = splitToksForList is toks3

    r' = makeGroup (strip $ nameLayout ++ exportLayout ++ importLayout ++ declLayout ++ (makeLeafFromToks toks4))
    r = addEndOffsets r' toks

-- ---------------------------------------------------------------------


addEndOffsets :: LayoutTree -> [PosToken] -> LayoutTree
addEndOffsets tree toks = go tree
  where
    go (t@(Node (Entry _ _ _toks) [])) = t
    go (  (Node (Entry s (Above so p1 (r,c) _eo) []) subs))
        = (Node (Entry s (Above so p1 (r,c) eo') []) (map go subs))
      where
        -- (_,m,_) = splitToksIncComments ((r,c),(99999,1)) toks
        (_,m,_) = splitToks ((r,c),(99999,1)) toks
        eo' = case m of
                []  -> None
                [_] -> None
                xs  -> if ro' /= 0 then FromAlignCol off
                                   else SameLine co'
                  where
                   -- off@(ro',co') = case (dropWhile isWhiteSpace $ tail xs) of
                   -- off@(ro',co') = case (dropWhile isWhiteSpace xs) of
                   off@(ro',co') = case (dropWhile isEmpty xs) of
                     []    -> (tokenRow y - r, tokenCol y - c) where y = head $ tail xs
                     (y:_) -> (tokenRow y - r, tokenCol y - c)
    go (  (Node (Entry s l []) subs)) = (Node (Entry s l []) (map go subs))
    go n = error $ "addEndOffsets:strange node:" ++ (show n)

-- ---------------------------------------------------------------------

allocDecls :: [GHC.LHsDecl GHC.RdrName] -> [PosToken] -> [LayoutTree]
allocDecls decls toks = r
  where
    (declLayout,tailToks) = foldl' doOne ([],toks) decls

    r = strip $ declLayout ++ (makeLeafFromToks tailToks)

    doOne :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
    doOne acc d@(GHC.L _ (GHC.TyClD       _)) = allocTyClD       acc d
    doOne acc d@(GHC.L _ (GHC.InstD       _)) = allocInstD       acc d
    doOne acc d@(GHC.L _ (GHC.DerivD      _)) = allocDerivD      acc d
    doOne acc d@(GHC.L _ (GHC.ValD        _)) = allocValD        acc d
    doOne acc d@(GHC.L _ (GHC.SigD        _)) = allocSigD        acc d
    doOne acc d@(GHC.L _ (GHC.DefD        _)) = allocDefD        acc d
    doOne acc d@(GHC.L _ (GHC.ForD        _)) = allocForD        acc d
    doOne acc d@(GHC.L _ (GHC.WarningD    _)) = allocWarningD    acc d
    doOne acc d@(GHC.L _ (GHC.AnnD        _)) = allocAnnD        acc d
    doOne acc d@(GHC.L _ (GHC.RuleD       _)) = allocRuleD       acc d
    doOne acc d@(GHC.L _ (GHC.VectD       _)) = allocVectD       acc d
    doOne acc d@(GHC.L _ (GHC.SpliceD     _)) = allocSpliceD     acc d
    doOne acc d@(GHC.L _ (GHC.DocD        _)) = allocDocD        acc d
    doOne acc d@(GHC.L _ (GHC.QuasiQuoteD _)) = allocQuasiQuoteD acc d

-- ---------------------------------------------------------------------

allocTyClD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocTyClD (acc,toks) (GHC.L l (GHC.TyClD d)) = (r,toks')
  where
    (s1,clToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    declLayout = allocLTyClDecl (GHC.L l d) clToks
    r = acc ++ [makeGroup (strip $ (makeLeafFromToks s1) ++ declLayout)]
allocTyClD _ x = error $ "allocTyClD:unexpected value:" ++ showGhc x

-- ---------------------------------------------------------------------

allocInstD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocInstD (acc,toks) (GHC.L l (GHC.InstD inst)) = (r,toks')
  where
    (s1,instToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    instLayout = allocInstDecl (GHC.L l inst) instToks
    r = acc ++ [makeGroup (strip $ (makeLeafFromToks s1) ++ [makeGroup instLayout] )]
allocInstD _ x = error $ "allocInstD:unexpected value:" ++ showGhc x

-- ---------------------------------------------------------------------

allocDerivD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocDerivD (acc,toks) (GHC.L l (GHC.DerivD (GHC.DerivDecl typ))) = (r,toks')
  where
    (s1,bindToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    typLayout = allocType typ bindToks
    r = acc ++ [makeGroup (strip $ (makeLeafFromToks s1) ++ [makeGroup typLayout] )]
allocDerivD _ x = error $ "allocDerivD:unexpected value:" ++ showGhc x

-- ---------------------------------------------------------------------

allocValD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocValD (acc,toks) (GHC.L l (GHC.ValD bind)) = (r,toks')
  where
    (s1,bindToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    bindLayout = allocBind (GHC.L l bind) bindToks
    r = acc ++ [makeGroup (strip $ (makeLeafFromToks s1) ++ [makeGroup bindLayout] )]
allocValD _ x = error $ "allocValD:unexpected value:" ++ showGhc x

-- ---------------------------------------------------------------------

allocSigD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocSigD (acc,toks) (GHC.L l (GHC.SigD sig)) = (r,toks')
  where
    (s1,sigToks,toks')  = splitToksIncComments (ghcSpanStartEnd l) toks
    sigLayout = allocSig (GHC.L l sig) sigToks
    r = acc ++ [makeGroup (strip $ (makeLeafFromToks s1)
                     ++ sigLayout)]
allocSigD _ x = error $ "allocSigD:unexpected value:" ++ showGhc x

-- ---------------------------------------------------------------------

allocDefD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocDefD (acc,toks) (GHC.L l (GHC.DefD (GHC.DefaultDecl typs))) = (r,toks')
  where
    (s1,typsToks,toks')  = splitToksIncComments (ghcSpanStartEnd l) toks
    typsLayout = allocList typs typsToks allocType
    r = acc ++ [makeGroup (strip $ (makeLeafFromToks s1)
                     ++ typsLayout)]
allocDefD _ x = error $ "allocDefD:unexpected value:" ++ showGhc x

-- ---------------------------------------------------------------------

allocForD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocForD (acc,toks) (GHC.L l (GHC.ForD (GHC.ForeignImport (GHC.L ln _) typ@(GHC.L lt _) _coer _imp))) = (r,toks')
  where
    (s1,declToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nameToks,toks1) = splitToksIncComments (ghcSpanStartEnd ln) declToks
    (s3,typToks,toks2)  = splitToksIncComments (ghcSpanStartEnd lt) toks1
    nameLayout = [makeLeaf ln NoChange nameToks]
    typLayout = allocType typ typToks
    r = acc ++ [makeGroup (strip $ (makeLeafFromToks s1)
                      ++ (makeLeafFromToks s2) ++ nameLayout
                      ++ (makeLeafFromToks s3) ++ typLayout
                      ++ (makeLeafFromToks toks2))]
allocForD (acc,toks) (GHC.L l (GHC.ForD (GHC.ForeignExport (GHC.L ln _) typ@(GHC.L lt _) _coer _imp))) = (r,toks')
  where
    (s1,declToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nameToks,toks1) = splitToksIncComments (ghcSpanStartEnd ln) declToks
    (s3,typToks,toks2)  = splitToksIncComments (ghcSpanStartEnd lt) toks1
    nameLayout = [makeLeaf ln NoChange nameToks]
    typLayout = allocType typ typToks
    r = acc ++ [makeGroup (strip $ (makeLeafFromToks s1)
                      ++ (makeLeafFromToks s2) ++ nameLayout
                      ++ (makeLeafFromToks s3) ++ typLayout
                      ++ (makeLeafFromToks toks2))]
allocForD _ x = error $ "allocForD:unexpected value:" ++ showGhc x

-- ---------------------------------------------------------------------

allocWarningD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocWarningD (acc,toks) (GHC.L _l (GHC.WarningD _)) = (acc,toks)
allocWarningD _ x = error $ "allocWarningD:unexpected value:" ++ showGhc x

-- ---------------------------------------------------------------------

allocAnnD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocAnnD (acc,toks) (GHC.L _l (GHC.AnnD _)) = (acc,toks)
allocAnnD _ x = error $ "allocAnnD:unexpected value:" ++ showGhc x

-- ---------------------------------------------------------------------

allocRuleD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocRuleD (acc,toks) (GHC.L _l (GHC.RuleD _)) = (acc,toks)
allocRuleD _ x = error $ "allocRuleD:unexpected value:" ++ showGhc x

-- ---------------------------------------------------------------------

allocVectD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocVectD (acc,toks) (GHC.L _l (GHC.VectD       _)) = (acc,toks)
allocVectD _ x = error $ "allocVectD:unexpected value:" ++ showGhc x

-- ---------------------------------------------------------------------

allocSpliceD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocSpliceD (acc,toks) (GHC.L l (GHC.SpliceD (GHC.SpliceDecl ex _))) = (r,toks')
  where
    (s1,exprToks,toks')  = splitToksIncComments (ghcSpanStartEnd l) toks
    exprLayout = allocExpr ex exprToks
    r = acc ++ [makeGroup (strip $ (makeLeafFromToks s1)
                     ++ exprLayout)]
allocSpliceD _ x = error $ "allocSpliceD:unexpected value:" ++ showGhc x

-- ---------------------------------------------------------------------

allocDocD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
-- allocDocD (acc,toks) d@(GHC.L l (GHC.DocD        _))
--   = error "allocDocD undefined"
allocDocD _ x = error $ "allocDocD:unexpected value:" ++ showGhc x

-- ---------------------------------------------------------------------

allocQuasiQuoteD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocQuasiQuoteD (acc,toks) (GHC.L l (GHC.QuasiQuoteD (GHC.HsQuasiQuote _n _ss _))) = (r,toks')
  where
    (s1,qqToks,toks')  = splitToksIncComments (ghcSpanStartEnd l) toks
    qqLayout = makeLeafFromToks qqToks
    r = acc ++ [makeGroup (strip $ (makeLeafFromToks s1)
                     ++ qqLayout)]
allocQuasiQuoteD _ x = error $ "allocQuasiQuoteD:unexpected value:" ++ showGhc x

-- ---------------------------------------------------------------------

allocLTyClDecl :: GHC.LTyClDecl GHC.RdrName -> [PosToken] -> [LayoutTree]
allocLTyClDecl (GHC.L l (GHC.ForeignType ln _)) toks = r
  where
    (s1,clToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    lnToks = allocLocated ln clToks
    r = [makeGroup (strip $ (makeLeafFromToks s1) ++ lnToks ++ (makeLeafFromToks toks'))]
allocLTyClDecl (GHC.L l (GHC.TyFamily _f n@(GHC.L ln _) vars _mk)) toks = r
  where
    (s1,clToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nToks,varsToks) = splitToksIncComments (ghcSpanStartEnd ln) toks'
    nLayout = allocLocated n nToks
#if __GLASGOW_HASKELL__ > 704
    (varsLayout,s3) = allocTyVarBndrs vars varsToks
#else
    varsLayout = allocList vars varsToks allocTyVarBndr
    s3 = []
#endif
    r = [makeGroup (strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks clToks)
                     ++ (makeLeafFromToks s2) ++ nLayout ++ varsLayout
                     ++ (makeLeafFromToks s3)
                     ++ (makeLeafFromToks toks'))
        ]
#if __GLASGOW_HASKELL__ > 704
allocLTyClDecl (GHC.L l (GHC.TyDecl (GHC.L ln _) vars def _fvs)) toks = r
  where
    (s1,clToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nToks,toks'') = splitToksIncComments (ghcSpanStartEnd ln) clToks
    (varsLayout,toks3) = allocTyVarBndrs vars toks''
    (typeLayout,toks4) = allocHsTyDefn def toks3
    r = [makeGroup (strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
                     ++ (makeLeafFromToks nToks) ++ varsLayout ++ typeLayout
                     ++ (makeLeafFromToks toks4)
             ++ (makeLeafFromToks toks'))]
#else
allocLTyClDecl (GHC.L l (GHC.TyData _ (GHC.L lc ctx) (GHC.L ln _) vars mpats mkind cons mderivs)) toks = r
  where
    (s1,clToks,toks')    = splitToksIncComments (ghcSpanStartEnd l) toks
    (s15,ctxToks,toks'a) = splitToksIncComments (ghcSpanStartEnd lc) clToks
    (s2,nToks,toks'')    = splitToksIncComments (ghcSpanStartEnd ln) toks'a
    (s21,vToks,toks3)    = splitToksForList vars toks''
    ctxLayout = allocHsContext ctx ctxToks
    varsLayout = allocList vars vToks allocTyVarBndr
    (patsLayout,toks4) = case mpats of
       Nothing -> ([],toks3)
       Just pats -> ([makeGroup (strip $ (makeLeafFromToks s3) ++ (allocList pats patsToks allocType))],toks4')
          where (s3,patsToks,toks4') = splitToksForList pats toks3
    (kindLayout,toks5) = case mkind of
       Nothing -> ([],toks4)
       Just k@(GHC.L lk _k) -> (kLayout,toks5')
         where
           (s4,kToks,toks5') = splitToksIncComments (ghcSpanStartEnd lk) toks4
           kLayout = [makeGroup (strip $ (makeLeafFromToks s4) ++ allocHsKind k kToks)]
    (s5,consToks,toks6) = splitToksForList cons toks5
    consLayout = [makeGroup (strip $ (makeLeafFromToks s5) ++ (allocList cons consToks allocConDecl))]
    (derivsLayout,toks7) = case mderivs of
      Nothing -> ([],toks6)
      Just derivs -> (dLayout,toks7')
        where
          (s6,dToks,toks7') = splitToksForList derivs toks6
          dLayout = [makeGroup (strip $ (makeLeafFromToks s6) ++ (allocList derivs dToks allocType))]

    r = [makeGroup (strip $ (makeLeafFromToks s1)
                     ++ (makeLeafFromToks s15)
                     ++ ctxLayout
                     ++ (makeLeafFromToks s2)
                     ++ (makeLeafFromToks nToks)
                     ++ (makeLeafFromToks s21)
                     ++ varsLayout ++ patsLayout
                     ++ kindLayout
                     ++ consLayout ++ derivsLayout
                     ++ (makeLeafFromToks toks7)
                     ++ (makeLeafFromToks toks')
         )]
{-
tcdND :: NewOrData
tcdCtxt :: LHsContext name

    Context...

    Context 
tcdLName :: Located name

    Name of the class

    type constructor

    Type constructor 
tcdTyVars :: [LHsTyVarBndr name]

    Class type variables

    type variables

    Type variables 
tcdTyPats :: Maybe [LHsType name]

    Type patterns See Note [tcdTyVars and tcdTyPats]

    Type patterns. See Note [tcdTyVars and tcdTyPats] 
tcdKindSig :: Maybe (LHsKind name)

    Optional kind signature.

    (Just k) for a GADT-style data, or data instance decl with explicit kind sig 
tcdCons :: [LConDecl name]

    Data constructors

    For data T a = T1 | T2 a the LConDecls all have ResTyH98. For data T a where { T1 :: T a } the LConDecls all have ResTyGADT. 
tcdDerivs :: Maybe [LHsType name]

    Derivings; Nothing => not specified, Just [] => derive exactly what is asked

    These types must be of form forall ab. C ty1 ty2 Typically the foralls and ty args are empty, but they are non-empty for the newtype-deriving case 
-}
#endif
#if __GLASGOW_HASKELL__ > 704
allocLTyClDecl (GHC.L l (GHC.ClassDecl (GHC.L lc ctx) n@(GHC.L ln _) vars fds sigs meths ats atdefs docs _fvs)) toks = r
#else
allocLTyClDecl (GHC.L l (GHC.ClassDecl (GHC.L lc ctx) n@(GHC.L ln _) vars fds sigs meths ats atdefs docs     )) toks = r
#endif
  where
    (s1,clToks,  toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,ctxToks, toks1) = splitToksIncComments (ghcSpanStartEnd lc) clToks
    (s3,nToks,   toks2) = splitToksIncComments (ghcSpanStartEnd ln) toks1
#if __GLASGOW_HASKELL__ > 704
    (varsLayout, toks3) = allocTyVarBndrs vars toks2
#else
    varsLayout = allocList vars toks2 allocTyVarBndr
    toks3 = [] -- hmm
#endif
    (s5,fdToks,  toks4) = splitToksForList fds toks3

    ctxLayout = allocHsContext ctx ctxToks
    nLayout   = allocLocated n nToks
    -- fdsLayout = allocList fds fdToks allocFunDep
    fdsLayout = makeLeafFromToks fdToks

    bindList = GHC.bagToList meths
    sigMix     = makeMixedListEntry sigs     (shim allocSig)
    methsMix   = makeMixedListEntry bindList (shim allocBind)
    atsMix     = makeMixedListEntry ats      (shim allocLTyClDecl)
#if __GLASGOW_HASKELL__ > 704
    atsdefsMix = makeMixedListEntry atdefs   (shim allocLFamInstDecl)
#else
    atsdefsMix = makeMixedListEntry atdefs   (shim allocLTyClDecl)
#endif
    docsMix    = makeMixedListEntry docs     (shim allocLocated)

    bindsLayout = allocMixedList (sigMix++methsMix++atsMix++atsdefsMix++docsMix) toks4

    r = [makeGroup $ strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ ctxLayout ++ (makeLeafFromToks s3)
             ++ nLayout ++ varsLayout ++ (makeLeafFromToks s5)
             ++ fdsLayout ++ bindsLayout
             ++ (makeLeafFromToks toks')
        ]

#if __GLASGOW_HASKELL__ > 704
#else
allocLTyClDecl (GHC.L l (GHC.TySynonym n@(GHC.L ln _) vars mpats synrhs@(GHC.L lr _))) toks = r
  where
    (s1,clToks,toks')   = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nToks,toks2)    = splitToksIncComments (ghcSpanStartEnd ln) clToks
    (s25,vToks,toks3)    = splitToksForList vars toks2
    (patsLayout,toks4) = case mpats of
       Nothing -> ([],toks3)
       Just pats -> ([makeGroup (strip $ (makeLeafFromToks s3) ++ (allocList pats patsToks allocType))],toks4')
          where (s3,patsToks,toks4') = splitToksForList pats toks3
    (s4,rToks,toks5)    = splitToksIncComments (ghcSpanStartEnd lr) toks4
    varsLayout = allocList vars vToks allocTyVarBndr
    synrhsLayout = allocType synrhs rToks

    r = [makeGroup (strip $ (makeLeafFromToks s1)
                     ++ (makeLeafFromToks s2)
                     ++ (makeLeafFromToks nToks)
                     ++ (makeLeafFromToks s25)
                     ++ varsLayout ++ patsLayout
                     ++ (makeLeafFromToks s4)
                     ++ synrhsLayout
                     ++ (makeLeafFromToks toks5)
                     ++ (makeLeafFromToks toks')
         )]
#endif

allocLTyClDecl x _ = error $ "allocLTyClDecl:unknown value:" ++ showGhc x

-- ---------------------------------------------------------------------

allocMatches :: [GHC.LMatch GHC.RdrName] -> [PosToken] -> [LayoutTree]
allocMatches matches toksIn = allocList matches toksIn doOne
  where
    doOne :: GHC.LMatch GHC.RdrName -> [PosToken] -> [LayoutTree]
    doOne (GHC.L lm (GHC.Match pats mtyp grhs@(GHC.GRHSs rhs _))) toks = r
      where
        (sb,matchToks,sa) = splitToksIncComments (ghcSpanStartEnd lm) toks
        (s2,patsToks,toks2) = splitToksForList pats matchToks
        (mtypLayout,toks') = case mtyp of
          Nothing -> ([],toks2)
          Just (typ@(GHC.L l _)) -> (typeLayout,toks'')
            where
              (t1,typToks,toks'') = splitToksIncComments (ghcSpanStartEnd l) toks2
              typeLayout = strip $ (makeLeafFromToks t1) ++ allocType typ typToks

        (s3,rhsToks,bindsToks) = splitToksForList rhs toks'
        -- patLayout = allocList pats patsToks allocPat

        -- Insert a SrcSpan over the parameters, if there are any
        patLayout = case (strip $ allocList pats patsToks allocPat) of
                     [] -> []
                     ps -> [makeGroup ps]

        grhsLayout = allocGRHSs grhs (rhsToks++bindsToks)
        matchLayout = [makeGroup $ strip $ (makeLeafFromToks s2)
                           ++ patLayout
                           ++ mtypLayout
                           ++ (makeLeafFromToks s3)
                           ++ grhsLayout
                      ]
        r = (strip $ (makeLeafFromToks sb)
                  ++ matchLayout
                  ++ (makeLeafFromToks sa))


-- ---------------------------------------------------------------------

allocGRHSs :: GHC.GRHSs GHC.RdrName -> [PosToken] -> [LayoutTree]
allocGRHSs (GHC.GRHSs rhs localBinds) toks = r
  where
    (s1,rhsToks,bindsToks) = splitToksForList rhs toks
    rhsLayout = allocList rhs rhsToks allocRhs
    localBindsLayout = allocLocalBinds localBinds bindsToks
    r = (strip $ (makeLeafFromToks s1) ++ rhsLayout ++ localBindsLayout)

-- ---------------------------------------------------------------------

-- TODO: should this use the span from the LPat?
allocPat :: GHC.LPat GHC.RdrName -> [PosToken] -> [LayoutTree]
allocPat (GHC.L _ _) toks = makeLeafFromToks toks

-- ---------------------------------------------------------------------

allocRhs :: GHC.LGRHS GHC.RdrName -> [PosToken] -> [LayoutTree]
allocRhs (GHC.L l (GHC.GRHS stmts expr)) toksIn = r
  where
    (sb,toksRhs,sa) = splitToksIncComments (ghcSpanStartEnd l) toksIn
    (s1,stmtsToks,toks') = splitToksForList stmts toksRhs
    stmtsLayout = allocList stmts stmtsToks allocStmt
    exprLayout = allocExpr expr toks'
    exprMainLayout = [makeGroup $ strip $ (makeLeafFromToks s1) ++ stmtsLayout ++ exprLayout]
    r = strip $ (makeLeafFromToks sb) ++ exprMainLayout ++ (makeLeafFromToks sa)

-- ---------------------------------------------------------------------

allocStmt :: GHC.LStmt GHC.RdrName -> [PosToken] -> [LayoutTree]
allocStmt (GHC.L _ (GHC.LastStmt expr _)) toks = allocExpr expr toks
allocStmt (GHC.L _ (GHC.BindStmt pat@(GHC.L lp _) expr _ _)) toks = r
  where
    (s1,patToks,toks') = splitToksIncComments (ghcSpanStartEnd lp) toks
    patLayout = allocPat pat patToks
    exprLayout = allocExpr expr toks'
    r = strip $ (makeLeafFromToks s1) ++ patLayout ++ exprLayout
allocStmt (GHC.L _ (GHC.ExprStmt expr _ _ _)) toks = allocExpr expr toks
allocStmt (GHC.L _ (GHC.LetStmt binds))       toks = allocLocalBinds binds toks
#if __GLASGOW_HASKELL__ > 704
allocStmt (GHC.L l (GHC.ParStmt blocks _ _))  toks = r
  where
    (s1,blocksToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (blocksLayout,toks2) = foldl' allocParStmtBlock ([],blocksToks) blocks
    r = [makeGroup $ strip $ (makeLeafFromToks s1) ++ blocksLayout
              ++ (makeLeafFromToks toks2)
              ++ (makeLeafFromToks toks')]
#else
allocStmt (GHC.L l (GHC.ParStmt blocks _ _ _)) toks = r
  where
    (s1,blocksToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (blocksLayout,toks2) = foldl' allocParStmtBlock ([],blocksToks) blocks
    r = [makeGroup $ strip $ (makeLeafFromToks s1) ++ blocksLayout
              ++ (makeLeafFromToks toks2)
              ++ (makeLeafFromToks toks')]

    allocParStmtBlock :: ([LayoutTree],[PosToken])
         -> ([GHC.LStmt GHC.RdrName],[GHC.RdrName]) -> ([LayoutTree],[PosToken])
    allocParStmtBlock (acc,toks) (stmts,ns) = (r1,toks')
      where
        (s1,stmtToks,toks') = splitToksForList stmts toks
        stmtLayout = allocList stmts stmtToks allocStmt
        r1 = [makeGroup $ strip $ (makeLeafFromToks s1)
                      ++ stmtLayout]
-- ParStmt [([LStmt idL], [idR])] (SyntaxExpr idR) (SyntaxExpr idR) (SyntaxExpr idR)
#endif
allocStmt (GHC.L l (GHC.TransStmt _ stmts _ using@(GHC.L lu _) mby _ _ _ )) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,stmtsToks,toks1) = splitToksForList stmts toksExpr
    (s2,usingToks,toks2) = splitToksIncComments (ghcSpanStartEnd lu) toks1
    (byLayout,toks3) = case mby of
       Nothing -> ([],toks2)
       Just e -> (byL,toks3')
         where
           byL = allocExpr e toks2
           toks3' = []

    stmtsLayout = allocList stmts stmtsToks allocStmt
    usingLayout = allocExpr using usingToks
    r = [makeGroup $ strip $ (makeLeafFromToks sb)
                  ++ (makeLeafFromToks s1) ++ stmtsLayout
                  ++ (makeLeafFromToks s2) ++ usingLayout
                  ++ byLayout
                  ++ (makeLeafFromToks toks3)
                  ++ (makeLeafFromToks sa)
        ]

allocStmt (GHC.L l (GHC.RecStmt stmts _ _ _ _ _ _ _ _))  toks = r
  where
    -- Note: everything after the first field is filled in from the
    -- renamer onwards, can be ignored here
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,stmtsToks,toks1) = splitToksForList stmts toksExpr
    stmtsLayout = allocList stmts stmtsToks allocStmt

    r = [makeGroup $ strip $ (makeLeafFromToks sb)
                  ++ (makeLeafFromToks s1) ++ stmtsLayout
                  ++ (makeLeafFromToks toks1)
                  ++ (makeLeafFromToks sa)
        ]
{-
RecStmt
  recS_stmts :: [LStmtLR idL idR]
  recS_later_ids :: [idR]
  recS_rec_ids :: [idR]
  recS_bind_fn :: SyntaxExpr idR
  recS_ret_fn :: SyntaxExpr idR
  recS_mfix_fn :: SyntaxExpr idR
  recS_later_rets :: [PostTcExpr]
  recS_rec_rets :: [PostTcExpr]
  recS_ret_ty :: PostTcType
-}
-- ---------------------------------------------------------------------

#if __GLASGOW_HASKELL__ > 704
allocParStmtBlock :: ([LayoutTree],[PosToken]) -> GHC.ParStmtBlock GHC.RdrName GHC.RdrName -> ([LayoutTree],[PosToken])
allocParStmtBlock (acc,toks) (GHC.ParStmtBlock stmts _ns _) = (acc ++ r,toks')
  where
    (s1,stmtToks,toks') = splitToksForList stmts toks
    stmtLayout = allocList stmts stmtToks allocStmt
    r = [makeGroup $ strip $ (makeLeafFromToks s1)
                      ++ stmtLayout]
#endif

-- ---------------------------------------------------------------------

allocExpr :: GHC.LHsExpr GHC.RdrName -> [PosToken] -> [LayoutTree]
allocExpr (GHC.L l (GHC.HsVar _)) toks = [makeLeaf l NoChange toks]
allocExpr (GHC.L l (GHC.HsLit _)) toks = [makeLeaf l NoChange toks]
allocExpr (GHC.L l (GHC.HsOverLit _)) toks = [makeLeaf l NoChange toks]
allocExpr (GHC.L _ (GHC.HsLam (GHC.MatchGroup matches _))) toks
  = allocMatches matches toks
#if __GLASGOW_HASKELL__ > 704
allocExpr (GHC.L _ (GHC.HsLamCase _ (GHC.MatchGroup matches _))) toks
  = allocMatches matches toks
#endif
allocExpr (GHC.L l (GHC.HsApp e1@(GHC.L l1 _) e2)) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,e1Toks,e2Toks) = splitToksIncComments (ghcSpanStartEnd l1) toksExpr
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    exprLayout = [makeGroup $ strip $ (makeLeafFromToks s1) ++ e1Layout ++ e2Layout]
    r = strip $ (makeLeafFromToks sb) ++ exprLayout ++ (makeLeafFromToks sa)
allocExpr (GHC.L l (GHC.OpApp e1@(GHC.L l1 _) e2@(GHC.L l2 _) _ e3)) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,e1Toks,toks1) = splitToksIncComments (ghcSpanStartEnd l1) toksExpr
    (s2,e2Toks,e3Toks) = splitToksIncComments (ghcSpanStartEnd l2) toks1
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    e3Layout = allocExpr e3 e3Toks
    exprLayout = [makeGroup $ strip $ (makeLeafFromToks s1)
                      ++ e1Layout ++ (makeLeafFromToks s2)
                      ++ e2Layout ++ e3Layout]
    r = strip $ (makeLeafFromToks sb) ++ exprLayout ++ (makeLeafFromToks sa)
allocExpr (GHC.L l (GHC.NegApp expr _)) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    exprLayout = [makeGroup $ allocExpr expr toksExpr]
    r = strip $ (makeLeafFromToks sb) ++ exprLayout ++ (makeLeafFromToks sa)
allocExpr (GHC.L l (GHC.HsPar expr))    toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    exprLayout = [makeGroup $ allocExpr expr toksExpr]
    r = strip $ (makeLeafFromToks sb) ++ exprLayout ++ (makeLeafFromToks sa)
allocExpr (GHC.L l (GHC.SectionL e1@(GHC.L l1 _) e2)) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,e1Toks,e2Toks) = splitToksIncComments (ghcSpanStartEnd l1) toksExpr
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    exprLayout = [makeGroup $ strip $ (makeLeafFromToks s1) ++ e1Layout ++ e2Layout]
    r = strip $ (makeLeafFromToks sb) ++ exprLayout ++ (makeLeafFromToks sa)
allocExpr (GHC.L l (GHC.SectionR e1@(GHC.L l1 _) e2)) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,e1Toks,e2Toks) = splitToksIncComments (ghcSpanStartEnd l1) toksExpr
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    exprLayout = [makeGroup $ strip $ (makeLeafFromToks s1) ++ e1Layout ++ e2Layout]
    r = strip $ (makeLeafFromToks sb) ++ exprLayout ++ (makeLeafFromToks sa)
allocExpr (GHC.L l (GHC.ExplicitTuple tupArgs _)) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,tupToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toksExpr
    tupLayout = allocTupArgList tupArgs tupToks
    exprLayout = [makeGroup $ strip $ (makeLeafFromToks s1) ++ tupLayout
             ++ (makeLeafFromToks toks')]
    r = strip $ (makeLeafFromToks sb) ++ exprLayout ++ (makeLeafFromToks sa)
-- ExplicitTuple [HsTupArg id] Boxity
allocExpr (GHC.L l (GHC.HsCase expr@(GHC.L le _) (GHC.MatchGroup matches _))) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,exprToks,toks1) = splitToksIncComments (ghcSpanStartEnd le) toksExpr
    (s2,matchToks,toks2) = splitToksForList matches toks1
    exprLayout = allocExpr expr exprToks

    firstMatchTok = ghead "allocLocalBinds" $ dropWhile isWhiteSpaceOrIgnored matchToks
    p1 = (tokenRow firstMatchTok,tokenCol firstMatchTok)
    (ro,co) = case (filter isOf s2) of
               [] -> (0,0)
               (x:_) -> (tokenRow firstMatchTok - tokenRow x,
                         tokenCol firstMatchTok - (tokenCol x + tokenLen x))

    (rt,ct) = calcLastTokenPos matchToks

    so = makeOffset ro (co - 1)
    matchesLayout = [placeAbove so p1 (rt,ct) (allocMatches matches matchToks)]

    exprMainLayout = [makeGroup $ strip $ (makeLeafFromToks s1) ++ exprLayout
             ++ (makeLeafFromToks s2) ++ matchesLayout ++ (makeLeafFromToks toks2)]

    r = strip $ (makeLeafFromToks sb) ++ exprMainLayout ++ (makeLeafFromToks sa)
allocExpr (GHC.L l (GHC.HsIf _ e1@(GHC.L l1 _) e2@(GHC.L l2 _) e3)) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,e1Toks,toks1) = splitToksIncComments (ghcSpanStartEnd l1) toksExpr
    (s2,e2Toks,e3Toks) = splitToksIncComments (ghcSpanStartEnd l2) toks1
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    e3Layout = allocExpr e3 e3Toks
    exprLayout = [makeGroup $ strip $ (makeLeafFromToks s1)
                         ++ e1Layout ++ (makeLeafFromToks s2)
                         ++ e2Layout ++ e3Layout]
    r = strip $ (makeLeafFromToks sb) ++ exprLayout ++ (makeLeafFromToks sa)
#if __GLASGOW_HASKELL__ > 704
allocExpr (GHC.L l (GHC.HsMultiIf _ rhs)) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    exprLayout = [makeGroup $ allocList rhs toksExpr allocRhs]
    r = strip $ (makeLeafFromToks sb) ++ exprLayout ++ (makeLeafFromToks sa)
#endif
allocExpr (GHC.L l (GHC.HsLet localBinds expr@(GHC.L le _))) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (bindToks,exprToks,toks') = splitToksIncComments (ghcSpanStartEnd le) toksExpr
    bindLayout = allocLocalBinds localBinds bindToks
    exprLayout = allocExpr expr exprToks
    exprMainLayout = [makeGroup $ strip $ bindLayout ++ [makeGroup exprLayout] ++ (makeLeafFromToks toks')]
    r = strip $ (makeLeafFromToks sb) ++ exprMainLayout ++ (makeLeafFromToks sa)


-- various kinds of list comprehension
allocExpr e@(GHC.L _ (GHC.HsDo GHC.ListComp  _ _)) toks = allocExprListComp e toks
allocExpr e@(GHC.L _ (GHC.HsDo GHC.MonadComp _ _)) toks = allocExprListComp e toks
allocExpr e@(GHC.L _ (GHC.HsDo GHC.PArrComp  _ _)) toks = allocExprListComp e toks


-- various kinds of do
allocExpr e@(GHC.L _ (GHC.HsDo GHC.DoExpr   _ _)) toks = allocDoExpr e toks
allocExpr e@(GHC.L _ (GHC.HsDo GHC.GhciStmt _ _)) toks = allocDoExpr e toks
allocExpr e@(GHC.L _ (GHC.HsDo GHC.MDoExpr  _ _)) toks = allocDoExpr e toks


allocExpr e@(GHC.L _ (GHC.HsDo GHC.ArrowExpr _ _)) _ = error $ "allocExpr undefined for " ++ (SYB.showData SYB.Parser 0  e)
allocExpr e@(GHC.L _ (GHC.HsDo (GHC.PatGuard _) _ _)) _ = error $ "allocExpr undefined for " ++ (SYB.showData SYB.Parser 0  e)
allocExpr e@(GHC.L _ (GHC.HsDo (GHC.ParStmtCtxt _) _ _)) _ = error $ "allocExpr undefined for " ++ (SYB.showData SYB.Parser 0  e)
allocExpr e@(GHC.L _ (GHC.HsDo (GHC.TransStmtCtxt _) _ _)) _ = error $ "allocExpr undefined for " ++ (SYB.showData SYB.Parser 0  e)

allocExpr (GHC.L l (GHC.ExplicitList _ exprs)) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    exprLayout = [makeGroup $ allocList exprs toksExpr allocExpr]
    r = strip $ (makeLeafFromToks sb) ++ exprLayout ++ (makeLeafFromToks sa)
allocExpr (GHC.L l (GHC.ExplicitPArr _ exprs)) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    exprLayout = [makeGroup $ allocList exprs toksExpr allocExpr]
    r = strip $ (makeLeafFromToks sb) ++ exprLayout ++ (makeLeafFromToks sa)
allocExpr (GHC.L l (GHC.RecordCon (GHC.L ln _) _ binds)) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,nameToks,fieldsToks) = splitToksIncComments (ghcSpanStartEnd ln) toksExpr
    nameLayout = [makeLeaf ln NoChange nameToks]
    (bindsLayout,toks3) = allocHsRecordBinds binds fieldsToks
    exprLayout = [makeGroup $ strip $ (makeLeafFromToks s1)
                 ++ nameLayout ++ bindsLayout
                 ++ (makeLeafFromToks toks3)]

    r = strip $ (makeLeafFromToks sb) ++ exprLayout ++ (makeLeafFromToks sa)

allocExpr (GHC.L l (GHC.RecordUpd expr@(GHC.L le _) binds _cons _ptctypes1 _ptctypes2)) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,toksE,toks2) = splitToksIncComments (ghcSpanStartEnd le) toksExpr
    (bindsLayout,toks3) = allocHsRecordBinds binds toks2
    exprLayout = allocExpr expr toksE
    recLayout = [makeGroup $ strip $ (makeLeafFromToks s1) ++ exprLayout
                              ++ bindsLayout ++ (makeLeafFromToks toks3)]
    r = strip $ (makeLeafFromToks sb) ++ recLayout ++ (makeLeafFromToks sa)
{-
RecordUpd (LHsExpr id) (HsRecordBinds id) [DataCon] [PostTcType] [PostTcType]
-}
allocExpr (GHC.L l (GHC.ArithSeq _ info)) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    exprLayout = [makeGroup $ allocArithSeqInfo info toksExpr]
    r = strip $ (makeLeafFromToks sb) ++ exprLayout ++ (makeLeafFromToks sa)

allocExpr (GHC.L l (GHC.ExprWithTySig (GHC.L le expr) (GHC.L lt typ))) toks = r
  where
    (sb,toksExpr,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,toksE,toks2) = splitToksIncComments (ghcSpanStartEnd le) toksExpr
    (s2,toksType,toks3) = splitToksIncComments (ghcSpanStartEnd lt) toks2

    exprLayout = allocExpr (GHC.L le expr) toksE
    typeLayout = allocType (GHC.L lt typ) toksType
    layout = [makeGroup $ strip $ (makeLeafFromToks s1) ++ exprLayout
                              ++ (makeLeafFromToks s2) ++ typeLayout
                              ++ (makeLeafFromToks toks3)]
    r = strip $ (makeLeafFromToks sb) ++ layout ++ (makeLeafFromToks sa)

allocExpr (GHC.L _ (GHC.HsIPVar _)) toks = makeLeafFromToks toks
allocExpr e@(GHC.L _ (GHC.PArrSeq _ _)) _ = error $ "allocExpr undefined for " ++ (SYB.showData SYB.Parser 0  e)
allocExpr (GHC.L _ (GHC.HsSCC _ ex)) toks = allocExpr ex toks
allocExpr (GHC.L _ (GHC.HsCoreAnn _ ex)) toks = allocExpr ex toks
allocExpr (GHC.L l (GHC.HsBracket bracket)) toks = r
  where
    (sb,toksBrack,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    layoutBrack = case bracket of
      GHC.ExpBr ex -> allocExpr ex toksBrack
      GHC.PatBr p -> allocPat p toksBrack
      GHC.DecBrL decs -> allocDecls decs toksBrack
      GHC.DecBrG g -> error $ "allocExpr.DecBrG undefined for " ++ (SYB.showData SYB.Parser 0 g)
      GHC.TypBr typ -> allocType typ toksBrack
      GHC.VarBr _ _ -> makeLeafFromToks toksBrack
    r = [makeGroup $ strip $ (makeLeafFromToks sb)
                   ++ layoutBrack
                   ++ (makeLeafFromToks sa)]

-- Note: these are only present after the typechecker
allocExpr e@(GHC.L _ (GHC.ExprWithTySigOut _ _)) _ = error $ "allocExpr undefined for " ++ (SYB.showData SYB.Parser 0  e)
allocExpr e@(GHC.L _ (GHC.HsBracketOut _ _)) _ = error $ "allocExpr undefined for " ++ (SYB.showData SYB.Parser 0  e)


allocExpr (GHC.L _l (GHC.HsSpliceE (GHC.HsSplice _ expr))) toks = allocExpr expr toks

allocExpr e@(GHC.L _ (GHC.HsQuasiQuoteE _)) _ = error $ "allocExpr undefined for " ++ (SYB.showData SYB.Parser 0  e)

allocExpr (GHC.L l (GHC.HsProc p@(GHC.L lp _) cmd@(GHC.L lc _))) toks = r
  where
    (sb,toksBrack,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,toksPat,toks1) = splitToksIncComments (ghcSpanStartEnd lp) toksBrack
    (s2,toksCmd,toks2) = splitToksIncComments (ghcSpanStartEnd lc) toks1
    layoutPat = allocPat p toksPat
    layoutCmd = allocCmdTop cmd toksCmd
    r = [makeGroup $ strip $ (makeLeafFromToks sb)
                   ++ (makeLeafFromToks s1)
                   ++ layoutPat
                   ++ (makeLeafFromToks s2)
                   ++ layoutCmd
                   ++ (makeLeafFromToks toks2)
                   ++ (makeLeafFromToks sa)]

allocExpr (GHC.L l (GHC.HsArrApp e1@(GHC.L l1 _) e2@(GHC.L l2 _) _ _ _)) toks = r
  where
    (sb,toksApp,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,toksE1,toks1) = splitToksIncComments (ghcSpanStartEnd l1) toksApp
    (s2,toksE2,toks2) = splitToksIncComments (ghcSpanStartEnd l2) toks1
    layoutE1 = allocExpr e1 toksE1
    layoutE2 = allocExpr e2 toksE2
    r = [makeGroup $ strip $ (makeLeafFromToks sb)
                   ++ (makeLeafFromToks s1)
                   ++ layoutE1
                   ++ (makeLeafFromToks s2)
                   ++ layoutE2
                   ++ (makeLeafFromToks toks2)
                   ++ (makeLeafFromToks sa)]

allocExpr (GHC.L l (GHC.HsArrForm e@(GHC.L le _) _ cmds)) toks = r
  where
    (sb,toksApp,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,toksExpr,toks1) = splitToksIncComments (ghcSpanStartEnd le) toksApp
    (s2,toksCmd,toks2) = splitToksForList cmds toks1
    layoutExpr = allocExpr e toksExpr
    layoutCmds = allocList cmds toksCmd allocCmdTop
    r = [makeGroup $ strip $ (makeLeafFromToks sb)
                   ++ (makeLeafFromToks s1)
                   ++ layoutExpr
                   ++ (makeLeafFromToks s2)
                   ++ layoutCmds
                   ++ (makeLeafFromToks toks2)
                   ++ (makeLeafFromToks sa)]

allocExpr (GHC.L _ (GHC.HsTick _ e)) toks = allocExpr e toks
allocExpr (GHC.L _ (GHC.HsBinTick _ _ e)) toks = allocExpr e toks
allocExpr (GHC.L _ (GHC.HsTickPragma _ e)) toks = allocExpr e toks

allocExpr (GHC.L l (GHC.EWildPat)) toks = r
  where
    (sb,toksPat,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    r = [makeGroup $ strip $ (makeLeafFromToks sb)
                   ++ (makeLeafFromToks toksPat)
                   ++ (makeLeafFromToks sa)]

allocExpr (GHC.L l (GHC.EAsPat (GHC.L ln _) e@(GHC.L le _))) toks = r
  where
    (sb,toksPat,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,toksN,toks1) = splitToksIncComments (ghcSpanStartEnd ln) toksPat
    (s2,toksE,toks2) = splitToksIncComments (ghcSpanStartEnd le) toks1
    layoutN = makeLeafFromToks toksN
    layoutExpr = allocExpr e toksE
    r = [makeGroup $ strip $ (makeLeafFromToks sb)
                   ++ (makeLeafFromToks s1)
                   ++ layoutN
                   ++ (makeLeafFromToks s2)
                   ++ layoutExpr
                   ++ (makeLeafFromToks toks2)
                   ++ (makeLeafFromToks sa)]

allocExpr (GHC.L l (GHC.EViewPat e1@(GHC.L l1 _) e2@(GHC.L l2 _))) toks = r
  where
    (sb,toksPat,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,toksE1,toks1) = splitToksIncComments (ghcSpanStartEnd l1) toksPat
    (s2,toksE2,toks2) = splitToksIncComments (ghcSpanStartEnd l2) toks1
    layoutE1 = allocExpr e1 toksE1
    layoutE2 = allocExpr e2 toksE2
    r = [makeGroup $ strip $ (makeLeafFromToks sb)
                   ++ (makeLeafFromToks s1)
                   ++ layoutE1
                   ++ (makeLeafFromToks s2)
                   ++ layoutE2
                   ++ (makeLeafFromToks toks2)
                   ++ (makeLeafFromToks sa)]

allocExpr (GHC.L _ (GHC.ELazyPat e)) toks = allocExpr e toks
allocExpr (GHC.L _ (GHC.HsType typ)) toks = allocType typ toks
allocExpr e@(GHC.L _ (GHC.HsWrap _ _)) toks = allocExpr e toks

-- -------------------------------------

allocDoExpr :: GHC.LHsExpr GHC.RdrName -> [PosToken] -> [LayoutTree]
allocDoExpr _e@(GHC.L l (GHC.HsDo _ stmts _)) toks = r
  where
    (s1,toksBinds',toks1) = splitToksIncComments (ghcSpanStartEnd l) toks

    (before,including) = break isDo toksBinds'
    doToks = before ++ [ghead ("allocExpr:" ++ (show toksBinds') ++ (SYB.showData SYB.Renamer 0 _e)) including]
    toksBinds = gtail ("allocExpr.HsDo" ++ show (l,before,including,toks)) including

    bindsLayout' = allocList stmts toksBinds allocStmt

    firstBindTok = ghead "allocLocalBinds" $ dropWhile isWhiteSpaceOrIgnored toksBinds
    p1 = (tokenRow firstBindTok,tokenCol firstBindTok)
    (ro,co) = case (filter isDo doToks) of
               [] -> (0,0)
               (x:_) -> (tokenRow firstBindTok - tokenRow x,
                         tokenCol firstBindTok - (tokenCol x + tokenLen x))

    (rt,ct) = calcLastTokenPos toksBinds

    so = makeOffset ro (co -1)

    bindsLayout = case bindsLayout' of
      [] -> []
      bs -> [placeAbove so p1 (rt,ct) bs]

    r = strip $ (makeLeafFromToks (s1++doToks) ++ bindsLayout ++ makeLeafFromToks toks1)
allocDoExpr e _
  = error $ "Layout.allocDoExpr should not have been called with " ++ showGhc e

-- -------------------------------------

allocExprListComp :: GHC.LHsExpr GHC.RdrName -> [PosToken] -> [LayoutTree]
allocExprListComp _e@(GHC.L l (GHC.HsDo _ stmts _)) toks = r
  where
    (s1,toksBinds,toks1) = splitToksIncComments (ghcSpanStartEnd l) toks
    bindsLayout = allocList stmts toksBinds allocStmt
    r = strip $ ((makeLeafFromToks s1) ++ bindsLayout ++ makeLeafFromToks toks1)
allocExprListComp e _
  = error $ "Layout.allocExprListComp should not have been called with " ++ showGhc e

-- ---------------------------------------------------------------------

allocCmdTop :: GHC.LHsCmdTop GHC.RdrName -> [PosToken] -> [LayoutTree]
allocCmdTop (GHC.L l (GHC.HsCmdTop cmd _ _ _)) toks = r
  where
    (sb,toksCmd,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    layoutExpr = allocExpr cmd toksCmd
    r = [makeGroup $ strip $ (makeLeafFromToks sb)
                   ++ layoutExpr
                   ++ (makeLeafFromToks sa)]

-- ---------------------------------------------------------------------

allocHsRecordBinds :: GHC.HsRecordBinds GHC.RdrName -> [PosToken] -> ([LayoutTree],[PosToken])
allocHsRecordBinds (GHC.HsRecFields flds _dot) toks = (r,toks')
  where
    (r,toks') = foldl doOne ([],toks) flds

    doOne (r1,toks1) fld = (r1',toks1')
      where
        (r2,toks1') = allocHsRecField fld toks1
        r1' = r1 ++ r2
{-
type HsRecordBinds id = HsRecFields id (LHsExpr id)

data HsRecFields id arg

Constructors
  HsRecFields
    rec_flds :: [HsRecField id arg]
    rec_dotdot :: Maybe Int

data HsRecField id arg

Constructors
  HsRecField
    hsRecFieldId :: Located id
    hsRecFieldArg :: arg
    hsRecPun :: Bool

-}

allocHsRecField ::
 GHC.HsRecField GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> [PosToken]
 -> ([LayoutTree],[PosToken])
allocHsRecField (GHC.HsRecField (GHC.L ln _) expr@(GHC.L le _) _) toks = (r,toks')
  where
    (s1,toksN,toks1) = splitToksIncComments (ghcSpanStartEnd ln) toks
    (s2,toksE,toks2) = splitToksIncComments (ghcSpanStartEnd le) toks1
    nLayout = makeLeafFromToks toksN
    exprLayout = allocExpr expr toksE
    toks' = toks2
    r = [makeGroup $ strip $ (makeLeafFromToks s1) ++ nLayout
                    ++ (makeLeafFromToks s2) ++ exprLayout]

-- ---------------------------------------------------------------------

allocLocalBinds :: GHC.HsLocalBinds GHC.RdrName -> [PosToken] -> [LayoutTree]
allocLocalBinds GHC.EmptyLocalBinds toks = strip $ makeLeafFromToks toks
allocLocalBinds (GHC.HsValBinds (GHC.ValBindsIn binds sigs)) toks = r
  where
    bindList = GHC.bagToList binds

    startBind = startPosForList bindList
    startSig  = startPosForList sigs
    start = if startSig < startBind then startSig else startBind

    endBind = endPosForList bindList
    endSig  = endPosForList sigs
    end = if endSig > endBind then endSig else endBind

    (s1,toksBinds,toks1) = splitToksIncComments (start,end) toks

    firstBindTok = ghead "allocLocalBinds" $ dropWhile isWhiteSpaceOrIgnored toksBinds
    p1 = (tokenRow firstBindTok,tokenCol firstBindTok)
    (ro,co) = case (filter isWhereOrLet s1) of
               [] -> (0,0)
               (x:_) -> (tokenRow firstBindTok - tokenRow x,
                         tokenCol firstBindTok - (tokenCol x + tokenLen x))

    (rt,ct) = calcLastTokenPos toksBinds

    bindsLayout' = allocInterleavedLists bindList sigs (toksBinds) allocBind allocSig

    so = makeOffset ro (co -1)

    bindsLayout = case bindsLayout' of
      [] -> []
      bs -> [placeAbove so p1 (rt,ct) bs]

    r = strip $ (makeLeafFromToks s1) ++ bindsLayout ++ (makeLeafFromToks toks1)
allocLocalBinds (GHC.HsValBinds (GHC.ValBindsOut _ _)) _
   = error "allocLocalBinds (GHC.HsValBinds (GHC.ValBindsOut..)) should not be required"

allocLocalBinds (GHC.HsIPBinds (GHC.IPBinds bs _))  toks = r
  where
    -- Note: only the Left x part is populated until after renaming, so no
    -- need to process deeper than this
    bindsLayout = allocList bs toks allocLocated
    r = strip $ bindsLayout

-- ---------------------------------------------------------------------

makeOffset :: RowOffset -> ColOffset -> EndOffset
makeOffset 0   0 = None
makeOffset 0  co = SameLine co
makeOffset ro co = FromAlignCol (ro,co)

-- ---------------------------------------------------------------------

startPosForList :: [GHC.Located a] -> SimpPos
startPosForList xs = start
  where
    (start,_) = case xs of
                 [] -> ((100000,0),(0,0))
                 ((GHC.L ls _):_) -> ghcSpanStartEnd ls

endPosForList :: [GHC.Located a] -> SimpPos
endPosForList xs = end
  where
    (_,end) = case xs of
                 [] -> ((0,0),(0,0))
                 ls -> ghcSpanStartEnd $ GHC.getLoc $ last ls

-- ---------------------------------------------------------------------

allocBind :: GHC.LHsBind GHC.RdrName -> [PosToken] -> [LayoutTree]
allocBind (GHC.L l (GHC.FunBind (GHC.L ln _) _ (GHC.MatchGroup matches _) _ _ _)) toks = r
  where
    (nameLayout,toks1) = ((makeLeafFromToks s1)++[makeLeaf ln NoChange nameToks],toks')
      where
        (s1,nameToks,toks') = splitToksIncComments (ghcSpanStartEnd ln) toks

    (matchesLayout,toks2) = ((makeLeafFromToks s2) ++ allocMatches matches matchToks,toks2')
          where
            (s2,matchToks,toks2') = splitToksForList matches toks1

    r = strip $ [mkGroup l NoChange (strip $ nameLayout ++ matchesLayout)] ++ (makeLeafFromToks toks2)

allocBind (GHC.L l (GHC.PatBind lhs@(GHC.L ll _) grhs@(GHC.GRHSs rhs _) _ _ _)) toks = r
  where
    (s1,bindToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,lhsToks,toks1) = splitToksIncComments (ghcSpanStartEnd ll) bindToks
    (s3,rhsToks,bindsToks) = splitToksForList rhs toks1

    lhsLayout = allocPat lhs lhsToks
    grhsLayout = allocGRHSs grhs (rhsToks ++ bindsToks)

    r = [makeGroup $ (strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
              ++ lhsLayout ++ (makeLeafFromToks s3) ++ grhsLayout
              ++ (makeLeafFromToks toks')) ]

allocBind (GHC.L l (GHC.VarBind _n rhs@(GHC.L lr _) _)) toks  = r
  where
    (sb,toksBind,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,exprToks,toks2) = splitToksIncComments (ghcSpanStartEnd lr) toksBind
    exprLayout = allocExpr rhs exprToks
    r = [makeGroup $ (strip $ (makeLeafFromToks sb)
              ++ (makeLeafFromToks s1)
              ++ exprLayout
              ++ (makeLeafFromToks toks2)
              ++ (makeLeafFromToks sa)
             )
         ]

allocBind (GHC.L l (GHC.AbsBinds _tvs _vars _exps _ev binds)) toks = r
  where
    bindsList = GHC.bagToList binds
    (sb,toksBind,sa) = splitToksIncComments (ghcSpanStartEnd l) toks
    (s1,bindsToks,toks2) = splitToksForList bindsList toksBind
    bindsLayout = allocList bindsList bindsToks allocBind
    r = [makeGroup $ (strip $ (makeLeafFromToks sb)
              ++ (makeLeafFromToks s1)
              ++ bindsLayout
              ++ (makeLeafFromToks toks2)
              ++ (makeLeafFromToks sa)
             )
         ]

-- ---------------------------------------------------------------------

allocSig :: GHC.LSig GHC.RdrName -> [PosToken] -> [LayoutTree]
allocSig (GHC.L l (GHC.TypeSig names t@(GHC.L lt _))) toks = r
  where
    (s1,bindToks,toks')  = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nameToks,toks'') = splitToksForList names bindToks
    (s3,typeToks,s4)     = splitToksIncComments (ghcSpanStartEnd lt) toks''
    nameLayout = allocList names nameToks allocLocated
    typeLayout = allocType t typeToks
    r = [makeGroup (strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
               ++ nameLayout ++ (makeLeafFromToks s3) ++ typeLayout
               ++ (makeLeafFromToks s4) ++ (makeLeafFromToks toks'))]
allocSig (GHC.L l (GHC.GenericSig names t@(GHC.L lt _))) toks = r
  where
    (s1,bindToks,toks')  = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nameToks,toks'') = splitToksForList names bindToks
    (s3,typeToks,s4)     = splitToksIncComments (ghcSpanStartEnd lt) toks''
    nameLayout = allocList names nameToks allocLocated
    typeLayout = allocType t typeToks
    r = [makeGroup (strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
            ++ nameLayout ++ (makeLeafFromToks s3) ++typeLayout
            ++ (makeLeafFromToks s4) ++ (makeLeafFromToks toks') )]
allocSig (GHC.L l (GHC.IdSig _i)) toks = r
  where
    (s1,nameToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    r = [makeGroup $ (strip $ (makeLeafFromToks s1) ++ [makeLeaf l NoChange nameToks])
              ++ (makeLeafFromToks toks') ]
allocSig (GHC.L l (GHC.FixSig (GHC.FixitySig n@(GHC.L ln _) _fix))) toks = r
  where
    (s1,fToks,toks')   = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nToks,fixToks) = splitToksIncComments (ghcSpanStartEnd ln) fToks

    r = [makeGroup $ (strip $ (makeLeafFromToks s1) ++ (allocLocated n nToks)
              ++ (makeLeafFromToks s2) ++ (makeLeafFromToks fixToks))
              ++ (makeLeafFromToks toks') ]
allocSig (GHC.L l (GHC.InlineSig n@(GHC.L ln _) _ip)) toks = r
  where
    (s1,sigToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nToks,ipToks)  = splitToksIncComments (ghcSpanStartEnd ln) sigToks
    r = [makeGroup $ (strip $ (makeLeafFromToks s1) ++ (allocLocated n nToks)
              ++ (makeLeafFromToks s2) ++ (makeLeafFromToks ipToks))
              ++ (makeLeafFromToks toks') ]
allocSig (GHC.L l (GHC.SpecSig n@(GHC.L ln _) t@(GHC.L lt _) _ip)) toks = r
  where
    (s1,sigToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nToks,toks'')  = splitToksIncComments (ghcSpanStartEnd ln) sigToks
    (s3,tToks,ipToks)  = splitToksIncComments (ghcSpanStartEnd lt) toks''
    nameLayout = allocLocated n nToks
    typeLayout = allocType t tToks
    ipLayout = makeLeafFromToks ipToks
    r = [makeGroup $ (strip $ (makeLeafFromToks s1) ++ nameLayout ++ (makeLeafFromToks s2)
              ++ typeLayout ++ (makeLeafFromToks s3) ++ ipLayout
              ++ (makeLeafFromToks toks')) ]
allocSig (GHC.L l (GHC.SpecInstSig t)) toks = r
  where
    (s1,sigToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    r = [makeGroup $ (strip $ (makeLeafFromToks s1) ++ allocType t sigToks
              ++ (makeLeafFromToks toks')) ]

-- ---------------------------------------------------------------------

allocArithSeqInfo :: GHC.ArithSeqInfo GHC.RdrName -> [PosToken] -> [LayoutTree]
allocArithSeqInfo (GHC.From e) toks = allocExpr e toks
allocArithSeqInfo (GHC.FromThen e1@(GHC.L l _) e2) toksIn = r
  where
    (s1,e1Toks,e2Toks) = splitToksIncComments (ghcSpanStartEnd l) toksIn
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    r = strip $ (makeLeafFromToks s1) ++ e1Layout ++ e2Layout

allocArithSeqInfo (GHC.FromTo e1@(GHC.L l _) e2) toksIn = r
  where
    (s1,e1Toks,e2Toks) = splitToksIncComments (ghcSpanStartEnd l) toksIn
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    r = strip $ (makeLeafFromToks s1) ++ e1Layout ++ e2Layout
allocArithSeqInfo (GHC.FromThenTo e1@(GHC.L l1 _) e2@(GHC.L l2 _) e3) toksIn = r
  where
    (s1,e1Toks,toks)   = splitToksIncComments (ghcSpanStartEnd l1) toksIn
    (s2,e2Toks,e3Toks) = splitToksIncComments (ghcSpanStartEnd l2) toks
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    e3Layout = allocExpr e3 e3Toks
    r = strip $ (makeLeafFromToks s1) ++ e1Layout ++ e2Layout ++ (makeLeafFromToks s2) ++  e3Layout

-- ---------------------------------------------------------------------

allocType :: GHC.LHsType GHC.RdrName -> [PosToken] -> [LayoutTree]
allocType (GHC.L l (GHC.HsForAllTy _ef vars (GHC.L lc ctx) typ) ) toks = r
  where
    (s1,exprToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
#if __GLASGOW_HASKELL__ > 704
    (varsLayout,toks2) = allocTyVarBndrs vars exprToks
#else
    (s1',tp,toks2) = splitToksForList vars exprToks
    varsLayout = strip $ (makeLeafFromToks s1') ++ allocList vars tp allocTyVarBndr
#endif
    (s2,ctxToks,toks3) = splitToksIncComments (ghcSpanStartEnd lc) toks2

    ctxLayout = allocHsContext ctx ctxToks
    typLayout = allocType typ toks3

    r = strip $ (makeLeafFromToks s1) ++ varsLayout
             ++ (makeLeafFromToks s2) ++ ctxLayout
             ++ typLayout ++ (makeLeafFromToks toks')
allocType n@(GHC.L _l (GHC.HsTyVar _) ) toks = allocLocated n toks
allocType (GHC.L l (GHC.HsAppTy t1@(GHC.L l1 _) t2@(GHC.L _ _)) ) toks = r
  where
    (s1,typeToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,t1Toks,t2Toks) = splitToksIncComments (ghcSpanStartEnd l1) typeToks
    t1Layout = allocType t1 t1Toks
    t2Layout = allocType t2 t2Toks
    r = strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ t1Layout ++ t2Layout ++ (makeLeafFromToks toks')
allocType (GHC.L l (GHC.HsFunTy t1@(GHC.L l1 _) t2@(GHC.L _ _)) ) toks = r
  where
    (s1,typeToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,t1Toks,t2Toks) = splitToksIncComments (ghcSpanStartEnd l1) typeToks
    t1Layout = allocType t1 t1Toks
    t2Layout = allocType t2 t2Toks
    r = strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ t1Layout ++ t2Layout ++ (makeLeafFromToks toks')
allocType (GHC.L l (GHC.HsListTy t1@(GHC.L l1 _)) ) toks = r
  where
    (s1,typeToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,t1Toks,toks2) = splitToksIncComments (ghcSpanStartEnd l1) typeToks
    t1Layout = allocType t1 t1Toks
    r = strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ t1Layout ++ (makeLeafFromToks toks2) ++ (makeLeafFromToks toks')
allocType (GHC.L l (GHC.HsPArrTy t1@(GHC.L l1 _)) ) toks = r
  where
    (s1,typeToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,t1Toks,toks2) = splitToksIncComments (ghcSpanStartEnd l1) typeToks
    t1Layout = allocType t1 t1Toks
    r = strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ t1Layout ++ (makeLeafFromToks toks2) ++ (makeLeafFromToks toks')
allocType (GHC.L l (GHC.HsTupleTy _sort types)) toks = r
  where
    (s1,typeToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    typesLayout = allocList types typeToks allocType
    r = strip $ (makeLeafFromToks s1)
             ++ typesLayout ++ (makeLeafFromToks toks')
allocType (GHC.L l (GHC.HsOpTy t1@(GHC.L l1 _) _op t2@(GHC.L l2 _))) toks = r
  where
    (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,t1Toks,toks2) = splitToksIncComments (ghcSpanStartEnd l1) toks1
    (s4,t2Toks,toks4) = splitToksIncComments (ghcSpanStartEnd l2) toks2
    t1Layout = allocType t1 t1Toks
    -- opLayout = allocLocated op opToks
    t2Layout = allocType t2 t2Toks
    r = strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ t1Layout -- ++ (makeLeafFromToks s3)
             {- ++ opLayout -} ++ (makeLeafFromToks s4)
             ++ t2Layout ++ (makeLeafFromToks toks4)
             ++ (makeLeafFromToks toks')
allocType n@(GHC.L _l (GHC.HsParTy _) ) toks = allocLocated n toks
allocType (GHC.L l (GHC.HsIParamTy _ typ@(GHC.L lt _)) ) toks = r
  where
    (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,typToks,toks2) = splitToksIncComments (ghcSpanStartEnd lt) toks1
    typLayout = allocType typ typToks
    r = strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ typLayout ++ (makeLeafFromToks toks2)
             ++ (makeLeafFromToks toks')
allocType (GHC.L l (GHC.HsEqTy t1@(GHC.L l1 _) t2@(GHC.L l2 _))) toks = r
  where
    (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,t1Toks,toks2) = splitToksIncComments (ghcSpanStartEnd l1) toks1
    (s3,t2Toks,toks3) = splitToksIncComments (ghcSpanStartEnd l2) toks2
    t1Layout = allocType t1 t1Toks
    t2Layout = allocType t2 t2Toks
    r = strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ t1Layout ++ (makeLeafFromToks s3)
             ++ t2Layout ++ (makeLeafFromToks toks3)
             ++ (makeLeafFromToks toks')
allocType (GHC.L l (GHC.HsKindSig t1@(GHC.L l1 _) t2@(GHC.L l2 _))) toks = r
  where
    (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,t1Toks,toks2) = splitToksIncComments (ghcSpanStartEnd l1) toks1
    (s3,t2Toks,toks3) = splitToksIncComments (ghcSpanStartEnd l2) toks2
    t1Layout = allocType t1 t1Toks
    t2Layout = allocType t2 t2Toks
    r = strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ t1Layout ++ (makeLeafFromToks s3)
             ++ t2Layout ++ (makeLeafFromToks toks3)
             ++ (makeLeafFromToks toks')
allocType (GHC.L l (GHC.HsQuasiQuoteTy (GHC.HsQuasiQuote _n _lq _)) ) toks = r
  where
    (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    quoteLayout = makeLeafFromToks toks1
    r = strip $ (makeLeafFromToks s1)
             ++ quoteLayout
             ++ (makeLeafFromToks toks')
allocType (GHC.L l (GHC.HsSpliceTy (GHC.HsSplice _n e@(GHC.L le _)) _fv _k) ) toks = r
  where
    (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,eToks,toks2) = splitToksIncComments (ghcSpanStartEnd le) toks1
    eLayout = allocExpr e eToks
    r = strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ eLayout ++ (makeLeafFromToks toks2)
             ++ (makeLeafFromToks toks')
allocType (GHC.L l (GHC.HsDocTy t1@(GHC.L l1 _) t2@(GHC.L l2 _))) toks = r
  where
    (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,t1Toks,toks2) = splitToksIncComments (ghcSpanStartEnd l1) toks1
    (s3,t2Toks,toks3) = splitToksIncComments (ghcSpanStartEnd l2) toks2
    t1Layout = allocType t1 t1Toks
    t2Layout = allocLocated t2 t2Toks
    r = strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ t1Layout ++ (makeLeafFromToks s3)
             ++ t2Layout ++ (makeLeafFromToks toks3)
             ++ (makeLeafFromToks toks')
allocType (GHC.L l (GHC.HsBangTy _ t1@(GHC.L l1 _)) ) toks = r
  where
    (s1,typeToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,t1Toks,toks2) = splitToksIncComments (ghcSpanStartEnd l1) typeToks
    t1Layout = allocType t1 t1Toks
    r = strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ t1Layout ++ (makeLeafFromToks toks2) ++ (makeLeafFromToks toks')
allocType (GHC.L l (GHC.HsRecTy decls) ) toks = r
  where
    (s1,typeToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (declsLayout,toks1) = allocConDeclFieldList decls typeToks
    r = strip $ (makeLeafFromToks s1)
             ++ declsLayout
             ++ (makeLeafFromToks toks1)
             ++ (makeLeafFromToks toks')
allocType n@(GHC.L _l (GHC.HsCoreTy _) ) toks = allocLocated n toks
allocType (GHC.L _l (GHC.HsExplicitListTy  _ ts) ) toks = allocList ts toks allocType
allocType (GHC.L _l (GHC.HsExplicitTupleTy _ ts) ) toks = allocList ts toks allocType
#if __GLASGOW_HASKELL__ > 704
allocType n@(GHC.L _l (GHC.HsTyLit _) ) toks = allocLocated n toks
#endif
allocType (GHC.L l (GHC.HsWrapTy _ typ) ) toks = allocType (GHC.L l typ) toks

-- ---------------------------------------------------------------------

allocInstDecl :: GHC.LInstDecl GHC.RdrName -> [PosToken] -> [LayoutTree]
#if __GLASGOW_HASKELL__ > 704
allocInstDecl (GHC.L l (GHC.ClsInstD polyTy@(GHC.L lt _) binds sigs famInsts)) toks = r
  where
    (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,polytToks,toks2) = splitToksIncComments (ghcSpanStartEnd lt) toks1

    polytLayout = allocType polyTy polytToks

    -- TODO: will require 3-way merge of binds,sigs and famInsts
    bindList = GHC.bagToList binds
    bindMix = makeMixedListEntry bindList (shim allocBind)
    sigMix  = makeMixedListEntry sigs (shim allocSig)
    famMix  = makeMixedListEntry famInsts (shim allocLFamInstDecl)

    bindsLayout' = allocMixedList (bindMix++sigMix++famMix) toks2
    r = strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ polytLayout ++ bindsLayout'
             ++ (makeLeafFromToks toks')
allocInstDecl (GHC.L l (GHC.FamInstD decl)) toks = r
  where
    (s1,toks1,s2) = splitToksIncComments (ghcSpanStartEnd l) toks
    declLayout = allocLFamInstDecl (GHC.L l decl) toks1
    r = strip $(makeLeafFromToks s1) ++ declLayout ++ (makeLeafFromToks s2)
#else
-- InstDecl (LHsType name) (LHsBinds name) [LSig name] [LTyClDecl name]
allocInstDecl (GHC.L l (GHC.InstDecl (GHC.L ln _) binds sigs tycldecls)) toks = r
  where
    (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks

    -- TODO: will require 3-way merge of binds,sigs and famInsts
    bindList = GHC.bagToList binds
    bindMix = makeMixedListEntry bindList (shim allocBind)
    sigMix  = makeMixedListEntry sigs (shim allocSig)
    famMix  = makeMixedListEntry tycldecls (shim allocLTyClDecl)

    bindsLayout' = allocMixedList (bindMix++sigMix++famMix) toks1
    r = strip $ (makeLeafFromToks s1)
             ++ bindsLayout'
             ++ (makeLeafFromToks toks')
#endif

-- ---------------------------------------------------------------------

#if __GLASGOW_HASKELL__ > 704
allocLFamInstDecl :: GHC.LFamInstDecl GHC.RdrName -> [PosToken] -> [LayoutTree]
allocLFamInstDecl (GHC.L l (GHC.FamInstDecl n@(GHC.L ln _) (GHC.HsWB typs _ _) defn _fvs)) toks = r
  where
    (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nToks,toks2) = splitToksIncComments (ghcSpanStartEnd ln) toks1
    (s3,typsToks,defnToks) = splitToksForList typs toks2

    nLayout = allocLocated n nToks
    patsLayout = allocList typs typsToks allocType
    (defnLayout,s4) = allocHsTyDefn defn defnToks
    r = strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ nLayout ++ (makeLeafFromToks s3)
             ++ patsLayout ++ defnLayout
             ++ (makeLeafFromToks s4)
             ++ (makeLeafFromToks toks')
#endif

-- ---------------------------------------------------------------------

allocTupArgList :: [GHC.HsTupArg GHC.RdrName] -> [PosToken] -> [LayoutTree]
allocTupArgList tas toksIn = r
  where
    go :: ([LayoutTree],[PosToken]) -> [GHC.HsTupArg GHC.RdrName] -> ([LayoutTree],[PosToken])
    go (acc,toks) [] = (acc,toks)
    go (acc,toks) ((GHC.Missing _):ts')    = go (acc,toks) ts'
    go (acc,toks) ((GHC.Present expr@(GHC.L l _)):ts') = go (acc++exprLayout,toks') ts'
      where
        (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
        eLayout = allocExpr expr toks1
        exprLayout = strip $ (makeLeafFromToks s1) ++ eLayout
    (lay,toksOut) = go ([],toksIn) tas
    r = strip $ lay ++ (makeLeafFromToks toksOut)

-- ---------------------------------------------------------------------

allocLocated :: GHC.Located b -> [PosToken] -> [LayoutTree]
allocLocated (GHC.L l _) toks = r
  where
    (s1,toks1,s2) = splitToksIncComments (ghcSpanStartEnd l) toks
    r = strip $ (makeLeafFromToks s1) ++ [makeLeaf l NoChange toks1] ++ (makeLeafFromToks s2)

-- ---------------------------------------------------------------------

#if __GLASGOW_HASKELL__ > 704
allocTyVarBndrs :: GHC.LHsTyVarBndrs GHC.RdrName -> [PosToken] -> ([LayoutTree],[PosToken])
allocTyVarBndrs (GHC.HsQTvs _kvs tvs) toks = (r,s1)
  where
    (kvsToks,tyvarToks,s1) = splitToksForList tvs toks
    tyvarLayout = allocList tvs tyvarToks allocTyVarBndr
    r = (strip $ (makeLeafFromToks kvsToks) ++ tyvarLayout)
#else

#endif

-- ---------------------------------------------------------------------

allocTyVarBndr :: GHC.LHsTyVarBndr GHC.RdrName -> [PosToken] -> [LayoutTree]
#if __GLASGOW_HASKELL__ > 704
allocTyVarBndr n@(GHC.L l (GHC.UserTyVar _  )) toks = r
#else
allocTyVarBndr n@(GHC.L l (GHC.UserTyVar _ _)) toks = r
#endif
  where
    (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    nLayout = allocLocated n toks1
    r = strip $ (makeLeafFromToks s1) ++ nLayout
             ++ (makeLeafFromToks toks')
#if __GLASGOW_HASKELL__ > 704
allocTyVarBndr (GHC.L l (GHC.KindedTyVar _n k@(GHC.L lk _)  )) toks = r
#else
allocTyVarBndr (GHC.L l (GHC.KindedTyVar _n k@(GHC.L lk _) _)) toks = r
#endif
  where
    (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (nToks,kToks,toks2) = splitToksIncComments (ghcSpanStartEnd lk) toks1
    nLayout = makeLeafFromToks nToks
    kindLayout = allocType k kToks
    r = strip $ (makeLeafFromToks s1) ++ nLayout
             ++ kindLayout ++ (makeLeafFromToks toks2)
             ++ (makeLeafFromToks toks')

-- ---------------------------------------------------------------------

#if __GLASGOW_HASKELL__ > 704
allocHsTyDefn :: GHC.HsTyDefn GHC.RdrName -> [PosToken] -> ([LayoutTree],[PosToken])
allocHsTyDefn (GHC.TySynonym typ@(GHC.L l _)) toks = (r,toks')
  where
    (s1,typToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    typeLayout = allocType typ typToks
    r = [makeGroup $ strip $ (makeLeafFromToks s1) ++ typeLayout]
allocHsTyDefn (GHC.TyData _ (GHC.L lc ctx) mc mk cons mderivs) toks = (r,toks')
  where
    (s1,ctxToks,toks2) = splitToksIncComments (ghcSpanStartEnd lc) toks
    ctxLayout = allocHsContext ctx ctxToks

    -- TODO: correctly determine the token range for this
    (mcLayout,toks3) = case mc of
      Nothing -> ([],toks2)
      Just ct -> (rc,toks2')
        where
          ctLayout = allocCType ct toks2
          toks2' = toks2
          rc = strip $ ctLayout

    (mkLayout,toks4) = case mk of
      Nothing -> ([],toks3)
      Just k@(GHC.L lk _) -> (rk,toks3')
        where
          (sk,kToks,toks3') = splitToksIncComments (ghcSpanStartEnd lk) toks3
          kindLayout = allocHsKind k kToks
          rk = strip $ (makeLeafFromToks sk) ++ kindLayout

    (s2,consToks,toks5) = splitToksForList cons toks4
    consLayout = allocList cons consToks allocConDecl

    (mderivsLayout,toks6) = case mderivs of
      Nothing -> ([],toks5)
      Just ds -> (rd,toksd)
        where
          (sd,derivToks,toksd) = splitToksForList ds toks5
          derivLayout = allocList ds derivToks allocType
          rd = strip $ (makeLeafFromToks sd) ++ derivLayout
    toks' = toks6
    r = [makeGroup $ strip $ (makeLeafFromToks s1) ++ ctxLayout ++ mcLayout ++ mkLayout
             ++ (makeLeafFromToks s2) ++ consLayout ++ mderivsLayout]
#endif

-- ---------------------------------------------------------------------

allocConDecl :: GHC.LConDecl GHC.RdrName -> [PosToken] -> [LayoutTree]
allocConDecl (GHC.L l (GHC.ConDecl n@(GHC.L ln _) _expl qvars (GHC.L lc ctx) details res mdoc _)) toks = r
  where
    (s1,conDeclToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nameToks,toks2) = splitToksIncComments (ghcSpanStartEnd ln) conDeclToks
    nameLayout = allocLocated n nameToks
#if __GLASGOW_HASKELL__ > 704
    (qvarsLayout,toks3) = allocTyVarBndrs qvars toks2
#else
    qvarsLayout = allocList qvars toks2 allocTyVarBndr
    toks3 = []
#endif
    (s3,ctxToks,toks4) = splitToksIncComments (ghcSpanStartEnd lc) toks3
    ctxLayout = allocHsContext ctx ctxToks

    (detailsLayout,toks5) = allocHsConDeclDetails details toks4
    (resLayout,toks6) = case res of
      GHC.ResTyH98 -> ([],toks5)
      GHC.ResTyGADT (ty@(GHC.L lt _)) -> (rt,toks6')
        where
          (st,tyToks,toks6') = splitToksIncComments (ghcSpanStartEnd lt) toks5
          tyLayout = allocType ty tyToks
          rt = strip $ (makeLeafFromToks st) ++ tyLayout

    (docLayout,toks7) = case mdoc of
      Nothing -> ([],toks6)
      Just ds@(GHC.L ld _) -> (rd,toks7')
        where
          (sd,dsToks,toks7') = splitToksIncComments (ghcSpanStartEnd ld) toks6
          dsLayout = allocLocated ds dsToks
          rd = strip (makeLeafFromToks sd) ++ dsLayout

    r = strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ nameLayout ++ qvarsLayout ++ (makeLeafFromToks s3)
             ++ ctxLayout ++ detailsLayout ++ resLayout
             ++ docLayout ++ (makeLeafFromToks toks7)
             ++ (makeLeafFromToks toks')

-- ---------------------------------------------------------------------

allocHsConDeclDetails :: GHC.HsConDeclDetails GHC.RdrName -> [PosToken] -> ([LayoutTree],[PosToken])
allocHsConDeclDetails (GHC.PrefixCon ds) toks = (r,toks')
  where
    (s1,dsToks,toks') = splitToksForList ds toks
    dsLayout = allocList ds dsToks allocLBangType
    r = strip $ (makeLeafFromToks s1) ++ dsLayout
allocHsConDeclDetails (GHC.RecCon conDecls) toks = allocConDeclFieldList conDecls toks
allocHsConDeclDetails (GHC.InfixCon bt1@(GHC.L lb1 _) bt2@(GHC.L lb2 _)) toks = (r,toks')
  where
    (s1,bt1Toks,toks2) = splitToksIncComments (ghcSpanStartEnd lb1) toks
    (s2,bt2Toks,toks') = splitToksIncComments (ghcSpanStartEnd lb2) toks2
    bt1Layout = allocType bt1 bt1Toks
    bt2Layout = allocType bt2 bt2Toks

    r = strip $ (makeLeafFromToks s1) ++ bt1Layout
             ++ (makeLeafFromToks s2) ++ bt2Layout

-- ---------------------------------------------------------------------

allocConDeclFieldList :: [GHC.ConDeclField GHC.RdrName] -> [PosToken] -> ([LayoutTree],[PosToken])
allocConDeclFieldList conDecls toks = (r,toks')
  where
    (r,toks') = foldl' doOne ([],toks) conDecls

    doOne (acc,toksOne) cdf = (r1,toks2)
      where
        (lay,toks2) = allocConDeclField cdf toksOne
        r1 = acc ++ lay

allocConDeclField :: GHC.ConDeclField GHC.RdrName -> [PosToken] -> ([LayoutTree],[PosToken])
allocConDeclField (GHC.ConDeclField n@(GHC.L ln _) typ@(GHC.L lb _) mdoc) toks = (r,toks')
  where
    (s1,nToks,toks1) = splitToksIncComments (ghcSpanStartEnd ln) toks
    nLayout = allocLocated n nToks
    (s2,btToks,toks2) = splitToksIncComments (ghcSpanStartEnd lb) toks1
    btLayout = allocLBangType typ btToks
    (mdocLayout,toks') = case mdoc of
      Nothing -> ([],toks2)
      Just ldoc@(GHC.L ld _) -> (rd,toks2')
        where
          (sd,docToks,toks2') = splitToksIncComments (ghcSpanStartEnd ld) toks2
          rdLayout = allocLocated ldoc docToks
          rd = strip $ (makeLeafFromToks sd) ++ rdLayout
    r = strip $ (makeLeafFromToks s1) ++ nLayout ++ (makeLeafFromToks s2)
             ++ btLayout ++ mdocLayout

-- ---------------------------------------------------------------------

allocLBangType :: GHC.LBangType GHC.RdrName -> [PosToken] -> [LayoutTree]
allocLBangType bt toks = allocType bt toks

-- ---------------------------------------------------------------------

allocHsKind :: GHC.LHsKind GHC.RdrName -> [PosToken] -> [LayoutTree]
allocHsKind = error "allocHsKind undefined"

-- ---------------------------------------------------------------------

#if __GLASGOW_HASKELL__ > 704
allocCType :: GHC.CType -> [PosToken] -> [LayoutTree]
#endif
allocCType = error "allocCType undefined"

-- ---------------------------------------------------------------------

allocHsContext :: GHC.HsContext GHC.RdrName -> [PosToken] -> [LayoutTree]
allocHsContext ts toks = r
  where
    r = allocList ts toks allocType

-- ---------------------------------------------------------------------

strip :: [LayoutTree] -> [LayoutTree]
strip ls = filter (not . emptyNode) ls
  where
    emptyNode (Node (Entry _ _ []) []) = True
    emptyNode _                        = False

-- ---------------------------------------------------------------------

allocList ::
      [GHC.Located b]
   -> [PosToken]
   -> (GHC.Located b -> [PosToken] -> [LayoutTree])
   -> [LayoutTree]
allocList xs toksIn allocFunc = r
  where
    (s2,listToks,toks2') = splitToksForList xs toksIn
    (layout,toks2) = (allocAll xs listToks,toks2')

    allocAll xs' toks = res
      where
        (declLayout,tailToks) = foldl' doOne ([],toks) xs'

        res = strip $ declLayout ++ (makeLeafFromToks tailToks)

        -- doOne :: ([LayoutTree],[PosToken]) -> GHC.Located a -> ([LayoutTree],[PosToken])
        doOne (acc,toksOne) x@(GHC.L l _) = r1
          where
            (s1,funcToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toksOne
            layout' = (makeLeafFromToks s1) ++ [makeGroup (strip $ allocFunc x funcToks)]
            r1 = (acc ++ (strip layout'),toks')

    -- r = strip $ (makeLeafFromToks s2) ++ layout ++ (makeLeafFromToks toks2)
    r = strip $ (makeLeafFromToks s2) ++ [makeGroup $ strip $ layout] ++ (makeLeafFromToks toks2)

-- ---------------------------------------------------------------------

-- TODO: get rid of this in favour of mix stuf
allocInterleavedLists :: [GHC.Located a] -> [GHC.Located b] -> [PosToken]
   -> (GHC.Located a -> [PosToken] -> [LayoutTree])
   -> (GHC.Located b -> [PosToken] -> [LayoutTree])
   -> [LayoutTree]
allocInterleavedLists axs bxs toksIn allocFuncA allocFuncB = r
  where
    -- go :: ([LayoutTree],[PosToken]) -> [GHC.Located a] -> [GHC.Located b] -> ([LayoutTree],[PosToken])
    go (acc,ts) []     []     = (acc,ts)
    go (acc,ts) (a:as) []     = go (acc ++ aa,ts') as []
        where
          (aa,ts') = allocA a ts
    go (acc,ts) []     (b:bs) = go (acc ++ bb,ts') [] bs
        where
          (bb,ts') = allocB b ts
    go (acc,ts) (a:as) (b:bs) = if GHC.getLoc a < GHC.getLoc b
                             then go (acc ++ aa,tsa') as (b:bs)
                             else go (acc ++ bb,tsb') (a:as) bs
        where
          (aa,tsa') = allocA a ts
          (bb,tsb') = allocB b ts

    -- allocA :: GHC.Located a -> [PosToken] -> ([LayoutTree],[PosToken])
    allocA x@(GHC.L l _) toks = (r',toks')
      where
        (s1,funcToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
        funcLayout = allocFuncA x funcToks
        r' = strip $ (makeLeafFromToks s1) ++ [makeGroup (strip funcLayout)]

    -- allocB :: GHC.Located b -> [PosToken] -> ([LayoutTree],[PosToken])
    allocB x@(GHC.L l _) toks = (r',toks')
      where
        (s1,funcToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
        funcLayout = allocFuncB x funcToks
        r' = strip $ (makeLeafFromToks s1) ++ [makeGroup (strip funcLayout)]

    (layout,s2) = go ([],toksIn) axs bxs
    r = strip $ layout ++ (makeLeafFromToks s2)

-- ---------------------------------------------------------------------

shim ::
    (GHC.Located a -> [PosToken] -> [LayoutTree])
 -> (GHC.Located a -> [PosToken] -> ([LayoutTree],[PosToken]))
shim f = f'
  where
    f' x@(GHC.L l _) toks = (r,toks')
      where
        (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
        r = strip $ (makeLeafFromToks s1) ++ f x toks1

makeMixedListEntry ::
      [GHC.Located a]
   -> (GHC.Located a -> [PosToken] -> ([LayoutTree],[PosToken]))
   -> [(SimpPos,([PosToken] -> ([LayoutTree],[PosToken])))]
makeMixedListEntry xs f = map (\x@(GHC.L l _) -> (fst $ ghcSpanStartEnd l,f x)) xs

allocMixedList ::
       [(SimpPos,([PosToken] -> ([LayoutTree],[PosToken])))]
   -> [PosToken] -> [LayoutTree]
allocMixedList xs toksIn = r
  where
    xs' = sortBy (\(p1,_) (p2,_) -> compare p1 p2) xs
    (layout,toksFin) = foldl' doOne ([],toksIn) xs'

    doOne :: ([LayoutTree],[PosToken]) -> (SimpPos,([PosToken] -> ([LayoutTree],[PosToken])))
              -> ([LayoutTree],[PosToken])
    doOne (acc,toks) (_,f) = (acc++lay,toks')
      where
        (lay,toks') = f toks

    r = strip $ layout ++ (makeLeafFromToks toksFin)

-- ---------------------------------------------------------------------

-- | Split the given tokens into the ones that occur prior to the start
-- of the list and ones that occur after
splitToksForList :: [GHC.Located a] -> [PosToken] -> ([PosToken],[PosToken],[PosToken])
splitToksForList [] toks = ([],[],toks)
splitToksForList xs toks = splitToksIncComments (getGhcLoc s, getGhcLocEnd e) toks
  where
    (GHC.L s _) = head xs
    (GHC.L e _) = last xs

-- ---------------------------------------------------------------------

calcLastTokenPos :: [PosToken] -> (Int,Int)
calcLastTokenPos toks = (rt,ct)
  where
    (rt,ct) = case (dropWhile isEmpty (reverse toks)) of
             []    -> (0,0)
             (x:_) -> (tokenRow x,tokenCol x + tokenLen x)

-- ---------------------------------------------------------------------

placeAbove :: EndOffset -> (Row,Col) -> (Row,Col) -> [LayoutTree] -> LayoutTree
placeAbove _ _ _ [] = error "placeAbove []"
placeAbove so p1 p2 ls = Node (Entry loc (Above so p1 p2 None) []) ls
  where
    loc = combineSpans (getLoc $ head ls) (getLoc $ last ls)

-- ---------------------------------------------------------------------

makeGroup :: [LayoutTree] -> LayoutTree
makeGroup [x] = x
makeGroup ls  = makeGroupLayout NoChange ls

makeGroupLayout :: Layout -> [LayoutTree] -> LayoutTree
makeGroupLayout lay ls = Node (Entry loc lay []) ls
  where
    loc = case ls of
           [] -> sf nullSrcSpan
           _  -> combineSpans (getLoc $ head ls) (getLoc $ last ls)

mkGroup :: GHC.SrcSpan -> Layout -> [LayoutTree] -> LayoutTree
mkGroup sspan lay subs = Node (Entry (sf sspan) lay []) subs

-- ---------------------------------------------------------------------

makeLeafFromToks :: [PosToken] -> [LayoutTree]
makeLeafFromToks [] = []
makeLeafFromToks toks = [Node (Entry loc NoChange toks) []]
  where
    loc = sspan

    (startLoc',endLoc') = nonCommentSpanLayout toks
    sspan    = if (startLoc',endLoc') == ((0,0),(0,0))
      then error $ "mkLeafFromToks:null span for:" ++ (show toks)
      else simpPosToForestSpan (startLoc',endLoc')

-- ---------------------------------------------------------------------

-- |Extract the start and end position of a span, without any leading
-- or trailing comments
nonCommentSpanLayout :: [PosToken] -> (SimpPos,SimpPos)
nonCommentSpanLayout [] = ((0,0),(0,0))
nonCommentSpanLayout toks = (startPos,endPos)
  where
    stripped = dropWhile isComment $ toks
    (startPos,endPos) = case stripped of
      -- [] -> ((0,0),(0,0))
      [] -> (tokenPos $ head toks,tokenPosEnd $ last toks)
      _ -> (tokenPos startTok,tokenPosEnd endTok)
       where
        startTok = ghead "nonCommentSpan.1" $ dropWhile isComment $ toks
        endTok   = ghead "nonCommentSpan.2" $ dropWhile isComment $ reverse toks


makeLeaf :: GHC.SrcSpan -> Layout -> [PosToken] -> LayoutTree
makeLeaf sspan lay toks = Node (Entry (sf sspan) lay toks) []

-- ---------------------------------------------------------------------

getLoc :: LayoutTree -> ForestSpan
getLoc (Node (Entry   l _ _) _) = l
getLoc (Node (Deleted l _ _) _) = l

-- ---------------------------------------------------------------------

retrieveTokens :: LayoutTree -> [PosToken]
retrieveTokens layout = go [] layout
  where
    -- go acc (Group _ _ xs)  = acc ++ (concat $ map (go []) xs)
    -- go acc (Leaf _ _ toks) = acc ++ toks
    go acc (Node (Entry _ _ []  ) xs) = acc ++ (concat $ map (go []) xs)
    go acc (Node (Entry _ _ toks)  _) = acc ++ toks
    go acc (Node (Deleted _ _ _)   _) = acc

-- ---------------------------------------------------------------------

-- | Split the given tokens to include the comments belonging to the span.
splitToksIncComments ::
     (SimpPos, SimpPos)
  -> [PosToken]
  -> ([PosToken], [PosToken], [PosToken])
splitToksIncComments pos toks = splitToks pos' toks
  where
    pos' = startEndLocIncComments' toks pos

-- ---------------------------------------------------------------------

