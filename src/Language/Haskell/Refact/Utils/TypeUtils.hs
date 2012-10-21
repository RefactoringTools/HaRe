{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE NoMonomorphismRestriction #-}

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
{-
module RefacTypeUtils(module DriftStructUtils, module StrategyLib, module RefacTITypeSyn, module PosSyntax,
                  module SourceNames, module UniqueNames, module PNT,
                  module Ents, module Relations, module QualNames, module TypedIds 
-}
module Language.Haskell.Refact.Utils.TypeUtils
       (
 -- * Program Analysis
    -- ** Imports and exports
   inScopeInfo, isInScopeAndUnqualified, isInScopeAndUnqualifiedGhc -- , hsQualifier, {-This function should be removed-} rmPrelude 
   -- ,exportInfo, isExported, isExplicitlyExported, modIsExported

    -- ** Variable analysis
    ,hsPNs -- ,hsPNTs,hsDataConstrs,hsTypeConstrsAndClasses, hsTypeVbls
    {- ,hsClassMembers -} , HsDecls(hsDecls,isDeclaredIn{- ,replaceDecls -})
    ,getDecls, getDeclsP, replaceDecls
    ,hsFreeAndDeclaredPNs, hsFreeAndDeclaredNames
    ,hsVisiblePNs, hsVisibleNames
    ,hsFDsFromInside, hsFDNamesFromInside

    -- ** Property checking
    -- ,isVarId,isConId,isOperator,isTopLevelPN,isLocalPN,isTopLevelPNT
    -- ,isQualifiedPN,isFunPNT, isFunName, isPatName, isFunOrPatName,isTypeCon,isTypeSig
    ,isFunBindP,isFunBindR,isPatBindP,isPatBindR,isSimplePatBind
    {- ,isComplexPatBind -},isFunOrPatBindP,isFunOrPatBindR -- ,isClassDecl,isInstDecl,isDirectRecursiveDef
    -- ,usedWithoutQual,canBeQualified, hasFreeVars,isUsedInRhs
    -- ,findPNT,findPN      -- Try to remove this.
    {-,findPNs -}, findEntity, findEntity'
    ,sameOccurrence
    ,defines, definesP -- ,definesTypeSig, isTypeSigOf
    -- ,HasModName(hasModName), HasNameSpace(hasNameSpace)


    -- ** Modules and files
    -- ,clientModsAndFiles,serverModsAndFiles,isAnExistingMod
    -- ,fileNameToModName, strToModName, modNameToStr

    -- ** Locations
    {- ,defineLoc, useLoc-},locToPNT {-,locToPN -},locToExp -- , getStartEndLoc
    ,locToName
    ,getName

 -- * Program transformation
    -- ** Adding
    -- ,addDecl ,addItemsToImport, addHiding, rmItemsFromImport, addItemsToExport
    {- ,addParamsToDecls, addGuardsToRhs, addImportDecl-}, duplicateDecl -- , moveDecl
    -- ** Rmoving
    -- ,rmDecl, rmTypeSig, commentOutTypeSig, rmParams
    -- ,rmItemsFromExport, rmSubEntsFromExport, Delete(delete)
    -- ** Updating
    -- ,Update(update)
    {- ,qualifyPName,rmQualifier -} ,renamePN -- ,replaceNameInPN,autoRenameLocalVar

-- * Miscellous
    -- ** Parsing, writing and showing
   -- ,parseSourceFile,writeRefactoredFiles, showEntities ,showPNwithLoc, newProj, addFile, chase
    -- ** Locations
   -- ,toRelativeLocs, rmLocs
    -- ** Default values
   ,defaultPN,defaultPNT {-,defaultModName-},defaultExp-- ,defaultPat, defaultExpUnTyped


    -- ** Identifiers, expressions, patterns and declarations
    ,pNTtoPN -- ,pNTtoName,pNtoName,nameToPNT, nameToPN,pNtoPNT
    ,ghcToPN,lghcToPN
    -- ,expToPNT, expToPN, nameToExp,pNtoExp,patToPNT, patToPN, nameToPat,pNtoPat
    ,definingDecls -- , definedPNs
    ,definingDeclsNames

    -- ,simplifyDecl
    -- ** Others
   -- , applyRefac, applyRefacToClientMods
    , mkRdrName, mkNewName

    -- The following functions are not in the the API yet.
    -- ,getDeclToks, causeNameClashInExports, inRegion , ghead, glast, gfromJust, unmodified, prettyprint,
    -- getDeclAndToks

-- * Typed AST traversals (added by CMB)
    -- * Miscellous
    -- ,removeFromInts, getDataName, checkTypes, getPNs, getPN, getPNPats, mapASTOverTAST

-- * Debug stuff
  , allPNT
  , allPNTLens
  , allNames
  , newNameTok
 ) where

import Exception
-- import Control.Exception
import Control.Monad.State
import Data.Char
import Data.List
import Data.Maybe
import Language.Haskell.Refact.Utils.GhcModuleGraph
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn
import System.IO.Unsafe

-- Modules from GHC
import qualified Bag           as GHC
import qualified BasicTypes    as GHC
import qualified Coercion      as GHC
import qualified Digraph       as GHC
import qualified DynFlags      as GHC
import qualified ErrUtils      as GHC
import qualified FastString    as GHC
import qualified ForeignCall   as GHC
import qualified GHC           as GHC
import qualified GHC.Paths     as GHC
import qualified HsDecls       as GHC
import qualified HsPat         as GHC
import qualified HsSyn         as GHC
import qualified InstEnv       as GHC
import qualified Lexer         as GHC
import qualified Module        as GHC
import qualified MonadUtils    as GHC
import qualified Name          as GHC
import qualified NameSet       as GHC
import qualified OccName       as GHC
import qualified Outputable    as GHC
import qualified RdrName       as GHC
import qualified SrcLoc        as GHC
import qualified TcEvidence    as GHC
import qualified TcType        as GHC
import qualified TypeRep       as GHC
import qualified Unique        as GHC
import qualified Var           as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB
import qualified Unsafe.Coerce as SYB

-- Lens
import Control.Applicative
import Control.Lens hiding (Rep)
import Control.Lens.Plated
import Control.Lens.Traversal
import Control.Lens.Traversal
import Data.Data.Lens hiding (tinplate)
import GHC.Generics hiding (from, to)
import GHC.Generics.Lens

-- ---------------------------------------------------------------------
-- |Process the inscope relation returned from the parsing and module
-- analysis pass, and return a list of four-element tuples. Each tuple
-- contains an identifier name, the identifier's namespace info, the
-- identifier's defining module name and its qualifier name.
--
-- The same identifier may have multiple entries in the result because
-- it may have different qualifiers. This makes it easier to decide
-- whether the identifier can be used unqualifiedly by just checking
-- whether there is an entry for it with the qualifier field being
-- Nothing.
--
inScopeInfo :: InScopes                                          -- ^ The inscope relation .
           ->[(String, GHC.NameSpace, GHC.ModuleName, Maybe GHC.ModuleName)] -- ^ The result
inScopeInfo names = nub $  map getEntInfo $ names
  where
     getEntInfo name
       =(GHC.showPpr name,
         GHC.occNameSpace $ GHC.nameOccName name,
         GHC.moduleName $ GHC.nameModule name,
         getQualMaybe $ GHC.nameRdrName name)

     getQualMaybe rdrName = case rdrName of
       GHC.Qual modName _occName -> Just modName
       _                         -> Nothing

     -- getEntInfo (qual, ent@(Ent modName ident _))
     --   =(identToName ident, hasNameSpace ent,  modName, getQualifier qual)

{-
-- | Process the export relation returned from the parsing and module analysis pass, and
--   return a list of trhee-element tuples. Each tuple contains an identifier name, the
--   identifier's namespace info, and the identifier's define module.
exportInfo::Exports                             -- ^ The export relation.
          -> [(String, NameSpace, ModuleName)]  -- ^ The result
exportInfo exports = nub $ map getEntInfo  exports
  where
    getEntInfo (_, ent@(Ent modName ident _))
      =(identToName ident, hasNameSpace ent,  modName)
-}

-- | Return True if the identifier is inscope and can be used without
-- a qualifier.
isInScopeAndUnqualified::String       -- ^ The identifier name.
                       ->InScopes     -- ^ The inscope relation
                       ->Bool         -- ^ The result.
isInScopeAndUnqualified n names
 = isJust $ find (\ (x, _,_, qual) -> x == n && isNothing qual ) $ inScopeInfo names

-- isInScopeAndUnqualified id inScopeRel
--  = isJust $ find (\ (x, _,_, qual) -> x == id && isNothing qual ) $ inScopeInfo inScopeRel

-- | Return True if the identifier is inscope and can be used without
-- a qualifier. The identifier name string may have a qualifier already
isInScopeAndUnqualifiedGhc :: String         -- ^ The identifier name.
                           -> RefactGhc Bool -- ^ The result.
isInScopeAndUnqualifiedGhc n = do
  -- (ExceptionMonad m, Exception e)
  -- namesOr <- (gtry (GHC.parseName n)) :: (Exception e) => Either e [GHC.Name] -- TODO: throws an exception if name not found
  names <- ghandle handler (GHC.parseName n)
  nameInfo <- mapM GHC.lookupName names
  let nameList = filter isId $ catMaybes nameInfo
  return $ nameList /= []

  where
    isId (GHC.AnId _) = True
    isId _            = False

    -- handler:: (Exception e,GHC.GhcMonad m) => e -> m [GHC.Name]
    handler:: (GHC.GhcMonad m) => SomeException -> m [GHC.Name]
    handler _ = return []

-- ---------------------------------------------------------------------

-- | Default identifier in the PNT format.
-- defaultPNT:: GHC.GenLocated GHC.SrcSpan GHC.RdrName   -- GHC.RdrName
defaultPNT:: PNT
-- defaultPNT = PNT defaultPN Value (N Nothing) :: PNT
-- defaultPNT = GHC.mkRdrUnqual "nothing" :: PNT
-- defaultPNT = PNT (mkRdrName "nothing") (N Nothing) :: PNT
defaultPNT = PNT (GHC.L GHC.noSrcSpan (mkRdrName "nothing"))

defaultPN :: PName
defaultPN = PN (mkRdrName "nothing")

-- | Default expression.
defaultExp::HsExpP
-- defaultExp=Exp (HsId (HsVar defaultPNT))
defaultExp=GHC.HsVar $ mkRdrName "nothing"

mkRdrName s = GHC.mkVarUnqual (GHC.mkFastString s)

-- | Make a new GHC.Name, using the Unique Int sequence stored in the
-- RefactState
mkNewName :: String -> RefactGhc GHC.Name
mkNewName name = do
  s <- get
  u <- gets rsUniqState
  put s { rsUniqState = (u+1) }

  let un = GHC.mkUnique 'H' (u+1) -- H for HaRe :)
      n = GHC.mkSystemName un (GHC.mkVarOcc name)

  return n



------------------------------------------------------------------------
-- | Collect the free and declared variables (in the GHC.Name format)
-- in a given syntax phrase t. In the result, the first list contains
-- the free variables, and the second list contains the declared
-- variables.
-- Expects RenamedSource

hsFreeAndDeclaredPNs:: (SYB.Data t) => t -> ([GHC.Name],[GHC.Name])
hsFreeAndDeclaredPNs t = (nub f, nub d)
   where
          (f,d) = hsFreeAndDeclared'

          hsFreeAndDeclared' :: ([GHC.Name],[GHC.Name])

          hsFreeAndDeclared' = SYB.everythingStaged SYB.Renamer
                             (\(f1,d1) (f2,d2) -> (f1++f2,d1++d2))
                             ([],[])
                             (([],[]) `SYB.mkQ` expr
                             `SYB.extQ` pattern
                             `SYB.extQ` match
                             `SYB.extQ` stmts) t


          -- TODO: ++AZ++ Note:After renaming, HsBindLR has field bind_fvs
          --       containing locally bound free vars

          -- expr --
          expr (GHC.HsVar n) = ([n],[])

          expr (GHC.OpApp e1 (GHC.L _ (GHC.HsVar n)) _ e2)
              = addFree n (hsFreeAndDeclaredPNs [e1,e2])

          expr ((GHC.HsLam (GHC.MatchGroup matches _)) :: GHC.HsExpr GHC.Name) =
             hsFreeAndDeclaredPNs matches

          expr ((GHC.HsLet decls e) :: GHC.HsExpr GHC.Name) =
            let
              (df,dd) = hsFreeAndDeclaredPNs decls
              (ef,_)  = hsFreeAndDeclaredPNs e
            in
              ((df `union` (ef \\ dd)),[])

          expr (GHC.RecordCon (GHC.L _ n) _ e) =
            addFree  n (hsFreeAndDeclaredPNs e)   --Need Testing

          expr (GHC.EAsPat (GHC.L _ n) e) =
            addFree  n (hsFreeAndDeclaredPNs e)

          expr _ = ([],[])

          -- pat --
          pattern (GHC.VarPat n) = ([],[n])
          -- It seems all the GHC pattern match syntax elements end up
          -- with GHC.VarPat

          pattern _ = ([],[])

          -- match and patBind, same type--
          match ((GHC.FunBind (GHC.L _ n) _ (GHC.MatchGroup matches _) _ _ _) :: GHC.HsBind GHC.Name) =
           let
             (pf,_pd) = hsFreeAndDeclaredPNs matches
           in
             -- ((pf `union` ((rf `union` df) \\ (dd `union` pd `union` [fun]))),[fun])
             (pf,[n])

          -- patBind --
          match (GHC.PatBind pat rhs _ _ _) =
            let
              (pf,pd)  = hsFreeAndDeclaredPNs pat
              (rf,_rd) = hsFreeAndDeclaredPNs rhs
            in
              (pf `union` (rf \\pd),pd)

          match _ = ([],[])


          -- stmts --
          stmts ((GHC.BindStmt pat expr bind fail) :: GHC.Stmt GHC.Name) =
            let
              (pf,pd) = hsFreeAndDeclaredPNs pat
              (ef,ed) = hsFreeAndDeclaredPNs expr
              (sf,sd) = hsFreeAndDeclaredPNs [bind,fail]
            in
              (pf `union` ef `union` (sf\\pd),[]) -- pd) -- Check this

          stmts ((GHC.LetStmt binds) :: GHC.Stmt GHC.Name) =
            hsFreeAndDeclaredPNs binds

          stmts _ = ([],[])

