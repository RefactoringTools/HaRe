{-# LANGUAGE CPP #-}
{-# LANGUAGE StandaloneDeriving   #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE ScopedTypeVariables  #-}

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
-- import qualified HsTypes       as GHC
-- import qualified Outputable    as GHC
-- import qualified SrcLoc        as GHC

import Outputable

-- import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import Data.List
-- import Data.Maybe
import Data.Tree
-- import Language.Haskell.Refact.Utils.GhcUtils
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
  ppr (Deleted sspan eg)     = text "Deleted" <+> ppr sspan <+> ppr eg

instance Outputable Layout where
  ppr (Above ro co p1 p2 oe)   = text "Above" <+> ppr ro <+> ppr co <+> ppr p1 <+> ppr p2 <+> ppr oe
  ppr (Offset r c)    = text "Offset" <+> ppr r <+> ppr c
  ppr (NoChange)      = text "NoChange"
  -- ppr (EndOffset r c) = text "EndOffset" <+> ppr r <+> ppr c

instance Outputable Ppr where
  ppr (PprText r c toks) = text "PprText" <+> ppr r <+> ppr c
                        <+> text "\"" <> text (GHC.showRichTokenStream toks) <> text "\""
  ppr (PprAbove ro co rc erc pps) = hang (text "PprAbove" <+> ppr ro <+> ppr co <+> ppr rc <+> ppr erc)
                                           2 (ppr pps)
  ppr (PprOffset ro co pps)       = hang (text "PprOffset" <+> ppr ro <+> ppr co)
                                           2 (ppr pps)

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

    (declLayout,_toks4) =
      case decls of
        [] -> ([],toks3)
        -- is -> ([Leaf s4,Leaf impToks,Leaf toks4'],[])
        is -> ((makeLeafFromToks s4) ++ allocDecls is declToks ++ (makeLeafFromToks toks4'),[])
          where
            (s4,declToks,toks4') = splitToksForList is toks3

    r' = makeGroup (strip $ nameLayout ++ exportLayout ++ importLayout ++ declLayout)
    r = addEndOffsets r' toks
    -- r = error $ "allocTokens:(nameLayout,toks1)=" ++ (show (nameLayout,toks1)) -- ++AZ++
    -- r = error $ "allocTokens:(exportLayout,toks2)=" ++ (show (exportLayout,toks2)) -- ++AZ++
    -- r = error $ "allocTokens:(importLayout,toks3)=" ++ (show (importLayout,toks3)) -- ++AZ++
    -- r = error $ "allocTokens:(declLayout,toks4)=" ++ (show (declLayout,_toks4)) -- ++AZ++

-- ---------------------------------------------------------------------

addEndOffsets :: LayoutTree -> [PosToken] -> LayoutTree
addEndOffsets tree toks = go tree
  where
    go (t@(Node (Entry _ _ _toks) [])) = t
    go (  (Node (Entry s (Above ro co p1 (r,c) _eo) []) subs)) = (Node (Entry s (Above ro co p1 (r,c) eo') []) (map go subs))
      where
        -- (_,m,_) = splitToksIncComments ((r,c),(99999,1)) toks
        (_,m,_) = splitToks ((r,c),(99999,1)) toks
        -- eo' = case m of
        eo' = case (dropWhile isWhiteSpaceOrIgnored m) of
               (_x:y:_ts) -> (tokenRow y - r, tokenCol y - c)
               _ -> (0,0)
        -- eo' = error $ "addEndOffsets:m=" ++ (show m)
        -- eo' = (0,0)
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
allocTyClD (acc,toks) (GHC.L l (GHC.TyClD (GHC.ForeignType ln _))) = (r,toks')
  where
    (s1,clToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    lnToks = allocLocated ln clToks
    r = acc ++ (strip $ (makeLeafFromToks s1) ++ lnToks)
allocTyClD (acc,toks) (GHC.L l (GHC.TyClD (GHC.TyFamily _f n@(GHC.L ln _) vars _mk))) = (r,toks')
  where
    (s1,clToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nToks,varsToks) = splitToksIncComments (ghcSpanStartEnd ln) toks'
    nLayout = allocLocated n nToks
    (varsLayout,s3) = allocTyVarBndrs vars varsToks
    r = acc ++ (strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks clToks)
                     ++ (makeLeafFromToks s2) ++ nLayout ++ varsLayout
                     ++ (makeLeafFromToks s3))
allocTyClD (acc,toks) (GHC.L l (GHC.TyClD (GHC.TyDecl (GHC.L ln _) vars def _fvs))) = (r,toks')
  where
    (s1,clToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nToks,toks'') = splitToksIncComments (ghcSpanStartEnd ln) clToks
    (varsLayout,toks3) = allocTyVarBndrs vars toks''
    (typeLayout,toks4) = allocHsTyDefn def toks3
    r = acc ++ (strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
                     ++ (makeLeafFromToks nToks) ++ varsLayout ++ typeLayout
                     ++ (makeLeafFromToks toks4))
allocTyClD (acc,toks) (GHC.L l (GHC.TyClD (GHC.ClassDecl (GHC.L lc ctx) n@(GHC.L ln _) vars fds sigs meths ats atdefs docs _fvs))) = (acc++r,toks')
  where
    (s1,clToks,  toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,ctxToks, toks1) = splitToksIncComments (ghcSpanStartEnd lc) clToks
    (s3,nToks,   toks2) = splitToksIncComments (ghcSpanStartEnd ln) toks1
    (varsLayout, toks3) = allocTyVarBndrs vars toks2
    (s5,fdToks,  toks4) = splitToksForList fds toks3

    ctxLayout = allocHsContext ctx ctxToks
    nLayout   = allocLocated n nToks
    fdsLayout = allocList fds fdToks allocFunDep

    bindList = GHC.bagToList meths
    sigMix     = makeMixedListEntry sigs     (shim allocSig)
    methsMix   = makeMixedListEntry bindList (shim allocBind)
    atsMix     = makeMixedListEntry ats      (shim allocLTyClDecl)
    atsdefsMix = makeMixedListEntry atdefs   (shim allocLFamInstDecl)
    docsMix    = makeMixedListEntry docs     (shim allocLocated)

    bindsLayout = allocMixedList (sigMix++methsMix++atsMix++atsdefsMix++docsMix) toks4

    r = strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
             ++ ctxLayout ++ (makeLeafFromToks s3)
             ++ nLayout ++ varsLayout ++ (makeLeafFromToks s5)
             ++ fdsLayout ++ bindsLayout

{-
ClassDecl

tcdCtxt :: LHsContext name

    Context... 
tcdLName :: Located name

    Name of the class

    Type constructor 
tcdTyVars :: LHsTyVarBndrs name

    Class type variables

    Type variables; for an associated type these include outer binders Eg class T a where type F a :: * type F a = a -> a Here the type decl for f includes a in its tcdTyVars 
tcdFDs :: [Located (FunDep name)]

    Functional deps 
tcdSigs :: [LSig name]

    Methods' signatures 
tcdMeths :: LHsBinds name

    Default methods 
tcdATs :: [LTyClDecl name]

    Associated types; ie only TyFamily 
tcdATDefs :: [LFamInstDecl name]

    Associated type defaults; ie only TySynonym 
tcdDocs :: [LDocDecl]

    Haddock docs 
tcdFVs :: NameSet


-}
-- ---------------------------------------------------------------------

allocInstD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocInstD (acc,toks) (GHC.L l (GHC.InstD inst)) = (r,toks')
  where
    (s1,instToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    instLayout = allocInstDecl (GHC.L l inst) instToks
    r = acc ++ (strip $ (makeLeafFromToks s1) ++ [makeGroup instLayout] )


-- ---------------------------------------------------------------------

allocDerivD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocDerivD (acc,toks) d@(GHC.L l (GHC.DerivD      _))
  = error "allocDerivD undefined"

-- ---------------------------------------------------------------------

allocValD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocValD (acc,toks) (GHC.L l (GHC.ValD bind)) = (r,toks')
  where
    (s1,bindToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    bindLayout = allocBind (GHC.L l bind) bindToks
    r = acc ++ (strip $ (makeLeafFromToks s1) ++ [makeGroup bindLayout] )


-- ---------------------------------------------------------------------

allocSigD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocSigD (acc,toks) (GHC.L l (GHC.SigD sig)) = (r,toks')
  where
    (s1,sigToks,toks')  = splitToksIncComments (ghcSpanStartEnd l) toks
    sigLayout = allocSig (GHC.L l sig) sigToks
    r = acc ++ (strip $ (makeLeafFromToks s1)
                     ++ sigLayout)

-- ---------------------------------------------------------------------

allocDefD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocDefD (acc,toks) d@(GHC.L l (GHC.DefD        _))
  = error "allocDefD undefined"

-- ---------------------------------------------------------------------

allocForD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocForD (acc,toks) d@(GHC.L l (GHC.ForD        _))
  = error "allocForD undefined"

-- ---------------------------------------------------------------------

allocWarningD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocWarningD (acc,toks) d@(GHC.L l (GHC.WarningD    _))
  = error "allocWarningD undefined"

-- ---------------------------------------------------------------------

allocAnnD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocAnnD (acc,toks) d@(GHC.L l (GHC.AnnD        _))
  = error "allocAnnD undefined"

-- ---------------------------------------------------------------------

allocRuleD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocRuleD (acc,toks) d@(GHC.L l (GHC.RuleD       _))
  = error "allocRuleD undefined"

-- ---------------------------------------------------------------------

allocVectD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocVectD (acc,toks) d@(GHC.L l (GHC.VectD       _))
  = error "allocVectD undefined"

-- ---------------------------------------------------------------------

allocSpliceD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocSpliceD (acc,toks) d@(GHC.L l (GHC.SpliceD     _))
  = error "allocSpliceD undefined"

-- ---------------------------------------------------------------------

allocDocD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocDocD (acc,toks) d@(GHC.L l (GHC.DocD        _))
  = error "allocDocD undefined"

-- ---------------------------------------------------------------------

allocQuasiQuoteD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocQuasiQuoteD (acc,toks) d@(GHC.L l (GHC.QuasiQuoteD _))
  = error "allocQuasiQuoteD undefined"

-- ---------------------------------------------------------------------

allocMatches :: [GHC.LMatch GHC.RdrName] -> [PosToken] -> [LayoutTree]
allocMatches matches toksIn = allocList matches toksIn doOne
  where
    doOne :: GHC.LMatch GHC.RdrName -> [PosToken] -> [LayoutTree]
    doOne (GHC.L _ (GHC.Match pats mtyp grhs@(GHC.GRHSs rhs _))) toks = r
      where
        (s1,patsToks,toks1) = splitToksForList pats toks
        (mtypLayout,toks') = case mtyp of
          Nothing -> ([],toks1)
          Just (typ@(GHC.L l _)) -> (typeLayout,toks'')
            where
              (t1,typToks,toks'') = splitToksIncComments (ghcSpanStartEnd l) toks1
              typeLayout = strip $ (makeLeafFromToks t1) ++ allocType typ typToks

        (s2,rhsToks,bindsToks) = splitToksForList rhs toks'
        patLayout = allocList pats patsToks allocPat
        grhsLayout = allocGRHSs grhs (rhsToks++bindsToks)
        r = (strip $ (makeLeafFromToks s1) ++ patLayout ++ mtypLayout
                  ++ (makeLeafFromToks s2) ++ grhsLayout)

-- ---------------------------------------------------------------------

allocGRHSs :: GHC.GRHSs GHC.RdrName -> [PosToken] -> [LayoutTree]
allocGRHSs (GHC.GRHSs rhs localBinds) toks = r
  where
    (s1,rhsToks,bindsToks) = splitToksForList rhs toks
    rhsLayout = allocList rhs rhsToks allocRhs
    localBindsLayout = allocLocalBinds localBinds bindsToks
    r = (strip $ (makeLeafFromToks s1) ++ rhsLayout ++ localBindsLayout)
    -- r = error $ "allocGRHSs:toks=" ++ (show localBindsLayout)

-- ---------------------------------------------------------------------

allocPat :: GHC.LPat GHC.RdrName -> [PosToken] -> [LayoutTree]
allocPat (GHC.L l _) toks = makeLeafFromToks toks

-- ---------------------------------------------------------------------

allocRhs :: GHC.LGRHS GHC.RdrName -> [PosToken] -> [LayoutTree]
allocRhs (GHC.L _l (GHC.GRHS stmts expr)) toksIn = r
  where
    (s1,stmtsToks,toks') = splitToksForList stmts toksIn
    stmtsLayout = allocList stmts stmtsToks allocStmt
    exprLayout = allocExpr expr toks'
    r = strip $ (makeLeafFromToks s1) ++ stmtsLayout ++ exprLayout

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
allocStmt (GHC.L _ (GHC.ParStmt stmts _ _))          toks = error "allocStmt ParStmt undefined"
#else
allocStmt (GHC.L _ (GHC.ParStmt stmts _ _ _))        toks = error "allocStmt ParStmt undefined"
#endif
allocStmt (GHC.L _ (GHC.TransStmt _ _ _ _ _ _ _ _ )) toks = error "allocStmt TransStmt undefined"
allocStmt (GHC.L _ (GHC.RecStmt _ _ _ _ _ _ _ _ _))  toks = error "allocStmt RecStmt undefined"

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
allocExpr (GHC.L _ (GHC.HsApp e1@(GHC.L l1 _) e2)) toks = r
  where
    (s1,e1Toks,e2Toks) = splitToksIncComments (ghcSpanStartEnd l1) toks
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    r = strip $ (makeLeafFromToks s1) ++ e1Layout ++ e2Layout
allocExpr (GHC.L _ (GHC.OpApp e1@(GHC.L l1 _) e2@(GHC.L l2 _) _ e3)) toks = r
  where
    (s1,e1Toks,toks1) = splitToksIncComments (ghcSpanStartEnd l1) toks
    (s2,e2Toks,e3Toks) = splitToksIncComments (ghcSpanStartEnd l2) toks1
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    e3Layout = allocExpr e3 e3Toks
    r = strip $ (makeLeafFromToks s1) ++ e1Layout ++ (makeLeafFromToks s2) ++ e2Layout ++ e3Layout
allocExpr (GHC.L _ (GHC.NegApp expr _)) toks = allocExpr expr toks
allocExpr (GHC.L _ (GHC.HsPar expr))    toks = allocExpr expr toks
allocExpr (GHC.L _ (GHC.SectionL e1@(GHC.L l1 _) e2)) toks = r
  where
    (s1,e1Toks,e2Toks) = splitToksIncComments (ghcSpanStartEnd l1) toks
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    r = strip $ (makeLeafFromToks s1) ++ e1Layout ++ e2Layout
allocExpr (GHC.L _ (GHC.SectionR e1@(GHC.L l1 _) e2)) toks = r
  where
    (s1,e1Toks,e2Toks) = splitToksIncComments (ghcSpanStartEnd l1) toks
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    r = strip $ (makeLeafFromToks s1) ++ e1Layout ++ e2Layout
allocExpr (GHC.L l (GHC.ExplicitTuple tupArgs _)) toks = r
  where
    (s1,tupToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    tupLayout = allocTupArgList tupArgs tupToks
    r = strip $ (makeLeafFromToks s1) ++ tupLayout
             ++ (makeLeafFromToks toks')
-- ExplicitTuple [HsTupArg id] Boxity
allocExpr (GHC.L _ (GHC.HsCase expr@(GHC.L le _) (GHC.MatchGroup matches _))) toks = r
  where
    (s1,exprToks,toks1) = splitToksIncComments (ghcSpanStartEnd le) toks
    (s2,matchToks,toks2) = splitToksForList matches toks1
    exprLayout = allocExpr expr exprToks

    firstMatchTok = ghead "allocLocalBinds" $ dropWhile isWhiteSpaceOrIgnored matchToks
    p1 = (tokenRow firstMatchTok,tokenCol firstMatchTok)
    (ro,co) = case (filter isOf s2) of
               [] -> (0,0)
               (x:_) -> (tokenRow firstMatchTok - tokenRow x,
                         tokenCol firstMatchTok - (tokenCol x + tokenLen x))

    (rt,ct) = case (dropWhile isWhiteSpaceOrIgnored (reverse matchToks)) of
             []    -> (0,0)
             (x:_) -> (tokenRow x,tokenCol x)

    matchesLayout = [placeAbove ro co p1 (rt,ct) (allocMatches matches matchToks)]
    r = strip $ (makeLeafFromToks s1) ++ exprLayout
             ++ (makeLeafFromToks s2) ++ matchesLayout ++ (makeLeafFromToks toks2)
allocExpr (GHC.L _ (GHC.HsIf _ e1@(GHC.L l1 _) e2@(GHC.L l2 _) e3)) toks = r
  where
    (s1,e1Toks,toks1) = splitToksIncComments (ghcSpanStartEnd l1) toks
    (s2,e2Toks,e3Toks) = splitToksIncComments (ghcSpanStartEnd l2) toks1
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    e3Layout = allocExpr e3 e3Toks
    r = strip $ (makeLeafFromToks s1) ++ e1Layout ++ (makeLeafFromToks s2) ++ e2Layout ++ e3Layout
#if __GLASGOW_HASKELL__ > 704
allocExpr (GHC.L _ (GHC.HsMultiIf _ rhs)) toks = allocList rhs toks allocRhs
#endif
allocExpr (GHC.L _ (GHC.HsLet localBinds expr@(GHC.L le _))) toks = r
  where
    (bindToks,exprToks,toks') = splitToksIncComments (ghcSpanStartEnd le) toks
    bindLayout = allocLocalBinds localBinds bindToks
    exprLayout = allocExpr expr exprToks
    r = strip $ bindLayout ++ [makeGroup exprLayout] ++ (makeLeafFromToks toks')
allocExpr (GHC.L _ (GHC.HsDo _ stmts _)) toks = allocList stmts toks allocStmt
allocExpr (GHC.L _ (GHC.ExplicitList _ exprs)) toks = allocList exprs toks allocExpr
allocExpr (GHC.L _ (GHC.ExplicitPArr _ exprs)) toks = allocList exprs toks allocExpr
allocExpr (GHC.L _ (GHC.RecordCon (GHC.L ln _) _ (GHC.HsRecFields fields _))) toks = r
  where
    (s1,nameToks,fieldsToks) = splitToksIncComments (ghcSpanStartEnd ln) toks
    nameLayout = [makeLeaf ln NoChange nameToks]
    fieldsLayout = error "allocExpr allocRecField needs work"
    r = strip $ (makeLeafFromToks s1) ++ nameLayout ++ fieldsLayout

allocExpr (GHC.L _ (GHC.ArithSeq _ info)) toks = allocArithSeqInfo info toks

allocExpr e toks = error $ "allocExpr undefined for " ++ (SYB.showData SYB.Parser 0  e)

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

    (rt,ct) = case (dropWhile isWhiteSpaceOrIgnored (reverse toksBinds)) of
             [] -> (0,0)
             (x:_) -> (tokenRow x,tokenCol x)

    bindsLayout' = allocInterleavedLists bindList sigs (toksBinds) allocBind allocSig

    bindsLayout = case bindsLayout' of
      [] -> []
      bs -> [placeAbove ro co p1 (rt,ct) bs]

    r = strip $ (makeLeafFromToks s1) ++ bindsLayout ++ (makeLeafFromToks toks1)
    -- r = error $ "allocLocalBinds:(s1,toksBinds,toks1)=" ++ show (s1,toksBinds,toks1)

allocLocalBinds (GHC.HsIPBinds ib)  toks = error "allocLocalBinds undefined"

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

    r = (strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
              ++ lhsLayout ++ (makeLeafFromToks s3) ++ grhsLayout
              ++ (makeLeafFromToks toks'))

allocBind d@(GHC.L l (GHC.VarBind n rhs _)) toks  = error "allocValD:VarBinds"
allocBind d@(GHC.L l (GHC.AbsBinds tvs vars exps ev binds)) toks = error "allocValD:AbsBinds"

-- ---------------------------------------------------------------------

allocSig :: GHC.LSig GHC.RdrName -> [PosToken] -> [LayoutTree]
allocSig (GHC.L l (GHC.TypeSig names t@(GHC.L lt _))) toks = r
  where
    (s1,bindToks,toks')  = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nameToks,toks'') = splitToksForList names bindToks
    (s3,typeToks,s4)     = splitToksIncComments (ghcSpanStartEnd lt) toks''
    nameLayout = allocList names nameToks allocLocated
    typeLayout = allocType t typeToks
    r = (strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
               ++ nameLayout ++ (makeLeafFromToks s3) ++ typeLayout
               ++ (makeLeafFromToks s4) ++ (makeLeafFromToks toks'))
allocSig (GHC.L l (GHC.GenericSig names t@(GHC.L lt _))) toks = r
  where
    (s1,bindToks,toks')  = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nameToks,toks'') = splitToksForList names bindToks
    (s3,typeToks,s4)     = splitToksIncComments (ghcSpanStartEnd lt) toks''
    nameLayout = allocList names nameToks allocLocated
    typeLayout = allocType t typeToks
    r = (strip $ (makeLeafFromToks s1) ++ (makeLeafFromToks s2)
            ++ nameLayout ++ (makeLeafFromToks s3) ++typeLayout
            ++ (makeLeafFromToks s4) ++ (makeLeafFromToks toks') )
allocSig (GHC.L l (GHC.IdSig _i)) toks = r
  where
    (s1,nameToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    r = (strip $ (makeLeafFromToks s1) ++ [makeLeaf l NoChange nameToks])
              ++ (makeLeafFromToks toks')
allocSig (GHC.L l (GHC.FixSig (GHC.FixitySig n@(GHC.L ln _) _fix))) toks = r
  where
    (s1,fToks,toks')   = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nToks,fixToks) = splitToksIncComments (ghcSpanStartEnd ln) fToks

    r = (strip $ (makeLeafFromToks s1) ++ (allocLocated n nToks)
              ++ (makeLeafFromToks s2) ++ (makeLeafFromToks fixToks))
              ++ (makeLeafFromToks toks')
allocSig (GHC.L l (GHC.InlineSig n@(GHC.L ln _) _ip)) toks = r
  where
    (s1,sigToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nToks,ipToks)  = splitToksIncComments (ghcSpanStartEnd ln) sigToks
    r = (strip $ (makeLeafFromToks s1) ++ (allocLocated n nToks)
              ++ (makeLeafFromToks s2) ++ (makeLeafFromToks ipToks))
              ++ (makeLeafFromToks toks')
allocSig (GHC.L l (GHC.SpecSig n@(GHC.L ln _) t@(GHC.L lt _) _ip)) toks = r
  where
    (s1,sigToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nToks,toks'')  = splitToksIncComments (ghcSpanStartEnd ln) sigToks
    (s3,tToks,ipToks)  = splitToksIncComments (ghcSpanStartEnd lt) toks''
    nameLayout = allocLocated n nToks
    typeLayout = allocType t tToks
    ipLayout = makeLeafFromToks ipToks
    r = (strip $ (makeLeafFromToks s1) ++ nameLayout ++ (makeLeafFromToks s2)
              ++ typeLayout ++ (makeLeafFromToks s3) ++ ipLayout
              ++ (makeLeafFromToks toks'))
allocSig (GHC.L l (GHC.SpecInstSig t)) toks = r
  where
    (s1,sigToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    r = (strip $ (makeLeafFromToks s1) ++ allocType t sigToks
              ++ (makeLeafFromToks toks'))


{-
GenericSig [Located name] (LHsType name)	 
IdSig Id	 
FixSig (FixitySig name)	 
InlineSig (Located name) InlinePragma	 
SpecSig (Located name) (LHsType name) InlinePragma	 
SpecInstSig (LHsType name)
-}
-- ---------------------------------------------------------------------

allocRecField :: GHC.HsRecFields GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> [PosToken] -> [LayoutTree]
allocRecField = error "Layout.allocRecField undefined"

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
    (varsLayout,toks2) = allocTyVarBndrs vars exprToks
    (s2,ctxToks,toks3) = splitToksIncComments (ghcSpanStartEnd lc) toks2

    ctxLayout = allocHsContext ctx ctxToks
    typLayout = allocType typ toks3

    r = strip $ (makeLeafFromToks s1) ++ varsLayout ++ (makeLeafFromToks s2)
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
allocType n@(GHC.L _l (GHC.HsTyLit _) ) toks = allocLocated n toks
allocType (GHC.L l (GHC.HsWrapTy _ typ) ) toks = allocType (GHC.L l typ) toks
allocType t toks = error $ "allocType: not implemented for:" ++ (showGhc t)

-- ---------------------------------------------------------------------

allocInstDecl :: GHC.LInstDecl GHC.RdrName -> [PosToken] -> [LayoutTree]
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

-- ---------------------------------------------------------------------

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

-- ---------------------------------------------------------------------

allocLTyClDecl = error "allocLTyClDecl undefined"
allocFunDep = error "allocFunDep undefined"

allocHsTupArg :: GHC.HsTupArg GHC.RdrName -> [PosToken] -> [LayoutTree]
allocHsTupArg = error "allocHsTupArg undefined"

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

allocTyVarBndrs :: GHC.LHsTyVarBndrs GHC.RdrName -> [PosToken] -> ([LayoutTree],[PosToken])
allocTyVarBndrs (GHC.HsQTvs _kvs tvs) toks = (r,s1)
  where
    (kvsToks,tyvarToks,s1) = splitToksForList tvs toks
    tyvarLayout = allocList tvs tyvarToks allocTyVarBndr
    r = (strip $ (makeLeafFromToks kvsToks) ++ tyvarLayout)

-- ---------------------------------------------------------------------

allocTyVarBndr :: GHC.LHsTyVarBndr GHC.RdrName -> [PosToken] -> [LayoutTree]
allocTyVarBndr n@(GHC.L l (GHC.UserTyVar _)) toks = r
  where
    (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    nLayout = allocLocated n toks1
    r = strip $ (makeLeafFromToks s1) ++ nLayout
             ++ (makeLeafFromToks toks')
allocTyVarBndr (GHC.L l (GHC.KindedTyVar _n k@(GHC.L lk _))) toks = r
  where
    (s1,toks1,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (nToks,kToks,toks2) = splitToksIncComments (ghcSpanStartEnd lk) toks1
    nLayout = makeLeafFromToks nToks
    kindLayout = allocType k kToks
    r = strip $ (makeLeafFromToks s1) ++ nLayout
             ++ kindLayout ++ (makeLeafFromToks toks2)
             ++ (makeLeafFromToks toks')

{-

data HsTyVarBndr name

Constructors
  UserTyVar name	 
  KindedTyVar name (LHsKind name)	 

-}
-- ---------------------------------------------------------------------

allocHsTyDefn :: GHC.HsTyDefn GHC.RdrName -> [PosToken] -> ([LayoutTree],[PosToken])
allocHsTyDefn (GHC.TySynonym typ@(GHC.L l _)) toks = (r,toks')
  where
    (s1,typToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    typeLayout = allocType typ typToks
    r = strip $ (makeLeafFromToks s1) ++ typeLayout
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
    r = strip $ (makeLeafFromToks s1) ++ ctxLayout ++ mcLayout ++ mkLayout
             ++ (makeLeafFromToks s2) ++ consLayout ++ mderivsLayout

-- ---------------------------------------------------------------------

allocConDecl :: GHC.LConDecl GHC.RdrName -> [PosToken] -> [LayoutTree]
allocConDecl (GHC.L l (GHC.ConDecl n@(GHC.L ln _) _expl qvars (GHC.L lc ctx) details res mdoc _)) toks = r
  where
    (s1,conDeclToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
    (s2,nameToks,toks2) = splitToksIncComments (ghcSpanStartEnd ln) conDeclToks
    nameLayout = allocLocated n nameToks
    (qvarsLayout,toks3) = allocTyVarBndrs qvars toks2
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

allocList :: [GHC.Located b] -> [PosToken]
   -> (GHC.Located b -> [PosToken] -> [LayoutTree])
   -> [LayoutTree]
allocList xs toksIn allocFunc = r
  where
    (s2,listToks,toks2') = splitToksForList xs toksIn
    (layout,toks2) = ((makeLeafFromToks s2) ++ allocAll xs listToks,toks2')

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

    r = strip $ layout ++ (makeLeafFromToks toks2)

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
        -- r' = error $ "allocB:(funcLayout)=" ++ show funcLayout

    (layout,s2) = go ([],toksIn) axs bxs
    r = strip $ layout ++ (makeLeafFromToks s2)

-- ---------------------------------------------------------------------
{-
allocInterleavedLists3 :: [GHC.Located a] -> [GHC.Located b] -> [GHC.Located c]
   -> [PosToken]
   -> (GHC.Located a -> [PosToken] -> [LayoutTree])
   -> (GHC.Located b -> [PosToken] -> [LayoutTree])
   -> (GHC.Located c -> [PosToken] -> [LayoutTree])
   -> [LayoutTree]
allocInterleavedLists3 axs bxs cxs toksIn allocFuncA allocFuncB allocFuncC = r
  where
    -- go :: ([LayoutTree],[PosToken]) -> [GHC.Located a] -> [GHC.Located b] -> ([LayoutTree],[PosToken])
    go (acc,ts) []     []    [] = (acc,ts)
    go (acc,ts) (a:as) []    [] = go (acc ++ aa,ts') as [] []
        where
          (aa,ts') = allocA a ts
    go (acc,ts) []     (b:bs) [] = go (acc ++ bb,ts') [] bs []
        where
          (bb,ts') = allocB b ts
    go (acc,ts) []     [] (c:cs) = go (acc ++ cc,ts') [] [] cs
        where
          (cc,ts') = allocC c ts

    go (acc,ts) (a:as) (b:bs) [] = if GHC.getLoc a < GHC.getLoc b
                             then go (acc ++ aa,tsa') as (b:bs) []
                             else go (acc ++ bb,tsb') (a:as) bs []
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
        -- r' = error $ "allocB:(funcLayout)=" ++ show funcLayout

    -- allocC :: GHC.Located c -> [PosToken] -> ([LayoutTree],[PosToken])
    allocC x@(GHC.L l _) toks = (r',toks')
      where
        (s1,funcToks,toks') = splitToksIncComments (ghcSpanStartEnd l) toks
        funcLayout = allocFuncC x funcToks
        r' = strip $ (makeLeafFromToks s1) ++ [makeGroup (strip funcLayout)]
        -- r' = error $ "allocC:(funcLayout)=" ++ show funcLayout

    (layout,s2) = go ([],toksIn) axs bxs cxs
    r = strip $ layout ++ (makeLeafFromToks s2)
-}

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

placeAbove :: RowOffset -> ColOffset -> (Row,Col) -> (Row,Col) -> [LayoutTree] -> LayoutTree
placeAbove _ _ _ _ [] = error "placeAbove []"
placeAbove ro co p1 p2 ls = Node (Entry loc (Above ro co p1 p2 (0,0)) []) ls
  where
    loc = combineSpans (getLoc $ head ls) (getLoc $ last ls)

-- ---------------------------------------------------------------------

placeOffset :: RowOffset -> ColOffset -> [LayoutTree] -> LayoutTree
placeOffset _ _ [] = error "placeOffset []"
placeOffset r c ls = Node (Entry loc (Offset r c) []) ls
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
    -- TODO: ignore leading/trailing comments etc
    loc = combineSpans (sf $ tokenSrcSpan $ head toks) (sf $ tokenSrcSpan $ last toks)

makeLeaf :: GHC.SrcSpan -> Layout -> [PosToken] -> LayoutTree
makeLeaf sspan lay toks = Node (Entry (sf sspan) lay toks) []

-- ---------------------------------------------------------------------

getLoc :: LayoutTree -> ForestSpan
getLoc (Node (Entry l _ _) _) = l
getLoc (Node (Deleted l _) _) = l

-- ---------------------------------------------------------------------

retrieveTokens :: LayoutTree -> [PosToken]
retrieveTokens layout = go [] layout
  where
    -- go acc (Group _ _ xs)  = acc ++ (concat $ map (go []) xs)
    -- go acc (Leaf _ _ toks) = acc ++ toks
    go acc (Node (Entry _ _ []  ) xs) = acc ++ (concat $ map (go []) xs)
    go acc (Node (Entry _ _ toks)  _) = acc ++ toks
    go acc (Node (Deleted _ _)     _)  = acc

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

