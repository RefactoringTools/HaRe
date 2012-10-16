{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE RankNTypes #-}

module Language.Haskell.Refact.Utils
       ( expToPNT
       , locToExp
       , sameOccurrence
       , parseSourceStr
       , unsafeParseSourceStr
       , parseSourceFile
       , unsafeParseSourceFile
       , parseSourceFileGhc

       -- * The bits that do the work
       , runRefacSession
       , applyRefac
       , ApplyRefacResult(..)

       , update
       -- , writeRefactoredFiles
       -- , Refact -- ^ deprecated
       -- , fileNameToModName
       , getModuleName
       , isVarId
       , clientModsAndFiles
       , serverModsAndFiles
       , getCurrentModuleGraph
       , sortCurrentModuleGraph
       , modIsExported
       ) where

import Control.Monad.State
import Data.Char
import Data.List
import Data.Maybe
import Language.Haskell.Refact.Utils.GhcModuleGraph
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils
import System.IO.Unsafe


import qualified Bag           as GHC
import qualified BasicTypes    as GHC
import qualified Coercion      as GHC
import qualified Digraph       as GHC
import qualified DynFlags      as GHC
import qualified ErrUtils      as GHC
import qualified FastString    as GHC
import qualified ForeignCall   as GHC
import qualified GHC
import qualified GHC           as GHC
import qualified GHC.Paths     as GHC
import qualified HsSyn         as GHC
import qualified InstEnv       as GHC
import qualified Module        as GHC
import qualified MonadUtils    as GHC
import qualified NameSet       as GHC
import qualified OccName       as GHC
import qualified Outputable    as GHC
import qualified RdrName       as GHC
import qualified SrcLoc        as GHC
import qualified TcEvidence    as GHC
import qualified TcType        as GHC
import qualified TypeRep       as GHC
import qualified Var           as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

-- import Data.Generics

import Debug.Trace

-- ---------------------------------------------------------------------

{-
-- deriving instance Eq (GHC.Bag GHC.EvBind) => Eq (GHC.Bag GHC.EvBind)
-- deriving instance Eq (GHC.LHsBindsLR GHC.Id GHC.Id) => Eq (GHC.LHsBindsLR GHC.Id GHC.Id)
-- deriving instance Eq GHC.KindOrType => Eq GHC.KindOrType
-- deriving instance Eq GHC.PostTcType => Eq GHC.PostTcType
deriving instance Eq (GHC.ArithSeqInfo GHC.Id) => Eq (GHC.ArithSeqInfo GHC.Id)
deriving instance Eq (GHC.ArithSeqInfo GHC.RdrName) => Eq (GHC.ArithSeqInfo GHC.RdrName)
deriving instance Eq (GHC.ConDeclField GHC.Var) => Eq (GHC.ConDeclField GHC.Var)
deriving instance Eq (GHC.FixitySig GHC.Name) => Eq (GHC.FixitySig GHC.Name)
deriving instance Eq (GHC.FixitySig GHC.Var) => Eq (GHC.FixitySig GHC.Var)
deriving instance Eq (GHC.GRHSs GHC.Var) => Eq (GHC.GRHSs GHC.Var)
deriving instance Eq (GHC.HsBracket GHC.Id) => Eq (GHC.HsBracket GHC.Id)
deriving instance Eq (GHC.HsBracket GHC.Name) => Eq (GHC.HsBracket GHC.Name)
deriving instance Eq (GHC.HsBracket GHC.RdrName) => Eq (GHC.HsBracket GHC.RdrName)
deriving instance Eq (GHC.HsCmdTop GHC.RdrName) => Eq (GHC.HsCmdTop GHC.RdrName)
deriving instance Eq (GHC.HsCmdTop GHC.Var) => Eq (GHC.HsCmdTop GHC.Var)
deriving instance Eq (GHC.HsConPatDetails GHC.Var) => Eq (GHC.HsConPatDetails GHC.Var)
deriving instance Eq (GHC.HsExpr GHC.RdrName) => Eq (GHC.HsExpr GHC.RdrName)
deriving instance Eq (GHC.HsIPBinds GHC.Id) => Eq (GHC.HsIPBinds GHC.Id)
deriving instance Eq (GHC.HsLocalBinds GHC.Id) => Eq (GHC.HsLocalBinds GHC.Id)
deriving instance Eq (GHC.HsLocalBinds GHC.RdrName) => Eq (GHC.HsLocalBinds GHC.RdrName)
deriving instance Eq (GHC.HsQuasiQuote GHC.RdrName) => Eq (GHC.HsQuasiQuote GHC.RdrName)
deriving instance Eq (GHC.HsQuasiQuote GHC.Var) => Eq (GHC.HsQuasiQuote GHC.Var)
deriving instance Eq (GHC.HsRecFields GHC.Var (GHC.LPat GHC.Var)) => Eq (GHC.HsRecFields GHC.Var (GHC.LPat GHC.Var))
deriving instance Eq (GHC.HsRecordBinds GHC.Id) => Eq (GHC.HsRecordBinds GHC.Id)
deriving instance Eq (GHC.HsRecordBinds GHC.RdrName) => Eq (GHC.HsRecordBinds GHC.RdrName)
deriving instance Eq (GHC.HsSplice GHC.RdrName) => Eq (GHC.HsSplice GHC.RdrName)
deriving instance Eq (GHC.HsSplice GHC.Var) => Eq (GHC.HsSplice GHC.Var)
deriving instance Eq (GHC.HsStmtContext GHC.Name) => Eq (GHC.HsStmtContext GHC.Name)
deriving instance Eq (GHC.HsTupArg GHC.RdrName) => Eq (GHC.HsTupArg GHC.RdrName)
deriving instance Eq (GHC.HsTyVarBndr GHC.Var) => Eq (GHC.HsTyVarBndr GHC.Var)
deriving instance Eq (GHC.HsType GHC.Name) => Eq (GHC.HsType GHC.Name)
deriving instance Eq (GHC.HsType GHC.RdrName) => Eq (GHC.HsType GHC.RdrName)
deriving instance Eq (GHC.HsType GHC.Var) => Eq (GHC.HsType GHC.Var)
deriving instance Eq (GHC.HsValBindsLR GHC.Id GHC.Id) => Eq (GHC.HsValBindsLR GHC.Id GHC.Id)
deriving instance Eq (GHC.IPBind GHC.Var) => Eq (GHC.IPBind GHC.Var)
deriving instance Eq (GHC.Match GHC.Var) => Eq (GHC.Match GHC.Var)
deriving instance Eq (GHC.MatchGroup GHC.Id) => Eq (GHC.MatchGroup GHC.Id)
deriving instance Eq (GHC.MatchGroup GHC.RdrName) => Eq (GHC.MatchGroup GHC.RdrName)
deriving instance Eq (GHC.Pat GHC.RdrName) => Eq (GHC.Pat GHC.RdrName)
deriving instance Eq (GHC.Pat GHC.Var) => Eq (GHC.Pat GHC.Var)
deriving instance Eq (GHC.Sig GHC.Name) => Eq (GHC.Sig GHC.Name)
deriving instance Eq (GHC.Sig GHC.Var) => Eq (GHC.Sig GHC.Var)
deriving instance Eq (GHC.StmtLR GHC.RdrName GHC.RdrName) => Eq (GHC.StmtLR GHC.RdrName GHC.RdrName)
deriving instance Eq (GHC.StmtLR GHC.Var GHC.Var) => Eq (GHC.StmtLR GHC.Var GHC.Var)
deriving instance Eq GHC.EvBindsVar => Eq GHC.EvBindsVar
deriving instance Eq GHC.EvTerm => Eq GHC.EvTerm
deriving instance Eq GHC.HsArrAppType => Eq GHC.HsArrAppType
deriving instance Eq GHC.HsExplicitFlag => Eq GHC.HsExplicitFlag
deriving instance Eq GHC.HsTupleSort => Eq GHC.HsTupleSort
deriving instance Eq GHC.HsTyWrapper => Eq GHC.HsTyWrapper
deriving instance Eq GHC.HsWrapper => Eq GHC.HsWrapper
deriving instance Eq GHC.PostTcExpr => Eq GHC.PostTcExpr
deriving instance Eq GHC.TcCoercion => Eq GHC.TcCoercion
deriving instance Eq GHC.TcEvBinds => Eq GHC.TcEvBinds
deriving instance Eq GHC.TcType => Eq GHC.TcType
deriving instance Eq GHC.TransForm => Eq GHC.TransForm
deriving instance Eq (GHC.HsTupArg GHC.Var) => Eq (GHC.HsTupArg GHC.Var)
deriving instance Eq (GHC.HsConPatDetails GHC.RdrName) => Eq (GHC.HsConPatDetails GHC.RdrName)
deriving instance Eq (GHC.HsRecFields GHC.RdrName (GHC.LPat GHC.RdrName)) => Eq (GHC.HsRecFields GHC.RdrName (GHC.LPat GHC.RdrName))

deriving instance Eq(GHC.HsRecField GHC.RdrName (GHC.GenLocated GHC.SrcSpan (GHC.Pat GHC.RdrName))) => Eq (GHC.HsRecField GHC.RdrName (GHC.GenLocated GHC.SrcSpan (GHC.Pat GHC.RdrName)))

deriving instance Eq (GHC.Match GHC.RdrName) => Eq (GHC.Match GHC.RdrName)
deriving instance Eq (GHC.GRHSs GHC.RdrName) => Eq (GHC.GRHSs GHC.RdrName)
deriving instance Eq (GHC.GRHS GHC.RdrName) => Eq (GHC.GRHS GHC.RdrName)
deriving instance Eq (GHC.ConDeclField GHC.RdrName) => Eq (GHC.ConDeclField GHC.RdrName)
deriving instance Eq (GHC.HsTyVarBndr GHC.RdrName) => Eq (GHC.HsTyVarBndr GHC.RdrName)
deriving instance Eq (GHC.ConDeclField GHC.Name) => Eq (GHC.ConDeclField GHC.Name)
deriving instance Eq (GHC.HsSplice GHC.Name) => Eq (GHC.HsSplice GHC.Name)
deriving instance Eq (GHC.HsQuasiQuote GHC.Name) => Eq (GHC.HsQuasiQuote GHC.Name)
deriving instance Eq (GHC.HsExpr GHC.Name) => Eq (GHC.HsExpr GHC.Name)
deriving instance Eq (GHC.HsTyVarBndr GHC.Name) => Eq (GHC.HsTyVarBndr GHC.Name)

deriving instance Eq (GHC.HsCmdTop GHC.Name) => Eq (GHC.HsCmdTop GHC.Name)
deriving instance Eq (GHC.Pat GHC.Name) => Eq (GHC.Pat GHC.Name)
deriving instance Eq (GHC.ArithSeqInfo GHC.Name) => Eq (GHC.ArithSeqInfo GHC.Name)
deriving instance Eq (GHC.HsRecordBinds GHC.Name) => Eq (GHC.HsRecordBinds GHC.Name)
deriving instance Eq (GHC.StmtLR GHC.Name GHC.Name) => Eq (GHC.StmtLR GHC.Name GHC.Name)
deriving instance Eq (GHC.HsLocalBinds GHC.Name) => Eq (GHC.HsLocalBinds GHC.Name)
deriving instance Eq (GHC.HsTupArg GHC.Name) => Eq (GHC.HsTupArg GHC.Name)
deriving instance Eq (GHC.MatchGroup GHC.Name) => Eq (GHC.MatchGroup GHC.Name)

deriving instance Eq (GHC.Match GHC.Name) => Eq (GHC.Match GHC.Name)
deriving instance Eq (GHC.HsIPBinds GHC.Name) => Eq (GHC.HsIPBinds GHC.Name)
deriving instance Eq (GHC.HsValBindsLR GHC.Name GHC.Name) => Eq (GHC.HsValBindsLR GHC.Name GHC.Name)
deriving instance Eq (GHC.IPBind GHC.Name) => Eq (GHC.IPBind GHC.Name)
deriving instance Eq (GHC.GRHSs GHC.Name) => Eq (GHC.GRHSs GHC.Name)

deriving instance Eq (GHC.HsRecField GHC.Name (GHC.GenLocated GHC.SrcSpan (GHC.HsExpr GHC.Name))) => Eq (GHC.HsRecField GHC.Name (GHC.GenLocated GHC.SrcSpan (GHC.HsExpr GHC.Name)))

deriving instance Eq (GHC.GRHS GHC.Name) => Eq (GHC.GRHS GHC.Name)
deriving instance Eq (GHC.HsConPatDetails GHC.Name) => Eq (GHC.HsConPatDetails GHC.Name)
deriving instance Eq (GHC.HsRecFields GHC.Name (GHC.LPat GHC.Name)) => Eq (GHC.HsRecFields GHC.Name (GHC.LPat GHC.Name))
deriving instance Eq (GHC.HsRecField GHC.Name (GHC.GenLocated GHC.SrcSpan (GHC.Pat GHC.Name))) => Eq (GHC.HsRecField GHC.Name (GHC.GenLocated GHC.SrcSpan (GHC.Pat GHC.Name)))
deriving instance Eq (GHC.HsMatchContext GHC.Name) => Eq (GHC.HsMatchContext GHC.Name)
deriving instance Eq (GHC.HsRecField GHC.RdrName (GHC.GenLocated GHC.SrcSpan (GHC.HsExpr GHC.RdrName))) => Eq (GHC.HsRecField GHC.RdrName (GHC.GenLocated GHC.SrcSpan (GHC.HsExpr GHC.RdrName)))
deriving instance Eq (GHC.HsRecField GHC.Var (GHC.GenLocated GHC.SrcSpan (GHC.HsExpr GHC.Var))) => Eq (GHC.HsRecField GHC.Var (GHC.GenLocated GHC.SrcSpan (GHC.HsExpr GHC.Var)))
deriving instance Eq (GHC.HsRecField GHC.Var (GHC.GenLocated GHC.SrcSpan (GHC.Pat GHC.Var))) => Eq (GHC.HsRecField GHC.Var (GHC.GenLocated GHC.SrcSpan (GHC.Pat GHC.Var)))

deriving instance Eq (GHC.HsIPBinds GHC.RdrName) => Eq (GHC.HsIPBinds GHC.RdrName)
deriving instance Eq (GHC.HsValBindsLR GHC.RdrName GHC.RdrName) => Eq (GHC.HsValBindsLR GHC.RdrName GHC.RdrName)
deriving instance Eq (GHC.Sig GHC.RdrName) => Eq (GHC.Sig GHC.RdrName)
deriving instance Eq (GHC.IPBind GHC.RdrName) => Eq (GHC.IPBind GHC.RdrName)
deriving instance Eq (GHC.HsGroup GHC.RdrName) => Eq (GHC.HsGroup GHC.RdrName)
deriving instance Eq (GHC.HsDecl GHC.RdrName) => Eq (GHC.HsDecl GHC.RdrName)

deriving instance Eq GHC.DocDecl => Eq GHC.DocDecl
deriving instance Eq (GHC.SpliceDecl GHC.RdrName) => Eq (GHC.SpliceDecl GHC.RdrName)
deriving instance Eq (GHC.VectDecl GHC.RdrName) => Eq (GHC.VectDecl GHC.RdrName)
deriving instance Eq (GHC.RuleDecl GHC.RdrName) => Eq (GHC.RuleDecl GHC.RdrName)
deriving instance Eq (GHC.AnnDecl GHC.RdrName) => Eq (GHC.AnnDecl GHC.RdrName)
deriving instance Eq (GHC.WarnDecl GHC.RdrName) => Eq (GHC.WarnDecl GHC.RdrName)
deriving instance Eq (GHC.ForeignDecl GHC.RdrName) => Eq (GHC.ForeignDecl GHC.RdrName)
deriving instance Eq (GHC.DefaultDecl GHC.RdrName) => Eq (GHC.DefaultDecl GHC.RdrName)
deriving instance Eq (GHC.HsBind GHC.RdrName) => Eq (GHC.HsBind GHC.RdrName)
deriving instance Eq (GHC.DerivDecl GHC.RdrName) => Eq (GHC.DerivDecl GHC.RdrName)
deriving instance Eq (GHC.InstDecl GHC.RdrName) => Eq (GHC.InstDecl GHC.RdrName)
deriving instance Eq (GHC.TyClDecl GHC.RdrName) => Eq (GHC.TyClDecl GHC.RdrName)
-- deriving instance Eq (GHC.LHsBinds GHC.RdrName) => Eq (GHC.LHsBinds GHC.RdrName)
deriving instance Eq (GHC.ConDecl GHC.RdrName) => Eq (GHC.ConDecl GHC.RdrName)
deriving instance Eq GHC.FamilyFlavour => Eq GHC.FamilyFlavour
deriving instance Eq (GHC.ResType GHC.RdrName) => Eq (GHC.ResType GHC.RdrName)
deriving instance Eq (GHC.HsConDeclDetails GHC.RdrName) => Eq (GHC.HsConDeclDetails GHC.RdrName)

deriving instance Eq (GHC.ABExport GHC.RdrName) => Eq (GHC.ABExport GHC.RdrName)
deriving instance Eq GHC.ForeignExport => Eq GHC.ForeignExport
deriving instance Eq GHC.ForeignImport => Eq GHC.ForeignImport
deriving instance Eq GHC.CImportSpec => Eq GHC.CImportSpec
deriving instance Eq GHC.CExportSpec => Eq GHC.CExportSpec
deriving instance Eq GHC.TcSpecPrags => Eq GHC.TcSpecPrags
deriving instance Eq GHC.Coercion => Eq GHC.Coercion
deriving instance Eq (GHC.AnnProvenance GHC.RdrName) => Eq (GHC.AnnProvenance GHC.RdrName)
deriving instance Eq (GHC.RuleBndr GHC.RdrName) => Eq (GHC.RuleBndr GHC.RdrName)
-- deriving instance Eq GHC.Instance => Eq GHC.Instance
deriving instance Eq (GHC.FixitySig GHC.RdrName) => Eq (GHC.FixitySig GHC.RdrName)
deriving instance Eq GHC.TcSpecPrag => Eq GHC.TcSpecPrag
deriving instance Eq (GHC.HsGroup GHC.Name) => Eq (GHC.HsGroup GHC.Name)
deriving instance Eq (GHC.HsGroup GHC.Id) => Eq (GHC.HsGroup GHC.Id)
deriving instance Eq (GHC.HsDecl GHC.Var) => Eq (GHC.HsDecl GHC.Var)
deriving instance Eq (GHC.HsDecl GHC.Name) => Eq (GHC.HsDecl GHC.Name)

deriving instance Eq (GHC.SpliceDecl GHC.Name) => Eq (GHC.SpliceDecl GHC.Name)
deriving instance Eq (GHC.VectDecl GHC.Name) => Eq (GHC.VectDecl GHC.Name)
deriving instance Eq (GHC.RuleDecl GHC.Name) => Eq (GHC.RuleDecl GHC.Name)
deriving instance Eq (GHC.AnnDecl GHC.Name) => Eq (GHC.AnnDecl GHC.Name)
deriving instance Eq (GHC.WarnDecl GHC.Name) => Eq (GHC.WarnDecl GHC.Name)
deriving instance Eq (GHC.ForeignDecl GHC.Name) => Eq (GHC.ForeignDecl GHC.Name)
deriving instance Eq (GHC.DefaultDecl GHC.Name) => Eq (GHC.DefaultDecl GHC.Name)
deriving instance Eq (GHC.HsBind GHC.Name) => Eq (GHC.HsBind GHC.Name)
deriving instance Eq (GHC.DerivDecl GHC.Name) => Eq (GHC.DerivDecl GHC.Name)
deriving instance Eq (GHC.InstDecl GHC.Name) => Eq (GHC.InstDecl GHC.Name)
deriving instance Eq (GHC.TyClDecl GHC.Name) => Eq (GHC.TyClDecl GHC.Name)
deriving instance Eq (GHC.ConDecl GHC.Name) => Eq (GHC.ConDecl GHC.Name)
deriving instance Eq (GHC.ResType GHC.Name) => Eq (GHC.ResType GHC.Name)
deriving instance Eq (GHC.HsConDeclDetails GHC.Name) => Eq (GHC.HsConDeclDetails GHC.Name)
deriving instance Eq (GHC.ABExport GHC.Name) => Eq (GHC.ABExport GHC.Name)
deriving instance Eq (GHC.AnnProvenance GHC.Name) => Eq (GHC.AnnProvenance GHC.Name)
deriving instance Eq (GHC.RuleBndr GHC.Name) => Eq (GHC.RuleBndr GHC.Name)

deriving instance Eq (GHC.SpliceDecl GHC.Var) => Eq (GHC.SpliceDecl GHC.Var)
deriving instance Eq (GHC.VectDecl GHC.Var) => Eq (GHC.VectDecl GHC.Var)
deriving instance Eq (GHC.RuleDecl GHC.Var) => Eq (GHC.RuleDecl GHC.Var)
deriving instance Eq (GHC.AnnDecl GHC.Var) => Eq (GHC.AnnDecl GHC.Var)
deriving instance Eq (GHC.WarnDecl GHC.Var) => Eq (GHC.WarnDecl GHC.Var)
deriving instance Eq (GHC.ForeignDecl GHC.Var) => Eq (GHC.ForeignDecl GHC.Var)
deriving instance Eq (GHC.DefaultDecl GHC.Var) => Eq (GHC.DefaultDecl GHC.Var)
deriving instance Eq (GHC.HsBind GHC.Var) => Eq (GHC.HsBind GHC.Var)
deriving instance Eq (GHC.DerivDecl GHC.Var) => Eq (GHC.DerivDecl GHC.Var)
deriving instance Eq (GHC.InstDecl GHC.Var) => Eq (GHC.InstDecl GHC.Var)
deriving instance Eq (GHC.TyClDecl GHC.Var) => Eq (GHC.TyClDecl GHC.Var)
deriving instance Eq (GHC.ConDecl GHC.Var) => Eq (GHC.ConDecl GHC.Var)
deriving instance Eq (GHC.ABExport GHC.Var) => Eq (GHC.ABExport GHC.Var)
deriving instance Eq (GHC.AnnProvenance GHC.Var) => Eq (GHC.AnnProvenance GHC.Var)
deriving instance Eq (GHC.RuleBndr GHC.Var) => Eq (GHC.RuleBndr GHC.Var)
deriving instance Eq GHC.Instance => Eq GHC.Instance
deriving instance Eq (GHC.ResType GHC.Var) => Eq (GHC.ResType GHC.Var)
deriving instance Eq (GHC.HsConDeclDetails GHC.Var) => Eq (GHC.HsConDeclDetails GHC.Var)
deriving instance Eq (GHC.GRHS GHC.Var) => Eq (GHC.GRHS GHC.Var)
deriving instance Eq GHC.EvBind => Eq GHC.EvBind

instance (Eq a) => Eq (GHC.Bag a) where
  -- TODO: will this comparison work? Implicit order is assumed
  (==) b1 b2 = (GHC.bagToList b1) == (GHC.bagToList b2)

instance (Eq a, Eq b, Eq (GHC.HsBindLR a b)) => Eq (GHC.LHsBindsLR a b) where
  -- TODO: will this comparison work? Implicit order is assumed
  (==) b1 b2 = (GHC.bagToList b1) == (GHC.bagToList b2)
-}

-- ---------------------------------------------------------------------

-- Term defined in ../StrategyLib-4.0-beta/models/deriving/TermRep.hs

-- type PosToken = (Token, (Pos, String))
--       -- Defined at ../tools/base/parse2/Lexer/HsLayoutPre.hs:14:6
-- data Pos
--   = Pos {HsLexerPass1.char :: !Int, line :: !Int, column :: !Int}
--      -- Defined at ../tools/base/parse2/Lexer/HsLexerPos.hs:3:6
-- data Token
--      -- Defined at ../tools/base/parse2/Lexer/HsTokens.hs:5:6

-- GHC version
-- getRichTokenStream :: GhcMonad m => Module -> m [(Located Token, String)]

-- getStartEndLoc ::
--   forall t.
--   (Term t, StartEndLoc t, Printable t) =>
--   [PosToken] -> t -> (SimpPos, SimpPos)
--       -- Defined at RefacLocUtils.hs:1188:1

-- type HsExpP = HsExpI PNT     -- Defined at RefacTypeSyn.hs:17:6


-- data PNT = PNT PName (IdTy PId) OptSrcLoc
--       -- Defined at ../tools/base/defs/PNT.hs:23:6


{- ++AZ++ commentary


once_tdTU traverses the tree in a top-down manner, terminating when
the pattern match to worker succeeds.

failTU is a polymorphic strategy that always fails (by using mzero
from the MonadPlus class) regardless of the given term.

adhocTU allows the function worker to be applied to all nodes in a
layered data type: it updates a strategy to add type-specific behavior
so that the function on the left can be applied unless the function on
the right succeeds.
-}

-- | From file name to module name.
--fileNameToModName::( )=>String->PFE0MT n i ds ext m ModuleName

{- fileNameToModName::(PFE0_IO err m,IOErr err,HasInfixDecls i ds,QualNames i m1 n, Read n,Show n)=>
                   String->PFE0MT n i ds ext m ModuleName
fileNameToModName fileName =
  do gf <- getCurrentModuleGraph
     let fileAndMods = [(m,f)|(f,(m,ms))<-gf]
         f = filter (\(m,f) -> f==fileName) fileAndMods
     if f ==[] then error $ "Can't find module name"
                    else return $ (fst.head) f
-}
{- ++AZ++ may not need this, get it from modinfo
-- | From file name to module name.
fileNameToModName :: String -> PFE0MT n i ds ext m ModuleName
fileNameToModName fileName =
  do gf <- getCurrentModuleGraph
     let fileAndMods = [(m,f)|(f,(m,ms))<-gf]
         f = filter (\(m,f) -> f==fileName) fileAndMods
     if f ==[] then error $ "Can't find module name"
                    else return $ (fst.head) f
-}

-- | Extract the module name from the parsed source, if there is one
getModuleName :: GHC.ParsedSource -> Maybe (GHC.ModuleName,String)
getModuleName (GHC.L _ mod) =
  case (GHC.hsmodName mod) of
    Nothing -> Nothing
    Just (GHC.L _ modname) -> Just $ (modname,GHC.moduleNameString modname)



-- ---------------------------------------------------------------------

-- |Parse a Haskell source files, and returns a four-element tuple. The first element in the result is the inscope
-- relation, the second element is the export relation, the third is the AST of the module and the forth element is
-- the token stream of the module.
{-
parseSourceFile:: ( ) =>FilePath
                      ->m (InScopes,Exports,HsModuleP,[PosToken])
-}

parseSourceFile ::
  String
  -> IO (ParseResult, [PosToken])
parseSourceFile targetFile =
  GHC.defaultErrorHandler GHC.defaultLogAction $ do
    GHC.runGhc (Just GHC.libdir) $ do
      dflags <- GHC.getSessionDynFlags
      let dflags' = foldl GHC.xopt_set dflags
                    [GHC.Opt_Cpp, GHC.Opt_ImplicitPrelude, GHC.Opt_MagicHash]

          -- Enable GHCi style in-memory linking
          dflags'' = dflags' { GHC.hscTarget = GHC.HscInterpreted,
                               GHC.ghcLink   =  GHC.LinkInMemory }

      GHC.setSessionDynFlags dflags''
      target <- GHC.guessTarget targetFile Nothing
      GHC.setTargets [target]
      GHC.load GHC.LoadAllTargets -- Loads and compiles, much as calling ghc --make
      g <- GHC.getModuleGraph
      -- modSum <- GHC.getModSummary $ mkModuleName "B"
      let modSum = head g
      p <- GHC.parseModule modSum
      t <- GHC.typecheckModule p

      GHC.setContext [GHC.IIModule (GHC.ms_mod modSum)]
      inscopeNames    <- GHC.getNamesInScope
      -- inscopeRdrNames <- GHC.getRdrNamesInScope

      let pm = GHC.tm_parsed_module t

      let typechecked = GHC.tm_typechecked_source t
          renamed     = GHC.tm_renamed_source t
          parsed      = GHC.pm_parsed_source pm
      tokens <- GHC.getRichTokenStream (GHC.ms_mod modSum)
      -- return ((inscopes,exports,modAst),tokens)
      -- return ((typechecked,renamed,parsed),tokens)
      return ((inscopeNames,renamed,parsed),tokens)


