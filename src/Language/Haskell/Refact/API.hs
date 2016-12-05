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
       , logAst
 -- * from `Language.Haskell.Refact.Utils.Utils`

       -- ** Managing the GHC / project environment
       , parseSourceFileGhc
       , getTargetGhc

       -- ** The bits that do the work
       , runRefacSession
       , runMultRefacSession
       , applyRefac
       , applyRefac'
       , refactDone
       , ApplyRefacResult
       , RefacSource(..)

       , nameSybQuery
       , fileNameFromModSummary
       , getModuleName
       , clientModsAndFiles
       , serverModsAndFiles
       , lookupAnns  

       , stripCallStack


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
       , fetchAnnsFinal

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
                     , emptyList
                     , nonEmptyList


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
    , hsNamessRdr
    , isDeclaredInRdr
    , FreeNames(..),DeclaredNames(..)
    , hsFreeAndDeclaredNameStrings
    , hsFreeAndDeclaredRdr
    , hsFreeAndDeclaredPNs
    , getDeclaredVarsRdr

    , hsVisibleNamesRdr
    , hsFDsFromInsideRdr, hsFDNamesFromInsideRdr, hsFDNamesFromInsideRdrPure
    , hsVisibleDsRdr
    , rdrName2Name, rdrName2NamePure
    , eqRdrNamePure
    , sameNameSpace

    -- *** Property checking
    ,isVarId,isConId,isOperator,isTopLevelPN,isLocalPN,isNonLibraryName -- ,isTopLevelPNT
    ,isQualifiedPN, isFunOrPatName,isTypeSig
    ,isFunBindP,isFunBindR,isPatBindP,isPatBindR,isSimplePatBind,isSimplePatDecl
    ,isComplexPatBind,isComplexPatDecl,isFunOrPatBindP,isFunOrPatBindR
    ,usedWithoutQualR
    ,findNameInRdr
    ,findNamesRdr, findEntity, findEntity'
    ,sameOccurrence
    , findIdForName
    , getTypeForName
    , definesTypeSigRdr,definesSigDRdr
    , sameBindRdr
    , UsedByRhs(..)

    -- *** Modules and files
    , isMainModule
    , getModule

    -- *** Locations
    ,defineLoc, useLoc, locToExp
    ,findLRdrName
    ,locToNameRdr
    ,locToNameRdrPure
    ,locToRdrName
    ,getName

 -- * Program transformation
    -- *** Adding
    ,addDecl, addItemsToImport, addItemsToExport, addHiding
    ,addParamsToDecls, addParamsToSigs, addActualParamsToRhs, addImportDecl, duplicateDecl

    -- *** Removing
    ,rmDecl, rmTypeSig, rmTypeSigs

    -- *** Updating
    -- ,Update(update)
    ,rmQualifier,qualifyToplevelName,renamePN, HowToQual(..), autoRenameLocalVar

    -- *** Identifiers, expressions, patterns and declarations
    , expToNameRdr
    , patToNameRdr
    , nameToString
    , pNtoPat
    , definedPNsRdr,definedNamesRdr
    , definingDeclsRdrNames, definingDeclsRdrNames', definingSigsRdrNames
    , definingTyClDeclsNames

    -- *** Others
    , divideDecls
    , mkRdrName,mkQualifiedRdrName,mkNewGhcName,mkNewName,mkNewToplevelName
    , registerRdrName

    -- The following functions are not in the the API yet.
    , causeNameClashInExports

    , declsSybTransform

    -- ** Typed AST traversals (added by CMB)
    -- ** Miscellous

 -- ** from `Language.Haskell.Refact.Utils.GhcUtils`
    -- ** SYB versions
    , everywhereMStaged'
    , everywhereStaged
    , everywhereStaged'
    , listifyStaged
    , everywhereButMStaged

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

  , exactPrintParsed
  , exactPrintExpr
  , zeroDP
  , setDP
  , handleParseResult
  , getAllAnns
  , removeAnns
  , synthesizeAnns
  , addNewKeyword
  , addNewKeywords

  , addEmptyAnn
  , addAnnVal
  , addAnn

   -- from Language.Haskell.Refact.Utils.Synonyms
 , UnlocParsedHsBind
 , ParsedGRHSs
 , ParsedMatchGroup
 , ParsedLMatch
 , ParsedExpr
 , ParsedLStmt
 , ParsedLExpr
 , ParsedBind

 -- from Language.Haskell.Refact.Utils.Transform
  , addSimpleImportDecl
  , wrapInLambda
  , wrapInPars
  , addNewLines
  , wrapInParsWithDPs
  , locate
-- from Language.Haskell.Refact.Utils.Query
  , getVarAndRHS
  , getHsBind
  , isHsVar
 ) where

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
import Language.Haskell.Refact.Utils.Transform
import Language.Haskell.GHC.ExactPrint.Utils
import Language.Haskell.Refact.Utils.Synonyms
import Language.Haskell.Refact.Utils.Query
