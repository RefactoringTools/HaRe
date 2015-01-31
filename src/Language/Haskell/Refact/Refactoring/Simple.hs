{-# LANGUAGE PatternSynonyms #-}
module Language.Haskell.Refact.Refactoring.Simple(removeBracket) where

import qualified Data.Generics         as SYB
import qualified GHC.SYB.Utils         as SYB

import qualified BasicTypes    as GHC
import qualified GHC           as GHC

import Language.Haskell.GhcMod
import Language.Haskell.Refact.API

-- To be moved into HaRe API
import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.Refact.Utils.ExactPrint
import Language.Haskell.Refact.Utils.TypeUtils

import qualified Data.Map as Map
import Control.Applicative
import Data.Maybe
import Debug.Trace

-- ---------------------------------------------------------------------

-- | Convert an if expression to a case expression
removeBracket :: RefactSettings -> Options -> FilePath -> SimpPos -> SimpPos -> IO [FilePath]
removeBracket settings opts fileName beginPos endPos =
  let applied = (:[]) . fst <$> applyRefac
                  (getModuleGhc fileName
                   >> removeBracketTransform fileName beginPos endPos)
                  (RSFile fileName) in
  runRefacSession settings opts applied

type HsExpr a = GHC.Located (GHC.HsExpr a)
pattern HsPar l s = GHC.L l (GHC.HsPar s)

removeBracketTransform  :: FilePath -> SimpPos -> SimpPos -> RefactGhc ()
removeBracketTransform fileName beginPos endPos = do
       getModuleGhc fileName
       parsed <- getRefactParsed
       let expr :: GHC.Located (GHC.HsExpr GHC.RdrName)
           expr = fromJust $ locToExp beginPos endPos parsed
           removePar :: (HsExpr GHC.RdrName -> HsExpr GHC.RdrName) -> HsExpr GHC.RdrName -> HsExpr GHC.RdrName
           removePar k e@(HsPar l s)
            | sameOccurrence e expr = s
           removePar k e = k e
           transform :: (HsExpr GHC.RdrName) -> RefactGhc (HsExpr GHC.RdrName)
           transform = return . removePar id
       p2 <- SYB.everywhereMStaged SYB.Parser (SYB.mkM transform) parsed
       putRefactParsed p2 (Map.empty,Map.empty)
       logm $ showGhc p2
       return ()