-- ---------------------------------------------------------------------

-- | Parse a source file into a GHC session
parseSourceFileGhc ::
  String -> RefactGhc (ParseResult,[PosToken])
parseSourceFileGhc targetFile = do
      settings <- getRefacSettings
      dflags <- GHC.getSessionDynFlags
      let dflags' = foldl GHC.xopt_set dflags
                    [GHC.Opt_Cpp, GHC.Opt_ImplicitPrelude, GHC.Opt_MagicHash]
          dflags'' = dflags' { GHC.importPaths = rsetImportPath settings }

          -- Enable GHCi style in-memory linking
          dflags''' = dflags'' { GHC.hscTarget = GHC.HscInterpreted,
                                 GHC.ghcLink   =  GHC.LinkInMemory }

      GHC.setSessionDynFlags dflags'''
      -- target <- GHC.guessTarget targetFile Nothing
      target <- GHC.guessTarget ("*" ++ targetFile) Nothing -- Force interpretation, for inscopes
      GHC.setTargets [target]
      GHC.load GHC.LoadAllTargets -- Loads and compiles, much as calling ghc --make
      g <- GHC.getModuleGraph
      -- modSum <- GHC.getModSummary $ mkModuleName "B"
      let modSum = head g
      p <- GHC.parseModule modSum
      t <- GHC.typecheckModule p

      GHC.setContext [GHC.IIModule (GHC.ms_mod modSum)]
      inscopeNames    <- GHC.getNamesInScope
      -- inscopeRdrNames <- GHC.getRdrNamesInScope

      let pm = GHC.tm_parsed_module t

      let typechecked = GHC.tm_typechecked_source t
          renamed     = GHC.tm_renamed_source t
          parsed      = GHC.pm_parsed_source pm
      tokens <- GHC.getRichTokenStream (GHC.ms_mod modSum)
      -- return ((inscopes,exports,modAst),tokens)
      -- return ((typechecked,renamed,parsed),tokens)
      return ((inscopeNames,renamed,parsed),tokens)

