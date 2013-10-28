{-# LANGUAGE StandaloneDeriving #-}

-- |
--

module Language.Haskell.Refact.Utils.Layout (
    initTokenLayout
  , nullTokenLayout
  , allocTokens
  , retrieveTokens
  , getLoc
  ) where

import qualified Bag           as GHC
import qualified GHC           as GHC
import qualified Outputable    as GHC
import qualified SrcLoc        as GHC

import Outputable

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import Data.List
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.LayoutTypes
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TypeSyn

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

deriving instance Show LayoutTree

instance Outputable LayoutTree where
  ppr (Group sspan lay list) = hang (text "Group") 2 (vcat [ppr sspan, ppr lay,ppr list])
  ppr (Leaf sspan lay toks)  = hang (text "Leaf")  2 (vcat [ppr sspan, ppr lay,text (show toks)])

instance Outputable Layout where
  ppr (Above)      = text "Above"
  ppr (Offset r c) = text "Offset" <+> ppr r <+> ppr c
  ppr (NoChange)   = text "NoChange"

-- ---------------------------------------------------------------------

initTokenLayout :: GHC.ParsedSource -> [PosToken] -> TokenLayout
initTokenLayout parsed toks = TL (allocTokens parsed toks)

nullTokenLayout :: TokenLayout
nullTokenLayout = TL (Leaf nullSrcSpan NoChange [])

-- ---------------------------------------------------------------------

-- TODO: bring in startEndLocIncComments'
allocTokens :: GHC.ParsedSource -> [PosToken] -> LayoutTree
allocTokens (GHC.L _l (GHC.HsModule maybeName maybeExports imports decls _warns _haddocks)) toks = r
  where
    (nameLayout,toks1) =
      case maybeName of
        Nothing -> ([],toks)
        Just (GHC.L ln _modName) -> ((makeLeafFromToks s1) ++ [Leaf ln NoChange modNameToks],toks')
          where
            (s1,modNameToks,toks') = splitToks (ghcSpanStartEnd ln) toks

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

    r = makeGroup (strip $ nameLayout ++ exportLayout ++ importLayout ++ declLayout)

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
allocTyClD (acc,toks) d@(GHC.L l (GHC.TyClD       _)) = ([],[])

-- ---------------------------------------------------------------------

allocInstD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocInstD (acc,toks) d@(GHC.L l (GHC.InstD       _)) = ([],[])

-- ---------------------------------------------------------------------

allocDerivD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocDerivD (acc,toks) d@(GHC.L l (GHC.DerivD      _)) = ([],[])

-- ---------------------------------------------------------------------

allocValD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocValD (acc,toks) (GHC.L l (GHC.ValD bind@(GHC.FunBind _ _ _ _ _ _))) = r
  where
    (s1,bindToks,toks') = splitToks (ghcSpanStartEnd l) toks
    bindLayout = allocBind (GHC.L l bind) bindToks
    r = (acc ++ (strip $ (makeLeafFromToks s1) ++ [makeGroup bindLayout] ),toks')

allocValD (acc,toks) d@(GHC.L l (GHC.ValD (GHC.PatBind lhs rhs _ _ _))) = r
  where
    r = ([],[])

allocValD (acc,toks) d@(GHC.L l (GHC.ValD (GHC.VarBind n rhs _))) = error "allocValD:VarBinds"
allocValD (acc,toks) d@(GHC.L l (GHC.ValD (GHC.AbsBinds tvs vars exps ev binds))) = error "allocValD:AbsBinds"

-- ---------------------------------------------------------------------

allocSigD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocSigD (acc,toks) d@(GHC.L l (GHC.SigD        _)) = ([],[])

-- ---------------------------------------------------------------------

allocDefD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocDefD (acc,toks) d@(GHC.L l (GHC.DefD        _)) = ([],[])

-- ---------------------------------------------------------------------

allocForD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocForD (acc,toks) d@(GHC.L l (GHC.ForD        _)) = ([],[])

-- ---------------------------------------------------------------------

allocWarningD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocWarningD (acc,toks) d@(GHC.L l (GHC.WarningD    _)) = ([],[])

-- ---------------------------------------------------------------------

allocAnnD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocAnnD (acc,toks) d@(GHC.L l (GHC.AnnD        _)) = ([],[])

-- ---------------------------------------------------------------------

allocRuleD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocRuleD (acc,toks) d@(GHC.L l (GHC.RuleD       _)) = ([],[])

-- ---------------------------------------------------------------------

allocVectD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocVectD (acc,toks) d@(GHC.L l (GHC.VectD       _)) = ([],[])

-- ---------------------------------------------------------------------

allocSpliceD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocSpliceD (acc,toks) d@(GHC.L l (GHC.SpliceD     _)) = ([],[])

-- ---------------------------------------------------------------------

allocDocD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocDocD (acc,toks) d@(GHC.L l (GHC.DocD        _)) = ([],[])

-- ---------------------------------------------------------------------

allocQuasiQuoteD :: ([LayoutTree],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([LayoutTree],[PosToken])
allocQuasiQuoteD (acc,toks) d@(GHC.L l (GHC.QuasiQuoteD _)) = ([],[])

-- ---------------------------------------------------------------------

allocMatches :: [GHC.LMatch GHC.RdrName] -> [PosToken] -> [LayoutTree]
allocMatches matches toksIn = allocList matches toksIn doOne
  where
    doOne :: GHC.LMatch GHC.RdrName -> [PosToken] -> [LayoutTree]
    doOne (GHC.L _ (GHC.Match pats _mtyp (GHC.GRHSs rhs localBinds))) toks = r
      where
        (s1,patsToks,toks1) = splitToksForList pats toks
        (s2,rhsToks,bindsToks) = splitToksForList rhs toks1
        patLayout = allocList pats patsToks allocPat
        rhsLayout = allocList rhs rhsToks allocRhs
        localBindsLayout = allocLocalBinds localBinds bindsToks
        r = (strip $ (makeLeafFromToks s1) ++ patLayout ++ (makeLeafFromToks s2) ++ rhsLayout ++ localBindsLayout)

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
    (s1,patToks,toks') = splitToks (ghcSpanStartEnd lp) toks
    patLayout = allocPat pat patToks
    exprLayout = allocExpr expr toks'
    r = strip $ (makeLeafFromToks s1) ++ patLayout ++ exprLayout
allocStmt (GHC.L _ (GHC.ExprStmt expr _ _ _)) toks = allocExpr expr toks
allocStmt (GHC.L _ (GHC.LetStmt binds))       toks = allocLocalBinds binds toks
allocStmt (GHC.L _ (GHC.ParStmt stmts _ _))          toks = undefined
allocStmt (GHC.L _ (GHC.TransStmt _ _ _ _ _ _ _ _ )) toks = undefined
allocStmt (GHC.L _ (GHC.RecStmt _ _ _ _ _ _ _ _ _))  toks = undefined

-- ---------------------------------------------------------------------

allocExpr :: GHC.LHsExpr GHC.RdrName -> [PosToken] -> [LayoutTree]
allocExpr (GHC.L l (GHC.HsVar _)) toks = [Leaf l NoChange toks]
allocExpr (GHC.L l (GHC.HsLit _)) toks = [Leaf l NoChange toks]
allocExpr (GHC.L l (GHC.HsOverLit _)) toks = [Leaf l NoChange toks]
allocExpr (GHC.L _ (GHC.HsLam (GHC.MatchGroup matches _))) toks
  = allocMatches matches toks
allocExpr (GHC.L _ (GHC.HsLamCase _ (GHC.MatchGroup matches _))) toks
  = allocMatches matches toks
allocExpr (GHC.L _ (GHC.HsApp e1@(GHC.L l1 _) e2)) toks = r
  where
    (s1,e1Toks,e2Toks) = splitToks (ghcSpanStartEnd l1) toks
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    r = strip $ (makeLeafFromToks s1) ++ e1Layout ++ e2Layout
allocExpr (GHC.L _ (GHC.OpApp e1@(GHC.L l1 _) e2@(GHC.L l2 _) _ e3)) toks = r
  where
    (s1,e1Toks,toks1) = splitToks (ghcSpanStartEnd l1) toks
    (s2,e2Toks,e3Toks) = splitToks (ghcSpanStartEnd l2) toks1
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    e3Layout = allocExpr e3 e3Toks
    r = strip $ (makeLeafFromToks s1) ++ e1Layout ++ (makeLeafFromToks s2) ++ e2Layout ++ e3Layout
allocExpr (GHC.L _ (GHC.NegApp expr _)) toks = allocExpr expr toks
allocExpr (GHC.L _ (GHC.HsPar expr))    toks = allocExpr expr toks
allocExpr (GHC.L _ (GHC.SectionL e1@(GHC.L l1 _) e2)) toks = r
  where
    (s1,e1Toks,e2Toks) = splitToks (ghcSpanStartEnd l1) toks
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    r = strip $ (makeLeafFromToks s1) ++ e1Layout ++ e2Layout
allocExpr (GHC.L _ (GHC.SectionR e1@(GHC.L l1 _) e2)) toks = r
  where
    (s1,e1Toks,e2Toks) = splitToks (ghcSpanStartEnd l1) toks
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    r = strip $ (makeLeafFromToks s1) ++ e1Layout ++ e2Layout
allocExpr (GHC.L _ (GHC.ExplicitTuple tupArgs _)) toks = r
  where
    r = undefined
allocExpr (GHC.L _ (GHC.HsCase expr@(GHC.L le _) (GHC.MatchGroup matches _))) toks = r
  where
    (s1,exprToks,matchToks) = splitToks (ghcSpanStartEnd le) toks
    exprLayout = allocExpr expr exprToks
    matchesLayout = allocMatches matches matchToks
    r = strip $ (makeLeafFromToks s1) ++ exprLayout ++ matchesLayout
allocExpr (GHC.L _ (GHC.HsIf _ e1@(GHC.L l1 _) e2@(GHC.L l2 _) e3)) toks = r
  where
    (s1,e1Toks,toks1) = splitToks (ghcSpanStartEnd l1) toks
    (s2,e2Toks,e3Toks) = splitToks (ghcSpanStartEnd l2) toks1
    e1Layout = allocExpr e1 e1Toks
    e2Layout = allocExpr e2 e2Toks
    e3Layout = allocExpr e3 e3Toks
    r = strip $ (makeLeafFromToks s1) ++ e1Layout ++ (makeLeafFromToks s2) ++ e2Layout ++ e3Layout
allocExpr (GHC.L _ (GHC.HsMultiIf _ rhs)) toks = allocList rhs toks allocRhs
allocExpr (GHC.L _ (GHC.HsLet localBinds expr@(GHC.L le _))) toks = r
  where
    (bindToks,exprToks,toks') = splitToks (ghcSpanStartEnd le) toks
    bindLayout = allocLocalBinds localBinds bindToks
    exprLayout = allocExpr expr exprToks
    r = strip $ bindLayout ++ [makeGroup exprLayout] ++ (makeLeafFromToks toks')
allocExpr (GHC.L _ (GHC.HsDo _ stmts _)) toks = allocList stmts toks allocStmt
allocExpr (GHC.L _ (GHC.ExplicitList _ exprs)) toks = allocList exprs toks allocExpr
allocExpr (GHC.L _ (GHC.ExplicitPArr _ exprs)) toks = allocList exprs toks allocExpr
allocExpr (GHC.L _ (GHC.RecordCon (GHC.L ln _) _ (GHC.HsRecFields fields _))) toks = r
  where
    (s1,nameToks,fieldsToks) = splitToks (ghcSpanStartEnd ln) toks
    nameLayout = [Leaf ln NoChange nameToks]
    fieldsLayout = error "allocExpr allocRecField needs work"
    r = strip $ (makeLeafFromToks s1) ++ nameLayout ++ fieldsLayout

allocExpr e toks = error $ "allocExpr for " ++ (SYB.showData SYB.Parser 0  e) ++ " undefined"

-- ---------------------------------------------------------------------

allocLocalBinds :: GHC.HsLocalBinds GHC.RdrName -> [PosToken] -> [LayoutTree]
allocLocalBinds GHC.EmptyLocalBinds toks = strip $ makeLeafFromToks toks
allocLocalBinds (GHC.HsValBinds (GHC.ValBindsIn binds sigs)) toks = r
  where
    bindList = GHC.bagToList binds
    (s1,toksBinds,toks1) = splitToksForList bindList toks

    firstBindTok = ghead "allocLocalBinds" $ dropWhile isWhiteSpaceOrIgnored toksBinds

    (ro,co) = case (filter isWhereOrLet s1) of
               [] -> (0,0)
               (x:_) -> (tokenRow firstBindTok - tokenRow x,
                         tokenCol firstBindTok - tokenCol x)

    bindsLayout = allocList bindList toksBinds allocBind
    sigsLayout = allocList sigs toks1 doSigs
    doSigs = undefined
    r = strip $ (makeLeafFromToks s1) ++ [placeOffset ro co [placeAbove bindsLayout]] ++ sigsLayout

allocLocalBinds (GHC.HsIPBinds ib)  toks = error "allocLocalBinds undefined"

-- ---------------------------------------------------------------------

allocBind :: GHC.LHsBind GHC.RdrName -> [PosToken] -> [LayoutTree]
allocBind (GHC.L l (GHC.FunBind (GHC.L ln _) _ (GHC.MatchGroup matches _) _ _ _)) toks = r
  where
    (nameLayout,toks1) = ((makeLeafFromToks s1)++[Leaf ln NoChange nameToks],toks')
      where
        (s1,nameToks,toks') = splitToks (ghcSpanStartEnd ln) toks

    (matchesLayout,toks2) = ((makeLeafFromToks s2) ++ allocMatches matches matchToks,toks2')
          where
            (s2,matchToks,toks2') = splitToksForList matches toks1

    r = strip $ [Group l NoChange (strip $ nameLayout ++ matchesLayout)] ++ (makeLeafFromToks toks2)

-- ---------------------------------------------------------------------

allocRecField :: GHC.HsRecFields GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> [PosToken] -> [LayoutTree]
allocRecField = undefined

-- ---------------------------------------------------------------------

strip :: [LayoutTree] -> [LayoutTree]
strip ls = filter notEmpty ls
  where
    -- notEmpty (Leaf []) = False
    notEmpty (Leaf _ _ []) = False
    notEmpty _ = True

-- ---------------------------------------------------------------------

allocList :: [GHC.Located a] -> [PosToken]
   -> (GHC.Located a -> [PosToken] -> [LayoutTree])
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
            (s1,funcToks,toks') = splitToks (ghcSpanStartEnd l) toksOne
            layout' = (makeLeafFromToks s1) ++ [makeGroup (strip $ allocFunc x funcToks)]
            r1 = (acc ++ (strip layout'),toks')

    r = strip $ layout ++ (makeLeafFromToks toks2)

-- ---------------------------------------------------------------------

-- | Split the given tokens into the ones that occur prior to the start
-- of the list and ones that occur after
splitToksForList :: [GHC.Located a] -> [PosToken] -> ([PosToken],[PosToken],[PosToken])
splitToksForList [] toks = ([],[],toks)
splitToksForList xs toks = splitToks (getGhcLoc s, getGhcLocEnd e) toks
  where
    (GHC.L s _) = head xs
    (GHC.L e _) = last xs

-- ---------------------------------------------------------------------

placeAbove :: [LayoutTree] -> LayoutTree
placeAbove [] = error "placeAbove []"
placeAbove ls = Group loc Above ls
  where
    loc = GHC.combineSrcSpans (getLoc $ head ls) (getLoc $ last ls)

-- ---------------------------------------------------------------------

placeOffset :: RowOffset -> ColOffset -> [LayoutTree] -> LayoutTree
placeOffset _ _ [] = error "placeOffset []"
placeOffset r c ls = Group loc (Offset r c) ls
  where
    loc = GHC.combineSrcSpans (getLoc $ head ls) (getLoc $ last ls)

-- ---------------------------------------------------------------------

makeGroup :: [LayoutTree] -> LayoutTree
makeGroup ls = makeGroupLayout NoChange ls

makeGroupLayout :: Layout -> [LayoutTree] -> LayoutTree
makeGroupLayout lay ls = Group loc lay ls
  where
    loc = case ls of
           [] -> nullSrcSpan
           _  -> GHC.combineSrcSpans (getLoc $ head ls) (getLoc $ last ls)

-- ---------------------------------------------------------------------

makeLeafFromToks :: [PosToken] -> [LayoutTree]
makeLeafFromToks [] = []
makeLeafFromToks toks = [Leaf loc NoChange toks]
  where
    -- TODO: ignore leading/trailing comments etc
    loc = GHC.combineSrcSpans (tokenSrcSpan $ head toks) (tokenSrcSpan $ last toks)

-- ---------------------------------------------------------------------

getLoc :: LayoutTree -> GHC.SrcSpan
getLoc (Group l _ _) = l
getLoc (Leaf  l _ _) = l

-- ---------------------------------------------------------------------

retrieveTokens :: LayoutTree -> [PosToken]
retrieveTokens layout = go [] layout
  where
    go acc (Group _ _ xs)  = acc ++ (concat $ map (go []) xs)
    go acc (Leaf _ _ toks) = acc ++ toks

