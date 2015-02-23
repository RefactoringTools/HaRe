{-# LANGUAGE ScopedTypeVariables,TemplateHaskell #-}
module Language.Haskell.Refact.Refactoring.SimplifyArithmetic where

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB
import BasicTypes
import qualified GHC 
import Control.Monad
import Control.Monad.State
import Language.Haskell.GhcMod
import Language.Haskell.Refact.API
import Data.Generics.Strafunski.StrategyLib.StrategyLib

simplifyArithmetic :: RefactSettings -> Cradle -> FilePath -> IO [FilePath]
simplifyArithmetic settings cradle fileName = runRefacSession settings cradle (comp fileName)

comp :: FilePath -> RefactGhc [ApplyRefacResult]
comp fileName = do
   getModuleGhc fileName
   renamed <- getRefactRenamed
   parsed <- getRefactParsed
   m <- getModule
   let (Just (modName,_)) = getModuleName parsed
   (refactoredMod@((_fp,ismod),(_,_toks',renamed')),_) <- applyRefac (doSimplify) RSAlreadyLoaded
   return []

doSimplify :: RefactGhc ()
doSimplify = do
   renamed <- getRefactRenamed
   res <- everywhereMStaged' (SYB.Renamer) (SYB.mkM simpAdd) renamed
   --res <- applyTP (full_buTP simpAdd) renamed-- `adhocTP` simpMul))
   return ()

simpAdd exp = return ()
