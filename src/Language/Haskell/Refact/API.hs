-- | This module should provide all that is required to write further
-- refactorings.
-- NOTE: it is currently unstable, and may change without notice on minor version number bumps
module Language.Haskell.Refact.API
 (
 -- * from `Language.Haskell.Refact.Utils.Monad`
         ParseResult
       , VerboseLevel(..)
       , RefactSettings(..)
       , TargetModule
       , RefactFlags(..)
       , StateStorage(..)

       -- ** The GHC Monad
       , RefactGhc
       , runRefactGhc
       , getRefacSettings
       , defaultSettings
       , logSettings

       , logm
       , logDataWithAnns
       , logExactprint
       , logParsedSource

 -- * from `Language.Haskell.Refact.Utils.Utils`

       -- ** Managing the GHC / project environment
       , parseSourceFileGhc
       , getTargetGhc

       -- ** The bits that do the work
       , runRefacSession
       , applyRefac
       , refactDone
       , ApplyRefacResult
       , RefacSource(..)

       , nameSybQuery
       , fileNameFromModSummary
       , getModuleName
       , clientModsAndFiles
       , serverModsAndFiles


 -- * from `Language.Haskell.Refact.Utils.MonadFunctions`

       -- ** Conveniences for state access

       , getTypecheckedModule
       , RefacResult(..)
       , getRefactStreamModified
       , setRefactStreamModified
       , getRefactInscopes
       , getRefactRenamed
       , putRefactRenamed
       , getRefactParsed
       , putRefactParsed
       , putParsedModule
       , clearParsedModule
       , getRefactFileName
       , getRefactTargetModule
       , getRefactNameMap

       , getRefactModule
       , getRefactModuleName

       -- * New ghc-exactprint interfacing
       -- , refactRunTransform
       , liftT

       -- ** State flags for managing generic traversals
       , getRefactDone
       , setRefactDone
       , clearRefactDone

       , setStateStorage
       , getStateStorage

       -- * Parsing source
       , parseDeclWithAnns

       -- , logm


 -- * from `Language.Haskell.Refact.Utils.LocUtils`

                     , SimpPos

                     , getGhcLoc
                     , getGhcLocEnd
                     , getLocatedStart
                     , getLocatedEnd
                     , getStartEndLoc
                     , startEndLocGhc
                     , emptyList, nonEmptyList

 -- * from `Language.Haskell.Refact.Utils.TypeSyn`
    , InScopes
    , ghead
    , glast
    , gtail
    , gfromJust

 -- * from `Language.Haskell.Refact.Utils.TypeUtils`

 -- ** Program Analysis
    -- ** Imports and exports
   , inScopeInfo, isInScopeAndUnqualified, isInScopeAndUnqualifiedGhc, inScopeNames
   , isExported, isExplicitlyExported, modIsExported
   , equivalentNameInNewMod
   , hsQualifier

    -- *** Variable analysis
    , isFieldName
    , isClassName
    , isInstanceName
    , hsTypeVbls
    , hsPNs, hsNamess, hsNamessRdr
    , hsBinds
    , HsValBinds(..)
    ,isDeclaredIn,isDeclaredInRdr
    ,FreeNames(..),DeclaredNames(..)
    ,hsFreeAndDeclaredPNsOld, hsFreeAndDeclaredNameStrings
    ,hsFreeAndDeclaredRdr
    ,hsFreeAndDeclaredPNs
    ,hsFreeAndDeclaredGhc
    ,getDeclaredTypes
    ,getFvs, getFreeVars, getDeclaredVars -- These two should replace hsFreeAndDeclaredPNs

    ,hsVisiblePNs, hsVisiblePNsRdr, hsVisibleNames
    ,hsVisibleNamesRdr
    ,hsFDsFromInsideRdr, hsFDNamesFromInsideRdr, hsFDNamesFromInsideRdrPure
    ,hsFDsFromInside, hsFDNamesFromInside
    ,hsVisibleDs
    ,rdrName2Name, rdrName2NamePure

    -- *** Property checking
    ,isVarId,isConId,isOperator,isTopLevelPN,isLocalPN,isNonLibraryName -- ,isTopLevelPNT
    ,isQualifiedPN, isFunOrPatName,isTypeSig
    ,isFunBindP,isFunBindR,isPatBindP,isPatBindR,isSimplePatBind,isSimplePatDecl
    ,isComplexPatBind,isComplexPatDecl,isFunOrPatBindP,isFunOrPatBindR
    ,usedWithoutQualR,isUsedInRhs
    ,findNameInRdr
    ,findPNT,findPN,findAllNameOccurences
    ,findPNs, findNamesRdr, findEntity, findEntity'
    ,sameOccurrence
    , findIdForName
    , getTypeForName
    , definesTypeSig,definesTypeSigRdr,definesSigDRdr
    ,sameBind,sameBindRdr
    ,UsedByRhs(..)

    -- *** Modules and files
    , isMainModule
    , getModule

    -- *** Locations
    ,defineLoc, useLoc, locToExp
    ,findLRdrName
    ,locToName, locToRdrName
    ,getName

 -- * Program transformation
    -- *** Adding
    ,addDecl, addItemsToImport, addItemsToExport, addHiding
    ,addParamsToDecls, addParamsToSigs, addActualParamsToRhs, addImportDecl, duplicateDecl

    -- *** Removing
    ,rmDecl, rmTypeSig, rmTypeSigs

    -- *** Updating
    -- ,Update(update)
    ,rmQualifier,qualifyToplevelName,renamePN,autoRenameLocalVar

    -- *** Identifiers, expressions, patterns and declarations
    ,ghcToPN,lghcToPN, expToName, expToNameRdr
    ,patToNameRdr
    ,nameToString
    ,patToPNT ,pNtoPat
    , definedPNs, definedPNsRdr,definedNamesRdr
    , definingDeclsRdrNames, definingDeclsRdrNames', definingSigsRdrNames
    , definingDeclsNames, definingDeclsNames', definingSigsNames
    , definingTyClDeclsNames
    , allNames

    -- *** Others
    , divideDecls
    , mkRdrName,mkQualifiedRdrName,mkNewGhcName,mkNewName,mkNewToplevelName
    , registerRdrName

    -- The following functions are not in the the API yet.
    , causeNameClashInExports

    , declsSybTransform

    -- ** Typed AST traversals (added by CMB)
    -- ** Miscellous

    -- ** Debug stuff
    , getParsedForRenamedLPat
    , getParsedForRenamedName
    , getParsedForRenamedLocated
    , stripLeadingSpaces

 -- ** from `Language.Haskell.Refact.Utils.GhcUtils`
    -- ** SYB versions
    , everywhereMStaged'
    , everywhereStaged
    , everywhereStaged'
    , onelayerStaged
    , listifyStaged

    -- ** Scrap Your Zipper versions
    , zeverywhereStaged
    , zopenStaged
    , zsomewhereStaged
    , transZ
    , transZM
    , zopenStaged'
    , ztransformStagedM
    -- *** SYZ utilities
    , upUntil
    , findAbove

 -- * from `Language.Haskell.Refact.Utils.GhcVersionSpecific`
  , showGhc
  , showGhcQual
  , prettyprint
  , prettyprint2
  , ppType
  , setGhcContext

 -- * from `Language.Haskell.Refact.Utils.TokenUtils`
  , NameMap

 -- * from `Language.Haskell.Refact.Utils.ExactPrint'`
  , replace
  , setRefactAnns
  , setAnnKeywordDP
  , copyAnn
  , clearPriorComments
  , balanceAllComments

 ) where

import Language.Haskell.Refact.Utils.Binds
import Language.Haskell.Refact.Utils.ExactPrint
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils
import Language.Haskell.Refact.Utils.Types
import Language.Haskell.Refact.Utils.Utils
import Language.Haskell.Refact.Utils.Variables

import Language.Haskell.GHC.ExactPrint.Utils

