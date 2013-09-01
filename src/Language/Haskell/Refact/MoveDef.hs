{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}

module Language.Haskell.Refact.MoveDef
  ( liftToTopLevel
  , liftOneLevel
  , demote
  -- ,liftingInClientMod
  ) where

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

-- import qualified Bag                   as GHC
import qualified Exception             as GHC
import qualified FastString            as GHC
import qualified GHC
import qualified Name                  as GHC
-- import qualified OccName               as GHC
-- import qualified Outputable            as GHC

import Control.Exception
import Control.Monad.State
import qualified Data.Generics.Zipper as Z
import Data.List
import Data.Maybe

import Language.Haskell.GhcMod
import Language.Haskell.GhcMod.Internal
import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

import Data.Generics.Strafunski.StrategyLib.StrategyLib

-- import Debug.Trace

-- ---------------------------------------------------------------------

data Direction = UptoTopLevel | UpOneLevel | Down

{--------This function handles refactorings involving moving a definition--------

 According to the Haskell's syntax, a declaration may occur in one of
the following six contexts:

  1. A top level declaration in the module:
        old: HsModule SrcLoc ModuleName (Maybe [HsExportSpecI i]) [HsImportDeclI i] ds
        new: (HsGroup Name, [LImportDecl Name], Maybe [LIE Name], Maybe LHsDocString)
              HsGroup hs_valds :: HsValBinds id ...

  2. A local declaration in a Match: (of a FunBind)
        old: HsMatch SrcLoc i [p] (HsRhs e) ds
        new: Match [LPat id] (Maybe (LHsType id)) (GRHSs id)

  3. A local declaration in a pattern binding:
        old: HsPatBind SrcLoc p (HsRhs e) ds
        new: PatBind (LPat idL) (GRHSs idR) PostTcType NameSet (Maybe tickish)

  4. A local declaration in a Let expression:
        old: HsLet ds e
        new: HsLet (HsLocalBinds id) (LHsExpr id)

  5. A local declaration in a Case alternative:
        old: HsAlt SrcLoc p (HsRhs e) ds
        new: HsCase (LHsExpr id) (MatchGroup id)
           new is same as in a FunBind.

  6. A local declaration in a Do statement:
        old: HsLetStmt ds (HsStmt e p ds)
        new: LetStmt (HsLocalBindsLR idL idR)
             in context GRHS [LStmt id] (LHsExpr id)
-}

-- | Lift a definition to the top level
liftToTopLevel :: RefactSettings -> Cradle -> FilePath -> SimpPos -> IO [FilePath]
liftToTopLevel settings cradle fileName (row,col) =
  runRefacSession settings cradle (compLiftToTopLevel fileName (row,col))


compLiftToTopLevel :: FilePath -> SimpPos
     -> RefactGhc [ApplyRefacResult]
compLiftToTopLevel fileName (row,col) = do
      getModuleGhc fileName
      renamed <- getRefactRenamed
      parsed  <- getRefactParsed

      let (Just (modName,_)) = getModuleName parsed
      let maybePn = locToName (GHC.mkFastString fileName) (row, col) renamed
      case maybePn of
        Just pn ->  do
            liftToTopLevel' modName pn
        _       ->  error "\nInvalid cursor position!\n"


-- ---------------------------------------------------------------------

-- | Move a definition one level up from where it is now
liftOneLevel :: RefactSettings -> Cradle -> FilePath -> SimpPos -> IO [FilePath]
liftOneLevel settings cradle fileName (row,col) =
  runRefacSession settings cradle (compLiftOneLevel fileName (row,col))


compLiftOneLevel :: FilePath -> SimpPos
     -> RefactGhc [ApplyRefacResult]
compLiftOneLevel fileName (row,col) = do
      getModuleGhc fileName
      renamed <- getRefactRenamed
      parsed  <- getRefactParsed

      -- logm $ "compLiftOneLevel:(fileName,row,col)="++(show (fileName,row,col))
      logm $ "compLiftOneLevel:renamed=" ++ (SYB.showData SYB.Renamer 0 renamed) -- ++AZ++

      let (Just (modName,_)) = getModuleName parsed
      let maybePn = locToName (GHC.mkFastString fileName) (row, col) renamed
      case maybePn of
        Just pn ->  do
            rs <- liftOneLevel' modName pn
            logm $ "compLiftOneLevel:rs=" ++ (show $ (refactDone rs,map (\((_,d),_) -> d) rs))
            if (refactDone rs)
              then return rs
              else error ( "Lifting this definition failed. "++
                       " This might be because that the definition to be "++
                       "lifted is defined in a class/instance declaration.")
        _       ->  error "\nInvalid cursor position!\n"



-- ---------------------------------------------------------------------

-- | Move a definition one level down
demote :: RefactSettings -> Cradle -> FilePath -> SimpPos -> IO [FilePath]
demote settings cradle fileName (row,col) =
  runRefacSession settings cradle (compDemote fileName (row,col))

compDemote ::FilePath -> SimpPos
         -> RefactGhc [ApplyRefacResult]
compDemote fileName (row,col) = do
      getModuleGhc fileName
      renamed <- getRefactRenamed
      parsed  <- getRefactParsed

      let (Just (modName,_)) = getModuleName parsed
      let maybePn = locToName (GHC.mkFastString fileName) (row, col) renamed
      case maybePn of
        Just pn -> do
          demote' modName pn
        _       -> error "\nInvalid cursor position!\n"


{-
demote args
 = do let  fileName = ghead "filename"  args
           row = read (args!!1)::Int
           col = read (args!!2)::Int
      modName <- fileNameToModName fileName
      (inscps, _, mod, toks) <- parseSourceFile fileName
      let pnt = locToPNT fileName (row, col) mod
          pn = pNTtoPN pnt
      if pn /= defaultPN
         then demote' modName fileName (mod, toks) pn
         else error "\nInvalid cursor position!\n"

move direction args
  = do let fileName = ghead "filename"  args
           row = read (args!!1)::Int
           col = read (args!!2)::Int
       modName <- fileNameToModName fileName
       (inscps, _, mod, toks) <- parseSourceFile fileName
       let pnt = locToPNT fileName (row, col) mod
           pn = pNTtoPN pnt
       if pn /= defaultPN
         then
          case direction  of
               UptoTopLevel ->liftToTopLevel' modName fileName (inscps, mod, toks) pnt
               UpOneLevel   ->liftOneLevel'   modName fileName (inscps, mod, toks) pnt
               Down         ->demote'         modName fileName (mod, toks)  pn
          else error "\nInvalid cursor position!\n"


{- Refactoring Names: 'liftToTopLevel'

   This refactoring lifts a local function/pattern binding to the top
   level of the module, so as to make it accessible to other functions in
   the current module, and those modules that import current module.

   In the current implementation, a definition will be lifted only if
   none of the identifiers defined in this definition will cause name
   clash/capture problems in the current module after lifting.

   In the case that the whole current module is exported implicitly,
   the lifted identifier will be exported automatically after lifting. If
   the identifier will cause name clash/ambiguous occurrence problem in a
   client module, it will be hided in the import declaration of the
   client module (Note: this might not be the best solution, we prefer
   hiding it in the server module instead of in the client module in the
   final version).

   In the case of indirect importing, it might be time-consuming to
   trace whether the lifted identifier will cause any problem in a client
   module that indirectly imports the current module. The current
   solution is: suppose a defintion is lifted to top level in module A,
   and module A is imported and exported by module B, then the lifted
   identifier will be hided in the import declaration of B no matter
  whether it causes problems in module B or not.

   Function name: liftToTopLevel
   parameters: fileName--current file name.
               mod -- the scoped abstract syntax tree of the module.
               pn  -- the function/pattern name to be lifted.
-}

-}

liftToTopLevel' :: GHC.ModuleName -- -> (ParseResult,[PosToken]) -> FilePath
                -> GHC.Located GHC.Name
                -> RefactGhc [ApplyRefacResult]
