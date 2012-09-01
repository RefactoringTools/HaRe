{-# LANGUAGE ScopedTypeVariables #-}
module GhcRefacUtils (
  locToExp
  ) where

import GhcRefacTypeSyn
import GhcRefacLocUtils
import GhcUtils
import Data.Maybe
import SrcLoc1
import TermRep
import MUtils (( # ))

import qualified BasicTypes    as GHC
import qualified GHC           as GHC
import qualified GHC.SYB.Utils as GHC
import qualified HsSyn         as GHC
import qualified Module        as GHC
import qualified Outputable    as GHC
import qualified RdrName       as GHC
import qualified SrcLoc        as GHC
import qualified FastString    as GHC

import qualified Data.Generics as SYB


-- Term defined in ../StrategyLib-4.0-beta/models/deriving/TermRep.hs

-- type PosToken = (Token, (Pos, String))
--   	-- Defined at ../tools/base/parse2/Lexer/HsLayoutPre.hs:14:6
-- data Pos
--   = Pos {HsLexerPass1.char :: !Int, line :: !Int, column :: !Int}
--  	-- Defined at ../tools/base/parse2/Lexer/HsLexerPos.hs:3:6
-- data Token
--  	-- Defined at ../tools/base/parse2/Lexer/HsTokens.hs:5:6

-- GHC version
-- getRichTokenStream :: GhcMonad m => Module -> m [(Located Token, String)]

-- getStartEndLoc ::
--   forall t.
--   (Term t, StartEndLoc t, Printable t) =>
--   [PosToken] -> t -> (SimpPos, SimpPos)
--   	-- Defined at RefacLocUtils.hs:1188:1

-- type HsExpP = HsExpI PNT 	-- Defined at RefacTypeSyn.hs:17:6


-- data PNT = PNT PName (IdTy PId) OptSrcLoc
--   	-- Defined at ../tools/base/defs/PNT.hs:23:6


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


-- | Given the syntax phrase (and the token stream), find the largest-leftmost expression contained in the
--  region specified by the start and end position. If no expression can be found, then return the defaultExp.
locToExp:: (Term t) => SimpPos            -- ^ The start position.
                  -> SimpPos            -- ^ The end position.
                  -> [PosToken]         -- ^ The token stream which should at least contain the tokens for t.
                  -> t                  -- ^ The syntax phrase.
                  -- -> HsExpP             -- ^ The result.
                  -> GHC.Located (GHC.HsExpr GHC.RdrName) -- ^ The result.
locToExp beginPos endPos toks t =
  -- Easy with a zipper, just go down until in scope...
  case res of
    [x] -> x
    [] -> GHC.L GHC.noSrcSpan defaultExp
  where
    res = everythingButStaged GHC.Parser (++) [] (([],False) `SYB.mkQ` exp) t

    exp :: GHC.Located (GHC.HsExpr GHC.RdrName) -> ([GHC.Located (GHC.HsExpr GHC.RdrName)],Bool)
    exp e
      |inScope e = ([e], True)
    exp _ = ([], False)
    {-
    exp (GHC.L l _) = case getGhcLoc l of
      [(row,col)] 

      ([],True)
    -}
    
    inScope :: GHC.Located e -> Bool
    inScope (GHC.L l _) =
      let
        (startLoc,endLoc) = case l of
          (GHC.RealSrcSpan ss) ->
            ((GHC.srcSpanStartLine ss,GHC.srcSpanStartCol ss),
             (GHC.srcSpanEndLine ss,GHC.srcSpanEndCol ss))
          (GHC.UnhelpfulSpan _) -> ((0,0),(0,0))
      in
       (startLoc>=beginPos) && (startLoc<= endPos) && (endLoc>= beginPos) && (endLoc<=endPos)



{-
-- | Given the syntax phrase (and the token stream), find the largest-leftmost expression contained in the
--  region specified by the start and end position. If no expression can be found, then return the defaultExp.
locToExp::{- (Term t) => -}SimpPos            -- ^ The start position.
                  -> SimpPos            -- ^ The end position.
                  -> [PosToken]         -- ^ The token stream which should at least contain the tokens for t.
                  -> t                  -- ^ The syntax phrase.
                  -- -> HsExpP             -- ^ The result.
                  -> GHC.HsExpr GHC.RdrName -- ^ The result.
locToExp beginPos endPos toks t =
  -- = fromMaybe defaultExp $ applyTU (once_tdTU (failTU `adhocTU` exp)) t
  case res of
    [x] -> x
    [] -> defaultExp
  where
    res = everythingButStaged GHC.Parser (++) [] (([],False) `SYB.mkQ` exp) t
       
    -- exp1 :: GHC.HsExpr GHC.RdrName -> ([HsExpP], Bool)
    -- exp1 _ = ([], True)

    -- exp :: GHC.HsExpr GHC.RdrName -> ([HsExpP], Bool)
    exp :: GHC.HsExpr GHC.RdrName -> ([GHC.HsExpr GHC.RdrName], Bool)
    exp e
      |inScope e = ([Just e], True)
    exp _ = ([Nothing], False)

    inScope :: GHC.HsExpr GHC.RdrName -> Bool
    inScope e
          = let (startLoc, endLoc)
                 = if expToPNT e /= defaultPNT
                    then let (SrcLoc _ _ row col) = useLoc (expToPNT e)
                         in ((row,col), (row,col))
                    else getStartEndLoc toks e
            in (startLoc>=beginPos) && (startLoc<= endPos) && (endLoc>= beginPos) && (endLoc<=endPos)
-}

{-                  
locToExp beginPos endPos toks t
  = fromMaybe defaultExp $ applyTU (once_tdTU (failTU `adhocTU` exp)) t
     where
        exp (e::HsExpP)
         |inScope e = Just e
        exp _ =Nothing

        inScope e
          = let (startLoc, endLoc)
                 = if expToPNT e /= defaultPNT
                    then let (SrcLoc _ _ row col) = useLoc (expToPNT e)
                         in ((row,col), (row,col))
                    else getStartEndLoc toks e
            in (startLoc>=beginPos) && (startLoc<= endPos) && (endLoc>= beginPos) && (endLoc<=endPos)
-}

---------------------------------------------------------------------------------------
{- Original
-- | Given the syntax phrase (and the token stream), find the largest-leftmost expression contained in the
--  region specified by the start and end position. If no expression can be found, then return the defaultExp.
locToExp::(Term t) => SimpPos            -- ^ The start position.
                  -> SimpPos            -- ^ The end position.
                  -> [PosToken]         -- ^ The token stream which should at least contain the tokens for t.
                  -> t                  -- ^ The syntax phrase.
                  -> HsExpP             -- ^ The result.
locToExp beginPos endPos toks t
  = fromMaybe defaultExp $ applyTU (once_tdTU (failTU `adhocTU` exp)) t
     where
        {- exp (e@(Exp (HsDo stmts))::HsExpP)
         | filter inScope2 (map (getStartEndLoc toks) (getStmtList stmts))/=[]
         = do let atoms = filter (\atom->inScope (getStartEndLoc toks atom)) (getStmtList stmts)
                  atoms'= reverse (dropWhile (not.isQualifierOrLastAtom) (reverse atoms))
              if atoms'==[]
                  then fail "Expession not selected"
                  else do stmts' <-atoms2Stmt atoms'
                          Just (Exp (HsDo stmts')) -}
        exp (e::HsExpP)
         |inScope e = Just e
        exp _ =Nothing

        inScope e
          = let (startLoc, endLoc)
                 = if expToPNT e /= defaultPNT
                    then let (SrcLoc _ _ row col) = useLoc (expToPNT e)
                         in ((row,col), (row,col))
                    else getStartEndLoc toks e
            in (startLoc>=beginPos) && (startLoc<= endPos) && (endLoc>= beginPos) && endLoc<=endPos

        isQualifierOrLastAtom (HsQualifierAtom e) = True
        isQualifierOrLastAtom (HsLastAtom e)      = True
        isQualifierOrLastAtom _ = False

        atoms2Stmt [HsQualifierAtom e]          = return (HsLast e)
        atoms2Stmt [HsLastAtom e]               = return (HsLast e)
        atoms2Stmt (HsGeneratorAtom s p e : ss) = HsGenerator s p e # atoms2Stmt ss
        atoms2Stmt (HsLetStmtAtom ds : ss)      = HsLetStmt ds # atoms2Stmt ss
        atoms2Stmt (HsQualifierAtom e : ss)     = HsQualifier e # atoms2Stmt ss
        atoms2Stmt _ = fail "last statement in a 'do' expression must be an expression"
-}
---------------------------------------------------------------------------------------
-- | Default identifier in the PNT format.
defaultPNT:: GHC.RdrName
-- defaultPNT = PNT defaultPN Value (N Nothing) :: PNT
-- defaultPNT = GHC.mkRdrUnqual "nothing" :: PNT
-- defaultPNT = PNT (mkRdrName "nothing") (N Nothing) :: PNT
defaultPNT = (mkRdrName "nothing") 

-- | Default expression.
defaultExp::HsExpP
-- defaultExp=Exp (HsId (HsVar defaultPNT))
defaultExp=GHC.HsVar $ mkRdrName "nothing"

mkRdrName s = GHC.mkVarUnqual (GHC.mkFastString s)


-- | If an expression consists of only one identifier then return this identifier in the PNT format,
--  otherwise return the default PNT.

-- TODO: bring in data constructor constants too.
expToPNT:: GHC.HsExpr GHC.RdrName -> GHC.RdrName
expToPNT (GHC.HsVar pnt)                     = pnt
expToPNT (GHC.HsIPVar (GHC.IPName pnt))      = pnt
-- expToPNT (GHC.HsOverLit (GHC.HsOverLit pnt)) = pnt
-- expToPNT (GHC.HsLit litVal) = GHC.showSDoc $ GHC.ppr litVal
expToPNT (GHC.HsPar (GHC.L _ e)) = expToPNT e
expToPNT _ = defaultPNT

-- ---------------------------------------------------------------------
-- | Return the identifier's source location.
useLoc::PNT -> SrcLoc
useLoc (PNT pname (N (Just loc))) = loc
useLoc (PNT _ _ )                 = loc0


-- From SrcLoc1.hs
-- loc0 = GHC.noSrcLoc

