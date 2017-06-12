{-# LANGUAGE CPP #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}

module Language.Haskell.Refact.Refactoring.MoveDef
  ( liftToTopLevel
  , compLiftToTopLevel
  , liftOneLevel
  , compLiftOneLevel
  , demote
  , compDemote
  -- ,liftingInClientMod
  ) where

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import qualified Data.Generics.Zipper as Z


import qualified Exception             as GHC
import qualified GHC                   as GHC
import qualified Name                  as GHC
import qualified RdrName               as GHC

import Control.Exception
import Control.Monad.State
import Data.Foldable
import Data.List
import Data.Maybe

import qualified GhcMod as GM
import Language.Haskell.Refact.API

import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.GHC.ExactPrint

import Data.Generics.Strafunski.StrategyLib.StrategyLib

import System.Directory

-- import Debug.Trace

-- ---------------------------------------------------------------------

-- data Direction = UptoTopLevel | UpOneLevel | Down

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
liftToTopLevel :: RefactSettings -> GM.Options -> FilePath -> SimpPos -> IO [FilePath]
liftToTopLevel settings opts fileName (row,col) = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings opts (compLiftToTopLevel absFileName (row,col))

compLiftToTopLevel :: FilePath -> SimpPos
     -> RefactGhc [ApplyRefacResult]
compLiftToTopLevel fileName (row,col) = do
      parseSourceFileGhc fileName
      logParsedSource "liftToMod orig:"
      parsed  <- getRefactParsed
      nm <- getRefactNameMap

      let (Just (modName,_)) = getModuleName parsed
      let maybePn = locToRdrName (row, col) parsed
      case maybePn of
        Just ln@(GHC.L l _) -> liftToTopLevel' modName (GHC.L l (rdrName2NamePure nm ln))
        _       -> error "\nInvalid cursor position!\n"


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
liftToTopLevel' :: GHC.ModuleName
                -> GHC.Located GHC.Name
                -> RefactGhc [ApplyRefacResult]
liftToTopLevel' modName pn@(GHC.L _ n) = do
  renamed <- getRefactRenamed
  parsed  <- getRefactParsed
  nm      <- getRefactNameMap
  targetModule <- getRefactTargetModule
  logm $ "liftToTopLevel':pn=" ++ (showGhc pn)
  if isLocalFunOrPatName nm n parsed
      then do
              (refactoredMod,declPns) <- applyRefac liftToMod RSAlreadyLoaded

              logm $ "liftToTopLevel' applyRefac done "

              if modIsExported modName renamed
               then do clients <- clientModsAndFiles targetModule
                       logm $ "liftToTopLevel':(clients,declPns)=" ++ (showGhc (clients,declPns))
                       refactoredClients <- mapM (liftingInClientMod modName declPns) clients
                       return (refactoredMod:(concat refactoredClients))
               else do return [refactoredMod]
      else error "\nThe identifier is not a local function/pattern name!"

    where
       {-step1: divide the module's top level declaration list into three parts: 'parent'
                is the top level declaration containing the lifted declaration, 'before'
                and `after` are those declarations before and after 'parent'.
         step2: get the declarations to be lifted from parent, bind it to liftedDecls
         step3: remove the lifted declarations from parent and extra arguments
                may be introduced.
         step4. test whether there are any names need to be renamed.
       -}
       liftToMod = do
         parsed' <- getRefactParsed
         parsed  <- liftT $ balanceAllComments parsed'
         nm      <- getRefactNameMap
         -- logDataWithAnns "parsed after balanceAllComments" parsed
         declsp <- liftT $ hsDecls parsed
         (before,parent,after) <- divideDecls declsp pn
         {- ++AZ++TODO: reinstate this, hsDecls does : hsBinds does not return class or instance definitions
         when (isClassDecl $ ghead "liftToMod" parent)
               $ error "Sorry, the refactorer cannot lift a definition from a class declaration!"
         when (isInstDecl $ ghead "liftToMod" parent)
               $ error "Sorry, the refactorer cannot lift a definition from an instance declaration!"
         -}
         -- declsParent <- liftT $ hsDecls (ghead "liftToMod" parent)
         -- logm $ "liftToMod:(declsParent)=" ++ (showGhc declsParent)
         let liftedDecls = definingDeclsRdrNames nm [n] parent True True
             declaredPns = nub $ concatMap (definedNamesRdr nm) liftedDecls
             liftedSigs  = definingSigsRdrNames nm declaredPns parent
             mLiftedSigs = liftedSigs


         -- logDataWithAnns "liftedDecls" liftedDecls

         -- Check that the lifted declaration does not include a tuple pattern on the lhs
         when (any isTupleDecl liftedDecls) $ do
           error "Cannot lift a declaration assigning to a tuple pattern"

         -- TODO: what about declarations between this
         -- one and the top level that are used in this one?

         pns <- pnsNeedRenaming parsed parent liftedDecls declaredPns
         logm $ "liftToMod:(pns needing renaming)=" ++ (showGhc pns)

         decls <- liftT $ hsDecls parsed'
         let dd = getDeclaredVarsRdr nm decls
         logm $ "liftToMod:(ddd)=" ++ (showGhc dd)

         if null pns
           then do
             (parent',liftedDecls',mLiftedSigs') <- addParamsToParentAndLiftedDecl n dd parent liftedDecls mLiftedSigs

             let defName  = ghead "liftToMod" (definedNamesRdr nm (ghead "liftToMod2" parent'))
             parsed1 <- liftT $ replaceDecls parsed (before++parent'++after)
             parsed2 <- moveDecl1 parsed1 (Just defName) [GHC.unLoc pn] liftedDecls'
                                                            declaredPns mLiftedSigs'
             putRefactParsed parsed2 emptyAnns

             logParsedSource "liftToMod done:"

             return declaredPns

           else askRenamingMsg pns "lifting"

isTupleDecl :: GHC.LHsDecl GHC.RdrName -> Bool
isTupleDecl (GHC.L _ (GHC.ValD (GHC.PatBind (GHC.L _ GHC.TuplePat {}) _ _ _ _))) = True
isTupleDecl (GHC.L _ (GHC.ValD (GHC.PatBind (GHC.L _ (GHC.AsPat _ (GHC.L _ GHC.TuplePat {}))) _ _ _ _))) = True
isTupleDecl _ = False

-- ---------------------------------------------------------------------

-- | Move a definition one level up from where it is now
liftOneLevel :: RefactSettings -> GM.Options -> FilePath -> SimpPos -> IO [FilePath]
liftOneLevel settings opts fileName (row,col) = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings opts (compLiftOneLevel absFileName (row,col))

compLiftOneLevel :: FilePath -> SimpPos
     -> RefactGhc [ApplyRefacResult]
compLiftOneLevel fileName (row,col) = do
      parseSourceFileGhc fileName
      parsed  <- getRefactParsed
      nm <- getRefactNameMap

      let (Just (modName,_)) = getModuleName parsed
      let maybePn = locToRdrName (row, col) parsed
      case maybePn of
        Just ln@(GHC.L l _) ->  do
            rs <- liftOneLevel' modName (GHC.L l (rdrName2NamePure nm ln))
            logm $ "compLiftOneLevel:rs=" ++ (show $ (refactDone rs,map (\((_,d),_) -> d) rs))
            if (refactDone rs)
              then return rs
              else error ( "Lifting this definition failed. "++
                       " This might be because that the definition to be "++
                       "lifted is defined in a class/instance declaration.")
        _       ->  error "\nInvalid cursor position!\n"

{- Refactoring Names: 'liftOneLevel'
   Description:
    this refactoring lifts a local function/pattern binding only one level up.
    By 'lifting one-level up' , I mean:

    case1: In a module (HsModule SrcLoc ModuleName (Maybe [HsExportSpecI i]) [HsImportDeclI i] ds):
           A local declaration D  will be lifted to the same level as the 'ds', if D is in the
           where clause of one of ds's element declaration.

        new: (HsModule mmn mexp imps ds mdepr _haddock)
           In pactice this means processing

           a.  Matches in a FunBind
                 (Match mln pats _typ (GRHSs grhs ds))
           b. A PatBind
               (PatBind lhs (GRHSs grhs ds) _typ _fvs _ticks)

           and lifting a decl D from ds to the top.

           VarBinds and AbsBinds are introduced by the type checker, so can be ignored here.
           A PatSynBind does not have decls in it, so is ignored.


    case2: In a match ( HsMatch SrcLoc i [p] (HsRhs e) ds) :
           A local declaration D  will be lifted to the same level as the 'ds', if D is in the
           where clause of one of ds's element declaration.
           A declaration D,say,in the rhs expression 'e' will be lifted to 'ds' if D is Not local to
           other declaration list in 'e'

           (in a FunBind)
        new: (Match mln pats _typ (GRHSs grhs lb))


    case3: In a pattern  binding (HsPatBind SrcLoc p (HsRhs e) ds):
           A local declaration D  will be lifted to the same level as the 'ds', if D is in the
           where clause of one of ds's element declaration.
           A declaration D,say,in the rhs expression 'e' will be lifted to 'ds' if D is Not local to
           other declaration list in 'e'

        new: (PatBind lhs (GRHSs grhs ds) _typ _fvs _ticks)


    case4: In the Let expression (Exp (HsLet ds e):
           A local declaration D  will be lifted to the same level as the 'ds', if D is in the
           where clause of one of ds's element declaration.
           A declaration D, say, in the expression 'e' will be lifted to 'ds' if D is not local to
           other declaration list in 'e'

        new: HsLet ds e


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
  parsed  <- getRefactParsed
  nm      <- getRefactNameMap
  targetModule <- getRefactTargetModule
  if isLocalFunOrPatName nm n parsed
        then do
                (refactoredMod,(b,pns)) <- applyRefac doLiftOneLevel RSAlreadyLoaded
                logm $ "liftOneLevel':main refactoring done:(p,pns)=" ++ showGhc (b,pns)
                if b &&  modIsExported modName renamed
                  then do
                          logm $ "liftOneLevel':looking for clients"
                          clients <- clientModsAndFiles targetModule
                          logm $ "liftOneLevel':(clients,pns)=" ++ (showGhc (clients,pns))
                          refactoredClients <- mapM (liftingInClientMod modName pns) clients
                          return (refactoredMod:concat refactoredClients)
                  else do return [refactoredMod]
        else error "\nThe identifer is not a function/pattern name!"

   where
      doLiftOneLevel = do
             logm $ "in doLiftOneLevel"
             parsed <- getRefactParsed
             logDataWithAnns "doLiftOneLevel:parsed" parsed
             nm <- getRefactNameMap
             ans <- liftT getAnnsT
             zp <- ztransformStagedM SYB.Parser
                                (Nothing
                                `SYB.mkQ`  (liftToModQ   nm ans)
                                `SYB.extQ` (liftToMatchQ nm ans)
                                `SYB.extQ` (liftToLetQ   nm ans)
                                ) (Z.toZipper parsed)
             let parsed' = Z.fromZipper zp
             putRefactParsed parsed' emptyAnns
             liftedToTopLevel pn parsed'

           where
             isMatch :: GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> Bool
             isMatch _ = True

             isHsLet :: GHC.LHsExpr GHC.RdrName -> Bool
             isHsLet (GHC.L _ (GHC.HsLet _ _)) = True
             isHsLet _               = False

             -- ------------------------

             liftToModQ ::
                           NameMap -> Anns
                        -> GHC.ParsedSource
                        -> Maybe (SYB.Stage
                                  -> Z.Zipper GHC.ParsedSource
                                  -> RefactGhc (Z.Zipper GHC.ParsedSource))
             liftToModQ nm ans (p :: GHC.ParsedSource)
                | nonEmptyList candidateBinds
                  = Just (doLiftZ p declsp)
                | otherwise = Nothing
                where
                 (declsp ,_,_) = runTransform ans (hsDecls p)
                 doOne bs = (definingDeclsRdrNames nm [n] declsbs False False,bs)
                   where
                     (declsbs,_,_) = runTransform ans (hsDeclsGeneric bs)

                 candidateBinds = map snd
                                $ filter (\(l,_bs) -> nonEmptyList l)
                                $ map doOne
                                $ declsp

             getHsDecls ans t = decls
               where (decls,_,_) = runTransform ans (hsDeclsGeneric t)

             -- ------------------------

             liftToMatchQ :: (SYB.Data a)
                          => NameMap -> Anns
                          -> GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)
                          -> Maybe (SYB.Stage -> Z.Zipper a -> RefactGhc (Z.Zipper a))
             liftToMatchQ nm ans (m@(GHC.L _ (GHC.Match _ _pats _mtyp (GHC.GRHSs _rhs ds)))::GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))
                 | (nonEmptyList (definingDeclsRdrNames nm [n] (getHsDecls ans ds) False False))
                    = Just (doLiftZ m (getHsDecls ans  ds))
                 | otherwise = Nothing

             -- ------------------------

             liftToLetQ :: SYB.Data a
                        => NameMap -> Anns
                        -> GHC.LHsExpr GHC.RdrName -> Maybe (SYB.Stage -> Z.Zipper a -> RefactGhc (Z.Zipper a))
             liftToLetQ nm ans ll@(GHC.L _ (GHC.HsLet ds _e))
               | nonEmptyList (definingDeclsRdrNames nm [n] (getHsDecls ans ds) False  False)
                 = Just (doLiftZ ll (getHsDecls ans ll))
               | otherwise = Nothing
             liftToLetQ _ _ _ = Nothing

             -- ------------------------

             doLiftZ :: (SYB.Data t,SYB.Data a)
               => t -- ^Item containing the decls which contain the ones to be lifted
               -> [GHC.LHsDecl GHC.RdrName] -- ^decls containing the ones to be lifted.
                                            -- ++AZ++:TODO: these are redundant, can be pulled out of t
               -> SYB.Stage -- ++AZ++:TODO: get rid of this
               -> Z.Zipper a
               -> RefactGhc (Z.Zipper a)
             doLiftZ ds decls _stage z =
                  do
                    logm $ "doLiftZ entered"
                    logDataWithAnns "doLiftZ:ds" ds
                    logDataWithAnns "doLiftZ:decls" decls

                    let zu = case (Z.up z) of
                              Just zz -> fromMaybe (error $ "MoveDef.liftToLet.1" ++ SYB.showData SYB.Parser 0 decls)
                                  $ upUntil (False `SYB.mkQ` isMatch
                                                   `SYB.extQ` isHsLet
                                                   )
                                     zz
                              Nothing -> z

                    let
                      wtop (ren::GHC.ParsedSource) = do
                        logm $ "wtop entered"
                        nm <- getRefactNameMap
                        let (_,DN dd) = (hsFreeAndDeclaredRdr nm ren)
                        -- ++AZ++ : TODO: get rid of worker in favour of
                        -- workerTop
                        worker ren decls pn dd
                        -- workerTop ren decls dd


                      wmatch :: GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)
                             -> RefactGhc (GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))
                      wmatch (m@(GHC.L _ (GHC.Match _mln _pats _typ grhss))) = do
                         logm $ "wmatch entered:" ++ SYB.showData SYB.Parser 0 m
                         nm <- getRefactNameMap
                         let (_,DN dd) = hsFreeAndDeclaredRdr nm grhss

                         decls' <- liftT $ hsDecls m
                         workerTop m decls' dd

                      wlet :: GHC.LHsExpr GHC.RdrName -> RefactGhc (GHC.LHsExpr GHC.RdrName)
                      wlet l@(GHC.L _ (GHC.HsLet dsl _e)) = do
                         logm $ "wlet entered "
                         nm <- getRefactNameMap
                         let (_,DN dd) = hsFreeAndDeclaredRdr nm dsl
                         dsl' <- workerTop l decls dd
                         return dsl'
                      wlet x = return x

                    ds' <- Z.transM ( SYB.mkM   wtop
                                     `SYB.extM` wmatch
                                     `SYB.extM` wlet
                                    ) zu

                    return ds'

             -- ----------------------------------------


             -- This is currently used for everything but the top level
             workerTop :: (HasDecls t)
                => t -- ^The destination of the lift operation
                -> [GHC.LHsDecl GHC.RdrName] -- ^ list containing the decl to be
                                             -- lifted
                -> [GHC.Name] -- ^Declared variables in the destination
                -> RefactGhc t
             workerTop dest ds dd
                  =do
                      logm $ "MoveDef.worker: dest" ++ SYB.showData SYB.Parser 0 dest
                      logm $ "MoveDef.workerTop: ds=" ++ (showGhc ds)
                      done <- getRefactDone
                      if done then return dest
                        else do
                          setRefactDone
                          let parent = dest
                          nm <- getRefactNameMap
                          let liftedDecls = definingDeclsRdrNames' nm [n] parent
                              declaredPns = nub $ concatMap (definedNamesRdr nm) liftedDecls
                          logm $ "MoveDef.workerTop: n=" ++ (showGhc n)
                          logm $ "MoveDef.workerTop: liftedDecls=" ++ (showGhc liftedDecls)
                          pns <- pnsNeedRenaming dest parent liftedDecls declaredPns
                          logm $ "MoveDef.workerTop: pns=" ++ (showGhc pns)
                          if pns==[]
                            then do
                                    (parent',liftedDecls',mLiftedSigs')<-addParamsToParentAndLiftedDecl n dd
                                                                         parent liftedDecls []
                                    logm $ "MoveDef.workerTop: liftedDecls'=" ++ (showGhc liftedDecls')
                                    --True means the new decl will be at the same level with its parant.
                                    let toMove = parent'
                                    pdecls <- liftT $ hsDecls toMove
                                    -- logm $ "MoveDef.workerTop:toMove=" ++ SYB.showData SYB.Parser 0 toMove
                                    -- logm $ "MoveDef.workerTop:pdecls=" ++ (showGhc pdecls)
                                    let mAfter = case pdecls of
                                          [] -> Nothing
                                          _ -> (Just (ghead "worker" (definedNamesRdr nm (glast "workerTop" ds))))
                                    dest' <- moveDecl1 toMove
                                               mAfter
                                               [n] liftedDecls' declaredPns mLiftedSigs'
                                    return dest'
                            else askRenamingMsg pns "lifting"

             -- ----------------------------------------

             -- TODO: get rid of this in favour of workerTop
             worker :: (HasDecls t)
                => t -- ^The destination of the lift operation
                -> [GHC.LHsDecl GHC.RdrName] -- ^ list containing the decl to be
                                             -- lifted
                -> GHC.Located GHC.Name -- ^ The name of the decl to be lifted
                -> [GHC.Name] -- ^Declared variables in the destination
                -> RefactGhc t
             worker dest ds pnn dd
                  =do
                      -- logm $ "MoveDef.worker: dest" ++ (showGhc dest)
                      logm $ "MoveDef.worker: ds=" ++ (showGhc ds)
                      done <- getRefactDone
                      if done then return dest
                        else do
                          setRefactDone
                          (before,parent,after) <- divideDecls ds pnn -- parent is misnomer, it is the decl to be moved
                          logm $ "MoveDef.worker:(before,parent,after)" ++ showGhc (before,parent,after)
                          nm <- getRefactNameMap
                          let liftedDecls = definingDeclsRdrNames nm [n] parent True True
                              declaredPns = nub $ concatMap (definedNamesRdr nm) liftedDecls
                          pns <- pnsNeedRenaming dest parent liftedDecls declaredPns
                          logm $ "MoveDef.worker: pns=" ++ (showGhc pns)
                          if pns==[]
                            then do
                                    (parent',liftedDecls',mLiftedSigs')<-addParamsToParentAndLiftedDecl n dd
                                                                         parent liftedDecls []
                                    --True means the new decl will be at the same level with its parant.
                                    toMove <- liftT $ replaceDecls dest (before++parent'++after)
                                    dest' <- moveDecl1 toMove
                                               (Just (ghead "worker" (definedNamesRdr nm (ghead "worker" parent'))))
                                               [n] liftedDecls' declaredPns mLiftedSigs'
                                    return dest'
                            else askRenamingMsg pns "lifting"


-- ---------------------------------------------------------------------

-- | Move a definition one level down
demote :: RefactSettings -> GM.Options -> FilePath -> SimpPos -> IO [FilePath]
demote settings opts fileName (row,col) = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings opts (compDemote absFileName (row,col))

compDemote ::FilePath -> SimpPos
         -> RefactGhc [ApplyRefacResult]
compDemote fileName (row,col) = do
      parseSourceFileGhc fileName
      parsed  <- getRefactParsed
      nm <- getRefactNameMap

      -- TODO: make the next one an API call, that also gets the
      -- parsed source
      let (Just (modName,_)) = getModuleName parsed
      let maybePn = locToRdrName (row, col) parsed
      case maybePn of
        Just pn@(GHC.L l _) -> demote' modName (GHC.L l (rdrName2NamePure nm pn))
        _       -> error "\nInvalid cursor position!\n"

-- ---------------------------------------------------------------------

moveDecl1 :: (SYB.Data t)
  => t -- ^ The syntax element to update
  -> Maybe GHC.Name -- ^ If specified, add defn after this one

  -> [GHC.Name]     -- ^ The first one is the decl to move
  -> [GHC.LHsDecl GHC.RdrName]
  -> [GHC.Name]     -- ^ The signatures to remove. May be multiple if
                    --   decl being moved has a patbind.
  -> [GHC.LSig GHC.RdrName] -- ^ lifted decls signature if present
  -> RefactGhc t    -- ^ The updated syntax element (and tokens in monad)
moveDecl1 t defName ns mliftedDecls sigNames mliftedSigs = do
  logm $ "moveDecl1:(defName,ns,sigNames,mliftedDecls)=" ++ showGhc (defName,ns,sigNames,mliftedDecls)
  -- logm $ "moveDecl1:(t)=" ++ SYB.showData SYB.Parser 0 (t)

  -- TODO: rmDecl can now remove the sig at the same time.
  (t'',_sigsRemoved) <- rmTypeSigs sigNames t
  -- logm $ "moveDecl1:after rmTypeSigs:t''" ++ SYB.showData SYB.Parser 0 t''
  logm $ "moveDecl1:mliftedSigs=" ++ showGhc mliftedSigs
  (t',_declRemoved,_sigRemoved) <- rmDecl (ghead "moveDecl3.1"  ns) False t''
  -- logm $ "moveDecl1:after rmDecl:t'" ++ SYB.showData SYB.Parser 0 t'
  let sigs = map wrapSig mliftedSigs
  r <- addDecl t' defName (sigs++mliftedDecls,Nothing)

  return r

-- ---------------------------------------------------------------------

askRenamingMsg :: [GHC.Name] -> String -> t
askRenamingMsg pns str
  = error ("The identifier(s): " ++ (intercalate "," $ map showPN pns) ++
           " will cause name clash/capture or ambiguity occurrence problem after "
           ++ str ++", please do renaming first!")

  where
    showPN pn = showGhc (pn,GHC.nameSrcLoc pn)

-- |Get the subset of 'pns' that need to be renamed before lifting.
pnsNeedRenaming :: (SYB.Data t1,SYB.Data t2) =>
  t1 -> t2 -> t3 -> [GHC.Name]
  -> RefactGhc [GHC.Name]
pnsNeedRenaming dest parent _liftedDecls pns
  = do
       logm $ "MoveDef.pnsNeedRenaming entered:pns=" ++ showGhc pns
       r <- mapM pnsNeedRenaming' pns
       return (concat r)
  where
     pnsNeedRenaming' pn
       = do
            logm $ "MoveDef.pnsNeedRenaming' entered"
            nm <- getRefactNameMap
            let (FN f,DN d) = hsFDsFromInsideRdr nm dest --f: free variable names that may be shadowed by pn
                                                         --d: declaread variables names that may clash with pn
            logm $ "MoveDef.pnsNeedRenaming':(f,d)=" ++ showGhc (f,d)
            DN vs <- hsVisibleDsRdr nm pn parent  --vs: declarad variables that may shadow pn
            logm $ "MoveDef.pnsNeedRenaming':vs=" ++ showGhc vs
            let vars = map pNtoName (nub (f `union` d `union` vs) \\ [pn]) -- `union` inscpNames
            isInScope <- isInScopeAndUnqualifiedGhc (pNtoName pn) Nothing
            logm $ "MoveDef.pnsNeedRenaming:(f,d,vs,vars,isInScope)=" ++ (showGhc (f,d,vs,vars,isInScope))
            -- if elem (pNtoName pn) vars  || isInScope && findEntity pn dest
            if elem (pNtoName pn) vars  || isInScope && findNameInRdr nm pn dest
               then return [pn]
               else return []
     pNtoName = showGhc

-- ---------------------------------------------------------------------

addParamsToParent :: (SYB.Data t) => GHC.Name -> [GHC.RdrName] -> t -> RefactGhc t
addParamsToParent _pn [] t = return t
addParamsToParent  pn params t = do
  logm $ "addParamsToParent:(pn,params)" ++ (showGhc (pn,params))
  nm <- getRefactNameMap
  applyTP (full_buTP (idTP  `adhocTP` (inExp nm))) t
  where
#if __GLASGOW_HASKELL__ <= 710
    inExp nm (e@(GHC.L l (GHC.HsVar n)) :: GHC.LHsExpr GHC.RdrName) = do
#else
    inExp nm (e@(GHC.L l (GHC.HsVar (GHC.L _ n))) :: GHC.LHsExpr GHC.RdrName) = do
#endif
      let ne = rdrName2NamePure nm (GHC.L l n)
      if GHC.nameUnique ne == GHC.nameUnique pn
         then addActualParamsToRhs pn params e
         else return e
    inExp _ e = return e

  -- addActualParamsToRhs pn params t


-- |Do refactoring in the client module. that is to hide the identifer
-- in the import declaration if it will cause any problem in the
-- client module.
liftingInClientMod :: GHC.ModuleName -> [GHC.Name] -> TargetModule
  -> RefactGhc [ApplyRefacResult]
liftingInClientMod serverModName pns targetModule = do
       logm $ "liftingInClientMod:targetModule=" ++ (show targetModule)
       getTargetGhc targetModule
       parsed <- getRefactParsed
       clientModule <- getRefactModule
       logm $ "liftingInClientMod:clientModule=" ++ (showGhc clientModule)
       modNames <- willBeUnQualImportedBy serverModName
       logm $ "liftingInClientMod:modNames=" ++ (showGhc modNames)
       if isJust modNames
        then do
             pns' <- namesNeedToBeHided clientModule (gfromJust "liftingInClientMod" modNames) pns
             let pnsRdr' = map GHC.nameRdrName pns'
             logm $ "liftingInClientMod:pns'=" ++ (showGhc pns')
             if (nonEmptyList pns')
                 then do (refactoredMod,_) <- applyRefac (addHiding serverModName parsed pnsRdr') RSAlreadyLoaded
                         return [refactoredMod]
                 else return []
        else return []

-- ---------------------------------------------------------------------

-- |Test whether an identifier defined in the modules specified by
-- 'names' will be exported by current module.
willBeExportedByClientMod :: [GHC.ModuleName] -> GHC.RenamedSource -> Bool
willBeExportedByClientMod names renamed =
  let (_,_,exps,_) = renamed
  in if isNothing exps
        then False
        else any isJust $ map (\y-> (find (\x-> (simpModule x==Just y)) (gfromJust "willBeExportedByClientMod" exps))) names
     where simpModule (GHC.L _ (GHC.IEModuleContents (GHC.L _ m))) = Just m
           simpModule _  = Nothing

-- |get the module name or alias name by which the lifted identifier
-- will be imported automatically.
-- TODO: maybe move this into TypeUtils
-- willBeUnQualImportedBy::HsName.ModuleName->HsModuleP->Maybe [HsName.ModuleName]
willBeUnQualImportedBy :: GHC.ModuleName -> RefactGhc (Maybe [GHC.ModuleName])
willBeUnQualImportedBy modName = do
   (_,imps,_,_) <- getRefactRenamed
   let ms = filter (\(GHC.L _ (GHC.ImportDecl _ (GHC.L _ modName1) _qualify _source _safe isQualified _isImplicit _as h))
                     -> modName == modName1 && (not isQualified) && (isNothing h || (isJust h && ((fst (fromJust h)) == True))))
                   imps

       res = if (emptyList ms) then Nothing
                               else Just $ nub $ map getModName ms

       getModName (GHC.L _ (GHC.ImportDecl _ (GHC.L _ modName2) _qualify _source _safe _isQualified _isImplicit as _h))
        = if isJust as then simpModName (fromJust as)
                       else modName2

       simpModName m = m

   logm $ "willBeUnQualImportedBy:(ms,res)=" ++ (showGhc (ms,res))

   return res

-- ---------------------------------------------------------------------

-- |get the subset of 'pns', which need to be hided in the import
-- declaration in module 'mod'
-- Note: these are newly exported from the module, so we cannot use
-- the GHC name resolution in this case.
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

            -- TODO: ++AZ++ check if next line needs to be reinstated
            -- was || any (\m -> causeNameClashInExports oldPN pn m renamed) modNames)
            || False)
           then return [pn]
           else return []


-- **************************************************************************************************************--

-- ---------------------------------------------------------------------

-- |When liftOneLevel is complete, identify whether any new declarations have
-- been put at the top level
liftedToTopLevel :: GHC.Located GHC.Name -> GHC.ParsedSource -> RefactGhc (Bool,[GHC.Name])
liftedToTopLevel (GHC.L _ pn) parsed = do
  logm $ "liftedToTopLevel entered:pn=" ++ showGhc pn
  nm <- getRefactNameMap
  decls <- liftT $ hsDecls parsed
  let topDecs = definingDeclsRdrNames nm [pn] decls False False
  -- ++AZ++ :TODO: we are not updating the nameMap to reflect moved decls
  if nonEmptyList topDecs
     then do
       let liftedDecls = definingDeclsRdrNames nm [pn] topDecs False False
           declaredPns  = nub $ concatMap (definedNamesRdr nm) liftedDecls
       return (True, declaredPns)
     else return (False, [])

-- ---------------------------------------------------------------------

addParamsToParentAndLiftedDecl :: (SYB.Data t) =>
     GHC.Name   -- ^name of decl being lifted
  -> [GHC.Name] -- ^Declared names in parent
  -> t          -- ^parent
  -> [GHC.LHsDecl GHC.RdrName] -- ^ decls being lifted
  -> [GHC.LSig GHC.RdrName]    -- ^ lifted decls signature if present
  -> RefactGhc (t, [GHC.LHsDecl GHC.RdrName], [GHC.LSig GHC.RdrName])
addParamsToParentAndLiftedDecl pn dd parent liftedDecls mLiftedSigs
  =do
       logm $ "addParamsToParentAndLiftedDecl:liftedDecls=" ++ (showGhc liftedDecls)
       nm <- getRefactNameMap
       let (FN ef,_) = hsFreeAndDeclaredRdr nm parent
       let (FN lf,_) = hsFreeAndDeclaredRdr nm liftedDecls

       logm $ "addParamsToParentAndLiftedDecl:(ef,lf)=" ++ showGhc (ef,lf)

       -- parameters to be added to pn because of lifting
       let newParamsNames = ((nub lf) \\ (nub ef)) \\ dd
           newParams = map GHC.nameRdrName newParamsNames

       logm $ "addParamsToParentAndLiftedDecl:(newParams,ef,lf,dd)=" ++ (showGhc (newParams,ef,lf,dd))

       if newParams /= []
         then if  (any isComplexPatDecl liftedDecls)
                then error "This pattern binding cannot be lifted, as it uses some other local bindings!"
                else do -- first remove the decls to be lifted, so they are not disturbed
                        (parent'',liftedDecls'',_msig) <- rmDecl pn False parent

                        parent' <- addParamsToParent pn newParams parent''

                        liftedDecls' <- addParamsToDecls [liftedDecls''] pn newParams

                        mLiftedSigs' <- mapM (addParamsToSigs newParamsNames) mLiftedSigs

                        logm $ "addParamsToParentAndLiftedDecl:mLiftedSigs'=" ++ showGhc mLiftedSigs'

                        return (parent',liftedDecls', mLiftedSigs')
         else return (parent,liftedDecls,mLiftedSigs)

-- ---------------------------------------------------------------------
{-
-- TODO: perhaps move this to TypeUtils
addParamsToSigs :: [GHC.Name] -> GHC.LSig GHC.RdrName -> RefactGhc (GHC.LSig GHC.RdrName)
addParamsToSigs [] ms = return ms
addParamsToSigs newParams (GHC.L l (GHC.TypeSig lns ltyp pns)) = do
  mts <- mapM getTypeForName newParams
  let ts = catMaybes mts
  logm $ "addParamsToSigs:ts=" ++ showGhc ts
  logDataWithAnns "addParamsToSigs:ts=" ts
  let newStr = ":: " ++ (intercalate " -> " $ map printSigComponent ts) ++ " -> "
  logm $ "addParamsToSigs:newStr=[" ++ newStr ++ "]"
  typ' <- liftT $ foldlM addOneType ltyp (reverse ts)
  sigOk <- isNewSignatureOk ts
  logm $ "addParamsToSigs:(sigOk,newStr)=" ++ show (sigOk,newStr)
  if sigOk
    then return (GHC.L l (GHC.TypeSig lns typ' pns))
    else error $ "\nNew type signature may fail type checking: " ++ newStr ++ "\n"
  where
    addOneType :: GHC.LHsType GHC.RdrName -> GHC.Type -> Transform (GHC.LHsType GHC.RdrName)
    addOneType et t = do
      hst <- typeToLHsType t
      ss1 <- uniqueSrcSpanT
      hst1 <- case t of
        (GHC.FunTy _ _) -> do
          ss <- uniqueSrcSpanT
          let t1 = GHC.L ss (GHC.HsParTy hst)
          setEntryDPT hst (DP (0,0))
          addSimpleAnnT t1  (DP (0,0)) [((G GHC.AnnOpenP),DP (0,1)),((G GHC.AnnCloseP),DP (0,0))]
          return t1
        _ -> return hst
      let typ = GHC.L ss1 (GHC.HsFunTy hst1 et)

      addSimpleAnnT typ (DP (0,0)) [((G GHC.AnnRarrow),DP (0,1))]
      return typ

addParamsToSigs np ls = error $ "addParamsToSigs: no match for:" ++ showGhc (np,ls)

-- ---------------------------------------------------------------------

printSigComponent :: GHC.Type -> String
printSigComponent x = ppType x

-- ---------------------------------------------------------------------

-- |Fail any signature having a forall in it.
-- TODO: this is unnecesarily restrictive, but needs
-- a) proper reversing of GHC.Type to GHC.LhsType
-- b) some serious reverse type inference to ensure that the
--    constraints are modified properly to merge the old signature
--    part and the new.
isNewSignatureOk :: [GHC.Type] -> RefactGhc Bool
isNewSignatureOk types = do
  -- NOTE: under some circumstances enabling Rank2Types or RankNTypes
  --       can resolve the type conflict, this can potentially be checked
  --       for.
  -- NOTE2: perhaps proceed and reload the tentative refactoring into
  --        the GHC session and accept it only if it type checks
  let
    r = SYB.everythingStaged SYB.TypeChecker (++) []
          ([] `SYB.mkQ` usesForAll) types
    usesForAll (GHC.ForAllTy _ _) = [1::Int]
    usesForAll _                  = []

  return $ emptyList r

-- ---------------------------------------------------------------------

-- TODO: perhaps move this to TypeUtils
-- TODO: complete this
typeToLHsType :: GHC.Type -> Transform (GHC.LHsType GHC.RdrName)
typeToLHsType (GHC.TyVarTy v)   = do
  ss <- uniqueSrcSpanT
  let typ = GHC.L ss (GHC.HsTyVar (GHC.nameRdrName $ Var.varName v))
  addSimpleAnnT typ (DP (0,0)) [((G GHC.AnnVal),DP (0,0))]
  return typ

typeToLHsType (GHC.AppTy t1 t2) = do
  t1' <- typeToLHsType t1
  t2' <- typeToLHsType t2
  ss <- uniqueSrcSpanT
  return $ GHC.L ss (GHC.HsAppTy t1' t2')

typeToLHsType t@(GHC.TyConApp _tc _ts) = tyConAppToHsType t

typeToLHsType (GHC.FunTy t1 t2) = do
  t1' <- typeToLHsType t1
  t2' <- typeToLHsType t2
  ss <- uniqueSrcSpanT
  let typ = GHC.L ss (GHC.HsFunTy t1' t2')
  addSimpleAnnT typ (DP (0,0)) [((G GHC.AnnRarrow),DP (0,1))]
  return typ

typeToLHsType (GHC.ForAllTy _v t) = do
  t' <- typeToLHsType t
  ss1 <- uniqueSrcSpanT
  ss2 <- uniqueSrcSpanT
  return $ GHC.L ss1 (GHC.HsForAllTy GHC.Explicit Nothing (GHC.HsQTvs [] []) (GHC.L ss2 []) t')

typeToLHsType (GHC.LitTy (GHC.NumTyLit i)) = do
  ss <- uniqueSrcSpanT
  let typ = GHC.L ss (GHC.HsTyLit (GHC.HsNumTy (show i) i)) :: GHC.LHsType GHC.RdrName
  addSimpleAnnT typ (DP (0,0)) [((G GHC.AnnVal),DP (0,0))]
  return typ

typeToLHsType (GHC.LitTy (GHC.StrTyLit s)) = do
  ss <- uniqueSrcSpanT
  let typ = GHC.L ss (GHC.HsTyLit (GHC.HsStrTy "" s)) :: GHC.LHsType GHC.RdrName
  addSimpleAnnT typ (DP (0,0)) [((G GHC.AnnVal),DP (0,0))]
  return typ


{-
data Type
  = TyVarTy Var	-- ^ Vanilla type or kind variable (*never* a coercion variable)

  | AppTy         -- See Note [AppTy invariant]
	Type
	Type		-- ^ Type application to something other than a 'TyCon'. Parameters:
	                --
                        --  1) Function: must /not/ be a 'TyConApp',
                        --     must be another 'AppTy', or 'TyVarTy'
	                --
	                --  2) Argument type

  | TyConApp      -- See Note [AppTy invariant]
	TyCon
	[KindOrType]	-- ^ Application of a 'TyCon', including newtypes /and/ synonyms.
	                -- Invariant: saturated appliations of 'FunTyCon' must
	                -- use 'FunTy' and saturated synonyms must use their own
                        -- constructors. However, /unsaturated/ 'FunTyCon's
                        -- do appear as 'TyConApp's.
	                -- Parameters:
	                --
	                -- 1) Type constructor being applied to.
	                --
                        -- 2) Type arguments. Might not have enough type arguments
                        --    here to saturate the constructor.
                        --    Even type synonyms are not necessarily saturated;
                        --    for example unsaturated type synonyms
	                --    can appear as the right hand side of a type synonym.

  | FunTy
	Type
	Type		-- ^ Special case of 'TyConApp': @TyConApp FunTyCon [t1, t2]@
			-- See Note [Equality-constrained types]

  | ForAllTy
	Var         -- Type or kind variable
	Type	        -- ^ A polymorphic type

  | LitTy TyLit     -- ^ Type literals are simillar to type constructors.

-}

tyConAppToHsType :: GHC.Type -> Transform (GHC.LHsType GHC.RdrName)
tyConAppToHsType (GHC.TyConApp tc _ts) = r (show $ GHC.tyConName tc)
  where
    r str = do
      ss <- uniqueSrcSpanT
      let typ = GHC.L ss (GHC.HsTyLit (GHC.HsStrTy str $ GHC.mkFastString str)) :: GHC.LHsType GHC.RdrName
      addSimpleAnnT typ (DP (0,0)) [((G GHC.AnnVal),DP (0,1))]
      return typ

-- tyConAppToHsType t@(GHC.TyConApp _tc _ts)
--    = error $ "tyConAppToHsType: unexpected:" ++ (SYB.showData SYB.TypeChecker 0 t)

{-
HsType
HsForAllTy HsExplicitFlag (LHsTyVarBndrs name) (LHsContext name) (LHsType name)
HsTyVar name
HsAppTy (LHsType name) (LHsType name)
HsFunTy (LHsType name) (LHsType name)
HsListTy (LHsType name)
HsPArrTy (LHsType name)
HsTupleTy HsTupleSort [LHsType name]
HsOpTy (LHsType name) (LHsTyOp name) (LHsType name)
HsParTy (LHsType name)
HsIParamTy HsIPName (LHsType name)
HsEqTy (LHsType name) (LHsType name)
HsKindSig (LHsType name) (LHsKind name)
HsQuasiQuoteTy (HsQuasiQuote name)
HsSpliceTy (HsSplice name) FreeVars PostTcKind
HsDocTy (LHsType name) LHsDocString
HsBangTy HsBang (LHsType name)
HsRecTy [ConDeclField name]
HsCoreTy Type
HsExplicitListTy PostTcKind [LHsType name]
HsExplicitTupleTy [PostTcKind] [LHsType name]
HsTyLit HsTyLit
HsWrapTy HsTyWrapper (HsType name)
-}

-}

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
  parsed  <- getRefactParsed
  nm      <- getRefactNameMap
  targetModule <- getRefactTargetModule
  if isFunOrPatName nm pn parsed
    then do
       isTl <- isTopLevelPN pn
       if isTl && isExplicitlyExported nm pn parsed
          then error "This definition can not be demoted, as it is explicitly exported by the current module!"
          else do
                  (refactoredMod,declaredPns) <- applyRefac (doDemoting pn) RSAlreadyLoaded
                  if isTl && modIsExported modName renamed
                    then do
                            logm $ "demote':isTl && isExported"
                            clients <- clientModsAndFiles targetModule
                            logm $ "demote':clients=" ++ (showGhc clients)
                            refactoredClients <-mapM (demotingInClientMod declaredPns) clients
                            return (refactoredMod:refactoredClients)
                    else do return [refactoredMod]
    else error "\nInvalid cursor position!"


-- |Do refactoring in the client module, that is:
--  a) Check whether the identifier is used in the module body
--  b) If the identifier is not used but is hided by the import
--     declaration, then remove it from the hiding.
demotingInClientMod ::
  [GHC.Name] -> TargetModule
  -> RefactGhc ApplyRefacResult
demotingInClientMod pns targetModule = do
  logm $ "demotingInClientMod:(pns,targetModule)=" ++ showGhc (pns,targetModule)
  getTargetGhc targetModule
  modu <- getRefactModule
  (refactoredMod,_) <- applyRefac (doDemotingInClientMod pns modu) RSAlreadyLoaded
  return refactoredMod


doDemotingInClientMod :: [GHC.Name] -> GHC.Module -> RefactGhc ()
doDemotingInClientMod pns modName = do
  logm $ "doDemotingInClientMod:(pns,modName)=" ++ showGhc (pns,modName)
  (GHC.L _ p) <- getRefactParsed
  nm <- getRefactNameMap
  if any (\pn -> findNameInRdr nm pn (GHC.hsmodDecls p) || findNameInRdr nm pn (GHC.hsmodExports p)) pns
     then error $ "This definition can not be demoted, as it is used in the client module '"++(showGhc modName)++"'!"
     else if any (\pn->findNameInRdr nm pn (GHC.hsmodImports p)) pns
             -- TODO: reinstate this
             then do -- (mod',((ts',m),_))<-runStateT (rmItemsFromImport mod pns) ((ts,unmodified),(-1000,0))
                     return ()
             else return ()

-- ---------------------------------------------------------------------

doDemoting :: GHC.Name -> RefactGhc [GHC.Name]
doDemoting  pn = do

  clearRefactDone -- Only do this action once

  parsed  <- getRefactParsed

  parsed' <- everywhereMStaged' SYB.Parser   (SYB.mkM   demoteInMod
                                             `SYB.extM` demoteInMatch
                                             `SYB.extM` demoteInPat
                                             `SYB.extM` demoteInLet
                                             `SYB.extM` demoteInStmt
                                            ) parsed
  putRefactParsed parsed' emptyAnns
  nm <- getRefactNameMap
  decls <- liftT $ hsDecls parsed
  let demotedDecls'= definingDeclsRdrNames nm [pn] decls True False
      declaredPnsRdr  = nub $ concatMap definedPNsRdr demotedDecls'
      declaredPns = map (rdrName2NamePure nm) declaredPnsRdr
  return declaredPns
    where
       --1. demote from top level
       demoteInMod x@(parsed :: GHC.ParsedSource) = do
         decls <- liftT $ hsDecls parsed
         nm <- getRefactNameMap
         if not $ emptyList (definingDeclsRdrNames nm [pn] decls False False)
           then do
              logm "MoveDef:demoteInMod" -- ++AZ++
              demoted <- doDemoting' parsed pn
              return demoted
           else return x

       --2. The demoted definition is a local decl in a match
       demoteInMatch match@(GHC.L _ (GHC.Match _ _pats _mt (GHC.GRHSs _ _ds))::GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)) = do
         -- decls <- liftT $ hsDecls ds
         decls <- liftT $ hsDecls match
         nm <- getRefactNameMap
         if not $ emptyList (definingDeclsRdrNames nm [pn] decls False False)
           then do
              logm "MoveDef:demoteInMatch" -- ++AZ++
              done <- getRefactDone
              match' <- if (not done)
                then doDemoting' match pn
                else return match
              return match'
           else return match

       --3. The demoted definition is a local decl in a pattern binding
       demoteInPat x@(pat@(GHC.L _ (GHC.ValD (GHC.PatBind _p (GHC.GRHSs _grhs _lb) _ _ _)))::GHC.LHsDecl GHC.RdrName) = do
         decls <- liftT $ hsDeclsPatBindD x
         nm <- getRefactNameMap
         if not $ emptyList (definingDeclsRdrNames nm [pn] decls False False)
           then do
              logm "MoveDef:demoteInPat" -- ++AZ++
              done <- getRefactDone
              pat' <- if (not done)
                then doDemoting' pat pn
                else return pat
              return pat'
           else return x
       demoteInPat x = return x

       --4: The demoted definition is a local decl in a Let expression
       demoteInLet x@(letExp@(GHC.L _ (GHC.HsLet _ds _e))::GHC.LHsExpr GHC.RdrName) = do
         decls <- liftT $ hsDecls x
         nm <- getRefactNameMap
         if not $ emptyList (definingDeclsRdrNames nm [pn] decls False False)
           then do
              logm "MoveDef:demoteInLet" -- ++AZ++
              done <- getRefactDone
              letExp' <- if (not done)
                 then doDemoting' letExp pn
                 else return letExp
              return letExp'
           else return x
       demoteInLet x = return x


       --6.The demoted definition is a local decl in a Let statement.
       -- demoteInStmt (letStmt@(HsLetStmt ds stmts):: (HsStmt (HsExpP) (HsPatP) [HsDeclP]))
       demoteInStmt (letStmt@(GHC.L _ (GHC.LetStmt _binds))::GHC.LStmt GHC.RdrName (GHC.LHsExpr GHC.RdrName)) = do
         decls <- liftT $ hsDecls letStmt
         nm <- getRefactNameMap
         if not $ emptyList (definingDeclsRdrNames nm [pn] decls False False)
           then do
              logm "MoveDef:demoteInStmt" -- ++AZ++
              done <- getRefactDone
              letStmt' <- if (not done)
                then doDemoting' letStmt pn
                else return letStmt
              return letStmt'
           else return letStmt
       demoteInStmt x = return x



-- |Demote the declaration of 'pn' in the context of 't'.
doDemoting' :: (UsedByRhs t) => t -> GHC.Name -> RefactGhc t
doDemoting' t pn = do
   nm <- getRefactNameMap
   -- origDecls <- liftT $ hsDecls t
   origDecls <- liftT $ hsDeclsGeneric t
   let
       demotedDecls'= definingDeclsRdrNames nm [pn] origDecls True False
       declaredPns = nub $ concatMap (definedNamesRdr nm) demotedDecls'
       pnsUsed = usedByRhsRdr nm t declaredPns
   logm $ "doDemoting':(pn,declaredPns)=" ++ showGhc (pn,declaredPns)
   -- logm $ "doDemoting':t=" ++ (SYB.showData SYB.Renamer 0 t)
   logm $ "doDemoting':(declaredPns,pnsUsed)=" ++ showGhc (declaredPns,pnsUsed)
   r <-  if not pnsUsed -- (usedByRhs t declaredPns)
       then do
              logm $ "doDemoting' no pnsUsed"
              -- dt <- liftT $ hsDecls t
              let dt = origDecls
              let demotedDecls = definingDeclsRdrNames nm [pn] dt True True
                  otherBinds = (deleteFirstsBy (sameBindRdr nm) dt demotedDecls)
                      {- From 'hsDecls t' to 'hsDecls t \\ demotedDecls'.
                         Bug fixed 06/09/2004 to handle direct recursive function.
                       -}
                  xx = map (\b -> (b,uses nm declaredPns [b])) otherBinds
                  useCount = sum $ concatMap snd xx
              logm $ "doDemoting': declaredPns=" ++ (showGhc declaredPns)
              logm $ "doDemoting': uses xx=" ++ (showGhc xx)
              logm $ "doDemoting': uses useCount=" ++ (show useCount)

              case useCount  of
                  0 ->do error "\n Nowhere to demote this function!\n"
                  1 -> --This function is only used by one friend function
                      do
                         logm "MoveDef.doDemoting':target location found" -- ++AZ++

                         let (FN f,_d) = hsFreeAndDeclaredRdr nm demotedDecls
                         (ds,removedDecl,_sigRemoved) <- rmDecl pn False t
                         (t',demotedSigs)             <- rmTypeSigs declaredPns ds

                         logDataWithAnns "MoveDef.doDemoting':after rmTypeSigs:demotedSigs=" demotedSigs

                         logm $ "MoveDef:declaredPns=" ++ (showGhc declaredPns) -- ++AZ++

                         dl <- mapM (flip (declaredNamesInTargetPlace nm) ds) declaredPns
                         logm $ "mapM declaredNamesInTargetPlace done"
                         --make sure free variable in 'f' do not clash with variables in 'dl',
                         --otherwise do renaming.
                         let clashedNames=filter (\x-> elem (id x) (map id f)) $ (nub.concat) dl
                         --rename clashed names to new names created automatically,update TOKEN STREAM as well.
                         if clashedNames/=[]
                            then error ("The identifier(s):" ++ showGhc clashedNames ++
                                       ", declared in where the definition will be demoted to, will cause name clash/capture"
                                       ++" after demoting, please do renaming first!")
                            else  --duplicate demoted declarations to the right place.
                                 do
                                    duplicateDecls declaredPns removedDecl demotedSigs t'
                  _ ->error "\nThis function/pattern binding is used by more than one friend bindings\n"

       else error "This function can not be demoted as it is used in current level!\n"

   return r

    where
          ---find how many matches/pattern bindings use  'pn'-------
          uses :: NameMap -> [GHC.Name] -> [GHC.LHsDecl GHC.RdrName] -> [Int]
          uses nm pns t2
               = concatMap used t2
                where

                  used :: GHC.LHsDecl GHC.RdrName -> [Int]
#if __GLASGOW_HASKELL__ <= 710
                  used (GHC.L _ (GHC.ValD (GHC.FunBind _n _ (GHC.MG matches _ _ _) _ _ _)))
#else
                  used (GHC.L _ (GHC.ValD (GHC.FunBind _n (GHC.MG (GHC.L _ matches) _ _ _) _ _ _)))
#endif
                     = concatMap (usedInMatch pns) matches

                  used (GHC.L _ (GHC.ValD (GHC.PatBind pat rhs _ _ _)))
                    | (not $ findNamesRdr nm pns pat) && findNamesRdr nm pns rhs
                    = [1::Int]
                  used  _ = []

                  usedInMatch pns' (GHC.L _ (GHC.Match _ pats _ rhs))
                    | (not $ findNamesRdr nm pns' pats) && findNamesRdr nm pns' rhs
                     = [1::Int]
                  usedInMatch _ _ = []


          duplicateDecls :: (SYB.Data t,SYB.Typeable t)
                         => [GHC.Name] -- ^ function names to be demoted
                         -> GHC.LHsDecl GHC.RdrName   -- ^Bind being demoted
                         -> [GHC.LSig GHC.RdrName]    -- ^Signatures being demoted, if any
                         -> t
                         -> RefactGhc t
          duplicateDecls pns demoted dsig o = do
            logm $ "duplicateDecls:t=" ++ SYB.showData SYB.Parser 0 o
            hasDeclsSybTransform workerHsDecls workerBind o
            where
              workerHsDecls :: forall t. HasDecls t => t -> RefactGhc t
              workerHsDecls t' = do
                dds <- liftT $ hsDecls t'
                ds'' <- duplicateDecls' pns demoted dsig dds
                liftT $ replaceDecls t' ds''

              workerBind :: (GHC.LHsBind GHC.RdrName -> RefactGhc (GHC.LHsBind GHC.RdrName))
              workerBind t'@(GHC.L _ (GHC.PatBind{})) = do
                dds <- liftT $ hsDeclsPatBind t'
                ds'' <- duplicateDecls' pns demoted dsig dds
                liftT $ replaceDeclsPatBind t' ds''
              workerBind x = error $ "MoveDef.duplicateDecls.workerBind:unmatched LHsBind:" ++ showGhc x


          -- duplicate demotedDecls to the right place (the outer most level where it is used).
          duplicateDecls' :: [GHC.Name] -- ^ function names to be demoted
                          -> GHC.LHsDecl GHC.RdrName   -- ^Bind being demoted
                          -> [GHC.LSig GHC.RdrName]    -- ^Signatures being demoted, if any
                          -> [GHC.LHsDecl GHC.RdrName] -- ^Binds of original top
                                                       -- level entiity,
                                                       -- including src and dst
                          -> RefactGhc [GHC.LHsDecl GHC.RdrName]
          duplicateDecls' pns demoted dsig decls
             = do
                  nm <- getRefactNameMap
                  everywhereMStaged' SYB.Parser (SYB.mkM (dupInMatch nm) -- top-down approach
                                                `SYB.extM` (dupInPat nm)) decls
               where
                 dupInMatch nm (match@(GHC.L _ (GHC.Match _ pats _mt rhs)) :: GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))
                   | (not $ findNamesRdr nm pns pats) && findNamesRdr nm pns rhs
                   =  do
                        done <- getRefactDone
                        logm $ "duplicateDecls.dupInMatch:value of done=" ++ (show done) -- ++AZ++
                        if done
                          then return match
                          else do
                            logm "duplicateDecls:setting done"  -- ++AZ++
                            setRefactDone
                            match' <- foldParams pns match decls demoted dsig
                            return match'
                 dupInMatch _ x = return x

                 dupInPat nm ((GHC.PatBind pat rhs@(GHC.GRHSs grhs lb) ty fvs ticks) :: GHC.HsBind GHC.RdrName)
                    | (not $ findNamesRdr nm pns pat) && findNamesRdr nm pns rhs
                   = do
                       logm $ "duplicateDecls.dupInPat"
                       let declsToLift = definingDeclsRdrNames' nm pns t
                       lb' <- moveDecl1 lb Nothing pns declsToLift pns []
                       return (GHC.PatBind pat (GHC.GRHSs grhs lb') ty fvs ticks)
                 dupInPat _ x = return x

                 -- demotedDecls = definingDecls pns decls True False
          ---------------------------------------------------------------------

          declaredNamesInTargetPlace :: (SYB.Data t)
                            => NameMap -> GHC.Name -> t
                            -> RefactGhc [GHC.Name]

          declaredNamesInTargetPlace nm pn' t' = do
             logm $ "declaredNamesInTargetPlace:pn=" ++ (showGhc pn')
             res <- applyTU (stop_tdTU (failTU
                                           `adhocTU` inMatch
                                           `adhocTU` inPat)) t'
             logm $ "declaredNamesInTargetPlace:res=" ++ (showGhc res)
             return res
               where
                 inMatch ((GHC.Match _ _pats _ rhs) :: GHC.Match GHC.RdrName (GHC.LHsExpr GHC.RdrName))
                    | findNameInRdr nm pn' rhs = do
                     logm $ "declaredNamesInTargetPlace:inMatch"
                     -- fds <- hsFDsFromInside rhs
                     let (_,DN ds) = hsFDsFromInsideRdr nm rhs
                     return ds
                 inMatch _ = return mzero

                 inPat ((GHC.PatBind pat rhs _ _ _) :: GHC.HsBind GHC.RdrName)
                    |findNameInRdr nm pn' rhs = do
                     logm $ "declaredNamesInTargetPlace:inPat"
                     let (_,DN ds) = hsFDsFromInsideRdr nm pat
                     return ds
                 inPat _=  return mzero

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
           -> GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)     -- ^The RHS of the place to receive the demoted decls
           -> [GHC.LHsDecl GHC.RdrName] -- ^Binds of original top level entiity, including src and dst
           -> GHC.LHsDecl GHC.RdrName   -- ^The decls being demoted
           -> [GHC.LSig GHC.RdrName]    -- ^Signatures being demoted, if any
           -> RefactGhc (GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))
foldParams pns match@(GHC.L l (GHC.Match _mfn _pats _mt rhs)) _decls demotedDecls dsig

     =do
         logm $ "MoveDef.foldParams entered"
         nm <- getRefactNameMap

         let matches = concatMap matchesInDecls [demotedDecls]
             pn = ghead "foldParams" pns    --pns /=[]
         logm $ "MoveDef.foldParams before allParams"
         params <- allParams pn rhs []
         logm $ "foldParams:params=" ++ showGhc params
         if (length.nub.map length) params==1                  -- have same number of param
             && ((length matches)==1)      -- only one 'match' in the demoted declaration
           then do
                   let patsInDemotedDecls=(patsInMatch.(ghead "foldParams")) matches
                       subst = mkSubst nm patsInDemotedDecls params
                       fstSubst = map fst subst
                       sndSubst = map snd subst

                   rhs' <- rmParamsInParent pn sndSubst rhs

                   let ls = map (hsFreeAndDeclaredRdr nm) sndSubst
                   let newNames = ((concatMap (fn . fst) ls)) \\ (fstSubst)
                   --There may be name clashing because of introducing new names.
                   clashedNames <- getClashedNames nm fstSubst newNames (ghead "foldParams" matches)

                   logm $ "MoveDef.foldParams about to foldInDemotedDecls"

                   demotedDecls''' <- foldInDemotedDecls pns clashedNames subst [demotedDecls]
                   logm $ "MoveDef.foldParams foldInDemotedDecls done"

                   let match' = GHC.L l ((GHC.unLoc match) {GHC.m_grhss = rhs' })
                   match'' <- addDecl match' Nothing (demotedDecls''',Nothing)
                   logm $ "MoveDef.foldParams addDecl done 1"
                   return match''
           else  do
                     logm $ "foldParams:no params"
                     let sigs = map wrapSig dsig
                     match' <- addDecl match Nothing (sigs++[demotedDecls],Nothing)
                     logm "MoveDef.foldParams addDecl done 2"
                     return match'

    where

       matchesInDecls :: GHC.LHsDecl GHC.RdrName -> [GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)]
#if __GLASGOW_HASKELL__ <= 710
       matchesInDecls (GHC.L _ (GHC.ValD (GHC.FunBind _ _ (GHC.MG matches _ _ _) _ _ _))) = matches
#else
       matchesInDecls (GHC.L _ (GHC.ValD (GHC.FunBind _ (GHC.MG (GHC.L _ matches) _ _ _) _ _ _))) = matches
#endif
       matchesInDecls _x = []

       patsInMatch (GHC.L _ (GHC.Match _ pats' _ _)) = pats'

       foldInDemotedDecls :: [GHC.Name]  -- ^The (list?) of names to be demoted
                          -> [GHC.Name]  -- ^Any names that clash
                          -> [(GHC.Name, GHC.HsExpr GHC.RdrName)] -- ^Parameter substitutions required
                          -> [GHC.LHsDecl GHC.RdrName] -- ^Binds of original top level entity, including src and dst
                          -> RefactGhc [GHC.LHsDecl GHC.RdrName]
       foldInDemotedDecls  pns' clashedNames subst decls = do
          logm $ "foldInDemotedDecls:(pns',clashedNames,subst)=" ++ showGhc (pns',clashedNames,subst)
          logm $ "foldInDemotedDecls:decls=" ++ SYB.showData SYB.Parser 0 decls
          nm <- getRefactNameMap
          SYB.everywhereMStaged SYB.Parser (SYB.mkM (worker nm) `SYB.extM` (workerBind nm)) decls
          where
#if __GLASGOW_HASKELL__ <= 710
          worker nm (match'@(GHC.L _ (GHC.FunBind ln _ (GHC.MG _matches _ _ _) _ _ _)) :: GHC.LHsBind GHC.RdrName)
#else
          worker nm (match'@(GHC.L _ (GHC.FunBind ln (GHC.MG _matches _ _ _) _ _ _)) :: GHC.LHsBind GHC.RdrName)
#endif
            = do
                logm $ "foldInDemotedDecls:rdrName2NamePure nm ln=" ++ show (rdrName2NamePure nm ln)
                if isJust (find (== rdrName2NamePure nm ln) pns')
                  then do
                    logm $ "foldInDemotedDecls:found match'"
                    match''  <- foldM (flip autoRenameLocalVar) match' clashedNames
                    match''' <- foldM replaceExpWithUpdToks match'' subst
                    rmParamsInDemotedDecls (map fst subst) match'''
                  else return match'
          worker _ x = return x

          workerBind nm ((GHC.L ll (GHC.ValD d)) :: GHC.LHsDecl GHC.RdrName)
            = do
                (GHC.L _ d') <- worker nm (GHC.L ll d)
                return (GHC.L ll (GHC.ValD d'))
          workerBind _ x = return x

      ------Get all of the paramaters supplied to pn ---------------------------
            {- eg. sumSquares x1 y1 x2 y2 = rt x1 y1 + rt x2 y2
                   rt x y = x+y
              demote 'rt' to 'sumSquares',
              'allParams pn rhs []'  returns [[x1,x2],[y1,y2]]
                where pn is 'rt' and  rhs is 'rt x1 y1 + rt x2 y2'
           -}

       allParams :: GHC.Name -> GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName)
                 -> [[GHC.HsExpr GHC.RdrName]]
                 -> RefactGhc [[GHC.HsExpr GHC.RdrName]]
       allParams pn rhs1 initial  -- pn: demoted function/pattern name.
        =do
            nm <- getRefactNameMap
            let p = getOneParam nm pn rhs1
            -- putStrLn (show p)
            logm $ "allParams:p=" ++ showGhc p
            if (nonEmptyList p)
              then do rhs' <- rmOneParam pn rhs1
                      logDataWithAnns "allParams:rhs'=" rhs'
                      allParams pn rhs' (initial++[p])
              else return initial
        where
           getOneParam :: (SYB.Data t) => NameMap -> GHC.Name -> t -> [GHC.HsExpr GHC.RdrName]
           getOneParam nm pn1
              = SYB.everythingStaged SYB.Renamer (++) []
                   ([] `SYB.mkQ`  worker)
              -- =applyTU (stop_tdTU (failTU `adhocTU` worker))
                where
                  worker :: GHC.HsExpr GHC.RdrName -> [GHC.HsExpr GHC.RdrName]
                  worker (GHC.HsApp e1 e2)
                   |(expToNameRdr nm e1 == Just pn1) = [GHC.unLoc e2]
                  worker _ = []

           rmOneParam :: (SYB.Data t) => GHC.Name -> t -> RefactGhc t
           rmOneParam pn1 t
              -- This genuinely needs to be done once only. Damn.
              -- =applyTP (stop_tdTP (failTP `adhocTP` worker))
             = do
                -- _ <- clearRefactDone
                nm <- getRefactNameMap
                everywhereMStaged' SYB.Parser (SYB.mkM (worker nm)) t
                where
                  worker nm (GHC.L _ (GHC.HsApp e1 _e2 )) -- The param being removed is e2
                    |expToNameRdr nm e1 == Just pn1 = return e1
                  worker _ x = return x
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
       rmParamsInDemotedDecls :: [GHC.Name] -> GHC.LHsBind GHC.RdrName
                              -> RefactGhc (GHC.LHsBind GHC.RdrName)
       rmParamsInDemotedDecls ps bind
         -- =applyTP (once_tdTP (failTP `adhocTP` worker))
         = SYB.everywhereMStaged SYB.Parser (SYB.mkM worker) bind
            where worker :: GHC.Match GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc (GHC.Match GHC.RdrName (GHC.LHsExpr GHC.RdrName))
                  worker (GHC.Match mfn' pats2 typ rhs1)
                    = do
                         nm <- getRefactNameMap
                         let pats'=filter (\x->not ((patToNameRdr nm x /= Nothing) &&
                                          elem (gfromJust "rmParamsInDemotedDecls" $ patToNameRdr nm x) ps)) pats2
                         return (GHC.Match mfn' pats' typ rhs1)

       ----------remove parameters in the parent functions' rhs-------------------
       rmParamsInParent :: GHC.Name -> [GHC.HsExpr GHC.RdrName]
                        -> GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName)
                        -> RefactGhc (GHC.GRHSs GHC.RdrName (GHC.LHsExpr GHC.RdrName))
       rmParamsInParent pn es grhss = do
         nm <- getRefactNameMap
         -- =applyTP (full_buTP (idTP `adhocTP` worker))
         SYB.everywhereMStaged SYB.Renamer (SYB.mkM (worker nm)) grhss
            where worker nm expr@(GHC.L _ (GHC.HsApp e1 e2))
                   | findNamesRdr nm [pn] e1 && (elem (showGhc (GHC.unLoc e2)) (map (showGhc) es))
                      = do
                       liftT $ transferEntryDPT expr e1
                       return e1
                  worker nm (expr@(GHC.L _ (GHC.HsPar e1)))
                    |Just pn==expToNameRdr nm e1
                       = do
                         liftT $ transferEntryDPT expr e1
                         return e1
                  worker _ x =return x


       getClashedNames :: NameMap -> [GHC.Name] -> [GHC.Name]
                       -> GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)
                       -> RefactGhc [GHC.Name]
       getClashedNames nm oldNames newNames match'
         = do  let (_f,DN d) = hsFDsFromInsideRdr nm match'
               ds'' <- mapM (flip (hsVisibleDsRdr nm) match') oldNames
               let ds' = map (\(DN ds) -> ds) ds''
               -- return clashed names
               return (filter (\x->elem ({- pNtoName -} x) newNames)  --Attention: nub
                                   ( nub (d `union` (nub.concat) ds')))

       ----- make Substitions between formal and actual parameters.-----------------
       mkSubst :: NameMap
               -> [GHC.LPat GHC.RdrName] -> [[GHC.HsExpr GHC.RdrName]]
               -> [(GHC.Name,GHC.HsExpr GHC.RdrName)]
       mkSubst nm pats1 params
           = catMaybes (zipWith (\x y -> if (patToNameRdr nm x/=Nothing) && (length (nub $ map showGhc y)==1)
                                          then Just (gfromJust "mkSubst" $ patToNameRdr nm x,(ghead "mkSubst") y)
                                          else Nothing) pats1 params)


-- |substitute an old expression by new expression
replaceExpWithUpdToks :: GHC.LHsBind GHC.RdrName -> (GHC.Name, GHC.HsExpr GHC.RdrName)
                      -> RefactGhc (GHC.LHsBind GHC.RdrName)
replaceExpWithUpdToks  decls subst = do
  nm <- getRefactNameMap
  let
    worker (e@(GHC.L l _)::GHC.LHsExpr GHC.RdrName)
      |(expToNameRdr nm e) == Just (fst subst)
          = return (GHC.L l (snd subst))
    worker x=return x

  -- = applyTP (full_buTP (idTP `adhocTP` worker)) decls
  everywhereMStaged' SYB.Parser (SYB.mkM worker) decls

-- | return True if pn is a local function/pattern name
isLocalFunOrPatName :: SYB.Data t => NameMap -> GHC.Name -> t -> Bool
isLocalFunOrPatName nm pn scope
 = isLocalPN pn && isFunOrPatName nm pn scope

-- EOF
