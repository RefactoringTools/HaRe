{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}
----------------------------------------------------------------------------------------------------------------
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


------------------------------------------------------------------------------------------------------------------
{-
module RefacTypeUtils(module DriftStructUtils, module StrategyLib, module RefacTITypeSyn, module PosSyntax,
                  module SourceNames, module UniqueNames, module PNT,
                  module Ents, module Relations, module QualNames, module TypedIds 
-}
module Language.Haskell.Refact.Utils.TypeUtils
       ( dummy
 -- * Program Analysis
    -- ** Imports and exports
   -- ,inScopeInfo, isInScopeAndUnqualified, hsQualifier, {-This function should be removed-} rmPrelude 
   -- ,exportInfo, isExported, isExplicitlyExported, modIsExported

    -- ** Variable analysis
    ,hsPNs -- ,hsPNTs,hsDataConstrs,hsTypeConstrsAndClasses, hsTypeVbls
    {- ,hsClassMembers -} , HsDecls(hsDecls,isDeclaredIn{- ,replaceDecls -})
    -- ,hsFreeAndDeclaredPNs -- ,hsFreeAndDeclaredNames
    -- ,hsVisiblePNs, hsVisibleNames
    -- ,hsFDsFromInside -- , hsFDNamesFromInside

    -- ** Property checking
    -- ,isVarId,isConId,isOperator,isTopLevelPN,isLocalPN,isTopLevelPNT
    -- ,isQualifiedPN,isFunPNT, isFunName, isPatName, isFunOrPatName,isTypeCon,isTypeSig
    ,isFunBind {- ,isPatBind -} ,isSimplePatBind
    -- ,isComplexPatBind,isFunOrPatBind,isClassDecl,isInstDecl,isDirectRecursiveDef
    -- ,usedWithoutQual,canBeQualified, hasFreeVars,isUsedInRhs
    -- ,findPNT,findPN      -- Try to remove this.
    -- ,findPNs, findEntity
    -- ,sameOccurrence
    ,defines -- ,definesTypeSig, isTypeSigOf
    -- ,HasModName(hasModName), HasNameSpace(hasNameSpace)


    -- ** Modules and files
    -- ,clientModsAndFiles,serverModsAndFiles,isAnExistingMod
    -- ,fileNameToModName, strToModName, modNameToStr

    -- ** Locations
    {- ,defineLoc, useLoc-},locToPNT --,locToPN,locToExp, getStartEndLoc

 -- * Program transformation
    -- ** Adding
    -- ,addDecl ,addItemsToImport, addHiding, rmItemsFromImport, addItemsToExport
    -- ,addParamsToDecls, addGuardsToRhs, addImportDecl, duplicateDecl, moveDecl
    -- ** Rmoving
    -- ,rmDecl, rmTypeSig, commentOutTypeSig, rmParams
    -- ,rmItemsFromExport, rmSubEntsFromExport, Delete(delete)
    -- ** Updating
    -- ,Update(update)
    -- ,qualifyPName,rmQualifier,renamePN,replaceNameInPN,autoRenameLocalVar

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
    -- ,simplifyDecl
    -- ** Others
   -- ,mkNewName, applyRefac, applyRefacToClientMods
    , mkRdrName

    -- The following functions are not in the the API yet.
    -- ,getDeclToks, causeNameClashInExports, inRegion , ghead, glast, gfromJust, unmodified, prettyprint,
    -- getDeclAndToks

-- * Typed AST traversals (added by CMB)
    -- * Miscellous
    -- ,removeFromInts, getDataName, checkTypes, getPNs, getPN, getPNPats, mapASTOverTAST

-- * Debug stuff
  , allPNT

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
import System.IO.Unsafe

-- Modules from GHC
import qualified Bag           as GHC
import qualified BasicTypes    as GHC
import qualified Coercion      as GHC
import qualified HsDecls       as GHC
import qualified Digraph       as GHC
import qualified DynFlags      as GHC
import qualified ErrUtils      as GHC
import qualified FastString    as GHC
import qualified ForeignCall   as GHC
import qualified GHC           as GHC
import qualified GHC.Paths     as GHC
import qualified HsPat         as GHC
import qualified HsSyn         as GHC
import qualified InstEnv       as GHC
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
import qualified Var           as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB


-- Until exports are correct
dummy = 1

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

{-
------------------------------------------------------------------------
-- | Collect the free and declared variables (in the PName format) in
-- a given syntax phrase t. In the result, the first list contains the
-- free variables, and the second list contains the declared
-- variables.
hsFreeAndDeclaredPNs:: (Term t, MonadPlus m)=> t-> m ([PName],[PName])
hsFreeAndDeclaredPNs t=do (f,d)<-hsFreeAndDeclared' t
                          return (nub f, nub d)
   where
          {-
          hsFreeAndDeclared'=applyTU (stop_tdTU (failTU  `adhocTU` exp
                                                         `adhocTU` pat
                                                         `adhocTU` match
                                                         `adhocTU` patBind
                                                         `adhocTU` alt
                                                         `adhocTU` decls
                                                         `adhocTU` stmts
                                                         `adhocTU` recDecl))
          -}

          hsFreeAndDeclared' = SYB.everythingStaged SYB.Parser (++) []
                             ([] `SYB.mkQ` exp) t

          -- TODO: After renaming, HsBindLR has field bind_fvs
          --       containing locally bound free vars

          exp (TiDecorate.Exp (HsId (HsVar (PNT pn _ _))))=return ([pn],[])
          exp (TiDecorate.Exp (HsId (HsCon (PNT pn _ _))))=return ([pn],[])
          exp (TiDecorate.Exp (HsInfixApp e1 (HsVar (PNT pn _ _)) e2))
              = addFree pn (hsFreeAndDeclaredPNs [e1,e2])
          exp (TiDecorate.Exp (HsLambda pats body))
              = do (pf,pd) <-hsFreeAndDeclaredPNs pats
                   (bf,_)  <-hsFreeAndDeclaredPNs body
                   return ((bf `union` pf) \\ pd, [])
          exp (TiDecorate.Exp (HsLet decls exp))
              = do (df,dd)<- hsFreeAndDeclaredPNs decls
                   (ef,_)<- hsFreeAndDeclaredPNs exp
                   return ((df `union` (ef \\ dd)),[])
          exp (TiDecorate.Exp (HsRecConstr _  (PNT pn _ _) e))
               = addFree  pn  (hsFreeAndDeclaredPNs e)   --Need Testing
          exp (TiDecorate.Exp (HsAsPat (PNT pn _ _) e))
              = addFree  pn  (hsFreeAndDeclaredPNs e)
          exp _ = mzero
-}
{-

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
++AZ++ -}

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


