module Language.Haskell.Refact.Utils.Synonyms where
import GHC

{-
This file has synonyms for commonly used AST parser types.
-}

type UnlocParsedHsBind = HsBindLR RdrName RdrName
type ParsedGRHSs = GRHSs RdrName (LHsExpr RdrName)
type ParsedMatchGroup = MatchGroup RdrName (LHsExpr RdrName)
type ParsedLMatch = LMatch RdrName (LHsExpr RdrName)
type ParsedExpr = HsExpr RdrName
type ParsedLExpr = LHsExpr RdrName
type ParsedLStmt = LStmt RdrName (LHsExpr RdrName)
type ParsedBind = HsBind RdrName 
