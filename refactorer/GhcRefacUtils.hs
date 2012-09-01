{-# LANGUAGE ScopedTypeVariables #-}
module GhcRefacUtils
       (
         locToExp
       , sameOccurrence
       , parseSourceFile
       , applyRefac
       , update  
       , writeRefactoredFiles  
       ) where

import GhcRefacTypeSyn
import GhcRefacLocUtils
import GhcUtils
import Data.Maybe
import SrcLoc1
import TermRep
import MUtils (( # ))
import Control.Monad.State
import Unlit
import qualified AbstractIO as AbstractIO
import qualified PFE0 as PFE0
import qualified MT(lift)
import EditorCommands

import qualified BasicTypes    as GHC
import qualified DynFlags      as GHC
import qualified FastString    as GHC
import qualified GHC           as GHC
import qualified GHC.Paths     as GHC
import qualified HsSyn         as GHC
import qualified Module        as GHC
import qualified MonadUtils    as GHC
import qualified Outputable    as GHC
import qualified RdrName       as GHC
import qualified SrcLoc        as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB


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
  case res of
    Just x -> x
    Nothing -> GHC.L GHC.noSrcSpan defaultExp
    -- _  -> error $ "locToExp:unexpected:" ++ (SYB.showData SYB.Parser 0 res)
  where
    res = somethingStaged SYB.Parser Nothing (Nothing `SYB.mkQ` exp) t

    exp :: GHC.Located (GHC.HsExpr GHC.RdrName) -> (Maybe (GHC.Located (GHC.HsExpr GHC.RdrName)))
    exp e
      |inScope e = Just e
    exp _ = Nothing
    
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

-- ---------------------------------------------------------------------

-- TODO: AZ: pretty sure this can be simplified, depends if we need to
--          manage transformed stuff too though.
    
-- | Return True if syntax phrases t1 and t2 refer to the same one.
sameOccurrence:: (Term t, Eq t) => t -> t -> Bool
sameOccurrence t1 t2
 = t1==t2 && srcLocs t1 == srcLocs t2
    
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
  -> IO ([a], [GHC.LIE GHC.RdrName], GHC.ParsedSource, [(GHC.Located GHC.Token, String)])
parseSourceFile targetFile =
  GHC.defaultErrorHandler GHC.defaultLogAction $ do
    GHC.runGhc (Just GHC.libdir) $ do
      dflags <- GHC.getSessionDynFlags
      let dflags' = foldl GHC.xopt_set dflags
                    [GHC.Opt_Cpp, GHC.Opt_ImplicitPrelude, GHC.Opt_MagicHash]
      GHC.setSessionDynFlags dflags'
      target <- GHC.guessTarget targetFile Nothing
      GHC.setTargets [target]
      GHC.load GHC.LoadAllTargets -- Loads and compiles, much as calling ghc --make
      g <- GHC.getModuleGraph
      -- modSum <- GHC.getModSummary $ mkModuleName "B"
      let modSum = head g
      p <- GHC.parseModule modSum
      let inscopes = [] -- TODO: populate this
          modAst = GHC.pm_parsed_source p
          exports = getExports modAst
      tokens <- GHC.getRichTokenStream (GHC.ms_mod modSum)
      return (inscopes,exports,modAst,tokens)
      
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

applyRefac refac Nothing fileName
  = do (inscps, exps, mod, toks)<-parseSourceFile fileName
       (mod',((toks',m),_))<-runStateT (refac (inscps, exps, mod)) ((toks,False), (-1000,0))
       return ((fileName,m),(toks',mod'))

applyRefac refac (Just (inscps, exps, mod, toks)) fileName
  = do (mod',((toks',m),_))<-runStateT (refac (inscps, exps, mod)) ((toks,False), (-1000,0))
       return ((fileName,m),(toks', mod'))

{-
applyRefacToClientMods refac fileName
   = do clients <- clientModsAndFiles =<< fileNameToModName fileName
        mapM (applyRefac refac Nothing) (map snd clients)
-}
    
