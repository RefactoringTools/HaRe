{-# LANGUAGE ScopedTypeVariables #-}
----------------------------------------------------------------------------------------------------------------
-- Module      : TypeUtils

-- Maintainer  : refactor-fp\@kent.ac.uk  
-- |
--
-- This module contains a collection of program analysis and transformation functions (the API) that work
-- over the Type Decorated AST. Most of the functions defined in the module are taken directly from the API,
-- but in some cases are modified to work with the type decorated AST.
--
-- In particular some new functions have been added to make type decorated AST traversals easier.
--
-- In HaRe, in order to preserve the
-- comments and layout of refactored programs, a refactoring modifies not only the AST but also the token stream, and
-- the program source after the refactoring is extracted from the token stream rather than the AST, for the comments
-- and layout information is kept in the token steam instead of the AST. As a consequence, a program transformation
-- function from this API modifies both the AST and the token stream (unless explicitly stated). So when you build 
-- your own program transformations, try to use the API to do the transformation, as this can liberate you from 
-- caring about the token stream.
--
-- This type decorated API is still in development. Any suggestions and comments are very much welcome.


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
    -- ,hsPNs,hsPNTs,hsDataConstrs,hsTypeConstrsAndClasses, hsTypeVbls
    -- ,hsClassMembers, HsDecls(hsDecls,isDeclaredIn, replaceDecls)
    -- ,hsFreeAndDeclaredPNs,hsFreeAndDeclaredNames
    -- ,hsVisiblePNs, hsVisibleNames
    -- ,hsFDsFromInside, hsFDNamesFromInside 

    -- ** Property checking
    -- ,isVarId,isConId,isOperator,isTopLevelPN,isLocalPN,isTopLevelPNT
    -- ,isQualifiedPN,isFunPNT, isFunName, isPatName, isFunOrPatName,isTypeCon,isTypeSig,isFunBind,isPatBind,isSimplePatBind
    -- ,isComplexPatBind,isFunOrPatBind,isClassDecl,isInstDecl,isDirectRecursiveDef
    -- ,usedWithoutQual,canBeQualified, hasFreeVars,isUsedInRhs
    -- ,findPNT,findPN      -- Try to remove this.
    -- ,findPNs, findEntity
    -- ,sameOccurrence   
    -- ,defines,definesTypeSig, isTypeSigOf
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
    -- ,expToPNT, expToPN, nameToExp,pNtoExp,patToPNT, patToPN, nameToPat,pNtoPat
    -- ,definingDecls, definedPNs
    -- ,simplifyDecl
    -- ** Others
   -- ,mkNewName, applyRefac, applyRefacToClientMods
                   
    -- The following functions are not in the the API yet.
    -- ,getDeclToks, causeNameClashInExports, inRegion , ghead, glast, gfromJust, unmodified, prettyprint,
    -- getDeclAndToks

-- * Typed AST traversals (added by CMB)
    -- * Miscellous
    -- ,removeFromInts, getDataName, checkTypes, getPNs, getPN, getPNPats, mapASTOverTAST

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

-- ---------------------------------------------------------------------

{-
-- |Find those declarations(function\/pattern binding and type signature) which define the specified PNames.
--incTypeSig indicates whether the corresponding type signature will be included.
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

------------------------------------------------------------------------------------

-- |Find the identifier(in PNT format) whose start position is (row,col) in the
-- file specified by the fileName, and returns defaultPNT if such an identifier does not exist.

-- TODO: ++AZ++ what is the fileName parameter actually for?
-- TODO: ++AZ++ does not seem to find PNTs if not at start of line/expression.
locToPNT::(SYB.Data t)=>FilePath  -- ^ The file name
                    ->(Int,Int)   -- ^ The row and column number
                    ->t           -- ^ The syntax phrase
                    ->PNT         -- ^ The result
-- TODO: return a Maybe, rather than encoding failure in defaultPNT
locToPNT  fileName (row, col) t
  = case res of
         Just x -> x
         Nothing -> defaultPNT
            -- =(fromMaybe defaultPNT). applyTU (once_buTU (failTU `adhocTU` worker))
       where
        res = somethingStaged SYB.Parser Nothing (Nothing `SYB.mkQ` worker) t

        -- worker (pnt@(GHC.L s (GHC.Unqual name)):: (GHC.Located (t1)))
        worker (pnt:: (GHC.Located GHC.RdrName))
              | inScope pnt = Just (PNT pnt)
              -- | True = Just defaultPNT
            -- |fileName1==fileName && (row1,col1) == (row,col) =Just pnt

        worker _ = Nothing

        -- TODO: check that the given point falls within the identifier
        inScope :: GHC.Located e -> Bool
        inScope (GHC.L l _) =
          let
            (startLoc,endLoc) = case l of
              (GHC.RealSrcSpan ss) ->
                ((GHC.srcSpanStartLine ss),
                 (GHC.srcSpanEndLine ss))
              (GHC.UnhelpfulSpan _) -> ((0),(0))
          in
           (startLoc==row) && (endLoc>= col)


------------------------------------------------------------------------------------
-- | From PNT to PName.
-- NOTE: the PNT holds the GHC.Name value, it must be converted to a GHC.RdrName
pNTtoPN :: PNT -> PName
pNTtoPN (PNT (GHC.L _ n)) = PN n

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
