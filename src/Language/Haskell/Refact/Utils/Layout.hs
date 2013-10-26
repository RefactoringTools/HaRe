-- |
--

module Language.Haskell.Refact.Utils.Layout (
  ) where

import qualified GHC           as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import Data.Tree
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.LocUtils
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
            | Leaf [PosToken]
            deriving (Show)

-- ---------------------------------------------------------------------


allocateTokens :: GHC.RenamedSource -> [PosToken] -> Layout
allocateTokens = undefined

-- |Perform a top-down traversal of the AST fragment building up the Layout tree in the process.
-- NOTE: may need to use ParsedSource, it is in lexical order
allocateTokensToAST :: (SYB.Data t) => t -> [PosToken] -> [Layout]
allocateTokensToAST t toks = r
  where
    r = everythingStaged SYB.Renamer (++) []
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