liftToTopLevel' modName pn@(GHC.L _ n) = do
  renamed <- getRefactRenamed
  -- logm $ "liftToTopLevel':renamed=" ++ (SYB.showData SYB.Renamer 0 renamed) -- ++AZ++
  logm $ "liftToTopLevel':pn=" ++ (showGhc pn)
  if isLocalFunOrPatName n renamed
      then do
              (refactoredMod,declPns) <- applyRefac (liftToMod) RSAlreadyLoaded

              logm $ "liftToTopLevel' applyRefac done "
              -- logm $ "liftToTopLevel' applyRefac done:toks= " ++ (show (fst $ snd refactoredMod))

              if modIsExported modName renamed
               then do clients <- clientModsAndFiles modName
                       logm $ "liftToTopLevel':(clients,declPns)=" ++ (showGhc (clients,declPns))
                       refactoredClients <- mapM (liftingInClientMod modName declPns) clients
                       return (refactoredMod:(concat refactoredClients))
               else do return [refactoredMod]
      else error "\nThe identifier is not a local function/pattern name!"

    where
          {-step1: divide the module's top level declaration list into three parts:
            'parent' is the top level declaration containing the lifted declaration,
            'before' and `after` are those declarations before and after 'parent'.
            step2: get the declarations to be lifted from parent, bind it to liftedDecls 
            step3: remove the lifted declarations from parent and extra arguments may be introduce.
            step4. test whether there are any names need to be renamed.
          -}
       liftToMod = do
                      renamed <- getRefactRenamed
                      let declsr = hsBinds renamed
                      let (before,parent,after) = divideDecls declsr pn
                      -- error ("liftToMod:(before,parent,after)=" ++ (showGhc (before,parent,after))) -- ++AZ++
                      {- ++AZ++ : hsBinds does not return class or instance definitions
                      when (isClassDecl $ ghead "liftToMod" parent)
                            $ error "Sorry, the refactorer cannot lift a definition from a class declaration!"
                      when (isInstDecl $ ghead "liftToMod" parent)
                            $ error "Sorry, the refactorer cannot lift a definition from an instance declaration!"
                      -}
                      let liftedDecls = definingDeclsNames [n] parent True True
                          declaredPns = nub $ concatMap definedPNs liftedDecls

                      -- TODO: what about declarations between this
                      -- one and the top level that are used in this one?

                      logm $ "liftToMod:(liftedDecls,declaredPns)=" ++ (showGhc (liftedDecls,declaredPns))
                      -- original : pns<-pnsNeedRenaming inscps mod parent liftedDecls declaredPns
                      pns <- pnsNeedRenaming renamed parent liftedDecls declaredPns

                      -- (_,dd) <- hsFreeAndDeclaredPNs renamed
                      let dd = getDeclaredVars $ hsBinds renamed
                      logm $ "liftToMod:(ddd)=" ++ (showGhc dd)

                      drawTokenTree "liftToMod.a"

                      if pns==[]
                        then do (parent',liftedDecls',paramAdded)<-addParamsToParentAndLiftedDecl n dd parent liftedDecls
                                let liftedDecls''=if paramAdded then filter isFunOrPatBindR liftedDecls'
                                                                else liftedDecls'

                                drawTokenTree "liftToMod.c"
                                logm $ "liftToMod:(declaredPns)=" ++ (showGhc declaredPns)

                                -- error ("liftToMod:newBinds=" ++ (showGhc (replaceBinds declsr (before++parent'++after)))) -- ++AZ++
                                -- mod'<-moveDecl1 (replaceDecls declsr (before++parent'++after))
                                mod' <- moveDecl1 (replaceBinds renamed (before++parent'++after))
                                       (Just (ghead "liftToMod" (definedPNs (ghead "liftToMod2" parent')))) 
                                       [GHC.unLoc pn] declaredPns True

                                drawTokenTree "liftToMod.b"

                                -- return (mod', declaredPns)
                                return declaredPns

                        else askRenamingMsg pns "lifting"



-- TODO: move this to TypeUtils, as moveDecl
moveDecl1 :: (HsValBinds t)
  => t -- ^ The syntax element to update
  -> Maybe GHC.Name -- ^ If specified, add defn after this one

     -- TODO: make this next parameter a single value, not a list,
     -- after module complete
  -> [GHC.Name]     -- ^ The first one is the decl to move
  -> [GHC.Name]     -- ^ The signatures to remove. May be multiple if
                    --   decl being moved has a patbind.
  -> Bool           -- ^ True if moving to the top level
  -> RefactGhc t    -- ^ The updated syntax element (and tokens in monad)
moveDecl1 t defName ns sigNames topLevel
   = do
        -- logm $ "moveDecl1:t=" ++ (SYB.showData SYB.Renamer 0 t) -- ++AZ++
        -- TODO: work with all of ns, not just the first
        let n = ghead "moveDecl1" ns
        -- let funBinding = definingDeclsNames [n] (hsBinds t) True True
        let funBinding = definingDeclsNames' [n] t

        logm $ "moveDecl1: (ns,funBinding)=" ++ (showGhc (ns,funBinding)) -- ++AZ++

        let Just sspan = getSrcSpan funBinding
        -- drawTokenTree "before getting toks" -- ++AZ++
        funToks <- getToksForSpan sspan
        logm $ "moveDecl1:funToks=" ++ (showToks funToks)
        drawTokenTree "moveDecl1:after getting toks" -- ++AZ++

        -- (t'',sigsRemoved) <- rmTypeSigs ns t
        (t'',sigsRemoved) <- rmTypeSigs sigNames t
        drawTokenTree "moveDecl1:after rmTypeSigs" -- ++AZ++
        -- logm $ "moveDecl1:t''=" ++ (SYB.showData SYB.Renamer 0 t'') -- ++AZ++
        (t',_declRemoved,_sigRemoved)  <- rmDecl (ghead "moveDecl3.1"  ns) False t''
        -- logm $ "moveDecl1:t'=" ++ (SYB.showData SYB.Renamer 0 t') -- ++AZ++
        drawTokenTree "moveDecl1:after rmDecl" -- ++AZ++

        let getToksForMaybeSig (GHC.L ss _) =
                             do
                               sigToks <- getToksForSpan ss
                               return sigToks

        -- maybeToksSigMulti <- mapM getToksForMaybeSig sigsRemoved
        maybeToksSigMulti <- mapM getToksForMaybeSig
                             $ sortBy (\(GHC.L s1 _) (GHC.L s2 _) -> compare (srcSpanToForestSpan s1) (srcSpanToForestSpan s2))  
                                sigsRemoved
        let maybeToksSig = concat maybeToksSigMulti

        logm $ "moveDecl1:maybeToksSig=" ++ (show maybeToksSig) -- ++AZ++
        logm $ "moveDecl1:(defName,topLevel)" ++ (showGhc (defName,topLevel)) -- ++AZ++

        addDecl t' defName (ghead "moveDecl1 2" funBinding,sigsRemoved,Just (maybeToksSig ++ funToks)) topLevel



{-
--get all the declarations define in the scope of t
allDeclsIn t = fromMaybe [] (applyTU (full_tdTU (constTU [] `adhocTU` decl)) t)
               where decl (d::HsDeclP)
                       |isFunBind d || isPatBind d || isTypeSig d = Just [d]
                     decl _ = Just []
-}


askRenamingMsg :: [GHC.Name] -> String -> t
askRenamingMsg pns str
  = error ("The identifier(s): " ++ (intercalate "," $ map showPN pns) ++
           " will cause name clash/capture or ambiguity occurrence problem after "
           ++ str ++", please do renaming first!")

  where
    showPN pn = showGhc (pn,GHC.nameSrcLoc pn)

-- |Get the subset of 'pns' that need to be renamed before lifting.
pnsNeedRenaming :: (SYB.Data t1) =>
  t1 -> [GHC.LHsBind GHC.Name] -> t2 -> [GHC.Name]
  -> RefactGhc [GHC.Name]
pnsNeedRenaming dest parent _liftedDecls pns
   =do
       r <- mapM pnsNeedRenaming' pns
       return (concat r)
  where
     pnsNeedRenaming' pn
       = do
            let (f,d) = hsFDsFromInside dest --f: free variable names that may be shadowed by pn
                                             --d: declaread variables names that may clash with pn
            let vs = hsVisiblePNs pn parent  --vs: declarad variables that may shadow pn
            let -- inscpNames = map (\(x,_,_,_)->x) $ inScopeInfo inscps
                vars = map pNtoName (nub (f `union` d `union` vs) \\ [pn]) -- `union` inscpNames
            -- if elem (pNtoName pn) vars  || isInScopeAndUnqualified (pNtoName pn) inscps && findEntity pn dest
            isInScope <- isInScopeAndUnqualifiedGhc (pNtoName pn) Nothing
            logm $ "MoveDef.pnsNeedRenaming:(f,d,vs,vars,isInScope)=" ++ (showGhc (f,d,vs,vars,isInScope))
            if elem (pNtoName pn) vars  || isInScope && findEntity pn dest
               then return [pn]
               else return []
     --This pNtoName takes into account the qualifier.
     pNtoName = showGhc


addParamsToParent :: (HsValBinds t) => GHC.Name -> [GHC.Name] -> t -> RefactGhc t
addParamsToParent _pn [] t = return t
addParamsToParent  pn params t = do
  logm $ "addParamsToParent:(pn,params)" ++ (showGhc (pn,params))
  t' <- addActualParamsToRhs True pn params t
  return t'


-- |Do refactoring in the client module. that is to hide the identifer
-- in the import declaration if it will cause any problem in the
-- client module.
liftingInClientMod :: GHC.ModuleName -> [GHC.Name] -> GHC.ModSummary
  -> RefactGhc [ApplyRefacResult]
liftingInClientMod serverModName pns modSummary = do
       getModuleDetails modSummary
       renamed <- getRefactRenamed
       -- logm $ "liftingInClientMod:renamed=" ++ (SYB.showData SYB.Renamer 0 renamed) -- ++AZ++
       let clientModule = GHC.ms_mod modSummary
       logm $ "liftingInClientMod:clientModule=" ++ (showGhc clientModule)
  -- = do (inscps, exps ,mod ,ts) <- parseSourceFile fileName
       -- let modNames = willBeUnQualImportedBy serverModName mod
       modNames <- willBeUnQualImportedBy serverModName
       logm $ "liftingInClientMod:modNames=" ++ (showGhc modNames)
       if isJust modNames
        then do
             pns' <- namesNeedToBeHided clientModule (fromJust modNames) pns
             logm $ "liftingInClientMod:pns'=" ++ (showGhc pns')
             -- in if pns' /= []
             if (nonEmptyList pns')
                 -- then do <-runStateT (addHiding serverModName mod pns') ((ts,unmodified),(-1000,0))
                 then do (refactoredMod,_) <- applyRefac (addHiding serverModName renamed pns') RSAlreadyLoaded 
                         return [refactoredMod]
                 else return []
        else return []

-- |Test whether an identifier defined in the modules specified by
-- 'names' will be exported by current module.
willBeExportedByClientMod :: [GHC.ModuleName] -> GHC.RenamedSource -> Bool
willBeExportedByClientMod names renamed =
  let (_,_,exps,_) = renamed
  in if isNothing exps
        then False
        else any isJust $ map (\y-> (find (\x-> (simpModule x==Just y)) (fromJust exps))) names
     where simpModule (GHC.L _ (GHC.IEModuleContents m)) = Just m
           simpModule _  = Nothing

-- |get the module name or alias name by which the lifted identifier
-- will be imported automatically.
-- TODO: maybe move this into TypeUtils
-- willBeUnQualImportedBy::HsName.ModuleName->HsModuleP->Maybe [HsName.ModuleName]
willBeUnQualImportedBy :: GHC.ModuleName -> RefactGhc (Maybe [GHC.ModuleName])
willBeUnQualImportedBy modName = do
   (_,imps,_,_) <- getRefactRenamed
   let ms = filter (\(GHC.L _ (GHC.ImportDecl (GHC.L _ modName1) _qualify _source _safe isQualified _isImplicit _as h))
                     -> modName == modName1 && (not isQualified) && (isNothing h || (isJust h && ((fst (fromJust h)) == True))))
                   imps

       res = if (emptyList ms) then Nothing
                               else Just $ nub $ map getModName ms

       getModName (GHC.L _ (GHC.ImportDecl (GHC.L _ modName2) _qualify _source _safe _isQualified _isImplicit as _h))
        = if isJust as then simpModName (fromJust as)
                       else modName2

       simpModName m = m

   logm $ "willBeUnQualImportedBy:(ms,res)=" ++ (showGhc (ms,res))

   return res


-- |get the subset of 'pns', which need to be hided in the import
-- declaration in module 'mod'
-- Note: these are newly exported from the module, so we cannot use
-- the GHC name resolution i nthis case.
namesNeedToBeHided :: GHC.Module -> [GHC.ModuleName] -> [GHC.Name]
   -> RefactGhc [GHC.Name]
namesNeedToBeHided clientModule modNames pns = do
  renamed <- getRefactRenamed
  parsed <- getRefactParsed
  logm $ "namesNeedToBeHided:willBeExportedByClientMod=" ++ (show $ willBeExportedByClientMod modNames renamed)
  gnames <- GHC.getNamesInScope
  let clientInscopes = filter (\n -> clientModule == GHC.nameModule n) gnames
  logm $ "namesNeedToBeHided:(clientInscopes)=" ++ (showGhc (clientInscopes))

  pnsMapped <- mapM getLocalEquiv pns
  logm $ "namesNeedToBeHided:pnsMapped=" ++ (showGhc pnsMapped)

  let pnsMapped' = filter (\(_,_,ns) -> not $ emptyList ns) pnsMapped

  if willBeExportedByClientMod modNames renamed
      then return pns
      else do
        ff <- mapM (needToBeHided parsed) pnsMapped'
        return $ concat ff
  where
    -- | Strip the package prefix from the name and return the
    -- stripped name together with any names in the local module that
    -- may match the stripped one
    getLocalEquiv :: GHC.Name -> RefactGhc (GHC.Name,String,[GHC.Name])
    getLocalEquiv pn = do
      let pnStr = stripPackage $ showGhc pn
      logm $ "MoveDef getLocalEquiv: about to parseName:" ++ (show pnStr)
      ecns <- GHC.gtry $ GHC.parseName pnStr
      let cns = case ecns of
                 Left (_e::SomeException) -> []
                 Right v -> v
      logm $ "MoveDef getLocalEquiv: cns:" ++ (showGhc cns)
      return (pn,pnStr,cns)

    stripPackage :: String -> String
    stripPackage str = reverse s
      where
        (s,_) = break (== '.') $ reverse str

    needToBeHided :: GHC.ParsedSource -> (GHC.Name,String,[GHC.Name]) -> RefactGhc [GHC.Name]
    needToBeHided parsed (pn,_pnStr,pnsLocal) = do
      let uwoq = map (\n -> usedWithoutQualR n parsed) pnsLocal

      -- logm $ "needToBeHided:(hsBinds renamed)=" ++ (showGhc (hsBinds renamed))
      logm $ "needToBeHided:(pn,uwoq)=" ++ (showGhc (pn,uwoq))

      if (any (== True) uwoq --the same name is used in the module unqualifiedly or
                --is exported unqualifiedly by an Ent decl

            -- was || causeNameClashInExports pn modNames renamed)
            -- TODO: ++AZ++ check if next line needs to be reinstated
            -- was || any (\m -> causeNameClashInExports oldPN pn m renamed) modNames)
            || False)
           then return [pn]
           else return []


-- **************************************************************************************************************--

{- Refactoring Names: 'liftOneLevel'
   Descritption:
    this refactoring lifts a local function/pattern binding only one level up.
    By 'lifting one-level up' ,I mean:

    case1: In a module (HsModule SrcLoc ModuleName (Maybe [HsExportSpecI i]) [HsImportDeclI i] ds):
           A local declaration D  will be lifted to the same level as the 'ds', if D is in the 
           where clause of one of ds's element declaration.

        new: (HsGroup Name, [LImportDecl Name], Maybe [LIE Name], Maybe LHsDocString)
              HsGroup hs_valds :: HsValBinds id ...



    case2: In a match ( HsMatch SrcLoc i [p] (HsRhs e) ds) :
          A local declaration D  will be lifted to the same level as the 'ds', if D is in the 
           where clause of one of ds's element declaration.
           A declaration D,say,in the rhs expression 'e' will be lifted to 'ds' if D is Not local to
           other declaration list in 'e'

           (in a FunBind)
        new: Match [LPat id] (Maybe (LHsType id)) (GRHSs id)


    case3: In a pattern  binding (HsPatBind SrcLoc p (HsRhs e) ds):
           A local declaration D  will be lifted to the same level as the 'ds', if D is in the 
           where clause of one of ds's element declaration.
           A declaration D,say,in the rhs expression 'e' will be lifted to 'ds' if D is Not local to
           other declaration list in 'e'

        new: PatBind (LPat idL) (GRHSs idR) PostTcType NameSet (Maybe tickish)



    case4: In the Let expression (Exp (HsLet ds e):
           A local declaration D  will be lifted to the same level as the 'ds', if D is in the 
           where clause of one of ds's element declaration.
           A declaration D, say, in the expression 'e' will be lifted to 'ds' if D is not local to
           other declaration list in 'e'

        new: HsLet (HsLocalBinds id) (LHsExpr id)


    case5: In the case Alternative expression:(HsAlt loc p rhs ds)
           A local declaration D  will be lifted to the same level as the 'ds', if D is in the 
           where clause of one of ds's element declaration.
           A declaration D in 'rhs' will be lifted to 'ds' if D is not local to other declaration 
           list in 'rhs'.

        new: HsCase (LHsExpr id) (MatchGroup id)
           new is same as in a FunBind.


    case6: In the do statement expression:(HsLetStmt ds stmts)
           A local declaration D  will be lifted to the same level as the 'ds', if D is in the 
           where clause of one of ds's element declaration.
           A declaration D in 'stmts' will be lifted to 'ds' if D is not local to other declaration 
           list in 'stmts'.

        new: LetStmt (HsLocalBindsLR idL idR)
             in context GRHS [LStmt id] (LHsExpr id)


Function name: liftOneLevel
parameters: fileName--current file name.
            mod -- the scoped abstract syntax tree of the module.
            pn  -- the function/pattern name to be lifted.

-}

liftOneLevel' :: GHC.ModuleName
                -> GHC.Located GHC.Name
                -> RefactGhc [ApplyRefacResult]

liftOneLevel' modName pn@(GHC.L _ n) = do
  renamed <- getRefactRenamed
  if isLocalFunOrPatName n renamed
        then do -- (mod', ((toks',m),_))<-liftOneLevel''
                (refactoredMod,_) <- applyRefac (liftOneLevel'') RSAlreadyLoaded
                let (b, pns) = liftedToTopLevel pn renamed
                if b &&  modIsExported modName renamed
                  then do clients<-clientModsAndFiles modName
                          -- logm $ "liftOneLevel':(clients,declPns)=" ++ (showGhc (clients,declPns))
                          refactoredClients <- mapM (liftingInClientMod modName pns) clients
                          return (refactoredMod:(concat refactoredClients))
                  else do return [refactoredMod]
        else error "\nThe identifer is not a function/pattern name!"

   where
      liftOneLevel''= do
             logm $ "in liftOneLevel''"
             renamed <- getRefactRenamed
             ztransformStagedM SYB.Renamer (Nothing
                                `SYB.mkQ` liftToModQ
                                `SYB.extQ` liftToMatchQ'
                                `SYB.extQ` liftToLet'
                                -- `SYB.mkQ` liftToMatchQ
                                -- `SYB.extQ` liftToLet
                                    ) (Z.toZipper renamed)

           where
             isValBinds :: GHC.HsValBinds GHC.Name -> Bool
             isValBinds _ = True

             isGRHSs :: GHC.GRHSs GHC.Name -> Bool
             isGRHSs _ = True

             isHsLet :: GHC.HsExpr GHC.Name -> Bool
             isHsLet (GHC.HsLet _ _) = True
             isHsLet _               = False

             liftToModQ ((g,_imps,_exps,_docs):: GHC.RenamedSource)
                | nonEmptyList candidateBinds
                  = Just (doLiftZ candidateBinds)
                | otherwise = Nothing
                where
                 candidateBinds = map snd
                                $ filter (\(l,_bs) -> nonEmptyList l)
                                $ map (\bs -> (definingDeclsNames [n] (hsBinds bs) False False,bs)) 
                                $ (hsBinds g)

             liftToMatchQ' :: (SYB.Data a) => GHC.Match GHC.Name -> Maybe (SYB.Stage -> Z.Zipper a -> RefactGhc (Z.Zipper a))
             liftToMatchQ' ((GHC.Match _pats _mtyp (GHC.GRHSs rhs ds))::GHC.Match GHC.Name)
                 | (nonEmptyList (definingDeclsNames [n] (hsBinds  ds) False False)) 
                    = Just (doLiftZ ds)
                 | (nonEmptyList (definingDeclsNames [n] (hsBinds rhs) False False))
                    = Just (doLiftZ rhs)
                 | otherwise = Nothing

             liftToLet' :: GHC.HsExpr GHC.Name -> Maybe (SYB.Stage -> Z.Zipper a -> RefactGhc (Z.Zipper a))
             liftToLet' ((GHC.HsLet ds _e)::GHC.HsExpr GHC.Name)
               | nonEmptyList (definingDeclsNames [n] (hsBinds ds) False  False)
                 = Just (doLiftZ ds)
               | otherwise = Nothing
             liftToLet' _ = Nothing

             doLiftZ :: (HsValBinds t)
               => t -> SYB.Stage -> Z.Zipper a
               -> RefactGhc (Z.Zipper a)
             doLiftZ ds _stage z =
                  do
                    logm $ "in liftOneLevel''.liftToLet in ds"

                    let zu = case (Z.up z) of
                              Just zz -> fromMaybe (error "MoveDef.liftToLet.1")
                                  $ upUntil (False `SYB.mkQ` isGRHSs
                                                   `SYB.extQ` isHsLet
                                                   `SYB.extQ` isValBinds)
                                     zz
                              Nothing -> z

                    let
                      wtop (ren::GHC.RenamedSource) = do
                        worker ren (hsBinds ds) pn True

                      wgrhs (grhss::GHC.GRHSs GHC.Name) = do
                         let (_,dd) = (hsFreeAndDeclaredPNs grhss)
                         worker1 grhss (hsBinds ds) pn dd False

                      wlet :: GHC.HsExpr GHC.Name -> RefactGhc (GHC.HsExpr GHC.Name)
                      wlet l@(GHC.HsLet dsl _e) = do
                        let (_,dd) = hsFreeAndDeclaredPNs dsl
                        dsl' <- worker1 l (hsBinds ds) pn dd False
                        return dsl'

                      wvalbinds (vb::GHC.HsValBinds GHC.Name) = do
                         let (_,dd) = (hsFreeAndDeclaredPNs vb)
                         worker1 vb (hsBinds ds) pn dd False

                    ds' <- Z.transM (SYB.mkM wtop `SYB.extM` wgrhs
                                     `SYB.extM` wlet `SYB.extM` wvalbinds) zu

                    return ds'

             -- TODO: merge worker and worker1
             worker :: (HsValBinds t)
                => t -- ^The destination of the lift operation
                -> [GHC.LHsBind GHC.Name] -- ^ list containing the
                                -- decl to be lifted
                -> GHC.Located GHC.Name -- ^ The name of the decl to
                                -- be lifted
                -> Bool -- ^True if lifting to the top level
                -> RefactGhc t
             worker dest ds pnn toToplevel
                  =do let (before,parent,after)=divideDecls ds pnn -- parent is misnomer, it is the decl to be moved
                          -- liftedDecls=definingDeclsNames [n] parent True  False
                          liftedDecls=definingDeclsNames [n] parent True  True
                          declaredPns=nub $ concatMap definedPNs liftedDecls
                      logm $ "MoveDef.worker: (dest)=" ++ (SYB.showData SYB.Renamer 0 dest)
                      logm $ "MoveDef.worker: (ds)=" ++ (showGhc (ds))
                      logm $ "MoveDef.worker: parent=" ++ (showGhc parent)
                      let (_, dd) = hsFreeAndDeclaredPNs dest
                      -- pns<-pnsNeedRenaming inscps dest parent liftedDecls declaredPns
                      pns<-pnsNeedRenaming dest parent liftedDecls declaredPns
                      logm $ "MoveDef.worker: pns=" ++ (showGhc pns)
                      if pns==[]
                        then do
                                (parent',liftedDecls',paramAdded)<-addParamsToParentAndLiftedDecl n dd
                                                                     parent liftedDecls 
                                let liftedDecls''=if paramAdded then filter isFunOrPatBindR liftedDecls'
                                                                else liftedDecls'
                                --True means the new decl will be at the same level with its parant. 
                                dest'<-moveDecl1 (replaceBinds dest (before++parent'++after))
                                           (Just (ghead "worker" (definedPNs (ghead "worker" parent')))) 
                                           [n] declaredPns toToplevel -- False -- ++AZ++ TODO: should be True for toplevel move
                                return dest'
                                --parent'<-doMoving declaredPns (ghead "worker" parent) True  paramAdded parent'
                                --return (before++parent'++liftedDecls''++after)
                        else askRenamingMsg pns "lifting"

             worker1 :: (HsValBinds t)
                => t -- ^The destination of the lift operation
                -> [GHC.LHsBind GHC.Name] -- ^ list containing the
                                -- decl to be lifted
                -> GHC.Located GHC.Name -- ^ The name of the decl to
                                -- be lifted
                -> [GHC.Name] -- ^Declared variables in the destination
                -> Bool -- ^True if lifting to the top level
                -> RefactGhc t
             worker1 dest ds pnn dd toToplevel
{-
Actions required
  1. add parameters to original decls if required
  2. add parameters to any points that call the lifted decl
     once it is lifted
  3. Replace the above in the AST
  4. Do the move
-}

                  =do let (_before,decl,_after)=divideDecls ds pnn
                          liftedDecls=definingDeclsNames [n] decl True  True
                          declaredPns=nub $ concatMap definedPNs liftedDecls
                      logm $ "MoveDef.worker1: (dest)=" ++ (SYB.showData SYB.Renamer 0 dest)
                      logm $ "MoveDef.worker1: (ds)=" ++ (showGhc (ds))
                      logm $ "MoveDef.worker1: decl=" ++ (showGhc decl)

                      pns <- pnsNeedRenaming dest decl liftedDecls declaredPns
                      logm $ "MoveDef.worker1: pns=" ++ (showGhc pns)
                      if pns==[]
                        then do
                                (dest',liftedDecls',paramAdded)
                                    -- <- addParamsToParentAndLiftedDecl n dd decl liftedDecls 
                                    <- addParamsToParentAndLiftedDecl n dd dest liftedDecls 
                                let liftedDecls''=if paramAdded then filter isFunOrPatBindR liftedDecls'
                                                                else liftedDecls'
                                -- logm $ "MoveDef.worker1:liftedDecls''=" ++ (showGhc liftedDecls'')
                                logm $ "MoveDef.worker1:dest'=" ++ (SYB.showData SYB.Renamer 0 dest')
                                --True means the new decl will be at the same level with its parant. 
                                dest'<-moveDecl1 dest' Nothing
                                           [n] declaredPns toToplevel -- False -- ++AZ++ TODO: should be True for toplevel move
                                return dest'
                                --decl'<-doMoving declaredPns (ghead "worker" decl) True  paramAdded decl'
                                --return (before++decl'++liftedDecls''++after)
                        else askRenamingMsg pns "lifting"


liftedToTopLevel :: GHC.Located GHC.Name -> GHC.RenamedSource -> (Bool,[GHC.Name])
liftedToTopLevel pnt@(GHC.L _ pn) renamed
  = if nonEmptyList (definingDeclsNames [pn] (hsBinds renamed) False True)
     then let (_, parent,_) = divideDecls (hsBinds renamed) pnt
              liftedDecls=definingDeclsNames [pn] (hsBinds parent) True True
              declaredPns  = nub $ concatMap definedPNs liftedDecls
          in (True, declaredPns)
     else (False, [])


addParamsToParentAndLiftedDecl :: HsValBinds t =>
  GHC.Name
  -> [GHC.Name] -- ^Declared names in parent
  -> t
  -> [GHC.LHsBind GHC.Name]
  -> RefactGhc (t, [GHC.LHsBind GHC.Name], Bool)
addParamsToParentAndLiftedDecl pn dd parent liftedDecls
  =do  let (ef,_) = hsFreeAndDeclaredPNs parent
       let (lf,_) = hsFreeAndDeclaredPNs liftedDecls

       let eff = getFreeVars $ hsBinds parent
       let lff = getFreeVars liftedDecls
       logm $ "addParamsToParentAndLiftedDecl:(eff,lff)=" ++ (showGhc (eff,lff))

       -- let newParams=((nub lf)\\ (nub ef)) \\ dd  --parameters (in PName format) to be added to pn because of lifting
       let newParams=((nub lff)\\ (nub eff)) \\ dd  --parameters (in PName format) to be added to pn because of lifting
       logm $ "addParamsToParentAndLiftedDecl:(newParams,ef,lf,dd)=" ++ (showGhc (newParams,ef,lf,dd))
       if newParams/=[]
         then if  (any isComplexPatBind liftedDecls)
                then error "This pattern binding cannot be lifted, as it uses some other local bindings!"
                else do parent' <- addParamsToParent pn newParams parent
                        liftedDecls'<-addParamsToDecls liftedDecls pn newParams True 
                        return (parent', liftedDecls',True)
         else return (parent,liftedDecls,False)


--------------------------------End of Lifting-----------------------------------------

{-Refactoring : demote a function/pattern binding(simpe or complex) to the declaration where it is used.
  Descritption: if a declaration D, say, is only used by another declaration F,say, then D can be 
                demoted into the local declaration list (where clause) in F.
                So currently, D can not be demoted if more than one declaration use it. 

                In a multi-module context, a top-level definition can not be demoted if it is used
                by other modules. In the case that the demoted identifer is in the hiding list of
                import declaration in a client module, it should be removed from the hiding list.

 Function name:demote
 parameters: fileName--current file name.
             mod -- the scoped abstract syntax tree of the module.
             pn  -- the function/pattern name to be demoted.

-}

demote' ::
     GHC.ModuleName
  -- -> FilePath
  -- -> (ParseResult,[PosToken])
  -> GHC.Located GHC.Name
  -> RefactGhc [ApplyRefacResult]
demote' modName (GHC.L _ pn) = do
  renamed <- getRefactRenamed
  if isFunOrPatName pn renamed
    then do
       isTl <- isTopLevelPN pn
       if isTl && isExplicitlyExported pn renamed
          then error "This definition can not be demoted, as it is explicitly exported by the current module!"
          else do -- (mod',((toks',m),_))<-doDemoting pn fileName mod toks
                  (refactoredMod,_) <- applyRefac (doDemoting pn) RSAlreadyLoaded
                  -- isTl <- isTopLevelPN pn
                  if isTl && modIsExported modName renamed
                    then do let demotedDecls'= definingDeclsNames [pn] (hsBinds renamed) True False
                                declaredPns  = nub $ concatMap definedPNs demotedDecls'
                            clients <- clientModsAndFiles modName
                            logm $ "demote':clients=" ++ (showGhc clients)
                            refactoredClients <-mapM (demotingInClientMod declaredPns) clients
                            -- return (refactoredMod:[])
                            return (refactoredMod:refactoredClients)
                    else do return [refactoredMod]
    else error "\nInvalid cursor position!"


-- |Do refactoring in the client module, that is:
--  a) Check whether the identifier is used in the module body
--  b) If the identifier is not used but is hided by the import
--     declaration, then remove it from the hiding.
demotingInClientMod ::
  [GHC.Name] -> GHC.ModSummary
  -> RefactGhc ApplyRefacResult
demotingInClientMod pns modSummary = do
  getModuleDetails modSummary
  (refactoredMod,_) <- applyRefac (doDemotingInClientMod pns (GHC.ms_mod modSummary)) RSAlreadyLoaded
  return refactoredMod


doDemotingInClientMod :: [GHC.Name] -> GHC.Module -> RefactGhc ()
doDemotingInClientMod pns modName = do
  renamed@(_g,imps,exps,_docs) <- getRefactRenamed
  -- if any (\pn->findPN pn (hsModDecls mod) || findPN pn (hsModExports mod)) pns
  if any (\pn->findPN pn (hsBinds renamed) || findPN pn (exps)) pns
     then error $ "This definition can not be demoted, as it is used in the client module '"++(showGhc modName)++"'!"
     else if any (\pn->findPN pn imps) pns
             -- TODO: reinstate this
             then do -- (mod',((ts',m),_))<-runStateT (rmItemsFromImport mod pns) ((ts,unmodified),(-1000,0))
                     return ()
             else return ()

doDemoting :: GHC.Name -> RefactGhc ()
doDemoting  pn = do

  clearRefactDone -- Only do this action once

  renamed  <- getRefactRenamed
  logm $ "MoveDef.doDemoting:renamed=" ++ (SYB.showData SYB.Renamer 0 renamed) -- ++AZ++
  -- everywhereMStaged' is top-down
  renamed' <- everywhereMStaged' SYB.Renamer (SYB.mkM   demoteInMod
                                             `SYB.extM` demoteInMatch
                                             `SYB.extM` demoteInPat
                                             `SYB.extM` demoteInLet
                                             `SYB.extM` demoteInStmt
                                            ) renamed
  -- error ("doDemoting:renamed'=" ++ (showGhc renamed'))
  putRefactRenamed renamed'
  -- ren <- getRefactRenamed
  -- error ("doDemoting:ren=" ++ (showGhc ren))
  return ()
{-
 =runStateT (applyTP ((once_tdTP (failTP `adhocTP` demoteInMod
                                         `adhocTP` demoteInMatch
                                         `adhocTP` demoteInPat
                                         `adhocTP` demoteInLet
                                         `adhocTP` demoteInAlt
                                         `adhocTP` demoteInStmt)) `choiceTP` failure) mod)
                     ((toks,unmodified),(-1000,0))
-}
    where
       --1. demote from top level
       -- demoteInMod (mod@(HsModule loc name exps imps ds):: HsModuleP)
       demoteInMod (renamed :: GHC.RenamedSource)
         | not $ emptyList decls
         = do
              logm "MoveDef:demoteInMod" -- ++AZ++
              demoted <- doDemoting' renamed pn
              return demoted
         where
           decls = (definingDeclsNames [pn] (hsBinds renamed) False False)
       demoteInMod x = return x

       --2. The demoted definition is a local decl in a match
       -- demoteInMatch (match@(HsMatch loc1 name pats rhs ds)::HsMatchP)
       demoteInMatch (match@(GHC.Match _pats _mt rhs)::GHC.Match GHC.Name)
         -- was | definingDecls [pn] ds False False/=[]
         | not $ emptyList (definingDeclsNames [pn] (hsBinds rhs) False False)
         = do
              logm "MoveDef:demoteInMatch" -- ++AZ++
              done <- getRefactDone
              match' <- if (not done)
                then doDemoting' match pn
                else return match
              return match'
       demoteInMatch  x = return x

       --3. The demoted definition is a local decl in a pattern binding
       -- demoteInPat (pat@(Dec (HsPatBind loc p rhs ds))::HsDeclP)
       demoteInPat (pat@((GHC.PatBind _p rhs _ _ _))::GHC.HsBind GHC.Name)
         -- was | definingDecls [pn] ds False False /=[]
         | not $ emptyList (definingDeclsNames [pn] (hsBinds rhs) False False)
          = do
              logm "MoveDef:demoteInPat" -- ++AZ++
              done <- getRefactDone
              pat' <- if (not done)
                then doDemoting' pat pn
                else return pat
              return pat'
       demoteInPat x = return x

       --4: The demoted definition is a local decl in a Let expression
       -- demoteInLet (letExp@(Exp (HsLet ds e))::HsExpP)
       demoteInLet (letExp@(GHC.HsLet ds _e)::GHC.HsExpr GHC.Name)
         -- was | definingDecls [pn] ds False False/=[]
         | not $ emptyList (definingDeclsNames [pn] (hsBinds ds) False False)
          = do
              logm "MoveDef:demoteInLet" -- ++AZ++
              done <- getRefactDone
              letExp' <- if (not done)
                 then doDemoting' letExp pn
                 else return letExp
              return letExp'
       demoteInLet x = return x

       -- TODO: the rest of these cases below
{-
       --5. The demoted definition is a local decl in a case alternative.
       demoteInAlt (alt@(HsAlt loc p rhs ds)::(HsAlt (HsExpP) (HsPatP) [HsDeclP]))
         | definingDecls [pn] ds False False /=[]
          = doDemoting'  alt pn
       demoteInAlt _=mzero
-}

       --6.The demoted definition is a local decl in a Let statement.
       -- demoteInStmt (letStmt@(HsLetStmt ds stmts):: (HsStmt (HsExpP) (HsPatP) [HsDeclP]))
       demoteInStmt (letStmt@(GHC.LetStmt binds)::GHC.Stmt GHC.Name)
         -- was | definingDecls [pn] ds False False /=[]
         | not $ emptyList (definingDeclsNames [pn] (hsBinds binds) False False)
          = do
              logm "MoveDef:demoteInStmt" -- ++AZ++
              done <- getRefactDone
              letStmt' <- if (not done)
                then doDemoting' letStmt pn
                else return letStmt
              return letStmt'
       demoteInStmt x =return x

       -- TODO: the rest of these cases below
{-
       failure=idTP `adhocTP` mod
             where
               mod (m::HsModuleP)
                = error "Refactoring failed!"   --SHOULD GIVE MORE DETAILED ERROR MESSAGE
-}



doDemoting' :: (HsValBinds t, UsedByRhs t) => t -> GHC.Name -> RefactGhc t
doDemoting' t pn
 = let origDecls = hsBinds t
       demotedDecls'= definingDeclsNames [pn] origDecls True False
       declaredPns = nub $ concatMap definedPNs demotedDecls'
   in if not (usedByRhs t declaredPns)
      -- if True -- ++AZ++ temporary
       then do
              -- drawTokenTree "" -- ++AZ++ debug
              let demotedDecls = definingDeclsNames [pn] (hsBinds t) True True
              -- logm $ "doDemoting':demotedDecls=" ++ (showGhc demotedDecls) -- ++AZ++
              -- find how many matches/pattern bindings (except the binding defining pn) use 'pn'
              -- uselist <- uses declaredPns (hsBinds t\\demotedDecls)
              let -- uselist = uses declaredPns (hsBinds t\\demotedDecls)
                  otherBinds = (deleteFirstsBy sameBind (hsBinds t) demotedDecls)
                  -- uselist = uses declaredPns otherBinds
                      {- From 'hsDecls t' to 'hsDecls t \\ demotedDecls'.
                         Bug fixed 06/09/2004 to handle direct recursive function.
                       -}
                  -- uselist = concatMap (\r -> if (emptyList r) then [] else ["Used"]) $ map (\b -> uses declaredPns [b]) otherBinds
                  xx = map (\b -> (b,uses declaredPns [b])) otherBinds
                  uselist = concatMap (\(b,r) -> if (emptyList r) then [] else [b]) xx
              logm $ "doDemoting': uses xx=" ++ (showGhc xx)
              logm $ "doDemoting': uses uselist=" ++ (showGhc uselist)

              case length uselist  of
                  0 ->do error "\n Nowhere to demote this function!\n"
                  1 -> --This function is only used by one friend function
                      do
                         drawTokenTree "" -- ++AZ++ debug
                         logm "MoveDef.doDemoting':target location found" -- ++AZ++
                         -- (f,d)<-hsFreeAndDeclaredPNs demotedDecls
                         let (f,_d) = hsFreeAndDeclaredPNs demotedDecls
                         -- remove demoted declarations
                         (ds,removedDecl,_sigRemoved) <- rmDecl pn False (hsBinds t)
                         (t',demotedSigs) <- rmTypeSigs declaredPns t

                         let (GHC.L ssd _) = removedDecl
                         demotedToks <- getToksForSpan ssd

                         -- TODO: move this to its own fn
                         let getToksForMaybeSig (GHC.L ss _) = do
                                                   sigToks <- getToksForSpan ss
                                                   return sigToks

                         demotedSigToksLists <- mapM getToksForMaybeSig demotedSigs
                         let demotedSigToks = concat demotedSigToksLists
                         -- end TODO

                         logm $ "MoveDef:declaredPns=" ++ (showGhc declaredPns) -- ++AZ++
                         logm $ "MoveDef:demotedSigToks=" ++ (show demotedSigToks) -- ++AZ++

                         logm $ "MoveDef:sig and decl toks[" ++ (GHC.showRichTokenStream (demotedSigToks ++ demotedToks)) ++ "]" -- ++AZ++

                         --get those variables declared at where the demotedDecls will be demoted to
                         -- let dl = map (flip declaredNamesInTargetPlace ds) declaredPns
                         dl <- mapM (flip declaredNamesInTargetPlace ds) declaredPns
                         logm $ "mapM declaredNamesInTargetPlace done"
                         --make sure free variable in 'f' do not clash with variables in 'dl',
                         --otherwise do renaming.
                         let clashedNames=filter (\x-> elem (id x) (map id f)) $ (nub.concat) dl
                         --rename clashed names to new names created automatically,update TOKEN STREAM as well.
                         if clashedNames/=[]
                            then error ("The identifier(s):" ++ showGhc clashedNames ++
                                       ", declared in where the definition will be demoted to, will cause name clash/capture"
                                       ++" after demoting, please do renaming first!")  
                                 --ds'<-foldM (flip (autoRenameLocalVar True)) ds clashedNames
                            else  --duplicate demoted declarations to the right place.
                                 do
                                    logm $ "MoveDef: about to duplicateDecls"
                                    -- ds'' <- duplicateDecls declaredPns removedDecl demotedSigs (Just (demotedSigToks ++ demotedToks)) origDecls
                                    ds'' <- duplicateDecls declaredPns removedDecl demotedSigs (Just (demotedSigToks ++ demotedToks)) ds
                                    logm $ "MoveDef:duplicateDecls done"

                                    -- drawTokenTree "" -- ++AZ++ debug

                                    return (replaceBinds t' ds'')
                  _ ->error "\nThis function/pattern binding is used by more than one friend bindings\n"
                  -- _ ->error $ "\nThis function/pattern binding is used by more than one friend bindings:\n" ++ (showGhc yy)
                  -- _ ->error $ "\nThis function/pattern binding is used by more than one friend bindings\n" ++ (showGhc (uselist,declaredPns,otherBinds)) -- ++AZ++

       else error "This function can not be demoted as it is used in current level!\n"
       -- else error ("doDemoting': demotedDecls=" ++ (showGhc demotedDecls)) -- ++AZ++
       -- else error ("doDemoting': declaredPns=" ++ (showGhc declaredPns)) -- ++AZ++
       -- else error ("doDemoting': (origDecls,demotedDecls',declaredPns,(usedByRhs t declaredPns))=" ++ (showGhc (origDecls,demotedDecls',declaredPns,(usedByRhs t declaredPns)))) -- ++AZ++


    where
          ---find how many matches/pattern bindings use  'pn'-------
          -- uses :: (SYB.Data t) => [GHC.Name] -> [t] -> [Int]
          -- uses :: (SYB.Data t) => [GHC.Name] -> t -> [Int]
          uses pns t
               = concat $ SYB.everythingStaged SYB.Renamer (++) []
                   ([] `SYB.mkQ`  usedInMatch
                       `SYB.extQ` usedInPat) t
                where
                  -- ++AZ++ Not in pattern, but is in RHS
                  -- usedInMatch (match@(HsMatch _ (PNT pname _ _) _ _ _)::HsMatchP)
                  usedInMatch ((GHC.Match pats _ rhs) :: GHC.Match GHC.Name)
                    -- was | isNothing (find (==pname) pns) && any  (flip findPN match) pns
                    | (not $ findPNs pns pats) && findPNs pns rhs
                     = return [1::Int]
                  usedInMatch _ = return []
                  -- usedInMatch _ = mzero

                  -- usedInPat (pat@(Dec (HsPatBind _ p _ _)):: HsDeclP)
                  usedInPat ((GHC.PatBind pat rhs _ _ _) :: GHC.HsBind GHC.Name)
                    -- was | hsPNs p `intersect` pns ==[]  && any  (flip findPN pat) pns
                    | (not $ findPNs pns pat) && findPNs pns rhs
                    = return [1::Int]
                  usedInPat  _ = return []
                  -- usedInPat  _ = mzero


          -- duplicate demotedDecls to the right place (the outer most level where it is used).
          -- duplicateDecls :: [GHC.Name] -> [GHC.LHsBind GHC.Name] -> RefactGhc [GHC.LHsBind GHC.Name]
          duplicateDecls :: [GHC.Name] -- ^ function names to be demoted
                         -> GHC.LHsBind GHC.Name -- ^Bind being demoted
                         -> [GHC.LSig GHC.Name] -- ^Signatures being demoted, if any
                         -> Maybe [PosToken]          -- ^Tokens if provided
                         -> [GHC.LHsBind GHC.Name]    -- ^Binds of original top level entiity, including src and dst
                         -> RefactGhc [GHC.LHsBind GHC.Name]
          -- duplicateDecls :: (SYB.Data t) =>[GHC.Name] -> t -> RefactGhc [GHC.LHsBind GHC.Name]
          duplicateDecls pns demoted dsig dtoks decls
             -- = do everywhereMStaged SYB.Renamer (SYB.mkM dupInMatch
             = do
                  -- logm "duplicateDecls:clearing done"  -- ++AZ++
                  -- clearRefactDone
                  everywhereMStaged' SYB.Renamer (SYB.mkM dupInMatch -- top-down approach
             -- = do somewhereMStaged SYB.Renamer (SYB.mkM dupInMatch -- need working MonadPlus for somewhereMStaged
                                                `SYB.extM` dupInPat) decls
             {-
             = do applyTP (once_tdTP (failTP `adhocTP` dupInMatch
                                             `adhocTP` dupInPat)) decls
                  --error (show decls' ++ "\n" ++ prettyprint decls')
                  -- rmDecl (ghead "moveDecl3"  pns) False =<<foldM (flip rmTypeSig) decls' pns 
             -}
               where
                 -- dupInMatch (match@(HsMatch loc1 name pats rhs ds)::HsMatchP)
                 dupInMatch (match@(GHC.Match pats _mt rhs) :: GHC.Match GHC.Name)
                   -- was | any (flip findPN match) pns && not (any (flip findPN name) pns)
                   | (not $ findPNs pns pats) && findPNs pns rhs
                   =  do
                        done <- getRefactDone
                        logm $ "duplicateDecls:value of done=" ++ (show done) -- ++AZ++
                        if done
                          then return match
                          else do
                            logm "duplicateDecls:setting done"  -- ++AZ++
                            setRefactDone
                            --If not fold parameters.
                            -- moveDecl pns pats False decls False
                            {- ++AZ++ foldParams instead
                            rhs' <- addDecl rhs Nothing (demoted,dsig,dtoks) False
                            return (GHC.Match pats mt rhs')
                            -}
                            -- If fold parameters.
                            -- error "dupInMatch" -- ++AZ++
                            match' <- foldParams pns match decls demoted dsig dtoks
                            return match'
                 -- dupInMatch _ =mzero
                 dupInMatch x = return x

                 -- dupInPat (pat@(Dec (HsPatBind loc p rhs ds))::HsDeclP)
                 dupInPat ((GHC.PatBind pat rhs ty fvs ticks) :: GHC.HsBind GHC.Name)
                    -- was |any (flip findPN pat) pns && not (any (flip findPN p) pns)
                    | (not $ findPNs pns pat) && findPNs pns rhs
                   -- =  moveDecl pns pat False decls False
                   = do
                       -- rhs' <- moveDecl pns rhs False decls False
                       -- TODO: what wbout dtoks?
                       -- error "dupInPat" -- ++AZ++
                       rhs' <- moveDecl1 rhs Nothing pns pns False
                       return (GHC.PatBind pat rhs' ty fvs ticks)
                 -- dupInPat _ =mzero
                 dupInPat x = return x

                 -- demotedDecls = definingDecls pns decls True False
          ---------------------------------------------------------------------
          {-
          declaredNamesInTargetPlace :: (Term t, MonadPlus m)=>PName->t->m [PName]
          declaredNamesInTargetPlace pn=applyTU (stop_tdTU (failTU
                                                    `adhocTU` inMatch
                                                    `adhocTU` inPat))
          -}
          declaredNamesInTargetPlace :: (SYB.Data t)
                            => GHC.Name -> t
                            -- -> RefactGhc [GHC.Name]
                            -> RefactGhc [GHC.Name]
{-
          declaredNamesInTargetPlace pn
             = SYB.everythingStaged SYB.Renamer (++) []
                   ([] `SYB.mkQ`  inMatch
                       `SYB.extQ` inPat)
-}
          declaredNamesInTargetPlace pn t = do
             logm $ "declaredNamesInTargetPlace:pn=" ++ (showGhc pn)
             res <- applyTU (stop_tdTUGhc (failTU
                                           `adhocTU` inMatch
                                           `adhocTU` inPat)) t
             logm $ "declaredNamesInTargetPlace:res=" ++ (showGhc res)
             return res
               where
                 -- inMatch (match@(HsMatch loc1 name pats rhs ds)::HsMatchP)
                 inMatch ((GHC.Match _pats _ rhs) :: GHC.Match GHC.Name)
                    | findPN pn rhs = do
                     logm $ "declaredNamesInTargetPlace:inMatch"
                     let fds = hsFDsFromInside rhs
                     return $ snd fds
                     -- (return.snd) =<< hsFDsFromInside rhs
                 -- inMatch _ = mzero
                 inMatch _ = return mzero

                 -- inPat (pat@(Dec (HsPatBind loc p rhs ds)):: HsDeclP)
                 inPat ((GHC.PatBind pat rhs _ _ _) :: GHC.HsBind GHC.Name)
                    |findPN pn rhs = do
                     logm $ "declaredNamesInTargetPlace:inPat"
                     let fds = hsFDsFromInside pat
                     return $ snd fds
                     -- (return.snd) =<< hsFDsFromInside pat
                 -- inPat _=  mzero
                 inPat _=  return mzero


{-
                 inMatch (match@(HsMatch loc1 name pats rhs ds)::HsMatchP)
                    | findPN pn rhs
                     =(return.snd)=<<hsFDsFromInside match
                 inMatch _ =mzero

                 inPat (pat@(Dec (HsPatBind loc p rhs ds)):: HsDeclP)
                    |findPN pn rhs
                     =(return.snd)=<<hsFDsFromInside pat
                 inPat _=mzero
-}



-- ---------------------------------------------------------------------




{- foldParams:remove parameters in the demotedDecls if possible
   parameters: pn -- the function/pattern name to be demoted in PName format
               match--where the demotedDecls will be demoted to
               demotedDecls -- the declarations to be demoted.
   example:
    module Test where        demote 'sq'       module Test where
    sumSquares x y               ===>          sumSquares x y =(sq 0) + (sq y)
      = sq x 0+ sq x y                               where sq y=x ^ y
    sq x y=x^y
-}
--PROBLEM: TYPE SIGNATURE SHOULD BE CHANGED.
--- TEST THIS FUNCTION!!!
foldParams :: [GHC.Name]             -- ^The (list?) function name being demoted
           -> GHC.Match GHC.Name     -- ^The RHS of the place to receive the demoted decls
           -> [GHC.LHsBind GHC.Name] -- ^Binds of original top level entiity, including src and dst
           -> GHC.LHsBind GHC.Name   -- ^The decls being demoted
           -> [GHC.LSig GHC.Name]    -- ^Signatures being demoted, if any
           -> Maybe [PosToken]          -- ^Tokens if provided
           -> RefactGhc (GHC.Match GHC.Name)
foldParams pns ((GHC.Match pats mt rhs)::GHC.Match GHC.Name) _decls demotedDecls dsig dtoks

     =do
         logm $ "MoveDef.foldParams entered"
         -- logm $ "MoveDef.foldParams:match=" ++ (SYB.showData SYB.Renamer 0 match)

         let matches=concatMap matchesInDecls [GHC.unLoc demotedDecls]
             pn=ghead "foldParams" pns    --pns /=[]
         params <- allParams pn rhs []
         if (length.nub.map length) params==1                  -- have same number of param 
             && ((length matches)==1)      -- only one 'match' in the demoted declaration
           then do
                   let patsInDemotedDecls=(patsInMatch.(ghead "foldParams")) matches
                       subst=mkSubst patsInDemotedDecls params
                       fstSubst=map fst subst
                       sndSubst=map snd subst

                   -- logm $ "MoveDef.foldParams before rmParamsInParent"
                   rhs' <- rmParamsInParent pn sndSubst rhs
                   -- logm $ "MoveDef.foldParams after rmParamsInParent"

                   -- ls<-mapM hsFreeAndDeclaredPNs sndSubst
                   -- ls <- mapM hsFreeAndDeclaredPNs sndSubst
                   let ls = map hsFreeAndDeclaredPNs sndSubst
                   -- newNames contains the newly introduced names to the demoted decls---
                   -- let newNames=(map pNtoName (concatMap fst ls)) \\ (map pNtoName fstSubst)
                   let newNames=((concatMap fst ls)) \\ (fstSubst)
                   --There may be name clashing because of introducing new names.
                   clashedNames<-getClashedNames fstSubst newNames (ghead "foldParams" matches)

                   logm $ "MoveDef.foldParams about to foldInDemotedDecls"

                   -- decls' <- foldInDemotedDecls pns clashedNames subst decls
                   -- let demotedDecls''' = definingDeclsNames pns decls' True False
                   demotedDecls''' <- foldInDemotedDecls pns clashedNames subst [demotedDecls]
                   logm $ "MoveDef.foldParams foldInDemotedDecls done"

                   let [(GHC.L declSpan _)] = demotedDecls'''
                   declToks <- getToksForSpan declSpan
                   logm $ "MoveDef.foldParams addDecl adding to (hsBinds):[" ++ (SYB.showData SYB.Renamer 0 $ hsBinds rhs') ++ "]" -- ++AZ++
                   rhs'' <- addDecl rhs' Nothing (ghead "foldParams 2" demotedDecls''',[],Just declToks) False
                   logm $ "MoveDef.foldParams addDecl done"
                   return (GHC.Match pats mt rhs'')
           else  do  -- moveDecl pns match False decls True
                     -- return (HsMatch loc1 name pats rhs (ds++demotedDecls))  -- no parameter folding 
                     logm $ "MoveDef.foldParams about to addDecl:dtoks=" ++ (show dtoks)
                     drawTokenTree "" -- ++AZ++ debug
                     rhs' <- addDecl rhs Nothing (demotedDecls,dsig,dtoks) False
                     return (GHC.Match pats mt rhs')

         -- return match
    where

       -- matchesInDecls ((Dec (HsFunBind loc matches))::HsDeclP)=matches
       matchesInDecls (GHC.FunBind _ _ (GHC.MatchGroup matches _) _ _ _) = matches
       matchesInDecls _x = []

       -- patsInMatch ((HsMatch loc1 name pats rhs ds)::HsMatchP)
       --   =pats
       patsInMatch (GHC.L _ (GHC.Match pats _ _)) = pats

       -- demotedDecls = map GHC.unLoc $ definingDeclsNames pns decls True False


       foldInDemotedDecls :: [GHC.Name]  -- ^The (list?) of names to be demoted
                          -> [GHC.Name]  -- ^Any names that clash
                          -> [(GHC.Name, GHC.HsExpr GHC.Name)] -- ^Parameter substitutions required
                          -> [GHC.LHsBind GHC.Name] -- ^Binds of original top level entiity, including src and dst
                          -> RefactGhc [GHC.LHsBind GHC.Name]
       foldInDemotedDecls  pns clashedNames subst decls
          = everywhereMStaged SYB.Renamer (SYB.mkM worker) decls
          where
          -- worker (match@(HsMatch loc1 (PNT pname _ _) pats rhs ds)::HsMatchP)
          worker (match@(GHC.FunBind (GHC.L _ pname) _ (GHC.MatchGroup _matches _) _ _ _) :: GHC.HsBind GHC.Name)
            | isJust (find (==pname) pns)
            = do
                 match'  <- foldM (flip (autoRenameLocalVar True)) match clashedNames
                 match'' <- foldM replaceExpWithUpdToks match' subst
                 rmParamsInDemotedDecls (map fst subst) match''

          worker x = return x

      ------Get all of the paramaters supplied to pn ---------------------------
            {- eg. sumSquares x1 y1 x2 y2 = rt x1 y1 + rt x2 y2
                   rt x y = x+y
              demote 'rt' to 'sumSquares',
              'allParams pn rhs []'  returns [[x1,x2],[y1,y2]]
                where pn is 'rt' and  rhs is 'rt x1 y1 + rt x2 y2'
           -}

       allParams :: GHC.Name -> GHC.GRHSs GHC.Name -> [[GHC.HsExpr GHC.Name]]
                 -> RefactGhc [[GHC.HsExpr GHC.Name]]
       allParams pn rhs initial  -- pn: demoted function/pattern name.
        =do -- p<-getOneParam pn rhs
            let p = getOneParam pn rhs
            -- putStrLn (show p)
            if (nonEmptyList p) then do rhs' <- rmOneParam pn rhs
                                        -- error $ "allParams: rhs=" ++ (SYB.showData SYB.Renamer 0 rhs) -- ++AZ++
                                        -- error $ "allParams: rhs'=" ++ (SYB.showData SYB.Renamer 0 rhs') -- ++AZ++
                                        allParams pn rhs' (initial++[p])
                     else return initial
        where
           getOneParam :: (SYB.Data t) => GHC.Name -> t -> [GHC.HsExpr GHC.Name]
           getOneParam pn
              = SYB.everythingStaged SYB.Renamer (++) []
                   ([] `SYB.mkQ`  worker)
              -- =applyTU (stop_tdTU (failTU `adhocTU` worker))
                where
                  worker :: GHC.HsExpr GHC.Name -> [GHC.HsExpr GHC.Name]
                  worker (GHC.HsApp e1 e2)
                   |(expToName e1==pn) = [GHC.unLoc e2]
                  worker _ = []
           rmOneParam :: (SYB.Data t) => GHC.Name -> t -> RefactGhc t
           rmOneParam pn t
              -- This genuinely needs to be done once only. Damn.
              -- =applyTP (stop_tdTP (failTP `adhocTP` worker))
             = do
                -- _ <- clearRefactDone
                everywhereMStaged' SYB.Renamer (SYB.mkM worker) t
                where
                  {-
                  worker :: GHC.HsExpr GHC.Name -> RefactGhc (GHC.HsExpr GHC.Name)
                  worker e@(GHC.HsApp e1 e2 ) = do -- The param being removed is e2
                    done <- getRefactDone
                    case (not done) && expToName e1==pn of
                      True ->  do setRefactDone
                                  return (GHC.unLoc e1)
                      False -> return e
                  worker x = return x
                  -}
                  worker (GHC.HsApp e1 _e2 ) -- The param being removed is e2
                    |expToName e1==pn = return (GHC.unLoc e1)
                  worker x = return x
{-
              AST output

                 addthree x y z

              becomes

                  (HsApp
                    (L {test/testdata/Demote/WhereIn6.hs:10:17-28}
                     (HsApp
                      (L {test/testdata/Demote/WhereIn6.hs:10:17-26}
                       (HsApp
                        (L {test/testdata/Demote/WhereIn6.hs:10:17-24}
                         (HsVar {Name: WhereIn6.addthree}))
                        (L {test/testdata/Demote/WhereIn6.hs:10:26}
                         (HsVar {Name: x}))))
                      (L {test/testdata/Demote/WhereIn6.hs:10:28}
                       (HsVar {Name: y}))))
                    (L {test/testdata/Demote/WhereIn6.hs:10:30}
                     (HsVar {Name: z})))

-----
                  (HsApp
                     (HsApp
                       (HsApp
                         (HsVar {Name: WhereIn6.addthree}))
                         (HsVar {Name: x}))))
                       (HsVar {Name: y}))))
                     (HsVar {Name: z})))

-----

                  sq p x

               becomes

                  (HsApp
                   (HsApp
                     (HsVar {Name: Demote.WhereIn4.sq}))
                     (HsVar {Name: p}))))
                   (HsVar {Name: x})))

----
                  sq x

               becomes

                  (HsApp
                   (HsVar {Name: sq}))
                   (HsVar {Name: x})))
-}


       -----------remove parameters in demotedDecls-------------------------------
       rmParamsInDemotedDecls :: [GHC.Name] -> GHC.HsBind GHC.Name
                              -> RefactGhc (GHC.HsBind GHC.Name)
       rmParamsInDemotedDecls ps bind
         -- = error $ "rmParamsInDemotedDecls: (ps,bind)=" ++ (showGhc (ps,bind)) -- ++AZ++
         -- =applyTP (once_tdTP (failTP `adhocTP` worker))
         = everywhereMStaged SYB.Renamer (SYB.mkM worker) bind
            -- where worker ((HsMatch loc1 name pats rhs ds)::HsMatchP)
            where worker (GHC.Match pats typ rhs)
                    = do
                         let pats'=filter (\x->not ((patToPNT x /= Nothing) &&
                                          elem (fromJust $ patToPNT x) ps)) pats

                         let (startPos,endPos) = getBiggestStartEndLoc pats
                         -- error $ "rmParamsInDemotedDecls:(startPos,endPos)=" ++ (show (startPos,endPos)) -- ++AZ++
                         -- error $ "rmParamsInDemotedDecls:(prettyprint pats')=" ++ (prettyprint pats) -- ++AZ++
                         if (emptyList pats')
                           then removeToksForPos (startPos,endPos)
                           else -- updateToksWithPos (startPos,endPos) pats' prettyprint False
                                updateToksWithPos (startPos,endPos) pats' pprPat False
                         -- toks <- fetchToks
                         -- error $ "rmParamsInDemotedDecls:(toks)=" ++ (showToks toks) -- ++AZ++
                         -- let (toks1, _, toks2)  = splitToks (startPos, (endRow,(endCol - 1))) toks
                         -- error $ "rmParamsInDemotedDecls:(last toks1,head toks2)=" ++ (showToks [last toks1, head toks2]) -- ++AZ++

                         -- pats'' <- update pats pats' pats

                         return (GHC.Match pats' typ rhs)

       pprPat pat = intercalate " " $ map (\p -> (prettyprint p )) pat

       ----------remove parameters in the parent functions' rhs-------------------
       --Attention: PNT i1 _ _==PNT i2 _ _ = i1 =i2
       rmParamsInParent :: GHC.Name -> [GHC.HsExpr GHC.Name] -> GHC.GRHSs GHC.Name 
                        -> RefactGhc (GHC.GRHSs GHC.Name)
       rmParamsInParent pn es
         -- =applyTP (full_buTP (idTP `adhocTP` worker))
         = everywhereMStaged SYB.Renamer (SYB.mkM worker)
            where worker exp@(GHC.L _ (GHC.HsApp e1 e2))
                   -- was | findPN pn e1 && (elem (GHC.unLoc e2) es)
                   | findPN pn e1 && (elem (showGhc (GHC.unLoc e2)) (map (showGhc) es))
                      = update exp e1 exp
                  worker (exp@(GHC.L _ (GHC.HsPar e1)))
                    |pn==expToName e1
                       = update exp e1 exp
                  worker x =return x


       getClashedNames oldNames newNames match
         = do  let (_f,d) = hsFDsFromInside match
               -- ds' <- mapM (flip hsVisiblePNs match) oldNames
               let ds' = map (flip hsVisiblePNs match) oldNames
               -- return clashed names
               return (filter (\x->elem ({- pNtoName -} x) newNames)  --Attention: nub
                                   ( nub (d `union` (nub.concat) ds')))
       {-
       getClashedNames oldNames newNames (match::HsMatchP)
         = do  (f,d)<-hsFDsFromInside match
               ds'<-mapM (flip hsVisiblePNs match) oldNames
               -- return clashed names
               return (filter (\x->elem (pNtoName x) newNames)  --Attention: nub
                                   ( nub (d `union` (nub.concat) ds')))
       -}
       ----- make Substitions between formal and actual parameters.-----------------
       mkSubst :: [GHC.LPat GHC.Name] -> [[GHC.HsExpr GHC.Name]] -> [(GHC.Name,GHC.HsExpr GHC.Name)]
       mkSubst pats params
           = catMaybes (zipWith (\x y -> if (patToPNT x/=Nothing) && (length (nub $ map showGhc y)==1)
                                          then Just (fromJust $ patToPNT x,(ghead "mkSubst") y)
                                          else Nothing) pats params)
           {-
           = catMaybes (zipWith (\x y ->if (patToPN x/=defaultPN) && (length (nub y)==1)
                            then Just (patToPN x,(ghead "mkSubst") y)
                            else Nothing) pats params)
           -}


-- |substitute an old expression by new expression
replaceExpWithUpdToks :: (SYB.Data t)
                      => t -> (GHC.Name, GHC.HsExpr GHC.Name)
                      -> RefactGhc t
replaceExpWithUpdToks  decls subst
  -- = applyTP (full_buTP (idTP `adhocTP` worker)) decls
  = everywhereMStaged' SYB.Renamer (SYB.mkM worker) decls
         where worker (e@(GHC.L l _)::GHC.LHsExpr GHC.Name)
                 |(expToName e/=defaultName) &&  (expToName e)==(fst subst)
                     = update e (GHC.L l (snd subst)) e
               worker x=return x



-- | return True if pn is a local function/pattern name
isLocalFunOrPatName :: SYB.Data t => GHC.Name -> t -> Bool
isLocalFunOrPatName pn scope
 = isLocalPN pn && isFunOrPatName pn scope

{-
-- |removeTypeSig removes the signature declaration for pn from the decl list.
-- removeTypeSig :: GHC.Name->[HsDeclP]->[HsDeclP]
removeTypeSig pn decls = decls
  -- ++ AZ++ TODO: make use of rmTypeSig pn decls from TypeUtils
-}

-- |Divide a declaration list into three parts (before, parent, after)
-- according to the PNT, where 'parent' is the first decl containing
-- the PNT, 'before' are those decls before 'parent' and 'after' are
-- those decls after 'parent'.

-- ++AZ++ : Not sure if this is meaningful with renamed source.

-- divideDecls::[HsDeclP]->PNT->([HsDeclP],[HsDeclP],[HsDeclP])
divideDecls ::
  SYB.Data a =>
  [a] -> GHC.Located GHC.Name -> ([a], [a], [a])
divideDecls ds pnt
  -- = error "undefined divideDecls"
  = let (before,after)=break (\x->findPNT pnt x) ds
    in if (not $ emptyList after)
         then (before, [ghead "divideDecls" after], tail after)
         else (ds,[],[])
