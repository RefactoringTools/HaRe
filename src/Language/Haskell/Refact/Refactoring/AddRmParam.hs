{-# LANGUAGE ScopedTypeVariables #-}
module Language.Haskell.Refact.Refactoring.AddRmParam
       ( addOneParameter, compAdd
       , rmOneParameter, compRm
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
import Data.Maybe
import Data.List hiding (delete)

import Data.Generics.Strafunski.StrategyLib.StrategyLib

import Control.Exception

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
  runRefacSession settings opts (compAdd absFileName paramName (row,col))

compAdd :: FilePath -> String -> SimpPos -> RefactGhc [ApplyRefacResult]
compAdd fileName paramName (row, col) = do
  if isVarId paramName
    then
      do
        parseSourceFileGhc fileName
        renamed <- getRefactRenamed
        parsed  <- getRefactParsed
        logParsedSource "compAdd entry"
        targetModule <- getRefactTargetModule
        logm $ "AddRmParam.compAdd:got targetModule"
        let (Just (modName,_)) = getModuleName parsed
        let maybePn = locToName (row, col) renamed
        case maybePn of
          Just (GHC.L _ pn) ->
            do
              logm $ "AddRmParam.compAdd:about to applyRefac for:pn=" ++ SYB.showData SYB.Parser 0 pn
              -- make sure this name is defined in this module
              if isFunOrPatName pn renamed
               then do
                  exported <- isExported pn
                  if exported
                    then do
                     clients <- clientModsAndFiles targetModule
                     decls <- liftT $ hsDecls parsed
                     let inscopes = []
                     defaultArg <- mkTopLevelDefaultArgName pn paramName fileName modName inscopes decls
                     logm $ "compAdd:defaultArg=" ++ showGhc defaultArg
                     (refactoredMod,_) <- applyRefac (doAddingParam (error "p2") modName pn paramName (Just defaultArg) True) RSAlreadyLoaded
                     refactoredClients <- mapM (addArgInClientMod pn defaultArg) clients
                     -- let refactoredClients = []
                     return $ refactoredMod:refactoredClients
                    else do
                     logm $ "compAdd:not exported"
                     (refactoredMod,_) <- applyRefac (doAddingParam (error "p1") modName pn paramName Nothing False) (RSFile fileName)
                     return [refactoredMod]

               else error "Invalid cursor position or identifier is not a function/pattern name defined in this module!\n"
          Nothing -> error "Invalid cursor position or identifier is not a function/pattern name defined in this module!\n"
    else error $ "Invalid parameter name:" ++ paramName ++ "!"

{-
addOneParameter args
 = let fileName = args!!0
       paramName= args!!1
       row      = read (args!!2)::Int
       col      = read (args!!3)::Int
   in if isVarId paramName
      then do modName <-fileNameToModName fileName
              (inscps, exps, mod, tokList)<-parseSourceFile fileName
              let pnt@(PNT pn _ _)=locToPNT fileName  (row, col) mod
              --make sure this name is defined in this module
              if pn /= defaultPN && isFunOrPatName pn mod
               then if isExported pnt exps
                    then do clients <- clientModsAndFiles modName
                            info    <- mapM parseSourceFile $ map snd  clients
                            defaultArg <-mkTopLevelDefaultArgName pn paramName fileName modName
                                            ( map (\(x, _,_,_)->x) (concatMap inScopeInfo (map myfst info))) (hsDecls mod)
                            (mod',((ts',m), _))<-doAddingParam fileName  modName pn paramName
                                                    (Just defaultArg) True  mod tokList
                            refactoredClients<-mapM (addArgInClientMod pnt defaultArg modName) $ zip info (map snd clients)
                            writeRefactoredFiles False $ ((fileName,m),(ts',mod')):refactoredClients
                    else do (mod',((ts',m),_))<-doAddingParam fileName  modName pn paramName Nothing  False mod tokList
                            writeRefactoredFiles False [((fileName,m),(ts',mod'))]
               else error "Invalid cursor position or identifier is not a function/pattern name defined in this module!\n"
      else error "Invalid parameter name!\n"
-}

-- ---------------------------------------------------------------------

doAddingParam :: FilePath -> GHC.ModuleName -> GHC.Name -> String -> Maybe (GHC.Located GHC.RdrName) -> Bool
              -> RefactGhc ()
doAddingParam fileName modName pn newParam defaultArg isExported = do
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
                    renamed <- getRefactRenamed
                    if isExported && isExplicitlyExported pn renamed
                      then do
                           -- logm $ "doAddingParam.inMod calling addItemsToExport for:" ++ showGhc [(fromJust defaultArg)]
                           addItemsToExport modu' (Just pn) False (Left [GHC.unLoc (fromJust defaultArg)])
                      else return modu'
                else mzero

             --2. pn is declared locally in the where clause of a match.
             inMatch (match@(GHC.L l (GHC.Match mf pats typ (GHC.GRHSs rhs ds)))::GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))
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
             inLet (letExp@(GHC.L l (GHC.HsLet ds e)) :: GHC.LHsExpr GHC.RdrName)
               -- | definingDecls [pn] ds False False /=[] = doAdding letExp  ds
               = do
                   nm <- getRefactNameMap
                   decls <- liftT $ hsDecls letExp
                   logm $ "doAddingParam.inLet:decls=" ++ showGhc decls
                   if not ( null (definingDeclsRdrNames nm [pn] decls False False))
                      then doAdding letExp decls
                      else mzero
             inLet (doStmt@(GHC.L l (GHC.HsDo ctx stmts ptt)) :: GHC.LHsExpr GHC.RdrName)
               = do
                   nm <- getRefactNameMap
                   logm $ "doAddingParam.inHsDo:stmts=" ++ showGhc stmts
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
                           return (GHC.L l (GHC.HsDo ctx stmts2 ptt))
                      else mzero
             inLet _ = mzero

