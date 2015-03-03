{-# LANGUAGE StandaloneDeriving #-}
module Language.Haskell.Refact.Refactoring.Case(ifToCase) where

import qualified Data.Generics         as SYB
import qualified GHC.SYB.Utils         as SYB

import qualified BasicTypes    as GHC
import qualified GHC           as GHC

import Language.Haskell.GhcMod
import Language.Haskell.Refact.API

import Language.Haskell.Refact.Utils.MonadFunctions

-- To be moved into HaRe API
import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.Refact.Utils.ExactPrint

import qualified Data.Map as Map
import Debug.Trace

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
   putRefactParsed p2 Map.empty
   return ()
       where
         inExp :: (GHC.Located (GHC.HsExpr GHC.RdrName)) -> RefactGhc (GHC.Located (GHC.HsExpr GHC.RdrName))
         inExp exp1@(GHC.L _ (GHC.HsIf _se (GHC.L _ _) (GHC.L _ _) (GHC.L _ _)))
           | sameOccurrence expr exp1
           = do
               newExp <- ifToCaseTransform exp1
               return newExp

         inExp e = return e

deriving instance Eq Annotation

-- |Actually do the transformation
ifToCaseTransform :: GHC.Located (GHC.HsExpr GHC.RdrName)
                  -> RefactGhc (GHC.Located (GHC.HsExpr GHC.RdrName))
ifToCaseTransform e@(GHC.L l (GHC.HsIf _se e1 e2 e3)) = do
  caseLoc       <- uniqueSrcSpan
  trueMatchLoc  <- uniqueSrcSpan
  trueLoc1      <- uniqueSrcSpan
  trueLoc       <- uniqueSrcSpan
  trueRhsLoc    <- uniqueSrcSpan
  falseLoc1     <- uniqueSrcSpan
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
                   GHC.L trueLoc1 $ GHC.ConPatIn (GHC.L trueLoc trueName) (GHC.PrefixCon [])
                 ]
                 Nothing
                 (GHC.GRHSs
                   [
                     GHC.L trueRhsLoc $ GHC.GRHS [] e2
                   ] GHC.EmptyLocalBinds)
                )
              , (GHC.L falseMatchLoc $ GHC.Match
                 Nothing
                 [
                   GHC.L falseLoc1 $ GHC.ConPatIn (GHC.L falseLoc falseName) (GHC.PrefixCon [])
                 ]
                 Nothing
                 (GHC.GRHSs
                   [
                     GHC.L falseRhsLoc $ GHC.GRHS [] e3
                   ] GHC.EmptyLocalBinds)
                )
              ] [] GHC.placeHolderType GHC.FromSource))
  --(_ret2,anne) <- resequenceAnnotations ret
  -- logm $ "annGetConstr\n\n:" ++ show (annGetConstr trueName)

  let annf =  Map.union (Map.fromList $ map (\(k, v) -> (uncurry AnnKey k, annNone { anns = v}))
              [((caseLoc,     CN "HsCase"), [ (G GHC.AnnCase, DP (0,1))
                                            , (G GHC.AnnOf,   DP (0,1) )
                                            ])
              ,((trueLoc,     CN "Unqual"), [(G GHC.AnnVal,    DP (1,0))])
              ,((trueRhsLoc,  CN "GRHS"),   [(G GHC.AnnRarrow, DP (0,2))])
              ,((falseLoc,    CN "Unqual"), [(G GHC.AnnVal,    DP (1,0))])
              ,((falseRhsLoc, CN "GRHS"),   [(G GHC.AnnRarrow, DP (0,1))])
              ]) Map.empty
  -- logm $ "\n\n\n" ++ showGhc annf
  let anne2 = setOffsets annf [ ( AnnKey caseLoc       (CN "HsCase"),   (DP (0,1),LineSame, 9, 2) )
                              , ( AnnKey trueRhsLoc    (CN "GRHS"),     (DP (0,2),LineSame, 19, 6) )
                              , ( AnnKey trueMatchLoc  (CN "Match"),    (DP (1,4),LineChanged, 13, 13) )
                              , ( AnnKey trueLoc1      (CN "ConPatIn"), (DP (1,0),LineSame, 13, 0) )
                              , ( AnnKey trueLoc       (CN "Unqual"),   (DP (1,0),LineSame, 13, 0) )
                              , ( AnnKey falseRhsLoc   (CN "GRHS"),     (DP (0,2),LineSame, 19, 6) )
                              , ( AnnKey falseMatchLoc (CN "Match"),    (DP (1,4),LineChanged, 13, 13) )
                              , ( AnnKey falseLoc1     (CN "ConPatIn"), (DP (1,0),LineSame, 13, 0) )
                              , ( AnnKey falseLoc      (CN "Unqual"),   (DP (1,0),LineSame, 13, 0))
                              ]

  -- logm $ "\n\n\nanne2" ++ showGhc anne2

  oldAnns <- getRefactAnns
  let anne1 = Map.delete (AnnKey l (CN "HsIf")) oldAnns
      final = mergeAnns anne1 anne2
      anne3 = setLocatedOffsets final
                [ (e1, (DP (0,1),LineSame,14,5))
                , (e2, (DP (0,1),LineSame,22,3))
                , (e3, (DP (0,1),LineSame,22,3))
                ]
  -- let anne3 = setLocatedDp final e2 (DP (0,1)) 5
  -- let anne4 = setLocatedDp anne3 e3 (DP (0,1)) 0
  -- let anne5 = setLocatedDp anne4 e1 (DP (0,1)) 5
  -- let out = (setColRec (const 0) ret) . setColRec (const 0) e $ anne5
  -- logm $ "Case:fi=" ++ out
  -- logm $ "Case:anne5=" ++ showGhc anne3
  -- setRefactAnns out
  setRefactAnns anne3
  return ret
ifToCaseTransform x = return x

-- ---------------------------------------------------------------------


-- EOF



