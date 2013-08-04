module Language.Haskell.Refact.Case(ifToCase) where

import qualified Data.Generics         as SYB
import qualified GHC.SYB.Utils         as SYB


import qualified GHC

import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TypeUtils

-- ---------------------------------------------------------------------

-- | The API entry point
ifToCase :: Maybe RefactSettings -> Maybe FilePath -> FilePath -> SimpPos -> SimpPos -> IO [FilePath]
ifToCase settings maybeMainFile fileName beginPos endPos =
  runRefacSession settings maybeMainFile (comp fileName beginPos endPos)

comp :: FilePath -> SimpPos -> SimpPos -> RefactGhc [ApplyRefacResult]
comp fileName beginPos endPos = do
       getModuleGhc fileName
       renamed <- getRefactRenamed
       let expr = locToExp beginPos endPos renamed
       case expr of
         Just exp1@(GHC.L _ (GHC.HsIf _ _ _ _))
                -> do (refactoredMod,_) <- applyRefac (doIfToCaseInternal exp1) RSAlreadyLoaded
                      return [refactoredMod]
         _      -> error $ "You haven't selected an if-then-else  expression!" --  ++ (show (beginPos,endPos,fileName)) ++ "]:" ++ (SYB.showData SYB.Parser 0 $ ast)

doIfToCaseInternal ::
  GHC.Located (GHC.HsExpr GHC.Name)
  -> RefactGhc ()
doIfToCaseInternal expr = do
  rs <- getRefactRenamed
  reallyDoIfToCase expr rs

reallyDoIfToCase ::
  GHC.Located (GHC.HsExpr GHC.Name)
  -> GHC.RenamedSource
  -> RefactGhc ()
reallyDoIfToCase expr rs = do

   everywhereMStaged SYB.Renamer (SYB.mkM inExp) rs
   return ()
       where
         inExp :: (GHC.Located (GHC.HsExpr GHC.Name)) -> RefactGhc (GHC.Located (GHC.HsExpr GHC.Name))

         inExp exp1@(GHC.L _ (GHC.HsIf _ _ _ _))
           | sameOccurrence expr exp1
           = do
               newExp <- ifToCaseTransform exp1
               updateToks exp1 newExp prettyprint True
               return newExp

         inExp e = return e

-- TODO: rearrange the structure and preserve the comments in the original, e.g. in e1,e2,e3
ifToCaseTransform :: GHC.Located (GHC.HsExpr GHC.Name) -> RefactGhc (GHC.Located (GHC.HsExpr GHC.Name))
ifToCaseTransform (GHC.L l (GHC.HsIf _se e1 e2 e3)) = do
  trueName  <- mkNewGhcName Nothing "True"
  falseName <- mkNewGhcName Nothing "False"
  let ret = GHC.L l (GHC.HsCase e1
             (GHC.MatchGroup
              [
                (GHC.noLoc $ GHC.Match
                 [
                   GHC.noLoc $ GHC.ConPatIn (GHC.noLoc trueName) (GHC.PrefixCon [])
                 ]
                 Nothing
                 ((GHC.GRHSs
                   [
                     GHC.noLoc $ GHC.GRHS [] e2
                   ] GHC.EmptyLocalBinds))
                )
              , (GHC.noLoc $ GHC.Match
                 [
                   GHC.noLoc $ GHC.ConPatIn (GHC.noLoc falseName) (GHC.PrefixCon [])
                 ]
                 Nothing
                 ((GHC.GRHSs
                   [
                     GHC.noLoc $ GHC.GRHS [] e3
                   ] GHC.EmptyLocalBinds))
                )
              ] undefined))
  return ret
ifToCaseTransform x = return x

-- ---------------------------------------------------------------------

-- EOF



