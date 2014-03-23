module Language.Haskell.Refact.API
 (
 -- * from `Language.Haskell.Refact.Utils.Monad`
         ParseResult
       , VerboseLevel(..)
       , RefactSettings(..)
       -- , RefactState(..)
       -- , RefactModule(..)
       , TargetModule
       -- , RefactStashId(..)
       , RefactFlags(..)
       , StateStorage(..)

       -- * The GHC Monad
       , RefactGhc
       , runRefactGhc
       , getRefacSettings
       , defaultSettings
       , logSettings
       , initGhcSession

       , loadModuleGraphGhc
       , ensureTargetLoaded
       , canonicalizeGraph

       , logm

 -- * from `Language.Haskell.Refact.Utils.MonadFunctions`

       -- * Conveniences for state access

       , fetchToksFinal
       , fetchLinesFinal
       , fetchOrigToks
       , fetchToks -- Deprecated
       -- , putToks -- ^Deprecated, destroys token tree
       , getTypecheckedModule
       , getRefactStreamModified
       , getRefactInscopes
       , getRefactRenamed
       , putRefactRenamed
       , getRefactParsed
       , putParsedModule
       , clearParsedModule
       , getRefactFileName

       -- * TokenUtils API
       , replaceToken
       , putToksForSpan
       , putDeclToksForSpan
       , getToksForSpan
       , getToksForSpanNoInv
       , getToksForSpanWithIntros
       , getToksBeforeSpan
       , putToksForPos
       , putToksAfterSpan
       , putToksAfterPos
       , putDeclToksAfterSpan
       , removeToksForSpan
       , removeToksForPos
       , syncDeclToLatestStash
       , indentDeclAndToks

       -- * LayoutUtils API
       -- , getLayoutForSpan
       -- , putDeclLayoutAfterSpan

       -- * For debugging
       , drawTokenTree
       , drawTokenTreeDetailed
       , getTokenTree
       -- , showPprDebug
       , showLinesDebug

       -- * State flags for managing generic traversals
       , getRefactDone
       , setRefactDone
       , clearRefactDone

       , setStateStorage
       , getStateStorage

       -- , logm

       , updateToks
       , updateToksWithPos

       -- * For use by the tests only
       , initRefactModule

 -- * from `Language.Haskell.Refact.Utils.LocUtils`

                     {-
                     module HsTokens,
                     PosToken,simpPos,
                     -}
                     , SimpPos,unmodified,modified
                     , simpPos0
                     , nullSrcSpan
                     -- , emptyList, nonEmptyList
                     , showToks
                     -- , tokenLen
                     -- ,lengthOfToks
                     -- , mkToken, mkZeroToken {-,defaultToken, -}
                     {-whiteSpacesToken -}
                     , whiteSpaceTokens
                     , realSrcLocFromTok
                     , isWhite
                     , notWhite
                     , isWhiteSpace
                     , isWhiteSpaceOrIgnored
                     , isIgnored
                     , isIgnoredNonComment
                     {-
                     ,isNewLn,isCommentStart -},isComment {-,
                     isNestedComment-},isMultiLineComment {-,isOpenBracket,isCloseBracket, -}
                     ,isOpenSquareBracket,isCloseSquareBracket {- ,isOpenBrace,isConid,
                     isLit,isWhereOrLet,isWhere,isLet-},isIn {- ,isCase,isDo,isIf,isForall,
                     isHiding,isModule-} ,isComma {-,isEqual,isLambda,isIrrefute -},isBar --,isMinus,
                     ,endsWithNewLn,startsWithNewLn,hasNewLn {- ,startsWithEmptyLn,
                     lastNonSpaceToken,firstNonSpaceToken -} ,compressPreNewLns,compressEndNewLns

                     , lengthOfLastLine
                     , getToks
                     -- , replaceToks,replaceTok
                     ,replaceTokNoReAlign,deleteToks,doRmWhites -- ,doAddWhites
                     , srcLocs
                     , getSrcSpan, getAllSrcLocs
                     -- , ghcSrcLocs -- Test version
                     -- , getLocatedStart
                     -- , getLocatedEnd
                     , getBiggestStartEndLoc
                     {-
                     , getStartEndLoc2,
                     startEndLoc,extendBothSides -},extendForwards,extendBackwards
                     , startEndLocIncFowComment{- ,startEndLocIncFowNewLn -}
                     , startEndLocIncComments, startEndLocIncComments'
                     {-,
                     prettyprint ,deleteFromToks, prettyprintGuardsAlt,
                     -}
                     , tokenise
                     , basicTokenise
                     , lexStringToRichTokens
                     , prettyprint -- , prettyprintGhc
                     , prettyprintPatList
                     , groupTokensByLine
                     , toksOnSameLine
                     , addLocInfo
                     -- , getIndentOffset
                     , getLineOffset
                     -- , splitToks
                     -- , splitOnNewLn
                     {-
                     , insertComments,
                     extractComments, insertTerms
                     -}
                     , tokenCol
                     , tokenColEnd
                     , tokenRow
                     , tokenPos
                     , tokenPosEnd
                     , tokenSrcSpan
                     , tokenCon
                     , increaseSrcSpan
                     , getGhcLoc
                     , getGhcLocEnd
                     , getLocatedStart
                     , getLocatedEnd
                     , getStartEndLoc
                     , startEndLocGhc
                     , realSrcLocEndTok
                     , fileNameFromTok
                     , splitToks
                     , emptyList, nonEmptyList
                     , divideComments
                     , notWhiteSpace
                     , isDoubleColon
                     , isEmpty
                     , isWhereOrLet
                     , isWhere
                     , isLet
                     , isElse
                     , isThen
                     , isOf
                     , isDo
                     , getIndentOffset
                     , splitOnNewLn
                     , tokenLen
                     , newLnToken
                     , newLinesToken
                     , monotonicLineToks
                     , reSequenceToks
                     , mkToken
                     , mkZeroToken
                     , markToken
                     , isMarked
                     , addOffsetToToks
                     , matchTokenPos
                     , rmOffsetFromToks


 ) where

import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.LocUtils