-- ---------------------------------------------------------------------

{- ++AZ++ trying to replace this with a generic alternative
{- | The Update class, -}
class (Term t, Term t1)=>Update t t1 where

  -- | Update the occurrence of one syntax phrase in a given scope by another syntax phrase of the same type.
  update::(MonadPlus m, MonadState (([PosToken],Bool),(Int,Int)) m)=>  t     -- ^ The syntax phrase to be updated.
                                                             -> t     -- ^ The new syntax phrase.
                                                             -> t1    -- ^ The contex where the old syntax phrase occurs.
                                                             -> m t1  -- ^ The result.
-}

-- | Update the occurrence of one syntax phrase in a given scope by another syntax phrase of the same type.
{-       
update::(GHC.Outputable t,Term t,Term t1,Eq t,Eq t1,MonadPlus m, MonadState (([PosToken],Bool),(Int,Int)) m) =>
        t     -- ^ The syntax phrase to be updated.
        -> t     -- ^ The new syntax phrase.
        -> t1    -- ^ The contex where the old syntax phrase occurs.
        -> m t1  -- ^ The result.
-}
-- update oldExp newExp contextExp
update oldExp newExp  t
   -- = applyTP (once_tdTP (failTP `adhocTP` inExp)) t
   = somewhereStaged SYB.Parser (SYB.mkM inExp) t
   where
    inExp e
     | e == oldExp && srcLocs e == srcLocs oldExp
       = do (newExp', _) <- updateToks oldExp newExp prettyprint
            return newExp'
    inExp e = mzero

    prettyprint x = GHC.showSDoc $ GHC.ppr x



-- ---------------------------------------------------------------------
       
-- | Write refactored program source to files.
{-
writeRefactoredFiles::Bool   -- ^ True means the current refactoring is a sub-refactoring
         ->[((String,Bool),([PosToken],HsModuleP))]  --  ^ String: the file name; Bool: True means the file has been modified.[PosToken]: the token stream; HsModuleP: the module AST.
         -> m ()
-}

-- OLD: type PosToken = (Token, (Pos, String))
-- GHC: type PosToken = (GHC.Located GHC.Token, String)

writeRefactoredFiles (isSubRefactor::Bool) (files::[((String,Bool),([PosToken], HsModuleP))])
    -- The AST is not used.
    -- isSubRefactor is used only for history (undo).
  = do let modifiedFiles = filter (\((f,m),_) -> m == modified) files
       PFE0.addToHistory isSubRefactor (map (fst.fst) modifiedFiles)
       sequence_ (map modifyFile modifiedFiles)
       -- mapM_ writeTestDataForFile files   -- This should be removed for the release version.

     where
       modifyFile ((fileName,_),(ts,_)) = do
           -- let source = concatMap (snd.snd) ts
           let source = GHC.showRichTokenStream ts
               
           -- (Julien personnal remark) seq forces the evaluation of
           -- its first argument and returns its second argument. It
           -- is unclear for me why (length source) evaluation is
           -- forced.
           seq (length source) (AbstractIO.writeFile fileName source) 
           -- (Julien) I have changed Unlit.writeHaskellFile into
           -- AbstractIO.writeFile (which is ok as long as we do not
           -- have literate Haskell files)
           
           editorCmds <- PFE0.getEditorCmds
           MT.lift (sendEditorModified editorCmds fileName)
           
       writeTestDataForFile ((fileName,_),(ts,mod)) = do
           -- let source=concatMap (snd.snd) ts
           let source = GHC.showRichTokenStream ts               
           seq (length source) $ writeFile (createNewFileName "_TokOut" fileName) source
           -- writeHaskellFile (createNewFileName "AST" fileName) ((render.ppi.rmPrelude) mod)
           -- ++AZ++ writeHaskellFile (createNewFileName "AST" fileName) (SYB.showData SYB.Parser mod)

       
       
       createNewFileName str fileName
          =let (name, posfix)=span (/='.') fileName
           in (name++str++posfix)

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