{-
             --5. pn is declared locally in a  case alternative.
             inAlt (alt@(HsAlt loc p rhs ds)::HsAltP)
               | definingDecls [pn] ds False  False/=[] = doAdding  alt  ds
             inAlt _ = mzero
-}

             --6.pn is declared locally in a let statement.
             inLetStmt (letStmt@(GHC.L l (GHC.LetStmt stmts)):: GHC.ExprLStmt GHC.RdrName)
               = do
                   nm <- getRefactNameMap
                   decls <- liftT $ hsDecls letStmt
                   logm $ "doAddingParam.inLetStmt.let:decls=" ++ showGhc decls
                   if not ( null (definingDeclsRdrNames nm [pn] decls False False))
                      then do
                        -- logm $ "doAddingParam.inLetStmt:True leg"
                        letStmt' <- doAdding letStmt decls
                        return letStmt'
                      else mzero
             inLetStmt bindStmt@(GHC.L l (GHC.BindStmt pats (GHC.L lv (GHC.HsVar v)) _s1 _s2))
               = do
                   nm <- getRefactNameMap
                   logm $ "doAddingParam.inLetStmt.bind:"
                   -- if not ( null (definingDeclsRdrNames nm [pn] decls False False))
                   if True
                      then do
                        -- logm $ "doAddingParam.inLetStmt:True leg"
                        -- bindStmt' <- doAdding bindStmt decls
                        let bindStmt' = bindStmt
                        return bindStmt'
                      else mzero
             inLetStmt _ = mzero

             failure = idTP `adhocTP` modu
               where modu (m::GHC.ParsedSource) = error "Refactoring failed"


             doAdding :: (HasDecls t) => t -> [GHC.LHsDecl GHC.RdrName] -> RefactGhc t
             doAdding parent ds = do
               logDataWithAnns "doAdding:parent:" parent
               logDataWithAnns "doAdding:ds:" ds
               nm <- getRefactNameMap
               if paramNameOk nm pn newParam ds
                   then do
                       logm $ "doAddingParam.doAdding: True leg of paramNameOk:newParam=" ++ showGhc (mkRdrName newParam)
                       ds' <- addParamsToDecls ds pn [mkRdrName newParam] --addFormalParam pn newParam ds
                       defaultParamPName <-if isNothing defaultArg
                                           then mkLocalDefaultArgName pn newParam modName parent
                                           else return (gfromJust "doAdding" defaultArg)
                       logm $ "doAddingParam.doAdding: defaultParamPName=" ++ showGhc defaultParamPName
                       parent1 <- liftT $ replaceDecls parent ds'
                       parent' <- addDefaultActualArg False pn defaultParamPName parent1
                       -- parent' <- addDefaultActualArg True pn defaultParamPName parent1
                       parent''<- addDefaultActualArgDecl defaultParamPName parent' pn isExported
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
                       logm $ "doAddingParam.doAddingStmts: True leg of paramNameOk:newParam=" ++ showGhc (mkRdrName newParam)
                       defaultParamPName <-if isNothing defaultArg
                                           then mkLocalDefaultArgName pn newParam modName stmts
                                           else return (gfromJust "doAddingStmts" defaultArg)
                       logm $ "doAddingParam.doAddingStmts: defaultParamPName=" ++ showGhc defaultParamPName
                       stmts' <- addDefaultActualArg False pn defaultParamPName stmts
                       -- ds'' <- addArgToSig pn ds2
                       return stmts'
                   else error " Refactoring failed."

-- ---------------------------------------------------------------------
{-
doAddingParam fileName modName pn newParam defaultArg isExported mod tokList
    =  runStateT (applyTP (once_tdTP (failTP `adhocTP` inMod
                                             `adhocTP` inMatch
                                             `adhocTP` inPat
                                             `adhocTP` inLet
                                             `adhocTP` inAlt
                                             `adhocTP` inLetStmt)
                           `choiceTP` failure) mod) ((tokList,unmodified),(-1000,0))
      where
             --1.pn is declared in top level
             inMod (mod@(HsModule loc name exps imps ds):: HsModuleP)
               | definingDecls [pn] ds False  False/=[]
               = do mod'<-doAdding mod  ds
                    if isExported && isExplicitlyExported pn mod
                      then addItemsToExport mod' (Just pn) False (Left [pNtoName (fromJust defaultArg)])
                      else return mod'

             inMod _ = mzero

             --2. pn is declared locally in the where clause of a match.
             inMatch (match@(HsMatch loc1 name pats rhs ds)::HsMatchP)
               | definingDecls [pn] ds False  False/=[]  = doAdding match  ds
             inMatch _ = mzero

             --3. pn is declared locally in the where clause of a pattern binding.
             inPat (pat@(Dec (HsPatBind loc p rhs ds))::HsDeclP)
               | definingDecls [pn] ds False  False/=[]  = doAdding pat  ds
             inPat _ = mzero

             --4: pn is declared locally in a  Let expression
             inLet (letExp@(Exp (HsLet ds e))::HsExpP)
               | definingDecls [pn] ds False False /=[] = doAdding letExp  ds
             inLet _ = mzero

             --5. pn is declared locally in a  case alternative.
             inAlt (alt@(HsAlt loc p rhs ds)::HsAltP)
               | definingDecls [pn] ds False  False/=[] = doAdding  alt  ds
             inAlt _ = mzero

             --6.pn is declared locally in a let statement.
             inLetStmt (letStmt@(HsLetStmt ds stmts):: HsStmtP)
               | definingDecls [pn] ds False  False/=[]  = doAdding letStmt ds
             inLetStmt _ = mzero

             failure = idTP `adhocTP` mod
               where mod (m::HsModuleP) = error "Refactoring failed"

             doAdding parent ds
               = if paramNameOk nm pn newParam ds
                   then
                    do ds' <- addParamsToDecls ds pn [nameToPN newParam] True  --addFormalParam pn newParam ds
                       defaultParamPName <-if isNothing defaultArg
                                           then mkLocalDefaultArgName pn newParam modName parent
                                           else return (fromJust defaultArg)
                       parent' <- addDefaultActualArg False pn defaultParamPName (replaceDecls parent ds')
                       parent''<- addDefaultActualArgDecl defaultParamPName  parent' pn isExported
                       ds'' <- addArgToSig pn (hsDecls parent'')
                       return (replaceDecls parent'' ds'')
                   else error " Refactoring failed."
