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
import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.GHC.ExactPrint.Utils
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
       oldAnns <- getRefactAnns
       logm $ "Case.comp:parsed=" ++ (showAnnData oldAnns 0 parsed) -- ++AZ++
       let expr = locToExp beginPos endPos parsed
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

-- |Actually do the transformation
ifToCaseTransform :: GHC.Located (GHC.HsExpr GHC.RdrName)
                  -> RefactGhc (GHC.Located (GHC.HsExpr GHC.RdrName))
ifToCaseTransform li@(GHC.L l (GHC.HsIf _se e1 e2 e3)) = do
  caseLoc        <- uniqueSrcSpan -- HaRe:-1:1
  trueMatchLoc   <- uniqueSrcSpan -- HaRe:-1:2
  trueLoc1       <- uniqueSrcSpan -- HaRe:-1:3
  trueLoc        <- uniqueSrcSpan -- HaRe:-1:4
  trueRhsLoc     <- uniqueSrcSpan -- HaRe:-1:5
  falseLoc1      <- uniqueSrcSpan -- HaRe:-1:6
  falseLoc       <- uniqueSrcSpan -- HaRe:-1:7
  falseMatchLoc  <- uniqueSrcSpan -- HaRe:-1:8
  falseRhsLoc    <- uniqueSrcSpan -- HaRe:-1:9
  caseVirtualLoc <- uniqueSrcSpan -- HaRe:-1:10
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

  oldAnns <- getRefactAnns
  let annIf   = gfromJust "Case.annIf"   $ getAnnotationEP li oldAnns
  let annCond = gfromJust "Case.annCond" $ getAnnotationEP e1 oldAnns
  let annThen = gfromJust "Case.annThen" $ getAnnotationEP e2 oldAnns
  let annElse = gfromJust "Case.annElse" $ getAnnotationEP e3 oldAnns
  logm $ "Case:annIf="   ++ show annIf
  logm $ "Case:annThen=" ++ show annThen
  logm $ "Case:annElse=" ++ show annElse

  let ((_ifr,    ifc),  ifDP) = getOriginalPos oldAnns li (G GHC.AnnIf)
  let ((_thenr,thenc),thenDP) = getOriginalPos oldAnns li (G GHC.AnnThen)
  let ((_elser,elsec),elseDP) = getOriginalPos oldAnns li (G GHC.AnnElse)
  let newCol = ifc + 2

  -- AZ:TODO: under some circumstances the GRHS annotations need LineSame, in others LineChanged.
  let ifDelta     = gfromJust "Case.ifDelta"     $ lookup (G GHC.AnnIf) (annsDP annIf)
  let ifSpanEntry = gfromJust "Case.ifSpanEntry" $ lookup (AnnSpanEntry) (annsDP annIf)
  let anne2' =
        [ ( AnnKey caseLoc       (CN "HsCase"),   annIf { annsDP = [ (AnnSpanEntry,ifSpanEntry),(G GHC.AnnCase, ifDelta)
                                                                 , (G GHC.AnnOf,     DP (0,1))
                                                                 ,(AnnList caseVirtualLoc,DP (0,0))] } )
        , ( AnnKey caseVirtualLoc (CN "(:)"),     Ann (DP (1,newCol)) (ColDelta newCol)  [(AnnSpanEntry,DP (1,0))])
        , ( AnnKey trueMatchLoc  (CN "Match"),    Ann (DP (0,0)) 0 [] )
        , ( AnnKey trueLoc1      (CN "ConPatIn"), Ann (DP (0,0)) 0 [] )
        , ( AnnKey trueLoc       (CN "Unqual"),   Ann (DP (0,0)) 0 [(G GHC.AnnVal, DP (0,0))] )
        , ( AnnKey trueRhsLoc    (CN "GRHS"),     Ann (DP (0,2)) 6 [(AnnSpanEntry,DP (0,2)),(G GHC.AnnRarrow, DP (0,0))] )

        , ( AnnKey falseMatchLoc (CN "Match"),    Ann (DP (1,0)) 0  [(AnnSpanEntry,DP (1,0))] )
        , ( AnnKey falseLoc1     (CN "ConPatIn"), Ann (DP (0,0)) 0  [] )
        , ( AnnKey falseLoc      (CN "Unqual"),   Ann (DP (0,0)) 0  [ (G GHC.AnnVal, DP (0,0))] )
        , ( AnnKey falseRhsLoc   (CN "GRHS"),     Ann (DP (0,1)) 6  [(AnnSpanEntry,DP (0,1)),(G GHC.AnnRarrow, DP (0,0))] )
        ]

{- For falseRhsLoc we have
  nd = - (sc - oc) = - (17 - (c + 2))
     = - (17 - 2 - c)
     = c - 15
  oc = c + edc [because the line offset is 0]

-}
  -- logm $ "\n\n\nanne2" ++ showGhc anne2

  let anne1 = Map.delete (AnnKey l (CN "HsIf")) oldAnns
      final = mergeAnns anne1 (Map.fromList anne2')
      anne3 = setLocatedOffsets final
                [ (e1, annCond)
                , (e2, annThen)
                , (e3, annElse)
                ]
  setRefactAnns anne3
  return ret
ifToCaseTransform x = return x

-- ---------------------------------------------------------------------


-- EOF



