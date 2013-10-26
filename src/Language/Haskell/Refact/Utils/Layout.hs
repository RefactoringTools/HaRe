-- |
--

module Language.Haskell.Refact.Utils.Layout (
  allocTokens
  ) where

import qualified GHC           as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import Data.List
import Language.Haskell.Refact.Utils.GhcUtils
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
{-

The layout will have to have a tree structure

-}
type RowOffset = Int
type ColOffset = Int
data Layout = Above [Layout]
            | Offset RowOffset ColOffset Layout
            | Leaf                    [PosToken]
            | LeafLocated GHC.SrcSpan [PosToken]
            deriving (Show)

-- ---------------------------------------------------------------------


allocateTokens :: GHC.ParsedSource -> [PosToken] -> Layout
allocateTokens = error "allocateTokens undefined"

-- |Perform a top-down traversal of the AST fragment building up the Layout tree in the process.
-- NOTE: may need to use ParsedSource, it is in lexical order
allocateTokensToAST :: (SYB.Data t) => t -> [PosToken] -> [Layout]
allocateTokensToAST t toks = r
  where
    r = everythingStaged SYB.Parser (++) []
      ([] `SYB.mkQ` allocateLet
--          `SYB.extQ` allocateWhere
--          `SYB.extQ` allocateOf
--          `SYB.extQ` allocateDo
      ) t

    allocateLet :: GHC.LHsExpr GHC.Name -> [Layout]
    allocateLet (GHC.L l (GHC.HsLet localBinds expr)) = []
    allocateLet _ = []

{-

Steps

alloc (HsLet localbinds expr) toks

e.g
  let a = 1
      b = 2
  in (a+b)

We have the 'let' and 'in' toks (and associated comments) living at
the level of the HsLet.

The localBinds and expr have their individul (recursive layouts)

So we would expect a result as

[Leaf "let"
, Offset 0 1 (Above (map alloc localbinds))
, Offset 1 0 (Leaf "in")
, Offset 0 1 (alloc expr exprtoks)
]

-}