-}

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

   -- bind ((Dec (HsFunBind _ matches@((HsMatch _ fun pats rhs ds):ms)))::HsDeclP)
   bind :: GHC.LHsBind GHC.RdrName -> Maybe Bool
   bind (GHC.L l (GHC.FunBind n i (GHC.MG matches a ptt o) co fvs t))
    | rdrName2NamePure nm n == pn
    = do results' <- mapM checkInMatch matches
         Just (all (==True) results')
   -- bind pat@(Dec (HsPatBind loc p rhs ds))
   bind (GHC.L _ (GHC.PatBind _pat _rhs _ty _fvs _t))
      = error "Parameter can not be added to complex pattern binding"
   bind _ = mzero

   checkInMatch match
     = do let (f,d) = hsFDNamesFromInsideRdrPure nm match
          if elem newParam (f `union` d)
           then error "The new parameter name will cause name clash or semantics change, please choose another name!"
           else return True

{-

-- check whether the new parameter is a legal.

paramNameOk pn newParam t = (fromMaybe True) (applyTU (once_tdTU (failTU `adhocTU` decl)) t)
  where
   decl ((Dec (HsFunBind _ matches@((HsMatch _ fun pats rhs ds):ms)))::HsDeclP)
    | pNTtoPN fun == pn
    = do results'<-mapM checkInMatch matches
         Just (all (==True) results')
   decl pat@(Dec (HsPatBind loc p rhs ds))
    | patToPN p == pn
    = do (f,d) <- hsFDNamesFromInside pat
         if elem newParam (f `union` d)
            then  error "The new parameter name will cause name clash or semantics change, please select another name!"
            else Just True
   decl (Dec (HsPatBind _ p _ _))
     | patToPN p /= pn && elem pn (hsPNs p)
      = error "Parameter can not be added to complex pattern binding"
   decl _=mzero

   checkInMatch match
     = do (f,d) <- hsFDNamesFromInside match
          if elem newParam (f `union` d)
           then error "The new parameter name will cause name clash or semantics change, please choose another name!"
           else return True
-}
-- ---------------------------------------------------------------------

-- |add the default argument declaration right after the declaration defining pn
addDefaultActualArgDecl :: (SYB.Data t) => GHC.Located GHC.RdrName -> t -> GHC.Name -> Bool -> RefactGhc t
addDefaultActualArgDecl defaultParamPName parent pn isExported = do
  defaultArgDecl <- parseDeclWithAnns ((showGhc defaultParamPName) ++ " = undefined")
  nm <- getRefactNameMap
  let inParent = findLRdrName nm pn parent
  if not inParent && not isExported
    then return parent
    else addDecl parent (Just pn) ([defaultArgDecl],Nothing)
{-
--add the default argument declaration right after the declaration defining pn
addDefaultActualArgDecl defaultParamPName parent pn isExported
   =if not (findEntity pn parent) && not isExported
      then return parent
      else addDecl parent (Just pn) (defaultArgDecl,Nothing) True
   where
      defaultArgDecl= [Dec (HsPatBind loc0 (nameToPat (pNtoName defaultParamPName))(HsBody (nameToExp "undefined"))[])]

-}
-- ---------------------------------------------------------------------

-- |suppose function name is f, parameter name is p, then the default argument
-- name is like f_p.
mkLocalDefaultArgName :: (SYB.Data t)
                      => GHC.Name -> String -> c -> t -> RefactGhc (GHC.Located GHC.RdrName)
mkLocalDefaultArgName fun paramName modName t = do
  logm $ "mkLocalDefaultArgName"
  (f,d) <- hsFDNamesFromInsideRdr t
  vs <- hsVisibleNamesRdr fun t -- ++AZ++ TODO : FindEntity on fun will fail in a RdrName AST
  let name = mkNewName ((showGhc fun)++"_"++paramName) (nub (f `union` d `union` vs)) 0
  loc <- liftT $ uniqueSrcSpanT
  let vn = (GHC.L loc (mkRdrName name))
  liftT $ addSimpleAnnT vn (DP (0,1)) [((G GHC.AnnVal),DP (0,0))]
  return vn
  -- return (PN (UnQual name) (S loc0))
{-
--suppose function name is f, parameter name is p, then the default argument name is like f_p.
mkLocalDefaultArgName fun paramName modName t
 =do (f,d)<-hsFDNamesFromInside t
     vs<-hsVisibleNames fun t
     let name=mkNewName ((pNtoName fun)++"_"++paramName) (nub (f `union` d `union` vs)) 0
     return (PN (UnQual name) (S loc0))

-}
-- ---------------------------------------------------------------------

mkTopLevelDefaultArgName :: (SYB.Data t,GHC.Outputable a)
                         => a -> String -> c
                         -> GHC.ModuleName
                         -> [String] -> t
                         -> RefactGhc (GHC.Located GHC.RdrName)
mkTopLevelDefaultArgName fun paramName fileName modName inscopeNames t = do
  logm $ "mkTopLevelDefaultArgName entered"
  nm <- getRefactNameMap
  (f,d) <- hsFDNamesFromInsideRdr t
  let name = mkNewName ((showGhc fun)++"_"++paramName) (nub (f `union` d `union` inscopeNames)) 0
  loc <- liftT $ uniqueSrcSpanT
  logm $ "mkTopLevelDefaultArgName:loc=" ++ showGhc loc
  logm $ "mkTopLevelDefaultArgName:modName=" ++ showGhc modName
  logm $ "mkTopLevelDefaultArgName:name=" ++ showGhc name
  -- let vn = (GHC.L loc (mkQualifiedRdrName modName name))
  let vn = (GHC.L loc (mkRdrName name))
  liftT $ addSimpleAnnT vn (DP (0,1)) [((G GHC.AnnVal),DP (0,0))]
  logm $ "mkTopLevelDefaultArgName:vn=" ++ showGhc vn
  return vn
  -- return (PN (UnQual name) (G modName name (N (Just loc))))

{-
mkTopLevelDefaultArgName fun paramName fileName modName inscopeNames t
 =do (f,d)<-hsFDNamesFromInside t
     let name=mkNewName ((pNtoName fun)++"_"++paramName) (nub (f `union` d `union` inscopeNames)) 0
     let loc =  SrcLoc fileName 0 (-1000) (-1000)
     return (PN (UnQual name) (G modName name (N (Just loc))))

-}
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
         inDecl nm fun@(GHC.L l (GHC.ValD (GHC.FunBind n i (GHC.MG matches a ptt o) co fvs t)))
           | rdrName2NamePure nm n == pn
           = return fun -- Stop the recursion by not returning mzero

         -- inDecl (pat@(Dec (HsPatBind loc1 ps rhs ds))::HsDeclP)
         --   | pn == patToPN  ps
         --   = return pat
         inDecl _ _ = mzero

         funApp :: NameMap -> GHC.LHsExpr GHC.RdrName -> RefactGhc (GHC.LHsExpr GHC.RdrName)
         funApp nm (expr@(GHC.L l (GHC.HsVar n))::GHC.LHsExpr GHC.RdrName)
          | rdrName2NamePure nm (GHC.L l n) == pn = do
            logm $ "addDefaultActualArg.funApp:expr=" ++ showGhc expr
            addParamToExp expr (GHC.unLoc argPName)

         funApp _ _ = mzero


{-

addDefaultActualArg recursion pn argPName
        = if recursion then applyTP (stop_tdTP (failTP `adhocTP` funApp))
                       else applyTP (stop_tdTP (failTP `adhocTP` inDecl
                                                       `adhocTP` funApp))
       where
         inDecl (fun@(Dec (HsFunBind _  ((HsMatch _ (PNT pname _ _) _ _ _):ms)))::HsDeclP)
           | pn == pname
           = return fun

         inDecl (pat@(Dec (HsPatBind loc1 ps rhs ds))::HsDeclP)
           | pn == patToPN  ps
           = return pat
         inDecl _ = mzero

         funApp (exp@(Exp (HsId (HsVar (PNT pname _ _))))::HsExpP)
          |pname==pn
           = update exp (Exp (HsParen (Exp (HsApp exp (pNtoExp argPName))))) exp

         funApp _ = mzero

-}
-- ---------------------------------------------------------------------

-- | Add a parameter to a 'GHC.HsVar' expression
addParamToExp :: GHC.LHsExpr GHC.RdrName -> GHC.RdrName
              -> RefactGhc (GHC.LHsExpr GHC.RdrName)
addParamToExp (expr@(GHC.L l (GHC.HsVar n))) argPName = do
  nm <- getRefactNameMap
  lp <- liftT uniqueSrcSpanT
  la <- liftT uniqueSrcSpanT
  lv <- liftT uniqueSrcSpanT
  let e2 = GHC.L lv (GHC.HsVar argPName)
  let ret = GHC.L lp (GHC.HsPar (GHC.L la (GHC.HsApp expr e2)))
  liftT $ addSimpleAnnT e2  (DP (0,1)) [((G GHC.AnnVal),DP (0,0))]
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
       -- addArgToSig' sig@[(GHC.L l (GHC.SigD s@(GHC.TypeSig is tp pr)))] = do
        -- (GHC.L _ s') <- addParamsToSigs [pn] (GHC.L l s)
        -- return [GHC.L l (GHC.SigD s')]
       addArgToSig' :: [GHC.LHsDecl GHC.RdrName] -> RefactGhc [GHC.LHsDecl GHC.RdrName]
       addArgToSig' sig@[(GHC.L l (GHC.SigD (GHC.TypeSig is tp pr)))] = do
              nm <- getRefactNameMap
              let tVar = mkNewTypeVarName sig
              typeVar <- newTypeVar tVar tp
              let newSig=if length is==1
                           then  --the type sig only defines the type for pn
                                [GHC.L l (GHC.SigD (GHC.TypeSig is typeVar pr))]
                           else  --otherwise, seperate it into two type signatures.
                               [GHC.L l (GHC.SigD (GHC.TypeSig (filter (\x->rdrName2NamePure nm x/=pn) is) tp pr)),
                                GHC.L l (GHC.SigD (GHC.TypeSig (filter (\x->rdrName2NamePure nm x==pn) is) typeVar pr))]
              return newSig

       -- compose a type application using type expressions tv and tp
       newTypeVar :: String -> GHC.LHsType GHC.RdrName -> RefactGhc (GHC.LHsType GHC.RdrName)
       newTypeVar tVar tp = do
         ls <- liftT $ uniqueSrcSpanT
         lv <- liftT $ uniqueSrcSpanT
         let tv = GHC.L lv (GHC.HsTyVar (mkRdrName tVar))
         let typ = GHC.L ls (GHC.HsFunTy tv tp)
         liftT $ addSimpleAnnT tv  (DP (0,0)) [((G GHC.AnnVal),DP (0,0))]
         liftT $ addSimpleAnnT typ (DP (0,1)) [((G GHC.AnnRarrow),DP (0,1))]
         return typ
         -- = error $ "addArgToSig.newTypeVar:(tVar,tp)=" ++ SYB.showData SYB.Parser 0 (tVar,tp)
         -- =(Typ (HsTyFun (Typ (HsTyVar (PNT (PN (UnQual tVar) (S loc0))
         --   (Type (TypeInfo {defType=Nothing, constructors=[], fields=[]})) (N (Just loc0))))) tp))

        -- make a fresh type variable name. the new name is the first letter in the alphabet which is not
        --   used in the type signature.
       mkNewTypeVarName :: [GHC.LHsDecl GHC.RdrName] -> String
       mkNewTypeVarName sig
          =mkNewName "a" $ map showGhc $ (snd.hsTypeVbls) sig
             where mkNewName initName v
                     =if elem initName v
                         then mkNewName ((intToDigit (digitToInt(head initName)+1)):tail initName) v
                         else initName

{-
--Add type arg to type siginature
addArgToSig pn decls
   = let (before,after)=break (\d ->definesTypeSig pn d) decls
     in if  after==[]
       then  return decls
       else  do newSig<-addArgToSig' [(head after)]  --no problem with head.
                return (before++newSig++(tail after))

    where
       addArgToSig' sig@[(Dec (HsTypeSig loc is c tp))]
          =do let tVar=mkNewTypeVarName sig
                  typeVar=newTypeVar tVar tp
              let newSig=if length is==1
                           then  --the type sig only defines the type for pn
                                [Dec (HsTypeSig loc is c typeVar)]
                           else  --otherwise, seperate it into two type signatures.
                               [Dec (HsTypeSig loc (filter (\x->pNTtoPN x/=pn) is) c tp),
                                Dec (HsTypeSig loc (filter (\x->pNTtoPN x==pn) is) c typeVar)]
              update sig newSig sig

       --compose a type application using type expressions tv and tp
       newTypeVar tVar tp
         =(Typ (HsTyFun (Typ (HsTyVar (PNT (PN (UnQual tVar) (S loc0))
           (Type (TypeInfo {defType=Nothing, constructors=[], fields=[]})) (N (Just loc0))))) tp))

       {- make a fresh type variable name. the new name is the first letter in the alphabet which is not
          used in the type signature. -}
       mkNewTypeVarName sig
          =mkNewName "a" $ map pNtoName $ (snd.hsTypeVbls) sig
             where mkNewName initName v
                     =if elem initName v
                         then mkNewName ((intToDigit (digitToInt(head initName)+1)):tail initName) v
                         else initName
-}
-- ---------------------------------------------------------------------

addArgInClientMod :: GHC.Name -> GHC.Located GHC.RdrName -> TargetModule -> RefactGhc ApplyRefacResult
addArgInClientMod pnt defaultArg serverModName = do
  (r,_) <- applyRefac (addArgInClientMod' pnt defaultArg (GM.mpModule serverModName)) (RSTarget serverModName)
  return r


addArgInClientMod' :: GHC.Name -> GHC.Located GHC.RdrName -> GHC.ModuleName -> RefactGhc ()
addArgInClientMod' pnt defaultArg serverModName = do
   logm $ "addArgInClientMod':defaultArg=" ++ showGhc defaultArg
   parsed <- getRefactParsed
   let pn = pnt
   qual <- hsQualifier pnt
   logm $ "addArgInClientMod':qual=" ++ showGhc qual
   if qual == []
          then return ()
          else do
            mod'  <- addItemsToImport serverModName  (Just pn) (Left [GHC.unLoc defaultArg]) parsed
            mod'' <- addItemsToExport parsed (Just pn) False (Left [GHC.unLoc defaultArg])
            isInScopeAndUnqual <- isInScopeAndUnqualifiedGhc (showGhc pnt) Nothing
            logm $ "addArgInClientMod':isInScopeAndUnqual=" ++ show isInScopeAndUnqual
            mod3 <- if isInScopeAndUnqual
               then addDefaultActualArgInClientMod  pn  (head qual) defaultArg False mod''
               else addDefaultActualArgInClientMod  pn  (head qual) defaultArg True  mod''
            putRefactParsed mod3 emptyAnns
            return ()


{-
addArgInClientMod pnt defaultArg  serverModName ((inscps, exps, mod,ts), fileName)
 = let qual = hsQualifier pnt inscps
       pn = pNTtoPN pnt
   in if qual == []
          then return ((fileName,unmodified), (ts,mod))
          else do (mod',((ts',m), _))<-
                      runStateT (do mod'<-addItemsToImport serverModName  (Just pn) (Left [pNtoName defaultArg]) mod
                                    mod''<-addItemsToExport mod (Just pn) False (Left [pNtoName defaultArg])
                                    if isInScopeAndUnqualified (pNtoName pn) inscps
                                       then addDefaultActualArgInClientMod  pn  (head qual) defaultArg False mod''
                                       else addDefaultActualArgInClientMod  pn  (head qual) defaultArg True  mod'')
                          ((ts,unmodified), (-1000,0))
                  return ((fileName,m),(ts',mod'))

-}
-- ---------------------------------------------------------------------

--add default actual argument to pn in all the calling places.
addDefaultActualArgInClientMod :: (SYB.Data t) => GHC.Name -> GHC.ModuleName -> GHC.Located GHC.RdrName -> Bool -> t -> RefactGhc t
addDefaultActualArgInClientMod pn qual argPName toBeQualified t = do
  logm $ "addDefaultActualArgInClientMod entered:argPName=" ++ showGhc argPName
  nm <- getRefactNameMap
  r <- applyTP (stop_tdTP (failTP `adhocTP` (funApp nm))) t
  -- logDataWithAnns "addDefaultActualArgInClientMod" r
  return r
  where
    -- funApp (exp@(Exp (HsId (HsVar pnt@(PNT pname _ _))))::HsExpP)
    funApp nm (expr@((GHC.L l (GHC.HsVar pname )))::GHC.LHsExpr GHC.RdrName)
      | GHC.nameUnique (rdrName2NamePure nm (GHC.L l pname)) == GHC.nameUnique pn
       = do
            logm $ "addDefaultActualArgInClientMod:hit"
            vs <- hsVisibleNamesRdr (GHC.L l pname) t
            let argExp = GHC.unLoc argPName
            -- let argExp=if toBeQualified || elem (pNtoName argPName) vs
            --              then pNtoExp (qualifyPName qual argPName)
            --              else pNtoExp argPName
            addParamToExp expr argExp
{-
            ss1 <- liftT uniqueSrcSpanT
            ss2 <- liftT uniqueSrcSpanT
            ss3 <- liftT uniqueSrcSpanT
            let argExp = GHC.L ss3 (GHC.HsVar (GHC.unLoc argPName))
            -- let argExp=if toBeQualified || elem (pNtoName argPName) vs
            --              then pNtoExp (qualifyPName qual argPName)
            --              else pNtoExp argPName
                newExp = (GHC.L ss1 (GHC.HsPar (GHC.L ss2 (GHC.HsApp exp argExp))))
            liftT $ addSimpleAnnT argExp (DP (0,1)) [((G GHC.AnnVal),DP (0,0))]
            liftT $ addSimpleAnnT newExp (DP (0,0)) [((G GHC.AnnOpenP),DP (0,0)),((G GHC.AnnCloseP),DP (0,0))]
            liftT $ transferEntryDPT exp newExp
            liftT $ setEntryDPT exp (DP (0,0))
            return newExp
-}
    funApp _ _ = mzero

myfst (a,_,_,_) = a

{-

--add default actual argument to pn in all the calling places.
addDefaultActualArgInClientMod pn qual argPName toBeQualified t
   = applyTP (stop_tdTP (failTP `adhocTP` funApp)) t
  where
    funApp (exp@(Exp (HsId (HsVar pnt@(PNT pname _ _))))::HsExpP)
      | pname == pn
       = do vs <- hsVisibleNames pnt t
            let argExp=if toBeQualified || elem (pNtoName argPName) vs
                         then pNtoExp (qualifyPName qual argPName)
                         else pNtoExp argPName
                newExp =(Exp (HsParen (Exp (HsApp exp argExp))))
            update exp newExp exp
    funApp _=mzero

myfst (a,_,_,_) = a
-}
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
  runRefacSession settings opts (compRm absFileName (row,col))

compRm :: FilePath -> SimpPos -> RefactGhc [ApplyRefacResult]
compRm fileName (row, col) = do
  parseSourceFileGhc fileName
  logParsedSource "compRm entry"
  -- pn is the function names.
  -- nth is the nth paramter of pn is to be removed,index starts form 0.
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

{-
  --pn is the function names.
  --nth is the nth paramter of pn is to be removed,index starts form 0.
  let (pnt,nth)=getParam tokList (row,col) mod
      pn=pNTtoPN pnt
  if pn/=defaultPN
    then do (mod',((ts',m), _))<-doRmParam pn nth mod fileName tokList
            if isExported pnt exps
             then do modName <- RefacUtils.fileNameToModName fileName
                     clients<-clientModsAndFiles modName
                     refactoredClients<-mapM (rmParamInClientMod pnt nth) clients
                     writeRefactoredFiles False $ ((fileName,m),(ts',mod')):refactoredClients
             else  writeRefactoredFiles  False [((fileName,m), (ts',mod'))]
    else error "Invalid cursor position!"
-}


{-
rmOneParameter args
 =do let fileName=args!!0
         row=read (args!!1)::Int
         col=read (args!!2)::Int
     (inscps, exps, mod, tokList)<-parseSourceFile fileName
     --pn is the function names.
     --nth is the nth paramter of pn is to be removed,index starts form 0.
     let (pnt,nth)=getParam tokList (row,col) mod
         pn=pNTtoPN pnt
     if pn/=defaultPN
       then do (mod',((ts',m), _))<-doRmParam pn nth mod fileName tokList
               if isExported pnt exps
                then do modName <- RefacUtils.fileNameToModName fileName
                        clients<-clientModsAndFiles modName
                        refactoredClients<-mapM (rmParamInClientMod pnt nth) clients
                        writeRefactoredFiles False $ ((fileName,m),(ts',mod')):refactoredClients
                else  writeRefactoredFiles  False [((fileName,m), (ts',mod'))]
       else error "Invalid cursor position!"
-}

