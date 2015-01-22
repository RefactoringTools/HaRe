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
         _      -> error $ "You haven't selected an if-then-else  expression!" --  ++ (show (beginPos,endPos,fileName)) ++ "]:" ++ (SYB.showData SYB.Parser 0 $ ast)

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
         inExp exp1@(GHC.L l (GHC.HsIf _se (GHC.L l1 _) (GHC.L l2 _) (GHC.L l3 _)))
           | sameOccurrence expr exp1
           = do
               newExp <- ifToCaseTransform exp1
               return newExp

         inExp e = return e

-- TODO: rearrange the structure and preserve the comments in the
--       original, e.g. in e1,e2,e3
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
  -- let annf' = addAnnKeywords anne "HsCase"
  --               [(G GHC.AnnCase,[DP (1,0)])
  --               ,(G GHC.AnnOf,  [DP (0,1)])]
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

{-

foo x = case (odd x) of
            True  -> "Odd"
            False -> "Even"

becomes

(L {examples/B.hs:1:1} 
 (HsModule 
  (Nothing) 
  (Nothing) 
  [] 
  [
   (L {examples/B.hs:(2,1)-(4,27)} 
    (ValD 
     (FunBind 
      (L {examples/B.hs:2:1-3} 
       (Unqual {OccName: foo})) 
      (False) 
      (MG 
       [
        (L {examples/B.hs:(2,1)-(4,27)} 
         (Match 
          (Just 
           ((,) 
            (L {examples/B.hs:2:1-3} 
             (Unqual {OccName: foo})) 
            (False))) 
          [
           (L {examples/B.hs:2:5} 
            (VarPat 
             (Unqual {OccName: x})))] 
          (Nothing) 
          (GRHSs 
           [
            (L {examples/B.hs:2:7} 
             (GRHS 
              [] 
              (L {examples/B.hs:(2,9)-(4,27)} 
               (HsCase 
                (L {examples/B.hs:2:14-20} 
                 (HsPar 
                  (L {examples/B.hs:2:15-19} 
                   (HsApp 
                    (L {examples/B.hs:2:15-17} 
                     (HsVar 
                      (Unqual {OccName: odd}))) 
                    (L {examples/B.hs:2:19} 
                     (HsVar 
                      (Unqual {OccName: x}))))))) 
                (MG 
                 [
                  (L {examples/B.hs:3:13-26} 
                   (Match 
                    (Nothing) 
                    [
                     (L {examples/B.hs:3:13-16} 
                      (ConPatIn 
                       (L {examples/B.hs:3:13-16} 
                        (Unqual {OccName: True})) 
                       (PrefixCon 
                        [])))] 
                    (Nothing) 
                    (GRHSs 
                     [
                      (L {examples/B.hs:3:19-26} 
                       (GRHS 
                        [] 
                        (L {examples/B.hs:3:22-26} 
                         (HsLit 
                          (HsString "\"Odd\"" {FastString: "Odd"})))))] 
                     (EmptyLocalBinds)))),
                  (L {examples/B.hs:4:13-27} 
                   (Match 
                    (Nothing) 
                    [
                     (L {examples/B.hs:4:13-17} 
                      (ConPatIn 
                       (L {examples/B.hs:4:13-17} 
                        (Unqual {OccName: False})) 
                       (PrefixCon 
                        [])))] 
                    (Nothing) 
                    (GRHSs 
                     [
                      (L {examples/B.hs:4:19-27} 
                       (GRHS 
                        [] 
                        (L {examples/B.hs:4:22-27} 
                         (HsLit 
                          (HsString "\"Even\"" {FastString: "Even"})))))] 
                     (EmptyLocalBinds))))] 
                 [] 
                 (PlaceHolder) 
                 (FromSource))))))] 
           (EmptyLocalBinds))))] 
       [] 
       (PlaceHolder) 
       (FromSource)) 
      (WpHole) 
      (PlaceHolder) 
      [])))] 
  (Nothing) 
  (Nothing)))

with

ann=([((examples/B.hs:1:1, HsModule RdrName),
   Ann {ann_comments = [], ann_delta = DP (-4,1)}),
  ((examples/B.hs:2:1-3, RdrName),
   Ann {ann_comments = [], ann_delta = DP (0,-3)}),
  ((examples/B.hs:(2,1)-(4,27), HsDecl RdrName),
   Ann {ann_comments = [], ann_delta = DP (-2,1)}),
  ((examples/B.hs:(2,1)-(4,27),
    Match RdrName (GenLocated SrcSpan (HsExpr RdrName))),
   Ann {ann_comments = [], ann_delta = DP (-2,1)}),
  ((examples/B.hs:2:5, Pat RdrName),
   Ann {ann_comments = [], ann_delta = DP (0,-1)}),
  ((examples/B.hs:2:7,
    GRHS RdrName (GenLocated SrcSpan (HsExpr RdrName))),
   Ann {ann_comments = [], ann_delta = DP (-2,7)}),
  ((examples/B.hs:(2,9)-(4,27), HsExpr RdrName),
   Ann {ann_comments = [], ann_delta = DP (-2,9)}),
  ((examples/B.hs:2:14-20, HsExpr RdrName),
   Ann {ann_comments = [], ann_delta = DP (0,-7)}),
  ((examples/B.hs:2:15-17, HsExpr RdrName),
   Ann {ann_comments = [], ann_delta = DP (0,-3)}),
  ((examples/B.hs:2:15-19, HsExpr RdrName),
   Ann {ann_comments = [], ann_delta = DP (0,-5)}),
  ((examples/B.hs:2:19, HsExpr RdrName),
   Ann {ann_comments = [], ann_delta = DP (0,-1)}),
  ((examples/B.hs:3:13-16, Pat RdrName),
   Ann {ann_comments = [], ann_delta = DP (0,-4)}),
  ((examples/B.hs:3:13-16, RdrName),
   Ann {ann_comments = [], ann_delta = DP (0,-4)}),
  ((examples/B.hs:3:13-26,
    Match RdrName (GenLocated SrcSpan (HsExpr RdrName))),
   Ann {ann_comments = [], ann_delta = DP (0,-14)}),
  ((examples/B.hs:3:19-26,
    GRHS RdrName (GenLocated SrcSpan (HsExpr RdrName))),
   Ann {ann_comments = [], ann_delta = DP (0,-8)}),
  ((examples/B.hs:3:22-26, HsExpr RdrName),
   Ann {ann_comments = [], ann_delta = DP (0,-5)}),
  ((examples/B.hs:4:13-17, Pat RdrName),
   Ann {ann_comments = [], ann_delta = DP (0,-5)}),
  ((examples/B.hs:4:13-17, RdrName),
   Ann {ann_comments = [], ann_delta = DP (0,-5)}),
  ((examples/B.hs:4:13-27,
    Match RdrName (GenLocated SrcSpan (HsExpr RdrName))),
   Ann {ann_comments = [], ann_delta = DP (0,-15)}),
  ((examples/B.hs:4:19-27,
    GRHS RdrName (GenLocated SrcSpan (HsExpr RdrName))),
   Ann {ann_comments = [], ann_delta = DP (0,-9)}),
  ((examples/B.hs:4:22-27, HsExpr RdrName),
   Ann {ann_comments = [], ann_delta = DP (0,-6)}),
  ((<no location info>, ()),
   Ann {ann_comments = [], ann_delta = DP (0,0)})],
 [((examples/B.hs:1:1, G AnnEofPos), [DP (1,1)]),
  ((examples/B.hs:2:1-3, G AnnVal), [DP (1,1)]),
  ((examples/B.hs:(2,1)-(4,27), G AnnEqual), [DP (0,1)]),
  ((examples/B.hs:2:5, G AnnVal), [DP (0,1)]),
  ((examples/B.hs:(2,9)-(4,27), G AnnCase), [DP (0,1)]),
  ((examples/B.hs:(2,9)-(4,27), G AnnOf), [DP (0,1)]),
  ((examples/B.hs:2:14-20, G AnnCloseP), [DP (0,0)]),
  ((examples/B.hs:2:14-20, G AnnOpenP), [DP (0,1)]),
  ((examples/B.hs:2:15-17, G AnnVal), [DP (0,0)]),
  ((examples/B.hs:2:19, G AnnVal), [DP (0,1)]),
  ((examples/B.hs:3:13-16, G AnnVal), [DP (1,13)]),
  ((examples/B.hs:3:19-26, G AnnRarrow), [DP (0,2)]),
  ((examples/B.hs:3:22-26, G AnnVal), [DP (0,1)]),
  ((examples/B.hs:4:13-17, G AnnVal), [DP (1,13)]),
  ((examples/B.hs:4:19-27, G AnnRarrow), [DP (0,1)]),
  ((examples/B.hs:4:22-27, G AnnVal), [DP (0,1)])])



-}
-- ---------------------------------------------------------------------
{-
HsIf (Maybe (SyntaxExpr id)) (LHsExpr id) (LHsExpr id) (LHsExpr id)

[Can ignore The SyntaxExpr]


HsCase (LHsExpr id) (MatchGroup id)

-}