{-
-- |The same as `hsFreeAndDeclaredPNs` except that the returned variables are in the String format.           
hsFreeAndDeclaredNames::(Term t, MonadPlus m)=> t->m([String],[String])
hsFreeAndDeclaredNames t =do (f1,d1)<-hsFreeAndDeclaredPNs t
                             return ((nub.map pNtoName) f1, (nub.map pNtoName) d1)
-}
------------------------------------------------------------------------
{- ++AZ++ come back to this
-- |`hsFDsFromInside` is different from `hsFreeAndDeclaredPNs` in
-- that: given an syntax phrase t, `hsFDsFromInside` returns not only
-- the declared variables that are visible from outside of t, but also
-- those declared variables that are visible to the main expression
-- inside t.

-- hsFDsFromInside:: (Term t, MonadPlus m)=> t-> m ([PName],[PName])
hsFDsFromInside:: (SYB.Data t, Monad m) => t-> m ([PName],[PName])
hsFDsFromInside t = do (f,d) <- hsFDsFromInside' t
                       return (nub f, nub d)
   where
     {-
     hsFDsFromInside' = applyTU (once_tdTU (failTU  `adhocTU` mod
                                                    -- `adhocTU` decls
                                                     `adhocTU` decl
                                                     `adhocTU` match
                                                     `adhocTU` exp
                                                     `adhocTU` alt
                                                     `adhocTU` stmts ))
     -}

     hsFDsFromInside' = SYB.everythingStaged SYB.Parser (++) [] ([] `SYB.mkQ` mod) t


     mod ((HsModule loc modName exps imps ds)::HsModuleP)
        = hsFreeAndDeclaredPNs ds  