-- ---------------------------------------------------------------------

-- TODO: harvest the common GHC setup in parseSourceFile and
-- parseSourceStr into a withGhc wrapper of some kind, or use the one
-- from buildwrapper

parseSourceStr ::
  String
  -> IO
       (Either
          GHC.ErrorMessages
          (GHC.WarningMessages, GHC.Located (GHC.HsModule GHC.RdrName)))
parseSourceStr s =
  GHC.defaultErrorHandler GHC.defaultLogAction $ do
    GHC.runGhc (Just GHC.libdir) $ do
      dflags <- GHC.getSessionDynFlags
      let dflags' = foldl GHC.xopt_set dflags
                    [GHC.Opt_Cpp, GHC.Opt_ImplicitPrelude, GHC.Opt_MagicHash]
      GHC.setSessionDynFlags dflags
      let result = GHC.parser s  dflags' "filename.hs"
          -- -> Either ErrorMessages (WarningMessages, Located (HsModule RdrName))	 
      return result

unsafeParseSourceFile :: String -> (ParseResult, [PosToken])
unsafeParseSourceFile fileName = unsafePerformIO $ parseSourceFile fileName

unsafeParseSourceStr ::
  String
  -> Either
       GHC.ErrorMessages
       (GHC.WarningMessages, GHC.Located (GHC.HsModule GHC.RdrName))