{-
          recDecl ((HsRecDecl _ _ _ _ is) :: HsConDeclI PNT (HsTypeI PNT) [HsTypeI PNT])
                =do let d=map pNTtoPN $ concatMap fst is
                    return ([],d)
          recDecl _ =mzero
-}

          addFree :: GHC.Name -> ([GHC.Name],[GHC.Name]) -> ([GHC.Name],[GHC.Name]) 
          addFree free (f,d) = ([free] `union` f, d)

{-
hsFreeAndDeclaredPNs:: (Term t, MonadPlus m)=> t-> m ([PName],[PName])
hsFreeAndDeclaredPNs t=do (f,d)<-hsFreeAndDeclared' t
                          return (nub f, nub d)
   where
          hsFreeAndDeclared'=applyTU (stop_tdTU (failTU  `adhocTU` exp
                                                         `adhocTU` pat
                                                         `adhocTU` match
                                                         `adhocTU` patBind
                                                         `adhocTU` alt
                                                         `adhocTU` decls
                                                         `adhocTU` stmts
                                                         `adhocTU` recDecl))

          exp (TiDecorate.Exp (HsId (HsVar (PNT pn _ _))))=return ([pn],[])
          exp (TiDecorate.Exp (HsId (HsCon (PNT pn _ _))))=return ([pn],[])
          exp (TiDecorate.Exp (HsInfixApp e1 (HsVar (PNT pn _ _)) e2))
              =addFree pn (hsFreeAndDeclaredPNs [e1,e2])
          exp (TiDecorate.Exp (HsLambda pats body))
              = do (pf,pd) <-hsFreeAndDeclaredPNs pats
                   (bf,_) <-hsFreeAndDeclaredPNs body
                   return ((bf `union` pf) \\ pd, [])
          exp (TiDecorate.Exp (HsLet decls exp))
              = do (df,dd)<- hsFreeAndDeclaredPNs decls
                   (ef,_)<- hsFreeAndDeclaredPNs exp
                   return ((df `union` (ef \\ dd)),[])
          exp (TiDecorate.Exp (HsRecConstr _  (PNT pn _ _) e))
               =addFree  pn  (hsFreeAndDeclaredPNs e)   --Need Testing
          exp (TiDecorate.Exp (HsAsPat (PNT pn _ _) e))
              =addFree  pn  (hsFreeAndDeclaredPNs e)
          exp _ = mzero


          pat (TiDecorate.Pat (HsPId (HsVar (PNT pn _ _))))=return ([],[pn])
          pat (TiDecorate.Pat (HsPInfixApp p1 (PNT pn _ _) p2))=addFree pn (hsFreeAndDeclaredPNs [p1,p2])
          pat (TiDecorate.Pat (HsPApp (PNT pn _ _) pats))=addFree pn (hsFreeAndDeclaredPNs pats)
          pat (TiDecorate.Pat (HsPRec (PNT pn _ _) fields))=addFree pn (hsFreeAndDeclaredPNs fields)
          pat _ =mzero


          match ((HsMatch _ (PNT fun _ _)  pats rhs  decls)::HsMatchP)
            = do (pf,pd) <- hsFreeAndDeclaredPNs pats
                 (rf,rd) <- hsFreeAndDeclaredPNs rhs
                 (df,dd) <- hsFreeAndDeclaredPNs decls
                 return ((pf `union` ((rf `union` df) \\ (dd `union` pd `union` [fun]))),[fun])

         -------Added by Huiqing Li-------------------------------------------------------------------

          patBind ((TiDecorate.Dec (HsPatBind _ pat (HsBody rhs) decls))::HsDeclP)
             =do (pf,pd) <- hsFreeAndDeclaredPNs pat
                 (rf,rd) <- hsFreeAndDeclaredPNs rhs
                 (df,dd) <- hsFreeAndDeclaredPNs decls
                 return (pf `union` ((rf `union` df) \\(dd `union` pd)),pd)
          patBind _=mzero
         ------------------------------------------------------------------------------------------- 

          alt ((HsAlt _ pat exp decls)::(HsAlt (HsExpP) (HsPatP) HsDeclsP))
             = do (pf,pd) <- hsFreeAndDeclaredPNs pat
                  (ef,ed) <- hsFreeAndDeclaredPNs exp
                  (df,dd) <- hsFreeAndDeclaredPNs decls
                  return (pf `union` (((ef \\ dd) `union` df) \\ pd),[])


          decls (ds :: [HsDeclP])
             =do (f,d) <-hsFreeAndDeclaredList ds
                 return (f\\d,d)

          stmts ((HsGenerator _ pat exp stmts) :: HsStmt (HsExpP) (HsPatP) HsDeclsP) -- Claus
             =do (pf,pd) <-hsFreeAndDeclaredPNs pat
                 (ef,ed) <-hsFreeAndDeclaredPNs exp
                 (sf,sd) <-hsFreeAndDeclaredPNs stmts
                 return (pf `union` ef `union` (sf\\pd),[]) -- pd) -- Check this 

          stmts ((HsLetStmt decls stmts) :: HsStmt (HsExpP) (HsPatP) HsDeclsP)
             =do (df,dd) <-hsFreeAndDeclaredPNs decls
                 (sf,sd) <-hsFreeAndDeclaredPNs stmts
                 return (df `union` (sf \\dd),[])
          stmts _ =mzero

          recDecl ((HsRecDecl _ _ _ _ is) :: HsConDeclI PNT (HsTypeI PNT) [HsTypeI PNT])
                =do let d=map pNTtoPN $ concatMap fst is
                    return ([],d)
          recDecl _ =mzero


          addFree free mfd=do (f,d)<-mfd
                              return ([free] `union` f, d)

          hsFreeAndDeclaredList l=do fds<-mapM hsFreeAndDeclaredPNs l
                                     return (foldr union [] (map fst fds),
                                             foldr union [] (map snd fds))
-}



-- |The same as `hsFreeAndDeclaredPNs` except that the returned
-- variables are in the String format.
hsFreeAndDeclaredNames::(SYB.Data t) => t -> ([String],[String])
hsFreeAndDeclaredNames t = ((nub.map GHC.showPpr) f1, (nub.map GHC.showPpr) d1)
  where
    (f1,d1) = hsFreeAndDeclaredPNs t

-- hsFreeAndDeclaredNames::(Term t, MonadPlus m)=> t->m([String],[String])
-- hsFreeAndDeclaredNames t =do (f1,d1)<-hsFreeAndDeclaredPNs t
--                              return ((nub.map pNtoName) f1, (nub.map pNtoName) d1)


