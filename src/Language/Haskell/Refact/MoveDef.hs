{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}

module Language.Haskell.Refact.MoveDef
  ( liftToTopLevel, doLiftToTopLevel
  -- , liftOneLevel, doLiftOneLevel
  , demote, doDemote
  -- ,liftingInClientMod
  ) where

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import qualified FastString            as GHC
import qualified GHC
import qualified OccName               as GHC
import qualified Outputable            as GHC

import Control.Monad.State
import Data.List
import Data.Maybe

import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

import Debug.Trace

-- ---------------------------------------------------------------------

data Direction = UptoTopLevel | UpOneLevel | Down

{--------This function handles refactorings involving moving a definition--------
 According to the Haskell's  syntax, a declaration may occur in one of the following six contexts:
  1. A top level declaration in the module:
            HsModule SrcLoc ModuleName (Maybe [HsExportSpecI i]) [HsImportDeclI i] ds
  2. A local declaration in a Match:
            HsMatch SrcLoc i [p] (HsRhs e) ds
  3. A local declaration in a pattern binding:
            HsPatBind SrcLoc p (HsRhs e) ds
  4. A local declaration in a Let expression:
            HsLet ds e
  5. A local declaration in a Case alternative:
            HsAlt SrcLoc p (HsRhs e) ds
  6. A local declaration in a Do statement:
            HsLetStmt ds (HsStmt e p ds)
-}

-- TODO: This boilerplate will be moved to the coordinator, just comp will be exposed
doLiftToTopLevel :: [String] -> IO () -- For now
doLiftToTopLevel args
 = do let fileName = ghead "filename" args
          row      = read (args!!1)::Int
          col      = read (args!!2)::Int
      liftToTopLevel Nothing  Nothing fileName (row,col)
      return ()

-- | The API entry point
liftToTopLevel :: Maybe RefactSettings -> Maybe FilePath -> FilePath -> SimpPos -> IO ()
liftToTopLevel settings maybeMainFile fileName (row,col) =
  runRefacSession settings (compLiftToTopLevel maybeMainFile fileName (row,col))


compLiftToTopLevel :: Maybe FilePath -> FilePath -> SimpPos
     -> RefactGhc [ApplyRefacResult]
compLiftToTopLevel maybeMainFile fileName (row,col) = do
      loadModuleGraphGhc maybeMainFile
      modInfo@(t, _tokList) <- getModuleGhc fileName
      renamed <- getRefactRenamed
      parsed  <- getRefactParsed

      let (Just (modName,_)) = getModuleName parsed
      let maybePn = locToName (GHC.mkFastString fileName) (row, col) renamed
      case maybePn of
        Just pn ->  do
            liftToTopLevel' modName modInfo fileName pn
        _       ->  error "\nInvalid cursor position!\n"


-- ---------------------------------------------------------------------

doDemote args
 = do let  fileName = ghead "filename"  args
           row = read (args!!1)::Int
           col = read (args!!2)::Int
      demote Nothing Nothing fileName (row,col)
      return ()

-- | The API entry point
demote :: Maybe RefactSettings -> Maybe FilePath -> FilePath -> SimpPos -> IO ()
demote settings maybeMainFile fileName (row,col) =
  runRefacSession settings (compDemote maybeMainFile fileName (row,col))

compDemote :: Maybe FilePath -> FilePath -> SimpPos
         -> RefactGhc [ApplyRefacResult]
compDemote maybeMainFile fileName (row,col) = do
      loadModuleGraphGhc maybeMainFile

      modInfo@(_t, _tokList) <- getModuleGhc fileName
      renamed <- getRefactRenamed
      parsed  <- getRefactParsed

      let (Just (modName,_)) = getModuleName parsed
      let maybePn = locToName (GHC.mkFastString fileName) (row, col) renamed
      case maybePn of
        Just pn -> do
          demote' modName fileName modInfo pn
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
   This refactoring lifts a local function/pattern binding to the top level of the module, so as to 
    make it accessible to  other functions in the current module, and those modules that import 
    current module.

   In the current implementation, a definition will be lifted only if none of the identifiers defined in this
   definition will cause name clash/capture problems in the current module after lifting. 

   In the case that the whole current module is exported implicitly, the lifted identifier will be  exported
   automatically after lifting. If the identifier will cause name clash/ambiguous occurrence problem in a 
   client module, it will be hided in the import declaration of the client module (Note: this might not be 
   the best solution, we prefer hiding it in the server module instead of in the client module in the final version).

   In the case of indirect importing, it might be time-consuming to trace whether the lifted identifier
   will cause any problem in a client module that indirectly imports the current  module. The current solution is:
   suppose a defintion is lifted to top level in module A, and module A is imported and exported by module B, then
   the lifted identifier will be hided in the import declaration of B no matter whether it causes problems in 
   module B or not.

   Function name: liftToTopLevel
   parameters: fileName--current file name.
               mod -- the scoped abstract syntax tree of the module.
               pn  -- the function/pattern name to be lifted.
-}

-}

liftToTopLevel' :: GHC.ModuleName -> (ParseResult,[PosToken]) -> FilePath
                -> GHC.Located GHC.Name
                -> RefactGhc [ApplyRefacResult]