unsafeParseSourceStr s = unsafePerformIO $ parseSourceStr s


{-
original

parseSourceFile filename
   = do
        name <- fileNameToModName filename
        res <- ((checkScope  @@ parseModule') name)
        return res

  where
   checkScope (ts,(((wm,_),mod),refs))
     = check (checkRefs refs) >> return (inscpRel wm, exports wm, mod, expandNewLnTokens ts)

   check [] = done
   check errs = fail $ pp $ "Scoping errors" $$ vcat errs
-}
getExports (GHC.L _ hsmod) =
  case hsmod of
    GHC.HsModule _ (Just exports) _ _ _ _ -> exports
    _                                     -> []

-- ---------------------------------------------------------------------

-- | The result of a refactoring is the file, a flag as to whether it
-- was modified, the updated token stream, and the updated AST
type ApplyRefacResult = ((FilePath, Bool), ([PosToken], RefactResult))


-- | Manage a whole refactor session. Initialise the monad, parse the
-- source files, apply the refactorings, write out the files.
--
-- It is intended that this forms the umbrella function, in which
-- applyRefac is called
--
runRefacSession :: (Maybe RefactSettings)
         -> RefactGhc [ApplyRefacResult] -- TODO: should this be a list of refactorings?
         -> IO ()
runRefacSession settings comp = do
  let
   initialState = RefSt
        { rsSettings = fromMaybe (RefSet ["."]) settings
        , rsUniqState = 1
        , rsTokenStream = [] -- :: [PosToken]
        , rsStreamModified = False -- :: Bool
        }
  (refactoredMods,_s) <- runRefactGhc comp initialState
  writeRefactoredFiles False refactoredMods
  return ()

-- ---------------------------------------------------------------------

-- TODO: the module should be stored in the state, and returned if it
-- has been modified in a prior refactoring, instead of being parsed
-- afresh each time.

-- | Apply a refactoring (or part of a refactoring) to a single module
applyRefac
    :: (ParseResult -> RefactGhc RefactResult) -- ^ The refactoring
    -> Maybe (ParseResult, [PosToken])         -- ^ parse of module, if available
    -> FilePath                                -- ^ filename, if not
    -> RefactGhc ApplyRefacResult

applyRefac refac Nothing fileName
  = do (pr, toks) <- parseSourceFileGhc fileName  -- TODO: move this into the RefactGhc monad, so it shares a session
       res <- applyRefac refac (Just (pr,toks)) fileName
       return res

applyRefac refac (Just (parsedFile,toks)) fileName = do
    let settings = RefSet ["."]

    -- TODO: currently a temporary, poor man's surrounding state
    -- management: store state now, set it to fresh, run refac, then
    -- restore the state. Fix this to store the modules in some kind of cache.
    (RefSt settings u ts m) <- get
    put (RefSt settings u toks False)

    mod' <- refac parsedFile
    (RefSt _ u' toks' m) <- get

    -- Replace state with original, probably not needed
    -- put (RefSt settings u' ts m)

    return ((fileName,m),(toks', mod'))


-- ---------------------------------------------------------------------



{-
applyRefacToClientMods refac fileName
   = do clients <- clientModsAndFiles =<< fileNameToModName fileName
        mapM (applyRefac refac Nothing) (map snd clients)
-}

-- ---------------------------------------------------------------------

{- ++AZ++ TODO: replace this with a single function -}

{-
-- | Update the occurrence of one syntax phrase in a given scope by
-- another syntax phrase
updateR :: (SYB.Data t,SYB.Data t1, GHC.OutputableBndr t)
         => t     -- ^ The syntax phrase to be updated.
         -> t     -- ^ The new syntax phrase.
         -> t1    -- ^ The contex where the old syntax phrase occurs.
         -> RefactGhc t1  -- ^ The result.
updateR old new t
  = everywhereMStaged SYB.Renamer (SYB.mkM inExp) t
       where
        inExp :: GHC.Located t -> RefactGhc (GHC.Located t)
        -- inExp (e::(GHC.OutputableBndr n, SYB.Data n) => GHC.Located n)
        -- inExp (e@(GHC.L l _)::(GHC.OutputableBndr n, SYB.Data n) => GHC.Located n)
        inExp (e@(GHC.L l _))
          | sameOccurrence e old
               = do (new', _) <- updateToks old new prettyprint
                -- error "update: updated tokens" -- ++AZ++ debug
                    return new'
          | otherwise = return e
-}

class (SYB.Data t, SYB.Data t1) => Update t t1 where

  -- | Update the occurrence of one syntax phrase in a given scope by
  -- another syntax phrase of the same type
  update::  t     -- ^ The syntax phrase to be updated.
         -> t     -- ^ The new syntax phrase.
         -> t1    -- ^ The contex where the old syntax phrase occurs.
         -> RefactGhc t1  -- ^ The result.

instance (SYB.Data t, GHC.OutputableBndr n, SYB.Data n) => Update (GHC.Located (GHC.HsExpr n)) t where
    update oldExp newExp t
           = everywhereMStaged SYB.Parser (SYB.mkM inExp) t
       where
        inExp (e::GHC.Located (GHC.HsExpr n))
          | sameOccurrence e oldExp
               = do _ <- updateToks oldExp newExp prettyprint
                -- error "update: updated tokens" -- ++AZ++ debug
                    return newExp
          | otherwise = return e


-- ---------------------------------------------------------------------
-- TODO: ++AZ++ get rid of the following instances, merge them into a
-- single function above
{-
instance (SYB.Data t) => Update (GHC.Located HsExpP) t where
    update oldExp newExp t
           = everywhereMStaged SYB.Parser (SYB.mkM inExp) t
       where
        inExp (e::GHC.Located HsExpP)
          | sameOccurrence e oldExp
               = do (newExp', _) <- updateToks oldExp newExp prettyprint
                -- error "update: updated tokens" -- ++AZ++ debug
                    return newExp'
          | otherwise = return e
-}

instance (SYB.Data t) => Update (GHC.Located HsPatP) t where
    update oldPat newPat t
        = everywhereMStaged SYB.Parser (SYB.mkM inPat) t
     where
        inPat (p::GHC.Located HsPatP) -- = error "here"
            | sameOccurrence p oldPat
                = do (newPat', _) <- updateToksList [oldPat] [newPat] (prettyprintPatList prettyprint False)
                     return $ head newPat'
            | otherwise = return p

instance (SYB.Data t) => Update [GHC.Located HsPatP] t where
 update oldPat newPat  t
   = everywhereMStaged SYB.Parser (SYB.mkM inPat) t
   where
    inPat (p::[GHC.Located HsPatP])
     | and $ zipWith sameOccurrence p oldPat
        =  do  liftIO $ putStrLn (">" ++ SYB.showData SYB.Parser 0 p ++ "<")
               (newPat', _) <- (updateToksList oldPat newPat (prettyprintPatList prettyprint False))
               liftIO $ putStrLn (">" ++ SYB.showData SYB.Parser 0 newPat' ++ "<") 
               return newPat'
    inPat p = return p

prettyprint :: (GHC.Outputable a) => a -> String
prettyprint x = GHC.showSDoc $ GHC.ppr x

-- ---------------------------------------------------------------------

-- | Write refactored program source to files.
{-
writeRefactoredFiles::Bool   -- ^ True means the current refactoring is a sub-refactoring
         ->[((String,Bool),([PosToken],HsModuleP))]
            --  ^ String: the file name; Bool: True means the file has
            --  been modified.[PosToken]: the token stream; HsModuleP:
            --  the module AST.
         -> m ()
-}
-- writeRefactoredFiles (isSubRefactor::Bool) (files::[((String,Bool),([PosToken], HsModuleP))])
writeRefactoredFiles (isSubRefactor::Bool) (files::[((String,Bool),([PosToken], RefactResult))])
-- writeRefactoredFiles :: Bool -> [(RefactState, GHC.ParsedSource)]
    -- The AST is not used.
    -- isSubRefactor is used only for history (undo).
  = do let modifiedFiles = filter (\((f,m),_) -> m == modified) files

       putStrLn $ "writeRefactoredFiles:files=[" ++ (show $ map (\((f,_),(ts,_)) -> (f,GHC.showRichTokenStream ts)) files) ++ "]" -- ++AZ++ debug


       -- TODO: restore the history function
       -- ++AZ++ PFE0.addToHistory isSubRefactor (map (fst.fst) modifiedFiles)
       sequence_ (map modifyFile modifiedFiles)
       -- mapM_ writeTestDataForFile files   -- This should be removed for the release version.

     where
       modifyFile ((fileName,_),(ts,_)) = do
           -- let source = concatMap (snd.snd) ts
           let source = GHC.showRichTokenStream ts

           putStrLn $ "writeRefactoredFiles:" ++ fileName ++ ":[" ++ source ++ "]" -- ++AZ++ debug
           -- (Julien personnal remark) seq forces the evaluation of
           -- its first argument and returns its second argument. It
           -- is unclear for me why (length source) evaluation is
           -- forced.
           -- seq (length source) (AbstractIO.writeFile fileName source) -- ++AZ++ TODO: restore this when ready for production
           seq (length source) (writeFile (fileName ++ ".refactored") source)

           -- (Julien) I have changed Unlit.writeHaskellFile into
           -- AbstractIO.writeFile (which is ok as long as we do not
           -- have literate Haskell files)

           {- ++AZ++ TODO: restore this
           editorCmds <- PFE0.getEditorCmds
           MT.lift (sendEditorModified editorCmds fileName)
           -}

       writeTestDataForFile ((fileName,_),(ts,mod)) = do
           -- let source=concatMap (snd.snd) ts
           let source = GHC.showRichTokenStream ts
           seq (length source) $ writeFile (createNewFileName "_TokOut" fileName) source
           -- writeHaskellFile (createNewFileName "AST" fileName) ((render.ppi.rmPrelude) mod)
           -- ++AZ++ writeHaskellFile (createNewFileName "AST" fileName) (SYB.showData SYB.Parser mod)

       createNewFileName str fileName
          =let (name, posfix)=span (/='.') fileName
           in (name++str++posfix)


-- | If an expression consists of only one identifier then return this identifier in the PNT format,
--  otherwise return the default PNT.

-- TODO: bring in data constructor constants too.
expToPNT ::
  GHC.GenLocated GHC.SrcSpan (GHC.HsExpr PNT)
  -> Maybe PNT

-- Will have to look this up ....
expToPNT (GHC.L x (GHC.HsVar pnt))                     = Just pnt
-- expToPNT (GHC.L x (GHC.HsIPVar (GHC.IPName pnt)))      = pnt
-- expToPNT (GHC.HsOverLit (GHC.HsOverLit pnt)) = pnt
-- expToPNT (GHC.HsLit litVal) = GHC.showSDoc $ GHC.ppr litVal
-- expToPNT (GHC.HsPar (GHC.L _ e)) = expToPNT e
expToPNT _ = Nothing



-- ---------------------------------------------------------------------

-- | Return True if a string is a lexically  valid variable name.
isVarId::String->Bool
isVarId id =isId id && isSmall (ghead "isVarId" id)
     where isSmall c=isLower c || c=='_'

-- | Return True if a string is a lexically valid constructor name.
isConId::String->Bool
isConId id =isId id && isUpper (ghead "isConId" id)

-- | Return True if a string is a lexically valid operator name.
isOperator::String->Bool
isOperator id = id /= [] && isOpSym (ghead "isOperator" id) &&
                isLegalOpTail (tail id) && not (isReservedOp id)
   where
    isOpSym id = elem id opSymbols
       where opSymbols = ['!', '#', '$', '%', '&', '*', '+','.','/','<','=','>','?','@','\'','^','|','-','~']

    isLegalOpTail tail = all isLegal tail
       where isLegal c = isOpSym c || c==':'

    isReservedOp id = elem id reservedOps
       where reservedOps = ["..", ":","::","=","\"", "|","<-","@","~","=>"]

{-Returns True if a string lexically is an identifier. *This function should not be exported.*
-}
isId::String->Bool
isId id = id/=[] && isLegalIdTail (tail id) && not (isReservedId id)
  where
    isLegalIdTail tail=all isLegal tail
        where isLegal c=isSmall c|| isUpper c || isDigit c || c=='\''

    isReservedId id=elem id reservedIds
      where reservedIds=["case", "class", "data", "default", "deriving","do","else" ,"if",
                         "import", "in", "infix","infixl","infixr","instance","let","module",
                         "newtype", "of","then","type","where","_"]

    isSmall c=isLower c || c=='_'

-- ---------------------------------------------------------------------

-- | Return True if the current module is exported either by default
-- or by specifying the module name in the export.
modIsExported::HsModuleP   -- ^ The AST of the module
               -> Bool     -- ^ The result
modIsExported (GHC.L _ mod)
   = let exps    = GHC.hsmodExports mod -- Maybe [LIE name]
         modName = GHC.hsmodName mod -- Maybe (Located ModuleName)

         matchModName :: GHC.Located (GHC.IE GHC.RdrName) -> Bool
         matchModName (GHC.L _ n) =
           case modName of
             Nothing -> False
             Just (GHC.L _ mn) -> (GHC.moduleNameString mn) == GHC.showRdrName (GHC.ieName n)

     in if isNothing exps
           then True
           -- else isJust $ find (==(ModuleE modName)) (fromJust exps)
           else isJust $ find matchModName (fromJust exps)

-- ---------------------------------------------------------------------

-- | Return the client modules and file names. The client modules of
-- module, say m, are those modules which directly or indirectly
-- import module m.

-- TODO: deal with an anonymous main module, by taking Maybe GHC.ModuleName
clientModsAndFiles
  :: GHC.GhcMonad m => GHC.ModuleName -> m [GHC.ModSummary]
clientModsAndFiles m = do
  ms <- GHC.getModuleGraph
  modsum <- GHC.getModSummary m
  let mg = getModulesAsGraph False ms Nothing
      rg = GHC.transposeG mg
      modNode = fromJust $ find (\(msum,_,_) -> mycomp msum modsum) (GHC.verticesG rg)
      clientMods = filter (\msum -> not (mycomp msum modsum))
                 $ map summaryNodeSummary $ GHC.reachableG rg modNode

  return clientMods

-- TODO : find decent name and place for this.
mycomp ms1 ms2 = (GHC.ms_mod ms1) == (GHC.ms_mod ms2)


-- ---------------------------------------------------------------------

-- | Return the server module and file names. The server modules of
-- module, say m, are those modules which are directly or indirectly
-- imported by module m. This can only be called in a live GHC session

serverModsAndFiles
  :: GHC.GhcMonad m => GHC.ModuleName -> m [GHC.ModSummary]
serverModsAndFiles m = do
  ms <- GHC.getModuleGraph
  modsum <- GHC.getModSummary m
  let mg = getModulesAsGraph False ms Nothing
      modNode = fromJust $ find (\(msum,_,_) -> mycomp msum modsum) (GHC.verticesG mg)
      serverMods = filter (\msum -> not (mycomp msum modsum))
                 $ map summaryNodeSummary $ GHC.reachableG mg modNode

  return serverMods


   -- do gf <- getCurrentModuleGraph
   --    let fileAndMods = [(m,f)|(f,(m,ms))<-gf]
   --        g           = (map snd) gf
   --        serverMods  = reachable g [m] \\ [m]
   --        servers     = concatMap (\m'->[(m,f)|(m,f)<-fileAndMods, m==m']) serverMods
   --    return servers


-- ---------------------------------------------------------------------

instance (Show GHC.ModuleName) where
  show = GHC.moduleNameString

-- ---------------------------------------------------------------------

-- | Return True if the given module name exists in the project.
--isAnExistingMod::( ) =>ModuleName->PFE0MT n i ds ext m Bool

{-
isAnExistingMod::(PFE0_IO err m,IOErr err,HasInfixDecls i ds,QualNames i m1 n, Read n,Show n)=>
                  ModuleName->PFE0MT n i ds ext m Bool

isAnExistingMod m
  =  do ms<-allModules
        return (elem m ms)
-}

-- ---------------------------------------------------------------------

-- | Get the current module graph, provided we are in a live GHC session
getCurrentModuleGraph :: RefactGhc GHC.ModuleGraph
getCurrentModuleGraph = GHC.getModuleGraph

sortCurrentModuleGraph :: RefactGhc [GHC.SCC GHC.ModSummary]
sortCurrentModuleGraph = do
  -- g <- GHC.getModuleGraph
  g <- getCurrentModuleGraph
  let scc = GHC.topSortModuleGraph False g Nothing
  return scc

-- getSubGraph optms = concat # getSortedSubGraph optms
-- getSortedSubGraph optms = flip optSubGraph optms # sortCurrentModuleGraph
-- allModules = moduleList # sortCurrentModuleGraph
-- moduleList g = [m|scc<-g,(_,(m,_))<-scc]