--------------------------------------------------------------------------------
-- | Same as `hsVisiblePNs' except that the returned identifiers are
-- in String format.
hsVisibleNames:: (SYB.Data t1, SYB.Data t2) => t1 -> t2 -> [String]
hsVisibleNames e t = ((nub.map GHC.showPpr) d)
  where
    d = hsVisiblePNs e t

-- hsVisibleNames:: (Term t1, Term t2, FindEntity t1, MonadPlus m) => t1 -> t2 -> m [String]
-- hsVisibleNames e t =do d<-hsVisiblePNs e t
--                        return ((nub.map pNtoName) d)


-- | Given syntax phrases e and t, if e occurs in t, then return those
-- variables which are declared in t and accessible to e, otherwise
-- return [].
hsVisiblePNs :: (SYB.Data t1, SYB.Data t2) =>
   t1 -> t2 -> [GHC.Name]
hsVisiblePNs e t = SYB.everythingStaged SYB.Renamer (++) []
                  ([] `SYB.mkQ`  top
                      `SYB.extQ` expr
                      `SYB.extQ` decl
                      `SYB.extQ` match
                      `SYB.extQ` stmts) t

      where
          top ((groups,_,_,_) :: GHC.RenamedSource)
            | findEntity e groups = dd
           where
             (_df,dd) = hsFreeAndDeclaredPNs groups
          top _ = []

          expr ((GHC.HsLam (GHC.MatchGroup matches _)) :: GHC.HsExpr GHC.Name)
            | findEntity e matches = dd
           where
             (_df,dd) = hsFreeAndDeclaredPNs matches

          expr ((GHC.HsLet decls e1) :: GHC.HsExpr GHC.Name)
             |findEntity e e1 || findEntity e decls = dd
           where
             (_df,dd) = hsFreeAndDeclaredPNs decls

          -- This is the equivalent of HsAlt
          expr ((GHC.HsCase _ (GHC.MatchGroup matches _)) :: GHC.HsExpr GHC.Name)
            | findEntity e matches = dd
           where
             (_df,dd) = hsFreeAndDeclaredPNs matches

          expr _ = []

          decl ((GHC.FunBind _ _ (GHC.MatchGroup matches _) _ _ _) :: GHC.HsBind GHC.Name) 
            | findEntity e matches = dd
           where
             (_df,dd) = hsFreeAndDeclaredPNs matches

          decl ((GHC.PatBind pat rhs _ _ _) :: GHC.HsBind GHC.Name)
            |findEntity e rhs = (pd `union` dd)
           where
             (_pf,pd) = hsFreeAndDeclaredPNs pat
             (_df,dd) = hsFreeAndDeclaredPNs rhs

          decl _ = []

          -- Pick up from HsAlt etc
          match ((GHC.Match pats _ rhs) :: GHC.Match GHC.Name)
            |findEntity e rhs = (pd `union` dd)
           where
             (_pf,pd) = hsFreeAndDeclaredPNs pats
             (_df,dd) = hsFreeAndDeclaredPNs rhs
          match _ = []

          stmts ((GHC.LetStmt binds) :: GHC.Stmt GHC.Name)
            | findEntity e binds = dd
           where
             (_df,dd) = hsFreeAndDeclaredPNs binds

          stmts ((GHC.BindStmt pat rhs _ _) :: GHC.Stmt GHC.Name)
            | findEntity e rhs = dd
           where
             (_df,dd) = hsFreeAndDeclaredPNs pat

          stmts _ = []

{- ++ original ++
-- | Given syntax phrases e and t, if e occurs in  t, then return those vairables
--  which are declared in t and accessible to e, otherwise return [].
hsVisiblePNs :: (Term t1, Term t2, FindEntity t1, MonadPlus m) => t1 -> t2 -> m [PName]
hsVisiblePNs e t =applyTU (full_tdTU (constTU [] `adhocTU` mod
                                                  `adhocTU` exp
                                                  `adhocTU` match
                                                  `adhocTU` patBind
                                                  `adhocTU` alt
                                                  `adhocTU` stmts)) t
      where
          mod ((HsModule loc modName exps imps decls)::HsModuleP)
            |findEntity e decls
           =do (df,dd)<-hsFreeAndDeclaredPNs decls
               return dd
          mod _=return []

          exp ((Exp (HsLambda pats body))::HsExpP)
            |findEntity e body
             = do (pf,pd) <-hsFreeAndDeclaredPNs pats
                  return pd

          exp (Exp (HsLet decls e1))
             |findEntity e e1 || findEntity e decls
             = do (df,dd)<- hsFreeAndDeclaredPNs decls
                  return dd
          exp _ =return []

          match (m@(HsMatch _ (PNT fun _ _)  pats rhs  decls)::HsMatchP)
            |findEntity e rhs || findEntity e decls
            = do (pf,pd) <- hsFreeAndDeclaredPNs pats
                 (df,dd) <- hsFreeAndDeclaredPNs decls
                 return  (pd `union` dd `union` [fun])
          match _=return []

          patBind (p@(Dec (HsPatBind _ pat rhs decls))::HsDeclP)
            |findEntity e rhs || findEntity e decls
             =do (pf,pd) <- hsFreeAndDeclaredPNs pat
                 (df,dd) <- hsFreeAndDeclaredPNs decls
                 return (pd `union` dd)
          patBind _=return []

          alt ((HsAlt _ pat exp decls)::HsAltP)
             |findEntity e exp || findEntity e decls
             = do (pf,pd) <- hsFreeAndDeclaredPNs pat
                  (df,dd) <- hsFreeAndDeclaredPNs decls
                  return (pd `union` dd)
          alt _=return []

          stmts ((HsGenerator _ pat exp stmts) :: HsStmtP)
            |findEntity e stmts
             =do (pf,pd) <-hsFreeAndDeclaredPNs pat
                 return pd

          stmts (HsLetStmt decls stmts)
            |findEntity e decls || findEntity e stmts
             =do (df,dd) <-hsFreeAndDeclaredPNs decls
                 return dd
          stmts _ =return []

-}

------------------------------------------------------------------------

-- | Returns True is a syntax phrase, say a, is part of another syntax
-- phrase, say b.
-- Expects to be at least Parser output
findEntity:: (SYB.Data a, SYB.Data b)=> a -> b -> Bool
findEntity a b = fromMaybe False res
  where
    -- ++AZ++ do a generic traversal, and see if it matches.
    res = somethingStaged SYB.Parser Nothing worker b

    worker :: (SYB.Typeable b, SYB.Data b) => b -> Maybe Bool
    worker b = if SYB.typeOf a == SYB.typeOf b
                 -- then Just (getStartEndLoc b == getStartEndLoc a)
                 then Just True -- ++AZ++ test for now
                 else Nothing

findEntity':: (SYB.Data a, SYB.Data b)
              => a -> b -> Maybe (SimpPos,SimpPos)
findEntity' a b = res
  where
    -- ++AZ++ do a generic traversal, and see if it matches.
    res = somethingStaged SYB.Parser Nothing worker b

    worker :: (SYB.Typeable c,SYB.Data c) 
           => c -> Maybe (SimpPos,SimpPos)
    worker b = if SYB.typeOf a == SYB.typeOf b
                 -- then Just (getStartEndLoc b == getStartEndLoc a)
                 then Just (getStartEndLoc b)
                 else Nothing

{-
    worker :: ( SYB.Typeable a{-, SYB.Typeable b-})
      => Maybe Bool
      -- -> (b -> r)
      -> a
      -> Maybe Bool
    worker a = case SYB.cast a of
               Just b -> Just True
               Nothing -> r
-}



------------------------------------------------------------------------

-- |`hsFDsFromInside` is different from `hsFreeAndDeclaredPNs` in
-- that: given an syntax phrase t, `hsFDsFromInside` returns not only
-- the declared variables that are visible from outside of t, but also
-- those declared variables that are visible to the main expression
-- inside t.
-- NOTE: Expects to be given RenamedSource

hsFDsFromInside:: (SYB.Data t) => t-> ([GHC.Name],[GHC.Name])
hsFDsFromInside t = (nub f, nub d)
   where
     (f,d) = hsFDsFromInside'
     {-
     hsFDsFromInside' = applyTU (once_tdTU (failTU  `adhocTU` mod
                                                    -- `adhocTU` decls
                                                     `adhocTU` decl
                                                     `adhocTU` match
                                                     `adhocTU` exp
                                                     `adhocTU` alt
                                                     `adhocTU` stmts ))
     -}
     hsFDsFromInside' :: ([GHC.Name],[GHC.Name])
     hsFDsFromInside' = SYB.everythingStaged SYB.Renamer
                  (\(f1,d1) (f2,d2) -> (f1++f2,d1++d2))
                  ([],[])
                  (([],[]) `SYB.mkQ` renamed
                           `SYB.extQ` match
                           `SYB.extQ` decl
                           `SYB.extQ` expr
                           `SYB.extQ` stmts) t

     renamed ((group,_,_,_)::GHC.RenamedSource)
        = hsFreeAndDeclaredPNs $ GHC.hs_valds group

 {-    decls (ds::[HsDeclP])                    --CHECK THIS.
       = hsFreeAndDeclaredPNs decls
-}
     -- Match [LPat id] (Maybe (LHsType id)) (GRHSs id)
     match ((GHC.Match pats _type rhs):: GHC.Match GHC.Name ) =
       let
         (pf, pd) = hsFreeAndDeclaredPNs pats
         (rf, rd) = hsFreeAndDeclaredPNs rhs
       in
         (nub (pf `union` (rf \\ pd)),
          nub (pd `union` rd))


     decl ((GHC.FunBind (GHC.L _ n) _ (GHC.MatchGroup matches _) _ _ _) :: GHC.HsBind GHC.Name) =
       let
         fds = map hsFDsFromInside matches
       in
         (nub (concatMap fst fds), nub(concatMap snd fds))

     decl ((GHC.PatBind p rhs _ _ _) :: GHC.HsBind GHC.Name) =
       let
         (pf, pd) = hsFreeAndDeclaredPNs p
         (rf, rd) = hsFreeAndDeclaredPNs rhs
       in
         (nub (pf `union` (rf \\ pd)),
          nub (pd `union` rd))

     decl ((GHC.VarBind p rhs _) :: GHC.HsBind GHC.Name) =
       let
         (pf, pd) = hsFreeAndDeclaredPNs p
         (rf, rd) = hsFreeAndDeclaredPNs rhs
       in
         (nub (pf `union` (rf \\ pd)),
          nub (pd `union` rd))

     expr ((GHC.HsLet decls e) :: GHC.HsExpr GHC.Name) =
       let
         (df,dd) = hsFreeAndDeclaredPNs decls
         (ef,_)  = hsFreeAndDeclaredPNs e
       in
         (nub (df `union` (ef \\ dd)), nub dd)

     expr ((GHC.HsLam (GHC.MatchGroup matches _)) :: GHC.HsExpr GHC.Name) =
       hsFreeAndDeclaredPNs matches

     expr ((GHC.HsCase e (GHC.MatchGroup matches _)) :: GHC.HsExpr GHC.Name) =
       let
         (ef,_)  = hsFreeAndDeclaredPNs e
         (df,dd) = hsFreeAndDeclaredPNs matches
       in
         (nub (df `union` (ef \\ dd)), nub dd)

     expr _ = ([],[])

     stmts ((GHC.BindStmt pat e1 e2 e3) :: GHC.Stmt GHC.Name) =
       let
         (pf,pd)  = hsFreeAndDeclaredPNs pat
         (ef,_ed) = hsFreeAndDeclaredPNs e1
         (df,dd)  = hsFreeAndDeclaredPNs [e2,e3]
       in
         (nub (pf `union` (((ef \\ dd) `union` df) \\ pd)), nub (pd `union` dd))

     stmts ((GHC.LetStmt binds) :: GHC.Stmt GHC.Name) =
       hsFreeAndDeclaredPNs binds


-- -----

{-
hsFDsFromInside:: (Term t, MonadPlus m)=> t-> m ([PName],[PName])
hsFDsFromInside t = do (f,d)<-hsFDsFromInside' t
                       return (nub f, nub d)
   where
     hsFDsFromInside' = applyTU (once_tdTU (failTU  `adhocTU` mod
                                                    -- `adhocTU` decls
                                                     `adhocTU` decl
                                                     `adhocTU` match
                                                     `adhocTU` exp
                                                     `adhocTU` alt
                                                     `adhocTU` stmts ))


     mod ((HsModule loc modName exps imps ds)::HsModuleP)
        = hsFreeAndDeclaredPNs ds

 {-    decls (ds::[HsDeclP])                    --CHECK THIS.
       = hsFreeAndDeclaredPNs decls
-}
     match ((HsMatch loc1 (PNT fun _ _) pats rhs ds) ::HsMatchP)
       = do (pf, pd) <-hsFreeAndDeclaredPNs pats
            (rf, rd) <-hsFreeAndDeclaredPNs rhs
            (df, dd) <-hsFreeAndDeclaredPNs ds
            return (nub (pf `union` ((rf `union` df) \\ (dd `union` pd `union` [fun]))), 
                    nub (pd `union` rd `union` dd `union` [fun]))

     decl ((TiDecorate.Dec (HsPatBind loc p rhs ds))::HsDeclP)
      = do (pf, pd)<-hsFreeAndDeclaredPNs p
           (rf, rd)<-hsFreeAndDeclaredPNs rhs
           (df, dd)<-hsFreeAndDeclaredPNs ds
           return (nub (pf `union` ((rf `union` df) \\ (dd `union` pd))),
                   nub ((pd `union` rd `union` dd)))

     decl (TiDecorate.Dec (HsFunBind loc matches))
         =do fds <-mapM hsFDsFromInside matches
             return (nub (concatMap fst fds), nub(concatMap snd fds))

     decl _ = mzero

     exp ((TiDecorate.Exp (HsLet decls exp))::HsExpP)
          = do (df,dd)<- hsFreeAndDeclaredPNs decls
               (ef,_)<- hsFreeAndDeclaredPNs exp
               return (nub (df `union` (ef \\ dd)), nub dd)
     exp (TiDecorate.Exp (HsLambda pats body))
            = do (pf,pd) <-hsFreeAndDeclaredPNs pats
                 (bf,_) <-hsFreeAndDeclaredPNs body
                 return (nub ((bf `union` pf) \\ pd), nub pd)
     exp _ = mzero

     alt ((HsAlt _ pat exp decls)::HsAltP)
         = do (pf,pd) <- hsFreeAndDeclaredPNs pat
              (ef,ed) <- hsFreeAndDeclaredPNs exp
              (df,dd) <- hsFreeAndDeclaredPNs decls
              return (nub (pf `union` (((ef \\ dd) `union` df) \\ pd)), nub (pd `union` dd))      

     stmts ((HsLetStmt decls stmts)::HsStmtP)
          = do (df,dd) <-hsFreeAndDeclaredPNs decls
               (sf,sd) <-hsFreeAndDeclaredPNs stmts
               return (nub (df `union` (sf \\dd)),[]) -- dd)

     stmts (HsGenerator _ pat exp stmts)
          = do (pf,pd) <-hsFreeAndDeclaredPNs pat
               (ef,ed) <-hsFreeAndDeclaredPNs exp
               (sf,sd) <-hsFreeAndDeclaredPNs stmts
               return (nub (pf `union` ef `union` (sf\\pd)),[]) -- pd)

     stmts _ = mzero
-}


-- | The same as `hsFDsFromInside` except that the returned variables
-- are in the String format
hsFDNamesFromInside::(SYB.Data t) => t -> ([String],[String])
hsFDNamesFromInside t =
  let
    (f,d) = hsFDsFromInside t
  in
    ((nub.map GHC.showPpr) f, (nub.map GHC.showPpr) d)
-- hsFDNamesFromInside::(Term t, MonadPlus m)=>t->m ([String],[String])
-- hsFDNamesFromInside t =do (f,d)<-hsFDsFromInside t
--                           return ((nub.map pNtoName) f, (nub.map pNtoName) d)


-- ---------------------------------------------------------------------
-- | Collect the identifiers (in PName format) in a given syntax phrase.

hsPNs::(SYB.Data t)=> t -> [PName]
hsPNs t = (nub.ghead "hsPNs") res
  where
     res = SYB.everythingStaged SYB.Parser (++) [] ([] `SYB.mkQ` inPnt) t

     inPnt (pname :: GHC.RdrName) = return [(PN pname)]

-- ---------------------------------------------------------------------

hsNamess::(SYB.Data t)=> t -> [GHC.Name]
hsNamess t = (nub.ghead "hsNamess") res
  where
     res = SYB.everythingStaged SYB.Renamer (++) [] ([] `SYB.mkQ` inName) t

     inName (pname :: GHC.Name) = return [pname]



{-
-- | Collect the identifiers (in PNT format) in a given syntax phrase.
hsPNTs ::(Term t)=>t->[PNT]
hsPNTs =(nub.ghead "hsPNTs").applyTU (full_tdTU (constTU [] `adhocTU` inPnt))
   where
     inPnt pnt@(PNT _  _ _) = return [pnt]
-}

-------------------------------------------------------------------------------
{-
-- | Return True if a PNT is a type constructor.
isTypeCon :: PNT -> Bool
isTypeCon (PNT pn (Type typeInfo) _) = defType typeInfo == Just TypedIds.Data
isTypeCon _ = False

-- | Return True if a declaration is a type signature declaration.
isTypeSig ::HsDeclP->Bool
isTypeSig (TiDecorate.Dec (HsTypeSig loc is c tp))=True
isTypeSig _=False
-}

-- | Return True if a declaration is a function definition.
isFunBindP::HsDeclP -> Bool
isFunBindP (GHC.L l (GHC.ValD (GHC.FunBind _ _ _ _ _ _))) = True
isFunBindP _ =False

isFunBindR::GHC.LHsBind t -> Bool
isFunBindR (GHC.L _l (GHC.FunBind _ _ _ _ _ _)) = True
isFunBindR _ =False

-- | Returns True if a declaration is a pattern binding.
isPatBindP::HsDeclP->Bool
isPatBindP (GHC.L _ (GHC.ValD (GHC.PatBind _ _ _ _ _))) = True
isPatBindP _=False

isPatBindR::GHC.LHsBind t -> Bool
isPatBindR (GHC.L _ (GHC.PatBind _ _ _ _ _)) = True
isPatBindR _=False


-- | Return True if a declaration is a pattern binding which only
-- defines a variable value.
isSimplePatBind :: (SYB.Data t) => GHC.LHsBind t-> Bool
isSimplePatBind decl = case decl of
     (GHC.L _l (GHC.PatBind p _rhs _ty _fvs _)) -> hsPNs p /= []
     _ -> False
-- isSimplePatBind :: HsDeclP -> Bool
-- isSimplePatBind decl = case decl of
--      (GHC.L l (GHC.ValD (GHC.PatBind p rhs ty fvs _))) -> hsPNs p /= []
--      _ -> False



{-
-- | Return True if a declaration is a pattern binding but not a simple one.
isComplexPatBind::HsDeclP->Bool
isComplexPatBind decl=case decl of
     TiDecorate.Dec (HsPatBind _ p _ _)->patToPN p ==defaultPN
     _ -> False
-}
-- | Return True if a declaration is a function\/pattern definition.
isFunOrPatBindP::HsDeclP->Bool
isFunOrPatBindP decl = isFunBindP decl || isPatBindP decl

-- | Return True if a declaration is a function\/pattern definition.
isFunOrPatBindR::GHC.LHsBind t -> Bool
isFunOrPatBindR decl = isFunBindR decl || isPatBindR decl

{-
-- | Return True if a declaration is a Class declaration.
isClassDecl :: HsDeclP ->Bool
isClassDecl (TiDecorate.Dec (HsClassDecl _ _ _ _ _)) = True
isClassDecl _ = False

-- | Return True if a declaration is a Class instance declaration.
isInstDecl :: HsDeclP -> Bool
isInstDecl (TiDecorate.Dec (HsInstDecl _ _ _ _ _)) = True
isInstDecl _ = False

-- | Return True if a function is a directly recursive function.
isDirectRecursiveDef::HsDeclP->Bool
isDirectRecursiveDef (TiDecorate.Dec (HsFunBind loc ms))
   = any isUsedInDef ms
  where
   isUsedInDef (HsMatch loc1 fun pats rhs ds)
     = findEntity (pNTtoPN fun) rhs
isDirectRecursiveDef _ = False
-}
-------------------------------------------------------------------------------

{- | The HsDecls class -}
class (SYB.Data t) => HsDecls t where

    -- | Return the declarations that are directly enclosed in the
    -- given syntax phrase.
    hsDecls :: t -> [HsDeclP]

    -- | Replace the directly enclosed declaration list by the given
    --  declaration list. Note: This function does not modify the
    --  token stream.
    -- replaceDecls :: t -> HsDeclsP -> t -- ++AZ++ TODO: what are HsDeclsP?

    -- | Return True if the specified identifier is declared in the
    -- given syntax phrase.
    isDeclaredIn :: PName -> t -> Bool

instance HsDecls GHC.ParsedSource where
   hsDecls (GHC.L _ (GHC.HsModule _ _ _ ds _ _)) = ds

   isDeclaredIn pn (GHC.L _ (GHC.HsModule _ _ _ ds _ _))
     = length (definingDecls [pn] ds False False) /= 0

-- | Replace the directly enclosed declaration list by the given
--  declaration list. Note: This function does not modify the
--  token stream.
replaceDecls :: [GHC.LHsBind GHC.Name] -> [GHC.LHsBind GHC.Name] -> [GHC.LHsBind GHC.Name]
replaceDecls t decls = undefined

getDecls :: GHC.RenamedSource -> GHC.LHsBinds GHC.Name
getDecls renamed@(group, _, _, _) = case (GHC.hs_valds group) of
   GHC.ValBindsIn   binds _sigs -> binds
   GHC.ValBindsOut rbinds _sigs -> GHC.unionManyBags $ map (\(_,b) -> b) rbinds

getDeclsP :: GHC.ParsedSource -> [HsDeclP]
getDeclsP parsed@(GHC.L _ hsMod) = GHC.hsmodDecls hsMod


{-
instance HsDecls HsMatchP where
    hsDecls (HsMatch loc1 fun pats rhs ds@(Decs x y))=x

    replaceDecls (HsMatch loc1 fun pats rhs ds) ds'
      =(HsMatch loc1 fun pats rhs ds')

    isDeclaredIn  pn match@(HsMatch loc1 (PNT fun _ _) pats rhs ds)
       =fromMaybe False ( do (_,d)<-hsFDsFromInside match
                             Just (elem pn (d \\ [fun])))
instance HsDecls HsDeclP where
    hsDecls (TiDecorate.Dec (HsPatBind loc p rhs ds@(Decs x y)))=x
    hsDecls (TiDecorate.Dec (HsFunBind loc matches))=concatMap hsDecls matches
    hsDecls _ =[]

    replaceDecls (TiDecorate.Dec (HsPatBind loc p rhs ds)) ds'
        =TiDecorate.Dec (HsPatBind loc p rhs ds')
    replaceDecls x ds' =x

    isDeclaredIn pn (TiDecorate.Dec (HsPatBind loc p rhs ds))
      = fromMaybe False (do (_, rd)<-hsFreeAndDeclaredPNs rhs
                            (_, dd)<-hsFreeAndDeclaredPNs ds
                            Just (elem pn (rd `union` dd)))
    isDeclaredIn pn _ =False

instance HsDecls HsDeclsP where
    hsDecls ds@(Decs x y) = concatMap hsDecls x
    replaceDecls ds _ = ds
    isDeclaredIn _ ds@(Decs x y) = False

instance HsDecls [HsDeclP] where
    hsDecls ds= concatMap hsDecls ds
    replaceDecls ds _ = ds             -- This should not happen.
    isDeclaredIn _ ds = False            -- This should not happen.

instance HsDecls HsModuleP where
    hsDecls (HsModule loc modName exps imps ds@(Decs x y))=x

    replaceDecls (HsModule loc modName exps imps ds) ds'
       = HsModule loc modName exps imps ds'

    isDeclaredIn pn (HsModule loc modName exps imps ds)
       =fromMaybe False  (do (rf,rd)<-hsFreeAndDeclaredPNs ds
                             Just (elem pn rd))

instance HsDecls RhsP where
    hsDecls rhs=fromMaybe [] (applyTU (stop_tdTU (failTU `adhocTU` inLet
                                                                        `adhocTU` inAlt
                                                                        `adhocTU` inStmt)) rhs) 
             where inLet ((TiDecorate.Exp (HsLet ds@(Decs x y) e)) ::HsExpP)=Just x
                   inLet _ =mzero

                   inAlt ((HsAlt _ p rhs ds@(Decs x y))::HsAlt HsExpP HsPatP HsDeclsP)=Just x

                   inStmt ((HsLetStmt ds@(Decs x y) _)::HsStmt HsExpP HsPatP HsDeclsP)=Just x
                   inStmt _=mzero

    replaceDecls rhs _ = rhs           -- This should not happen.
    isDeclaredIn _ _  = False            -- This should not happen.

instance HsDecls HsExpP where
    hsDecls rhs=fromMaybe [] (applyTU (stop_tdTU (failTU `adhocTU` inLet
                                                         `adhocTU` inAlt
                                                         `adhocTU` inStmt)) rhs)
             where inLet ((TiDecorate.Exp (HsLet ds@(Decs x y) e)) ::HsExpP)=Just x
                   inLet (TiDecorate.Exp (HsListComp (HsLetStmt ds@(Decs x y) stmts)))=Just x
                   inLet (TiDecorate.Exp (HsDo (HsLetStmt ds@(Decs x y) stmts)))=Just x
                   inLet _ =Nothing

                   inAlt ((HsAlt _ p rhs ds@(Decs x y))::HsAlt HsExpP HsPatP HsDeclsP)=Just x

                   inStmt ((HsLetStmt ds@(Decs x y) _)::HsStmt HsExpP HsPatP HsDeclsP)=Just x
                   inStmt _=Nothing

    replaceDecls (TiDecorate.Exp (HsLet ds e)) ds'
            =if ds'== Decs [] ([], [])
                then e
                else (TiDecorate.Exp (HsLet ds' e))

    replaceDecls (TiDecorate.Exp (HsListComp (HsLetStmt ds stmts))) ds'@(Decs x y)
            =if x==[] && isLast stmts
               then (TiDecorate.Exp (HsList [fromJust (expInLast stmts)]))
               else (TiDecorate.Exp (HsListComp (HsLetStmt ds' stmts)))
       where
         isLast (HsLast e)=True
         isLast _=False

         expInLast (HsLast e)=Just e
         expInLast _=Nothing

    replaceDecls (TiDecorate.Exp (HsDo (HsLetStmt ds stmts))) ds'@(Decs x y)
            =if x==[]
                then (TiDecorate.Exp (HsDo stmts))
                else (TiDecorate.Exp (HsDo (HsLetStmt ds' stmts)))
    replaceDecls x ds'=x


    isDeclaredIn pn (TiDecorate.Exp (HsLambda pats body))
            = fromMaybe False (do (pf,pd) <-hsFreeAndDeclaredPNs pats
                                  Just (elem pn  pd))

    isDeclaredIn pn (TiDecorate.Exp (HsLet decls e))
           =fromMaybe False (do (df,dd)<- hsFreeAndDeclaredPNs decls
                                Just (elem pn dd))

    isDeclaredIn pn _=False


instance HsDecls HsStmtP where
    hsDecls (HsLetStmt ds@(Decs x y) stmts)=x
    hsDecls  _ = []

    replaceDecls (HsLetStmt ds stmts) ds'@(Decs x y)
     = if x/=[] then  HsLetStmt ds' stmts
                  else stmts

    isDeclaredIn pn (HsGenerator _ pat exp stmts) -- Claus
        =fromMaybe False (do (pf,pd) <-hsFreeAndDeclaredPNs pat
                             Just (elem pn pd))

    isDeclaredIn pn (HsLetStmt decls stmts)
        =fromMaybe False (do (df,dd) <-hsFreeAndDeclaredPNs decls
                             Just (elem pn dd))

    isDeclaredIn pn _=False

instance HsDecls HsAltP where
    hsDecls (HsAlt _ p rhs ds@(Decs x y))=x

    replaceDecls (HsAlt loc p rhs ds) ds'=HsAlt loc p rhs ds'

    isDeclaredIn pn (HsAlt _ pat exp decls)
       =fromMaybe False ( do (pf,pd) <- hsFreeAndDeclaredPNs pat
                             (df,dd) <- hsFreeAndDeclaredPNs decls
                             Just (elem pn (pd `union` dd)))

-}
-- ---------------------------------------------------------------------

-- |Find those declarations(function\/pattern binding and type
-- signature) which define the specified PNames. incTypeSig indicates
-- whether the corresponding type signature will be included.

definingDecls::[PName]   -- ^ The specified identifiers.
            ->[HsDeclP]  -- ^ A collection of declarations.
            ->Bool       -- ^ True means to include the type signature.
            ->Bool       -- ^ True means to look at the local declarations as well. 
            ->[HsDeclP]  -- ^ The result.
-- definingDecls pns ds incTypeSig recursive = undefined
definingDecls pns ds incTypeSig recursive = concatMap defines ds
  where
   defines decl
     = if recursive -- TODO: original seems to stop on first match? Should continue
        -- then ghead "defines" $ applyTU (stop_tdTU (failTU `adhocTU` inDecl)) decl
        then SYB.everythingStaged SYB.Parser (++) [] ([] `SYB.mkQ` inDecl) decl
        else defines' decl
     where
      inDecl (d::GHC.LHsDecl GHC.RdrName {- HsDeclP -} )
        -- |defines' d /= [] =return $ defines' d
        -- | length (defines' d) /= 0 = defines' d -- TODO: horribly inefficient
        | True = defines' d -- TODO: horribly inefficient
      inDecl _ = []

      defines' :: HsDeclP -> [HsDeclP]

      -- ValD - binds
      defines' decl@(GHC.L l (GHC.ValD (GHC.FunBind (GHC.L _ pname) _ _ _ _ _)))
        |isJust (find (==(PN pname)) pns) = [decl]

      defines' decl@(GHC.L l (GHC.ValD (GHC.PatBind p rhs ty fvs _)))    ---CONSIDER AGAIN----
        |(hsPNs p) `intersect` pns /= [] = [decl]
      defines' decl@(GHC.L l (GHC.ValD _))                                    = []

      -- SigD - type signatures
      defines' decl@(GHC.L l (GHC.SigD (GHC.TypeSig is tp)))
        |(map lghcToPN is) `intersect` pns /=[]
        = if incTypeSig
           then [(GHC.L l (GHC.SigD (GHC.TypeSig (filter (\x->isJust (find (==lghcToPN x) pns)) is) tp)))]
           else []
      defines' decl@(GHC.L l (GHC.SigD        _ {- (GHC.Sig id) -}))          = []

      -- TyClD - Type definitions
      defines' decl@(GHC.L l (GHC.TyClD (GHC.TyData _ _ name _ _ _ cons _)))
       = if checkCons cons == True then [decl]
                                   else []

             where
               checkCons [] = False
               checkCons ((GHC.L _ (GHC.ConDecl (GHC.L _ pname) _ _ _ _ _ _ _)):ms)
                 | isJust (find (==(PN pname)) pns) = True
                 | otherwise = checkCons ms

      defines' decl@(GHC.L l (GHC.TyClD       _ {- (GHC.TyClDecl id) -}))     = []


      defines' decl@(GHC.L l (GHC.InstD       _ {- (GHC.InstDecl id) -}))     = []
      defines' decl@(GHC.L l (GHC.DerivD      _ {- (GHC.DerivDecl id) -}))    = []
      defines' decl@(GHC.L l (GHC.DefD        _ {- (GHC.DefaultDecl id) -}))  = []
      defines' decl@(GHC.L l (GHC.ForD        _ {- (GHC.ForeignDecl id) -}))  = []
      defines' decl@(GHC.L l (GHC.WarningD    _ {- (GHC.WarnDecl id) -}))     = []
      defines' decl@(GHC.L l (GHC.AnnD        _ {- (GHC.AnnDecl id) -}))      = []
      defines' decl@(GHC.L l (GHC.RuleD       _ {- (GHC.RuleDecl id) -}))     = []
      defines' decl@(GHC.L l (GHC.VectD       _ {- (GHC.VectDecl id) -}))     = []
      defines' decl@(GHC.L l (GHC.SpliceD     _ {- (GHC.SpliceDecl id) -}))   = []
      defines' decl@(GHC.L l (GHC.DocD        _ {- (GHC.DocDecl) -}))         = []
      defines' decl@(GHC.L l (GHC.QuasiQuoteD _ {- (GHC.HsQuasiQuote id) -})) = []

-- ---------------------------------------------------------------------

-- |Find those declarations(function\/pattern binding and type
-- signature) which define the specified GHC.Names. incTypeSig indicates
-- whether the corresponding type signature will be included.

definingDeclsNames:: (SYB.Data t) =>
            [GHC.Name] -- ^ The specified identifiers.
            ->t                -- ^ A collection of declarations.
            ->Bool       -- ^ True means to include the type signature.
            ->Bool       -- ^ True means to look at the local declarations as well. 
            ->[GHC.LHsBind GHC.Name]  -- ^ The result.
definingDeclsNames pns ds incTypeSig recursive = defines ds
  where
   defines decl
     = if recursive -- TODO: original seems to stop on first match? Should continue
        -- then ghead "defines" $ applyTU (stop_tdTU (failTU `adhocTU` inDecl)) decl
        -- then SYB.everythingStaged SYB.Parser (++) [] ([] `SYB.mkQ` inDecl) decl
        then []
        -- else defines' decl
        else SYB.everythingStaged SYB.Renamer (++) [] ([]  `SYB.mkQ` defines') decl
     where

      defines' decl'@(GHC.L _ (GHC.FunBind (GHC.L _ pname) _ _ _ _ _))
        |isJust (find (==(pname)) pns) = [decl']
        -- | True = [decl]

      defines' decl'@(GHC.L l (GHC.PatBind p rhs ty fvs _))
        |(hsNamess p) `intersect` pns /= [] = [decl']


      {-
      defines' decl@(GHC.L l (GHC.ValD (GHC.PatBind p rhs ty fvs _)))    ---CONSIDER AGAIN----
        |(hsPNs p) `intersect` pns /= [] = [decl]
      defines' decl@(GHC.L l (GHC.ValD _))                                    = []
      -}

      -- TODO: the type signature is a different type, move it to its
      --       own function, if it is required
      {-
      defines' sig@(GHC.L _ (GHC.TypeSig [GHC.L _ n] s))
        | incTypeSig = [sig]
      -}

      {-
      -- SigD - type signatures
      defines' decl@(GHC.L l (GHC.SigD (GHC.TypeSig is tp)))
        |(map lghcToPN is) `intersect` pns /=[]
        = if incTypeSig
           then [(GHC.L l (GHC.SigD (GHC.TypeSig (filter (\x->isJust (find (==lghcToPN x) pns)) is) tp)))]
           else []
      defines' decl@(GHC.L l (GHC.SigD        _ {- (GHC.Sig id) -}))          = []

      -- TyClD - Type definitions
      defines' decl@(GHC.L l (GHC.TyClD (GHC.TyData _ _ name _ _ _ cons _)))
       = if checkCons cons == True then [decl]
                                   else []

             where
               checkCons [] = False
               checkCons ((GHC.L _ (GHC.ConDecl (GHC.L _ pname) _ _ _ _ _ _ _)):ms)
                 | isJust (find (==(PN pname)) pns) = True
                 | otherwise = checkCons ms

      defines' decl@(GHC.L l (GHC.TyClD       _ {- (GHC.TyClDecl id) -}))     = []


      defines' decl@(GHC.L l (GHC.InstD       _ {- (GHC.InstDecl id) -}))     = []
      defines' decl@(GHC.L l (GHC.DerivD      _ {- (GHC.DerivDecl id) -}))    = []
      defines' decl@(GHC.L l (GHC.DefD        _ {- (GHC.DefaultDecl id) -}))  = []
      defines' decl@(GHC.L l (GHC.ForD        _ {- (GHC.ForeignDecl id) -}))  = []
      defines' decl@(GHC.L l (GHC.WarningD    _ {- (GHC.WarnDecl id) -}))     = []
      defines' decl@(GHC.L l (GHC.AnnD        _ {- (GHC.AnnDecl id) -}))      = []
      defines' decl@(GHC.L l (GHC.RuleD       _ {- (GHC.RuleDecl id) -}))     = []
      defines' decl@(GHC.L l (GHC.VectD       _ {- (GHC.VectDecl id) -}))     = []
      defines' decl@(GHC.L l (GHC.SpliceD     _ {- (GHC.SpliceDecl id) -}))   = []
      defines' decl@(GHC.L l (GHC.DocD        _ {- (GHC.DocDecl) -}))         = []
      defines' decl@(GHC.L l (GHC.QuasiQuoteD _ {- (GHC.HsQuasiQuote id) -})) = []
      -}

      defines' _ = []

-- ---------------------------------------------------------------------

{-

definingDecls::[PName]         -- ^ The specified identifiers.
            ->[HsDeclP]        -- ^ A collection of declarations.
            ->Bool             -- ^ True means to include the type signature.
            ->Bool             -- ^ True means to look at the local declarations as well. 
            ->[HsDeclP]        -- ^ The result.
definingDecls pns ds incTypeSig recursive=concatMap defines ds
  where
   defines decl
     =if recursive
        then ghead "defines" $ applyTU (stop_tdTU (failTU `adhocTU` inDecl)) decl
        else defines' decl
     where
      inDecl (d::HsDeclP)
        |defines' d /=[] =return $ defines' d
      inDecl _=mzero

      defines' decl@(TiDecorate.Dec (HsFunBind _ ((HsMatch _ (PNT pname _ _) _ _ _):ms))) 
        |isJust (find (==pname) pns) = [decl]
      defines' decl@(TiDecorate.Dec (HsPatBind loc p rhs ds))    ---CONSIDER AGAIN----
        |(hsPNs p) `intersect` pns /=[] = [decl]
      defines' decl@(TiDecorate.Dec (HsTypeSig loc is c tp))     --handle cases like  a,b::Int 
        |(map pNTtoPN is) `intersect` pns /=[]
        =if incTypeSig
           then [(TiDecorate.Dec (HsTypeSig loc (filter (\x->isJust (find (==pNTtoPN x) pns)) is) c tp))]
           else []
      defines' decl@(TiDecorate.Dec (HsDataDecl loc c tp cons i))
       = if checkCons cons == True then [decl]
                                   else []

             where
               checkCons [] = False
               checkCons ((HsConDecl loc i c (PNT pname _ _) t):ms)
                 | isJust (find (==pname) pns) = True
                 | otherwise = checkCons ms
      defines' _ =[]
-}

-- ---------------------------------------------------------------------

-- TODO: AZ: pretty sure this can be simplified, depends if we need to
--          manage transformed stuff too though.

-- | Return True if syntax phrases t1 and t2 refer to the same one.
sameOccurrence :: (GHC.Located t) -> (GHC.Located t) -> Bool
sameOccurrence (GHC.L l1 _) (GHC.L l2 _)
 = l1 == l2


-- ---------------------------------------------------------------------

-- | Return True if the function\/pattern binding defines the
-- specified identifier.
defines:: GHC.Name -> GHC.LHsBind GHC.Name -> Bool
defines n (GHC.L _ (GHC.FunBind (GHC.L _ pname) _ _ _ _ _))
 = pname == n
defines n (GHC.L _ (GHC.PatBind p _rhs _ty _fvs _))
 = elem n (hsNamess p)
defines _ _= False

definesP::PName->HsDeclP->Bool
definesP pn (GHC.L _ (GHC.ValD (GHC.FunBind (GHC.L _ pname) _ _ _ _ _)))
 = PN pname == pn
definesP pn (GHC.L _ (GHC.ValD (GHC.PatBind p _rhs _ty _fvs _)))
 = elem pn (hsPNs p)
definesP _ _= False

-- defines::PName->HsDeclP->Bool
-- defines pn (GHC.L l (GHC.ValD (GHC.FunBind (GHC.L _ pname) _ _ _ _ _)))
--  = PN pname == pn
-- defines pn (GHC.L l (GHC.ValD (GHC.PatBind p rhs ty fvs _)))
--  = elem pn (hsPNs p)
-- defines _ _= False



{-
-- | Return True if the declaration defines the type signature of the specified identifier.
definesTypeSig :: PName -> HsDeclP -> Bool
definesTypeSig pn (TiDecorate.Dec (HsTypeSig loc is c tp))=elem pn (map pNTtoPN is)  
definesTypeSig _  _ =False


-- | Return True if the declaration defines the type signature of the specified identifier.
isTypeSigOf :: PNT -> HsDeclP -> Bool
isTypeSigOf pnt (TiDecorate.Dec (HsTypeSig loc is c tp))= elem pnt is
isTypeSigOf _  _ =False


-- | Return the list of identifiers (in PName format) defined by a function\/pattern binding.
definedPNs::HsDeclP->[PName]
definedPNs (TiDecorate.Dec (HsFunBind _ ((HsMatch _ (PNT pname _ _) _ _ _):_))) =[pname]
definedPNs (TiDecorate.Dec (HsPatBind _ p _ _)) =hsPNs p
definedPNs (TiDecorate.Dec (HsDataDecl _ _ _ cons _) )
   = getCons cons
       where
         getCons [] = []
         getCons ((HsConDecl _ _ _ (PNT pname _ _) _):ms)
           = pname : (getCons ms)
         getCons ((HsRecDecl _ _ _ (PNT pname _ _) _):ms)
           = pname : (getCons ms)
         getCons _ = []
definedPNs _=[]


-- |Return True if the given syntax phrase contains any free variables.
hasFreeVars::(Term t)=>t->Bool
hasFreeVars t = fromMaybe False (do (f,_)<-hsFreeAndDeclaredPNs t
                                    if f/=[] then Just True
                                             else Nothing)
-}
------------------------------------------------------------------------------------

-- |Find the identifier(in PNT format) whose start position is (row,col) in the
-- file specified by the fileName, and returns defaultPNT if such an identifier does not exist.

locToPNT::(SYB.Data t)=>GHC.FastString -- ^ The file name
                    ->SimpPos          -- ^ The row and column number
                    ->t                -- ^ The syntax phrase
                    ->PNT              -- ^ The result
-- TODO: return a Maybe, rather than encoding failure in defaultPNT
locToPNT  fileName (row,col) t
  = case res of
         Just x -> x
         Nothing -> defaultPNT
       where
        res = somethingStaged SYB.Parser Nothing (Nothing `SYB.mkQ` worker `SYB.extQ` workerBind `SYB.extQ` workerExpr) t

        worker (pnt@(GHC.L l _) :: (GHC.Located GHC.RdrName))
          | inScope l = Just (PNT pnt)
        worker _ = Nothing

        workerBind (GHC.L l (GHC.VarPat name) :: (GHC.Located (GHC.Pat GHC.RdrName)))
          | inScope l = Just (PNT (GHC.L l name))
        workerBind _ = Nothing

        workerExpr (pnt@(GHC.L l (GHC.HsVar name)) :: (GHC.Located (GHC.HsExpr GHC.RdrName)))
          | inScope l = Just (PNT (GHC.L l name))
        workerExpr _ = Nothing

        inScope :: GHC.SrcSpan -> Bool
        inScope l =
          case l of
            (GHC.UnhelpfulSpan _) -> False
            (GHC.RealSrcSpan ss)  ->
              (GHC.srcSpanFile ss == fileName) &&
              (GHC.srcSpanStartLine ss == row) &&
              (col >= (GHC.srcSpanStartCol ss)) &&
              (col <= (GHC.srcSpanEndCol ss))

------------------------------------------------------------------------------------

-- |Find the identifier(in PNT format) whose start position is (row,col) in the
-- file specified by the fileName, and returns defaultPNT if such an identifier does not exist.

allPNT::(SYB.Data t)=>GHC.FastString   -- ^ The file name
                    ->SimpPos          -- ^ The row and column number
                    ->t                -- ^ The syntax phrase
                    ->[PNT]            -- ^ The result
-- TODO: return a Maybe, rather than encoding failure in defaultPNT
allPNT  fileName (row,col) t
  = res
       where
        -- res = somethingStaged SYB.Parser Nothing (Nothing `SYB.mkQ` worker) t
        res = SYB.everythingStaged SYB.Parser (++) []
            ([] `SYB.mkQ` worker `SYB.extQ` workerBind `SYB.extQ` workerExpr) t

        worker (pnt :: (GHC.Located GHC.RdrName))
          | True = [(PNT pnt)]
        worker _ = []

        workerBind (GHC.L l (GHC.VarPat name) :: (GHC.Located (GHC.Pat GHC.RdrName)))
          | True = [(PNT (GHC.L l name))]
        workerBind _ = []

        workerExpr (GHC.L l (GHC.HsVar name) :: (GHC.Located (GHC.HsExpr GHC.RdrName)))
          | True = [(PNT (GHC.L l name))]
        workerExpr _ = []


------------------------------------------------------------------------------------

-- |Find the identifier(in GHC.Name format) whose start position is
-- (row,col) in the file specified by the fileName, and returns
-- `Nothing` if such an identifier does not exist.

locToName::(SYB.Data t)=>GHC.FastString   -- ^ The file name
                    ->SimpPos          -- ^ The row and column number
                    ->t                -- ^ The syntax phrase
                    -> Maybe (GHC.Located GHC.Name)            -- ^ The result
locToName fileName (row,col) t
  = res
       where
        res = somethingStaged SYB.Renamer Nothing
            (Nothing `SYB.mkQ` worker `SYB.extQ` workerBind `SYB.extQ` workerExpr) t

        worker (pnt :: (GHC.Located GHC.Name))
          | inScope pnt = Just pnt
        worker _ = Nothing

        workerBind pnt@(GHC.L l (GHC.VarPat name) :: (GHC.Located (GHC.Pat GHC.Name)))
          | inScope pnt = Just (GHC.L l name)
        workerBind _ = Nothing


        workerExpr (pnt@(GHC.L l (GHC.HsVar name)) :: (GHC.Located (GHC.HsExpr GHC.Name)))
          | inScope pnt = Just (GHC.L l name)
        workerExpr _ = Nothing

        inScope :: GHC.Located e -> Bool
        inScope (GHC.L l _) =
          case l of
            (GHC.UnhelpfulSpan _) -> False
            (GHC.RealSrcSpan ss)  ->
              (GHC.srcSpanFile ss == fileName) &&
              (GHC.srcSpanStartLine ss == row) &&
              (col >= (GHC.srcSpanStartCol ss)) &&
              (col <= (GHC.srcSpanEndCol ss))



--------------------------------------------------------------------------------

-- |Find the identifier(in PNT format) whose start position is
-- (row,col) in the file specified by the fileName, and returns
-- defaultPNT if such an identifier does not exist.

allNames::(SYB.Data t)=>GHC.FastString   -- ^ The file name
                    ->SimpPos          -- ^ The row and column number
                    ->t                -- ^ The syntax phrase
                    ->[GHC.Located GHC.Name]            -- ^ The result
allNames  fileName (row,col) t
  = res
       where
        res = SYB.everythingStaged SYB.Parser (++) []
            ([] `SYB.mkQ` worker `SYB.extQ` workerBind `SYB.extQ` workerExpr) t

        worker (pnt :: (GHC.Located GHC.Name))
          -- | inScope pnt = [(PNT pnt)]
          | True = [pnt]
        worker _ = []

        workerBind (GHC.L l (GHC.VarPat name) :: (GHC.Located (GHC.Pat GHC.Name)))
          -- | inScope pnt = [(PNT pnt)]
          | True = [(GHC.L l name)]
        workerBind _ = []


        workerExpr (pnt@(GHC.L l (GHC.HsVar name)) :: (GHC.Located (GHC.HsExpr GHC.Name)))
          -- | inScope pnt = [(PNT pnt)]
          | True = [(GHC.L l name)]
        workerExpr _ = []

        inScope :: GHC.Located e -> Bool
        inScope (GHC.L l _) =
          case l of
            (GHC.UnhelpfulSpan _) -> False
            (GHC.RealSrcSpan ss)  ->
              (GHC.srcSpanFile ss == fileName) &&
              (GHC.srcSpanStartLine ss == row) &&
              (col >= (GHC.srcSpanStartCol ss)) &&
              (col <= (GHC.srcSpanEndCol ss))


--------------------------------------------------------------------------------

-- |Find the identifier with the given name. This looks through the
-- given syntax phrase for the first GHC.Name which matches. Because
-- it is Renamed source, the GHC.Name will include its defining
-- location. Returns Nothing if the name is not found.

getName::(SYB.Data t)=>
                      String           -- ^ The name to find
                    ->t                -- ^ The syntax phrase
                    ->Maybe GHC.Name   -- ^ The result
getName str t
  = res
       where
        res = somethingStaged SYB.Renamer Nothing
            (Nothing `SYB.mkQ` worker `SYB.extQ` workerBind `SYB.extQ` workerExpr) t

        worker (pnt@(GHC.L _ n) :: (GHC.Located GHC.Name))
          | GHC.showPpr n == str = Just n
        worker _ = Nothing

        workerBind (GHC.L l (GHC.VarPat name) :: (GHC.Located (GHC.Pat GHC.Name)))
          | GHC.showPpr name == str = Just name
        workerBind _ = Nothing


        workerExpr (pnt@(GHC.L l (GHC.HsVar name)) :: (GHC.Located (GHC.HsExpr GHC.Name)))
          | GHC.showPpr name == str = Just name
        workerExpr _ = Nothing



------------------------------------------------------------------------------------

-- |Find the identifier(in PNT format) whose start position is (row,col) in the
-- file specified by the fileName, and returns defaultPNT if such an identifier does not exist.
allPNTLens ::(SYB.Data t, SYB.Typeable t)=>GHC.FastString   -- ^ The file name
                    ->SimpPos          -- ^ The row and column number
                    ->t                -- ^ The syntax phrase
                    ->[PNT]            -- ^ The result

-- TODO: return a Maybe, rather than encoding failure in defaultPNT
allPNTLens fileName (row,col) t
  = res
       where
        -- res = []
        res = pnts t

        pnts :: (SYB.Data a, SYB.Typeable a) => a -> [PNT]
        -- pnts = foldMapOf ghcplate getPNT

        -- foldMapOf :: Monoid r => Simple Traversal a c -> (c -> r) -> a -> r
        pnts = foldMapOf mytraverse pntQ
        -- pnts = foldMapOf mytraverse getPNT
        -- pnts = foldMapOf ghcplate getPNT
        -- pnts = foldOf mytraverse
        -- pnts = foldMapOf ghcplate getPNTBind


mytraverse :: (SYB.Data a) => Simple Traversal a [PNT]
mytraverse = ghcplate

-- ghcplate ::
--   (Data a, Typeable b, Applicative c) => (b -> c b) -> a -> c a

-- foo :: (SYB.Data a, SYB.Typeable a) => a -> [PNT]
foo = undefined

-- mytraverse :: (SYB.Data a, SYB.Data b, SYB.Typeable b) => Simple Traversal a b
-- mytraverse :: (SYB.Data a, SYB.Typeable a) => a -> [PNT]
--mytraverse = ghcplate pntQ

-- pntQ :: (SYB.Data a, SYB.Typeable a) => a -> [PNT]
pntQ = (          [] `SYB.mkQ` getPNT `SYB.extQ` getPNTBind)

getPNT pnt@(GHC.L l name) = [PNT pnt]

getPNTBind (GHC.L l (GHC.VarPat name) :: (GHC.Located (GHC.Pat GHC.RdrName)))
       = [(PNT (GHC.L l name))]
getPNTBind _ = []

-- getPNT

  {-
        -- res = somethingStaged SYB.Parser Nothing (Nothing `SYB.mkQ` worker) t
        res = SYB.everythingStaged SYB.Parser (++) []
            ([] `SYB.mkQ` worker `SYB.extQ` workerBind `SYB.extQ` workerExpr) t

        worker (pnt :: (GHC.Located GHC.RdrName))
          -- | inScope pnt = [(PNT pnt)]
          | True = [(PNT pnt)]
        worker _ = []

        workerBind (GHC.L l (GHC.VarPat name) :: (GHC.Located (GHC.Pat GHC.RdrName)))
          -- | inScope pnt = [(PNT pnt)]
          | True = [(PNT (GHC.L l name))]
        workerBind _ = []

        workerExpr (pnt@(GHC.L l (GHC.HsVar name)) :: (GHC.Located (GHC.HsExpr GHC.RdrName)))
          -- | inScope pnt = [(PNT pnt)]
          | True = [(PNT (GHC.L l name))]
        workerExpr _ = []

        inScope :: GHC.Located e -> Bool
        inScope (GHC.L l _) =
          case l of
            (GHC.UnhelpfulSpan _) -> False
            (GHC.RealSrcSpan ss)  ->
              (GHC.srcSpanFile ss == fileName) &&
              (GHC.srcSpanStartLine ss == row) &&
              (col >= (GHC.srcSpanStartCol ss)) &&
              (col <= (GHC.srcSpanEndCol ss))
  -}

-- ---------------------------------------------------------------------

-- | Duplicate a functon\/pattern binding declaration under a new name
-- right after the original one. Also updates the token stream.
duplicateDecl::
    [GHC.LHsBind GHC.Name]  -- ^ The declaration list
  ->GHC.Name                -- ^ The identifier whose definition is to be duplicated
  ->GHC.Name                -- ^ The new name (possibly qualified)
  ->RefactGhc [GHC.LHsBind GHC.Name]  -- ^ The result
{- there maybe fun/simple pattern binding and type signature in the
duplicated decls function binding, and type signature are handled
differently here: the comment and layout in function binding are
preserved.The type signature is outputted by pretty printer, so the
comments and layout are NOT preserved.
 -}

{-
  TODO ++AZ++ the manipulations below are crying out for some kind of
  zipper or other similar structure to keep the declarations and token
  stream together, so that the manipulation can proceed in a natural
  way. Main target for phase 2
 -}

duplicateDecl decls n newFunName
 = do others <- get
      let toks = rsTokenStream others
      let (startPos, endPos) = startEndLocIncComments toks funBinding
          {-take those tokens before (and include) the function
            binding and its following white tokens before the 'new line' token.
            (some times the function may be followed by comments) -}
          toks1 = ts1++[ghead "duplicateDecl" ts2]
                    where (ts1, ts2) = break (\t -> (tokenPos t) > endPos) toks
          --take those token after (and include) the function binding
          toks2 = dropWhile (\t->tokenPos t/=startPos {- || isNewLn t -}) toks
      -- put((toks2,modified), others)
      put $ others {rsTokenStream = toks2, rsStreamModified = True }

      --rename the function name to the new name, and update token
      --stream (toks2, just updated) as well, in the monad
      funBinding' <- renamePN n newFunName True funBinding
      --rename function name in type signature  without adjusting the token stream
      -- typeSig'  <- renamePN pn Nothing newFunName False typeSig
      -- Get the updated token stream
      st <- get
      let toks2 = rsTokenStream st

      let offset = getOffset toks (fst (getStartEndLoc funBinding))
          newLineTok = if ((not (emptyList toks1)) {-&& endsWithNewLn (glast "doDuplicating" toks1 -})
                         then [newLnToken]
                         else [newLnToken,newLnToken]


          -- toks' = (toks1++newLineTok++(whiteSpacesToken (0,0) (snd startPos-1))++toks2) 
          toks' = (toks1++newLineTok++toks2)
          {- toks'= if typeSig/=[]
                 then let offset = tokenCol ((ghead "doDuplicating") (dropWhile (\t->isWhite t) toks2))
                          sigSource = concatMap (\s->replicate (offset-1) ' '++s++"\n")((lines.render.ppi) typeSig')
                          t = mkToken Whitespace (0,0) sigSource
                      in  (toks1++newLineTok++[t]++(whiteSpacesToken (0,0) (snd startPos-1))++toks2)
                 else  (toks1++newLineTok++(whiteSpacesToken (0,0) (snd startPos-1))++toks2) 
          -}
      -- put ((toks',modified),others)
      put $ others { rsTokenStream = toks', rsStreamModified = modified}
      -- return (typeSig'++funBinding')
      return funBinding'
     where
       declsToDup = definingDeclsNames [n] decls True False
       funBinding = filter isFunOrPatBindR declsToDup     --get the fun binding.
       -- typeSig    = filter isTypeSig declsToDup      --get the type signature.

{-
duplicateDecl decls pn newFunName
 = do ((toks,_), others)<-get
      let (startPos, endPos) =startEndLocIncComments toks funBinding
          {-take those tokens before (and include) the function binding and its following
            white tokens before the 'new line' token. (some times the function may be followed by 
            comments) -}
          toks1 = let (ts1, ts2) =break (\t->tokenPos t==endPos) toks in ts1++[ghead "duplicateDecl" ts2]
          --take those token after (and include) the function binding
          toks2 = dropWhile (\t->tokenPos t/=startPos || isNewLn t) toks
      put((toks2,modified), others)
      --rename the function name to the new name, and update token stream as well
      funBinding'<-renamePN pn Nothing newFunName True funBinding
      --rename function name in type signature  without adjusting the token stream
      typeSig'  <- renamePN pn Nothing newFunName False typeSig
      ((toks2,_), others)<-get
      let offset = getOffset toks (fst (startEndLoc toks funBinding))
          newLineTok = if toks1/=[] && endsWithNewLn (glast "doDuplicating" toks1)
                         then [newLnToken]
                         else [newLnToken,newLnToken]
          toks'= if typeSig/=[]
                 then let offset = tokenCol ((ghead "doDuplicating") (dropWhile (\t->isWhite t) toks2))
                          sigSource = concatMap (\s->replicate (offset-1) ' '++s++"\n")((lines.render.ppi) typeSig')
                          t = mkToken Whitespace (0,0) sigSource
                      in  (toks1++newLineTok++[t]++(whiteSpacesToken (0,0) (snd startPos-1))++toks2)
                 else (toks1++newLineTok++(whiteSpacesToken (0,0) (snd startPos-1))++toks2) 
      put ((toks',modified),others)
      return (typeSig'++funBinding')
     where
       declsToDup = definingDecls [pn] decls True False
       funBinding = filter isFunOrPatBind declsToDup     --get the fun binding.
       typeSig    = filter isTypeSig declsToDup      --get the type signature.


-}


{- ++ original ++
{- ********* IMPORTANT : THIS FUNCTION SHOULD BE UPDATED TO THE NEW TOKEN STREAM METHOD ****** -}
-- | Duplicate a functon\/pattern binding declaration under a new name right after the original one.
duplicateDecl::(MonadState (([PosToken],Bool),t1) m)
                 =>[HsDeclP]            -- ^ The declaration list
                 ->PName                -- ^ The identifier whose definition is going to be duplicated
                 ->String               -- ^ The new name
                 ->m [HsDeclP]          -- ^ The result
{-there maybe fun/simple pattern binding and type signature in the duplicated decls
  function binding, and type signature are handled differently here: the comment and layout
  in function binding are preserved.The type signature is output ted by pretty printer, so
  the comments and layout are NOT preserved.
 -}
duplicateDecl decls pn newFunName
 = do ((toks,_), others)<-get
      let (startPos, endPos) =startEndLocIncComments toks funBinding
          {-take those tokens before (and include) the function binding and its following
            white tokens before the 'new line' token. (some times the function may be followed by 
            comments) -}
          toks1 = let (ts1, ts2) =break (\t->tokenPos t==endPos) toks in ts1++[ghead "duplicateDecl" ts2]
          --take those token after (and include) the function binding
          toks2 = dropWhile (\t->tokenPos t/=startPos || isNewLn t) toks
      put((toks2,modified), others)
      --rename the function name to the new name, and update token stream as well
      funBinding'<-renamePN pn Nothing newFunName True funBinding
      --rename function name in type signature  without adjusting the token stream
      typeSig'  <- renamePN pn Nothing newFunName False typeSig
      ((toks2,_), others)<-get
      let offset = getOffset toks (fst (startEndLoc toks funBinding))
          newLineTok = if toks1/=[] && endsWithNewLn (glast "doDuplicating" toks1)
                         then [newLnToken]
                         else [newLnToken,newLnToken]
          toks'= if typeSig/=[]
                 then let offset = tokenCol ((ghead "doDuplicating") (dropWhile (\t->isWhite t) toks2))
                          sigSource = concatMap (\s->replicate (offset-1) ' '++s++"\n")((lines.render.ppi) typeSig')
                          t = mkToken Whitespace (0,0) sigSource
                      in  (toks1++newLineTok++[t]++(whiteSpacesToken (0,0) (snd startPos-1))++toks2)
                 else (toks1++newLineTok++(whiteSpacesToken (0,0) (snd startPos-1))++toks2) 
      put ((toks',modified),others)
      return (typeSig'++funBinding')
     where
       declsToDup = definingDecls [pn] decls True False
       funBinding = filter isFunOrPatBind declsToDup     --get the fun binding.
       typeSig    = filter isTypeSig declsToDup      --get the type signature.


-}

{-
------------------------------------------------------------------------------------------ 
-- | Replace the name (and qualifier if specified) by a new name (and qualifier) in a PName.
--   The function does not modify the token stream.
replaceNameInPN::Maybe ModuleName    -- ^ The new qualifier
                 ->PName             -- ^ The old PName
                 ->String            -- ^ The new name
                 ->PName             -- ^ The result
replaceNameInPN qualifier (PN (UnQual s)(UniqueNames.S loc))  newName
  = if isJust qualifier then (PN (Qual (fromJust qualifier) newName) (UniqueNames.S loc))
                        else (PN (UnQual newName) (UniqueNames.S loc))
replaceNameInPN qualifier (PN (Qual modName  s)(UniqueNames.S loc))  newName
  = if isJust qualifier  then (PN (Qual (fromJust qualifier) newName)(UniqueNames.S loc))
                         else (PN (Qual modName newName) (UniqueNames.S loc))
replaceNameInPN qualifier (PN (UnQual s) (G modName s1 loc))  newName
  = if isJust qualifier then (PN (Qual (fromJust qualifier)  newName) (G modName newName loc))
                        else (PN (UnQual newName) (G modName newName loc))
replaceNameInPN qualifier (PN (Qual modName s) (G modName1 s1 loc))  newName
  =if isJust qualifier then (PN (Qual (fromJust qualifier) newName) (G modName1 newName loc)) 
                       else (PN (Qual modName newName) (G modName1 newName loc))
-}

-- ---------------------------------------------------------------------

-- | Rename each occurrences of the identifier in the given syntax
-- phrase with the new name. If the Bool parameter is True, then
-- modify both the AST and the token stream, otherwise only modify the
-- AST.
renamePN::(SYB.Data t)
   =>GHC.Name             -- ^ The identifier to be renamed.
   ->GHC.Name             -- ^ The new name, including possible qualifier
   ->Bool                 -- ^ True means modifying the token stream as well.
   ->t                    -- ^ The syntax phrase
   ->RefactGhc t
renamePN oldPN newName updateTokens t
  = everywhereMStaged SYB.Renamer (SYB.mkM rename) t
  where
    rename :: (GHC.Located GHC.Name) -> RefactGhc (GHC.Located GHC.Name)
    rename  pnt@(GHC.L l n)
     | (GHC.nameUnique n == GHC.nameUnique oldPN)
     = do if updateTokens
           then  do
                    st <- get
                    let toks = rsTokenStream st
                    let (row,col) = (getLocatedStart pnt)
                    let toks'= replaceToks toks (row,col) (row,col) [newNameTok l newName]
                    put $ st { rsTokenStream = toks', rsStreamModified = modified }
                    return (GHC.L l newName)
           else return (GHC.L l newName)
    rename x = return x

-- ---------------------------------------------------------------------

newNameTok l newName =
  ((GHC.L l (GHC.ITvarid (GHC.occNameFS $ GHC.getOccName newName))),
   (GHC.occNameString $ GHC.getOccName newName))

-- ---------------------------------------------------------------------

{-  
-- | Return True if the identifier can become qualified.
canBeQualified::(Term t)=>PNT->t->Bool
canBeQualified pnt t
  = isTopLevelPNT pnt && isUsedInRhs pnt t && not (findPntInImp pnt t) 
  where 
    findPntInImp pnt 
      = (fromMaybe False).(applyTU (once_tdTU (failTU `adhocTU` inImp)))
      where 
       inImp ((HsImportDecl loc modName qual  as h)::HsImportDeclP)
        |findEntity pnt h = Just True
       inImp _ = Nothing
  
 
-- | Return True if the identifier(in PNT format) occurs in the given syntax phrase.
findPNT::(Term t)=>PNT->t->Bool  
findPNT pnt 
  = (fromMaybe False).(applyTU (once_tdTU (failTU `adhocTU` worker)))
  where
    worker (pnt1::PNT)
      | sameOccurrence pnt pnt1 =Just True
    worker _ =Nothing  

-- | Return True if the identifier (in PName format) occurs in the given syntax phrase.
findPN::(Term t)=>PName->t->Bool
findPN pn 
  =(fromMaybe False).(applyTU (once_tdTU (failTU `adhocTU` worker)))
     where 
        worker (pn1::PName)
           |pn == pn1 && srcLoc pn == srcLoc pn1 = Just True 
        worker _ =Nothing 

-- | Return True if any of the specified PNames ocuur in the given syntax phrase.
findPNs::(Term t)=>[PName]->t->Bool 
findPNs pns 
   =(fromMaybe False).(applyTU (once_tdTU (failTU `adhocTU` worker)))
     where 
        worker (pn1::PName)
           |elem pn1 pns = Just True
        worker _ =Nothing  

-}


-- ---------------------------------------------------------------------
-- | Given the syntax phrase (and the token stream), find the
-- largest-leftmost expression contained in the region specified by
-- the start and end position. If no expression can be found, then
-- return the defaultExp.
locToExp:: (SYB.Data t,SYB.Typeable n) =>
                   SimpPos    -- ^ The start position.
                -> SimpPos    -- ^ The end position.
                -> t          -- ^ The syntax phrase.
                -> Maybe (GHC.Located (GHC.HsExpr n)) -- ^ The result.
locToExp beginPos endPos t = res
  where
     res = somethingStaged SYB.Parser Nothing (Nothing `SYB.mkQ` expr) t

     expr :: GHC.Located (GHC.HsExpr n) -> (Maybe (GHC.Located (GHC.HsExpr n)))
     expr e
        |inScope e = Just e
     expr _ = Nothing

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

------------------------------------------------------------------------------------
-- | From PNT to PName.
-- NOTE: the PNT holds the GHC.Name value, it must be converted to a GHC.RdrName
pNTtoPN :: PNT -> PName
pNTtoPN (PNT (GHC.L _ n)) = PN n

ghcToPN :: GHC.RdrName -> PName
ghcToPN rdr = PN rdr

lghcToPN :: GHC.Located GHC.RdrName -> PName
lghcToPN (GHC.L _ rdr) = PN rdr

{- ++AZ++ this with deal with an actual GHC.Name
pNTtoPN (PNT pname) = case (GHC.nameModule_maybe pname) of
        Nothing -> PN (GHC.Unqual (GHC.nameOccName pname))
        (Just mod) -> PN (GHC.Qual (GHC.moduleName mod) (GHC.nameOccName pname))
++AZ++ end -}

{-
-- | From PName to Name. This function ignores the qualifier.
pNtoName::PName->String
pNtoName (PN (UnQual i) orig)=i
pNtoName (PN (Qual modName i) orig)=i
-}

{-
-- | From PNT to Name. This function ingnores the qualifier.
pNTtoName::PNT->String
pNTtoName=pNtoName.pNTtoPN
-}
----------------------------------------------------------------------------------