liftToTopLevel' modName _modInfo _fileName pn@(GHC.L _ n) = do
  renamed <- getRefactRenamed
  parsed  <- getRefactParsed
  if isLocalFunOrPatName n renamed
      then do -- ((mod',declPns),((toks',m),_))<-runStateT liftToMod ((toks,unmodified),(-1000,0))
              refactoredMod <- applyRefac (liftToMod) (Just _modInfo) _fileName

              if modIsExported parsed
               then do clients<-clientModsAndFiles modName
                       -- TODO: Complete this
                       -- refactoredClients <- mapM (liftingInClientMod modName declPns) clients
                       -- writeRefactoredFiles False $ ((fileName,m),(toks',mod')):refactoredClients
                       return (refactoredMod:[])
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
       liftToMod = do renamed <- getRefactRenamed
                      let declsr = hsBinds renamed
                      let (before,parent,after) = divideDecls declsr pn
                      -- error ("liftToMod:(before,parent,after)=" ++ (GHC.showPpr (before,parent,after))) -- ++AZ++
                      {- ++AZ++ : hsBinds does not return class or instance definitions
                      when (isClassDecl $ ghead "liftToMod" parent)
                            $ error "Sorry, the refactorer cannot lift a definition from a class declaration!"
                      when (isInstDecl $ ghead "liftToMod" parent)
                            $ error "Sorry, the refactorer cannot lift a definition from an instance declaration!"
                      -}
                      let liftedDecls = definingDeclsNames [n] parent True True
                          declaredPns = nub $ concatMap definedPNs liftedDecls
                      pns <- pnsNeedRenaming renamed parent liftedDecls declaredPns
                      let (_,dd) = hsFreeAndDeclaredPNs renamed
                      if pns==[]
                        then do (parent',liftedDecls',paramAdded)<-addParamsToParentAndLiftedDecl n dd parent liftedDecls
                                let liftedDecls''=if paramAdded then filter isFunOrPatBindR liftedDecls'
                                                                else liftedDecls'

                                -- error ("liftToMod:newBinds=" ++ (GHC.showPpr (replaceBinds declsr (before++parent'++after)))) -- ++AZ++
                                -- mod'<-moveDecl1 (replaceDecls declsr (before++parent'++after))
                                mod'<-moveDecl1 (replaceBinds renamed (before++parent'++after))
                                       (Just (ghead "liftToMod" (definedPNs (ghead "liftToMod2" parent')))) 
                                       [GHC.unLoc pn] True
                                -- return (mod', declaredPns)
                                return ()

                        else askRenamingMsg pns "lifting"


{-
liftToTopLevel' modName fileName (inscps, mod, toks) pnt@(PNT pn _ _)
  = if isLocalFunOrPatName pn mod
      then do ((mod',declPns),((toks',m),_))<-runStateT liftToMod ((toks,unmodified),(-1000,0))
              if modIsExported mod
               then do clients<-clientModsAndFiles modName
                       refactoredClients <- mapM (liftingInClientMod modName declPns) clients
                       writeRefactoredFiles False $ ((fileName,m),(toks',mod')):refactoredClients
               else do writeRefactoredFiles False [((fileName,m), (toks',mod'))]
      else error "\nThe identifier is not a local function/pattern name!"

     where
          {-step1: divide the module's top level declaration list into three parts:
            'parant' is the top level declaration containing the lifted declaration,
            'before' and `after` are those declarations before and after 'parent'.
            step2: get the declarations to be lifted from parent, bind it to liftedDecls 
            step3: remove the lifted declarations from parent and extra arguments may be introduce.
            step4. test whether there are any names need to be renamed.
          -}
       liftToMod = do let (before, parent,after)=divideDecls (hsDecls mod) pnt
                      when (isClassDecl $ ghead "liftToMod" parent)
                            $ error "Sorry, the refactorer cannot lift a definition from a class declaration!"
                      when (isInstDecl $ ghead "liftToMod" parent)
                            $ error "Sorry, the refactorer cannot lift a definition from an instance declaration!"
                      let liftedDecls=definingDecls [pn] parent True True
                          declaredPns=nub $ concatMap definedPNs liftedDecls
                      pns<-pnsNeedRenaming inscps mod parent liftedDecls declaredPns
                      (_,dd)<-hsFreeAndDeclaredPNs mod
                      if pns==[]
                        then do (parent',liftedDecls',paramAdded)<-addParamsToParentAndLiftedDecl pn dd parent liftedDecls
                                let liftedDecls''=if paramAdded then filter isFunOrPatBind liftedDecls'
                                                                else liftedDecls'
                                mod'<-moveDecl1 (replaceDecls mod (before++parent'++after))
                                       (Just (ghead "liftToMod" (definedPNs (ghead "liftToMod2" parent')))) [pn] True
                                return (mod', declaredPns)
                        else askRenamingMsg pns "lifting"
-}

-- TODO: move this to TypeUtils, as moveDecl
moveDecl1 :: (HsValBinds t)
  => t -- ^ The syntax element to update
  -> Maybe GHC.Name -- ^ If specified, add defn after this one

     -- TODO: make this next parameter a single value, not a list,
     -- after module complete
  -> [GHC.Name]     -- ^ The first one is the decl to move
  -> Bool           -- ^True if moving to the top level
  -> RefactGhc t    -- ^ The updated syntax element (and tokens in monad)
moveDecl1 t defName ns topLevel
   = do
        -- TODO: work with all of ns, not just the first
        let n = ghead "moveDecl1" ns
        let funBinding = definingDeclsNames [n] (hsBinds t) True True

        logm $ "moveDecl1: (ns,funBinding)=" ++ (GHC.showPpr (ns,funBinding)) -- ++AZ++

        let Just sspan = getSrcSpan funBinding
        funToks <- getToksForSpan sspan

        -- (t'',sigRemoved) <- rmTypeSig (ghead "moveDecl3.2"  ns) t
        (t'',sigsRemoved) <- rmTypeSigs ns t
        (t',_declRemoved,_sigRemoved)  <- rmDecl (ghead "moveDecl3.1"  ns) False t''

        let getToksForMaybeSig demotedSig@(GHC.L ss _) = 
                             do
                                                   sigToks <- getToksForSpan ss
                                                   return sigToks

        maybeToksSigMulti <- mapM getToksForMaybeSig sigsRemoved 
        let maybeToksSig = concat maybeToksSigMulti


        logm $ "moveDecl1:maybeToksSig=" ++ (show maybeToksSig) -- ++AZ++

        addDecl t' defName (ghead "moveDecl1 2" funBinding,sigsRemoved,Just (maybeToksSig ++ funToks)) topLevel



{-
--get all the declarations define in the scope of t
allDeclsIn t = fromMaybe [] (applyTU (full_tdTU (constTU [] `adhocTU` decl)) t)
               where decl (d::HsDeclP)
                       |isFunBind d || isPatBind d || isTypeSig d = Just [d]
                     decl _ = Just []
-}


askRenamingMsg pns str
  = error ("The identifier(s):" ++ prettyprint pns ++
           " will cause name clash/capture or ambiguity occurrence problem after "
           ++ str ++", please do renaming first!")
{- ++AZ++ original
askRenamingMsg pns str
  = error ("The identifier(s):" ++ showEntities showPNwithLoc pns ++
           " will cause name clash/capture or ambiguity occurrence problem after "
           ++ str ++", please do renaming first!")
-}

-- |Get the subset of 'pns' that need to be renamed before lifting.
pnsNeedRenaming :: (SYB.Data t1) =>
  t1 -> [GHC.LHsBind GHC.Name] -> t2 -> [GHC.Name] -> RefactGhc [GHC.Name]
pnsNeedRenaming dest parent liftedDecls pns
   =do r <- mapM pnsNeedRenaming' pns
       return (concat r)
  where
     pnsNeedRenaming' pn
       = do let (f,d) = hsFDsFromInside dest --f: free variable names that may be shadowed by pn
                                             --d: declaread variables names that may clash with pn
            let vs = hsVisiblePNs pn parent  --vs: declarad varaibles that may shadow pn
            let -- inscpNames = map (\(x,_,_,_)->x) $ inScopeInfo inscps
                vars = map pNtoName (nub (f `union` d `union` vs) \\ [pn]) -- `union` inscpNames
            -- if elem (pNtoName pn) vars  || isInScopeAndUnqualified (pNtoName pn) inscps && findEntity pn dest
            isInScope <- isInScopeAndUnqualifiedGhc (pNtoName pn)
            if elem (pNtoName pn) vars  || isInScope && findEntity pn dest

               then return [pn]
               else return []
     --This pNtoName takes into account the qualifier.
     pNtoName = GHC.showPpr

{- -- ++AZ++ original
   =do r<-mapM pnsNeedRenaming' pns
       return (concat r)
  where
     pnsNeedRenaming' pn
       = do (f,d)<-hsFDsFromInside dest  --f: free variable names that may be shadowed by pn
                                             --d: declaread variables names that may clash with pn
            vs<-hsVisiblePNs pn parent      --vs: declarad varaibles that may shadow pn
            let inscpNames = map (\(x,_,_,_)->x) $ inScopeInfo inscps
                vars = map pNtoName (nub (f `union` d `union` vs) \\ [pn]) -- `union` inscpNames
            if elem (pNtoName pn) vars  || isInScopeAndUnqualified (pNtoName pn) inscps && findEntity pn dest
               then return [pn]
               else return []
     --This pNtoName takes into account the qualifier.
     pNtoName (PN (UnQual i) orig)=i
     pNtoName (PN (Qual (PlainModule modName) i ) orig)=modName ++ "." ++ i
-}

--can not simply use PNameToExp, PNameToPat here because of the location information. 
addParamsToParent pn [] t = return t
addParamsToParent pn params t
  = error "undefined addParamsToParent"
{- ++AZ++ original
--can not simply use PNameToExp, PNameToPat here because of the location information. 
addParamsToParent pn [] t = return t
addParamsToParent pn params t
   =applyTP(full_buTP (idTP  `adhocTP` inExp)) t
   where
          inExp (exp@(Exp (HsId (HsVar (PNT pname ty loc))))::HsExpP)
            | pname==pn
             = do  let newExp=Exp (HsParen (foldl addParamToExp exp (map pNtoExp params)))
                   update exp newExp exp

          inExp x =return x

          addParamToExp  exp param
              =(Exp (HsApp exp param))
-}

{-
--Do refactoring in the client module.
-- that is to hide the identifer in the import declaration if it will cause any problem in the client module.

liftingInClientMod serverModName pns (modName, fileName)
  = do (inscps, exps ,mod ,ts) <- parseSourceFile fileName
       let modNames = willBeUnQualImportedBy serverModName mod
       if isJust modNames
        then let pns' = namesNeedToBeHided mod exps (fromJust modNames) pns
             in if pns' /= []
                 then do (mod', ((ts',m),_))<-runStateT (addHiding serverModName mod pns') ((ts,unmodified),(-1000,0))
                         return ((fileName,m), (ts',mod'))
                 else return ((fileName,unmodified), (ts,mod))
        else return ((fileName,unmodified),(ts,mod))


--Test whether an identifier defined in the modules specified by 'names' will be exported by current module.
willBeExportedByClientMod names mod
  = let exps = hsModExports mod
    in if isNothing exps
          then False
          else any isJust $ map (\y-> (find (\x-> (simpModule x==Just y)) (fromJust exps))) names
      where simpModule (ModuleE (SN m _)) = Just m
            simpModule _  = Nothing

--get the module name or alias name by which the lifted identifier will be imported automatically.
willBeUnQualImportedBy::HsName.ModuleName->HsModuleP->Maybe [HsName.ModuleName]
willBeUnQualImportedBy modName mod
   = let imps  = hsModImports mod
         ms =filter (\(HsImportDecl _ (SN modName1 _) qualify  as h)->modName==modName1 && (not qualify) && 
                          (isNothing h || (isJust h && ((fst (fromJust h))==True)))) imps
         in if ms==[] then Nothing
                      else Just $ nub $ map getModName ms

         where getModName (HsImportDecl _ (SN modName _) qualify  as h)
                 = if isJust as then simpModName (fromJust as)
                                else modName
               simpModName (SN m loc) = m

--get the subset of 'pns', which need to be hided in the import declaration in module 'mod'
namesNeedToBeHided mod exps modNames  pns
  = if willBeExportedByClientMod modNames mod
      then pns
      else concatMap needToBeHided pns
    where
      needToBeHided  pn
        = let name = pNtoName pn
          in if (usedWithoutQual name (hsModDecls mod) --the same name is used in the module unqualifiedly
                || usedWithoutQual name (hsModExports mod)  --the same name is exported unqualifiedly by an Ent decl
                || causeNameClashInExports pn name mod exps)
              then [pn]
              else []


-- **************************************************************************************************************--

{- Refactoring Names: 'liftOneLevel'
   Descritption:
    this refactoring lifts a local function/pattern binding only one level up.
    By 'lifting one-level up' ,I mean:
    case1: In a module (HsModule SrcLoc ModuleName (Maybe [HsExportSpecI i]) [HsImportDeclI i] ds):
           A local declaration D  will be lifted to the same level as the 'ds', if D is in the 
           where clause of one of ds's element declaration.

    case2: In a match ( HsMatch SrcLoc i [p] (HsRhs e) ds) :
          A local declaration D  will be lifted to the same level as the 'ds', if D is in the 
           where clause of one of ds's element declaration.
           A declaration D,say,in the rhs expression 'e' will be lifted to 'ds' if D is Not local to
           other declaration list in 'e'

    case3: In a pattern  binding (HsPatBind SrcLoc p (HsRhs e) ds):
           A local declaration D  will be lifted to the same level as the 'ds', if D is in the 
           where clause of one of ds's element declaration.
           A declaration D,say,in the rhs expression 'e' will be lifted to 'ds' if D is Not local to
           other declaration list in 'e'

    case4: In the Lex expression (Exp (HsLet ds e):
           A local declaration D  will be lifted to the same level as the 'ds', if D is in the 
           where clause of one of ds's element declaration.
           A declaration D, say, in the expression 'e' will be lifted to 'ds' if D is not local to
           other declaration list in 'e'
    case5: In the case Alternative expression:(HsAlt loc p rhs ds)
           A local declaration D  will be lifted to the same level as the 'ds', if D is in the 
           where clause of one of ds's element declaration.
           A declaration D in 'rhs' will be lifted to 'ds' if D is not local to other declaration 
           list in 'rhs'.

    case6: In the do statement expression:(HsLetStmt ds stmts)
           A local declaration D  will be lifted to the same level as the 'ds', if D is in the 
           where clause of one of ds's element declaration.
           A declaration D in 'stmts' will be lifted to 'ds' if D is not local to other declaration 
           list in 'stmts'.

Function name: liftOneLevel
parameters: fileName--current file name.
            mod -- the scoped abstract syntax tree of the module.
            pn  -- the function/pattern name to be lifted.

-}

liftOneLevel' modName fileName (inscps, mod, toks) pnt@(PNT pn _ _ )
   = if isLocalFunOrPatName pn mod
        then do (mod', ((toks',m),_))<-liftOneLevel''
                let (b, pns) = liftedToTopLevel pnt mod
                if b &&  modIsExported mod
                  then do clients<-clientModsAndFiles modName
                          refactoredClients <- mapM (liftingInClientMod modName pns) clients
                          -- ePutStrLn (show clients)
                          writeRefactoredFiles False $ ((fileName,m),(toks',mod')):refactoredClients
                  else writeRefactoredFiles False [((fileName,m), (toks',mod'))]
        else error "\nThe identifer is not a function/pattern name!"

   where
      liftOneLevel''=runStateT (applyTP ((once_tdTP (failTP `adhocTP` liftToMod
                                                            `adhocTP` liftToMatch
                                                            `adhocTP` liftToPattern 
                                                            `adhocTP` liftToLet
                                                             `adhocTP` liftToAlt
                                                            `adhocTP` liftToLetStmt))
                                          `choiceTP` failure) mod) ((toks,unmodified),(-1000,0))
           where
             --1. The defintion will be lifted to top level
             liftToMod (mod@(HsModule loc name exps imps ds):: HsModuleP)
                | definingDecls [pn] (hsDecls ds) False False /=[]  --False means not taking type signature into account 
                  =do ds'<-worker mod ds pn
                      return (HsModule loc name exps imps ds')
             liftToMod  _ =mzero

             --2. The definition will be lifted to the declaration list of a match
             liftToMatch (match@(HsMatch loc1 name pats rhs ds)::HsMatchP)
                 | definingDecls [pn] (hsDecls ds) False False/=[]
                  =do ds'<-worker match ds pn
                      return (HsMatch loc1 name pats rhs ds')

             liftToMatch (match@(HsMatch loc1 name pats rhs ds)::HsMatchP)
                 | definingDecls [pn] (hsDecls rhs) False False /=[]
                  = doLifting1 match pn
             liftToMatch _ =mzero

             --3. The definition will be lifted to the declaration list of a pattern binding 
             liftToPattern (pat@(Dec (HsPatBind loc p rhs ds))::HsDeclP)
                | definingDecls [pn] (hsDecls ds) False  False /=[]
                  =do ds'<-worker pat ds pn
                      return (Dec (HsPatBind loc p rhs ds'))

             liftToPattern (pat@(Dec (HsPatBind loc p rhs ds))::HsDeclP)
                | definingDecls [pn] (hsDecls rhs) False  False /=[]
                  =doLifting2 pat  pn
             liftToPattern _=mzero

             --4. The definition will be lifted to the declaration list in a let expresiion.
             liftToLet (letExp@(Exp (HsLet ds e))::HsExpP)
               | definingDecls [pn] (hsDecls ds) False  False/=[]
                =do ds' <-worker letExp ds pn
                    return (Exp (HsLet ds' e))

             liftToLet (letExp@(Exp (HsLet ds e))::HsExpP)  --Attention: ds can be empty!
               | definingDecls [pn] (hsDecls e) False  False /=[]
                = doLifting3 letExp pn
             liftToLet _ =mzero


             --5. The definition will be lifted to the declaration list in a alt
             liftToAlt (alt@(HsAlt loc p rhs ds)::(HsAlt (HsExpP) (HsPatP) [HsDeclP]))
                |definingDecls [pn] (hsDecls ds) False  False /=[]
                =do ds'<-worker alt ds pn
                    return (HsAlt loc p rhs ds')

             liftToAlt (alt@(HsAlt loc p rhs ds)::(HsAlt (HsExpP) (HsPatP) [HsDeclP]))
                |definingDecls [pn] (hsDecls rhs) False  False/=[]
                =doLifting4  alt  pn
             liftToAlt _=mzero

             --6. The defintion will be lifted to the declaration list in a let statement.
             liftToLetStmt (letStmt@(HsLetStmt ds stmts):: (HsStmt (HsExpP) (HsPatP) [HsDeclP]))
                |definingDecls [pn] (hsDecls ds) False  False/=[]
               =do ds'<-worker letStmt ds pn
                   return (HsLetStmt ds' stmts)

             liftToLetStmt (letStmt@(HsLetStmt ds stmts):: (HsStmt (HsExpP) (HsPatP) [HsDeclP])) 
                |definingDecls [pn] (hsDecls stmts) False False /=[]
               = doLifting5 letStmt pn
             liftToLetStmt _=mzero

             failure=idTP `adhocTP` mod
                where
                  mod (m::HsModuleP)
                   = error ( "Lifting this definition failed. "++
                           " This might be because that the definition to be lifted is defined in a class/instance declaration.")

             worker dest ds pn
                  =do let (before, parent,after)=divideDecls ds pnt
                          liftedDecls=definingDecls [pn] (hsDecls parent) True  False
                          declaredPns=nub $ concatMap definedPNs liftedDecls
                      (_, dd)<-hsFreeAndDeclaredPNs dest
                      pns<-pnsNeedRenaming inscps dest parent liftedDecls declaredPns
                      if pns==[]
                        then do
                                (parent',liftedDecls',paramAdded)<-addParamsToParentAndLiftedDecl pn dd
                                                                     parent liftedDecls 
                                let liftedDecls''=if paramAdded then filter isFunOrPatBind liftedDecls'
                                                                else liftedDecls'
                                --True means the new decl will be at the same level with its parant. 
                                dest'<-moveDecl1 (replaceDecls dest (before++parent'++after))
                                           (Just (ghead "liftToMod" (definedPNs (ghead "worker" parent')))) [pn] False
                                return (hsDecls dest')
                                --parent'<-doMoving declaredPns (ghead "worker" parent) True  paramAdded parent'
                                --return (before++parent'++liftedDecls''++after)
                        else askRenamingMsg pns "lifting"

             doLifting1 dest@(HsMatch loc1 name pats parent ds)  pn
               = do  let  liftedDecls=definingDecls [pn] (hsDecls parent) True  False
                          declaredPns=nub $ concatMap definedPNs liftedDecls
                     pns<-pnsNeedRenaming inscps dest parent liftedDecls declaredPns
                     (_, dd)<-hsFreeAndDeclaredPNs dest
                     if pns==[]
                       then do (parent',liftedDecls',paramAdded)<-addParamsToParentAndLiftedDecl pn dd parent liftedDecls
                               let liftedDecls''=if paramAdded then filter isFunOrPatBind liftedDecls'
                                                                else liftedDecls'
                               moveDecl1 (HsMatch loc1 name pats parent' ds) Nothing [pn] False 
                        else askRenamingMsg pns "lifting"
             doLifting2 dest@(Dec (HsPatBind loc p parent ds)) pn
               = do  let  liftedDecls=definingDecls [pn] (hsDecls parent) True  False
                          declaredPns=nub $ concatMap definedPNs liftedDecls
                     pns<-pnsNeedRenaming inscps dest parent liftedDecls declaredPns
                     (_, dd)<-hsFreeAndDeclaredPNs dest
                     if pns==[]
                       then do (parent',liftedDecls',paramAdded)<-addParamsToParentAndLiftedDecl pn dd parent liftedDecls
                               let liftedDecls''=if paramAdded then filter isFunOrPatBind liftedDecls'
                                                                else liftedDecls'
                               moveDecl1 (Dec (HsPatBind loc p parent' ds)) Nothing [pn] False 
                         else askRenamingMsg pns "lifting"

             doLifting3 dest@(Exp (HsLet ds parent)) pn
               = do  let  liftedDecls=definingDecls [pn] (hsDecls parent) True  False
                          declaredPns=nub $ concatMap definedPNs liftedDecls
                     pns<-pnsNeedRenaming inscps dest parent liftedDecls declaredPns
                     (_, dd)<-hsFreeAndDeclaredPNs dest
                     if pns==[]
                       then do (parent',liftedDecls',paramAdded)<-addParamsToParentAndLiftedDecl pn dd parent liftedDecls
                               let liftedDecls''=if paramAdded then filter isFunOrPatBind liftedDecls'
                                                                else liftedDecls'
                               moveDecl1 (Exp (HsLet ds parent')) Nothing [pn] False 
                         else askRenamingMsg pns "lifting"

             doLifting4 dest@(HsAlt loc p parent ds) pn
               = do  let  liftedDecls=definingDecls [pn] (hsDecls parent) True  False
                          declaredPns=nub $ concatMap definedPNs liftedDecls
                     pns<-pnsNeedRenaming inscps dest parent liftedDecls declaredPns
                     (_, dd)<-hsFreeAndDeclaredPNs dest
                     if pns==[]
                       then do (parent',liftedDecls',paramAdded)<-addParamsToParentAndLiftedDecl pn dd parent liftedDecls
                               let liftedDecls''=if paramAdded then filter isFunOrPatBind liftedDecls'
                                                                else liftedDecls'
                               moveDecl1 (HsAlt loc p parent' ds) Nothing [pn] False 
                         else askRenamingMsg pns "lifting"
             doLifting5 dest@(HsLetStmt ds parent) pn
               = do  let  liftedDecls=definingDecls [pn] (hsDecls parent) True  False
                          declaredPns=nub $ concatMap definedPNs liftedDecls
                     pns<-pnsNeedRenaming inscps dest parent liftedDecls declaredPns
                     (_, dd)<-hsFreeAndDeclaredPNs dest
                     if pns==[]
                       then do (parent',liftedDecls',paramAdded)<-addParamsToParentAndLiftedDecl pn dd parent liftedDecls
                               let liftedDecls''=if paramAdded then filter isFunOrPatBind liftedDecls'
                                                                else liftedDecls'
                               moveDecl1 (HsLetStmt ds parent') Nothing [pn] False 
                         else askRenamingMsg pns "lifting"



liftedToTopLevel pnt@(PNT pn _ _) (mod@(HsModule loc name exps imps ds):: HsModuleP)
  = if definingDecls [pn] (hsDecls ds) False True /=[]
     then let (_, parent,_) = divideDecls ds pnt
              liftedDecls=definingDecls [pn] (hsDecls parent) True True
              declaredPns  = nub $ concatMap definedPNs liftedDecls
          in (True, declaredPns)
     else (False, [])
-}

addParamsToParentAndLiftedDecl pn dd parent liftedDecls
  =do  let (ef,_) = hsFreeAndDeclaredPNs parent
       let (lf,_) = hsFreeAndDeclaredPNs liftedDecls
       let newParams=((nub lf)\\ (nub ef)) \\ dd  --parameters (in PName format) to be added to pn because of lifting
       if newParams/=[]
         then if  (any isComplexPatBind liftedDecls)
                then error "This pattern binding cannot be lifted, as it uses some other local bindings!"
                else do parent'<-{-addParamsToDecls parent pn newParams True-} addParamsToParent pn newParams parent
                        liftedDecls'<-addParamsToDecls liftedDecls pn newParams True 
                        return (parent', liftedDecls',True)
         else return (parent,liftedDecls,False)

{- ++AZ++ original
addParamsToParentAndLiftedDecl pn dd parent liftedDecls
  =do  (ef,_)<-hsFreeAndDeclaredPNs parent
       (lf,_)<-hsFreeAndDeclaredPNs liftedDecls
       let newParams=((nub lf)\\ (nub ef)) \\ dd  --parameters (in PName format) to be added to pn because of lifting
       if newParams/=[]
         then if  (any isComplexPatBind liftedDecls)
                then error "This pattern binding cannot be lifted, as it uses some other local bindings!"
                else do parent'<-{-addParamsToDecls parent pn newParams True-} addParamsToParent pn newParams parent
                        liftedDecls'<-addParamsToDecls liftedDecls pn newParams True 
                        return (parent', liftedDecls',True)
         else return (parent,liftedDecls,False)
-}

{-
--------------------------------End of Lifting-----------------------------------------
-}
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
  -> FilePath
  -> (ParseResult,[PosToken])
  -> GHC.Located GHC.Name
  -> RefactGhc [ApplyRefacResult]
demote' modName fileName modInfo@(mod,toks) (GHC.L _ pn) = do
  renamed <- getRefactRenamed
  parsed  <- getRefactParsed
  if isFunOrPatName pn renamed
    then do
       isTl <- isTopLevelPN pn
       if isTl && isExplicitlyExported pn renamed
          then error "This definition can not be demoted, as it is explicitly exported by the current module!"
          else do -- (mod',((toks',m),_))<-doDemoting pn fileName mod toks
                  refactoredMod <- applyRefac (doDemoting pn) (Just modInfo) fileName
                  -- isTl <- isTopLevelPN pn
                  if isTl && modIsExported parsed
                    then do let demotedDecls'= definingDeclsNames [pn] (hsBinds renamed) True False
                                declaredPns  = nub $ concatMap definedPNs demotedDecls'
                            -- clients<-clientModsAndFiles modName
                            -- TODO: Complete this
                            -- refactoredClients <-mapM (demotingInClientMod declaredPns) clients
                            -- writeRefactoredFiles False $ ((fileName,m),(toks',mod')):refactoredClients
                            return (refactoredMod:[])
                    -- else writeRefactoredFiles False [((fileName,m), (toks',mod'))]
                    else do return [refactoredMod]
    else error "\nInvalid cursor position!"


--Do refactoring in the client module, that is:
--a) Check whether the identifier is used in the module body
--b) If the identifier is not used but is hided by the import declaration, then remove it from the hiding.

demotingInClientMod pns (modName, fileName)
  = error "undefined demotingInClientMod"
{-
  = do (inscps, exps, mod ,ts) <- parseSourceFile fileName
       if any (\pn->findPN pn (hsModDecls mod) || findPN pn (hsModExports mod)) pns
          then error $ "This definition can not be demoted, as it is used in the client module '"++show modName++"'!"
          else if any (\pn->findPN pn (hsModImports mod)) pns
                  then do (mod',((ts',m),_))<-runStateT (rmItemsFromImport mod pns) ((ts,unmodified),(-1000,0))
                          return ((fileName,m), (ts',mod'))
                  else return ((fileName,unmodified), (ts,mod))
-}

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
  -- error ("doDemoting:renamed'=" ++ (GHC.showPpr renamed'))
  putRefactRenamed renamed'
  -- ren <- getRefactRenamed
  -- error ("doDemoting:ren=" ++ (GHC.showPpr ren))
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
         -- | definingDecls [pn] ds False False/=[]
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
         -- | definingDecls [pn] ds False False /=[]
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
         -- | definingDecls [pn] ds False False/=[]
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
         -- | definingDecls [pn] ds False False /=[]
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


{- ++ original ++
--Do refactoring in the client module, that is:
--a) Check whether the identifier is used in the module body
--b) If the identifier is not used but is hided by the import declaration, then remove it from the hiding.

demotingInClientMod pns (modName, fileName)
  = do (inscps, exps, mod ,ts) <- parseSourceFile fileName
       if any (\pn->findPN pn (hsModDecls mod) || findPN pn (hsModExports mod)) pns
          then error $ "This definition can not be demoted, as it is used in the client module '"++show modName++"'!"
          else if any (\pn->findPN pn (hsModImports mod)) pns
                  then do (mod',((ts',m),_))<-runStateT (rmItemsFromImport mod pns) ((ts,unmodified),(-1000,0))
                          return ((fileName,m), (ts',mod'))
                  else return ((fileName,unmodified), (ts,mod))


doDemoting  pn fileName mod toks
 =runStateT (applyTP ((once_tdTP (failTP `adhocTP` demoteInMod
                                         `adhocTP` demoteInMatch
                                         `adhocTP` demoteInPat
                                         `adhocTP` demoteInLet
                                         `adhocTP` demoteInAlt
                                         `adhocTP` demoteInStmt)) `choiceTP` failure) mod)
                     ((toks,unmodified),(-1000,0))
    where
       --1. demote from top level
       demoteInMod (mod@(HsModule loc name exps imps ds):: HsModuleP)
         |definingDecls [pn] ds False False /=[]
         = do mod'<-rmQualifier [pn] mod
              doDemoting' mod' pn
       demoteInMod _ =mzero

        --2. The demoted definition is a local decl in a match
       demoteInMatch (match@(HsMatch loc1 name pats rhs ds)::HsMatchP)
         | definingDecls [pn] ds False False/=[]
         = doDemoting' match pn
       demoteInMatch  _ =mzero

       --3. The demoted definition is a local decl in a pattern binding
       demoteInPat (pat@(Dec (HsPatBind loc p rhs ds))::HsDeclP)
         | definingDecls [pn] ds False False /=[]
          = doDemoting' pat pn
       demoteInPat _ =mzero

       --4: The demoted definition is a local decl in a Let expression
       demoteInLet (letExp@(Exp (HsLet ds e))::HsExpP)
         | definingDecls [pn] ds False False/=[]
          = doDemoting' letExp pn
       demoteInLet _=mzero

       --5. The demoted definition is a local decl in a case alternative.
       demoteInAlt (alt@(HsAlt loc p rhs ds)::(HsAlt (HsExpP) (HsPatP) [HsDeclP]))
         | definingDecls [pn] ds False False /=[]
          = doDemoting'  alt pn
       demoteInAlt _=mzero

       --6.The demoted definition is a local decl in a Let statement.
       demoteInStmt (letStmt@(HsLetStmt ds stmts):: (HsStmt (HsExpP) (HsPatP) [HsDeclP]))
         | definingDecls [pn] ds False False /=[]
          = doDemoting' letStmt pn
       demoteInStmt _=mzero

       failure=idTP `adhocTP` mod
             where
               mod (m::HsModuleP)
                = error "Refactoring failed!"   --SHOULD GIVE MORE DETAILED ERROR MESSAGE
-}

{- doDemoting' :(MonadPlus m)=>PName->[HsDeclP]->m [HsDeclP]
   parameters:  t -declaration or expression  where pn is define.
                pn -- the function/pattern name to be demoted in PName format

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
              -- logm $ "doDemoting':demotedDecls=" ++ (GHC.showPpr demotedDecls) -- ++AZ++
              -- find how many matches/pattern bindings (except the binding defining pn) use 'pn'
              -- uselist <- uses declaredPns (hsBinds t\\demotedDecls)
              let -- uselist = uses declaredPns (hsBinds t\\demotedDecls)
                  otherBinds = (deleteFirstsBy sameBind (hsBinds t) demotedDecls)
                  -- uselist = uses declaredPns otherBinds
                      {- From 'hsDecls t' to 'hsDecls t \\ demotedDecls'.
                         Bug fixed 06/09/2004 to handle direct recursive function.
                       -}
                  uselist = concatMap (\r -> if (emptyList r) then [] else ["Used"])$ map (\b -> uses declaredPns [b]) otherBinds
                  -- uselist' =map (\b -> uses declaredPns [b]) otherBinds
              case  length uselist  of
                  0 ->do error "\n Nowhere to demote this function!\n"
                  1 -> --This function is only used by one friend function
                      do
                         drawTokenTree "" -- ++AZ++ debug
                         logm "MoveDef.doDemoting':target location found" -- ++AZ++
                         -- (f,d)<-hsFreeAndDeclaredPNs demotedDecls
                         let (f,_d) = hsFreeAndDeclaredPNs demotedDecls
                         -- remove demoted declarations
                         --Without updating the token stream.
                         -- let ds=foldl (flip removeTypeSig) (hsBinds t\\demotedDecls) declaredPns
                         -- let ds=foldl (flip removeTypeSig) (deleteFirstsBy sameBind (hsBinds t) demotedDecls) declaredPns

                         -- ++AZ++ moved to after the rest, so the tree is still available to start with
                         (ds,removedDecl,_sigRemoved) <- rmDecl pn False (hsBinds t)
{-
                         (t',demotedSig) <- rmTypeSig pn t --TODO:
                                                           --reinstate
                                                           --declaredPns
                                                           --instead
                                                           --of pn
-}
                         -- (t',demotedSigsMaybe) <- foldM (\(tee,ds) n -> do { (tee',d) <- rmTypeSig n tee; return (tee', ds++[d])}) (t,[]) declaredPns
                         -- let demotedSigs = catMaybes demotedSigsMaybe
                         (t',demotedSigs) <- rmTypeSigs declaredPns t

                         let (GHC.L ssd _) = removedDecl
                         demotedToks <- getToksForSpan ssd

{-
                         demotedSigToks <- case demotedSig of
                                               Just (GHC.L ss _) -> do
                                                   sigToks <- getToksForSpan ss
                                                   return sigToks
                                               Nothing -> return []
-}
                         let getToksForMaybeSig demotedSig@(GHC.L ss _) = do
                                                   sigToks <- getToksForSpan ss
                                                   return sigToks

                         demotedSigToksLists <- mapM getToksForMaybeSig demotedSigs
                         let demotedSigToks = concat demotedSigToksLists

                         logm $ "MoveDef:demotedSigToks=" ++ (show demotedSigToks) -- ++AZ++

                         logm $ "MoveDef:sig and decl toks[" ++ (GHC.showRichTokenStream (demotedSigToks ++ demotedToks)) ++ "]" -- ++AZ++

                         --get those variables declared at where the demotedDecls will be demoted to
                         let dl = map (flip declaredNamesInTargetPlace ds) declaredPns
                         --make sure free variable in 'f' do not clash with variables in 'dl',
                         --otherwise do renaming.
                         let clashedNames=filter (\x-> elem (id x) (map id f)) $ (nub.concat) dl
                         --rename clashed names to new names created automatically,update TOKEN STREAM as well.
                         if clashedNames/=[]
                            then error ("The identifier(s):" ++ GHC.showPpr clashedNames ++
                                       ", declared in where the definition will be demoted to, will cause name clash/capture"
                                       ++" after demoting, please do renaming first!")  
                                 --ds'<-foldM (flip (autoRenameLocalVar True)) ds clashedNames
                            else  --duplicate demoted declarations to the right place.
                                 do
                                    logm $ "MoveDef: about to duplicateDecls"
                                    ds'' <- duplicateDecls declaredPns removedDecl demotedSigs (Just (demotedSigToks ++ demotedToks)) origDecls

                                    logm $ "MoveDef:duplicateDecls done"

                                    drawTokenTree "" -- ++AZ++ debug

                                    -- Finally, remove the original
                                    -- ds''' <- rmDecl pn True ds''
                                    -- t'' <- rmTypeSig pn t'
                                    -- t'' <- rmDecl pn True t



                                    return (replaceBinds t' ds'')
                                    -- return (t'')
                  _ ->error "\nThis function/pattern binding is used by more than one friend bindings\n"
                  -- _ ->error $ "\nThis function/pattern binding is used by more than one friend bindings\n" ++ (show uselist) -- ++AZ++

       else error "This function can not be demoted as it is used in current level!\n"
       -- else error ("doDemoting': demotedDecls=" ++ (GHC.showPpr demotedDecls)) -- ++AZ++
       -- else error ("doDemoting': declaredPns=" ++ (GHC.showPpr declaredPns)) -- ++AZ++
       -- else error ("doDemoting': (origDecls,demotedDecls',declaredPns,(usedByRhs t declaredPns))=" ++ (GHC.showPpr (origDecls,demotedDecls',declaredPns,(usedByRhs t declaredPns)))) -- ++AZ++


    where
          ---find how many matches/pattern bindings use  'pn'-------
          uses :: (SYB.Data t) => [GHC.Name] -> [t] -> [[String]]
          uses pns
               = SYB.everythingStaged SYB.Renamer (++) []
                   ([] `SYB.mkQ`  usedInMatch
                       `SYB.extQ` usedInPat)
                where
                  -- ++AZ++ Not in pattern, but is in RHS
                  -- usedInMatch (match@(HsMatch _ (PNT pname _ _) _ _ _)::HsMatchP)
                  usedInMatch ((GHC.Match pats _ rhs) :: GHC.Match GHC.Name)
                    -- | isNothing (find (==pname) pns) && any  (flip findPN match) pns
                    | (not $ findPNs pns pats) && findPNs pns rhs
                     = return ["Once"]
                  usedInMatch _ = mzero

                  -- usedInPat (pat@(Dec (HsPatBind _ p _ _)):: HsDeclP)
                  usedInPat ((GHC.PatBind pat rhs _ _ _) :: GHC.HsBind GHC.Name)
                    -- | hsPNs p `intersect` pns ==[]  && any  (flip findPN pat) pns
                    | (not $ findPNs pns pat) && findPNs pns rhs
                    = return ["Once"]
                  usedInPat  _=mzero


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
                   -- | any (flip findPN match) pns && not (any (flip findPN name) pns)
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
                    -- |any (flip findPN pat) pns && not (any (flip findPN p) pns)
                    | (not $ findPNs pns pat) && findPNs pns rhs
                   -- =  moveDecl pns pat False decls False
                   = do
                       -- rhs' <- moveDecl pns rhs False decls False
                       -- TODO: what wbout dtoks?
                       -- error "dupInPat" -- ++AZ++
                       rhs' <- moveDecl1 rhs Nothing pns False
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
                            -> [GHC.Name]
          declaredNamesInTargetPlace pn
             = SYB.everythingStaged SYB.Renamer (++) []
                   ([] `SYB.mkQ`  inMatch
                       `SYB.extQ` inPat)
               where
                 -- inMatch (match@(HsMatch loc1 name pats rhs ds)::HsMatchP)
                 inMatch ((GHC.Match pats _ rhs) :: GHC.Match GHC.Name)
                    | findPN pn rhs
                     -- =(return.snd)=<<hsFDsFromInside rhs
                     = (snd $ hsFDsFromInside rhs)
                 -- inMatch _ =mzero
                 inMatch _ = []

                 -- inPat (pat@(Dec (HsPatBind loc p rhs ds)):: HsDeclP)
                 inPat ((GHC.PatBind pat rhs _ _ _) :: GHC.HsBind GHC.Name)
                    |findPN pn rhs
                     -- =(return.snd)=<<hsFDsFromInside pat
                     = (snd $ hsFDsFromInside pat)
                 -- inPat _=mzero
                 inPat _ = []


{- ++original++
{- doDemoting' :(MonadPlus m)=>PName->[HsDeclP]->m [HsDeclP]
   parameters:  t -declaration or expression  where pn is define.
                pn -- the function/pattern name to be demoted in PName format

-}
doDemoting' t pn
 = let origDecls=hsDecls t
       demotedDecls'=definingDecls [pn] origDecls True False
       declaredPns=nub $ concatMap definedPNs demotedDecls'
       demotedDecls=definingDecls declaredPns origDecls True False
   in if not (usedByRhs t declaredPns)
       then do -- find how many matches/pattern bindings (except the binding defining pn) use 'pn' 
              uselist<-uses declaredPns (hsDecls t\\demotedDecls)
                      {- From 'hsDecls t' to 'hsDecls t \\ demotedDecls'.
                         Bug fixed 06/09/2004 to handle direct recursive function.
                       -}
              case  length uselist  of
                  0 ->do error "\n Nowhere to demote this function!\n"
                  1 -> --This function is only used by one friend function
                      do (f,d)<-hsFreeAndDeclaredPNs demotedDecls
                          -- remove demoted declarations
                         --Without updating the token stream.
                         let ds=foldl (flip removeTypeSig) (hsDecls t\\demotedDecls) declaredPns  
                         --get those varaibles declared at where the demotedDecls will be demoted to
                         dl  <-mapM (flip declaredNamesInTargetPlace ds) declaredPns
                         --make sure free variable in 'f' do not clash with variables in 'dl', 
                         --otherwise do renaming.
                         let clashedNames=filter (\x-> elem (pNtoName x) (map pNtoName f)) $ (nub.concat) dl
                         --rename clashed names to new names created automatically,update TOKEN STREAM as well.
                         if clashedNames/=[]
                            then error ("The identifier(s):" ++ showEntities showPNwithLoc clashedNames ++
                                       ", declared in where the definition will be demoted to, will cause name clash/capture"
                                       ++" after demoting, please do renaming first!")  
                                 --ds'<-foldM (flip (autoRenameLocalVar True)) ds clashedNames
                            else  --duplicate demoted declarations to the right place.
                                 do ds''<-duplicateDecls declaredPns origDecls
                                    return (replaceDecls t ds'')
                  _ ->error "\nThis function/pattern binding is used by more than one friend bindings\n"

      else error "This function can not be demoted as it is used in current level!\n"
    where
          ---find how many matches/pattern bindings use  'pn'-------
          uses pns
               = applyTU (stop_tdTU (failTU `adhocTU` usedInMatch
                                            `adhocTU` usedInPat))
                where
                  usedInMatch (match@(HsMatch _ (PNT pname _ _) _ _ _)::HsMatchP)
                     | isNothing (find (==pname) pns) && any  (flip findPN match) pns
                     =return ["Once"]
                  usedInMatch _ =mzero

                  usedInPat (pat@(Dec (HsPatBind _ p _ _)):: HsDeclP)
                    | hsPNs p `intersect` pns ==[]  && any  (flip findPN pat) pns
                    =return ["Once"]
                  usedInPat  _=mzero

          -- duplicate demotedDecls to the right place (the outer most level where it is used).
          duplicateDecls  pns decls
             = do applyTP (once_tdTP (failTP `adhocTP` dupInMatch
                                             `adhocTP` dupInPat)) decls
                  --error (show decls' ++ "\n" ++ prettyprint decls')
                  -- rmDecl (ghead "moveDecl3"  pns) False =<<foldM (flip rmTypeSig) decls' pns 
               where
                 dupInMatch (match@(HsMatch loc1 name pats rhs ds)::HsMatchP)
                   | any (flip findPN match) pns && not (any (flip findPN name) pns)
                   =  --If not fold parameters.
                      moveDecl pns match False decls False
                      -- If fold parameters.
                      --foldParams pns match decls
                 dupInMatch _ =mzero

                 dupInPat (pat@(Dec (HsPatBind loc p rhs ds))::HsDeclP)
                    |any (flip findPN pat) pns && not (any (flip findPN p) pns)
                   =  moveDecl pns pat False decls False
                 dupInPat _ =mzero

                 demotedDecls=definingDecls pns decls True False
          ---------------------------------------------------------------------
          declaredNamesInTargetPlace :: (Term t, MonadPlus m)=>PName->t->m [PName]
          declaredNamesInTargetPlace pn=applyTU (stop_tdTU (failTU
                                                    `adhocTU` inMatch
                                                    `adhocTU` inPat))
               where
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
foldParams pns (match@(GHC.Match pats mt rhs)::GHC.Match GHC.Name) _decls demotedDecls dsig dtoks

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
          worker (match@(GHC.FunBind (GHC.L _ pname) _ (GHC.MatchGroup matches _) _ _ _) :: GHC.HsBind GHC.Name)
            | isJust (find (==pname) pns)
            = do
                 match'  <- foldM (flip (autoRenameLocalVar True)) match clashedNames
                 match'' <- foldM replaceExpWithUpdToks match' subst
                 rmParamsInDemotedDecls (map fst subst) match''

          worker x = return x

{- ++AZ++ original before auto-stashing
       foldInDemotedDecls :: [GHC.Name]  -- ^The (list?) of names to be demoted
                          -> [GHC.Name]  -- ^Any names that clash
                          -> [(GHC.Name, GHC.HsExpr GHC.Name)] -- ^Parameter substitutions required
                          -> [GHC.LHsBind GHC.Name] -- ^Binds of original top level entiity, including src and dst
                          -> RefactGhc [GHC.LHsBind GHC.Name]
       foldInDemotedDecls  pns clashedNames subst decls
          -- = applyTP (stop_tdTP (failTP `adhocTP` worker)) decls
          = everywhereMStaged SYB.Renamer (SYB.mkM worker) decls
          where
          -- worker (match@(HsMatch loc1 (PNT pname _ _) pats rhs ds)::HsMatchP)
          worker (match@(GHC.FunBind (GHC.L _ pname) _ (GHC.MatchGroup matches _) _ _ _) :: GHC.HsBind GHC.Name)
            | isJust (find (==pname) pns)
            = do match'  <- foldM (flip (autoRenameLocalVar True)) match clashedNames
                 match'' <- foldM replaceExpWithUpdToks match' subst
                 rmParamsInDemotedDecls (map fst subst) match''

          worker x = return x
-}


{-
       foldInDemotedDecls  pns clashedNames subst decls
          = applyTP (stop_tdTP (failTP `adhocTP` worker)) decls
          where
          worker (match@(HsMatch loc1 (PNT pname _ _) pats rhs ds)::HsMatchP)
            | isJust (find (==pname) pns)
            = do match' <- foldM (flip (autoRenameLocalVar True)) match clashedNames
                 match'' <- foldM replaceExpWithUpdToks match' subst
                 rmParamsInDemotedDecls (map fst subst) match''

          worker _ = mzero
-}

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
                  worker (GHC.HsApp e1 e2 ) -- The param being removed is e2
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



       {- ++AZ++ original
       allParams pn rhs initial  -- pn: demoted function/pattern name.
        =do p<-getOneParam pn rhs
            --putStrLn (show p)
            if p/=[] then do rhs'<-rmOneParam pn rhs
                             allParams pn rhs' (initial++[p])
                     else return initial
        where
           getOneParam pn
              =applyTU (stop_tdTU (failTU `adhocTU` worker))
                where
                  worker (Exp (HsApp e1 e2))
                   |(expToPN e1==pn) =return (rmLocs [e2])
                  worker _ =mzero
           rmOneParam pn
              =applyTP (stop_tdTP (failTP `adhocTP` worker))
                where
                  worker (Exp (HsApp e1 e2 ))
                    |expToPN e1==pn =return e1
                  worker _ =mzero
       -}

       -----------remove parameters in demotedDecls-------------------------------
       rmParamsInDemotedDecls :: [GHC.Name] -> GHC.HsBind GHC.Name
                              -> RefactGhc (GHC.HsBind GHC.Name)
       rmParamsInDemotedDecls ps bind
         -- = error $ "rmParamsInDemotedDecls: (ps,bind)=" ++ (GHC.showPpr (ps,bind)) -- ++AZ++
         -- =applyTP (once_tdTP (failTP `adhocTP` worker))
         = everywhereMStaged SYB.Renamer (SYB.mkM worker) bind
            -- where worker ((HsMatch loc1 name pats rhs ds)::HsMatchP)
            where worker (GHC.Match pats typ rhs)
                    = do let pats'=filter (\x->not ((patToPNT x /= Nothing) &&
                                          elem (fromJust $ patToPNT x) ps)) pats

                         let (startPos,endPos@(endRow,endCol)) = getBiggestStartEndLoc pats
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
{-
       rmParamsInDemotedDecls ps
         =applyTP (once_tdTP (failTP `adhocTP` worker))
            where worker ((HsMatch loc1 name pats rhs ds)::HsMatchP)
                    = do let pats'=filter (\x->not ((patToPN x /=defaultPN) &&
                                          elem (patToPN x) ps)) pats
                         pats'<-update pats pats' pats
                         return (HsMatch loc1 name pats' rhs ds)
-}

       ----------remove parameters in the parent functions' rhs-------------------
       --Attention: PNT i1 _ _==PNT i2 _ _ = i1 =i2
       rmParamsInParent :: GHC.Name -> [GHC.HsExpr GHC.Name] -> GHC.GRHSs GHC.Name 
                        -> RefactGhc (GHC.GRHSs GHC.Name)
       rmParamsInParent  pn es
         -- =applyTP (full_buTP (idTP `adhocTP` worker))
         = everywhereMStaged SYB.Renamer (SYB.mkM worker)
            where worker exp@(GHC.L _ (GHC.HsApp e1 e2))
                   -- | findPN pn e1 && (elem (GHC.unLoc e2) es)
                   | findPN pn e1 && (elem (GHC.showPpr (GHC.unLoc e2)) (map GHC.showPpr es))
                      = update exp e1 exp
                  worker (exp@(GHC.L _ (GHC.HsPar e1)))
                    |pn==expToName e1
                       = update exp e1 exp
                  worker x =return x

         {-
         =applyTP (full_buTP (idTP `adhocTP` worker))
            where worker exp@(Exp (HsApp e1 e2))
                   | findPN pn e1 && elem e2 es
                      =update exp e1 exp
                  worker (exp@(Exp (HsParen e1)))
                    |pn==expToPN e1
                       =update exp e1 exp
                  worker x =return x
          -}


       getClashedNames oldNames newNames match
         = do  let (f,d) = hsFDsFromInside match
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
           = catMaybes (zipWith (\x y ->if (patToPNT x/=Nothing) && (length (nub $ map GHC.showPpr y)==1)
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

{-
--substitute an old expression by new expression
replaceExpWithUpdToks  decls subst
  = applyTP (full_buTP (idTP `adhocTP` worker)) decls
         where worker (e::HsExpP)
                 |(expToPN e/=defaultPN) &&  (expToPN e)==(fst subst)
                     =update e (snd subst) e
               worker x=return x
-}

{- ++ original

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
--- TEST THIS FUCNTION!!!
foldParams pns (match@(HsMatch loc1 name pats rhs ds)::HsMatchP) decls
     =do let matches=concatMap matchesInDecls demotedDecls
             pn=ghead "foldParams" pns    --pns /=[]
         params<-allParams pn rhs []
         if (length.nub.map length) params==1                  -- have same number of param 
             && ((length matches)==1)      -- only one 'match' in the demoted declaration
           then do let patsInDemotedDecls=(patsInMatch.(ghead "foldParams")) matches
                       subst=mkSubst patsInDemotedDecls params
                       fstSubst=map fst subst
                       sndSubst=map snd subst
                   rhs'<-rmParamsInParent pn sndSubst rhs
                   ls<-mapM hsFreeAndDeclaredPNs sndSubst
                   -- newNames contains the newly introduced names to the demoted decls---
                   let newNames=(map pNtoName (concatMap fst ls)) \\ (map pNtoName fstSubst)
                   --There may be name clashing because of introducing new names.
                   clashedNames<-getClashedNames fstSubst newNames (ghead "foldParams" matches)
                  {- --auotmatic renaming
                   demotedDecls'<-foldM (flip (autoRenameLocalVar True)) demotedDecls clashedNames
                   demotedDecls''<- foldM replaceExpWithUpdToks demotedDecls' subst 
                   --remove substituted parameters in demoted declarations
                   demotedDecls'''<-rmParamsInDemotedDecls fstSubst demotedDecls'' -}
                   decls' <- foldInDemotedDecls pns clashedNames subst decls
                   let demotedDecls''' = definingDecls pns decls' True False
                   moveDecl pns (HsMatch loc1 name pats rhs' ds) False decls' False
                   return (HsMatch loc1 name pats rhs' (ds++(filter (not.isTypeSig) demotedDecls''')))
           else  do  moveDecl pns match False decls True
                     return (HsMatch loc1 name pats rhs (ds++demotedDecls))  -- no parameter folding 

    where

       matchesInDecls ((Dec (HsFunBind loc matches))::HsDeclP)=matches
       matchesInDecls x = []

       patsInMatch ((HsMatch loc1 name pats rhs ds)::HsMatchP)
         =pats

       demotedDecls=definingDecls pns decls True False


       foldInDemotedDecls  pns clashedNames subst decls
          = applyTP (stop_tdTP (failTP `adhocTP` worker)) decls
          where
          worker (match@(HsMatch loc1 (PNT pname _ _) pats rhs ds)::HsMatchP)
            | isJust (find (==pname) pns)
            = do match' <- foldM (flip (autoRenameLocalVar True)) match clashedNames
                 match'' <- foldM replaceExpWithUpdToks match' subst
                 rmParamsInDemotedDecls (map fst subst) match''

          worker _ = mzero


      ------Get all of the paramaters supplied to pn ---------------------------
            {- eg. sumSquares x1 y1 x2 y2 = rt x1 y1 + rt x2 y2
                   rt x y = x+y
              demote 'rt' to 'sumSquares',
              'allParams pn rhs []'  returns [[x1,x2],[y1,y2]]
                where pn is 'rt' and  rhs is 'rt x1 y1 + rt x2 y2'
           -}
       allParams pn rhs initial  -- pn: demoted function/pattern name.
        =do p<-getOneParam pn rhs
            --putStrLn (show p)
            if p/=[] then do rhs'<-rmOneParam pn rhs
                             allParams pn rhs' (initial++[p])
                     else return initial
        where
           getOneParam pn
              =applyTU (stop_tdTU (failTU `adhocTU` worker))
                where
                  worker (Exp (HsApp e1 e2))
                   |(expToPN e1==pn) =return (rmLocs [e2])
                  worker _ =mzero
           rmOneParam pn
              =applyTP (stop_tdTP (failTP `adhocTP` worker))
                where
                  worker (Exp (HsApp e1 e2 ))
                    |expToPN e1==pn =return e1
                  worker _ =mzero

       -----------remove parameters in demotedDecls-------------------------------
       rmParamsInDemotedDecls ps
         =applyTP (once_tdTP (failTP `adhocTP` worker))
            where worker ((HsMatch loc1 name pats rhs ds)::HsMatchP)
                    = do let pats'=filter (\x->not ((patToPN x /=defaultPN) &&
                                          elem (patToPN x) ps)) pats
                         pats'<-update pats pats' pats
                         return (HsMatch loc1 name pats' rhs ds)


       ----------remove parameters in the parent functions' rhs-------------------
       --Attention: PNT i1 _ _==PNT i2 _ _ = i1 =i2
       rmParamsInParent  pn es
         =applyTP (full_buTP (idTP `adhocTP` worker))
            where worker exp@(Exp (HsApp e1 e2))
                   | findPN pn e1 && elem e2 es
                      =update exp e1 exp
                  worker (exp@(Exp (HsParen e1)))
                    |pn==expToPN e1
                       =update exp e1 exp
                  worker x =return x

       getClashedNames oldNames newNames (match::HsMatchP)
         = do  (f,d)<-hsFDsFromInside match
               ds'<-mapM (flip hsVisiblePNs match) oldNames
               -- return clashed names
               return (filter (\x->elem (pNtoName x) newNames)  --Attention: nub
                                   ( nub (d `union` (nub.concat) ds')))
       ----- make Substitions between formal and actual parameters.-----------------
       mkSubst pats params
           = catMaybes (zipWith (\x y ->if (patToPN x/=defaultPN) && (length (nub y)==1)
                            then Just (patToPN x,(ghead "mkSubst") y)
                            else Nothing) pats params)


--substitute an old expression by new expression
replaceExpWithUpdToks  decls subst
  = applyTP (full_buTP (idTP `adhocTP` worker)) decls
         where worker (e::HsExpP)
                 |(expToPN e/=defaultPN) &&  (expToPN e)==(fst subst)
                     =update e (snd subst) e
               worker x=return x
-}

-- | return True if pn is a local function/pattern name
isLocalFunOrPatName pn scope
 = isLocalPN pn && isFunOrPatName pn scope

-- |removeTypeSig removes the signature declaration for pn from the decl list.
-- removeTypeSig :: GHC.Name->[HsDeclP]->[HsDeclP]
removeTypeSig pn decls = decls
  -- ++ AZ++ TODO: make use of rmTypeSig pn decls from TypeUtils

{- ++ original
-- |removeTypeSig removes the signature declaraion for pn from the decl list.
removeTypeSig ::PName->[HsDeclP]->[HsDeclP]
removeTypeSig pn decls=concatMap (removeTypeSig' pn) decls
      where removeTypeSig' pn sig@(Dec (HsTypeSig loc is c tp))
             =if definesTypeSig pn sig && length is==1
                 then []
                 else [Dec (HsTypeSig loc (filter (\x-> (pNTtoPN x)/=pn) is) c tp)]
            removeTypeSig' pn x=[x]
-}


-- |Divide a declaration list into three parts (before, parent, after)
-- according to the PNT, where 'parent' is the first decl containing
-- the PNT, 'before' are those decls before 'parent' and 'after' are
-- those decls after 'parent'.

-- ++AZ++ : Not sure if this is meaningful with renamed source.

-- divideDecls::[HsDeclP]->PNT->([HsDeclP],[HsDeclP],[HsDeclP])
divideDecls ds pnt
  -- = error "undefined divideDecls"
  = let (before,after)=break (\x->findPNT pnt x) ds
    in if (not $ emptyList after)
         then (before, [ghead "divideDecls" after], tail after)
         else (ds,[],[])
{-
divideDecls::[HsDeclP]->PNT->([HsDeclP],[HsDeclP],[HsDeclP])
divideDecls ds pnt
  = let (before,after)=break (\x->findPNT pnt x) ds
    in if (after/=[])
         then (before, [ghead "divideDecls" after], tail after)
         else (ds,[],[])
-}
