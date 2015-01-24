module Language.Haskell.Refact.Refactoring.Case(ifToCase) where

import qualified Data.Generics         as SYB
import qualified GHC.SYB.Utils         as SYB

import qualified BasicTypes    as GHC
import qualified GHC           as GHC

import Language.Haskell.GhcMod
import Language.Haskell.Refact.API

-- To be moved into HaRe API
import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.Refact.Utils.ExactPrint

import qualified Data.Map as Map

-- ---------------------------------------------------------------------

-- | Convert an if expression to a case expression
ifToCase :: RefactSettings -> Options -> FilePath -> SimpPos -> SimpPos -> IO [FilePath]
ifToCase settings opts fileName beginPos endPos =
  runRefacSession settings opts (comp fileName beginPos endPos)

comp :: FilePath -> SimpPos -> SimpPos -> RefactGhc [ApplyRefacResult]
comp fileName beginPos endPos = do
       getModuleGhc fileName
       parsed <- getRefactParsed
       logm $ "Case.comp:parsed=" ++ (SYB.showData SYB.Parser 0 parsed) -- ++AZ++
       let expr = locToExp beginPos endPos parsed
       -- logm $ "Case.comp:expr=" ++ (SYB.showData SYB.Renamer 0 expr) -- ++AZ++
       case expr of
         Just exp1@(GHC.L _ (GHC.HsIf _ _ _ _))
                -> do (refactoredMod,_) <- applyRefac (doIfToCaseInternal exp1) RSAlreadyLoaded
                      return [refactoredMod]
         _      -> error $ "You haven't selected an if-then-else  expression!" -- (show (beginPos,endPos,fileName)) ++ "]:" ++ (SYB.showData SYB.Parser 0 $ ast)

doIfToCaseInternal ::
  GHC.Located (GHC.HsExpr GHC.RdrName)
  -> RefactGhc ()
doIfToCaseInternal expr = do
  rs <- getRefactParsed
  reallyDoIfToCase expr rs

reallyDoIfToCase ::
  GHC.Located (GHC.HsExpr GHC.RdrName)
  -> GHC.ParsedSource
  -> RefactGhc ()
reallyDoIfToCase expr p = do

   p2 <- SYB.everywhereMStaged SYB.Parser (SYB.mkM inExp) p
   -- logm $ "reallyDoIfToCase:p2=" ++ (SYB.showData SYB.Parser 0 p2)
   putRefactParsed p2 (Map.empty,Map.empty)
   return ()
       where
         inExp :: (GHC.Located (GHC.HsExpr GHC.RdrName)) -> RefactGhc (GHC.Located (GHC.HsExpr GHC.RdrName))
         inExp exp1@(GHC.L _ (GHC.HsIf _se (GHC.L _ _) (GHC.L _ _) (GHC.L _ _)))
           | sameOccurrence expr exp1
           = do
               newExp <- ifToCaseTransform exp1
               return newExp

         inExp e = return e

-- |Actually do the transformation
ifToCaseTransform :: GHC.Located (GHC.HsExpr GHC.RdrName)
                  -> RefactGhc (GHC.Located (GHC.HsExpr GHC.RdrName))
ifToCaseTransform (GHC.L _ (GHC.HsIf _se e1 e2 e3)) = do
  caseLoc       <- uniqueSrcSpan
  trueMatchLoc  <- uniqueSrcSpan
  trueLoc       <- uniqueSrcSpan
  trueRhsLoc    <- uniqueSrcSpan
  falseLoc      <- uniqueSrcSpan
  falseMatchLoc <- uniqueSrcSpan
  falseRhsLoc   <- uniqueSrcSpan
  let trueName  = mkRdrName "True"
  let falseName = mkRdrName "False"
  let ret = GHC.L caseLoc (GHC.HsCase e1
             (GHC.MG
              [
                (GHC.L trueMatchLoc $ GHC.Match
                 Nothing
                 [
                   GHC.L trueLoc $ GHC.ConPatIn (GHC.L trueLoc trueName) (GHC.PrefixCon [])
                 ]
                 Nothing
                 ((GHC.GRHSs
                   [
                     GHC.L trueRhsLoc $ GHC.GRHS [] e2
                   ] GHC.EmptyLocalBinds))
                )
              , (GHC.L falseMatchLoc $ GHC.Match
                 Nothing
                 [
                   GHC.noLoc $ GHC.ConPatIn (GHC.L falseLoc falseName) (GHC.PrefixCon [])
                 ]
                 Nothing
                 ((GHC.GRHSs
                   [
                     GHC.L falseRhsLoc $ GHC.GRHS [] e3
                   ] GHC.EmptyLocalBinds))
                )
              ] [] GHC.placeHolderType GHC.Generated))
  (_ret2,anne) <- resequenceAnnotations ret
  let anne2 = setOffsets anne [ ( (caseLoc,CN "HsCase"), (DP (1,2)) )
                              , ( (trueRhsLoc,  CN "GRHS"),  (DP (0,6)) )
                              , ( (trueMatchLoc,CN "Match"), (DP (1,4)) )
                              , ( (falseRhsLoc,  CN "GRHS"),  (DP (0,6)) )
                              , ( (falseMatchLoc,CN "Match"), (DP (1,4)) )
                              ]
  let anne3 = setLocatedDp anne2 e2 (DP (0,3))
  let anne4 = setLocatedDp anne3 e3 (DP (0,3))
  let annf = Map.fromList [((caseLoc,     G GHC.AnnCase),   [DP (1,0)])
                          ,((caseLoc,     G GHC.AnnOf),     [DP (0,1)])
                          ,((trueLoc,     G GHC.AnnVal),    [DP (1,0)])
                          ,((trueRhsLoc,  G GHC.AnnRarrow), [DP (0,2)])
                          ,((falseLoc,    G GHC.AnnVal),    [DP (1,0)])
                          ,((falseRhsLoc, G GHC.AnnRarrow), [DP (0,1)])
                          ]
  logm $ "Case:anns=" ++ showGhc (anne2,annf)
  addRefactAnns (anne4,annf)
  return ret
ifToCaseTransform x = return x

-- ---------------------------------------------------------------------


-- EOF



