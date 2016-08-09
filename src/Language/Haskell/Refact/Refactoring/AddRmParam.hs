{-# LANGUAGE CPP #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Language.Haskell.Refact.Refactoring.AddRmParam
       ( addOneParameter, compAddOneParameter
       , rmOneParameter, compRmOneParameter
       ) where

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import qualified GHC
import qualified Name                  as GHC
import qualified Outputable            as GHC

import qualified Language.Haskell.GhcMod as GM
import Language.Haskell.GhcMod.Internal  as GM
import Language.Haskell.Refact.API

import Language.Haskell.GHC.ExactPrint.Types
import Language.Haskell.GHC.ExactPrint.Transform
import Language.Haskell.GHC.ExactPrint.Utils

import System.Directory
import Data.Char
import Data.Foldable
import Data.Maybe
import Data.List hiding (delete)

import Data.Generics.Strafunski.StrategyLib.StrategyLib

-----------------------------------------------------------------------------------------------------
{- An argument can be added to the definition of a function or constant. Adding an argument to a constant
   definition will change the constant definition to a function definition.  The new parameter is always
   added as the first parameter of the function. A default parameter will be added as the first argument
   to each of the function's call site. Suppose a new  parameter named 'p' is added to function 'f',
   then default parameter will be defined automatically as p_f_i=undefined, where 'i' is an integer.
   To ensure that the default parameter name does not cause name clash in the client modules, we take the
   visble names both in the current module and in the client modules into account when creating the
   name.

-}
-----------------------------------------------------------------------------------------------------

addOneParameter :: RefactSettings -> GM.Options -> FilePath -> String -> SimpPos -> IO [FilePath]
addOneParameter settings opts fileName paramName (row,col) = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings opts (compAddOneParameter absFileName paramName (row,col))

compAddOneParameter :: FilePath -> String -> SimpPos -> RefactGhc [ApplyRefacResult]
compAddOneParameter fileName paramName (row, col) = do
  if isVarId paramName
    then
      do
        parseSourceFileGhc fileName
        parsed  <- getRefactParsed
        nm      <- getRefactNameMap
        logParsedSource "compAdd entry"
        targetModule <- getRefactTargetModule
        logm $ "AddRmParam.compAdd:got targetModule"
        let maybePn = locToNameRdrPure nm (row, col) parsed
        case maybePn of
          Just pn ->
            do
              logm $ "AddRmParam.compAdd:about to applyRefac for:pn=" ++ SYB.showData SYB.Parser 0 pn
              -- make sure this name is defined in this module
              if isFunOrPatName nm pn parsed
               then do
                  exported <- isExported pn
                  if exported
                    then do
                     clients <- clientModsAndFiles targetModule
                     decls <- liftT $ hsDecls parsed
                     let inscopes = []
                     defaultArg <- mkTopLevelDefaultArgName pn paramName inscopes decls
                     logm $ "compAdd:defaultArg=" ++ showGhc defaultArg
                     (refactoredMod,_) <- applyRefac (doAddingParam pn paramName (Just defaultArg) True) RSAlreadyLoaded
                     refactoredClients <- mapM (addArgInClientMod pn defaultArg) clients
                     -- let refactoredClients = []
                     return $ refactoredMod:refactoredClients
                    else do
                     logm $ "compAdd:not exported"
                     (refactoredMod,_) <- applyRefac (doAddingParam pn paramName Nothing False) (RSFile fileName)
                     return [refactoredMod]

               else error "Invalid cursor position or identifier is not a function/pattern name defined in this module!\n"
          Nothing -> error "Invalid cursor position or identifier is not a function/pattern name defined in this module!\n"
    else error $ "Invalid parameter name:" ++ paramName ++ "!"


-- ---------------------------------------------------------------------

doAddingParam :: GHC.Name -> String -> Maybe (GHC.Located GHC.RdrName) -> Bool
              -> RefactGhc ()
doAddingParam pn newParam defaultArg isExported' = do
    logm $ "doAddingParam entered:defaultArg=" ++ showGhc defaultArg
    parsed <- getRefactParsed
    -- logDataWithAnns "parsed" parsed
    r <- applyTP (once_tdTP (failTP `adhocTP` inMod
                                    `adhocTP` inMatch
                                    -- `adhocTP` inPat
                                    `adhocTP` inLet
                                    -- `adhocTP` inAlt
                                    `adhocTP` inLetStmt
                            )
                           `choiceTP` failure) parsed
    putRefactParsed r emptyAnns
    return ()
      where
             --1.pn is declared in top level
             inMod :: GHC.ParsedSource -> RefactGhc GHC.ParsedSource
             inMod modu = do
               nm <- getRefactNameMap
               decls <- liftT $ hsDecls modu
               if not ( null (definingDeclsRdrNames nm [pn] decls False False))
                then
                 do
                    logm $ "doAddingParam.inMod doing it"
                    ds <- liftT $ hsDecls modu
                    modu' <- doAdding modu ds
                    if isExported' && isExplicitlyExported nm pn modu
                      then addItemsToExport modu' (Just pn) False (Left [GHC.unLoc (fromJust defaultArg)])
                      else return modu'
                else mzero

             --2. pn is declared locally in the where clause of a match.
             inMatch ::GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName)
                     -> RefactGhc (GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))
             inMatch match
               = do
                   nm <- getRefactNameMap
                   decls <- liftT $ hsDecls match
                   logm $ "doAddingParam.inMatch:decls=" ++ showGhc decls
                   if not ( null (definingDeclsRdrNames nm [pn] decls False False))
                      then doAdding match decls
                      else mzero