-- TODO: bring in startEndLocIncComments'
allocTokens :: GHC.ParsedSource -> [PosToken] -> [Layout]
allocTokens (GHC.L _l (GHC.HsModule maybeName maybeExports imports decls _warns _haddocks)) toks = r
  where
    (nameLayout,toks1) =
      case maybeName of
        Nothing -> ([],toks)
        Just (GHC.L ln _modName) -> ([Leaf s1,LeafLocated ln modNameToks],toks')
          where
            (s1,modNameToks,toks') = splitToks (ghcSpanStartEnd ln) toks

    (exportLayout,toks2) =
      case maybeExports of
        Nothing -> ([],toks1)
        Just exps -> ([Leaf s2,Leaf expToks],toks2')
          where
            (s2,expToks,toks2') = splitToksForList exps toks1

    (importLayout,toks3) =
      case imports of
        [] -> ([],toks2)
        is -> ([Leaf s3,Leaf impToks],toks3')
          where
            (s3,impToks,toks3') = splitToksForList is toks2

    (declLayout,_toks4) =
      case decls of
        [] -> ([],toks3)
        -- is -> ([Leaf s4,Leaf impToks,Leaf toks4'],[])
        is -> ([Leaf s4] ++ allocDecls is declToks ++ [Leaf toks4'],[])
          where
            (s4,declToks,toks4') = splitToksForList is toks3


    r = strip $ nameLayout ++ exportLayout ++ importLayout ++ declLayout

-- ---------------------------------------------------------------------

allocDecls :: [GHC.LHsDecl GHC.RdrName] -> [PosToken] -> [Layout]
allocDecls decls toks = r
  where
    (declLayout,tailToks) = foldl' doOne ([],toks) decls

    r = strip $ declLayout ++ [Leaf tailToks]

    doOne :: ([Layout],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([Layout],[PosToken])
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

allocTyClD :: ([Layout],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([Layout],[PosToken])
allocTyClD (acc,toks) d@(GHC.L l (GHC.TyClD       _)) = ([],[])

-- ---------------------------------------------------------------------

allocInstD :: ([Layout],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([Layout],[PosToken])
allocInstD (acc,toks) d@(GHC.L l (GHC.InstD       _)) = ([],[])

-- ---------------------------------------------------------------------

allocDerivD :: ([Layout],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([Layout],[PosToken])
allocDerivD (acc,toks) d@(GHC.L l (GHC.DerivD      _)) = ([],[])

-- ---------------------------------------------------------------------

allocValD :: ([Layout],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([Layout],[PosToken])
allocValD (acc,toks) (GHC.L _l (GHC.ValD (GHC.FunBind (GHC.L ln _) _ (GHC.MatchGroup matches _) _ _ _))) = r
  where
    (nameLayout,toks1) = ([Leaf s1,LeafLocated ln nameToks],toks')
      where
        (s1,nameToks,toks') = splitToks (ghcSpanStartEnd ln) toks

    (matchesLayout,toks2) = ([Leaf s2] ++ allocMatches matches matchToks,toks2')
          where
            (s2,matchToks,toks2') = splitToksForList matches toks1

    r = (acc ++ (strip $ nameLayout ++ matchesLayout),toks2)

allocValD (acc,toks) d@(GHC.L l (GHC.ValD (GHC.PatBind lhs rhs _ _ _))) = r
  where
    r = ([],[])

allocValD (acc,toks) d@(GHC.L l (GHC.ValD (GHC.VarBind n rhs _))) = error "allocValD:VarBinds"
allocValD (acc,toks) d@(GHC.L l (GHC.ValD (GHC.AbsBinds tvs vars exps ev binds))) = error "allocValD:AbsBinds"

-- ---------------------------------------------------------------------

allocSigD :: ([Layout],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([Layout],[PosToken])
allocSigD (acc,toks) d@(GHC.L l (GHC.SigD        _)) = ([],[])

-- ---------------------------------------------------------------------

allocDefD :: ([Layout],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([Layout],[PosToken])
allocDefD (acc,toks) d@(GHC.L l (GHC.DefD        _)) = ([],[])

-- ---------------------------------------------------------------------

allocForD :: ([Layout],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([Layout],[PosToken])
allocForD (acc,toks) d@(GHC.L l (GHC.ForD        _)) = ([],[])

-- ---------------------------------------------------------------------

allocWarningD :: ([Layout],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([Layout],[PosToken])
allocWarningD (acc,toks) d@(GHC.L l (GHC.WarningD    _)) = ([],[])

-- ---------------------------------------------------------------------

allocAnnD :: ([Layout],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([Layout],[PosToken])
allocAnnD (acc,toks) d@(GHC.L l (GHC.AnnD        _)) = ([],[])

-- ---------------------------------------------------------------------

allocRuleD :: ([Layout],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([Layout],[PosToken])
allocRuleD (acc,toks) d@(GHC.L l (GHC.RuleD       _)) = ([],[])

-- ---------------------------------------------------------------------

allocVectD :: ([Layout],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([Layout],[PosToken])
allocVectD (acc,toks) d@(GHC.L l (GHC.VectD       _)) = ([],[])

-- ---------------------------------------------------------------------

allocSpliceD :: ([Layout],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([Layout],[PosToken])
allocSpliceD (acc,toks) d@(GHC.L l (GHC.SpliceD     _)) = ([],[])

-- ---------------------------------------------------------------------

allocDocD :: ([Layout],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([Layout],[PosToken])
allocDocD (acc,toks) d@(GHC.L l (GHC.DocD        _)) = ([],[])

-- ---------------------------------------------------------------------

allocQuasiQuoteD :: ([Layout],[PosToken]) -> GHC.LHsDecl GHC.RdrName -> ([Layout],[PosToken])
allocQuasiQuoteD (acc,toks) d@(GHC.L l (GHC.QuasiQuoteD _)) = ([],[])

-- ---------------------------------------------------------------------

allocMatches :: [GHC.LMatch GHC.RdrName] -> [PosToken] -> [Layout]
allocMatches matches toksIn = allocList matches toksIn doOne
  where
    doOne :: GHC.LMatch GHC.RdrName -> [PosToken] -> [Layout]
    doOne (GHC.L _ (GHC.Match pats _mtyp (GHC.GRHSs rhs localBinds))) toks = r
      where
        (s1,patsToks,toks1) = splitToksForList pats toks
        (s2,rhsToks,bindsToks) = splitToksForList rhs toks1
        patLayout = allocList pats patsToks allocPat
        rhsLayout = allocList rhs rhsToks allocRhs
        localBindsLayout = allocLocalBinds localBinds bindsToks
        r = (strip $ [Leaf s1] ++ patLayout ++ [Leaf s2] ++ rhsLayout ++ localBindsLayout)

-- ---------------------------------------------------------------------

allocPat :: GHC.LPat GHC.RdrName -> [PosToken] -> [Layout]
allocPat (GHC.L l _) toks = [Leaf toks]

-- ---------------------------------------------------------------------

allocRhs :: GHC.LGRHS GHC.RdrName -> [PosToken] -> [Layout]
allocRhs (GHC.L l (GHC.GRHS stmts expr)) toksIn = r
  where
    r = error "allocRhs undefined"

-- ---------------------------------------------------------------------

allocLocalBinds :: GHC.HsLocalBinds GHC.RdrName -> [PosToken] -> [Layout]
allocLocalBinds GHC.EmptyLocalBinds toks = strip $ [Leaf toks]
allocLocalBinds (GHC.HsValBinds (GHC.ValBindsIn binds sigs)) toks = error "allocLocalBinds undefined"

allocLocalBinds (GHC.HsIPBinds ib)  toks = error "allocLocalBinds undefined"

-- ---------------------------------------------------------------------

strip :: [Layout] -> [Layout]
strip ls = filter notEmpty ls
  where
    notEmpty (Leaf []) = False
    notEmpty (LeafLocated _ []) = False
    notEmpty _ = True

-- ---------------------------------------------------------------------

-- TODO: work this in everywhere
allocList :: [GHC.Located a] -> [PosToken] -> (GHC.Located a -> [PosToken] -> [Layout]) -> [Layout]
allocList xs toksIn allocFunc = r
  where
    (layout,toks2) = ([Leaf s2] ++ allocAll xs listToks,toks2')
          where
            (s2,listToks,toks2') = splitToksForList xs toksIn

    allocAll xs' toks = res
      where
        (declLayout,tailToks) = foldl' doOne ([],toks) xs'

        res = strip $ declLayout ++ [Leaf tailToks]

        -- doOne :: ([Layout],[PosToken]) -> GHC.Located a -> ([Layout],[PosToken])
        doOne (acc,toksOne) x@(GHC.L l _) = r1
          where
            (s1,funcToks,toks') = splitToks (ghcSpanStartEnd l) toksOne
            layout' = [Leaf s1] ++ allocFunc x funcToks
            r1 = (acc ++ (strip $ layout'),toks')

    r = strip $ layout ++ [Leaf toks2]

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