{-
Need to move to

(L {test/testdata/Case/B.hs:(9,10)-(11,17)} 
                 (HsCase 
                  (L {test/testdata/Case/B.hs:9:15-21} 
                   (HsPar 
                    (L {test/testdata/Case/B.hs:9:16-20} 
                     (HsApp 
                      (L {test/testdata/Case/B.hs:9:16-18} 
                       (HsVar {Name: GHC.Real.odd})) 
                      (L {test/testdata/Case/B.hs:9:20} 
                       (HsVar {Name: x})))))) 
                  (MatchGroup 
                   [
                    (L {test/testdata/Case/B.hs:10:3-15} 
                     (Match 
                      [
                       (L {test/testdata/Case/B.hs:10:3-6} 
                        (ConPatIn 
                         (L {test/testdata/Case/B.hs:10:3-6} {Name: GHC.Types.True}) 
                         (PrefixCon 
                          [])))] 
                      (Nothing) 
                      (GRHSs 
                       [
                        (L {test/testdata/Case/B.hs:10:11-15} 
                         (GRHS 
                          [] 
                          (L {test/testdata/Case/B.hs:10:11-15} 
                           (HsLit 
                            (HsString {FastString: "Odd"})))))] 
                       (EmptyLocalBinds)))),
                    (L {test/testdata/Case/B.hs:11:3-17} 
                     (Match 
                      [
                       (L {test/testdata/Case/B.hs:11:3-7} 
                        (ConPatIn 
                         (L {test/testdata/Case/B.hs:11:3-7} {Name: GHC.Types.False}) 
                         (PrefixCon 
                          [])))] 
                      (Nothing) 
                      (GRHSs 
                       [
                        (L {test/testdata/Case/B.hs:11:12-17} 
                         (GRHS 
                          [] 
                          (L {test/testdata/Case/B.hs:11:12-17} 
                           (HsLit 
                            (HsString {FastString: "Even"})))))] 
                       (EmptyLocalBinds))))] {!type placeholder here?!})))

from ---

(L {test/testdata/Case/B.hs:4:9-41} 
                 (HsIf 
                  (Nothing) 
                  (L {test/testdata/Case/B.hs:4:12-18} 
                   (HsPar 
                    (L {test/testdata/Case/B.hs:4:13-17} 
                     (HsApp 
                      (L {test/testdata/Case/B.hs:4:13-15} 
                       (HsVar {Name: GHC.Real.odd})) 
                      (L {test/testdata/Case/B.hs:4:17} 
                       (HsVar {Name: x})))))) 
                  (L {test/testdata/Case/B.hs:4:25-29} 
                   (HsLit 
                    (HsString {FastString: "Odd"}))) 
                  (L {test/testdata/Case/B.hs:4:36-41} 
                   (HsLit 
                    (HsString {FastString: "Even"})))))

-}

-- EOF