{-
             --3. pn is declared locally in the where clause of a pattern binding.
             inPat (pat@(Dec (HsPatBind loc p rhs ds))::HsDeclP)
               | definingDecls [pn] ds False  False/=[]  = doAdding pat  ds
             inPat _ = mzero
-}

             --4: pn is declared locally in a  Let expression
             inLet (letExp@(GHC.L _ (GHC.HsLet _ds _e)) :: GHC.LHsExpr GHC.RdrName)
               = do
                   nm <- getRefactNameMap
                   decls <- liftT $ hsDecls letExp
                   -- logm $ "doAddingParam.inLet:decls=" ++ showGhc decls
                   if not ( null (definingDeclsRdrNames nm [pn] decls False False))
                      then doAdding letExp decls
                      else mzero
#if __GLASGOW_HASKELL__ <= 710
             inLet ((GHC.L l (GHC.HsDo ctx stmts ptt)) :: GHC.LHsExpr GHC.RdrName)
#else
             inLet ((GHC.L l (GHC.HsDo ctx (GHC.L ls stmts) ptt)) :: GHC.LHsExpr GHC.RdrName)
#endif
               = do
                   nm <- getRefactNameMap
                   -- logm $ "doAddingParam.inHsDo:stmts=" ++ showGhc stmts
                   if not ( null (definingDeclsRdrNames' nm [pn] stmts))
                      then do
                           stmts' <- doAddingStmts stmts
                           stmts2 <- applyTP (once_tdTP (failTP `adhocTP` inMod
                                                                `adhocTP` inMatch
                                                                -- `adhocTP` inPat
                                                                `adhocTP` inLet
                                                                -- `adhocTP` inHsDo
                                                                -- `adhocTP` inAlt
                                                               `adhocTP` inLetStmt
                                                         )
                                                        `choiceTP` failure) stmts'
#if __GLASGOW_HASKELL__ <= 710
                           return (GHC.L l (GHC.HsDo ctx stmts2 ptt))
#else
                           return (GHC.L l (GHC.HsDo ctx (GHC.L ls stmts2) ptt))
#endif
                      else mzero
             inLet _ = mzero

{-
             --5. pn is declared locally in a  case alternative.
             inAlt (alt@(HsAlt loc p rhs ds)::HsAltP)
               | definingDecls [pn] ds False  False/=[] = doAdding  alt  ds
             inAlt _ = mzero
-}

             --6.pn is declared locally in a let statement.
             inLetStmt (letStmt@(GHC.L _ (GHC.LetStmt _stmts)):: GHC.ExprLStmt GHC.RdrName)
               = do
                   nm <- getRefactNameMap
                   decls <- liftT $ hsDecls letStmt
                   if not ( null (definingDeclsRdrNames nm [pn] decls False False))
                      then doAdding letStmt decls
                      else mzero
             inLetStmt _ = mzero

             failure = idTP `adhocTP` modu
               where modu (_::GHC.ParsedSource) = error "Refactoring failed"


             doAdding :: (HasDecls t) => t -> [GHC.LHsDecl GHC.RdrName] -> RefactGhc t
             doAdding parent ds = do
               nm <- getRefactNameMap
               if paramNameOk nm pn newParam ds
                   then do
                       ds' <- addParamsToDecls ds pn [mkRdrName newParam] --addFormalParam pn newParam ds
                       defaultParamPName <-if isNothing defaultArg
                                           then mkLocalDefaultArgName pn newParam parent
                                           else return (gfromJust "doAdding" defaultArg)
                       parent1 <- liftT $ replaceDecls parent ds'
                       parent' <- addDefaultActualArg False pn defaultParamPName parent1
                       parent''<- addDefaultActualArgDecl defaultParamPName parent' pn isExported'
                       ds2 <- liftT $ hsDecls parent''
                       ds'' <- addArgToSig pn ds2
                       parent3 <- liftT $ replaceDecls parent'' ds''
                       return parent3
                   else error " Refactoring failed."

             doAddingStmts :: [GHC.ExprLStmt GHC.RdrName] -> RefactGhc [GHC.ExprLStmt GHC.RdrName]
             doAddingStmts stmts = do
               logDataWithAnns "doAddingStmts:stmts:" stmts
               nm <- getRefactNameMap
               if paramNameOk nm pn newParam stmts
                   then do
                       defaultParamPName <-if isNothing defaultArg
                                           then mkLocalDefaultArgName pn newParam stmts
                                           else return (gfromJust "doAddingStmts" defaultArg)
                       stmts' <- addDefaultActualArg False pn defaultParamPName stmts
                       return stmts'
                   else error " Refactoring failed."

-- ---------------------------------------------------------------------

-- |check whether the new parameter is a legal.
paramNameOk :: (SYB.Data t) => NameMap -> GHC.Name -> String -> t -> Bool
paramNameOk nm pn newParam t
  = (fromMaybe True) (applyTU (once_tdTU (failTU `adhocTU` decl
                                                 `adhocTU` bind)) t)
  where
   decl :: GHC.LHsDecl GHC.RdrName -> Maybe Bool
   decl (GHC.L l (GHC.ValD d)) = bind (GHC.L l d)
   decl _ = mzero

   bind :: GHC.LHsBind GHC.RdrName -> Maybe Bool
#if __GLASGOW_HASKELL__ <= 710
   bind (GHC.L _ (GHC.FunBind n _i (GHC.MG matches _a _ptt _o) _co _fvs _))
#else
   bind (GHC.L _ (GHC.FunBind n (GHC.MG matches _a _ptt _o) _co _fvs _))
#endif
    | rdrName2NamePure nm n == pn
    = do results' <- mapM checkInMatch matches
         Just (all (==True) results')
   bind (GHC.L _ (GHC.PatBind _pat _rhs _ty _fvs _t))
      = error "Parameter can not be added to complex pattern binding"
   bind _ = mzero

   checkInMatch match
     = do let (f,d) = hsFDNamesFromInsideRdrPure nm match
          if elem newParam (f `union` d)
           then error "The new parameter name will cause name clash or semantics change, please choose another name!"
           else return True

-- ---------------------------------------------------------------------

-- |add the default argument declaration right after the declaration defining pn
addDefaultActualArgDecl :: (SYB.Data t) => GHC.Located GHC.RdrName -> t -> GHC.Name -> Bool -> RefactGhc t
addDefaultActualArgDecl defaultParamPName parent pn isExported' = do
  defaultArgDecl <- parseDeclWithAnns ((showGhc defaultParamPName) ++ " = undefined")
  nm <- getRefactNameMap
  let inParent = findLRdrName nm pn parent
  if not inParent && not isExported'
    then return parent
    else addDecl parent (Just pn) ([defaultArgDecl],Nothing)

-- ---------------------------------------------------------------------

-- |suppose function name is f, parameter name is p, then the default argument
-- name is like f_p.
mkLocalDefaultArgName :: (SYB.Data t)
                      => GHC.Name -> String -> t -> RefactGhc (GHC.Located GHC.RdrName)
mkLocalDefaultArgName fun paramName t = do
  logm $ "mkLocalDefaultArgName"
  (f,d) <- hsFDNamesFromInsideRdr t
  vs <- hsVisibleNamesRdr fun t -- ++AZ++ TODO : FindEntity on fun will fail in a RdrName AST
  let name = mkNewName ((showGhc fun)++"_"++paramName) (nub (f `union` d `union` vs)) 0
  loc <- liftT $ uniqueSrcSpanT
  let vn = (GHC.L loc (mkRdrName name))
  liftT $ addSimpleAnnT vn (DP (0,1)) [((G GHC.AnnVal),DP (0,0))]
  return vn

-- ---------------------------------------------------------------------

mkTopLevelDefaultArgName :: (SYB.Data t,GHC.Outputable a)
                         => a -> String -> [String] -> t
                         -> RefactGhc (GHC.Located GHC.RdrName)
mkTopLevelDefaultArgName fun paramName inscopeNames t = do
  (f,d) <- hsFDNamesFromInsideRdr t
  let name = mkNewName ((showGhc fun)++"_"++paramName) (nub (f `union` d `union` inscopeNames)) 0
  loc <- liftT $ uniqueSrcSpanT
  let vn = (GHC.L loc (mkRdrName name))
  liftT $ addSimpleAnnT vn (DP (0,1)) [((G GHC.AnnVal),DP (0,0))]
  return vn

-- ---------------------------------------------------------------------

-- |Add the default argument to each call site of the function receiving the new parameter (AZ)
addDefaultActualArg :: (SYB.Data t)
                    => Bool -- ^If True recursively add the parameter to all
                            -- occurences of the function call site. If False,
                            -- stop the recursion when hitting the function
                            -- itself.
                    -> GHC.Name -- ^ The function name to receive the new parameter
                    -> GHC.Located GHC.RdrName -- ^The new parameter name
                        -- ++AZ++: why is it located?
                    -> t -- ^The AST fragment to be updated
                    -> RefactGhc t
addDefaultActualArg recursion pn argPName t = do
  logm $ "addDefaultActualArg:(recursion,pn,argPName):" ++ showGhc (recursion,pn,argPName)
  logDataWithAnns "addDefaultActualArg:t=:" t
  nm <- getRefactNameMap
  if recursion then (applyTP (stop_tdTP (failTP `adhocTP` (funApp nm)))) t
               else (applyTP (stop_tdTP (failTP `adhocTP` (inDecl nm)
                                                `adhocTP` (funApp nm)))) t
       where
         inDecl :: NameMap -> GHC.LHsDecl GHC.RdrName -> RefactGhc (GHC.LHsDecl GHC.RdrName)
#if __GLASGOW_HASKELL__ <= 710
         inDecl nm fun@(GHC.L _ (GHC.ValD (GHC.FunBind n _i _ _co _fvs _)))
#else
         inDecl nm fun@(GHC.L _ (GHC.ValD (GHC.FunBind n _ _co _fvs _)))
#endif
           | rdrName2NamePure nm n == pn
           = return fun -- Stop the recursion by not returning mzero

         -- inDecl (pat@(Dec (HsPatBind loc1 ps rhs ds))::HsDeclP)
         --   | pn == patToPN  ps
         --   = return pat
         inDecl _ _ = mzero

         funApp :: NameMap -> GHC.LHsExpr GHC.RdrName -> RefactGhc (GHC.LHsExpr GHC.RdrName)
#if __GLASGOW_HASKELL__ <= 710
         funApp nm (expr@(GHC.L l (GHC.HsVar n))::GHC.LHsExpr GHC.RdrName)
#else
         funApp nm (expr@(GHC.L l (GHC.HsVar (GHC.L _ n)))::GHC.LHsExpr GHC.RdrName)
#endif
          | rdrName2NamePure nm (GHC.L l n) == pn = do
            logm $ "addDefaultActualArg.funApp:expr=" ++ showGhc expr
            addParamToExp expr (GHC.unLoc argPName)

         funApp _ _ = mzero


-- ---------------------------------------------------------------------

-- | Add a parameter to a 'GHC.HsVar' expression
addParamToExp :: GHC.LHsExpr GHC.RdrName -> GHC.RdrName
              -> RefactGhc (GHC.LHsExpr GHC.RdrName)
addParamToExp (expr@(GHC.L _ (GHC.HsVar _))) argPName = do
  lp <- liftT uniqueSrcSpanT
  la <- liftT uniqueSrcSpanT
  lv <- liftT uniqueSrcSpanT
#if __GLASGOW_HASKELL__ <= 710
  let e2 = GHC.L lv (GHC.HsVar argPName)
  liftT $ addSimpleAnnT e2  (DP (0,1)) [((G GHC.AnnVal),DP (0,0))]
#else
  let lname = GHC.L lv argPName
  let e2 = GHC.L lv (GHC.HsVar lname)
  liftT $ addSimpleAnnT e2 (DP (0,1)) [((G GHC.AnnVal),DP (0,0))]
#endif
  let ret = GHC.L lp (GHC.HsPar (GHC.L la (GHC.HsApp expr e2)))
  liftT $ addSimpleAnnT ret (DP (0,0)) [((G GHC.AnnOpenP),DP (0,0)),((G GHC.AnnCloseP),DP (0,0))]
  liftT $ transferEntryDPT expr ret
  liftT $ setEntryDPT expr (DP (0,0))
  return ret
addParamToExp x _
  = error $ "AddRmParam.addParamToExp: can only add param to HsVar, got:" ++ showGhc x

-- ---------------------------------------------------------------------

-- |Add type arg to type siginature
addArgToSig :: GHC.Name -> [GHC.LHsDecl GHC.RdrName] -> RefactGhc [GHC.LHsDecl GHC.RdrName]
addArgToSig pn decls = do
   nm <- getRefactNameMap
   let (before,after) = break (\d -> definesSigDRdr nm pn d) decls
     in if  null after
       then  return decls
       else  do newSig<-addArgToSig' [(head after)]  --no problem with head.
                return (before++newSig++(tail after))

    where
       addArgToSig' :: [GHC.LHsDecl GHC.RdrName] -> RefactGhc [GHC.LHsDecl GHC.RdrName]
#if __GLASGOW_HASKELL__ <= 710
       addArgToSig' sig@[(GHC.L l (GHC.SigD (GHC.TypeSig is tp pr)))] = do
#else
       addArgToSig' sig@[(GHC.L l (GHC.SigD (GHC.TypeSig is typ@(GHC.HsIB ivs (GHC.HsWC wcs mwc tp)))))] = do
#endif
              nm <- getRefactNameMap
              let tVar = mkNewTypeVarName sig
#if __GLASGOW_HASKELL__ <= 710
              typeVar <- newTypeVar tVar tp
#else
              typeVar' <- newTypeVar tVar tp
              let typeVar = GHC.HsIB ivs (GHC.HsWC wcs mwc typeVar')
#endif
              let newSig=if length is==1
#if __GLASGOW_HASKELL__ <= 710
                           then  --the type sig only defines the type for pn
                                [GHC.L l (GHC.SigD (GHC.TypeSig is typeVar pr))]
                           else  --otherwise, seperate it into two type signatures.
                               [GHC.L l (GHC.SigD (GHC.TypeSig (filter (\x->rdrName2NamePure nm x/=pn) is) tp pr)),
                                GHC.L l (GHC.SigD (GHC.TypeSig (filter (\x->rdrName2NamePure nm x==pn) is) typeVar pr))]
#else
                           then  --the type sig only defines the type for pn
                                [GHC.L l (GHC.SigD (GHC.TypeSig is typeVar))]
                           else  --otherwise, seperate it into two type signatures.
                               [GHC.L l (GHC.SigD (GHC.TypeSig (filter (\x->rdrName2NamePure nm x/=pn) is) typ)),
                                GHC.L l (GHC.SigD (GHC.TypeSig (filter (\x->rdrName2NamePure nm x==pn) is) typeVar))]
#endif
              return newSig
       addArgToSig' sig = do
         logm $ "addArgToSig':not processing " ++ showGhc sig
         return sig


       -- compose a type application using type expressions tv and tp
       newTypeVar :: String -> GHC.LHsType GHC.RdrName -> RefactGhc (GHC.LHsType GHC.RdrName)
       newTypeVar tVar tp = do
         ls <- liftT $ uniqueSrcSpanT
         lv <- liftT $ uniqueSrcSpanT
#if __GLASGOW_HASKELL__ <= 710
         let tv = GHC.L lv (GHC.HsTyVar (mkRdrName tVar))
         liftT $ addSimpleAnnT tv  (DP (0,0)) [((G GHC.AnnVal),DP (0,0))]
#else
         let lname = GHC.L lv (mkRdrName tVar)
         let tv = GHC.L lv (GHC.HsTyVar lname)
         liftT $ addSimpleAnnT lname  (DP (0,0)) [((G GHC.AnnVal),DP (0,0))]
#endif
         let typ = GHC.L ls (GHC.HsFunTy tv tp)
         liftT $ addSimpleAnnT typ (DP (0,1)) [((G GHC.AnnRarrow),DP (0,1))]
         return typ

       -- make a fresh type variable name. the new name is the first letter in
       -- the alphabet which is not used in the type signature.
       mkNewTypeVarName :: [GHC.LHsDecl GHC.RdrName] -> String
       mkNewTypeVarName sig
          =mkANewName "a" $ map showGhc $ (snd.hsTypeVbls) sig
             where mkANewName initName v
                     =if elem initName v
                         then mkANewName ((intToDigit (digitToInt(head initName)+1)):tail initName) v
                         else initName

-- ---------------------------------------------------------------------

addArgInClientMod :: GHC.Name -> GHC.Located GHC.RdrName -> TargetModule -> RefactGhc ApplyRefacResult
addArgInClientMod pnt defaultArg serverModName = do
  (r,_) <- applyRefac (addArgInClientMod' pnt defaultArg (GM.mpModule serverModName)) (RSTarget serverModName)
  return r


addArgInClientMod' :: GHC.Name -> GHC.Located GHC.RdrName -> GHC.ModuleName -> RefactGhc ()
addArgInClientMod' pnt defaultArg serverModName = do
   parsed <- getRefactParsed
   let pn = pnt
   qual <- hsQualifier pnt
   if qual == []
          then return ()
          else do
            mod'  <- addItemsToImport serverModName  (Just pn) (Left [GHC.unLoc defaultArg]) parsed
            mod'' <- addItemsToExport mod' (Just pn) False (Left [GHC.unLoc defaultArg])
            mod3 <- addDefaultActualArgInClientMod pn defaultArg mod''
            putRefactParsed mod3 emptyAnns
            return ()


-- ---------------------------------------------------------------------

-- |Add default actual argument to pn in all the calling places.
addDefaultActualArgInClientMod :: (SYB.Data t)
  => GHC.Name -> GHC.Located GHC.RdrName -> t
  -> RefactGhc t
addDefaultActualArgInClientMod pn argPName t = do
  logm $ "addDefaultActualArgInClientMod entered:argPName=" ++ showGhc argPName
  nm <- getRefactNameMap
  r <- applyTP (stop_tdTP (failTP `adhocTP` (funApp nm))) t
  return r
  where
#if __GLASGOW_HASKELL__ <= 710
    funApp nm (expr@((GHC.L l (GHC.HsVar pname )))::GHC.LHsExpr GHC.RdrName)
#else
    funApp nm (expr@((GHC.L l (GHC.HsVar (GHC.L _ pname) )))::GHC.LHsExpr GHC.RdrName)
#endif
      | GHC.nameUnique (rdrName2NamePure nm (GHC.L l pname)) == GHC.nameUnique pn
       = do
            logm $ "addDefaultActualArgInClientMod:hit"
            -- vs <- hsVisibleNamesRdr (GHC.L l pname) t
            let argExp = GHC.unLoc argPName
            addParamToExp expr argExp
    funApp _ _ = mzero

-------------------------------End of adding a parameter-----------------------------------

-----------------------------------------------------------------------------------------------------
{-Refactoring: Remove a parameter
  Description: The refactoring removes a user specified formal parameter in a function binding,and
               the corresponding actual parameters in all calling places of this function. The
               condition acompanying this refactoring is that the parameter to be removed is not being used.

  --To select a parameter, just stop the cursor at any position between the start and end position of this parameter.
-}
-----------------------------------------------------------------------------------------------------

-- |The refactoring removes a user specified formal parameter in a function
-- binding,and the corresponding actual parameters in all calling places of this
-- function. The condition acompanying this refactoring is that the parameter to
-- be removed is not being used.
-- The @SimpPos@ should be somwewhere inside the parameter to be removed
rmOneParameter :: RefactSettings -> GM.Options -> FilePath -> SimpPos -> IO [FilePath]
rmOneParameter settings opts fileName (row,col) = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings opts (compRmOneParameter absFileName (row,col))

compRmOneParameter :: FilePath -> SimpPos -> RefactGhc [ApplyRefacResult]
compRmOneParameter fileName (row, col) = do
  parseSourceFileGhc fileName
  -- logParsedSource "compRm entry"
  -- pn is the function names.
  -- nth is the nth paramter of pn is to be removed,index starts from 0.
  mp <- getParam (row,col)
  case mp of
    Nothing -> error "Invalid cursor position!"  -- cursor doesn't stop at a parameter position.
    Just (pn,pnth) -> do
      logm $ "compRm:(pn,pnth)=" ++ showGhc (pn,pnth)
      exported <- isExported pn
      if exported
        then do
          logm $ "compRm: exported"
          (refactoredMod,_) <- applyRefac (doRmParam pn pnth) (RSFile fileName)
          targetModule <- getRefactTargetModule
          clients <- clientModsAndFiles targetModule
          logm $ "compRm: clients:" ++ showGhc clients
          refactoredClients <- mapM (rmParamInClientMod pn pnth) clients
          -- let refactoredClients = []
          return $ refactoredMod:refactoredClients
        else do
          logm $ "compRm:not exported"
          (refactoredMod,_) <- applyRefac (doRmParam pn pnth) (RSFile fileName)
          return [refactoredMod]


-- ---------------------------------------------------------------------

--pn: function name; nth: the index of the parameter to be removed.
doRmParam :: GHC.Name -> Int -> RefactGhc ()
doRmParam pn nTh = do
    logm $ "doRmParam entered:(pn,nth)=" ++ showGhc (pn,nTh)
    parsed <- getRefactParsed
    r <- applyTP ((once_tdTP (failTP `adhocTP` inMod
                                     `adhocTP` inMatch
                                     -- `adhocTP` inPat
                                     `adhocTP` inLet
                                     -- `adhocTP` inAlt
                                     `adhocTP` inLetStmt
                             ))
                  `choiceTP` failure) parsed
    logm $ "doRmParam after applyTP"
    putRefactParsed r emptyAnns
    logParsedSource "doRmParam:parsed after"
    return ()
      where
             --1. pn is declared in top level.
             inMod :: GHC.ParsedSource -> RefactGhc GHC.ParsedSource
             inMod modu = doRemoving' modu

             -- --2. pn is declared locally in the where clause of a match.
             inMatch :: GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName) -> RefactGhc (GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))
#if __GLASGOW_HASKELL__ <= 710
             inMatch match@(GHC.L _ (GHC.Match (Just (_fun,_)) _pats _mtyp (GHC.GRHSs _rhs _ds)))
#else
             inMatch match@(GHC.L _ (GHC.Match (GHC.FunBindMatch _fun _) _pats _mtyp (GHC.GRHSs _rhs _ds)))
#endif
               = doRemoving' match
             inMatch _ = mzero

             -- --3. pn is declared locally in the where clause of a pattern binding.
             -- inPat (pat@(Dec (HsPatBind loc p rhs ds))::HsDeclP)
             --    | definingDecls [pn] ds False  False/=[]  = doRemoving pat  ds
             -- inPat _=mzero

             -- --4: pn is declared locally in a  Let expression
             inLet :: GHC.LHsExpr GHC.RdrName -> RefactGhc (GHC.LHsExpr GHC.RdrName)
             inLet letExp@(GHC.L _ (GHC.HsLet _bs _e))
               = doRemoving' letExp
#if __GLASGOW_HASKELL__ <= 710
             inLet (GHC.L l (GHC.HsDo ctx stmts ptt))
#else
             inLet (GHC.L l (GHC.HsDo ctx (GHC.L ls stmts) ptt))
#endif
               = do
                   nm <- getRefactNameMap
                   if not ( null (definingDeclsRdrNames' nm [pn] stmts))
                      then do
                           stmts' <- doRemovingStmts stmts
#if __GLASGOW_HASKELL__ <= 710
                           return (GHC.L l (GHC.HsDo ctx stmts' ptt))
#else
                           return (GHC.L l (GHC.HsDo ctx (GHC.L ls stmts') ptt))
#endif
                      else mzero
             inLet _ = mzero

             -- --5. pn is declared locally in a  case alternative.
             -- inAlt (alt@(HsAlt loc p rhs ds)::HsAltP)
             --    | definingDecls [pn] ds False  False/=[]  = doRemoving  alt  ds
             -- inAlt _=mzero

             -- --6.pn is declared locally in a let statement.
             inLetStmt :: GHC.ExprLStmt GHC.RdrName -> RefactGhc (GHC.ExprLStmt GHC.RdrName)
             inLetStmt letStmt@(GHC.L _ (GHC.LetStmt _))
               = doRemoving' letStmt
             inLetStmt _ = mzero

             failure = idTP `adhocTP` modu
               where modu (_m::GHC.ParsedSource) = error "Refactoring failed"

             -- ------------------------

             doRemoving' parent = do
               nm <- getRefactNameMap
               decls <- liftT $ hsDecls parent
               if not ( null (definingDeclsRdrNames nm [pn] decls False False))
                  then doRemoving parent decls
                  else mzero

             doRemoving :: (HasDecls t) => t -> [GHC.LHsDecl GHC.RdrName] -> RefactGhc t
             doRemoving parent ds  --PROBLEM: How about doRemoving fails?
                =do
                    -- Check the preconditions, will error on failure
                    void $ rmFormalArg pn nTh False True =<< rmNthArgInFunCall pn nTh ds

                    -- preconditions passed, do the transformation
                    ds' <- rmNthArgInSig pn nTh   =<< rmFormalArg pn nTh True False  ds
                    ds'' <- liftT $ replaceDecls parent ds'
                    rmNthArgInFunCall pn nTh ds''

             doRemovingStmts :: [GHC.ExprLStmt GHC.RdrName] -> RefactGhc [GHC.ExprLStmt GHC.RdrName]
             doRemovingStmts stmts
                =do
                    -- Check the preconditions, will error on failure
                    void $ rmFormalArg pn nTh False True =<< rmNthArgInFunCall pn nTh stmts

                    -- preconditions passed, do the transformation
                    stmts' <- rmFormalArg pn nTh True False stmts
                    rmNthArgInFunCall pn nTh stmts'

             -- |Just remove the nth formal parameter.
             rmFormalArg :: (SYB.Data t) => GHC.Name -> Int -> Bool -> Bool -> t -> RefactGhc t
             rmFormalArg pn' nTh' updateToks checking t = do
               logm $ "rmFormalArg:(pn,nTh,updateToks,checking)=" ++ showGhc (pn',nTh',updateToks,checking)
               -- logDataWithAnns "rmFormalArg:t=" t
               nm <- getRefactNameMap
               applyTP (stop_tdTP (failTP `adhocTP` (rmInMatch nm))) t

               where
                 -- a formal parameter only exists in a match
#if __GLASGOW_HASKELL__ <= 710
                 rmInMatch nm (match@(GHC.L l (GHC.Match (Just (fun,b)) pats typ (GHC.GRHSs rhs decls)))::GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))
#else
                 rmInMatch nm (match@(GHC.L l (GHC.Match (GHC.FunBindMatch fun b) pats typ (GHC.GRHSs rhs decls)))::GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))
#endif
                   | rdrName2NamePure nm fun == pn' =
                       let  pat = pats!!nTh'     --get the nth formal parameter
                            pats' = take nTh' pats ++ drop (nTh' + 1) pats
                            pNames = map (rdrName2NamePure nm) $ hsNamessRdr pat  --get all the names in this pat. (the pat may be just be a variable)
                       in if checking && not ( all (==False) ((map (flip (findNameInRdr nm) rhs) pNames)) && --not used in rhs
                                               all (==False) ((map (flip (findNameInRdr nm) decls) pNames))) --not used in the where clause
                            then error  "This parameter can not be removed, as it is used!"
                            else do
                              -- If we have removed the last parametwer, make
                              -- sure the AnnEqual annotation takes its spacing
                              -- from the original parameter spacing
                              when (null pats') $ do
                                dp <- liftT $ getEntryDPT (ghead "rmFormalArg" pats)
                                logm $ "rmFormalArg.rmInMatch:dp=" ++ show dp
                                liftT $ setAnnKeywordDP match (G GHC.AnnEqual) dp
#if __GLASGOW_HASKELL__ <= 710
                              return (GHC.L l (GHC.Match (Just (fun,b)) pats' typ (GHC.GRHSs rhs decls)))
#else
                              return (GHC.L l (GHC.Match (GHC.FunBindMatch fun b) pats' typ (GHC.GRHSs rhs decls)))
#endif
                 rmInMatch _ _ = mzero

-- ---------------------------------------------------------------------

-- |Remove the nth argument of function pn in all the calling places. The index
-- for the first argument is zero.
rmNthArgInFunCall :: (SYB.Data t) => GHC.Name -> Int -> t -> RefactGhc t
rmNthArgInFunCall pn nTh t = do
  nm <- getRefactNameMap
  applyTP (stop_tdTP (failTP `adhocTP` (funApp nm))) t
   where
         funApp nm (expr@(GHC.L _ (GHC.HsPar (GHC.L _ (GHC.HsApp e1 _e2))))::GHC.LHsExpr GHC.RdrName)
              | nTh == 0 && Just pn == expToNameRdr nm e1
             = do
                 liftT $ transferEntryDPT expr e1
                 return e1 -- handle the case like '(fun x) => fun "
         funApp nm (expr@(GHC.L _ (GHC.HsApp _e1 _e2))) = do
                --test if this application is a calling of fun pn.
              let expu = unfoldHsApp expr
              ed <- liftT $ getEntryDPT expr
              if Just pn == (expToNameRdr nm.snd.(ghead "rmNthArgInFunCall")) expu
               then do
                  let (before,after)=splitAt (nTh+1) expu   --remove the nth argument
                  let exp' = (foldHsApp (before++tail after))  --reconstruct the function application.
                  liftT $ setEntryDPT exp' ed
                  return exp'
               else mzero

         funApp _ _ = mzero

         -- |deconstruct a function application into a list of expressions.
         unfoldHsApp :: GHC.LHsExpr GHC.RdrName -> [(GHC.SrcSpan, GHC.LHsExpr GHC.RdrName)]
         unfoldHsApp expr =
              case expr of
                  (GHC.L l (GHC.HsApp e1 e2)) -> unfoldHsApp e1 ++ [(l,e2)]
                  _                           -> [(GHC.noSrcSpan,expr)]

         -- |reconstruct  a function application by a list of expressions.
         foldHsApp :: [(GHC.SrcSpan, GHC.LHsExpr GHC.RdrName)] -> GHC.LHsExpr GHC.RdrName
         foldHsApp [] = error "foldHsApp:empty list"
         foldHsApp exps = snd $ foldl1 (\(_l1,e1) (l2,e2) -> (l2,GHC.L l2 (GHC.HsApp e1 e2))) exps


-- ---------------------------------------------------------------------

rmNthArgInSig :: GHC.Name -> Int -> [GHC.LHsDecl GHC.RdrName] -> RefactGhc [GHC.LHsDecl GHC.RdrName]
rmNthArgInSig pn nTh decls = do
  nm <- getRefactNameMap
  let (before,after)=break (\d ->definesSigDRdr nm pn d) decls
  if null after
       then  return decls
       else  do newSig<-rmNthArgInSig' nm [(head after)]  --no problem with 'head'
                return (before++newSig++(tail after))

   where
#if __GLASGOW_HASKELL__ <= 710
         rmNthArgInSig' nm [GHC.L l (GHC.SigD (GHC.TypeSig is typ@(GHC.L lt (GHC.HsForAllTy ex wc bnd ctx tp)) c))]
#else
         -- rmNthArgInSig' nm [GHC.L l (GHC.SigD (GHC.TypeSig is typ@(GHC.HsIB ivs (GHC.HsWC wcs mwc (GHC.L lt (GHC.HsForAllTy bnd tp))))))]
         rmNthArgInSig' nm [GHC.L l (GHC.SigD (GHC.TypeSig is typ@(GHC.HsIB ivs (GHC.HsWC wcs mwc tp))))]
#endif
          =do
              ed <- liftT $ getEntryDPT tp
              let (GHC.L lp tp') = rmNth tp
              lp' <- liftT uniqueSrcSpanT
              liftT $ modifyAnnsT $ copyAnn (GHC.L lp tp') (GHC.L lp' tp')
              liftT $ setEntryDPT (GHC.L lp' tp') ed
#if __GLASGOW_HASKELL__ <= 710
              let typ' = GHC.L lt (GHC.HsForAllTy ex wc bnd ctx (GHC.L lp' tp'))
#else
              -- let typ' = GHC.HsIB ivs (GHC.HsWC wcs mwc (GHC.L lt (GHC.HsForAllTy bnd (GHC.L lp' tp'))))
              let typ' = GHC.HsIB ivs (GHC.HsWC wcs mwc (GHC.L lp' tp'))
#endif
              newSig <- liftT $ if length is ==1
                then --this type signature only defines the type of pn
#if __GLASGOW_HASKELL__ <= 710
                     return [GHC.L l (GHC.SigD (GHC.TypeSig is typ' c))]
#else
                     return [GHC.L l (GHC.SigD (GHC.TypeSig is typ'))]
#endif
                else do --this type signature also defines the type of other ids.
                     let otherNames = filter (\x->rdrName2NamePure nm x/=pn) is
                         [thisName] = filter (\x->rdrName2NamePure nm x==pn) is
                     removeTrailingCommaT thisName
                     removeTrailingCommaT (last otherNames)
                     ls <- uniqueSrcSpanT
#if __GLASGOW_HASKELL__ <= 710
                     let otherSig = GHC.L l  (GHC.SigD (GHC.TypeSig otherNames typ  c))
                         thisSig  = GHC.L ls (GHC.SigD (GHC.TypeSig [thisName] typ' c))
#else
                     let otherSig = GHC.L l  (GHC.SigD (GHC.TypeSig otherNames typ))
                         thisSig  = GHC.L ls (GHC.SigD (GHC.TypeSig [thisName] typ'))
#endif
                     modifyAnnsT $ copyAnn otherSig thisSig
                     clearPriorComments thisSig
                     setEntryDPT thisSig (DP (2,0))
                     return [otherSig,thisSig]
              return newSig
         rmNthArgInSig' _nm sig = return sig

         rmNth tp = let (before,after)=splitAt nTh (unfoldHsTypApp tp)
                    in  (foldHsTypApp (before ++ tail after))

         --deconstruct a type application into a list of types
         unfoldHsTypApp :: GHC.LHsType GHC.RdrName -> [(GHC.SrcSpan,GHC.LHsType GHC.RdrName)]
         unfoldHsTypApp typ =
               case typ of (GHC.L l (GHC.HsFunTy t1 t2)) ->(l,t1):unfoldHsTypApp t2
                           _ ->[(GHC.noSrcSpan,typ)]

         --reconstruct a type application by a list of type expression.
         foldHsTypApp :: [(GHC.SrcSpan,GHC.LHsType GHC.RdrName)] -> GHC.LHsType GHC.RdrName
         foldHsTypApp [] = error "foldHsTypApp:empty list"
         foldHsTypApp ts=snd $ foldr1 (\(l1,t1) (_l2,t2)->(l1,GHC.L l1 (GHC.HsFunTy t1 t2))) ts

-- ---------------------------------------------------------------------

-- |Get the function name and the index of the parameter to be removed from the
-- cursor position.
getParam :: SimpPos -> RefactGhc (Maybe (GHC.Name,Int))
getParam pos = do
  nm <- getRefactNameMap
  parsed <- getRefactParsed
  let r = applyTU (once_tdTU (failTU `adhocTU` inMatch)) parsed
  case r of
    Nothing     -> return Nothing
    Just (ln,i) -> return $ Just (rdrName2NamePure nm ln,i)
    where
#if __GLASGOW_HASKELL__ <= 710
       inMatch ((GHC.Match (Just (fun,_)) pats _mtyp _grhs)::GHC.Match GHC.RdrName (GHC.LHsExpr GHC.RdrName))
#else
       inMatch ((GHC.Match (GHC.FunBindMatch fun _) pats _mtyp _grhs)::GHC.Match GHC.RdrName (GHC.LHsExpr GHC.RdrName))
#endif
         = case locToRdrName pos pats of
             Nothing  -> Nothing
             Just _ln -> if isNothing element
                    then error  "Invalid cursor position!"  -- cursor doesn't stop at a parameter position.
                    else Just (fun, fromJust (elemIndex (fromJust element) paramPosRanges))
               where
                 paramPosRanges = map GHC.getLoc pats
                 element = find (inRange pos) paramPosRanges
       inMatch _ = Nothing

       inRange pos' ss = pos' >= startPos && pos'<=endPos
         where (startPos,endPos) = (ss2pos ss,ss2posEnd ss)

-- ---------------------------------------------------------------------

rmParamInClientMod :: GHC.Name -> Int -> TargetModule -> RefactGhc ApplyRefacResult
rmParamInClientMod pn nTh serverModName = do
  logm $ "rmParamInClientMod:serverModName" ++ showGhc serverModName
  (r,_) <- applyRefac (rmNthArgInFunCallMod pn nTh) (RSTarget serverModName)
  return r

rmNthArgInFunCallMod :: GHC.Name -> Int -> RefactGhc ()
rmNthArgInFunCallMod pn nTh = do
  parsed <- getRefactParsed
  newNames <- equivalentNameInNewMod pn
  logm $ "rmNthArgInFunCallMod:(newNames)=" ++ showGhcQual newNames
  case newNames of
    [] -> return ()
    [_pnt] -> do
      parsed' <- rmNthArgInFunCall pn nTh parsed
      putRefactParsed parsed' emptyAnns
      return ()
    _ns   -> error "HaRe: rmParam: more than one name matches"