-- ---------------------------------------------------------------------

--pn: function name; nth: the index of the parameter to be removed.
doRmParam :: GHC.Name -> Int -> RefactGhc ()
doRmParam pn nth = do
    logm $ "doRmParam entered:(pn,nth)=" ++ showGhc (pn,nth)
    parsed <- getRefactParsed
    r <- applyTP ((once_tdTP (failTP `adhocTP` inMod
                                     -- `adhocTP` inMatch
                                     -- `adhocTP` inPat
                                     -- `adhocTP` inLet
                                     -- `adhocTP` inAlt
                                     -- `adhocTP` inLetStmt
                             ))
                  `choiceTP` failure) parsed
    putRefactParsed r emptyAnns
    return ()
      where
             --1. pn is declared in top level.
             inMod :: GHC.ParsedSource -> RefactGhc GHC.ParsedSource
             inMod modu = do
               nm <- getRefactNameMap
               decls <- liftT $ hsDecls modu
               if not ( null (definingDeclsRdrNames nm [pn] decls False False))
                  then do doRemoving modu decls
                  else mzero
                -- |definingDecls [pn] ds False  False/=[] = doRemoving mod  ds
             inMod _ =mzero

             -- --2. pn is declared locally in the where clause of a match.
             -- inMatch (match@(HsMatch loc1 name pats rhs ds)::HsMatchP)
             --     |definingDecls [pn] ds False False /=[] = doRemoving match  ds
             -- inMatch _ =mzero

             -- --3. pn is declared locally in the where clause of a pattern binding.
             -- inPat (pat@(Dec (HsPatBind loc p rhs ds))::HsDeclP)
             --    | definingDecls [pn] ds False  False/=[]  = doRemoving pat  ds
             -- inPat _=mzero

             -- --4: pn is declared locally in a  Let expression
             -- inLet (letExp@(Exp (HsLet ds e))::HsExpP)
             --   | definingDecls [pn] ds False  False/=[] = doRemoving letExp  ds
             -- inLet _=mzero

             -- --5. pn is declared locally in a  case alternative.
             -- inAlt (alt@(HsAlt loc p rhs ds)::HsAltP)
             --    | definingDecls [pn] ds False  False/=[]  = doRemoving  alt  ds
             -- inAlt _=mzero

             -- --6.pn is declared locally in a let statement.
             -- inLetStmt (letStmt@(HsLetStmt ds stmts):: HsStmtP)
             --    | definingDecls [pn] ds False  False/=[]  = doRemoving letStmt ds
             -- inLetStmt _=mzero

             failure = idTP `adhocTP` modu
               where modu (m::GHC.ParsedSource) = error "Refactoring failed"


             doRemoving :: (HasDecls t) => t -> [GHC.LHsDecl GHC.RdrName] -> RefactGhc t
             doRemoving parent ds  --PROBLEM: How about doRemoving fails?
                =do rmFormalArg pn nth False True =<< rmNthArgInFunCall pn nth False ds
                    ds' <- rmNthArgInSig pn nth   =<< rmFormalArg pn nth True False  ds
                    ds'' <- liftT $ replaceDecls parent ds'
                    rmNthArgInFunCall pn nth True ds''

             -- just remove the nth formal parameter.
             rmFormalArg :: (SYB.Data t) => GHC.Name -> Int -> Bool -> Bool -> t -> RefactGhc t
             rmFormalArg pn nth updateToks checking t = do
               nm <- getRefactNameMap
               applyTP (stop_tdTP (failTP `adhocTP` (rmInMatch nm))) t

               where
                 -- a formal parameter only exists in a match
                 rmInMatch nm (match@(GHC.L l (GHC.Match (Just (fun,b)) pats typ (GHC.GRHSs rhs decls)))::GHC.LMatch GHC.RdrName (GHC.LHsExpr GHC.RdrName))
                   | rdrName2NamePure nm fun == pn =
                       let  pat = pats!!nth     --get the nth formal parameter
                            pats' = take nth pats ++ drop (nth + 1) pats
                            -- pNames = hsPNs pat  --get all the names in this pat. (the pat may be just be a variable)
                            pNames = map (rdrName2NamePure nm) $ hsNamessRdr pat  --get all the names in this pat. (the pat may be just be a variable)
                       in if checking && not ( all (==False) ((map (flip (findNameInRdr nm) rhs) pNames)) && --not used in rhs
                                               all (==False) ((map (flip (findNameInRdr nm) decls) pNames))) --not used in the where clause
                            then error  "This parameter can not be removed, as it is used!"
                            else return (GHC.L l (GHC.Match (Just (fun,b)) pats' typ (GHC.GRHSs rhs decls)))
                 rmInMatch _ _ = mzero
                 -- rmInMatch (match@(HsMatch loc  fun  pats rhs decls)::HsMatchP) --a formal parameter only exists in a match
                 --   |pNTtoPN fun==pn
                 --   =let  pat=pats!!nth   --get the nth formal parameter
                 --         pNames=hsPNs pat  --get all the names in this pat. (the pat may be just be a variable)
                 --    in if checking && not ( all (==False) ((map (flip findPN rhs) pNames)) && --not used in rhs
                 --                            all (==False) ((map (flip findPN decls) pNames))) --not used in the where clause
                 --         then error  "This parameter can not be removed, as it is used!"
                 --         else if updateToks
                 --                then  do  pats'<-delete pat pats
                 --                          return (HsMatch loc fun pats' rhs decls)
                 --                else return (HsMatch loc fun (pats\\[pat]) rhs decls)
                 -- rmInMatch _=mzero
{-
--pn: function name; nth: the index of the parameter to be removed.
doRmParam pn nth mod fileName tokList
       =runStateT (applyTP ((once_tdTP (failTP `adhocTP` inMod
                                              `adhocTP` inMatch
                                              `adhocTP` inPat
                                              `adhocTP` inLet
                                              `adhocTP` inAlt
                                              `adhocTP` inLetStmt)) `choiceTP` failure) mod)
                                           ((tokList,unmodified),(-1000,0))
      where
             --1. pn is declared in top level.
             inMod (mod@(HsModule loc name exps imps ds):: HsModuleP)
                |definingDecls [pn] ds False  False/=[] = doRemoving mod  ds
             inMod _ =mzero

             --2. pn is declared locally in the where clause of a match.
             inMatch (match@(HsMatch loc1 name pats rhs ds)::HsMatchP)
                 |definingDecls [pn] ds False False /=[] = doRemoving match  ds
             inMatch _ =mzero

             --3. pn is declared locally in the where clause of a pattern binding.
             inPat (pat@(Dec (HsPatBind loc p rhs ds))::HsDeclP)
                | definingDecls [pn] ds False  False/=[]  = doRemoving pat  ds
             inPat _=mzero

             --4: pn is declared locally in a  Let expression
             inLet (letExp@(Exp (HsLet ds e))::HsExpP)
               | definingDecls [pn] ds False  False/=[] = doRemoving letExp  ds
             inLet _=mzero

             --5. pn is declared locally in a  case alternative.
             inAlt (alt@(HsAlt loc p rhs ds)::HsAltP)
                | definingDecls [pn] ds False  False/=[]  = doRemoving  alt  ds
             inAlt _=mzero

             --6.pn is declared locally in a let statement.
             inLetStmt (letStmt@(HsLetStmt ds stmts):: HsStmtP)
                | definingDecls [pn] ds False  False/=[]  = doRemoving letStmt ds
             inLetStmt _=mzero

             failure=idTP `adhocTP` mod
                     where mod (m::HsModuleP)=error "Refactoring failed"

             doRemoving parent  ds  --PROBLEM: How about doRemoving fails?
                =do rmFormalArg pn nth False True =<<rmNthArgInFunCall pn nth False ds
                    ds'<-rmNthArgInSig pn nth =<<rmFormalArg pn nth True False  ds
                    rmNthArgInFunCall pn nth True (replaceDecls parent ds')

             -- just remove the nth formal parameter.
             rmFormalArg pn nth updateToks checking
                =applyTP (stop_tdTP (failTP `adhocTP` rmInMatch))

               where
                 rmInMatch (match@(HsMatch loc  fun  pats rhs decls)::HsMatchP) --a formal parameter only exists in a match
                   |pNTtoPN fun==pn
                   =let  pat=pats!!nth   --get the nth formal parameter
                         pNames=hsPNs pat  --get all the names in this pat. (the pat may be just be a variable)
                    in if checking && not ( all (==False) ((map (flip findPN rhs) pNames)) && --not used in rhs
                                            all (==False) ((map (flip findPN decls) pNames))) --not used in the where clause
                         then error  "This parameter can not be removed, as it is used!"
                         else if updateToks
                                then  do  pats'<-delete pat pats
                                          return (HsMatch loc fun pats' rhs decls)
                                else return (HsMatch loc fun (pats\\[pat]) rhs decls)
                 rmInMatch _=mzero
-}

-- ---------------------------------------------------------------------

-- |Remove the nth argument of function pn in all the calling places. The index
-- for the first argument is zero.
rmNthArgInFunCall :: (SYB.Data t) => GHC.Name -> Int -> Bool -> t -> RefactGhc t
rmNthArgInFunCall pn nth updateToks t = do
  nm <- getRefactNameMap
  applyTP (stop_tdTP (failTP `adhocTP` (funApp nm))) t
   where
         funApp nm (exp@(GHC.L _ (GHC.HsPar (GHC.L l (GHC.HsApp e1 e2))))::GHC.LHsExpr GHC.RdrName)
              | nth == 0 && Just pn == expToNameRdr nm e1
             = return e1 -- handle the case like '(fun x) => fun "
         funApp nm (exp@(GHC.L _ (GHC.HsApp e1 e2))::GHC.LHsExpr GHC.RdrName)
                --test if this application is a calling of fun pn.
              | Just pn == (expToNameRdr nm.snd.(ghead "rmNthArgInFunCall").unfoldHsApp) exp
               =do
                  logDataWithAnns "rmNthArgInFunCall:(exp)=" exp
                  logDataWithAnns "rmNthArgInFunCall:(unfoldHsApp exp)=" (unfoldHsApp exp)
                  let (before,after)=splitAt (nth+1) (unfoldHsApp exp)   --remove the nth argument
                  logDataWithAnns "rmNthArgInFunCall:(foldHsApp (before++tail after))=" (foldHsApp (before++tail after))
                  return (foldHsApp (before++tail after))  --reconstruct the function application.

         funApp _ _ = mzero

         -- |deconstruct a function application into a list of expressions.
         -- TODO:AZ include the location, for reconstruction
         unfoldHsApp :: GHC.LHsExpr GHC.RdrName -> [(GHC.SrcSpan, GHC.LHsExpr GHC.RdrName)]
         unfoldHsApp exp=
              case exp of
                  (GHC.L l (GHC.HsApp e1 e2))->(unfoldHsApp e1)++[(l,e2)]
                  _ ->[(GHC.noSrcSpan,exp)]

         -- |reconstruct  a function application by a list of expressions.
         -- TODO:AZ include the location, for reconstruction
         foldHsApp :: [(GHC.SrcSpan, GHC.LHsExpr GHC.RdrName)] -> GHC.LHsExpr GHC.RdrName
         -- foldHsApp exps = foldl1 (\e1 e2->(GHC.noLoc (GHC.HsApp e1 e2))) exps
         foldHsApp [] = error "foldHsApp:empty list"
         foldHsApp exps = snd $ foldl1 (\(l1,e1) (l2,e2) -> (l2,GHC.L l2 (GHC.HsApp e1 e2))) exps

{-
--remove the nth argument of function pn in all the calling places. the index for the first argument is zero.
rmNthArgInFunCall pn nth updateToks=applyTP (stop_tdTP (failTP `adhocTP` funApp))
   where
         funApp (exp@(Exp (HsParen (Exp (HsApp e1 e2))))::HsExpP)
              |nth==0 && pn==expToPN e1
             =do if updateToks
                   then do update exp e1 exp    --handle the case like '(fun x) => fun "
                   else return e1
         funApp (exp@(Exp (HsApp e1 e2))::HsExpP)
              |pn==(expToPN.(ghead "rmNthArgInFunCall").unfoldHsApp) exp  --test if this application is a calling of fun pn.
               =do let (before,after)=splitAt (nth+1) (unfoldHsApp exp)   --remove the nth argument
                   if updateToks
                    then delete (ghead "rmNthArgInFunCall" after) exp
                    else return (foldHsApp (before++tail after))  --reconstruct the function application.

         funApp _=mzero

         --deconstruct a function application into a list of expressions.
         unfoldHsApp exp=
              case exp of
                  (Exp (HsApp e1 e2))->(unfoldHsApp e1)++[e2]
                  _ ->[exp]
         --reconstruct  a function application by a list of expressions.
         foldHsApp exps=foldl1 (\e1 e2->(Exp (HsApp e1 e2))) exps
-}

-- ---------------------------------------------------------------------

rmNthArgInSig :: GHC.Name -> Int -> [GHC.LHsDecl GHC.RdrName] -> RefactGhc [GHC.LHsDecl GHC.RdrName]
rmNthArgInSig pn nth decls = do
  nm <- getRefactNameMap
  let (before,after)=break (\d ->definesSigDRdr nm pn d) decls
  if null after
       then  return decls
       else  do newSig<-rmNthArgInSig' nm nth  [(head after)]  --no problem with 'head'
                return (before++newSig++(tail after))

   where rmNthArgInSig' nm nth sig@[GHC.L l (GHC.SigD (GHC.TypeSig is tp c))]
          =do
              logDataWithAnns "rmNthArgInSig:(tp)" tp
              logDataWithAnns "rmNthArgInSig:(unfoldHsTypApp tp)" (unfoldHsTypApp tp)
              let newSig=if length is ==1
                            then --this type signature only defines the type of pn
                                 [GHC.L l (GHC.SigD (GHC.TypeSig is (rmNth tp) c))]
                            else --this type signature also defines the type of other ids.
                                 [GHC.L l (GHC.SigD (GHC.TypeSig (filter (\x->rdrName2NamePure nm x/=pn) is) tp         c)),
                                  GHC.L l (GHC.SigD (GHC.TypeSig (filter (\x->rdrName2NamePure nm x==pn) is) (rmNth tp) c))]
              return newSig

         rmNth tp = let (before,after)=splitAt nth (unfoldHsTypApp tp)
                    in  (foldHsTypApp (before ++ tail after))

         --deconstruct a type application into a list of types
         unfoldHsTypApp :: GHC.LHsType GHC.RdrName -> [GHC.LHsType GHC.RdrName]
         unfoldHsTypApp typ =
               case typ of (GHC.L l (GHC.HsFunTy t1 t2)) ->t1:unfoldHsTypApp t2
                           _ ->[typ]

         --reconstruct a type application by a list of type expression.
         foldHsTypApp :: [GHC.LHsType GHC.RdrName] -> GHC.LHsType GHC.RdrName
         foldHsTypApp [] = error "foldHsTypApp:empty list"
         foldHsTypApp ts=foldr1 (\t1 t2->(GHC.noLoc (GHC.HsFunTy t1 t2))) ts

{-

rmNthArgInSig pn nth decls
 = let (before,after)=break (\d ->definesTypeSig pn d) decls
   in if  after==[]
       then  return decls
       else  do newSig<-rmNthArgInSig' nth  [(head after)]  --no problem with 'head'
                return (before++newSig++(tail after))

   where rmNthArgInSig' nth sig@[(Dec (HsTypeSig loc is c tp))]
          =do let newSig=if length is ==1
                            then --this type signature only defines the type of pn
                                 [Dec (HsTypeSig loc is c (rmNth tp))]
                            else --this type signature also defines the type of other ids.
                                 [Dec (HsTypeSig loc (filter (\x->pNTtoPN x/=pn) is) c tp),
                                  Dec (HsTypeSig loc (filter (\x->pNTtoPN x==pn) is) c (rmNth tp))]
              update sig newSig sig

         rmNth tp=let (before,after)=splitAt nth (unfoldHsTypApp tp)
                    in  (foldHsTypApp (before ++ tail after))

         --deconstruct a type application into a list of types
         unfoldHsTypApp typ =
               case typ of (Typ (HsTyFun t1 t2)) ->t1:unfoldHsTypApp t2
                           _ ->[typ]

         --reconstruct a type application by a list of type expression.
         foldHsTypApp ts=foldr1 (\t1 t2->(Typ (HsTyFun t1 t2))) ts
-}

-- ---------------------------------------------------------------------

-- |get the function name and the index of the parameter to be removed from the cursor position.
getParam :: SimpPos -> RefactGhc (Maybe (GHC.Name,Int))
getParam pos = do
  nm <- getRefactNameMap
  parsed <- getRefactParsed
  -- let mparam = locToRdrName pos parsed
  let r = applyTU (once_tdTU (failTU `adhocTU` inMatch)) parsed
  case r of
    Nothing     -> return Nothing
    Just (ln,i) -> return $ Just (rdrName2NamePure nm ln,i)
    where
       inMatch (match@(GHC.Match (Just (fun,_)) pats mtyp grhs)::GHC.Match GHC.RdrName (GHC.LHsExpr GHC.RdrName))
         = case locToRdrName pos pats of
             Nothing -> Nothing
             Just ln -> if isNothing elem
                    then error  "Invalid cursor position!"  -- cursor doesn't stop at a parameter position.
                    else Just (fun, fromJust (elemIndex (fromJust elem) paramPosRanges))
               where
                 paramPosRanges = map GHC.getLoc pats
                 elem = find (inRange pos) paramPosRanges
           -- * |inRange pos (getStartEndLoc toks pats)

       inRange pos ss = pos >= startPos && pos<=endPos
         where (startPos,endPos) = (ss2pos ss,ss2posEnd ss)

{-
--get the function name and the index of the parameter to be removed from the cursor position.
getParam toks pos
     =(fromMaybe (defaultPNT, 0)).(applyTU (once_tdTU (failTU `adhocTU` inMatch)))
    where
       inMatch (match@(HsMatch loc  fun  pats rhs  decls)::HsMatchP)
          |inRange pos (getStartEndLoc toks pats)
          =let paramPosRanges=map (getStartEndLoc toks) pats
               elem=find (inRange pos) paramPosRanges
               in if isNothing elem
                    then error "Invalid cursor position!"  -- cursor doesn't stop at a parameter position.
                     else Just (fun, fromJust (elemIndex (fromJust elem) paramPosRanges))
       inMatch _=Nothing

       inRange pos (startPos,endPos)=pos>=startPos && pos<=endPos
-}

-- ---------------------------------------------------------------------

rmParamInClientMod :: GHC.Name -> Int -> TargetModule -> RefactGhc ApplyRefacResult
rmParamInClientMod pn nth serverModName = do
  logm $ "rmParamInClientMod:serverModName" ++ showGhc serverModName
  (r,_) <- applyRefac (rmNthArgInFunCallMod pn nth True) (RSTarget serverModName)
  return r
 -- = do (inscps, exps, mod, ts) <-parseSourceFile fileName
 --      let qualifier = hsQualifier pnt inscps
 --          pn = pNTtoPN pnt
 --      if  qualifier == []
 --          then return ((fileName,unmodified), (ts,mod))
 --          else do (mod',((ts',m), _)) <- runStateT (rmNthArgInFunCall pn nth True mod)
 --                                         ((ts,unmodified),(-1000,0))
 --                  return ((fileName,m), (ts',mod'))

{-
rmParamInClientMod pnt nth (m, fileName)
 = do (inscps, exps, mod, ts) <-parseSourceFile fileName
      let qualifier = hsQualifier pnt inscps
          pn = pNTtoPN pnt
      if  qualifier == []
          then return ((fileName,unmodified), (ts,mod))
          else do (mod',((ts',m), _)) <- runStateT (rmNthArgInFunCall pn nth True mod)
                                         ((ts,unmodified),(-1000,0))
                  return ((fileName,m), (ts',mod'))

-}

rmNthArgInFunCallMod pn nth f = do
  parsed <- getRefactParsed
  newNames <- equivalentNameInNewMod pn
  logm $ "rmNthArgInFunCallMod:(newNames)=" ++ showGhcQual newNames
  case newNames of
    [] -> return ()
    [pnt] -> do
      parsed' <- rmNthArgInFunCall pn nth f parsed
      putRefactParsed parsed' emptyAnns
      return ()
    ns    -> error "HaRe: rmParam: more than one name matches"