++AZ++ -}
{- ++AZ++
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
++AZ++ -}

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

{-
-- | The same as `hsFDsFromInside` except that the returned variables are in the String format
hsFDNamesFromInside::(Term t, MonadPlus m)=>t->m ([String],[String])
hsFDNamesFromInside t =do (f,d)<-hsFDsFromInside t
                          return ((nub.map pNtoName) f, (nub.map pNtoName) d)
-}

-- ---------------------------------------------------------------------
-- | Collect the identifiers (in PName format) in a given syntax phrase.

-- type HsName = GHC.RdrName
-- newtype PName = PN HsName deriving (Eq)

hsPNs::(SYB.Data t)=> t -> [PName]
-- hsPNs=(nub.ghead "hsPNs").applyTU (full_tdTU (constTU [] `adhocTU` inPnt))
hsPNs t = (nub.ghead "hsPNs") res
  where
     res = SYB.everythingStaged SYB.Parser (++) [] ([] `SYB.mkQ` inPnt) t

     -- inPnt (PNT pname ty loc) = return [pname]
     inPnt (pname :: GHC.RdrName) = return [(PN pname)]



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
isFunBind::HsDeclP -> Bool
isFunBind (GHC.L l (GHC.ValD (GHC.FunBind _ _ _ _ _ _))) = True
-- isFunBind (TiDecorate.Dec (HsFunBind loc matches)) = True
isFunBind _ =False
{-
-- | Returns True if a declaration is a pattern binding.
isPatBind::HsDeclP->Bool
isPatBind (TiDecorate.Dec (HsPatBind _ _ _ _))=True
isPatBind _=False
-}

-- | Return True if a declaration is a pattern binding which only defines a variable value.
isSimplePatBind :: HsDeclP -> Bool
isSimplePatBind decl = case decl of
     (GHC.L l (GHC.ValD (GHC.PatBind p rhs ty fvs _))) -> hsPNs p /= []
     -- TiDecorate.Dec (HsPatBind _ p _ _) -> patToPN p /=defaultPN
     _ -> False

{-
-- | Return True if a declaration is a pattern binding but not a simple one.
isComplexPatBind::HsDeclP->Bool
isComplexPatBind decl=case decl of
     TiDecorate.Dec (HsPatBind _ p _ _)->patToPN p ==defaultPN
     _ -> False

-- | Return True if a declaration is a function\/pattern definition.
isFunOrPatBind::HsDeclP->Bool
isFunOrPatBind decl=isFunBind decl || isPatBind decl

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

-- | Return True if the  function\/pattern binding defines the specified identifier.
defines::PName->HsDeclP->Bool
-- defines pn decl@(TiDecorate.Dec (HsFunBind loc ((HsMatch loc1 (PNT pname ty loc2) pats rhs ds):ms))) 
--  = pname == pn
-- defines pn decl@(TiDecorate.Dec (HsPatBind loc p rhs ds))
--  = elem pn (hsPNs p)
defines pn (GHC.L l (GHC.ValD (GHC.FunBind (GHC.L _ pname) _ _ _ _ _)))
 = PN pname == pn
defines pn (GHC.L l (GHC.ValD (GHC.PatBind p rhs ty fvs _)))
 = elem pn (hsPNs p)
defines _ _= False

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
