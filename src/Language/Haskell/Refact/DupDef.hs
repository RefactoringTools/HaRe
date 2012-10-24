{-# LANGUAGE ScopedTypeVariables #-}
module Language.Haskell.Refact.DupDef(duplicateDef) where

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import qualified Bag                   as GHC
import qualified DynFlags              as GHC
import qualified FastString            as GHC
import qualified GHC
import qualified MonadUtils            as GHC
import qualified OccName               as GHC
import qualified Outputable            as GHC
import qualified RdrName               as GHC

import Control.Monad
import Control.Monad.State
import Data.Data
import Data.List
import Data.Maybe
import GHC.Paths ( libdir )

import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

-- ---------------------------------------------------------------------
-- | This refactoring duplicates a definition(function binding or
-- simple pattern binding) at same level with a new name provided by
-- the user. The new name should not cause name clash/capture.

-- TODO: This boilerplate will be moved to the coordinator, just comp will be exposed
duplicateDef :: [String] -> IO () -- For now
duplicateDef args
 = do let fileName = ghead "filename" args
          newName  = args!!1
          row      = read (args!!2)::Int
          col      = read (args!!3)::Int
      runRefacSession Nothing (comp fileName newName (row,col))
      return ()

comp :: String -> String -> SimpPos
     -> RefactGhc [ApplyRefacResult]
comp fileName newName (row, col) = do
      if isVarId newName
        then do modInfo@((_,renamed,parsed), tokList) <- parseSourceFileGhc fileName
                -- modName <-fileNameToModName fileName
                -- let modName = getModuleName parsed
                let (Just (modName,_)) = getModuleName parsed
                -- let pn = pNTtoPN $ locToPNT (GHC.mkFastString fileName) (row, col) parsed
                let maybePn = locToName (GHC.mkFastString fileName) (row, col) renamed
                case maybePn of
                  Just pn ->
                       do refactoredMod@((fileName',m),(tokList',parsed')) <- applyRefac (doDuplicating pn newName) (Just modInfo) fileName
                          st <- get
                          case (rsStreamModified st) of
                            False -> error "The selected identifier is not a function/simple pattern name, or is not defined in this module "
                            True -> return ()

                          if modIsExported parsed
                          -- if False
                           then do clients <- clientModsAndFiles modName
                                   -- TODO: uncomment and complete this
                                   -- refactoredClients <- mapM (refactorInClientMod modName 
                                   --                            (findNewPName newName parsed')) clients
                                   let refactoredClients = [] -- ++AZ++ temporary
                                   -- writeRefactoredFiles False $ ((fileName,m),(tokList',parsed')):refactoredClients 
                                   return $ refactoredMod:refactoredClients
                           -- else  writeRefactoredFiles False [((fileName,m), (tokList',parsed'))]
                           else  return [refactoredMod]
                  Nothing -> error "Invalid cursor position!"
        else error $ "Invalid new function name:" ++ newName ++ "!"


doDuplicating :: GHC.Located GHC.Name -> String -> ParseResult
              -> RefactGhc RefactResult
doDuplicating pn newName (inscopes,Just renamed,parsed) =

   everywhereMStaged SYB.Renamer (SYB.mkM dupInMod
                                  `SYB.extM` dupInMatch
                                  `SYB.extM` dupInPat
                                  `SYB.extM` dupInLet
                                  `SYB.extM` dupInLetStmt
                                 ) renamed
        where
        --1. The definition to be duplicated is at top level.
        -- dupInMod :: (GHC.HsGroup GHC.Name)-> RefactGhc (GHC.HsGroup GHC.Name)
        dupInMod (grp :: (GHC.HsGroup GHC.Name))
          | not $ emptyList (findFunOrPatBind pn (hsBinds grp)) = doDuplicating' inscopes grp pn
        dupInMod grp = return grp

        --2. The definition to be duplicated is a local declaration in a match
        dupInMatch (match@(GHC.Match _pats _typ rhs)::GHC.Match GHC.Name)
          | not $ emptyList (findFunOrPatBind pn (hsBinds rhs)) = doDuplicating' inscopes match pn
        dupInMatch match = return match

        --3. The definition to be duplicated is a local declaration in a pattern binding
        dupInPat (pat@(GHC.PatBind _p rhs _typ _fvs _) :: GHC.HsBind GHC.Name)
          | not $ emptyList (findFunOrPatBind pn (hsBinds rhs)) = doDuplicating' inscopes pat pn
        dupInPat pat = return pat

        --4: The defintion to be duplicated is a local decl in a Let expression
        dupInLet (letExp@(GHC.HsLet ds e):: GHC.HsExpr GHC.Name)
          | not $ emptyList (findFunOrPatBind pn (hsBinds ds)) = doDuplicating' inscopes letExp pn
        dupInLet letExp = return letExp

        --5. The defintion to be duplicated is a local decl in a case alternative.
        -- Note: The local declarations in a case alternative are covered in #2 above.

        --6.The definition to be duplicated is a local decl in a Let statement.
        dupInLetStmt (letStmt@(GHC.LetStmt ds):: GHC.Stmt GHC.Name)
           -- |findFunOrPatBind pn ds /=[]=doDuplicating' inscps letStmt pn
           |not $ emptyList (findFunOrPatBind pn (hsBinds ds)) = doDuplicating' inscopes letStmt pn
        dupInLetStmt letStmt = return letStmt

{-
        failure=idTP `adhocTP` parsed
          where
            parsed (m::HsModuleP)
              = error "The selected identifier is not a function/simple pattern name, or is not defined in this module "
-}

{-
doDuplicating pn newName (inscps, parsed, tokList)
   = runStateT (applyTP ((once_tdTP (failTP `adhocTP` dupInMod
                                            `adhocTP` dupInMatch
                                            `adhocTP` dupInPat
                                            `adhocTP` dupInLet
                                            `adhocTP` dupInAlt
                                            `adhocTP` dupInLetStmt)) `choiceTP` failure) parsed)
                                     ((tokList,unmodified), (-1000))  -- the (-1000) should be deleted.
        where
        --1. The definition to be duplicated is at top level.
        dupInMod (parsed@(HsModule loc name exps imps ds):: HsModuleP)
          |findFunOrPatBind  pn ds/=[]=doDuplicating' inscps parsed pn
        dupInMod _ =mzero

        --2. The definition to be duplicated is a local declaration in a match
        dupInMatch (match@(HsMatch loc1 name pats rhs ds)::HsMatchP)
          |findFunOrPatBind pn ds/=[]=doDuplicating' inscps match pn
        dupInMatch _ =mzero

        --3. The definition to be duplicated is a local declaration in a pattern binding
        dupInPat (pat@(Dec (HsPatBind loc p rhs ds))::HsDeclP)
          |findFunOrPatBind pn ds/=[]=doDuplicating' inscps pat pn
        dupInPat _=mzero

        --4: The defintion to be duplicated is a local decl in a Let expression
        dupInLet (letExp@(Exp (HsLet ds e))::HsExpP)
          |findFunOrPatBind pn  ds/=[]=doDuplicating' inscps letExp pn
        dupInLet _=mzero

        --5. The defintion to be duplicated is a local decl in a case alternative.
        dupInAlt (alt@(HsAlt loc p rhs ds)::(HsAlt (HsExpP) (HsPatP) [HsDeclP]))
          |findFunOrPatBind pn ds/=[]=doDuplicating'  inscps alt pn
        dupInAlt _=mzero

        --6.The definition to be duplicated is a local decl in a Let statement.
        dupInLetStmt (letStmt@(HsLetStmt ds stmts):: (HsStmt (HsExpP) (HsPatP) [HsDeclP]))
           |findFunOrPatBind pn  ds /=[]=doDuplicating' inscps letStmt pn
        dupInLetStmt _=mzero


        failure=idTP `adhocTP` parsed
          where
            parsed (m::HsModuleP)
              = error "The selected identifier is not a function/simple pattern name, or is not defined in this module "
-}

        -- findFunOrPatBind :: (SYB.Data t) => GHC.Located GHC.Name -> t -> [GHC.LHsBind GHC.Name]
        findFunOrPatBind (GHC.L _ n) ds = filter (\d->isFunBindR d || isSimplePatBind d) $ definingDeclsNames [n] ds True False

        doDuplicating' :: (HsBinds t) => InScopes -> t -> GHC.Located GHC.Name
                       -> RefactGhc (t)
        doDuplicating' inscps parentr ln@(GHC.L _ n)
           = do let -- decls           = hsDecls parent -- TODO: reinstate this
                    -- declsr = GHC.bagToList $ getDecls parentr
                    declsr = hsBinds parentr

                    duplicatedDecls = definingDeclsNames [n] declsr True False
                    -- (after,before)  = break (definesP pn) (reverse declsp)

                    (f,d) = hsFDNamesFromInside parentr
                    --f: names that might be shadowd by the new name,
                    --d: names that might clash with the new name

                    dv = hsVisibleNames ln declsr --dv: names may shadow new name
                    -- inscpsNames = map ( \(x,_,_,_)-> x) $ inScopeInfo inscps
                    vars        = nub (f `union` d `union` dv)

                newNameGhc <- mkNewName newName
                -- TODO: Where definition is of form tup@(h,t), test each element of it for clashes, or disallow    
                nameAlreadyInScope <- isInScopeAndUnqualifiedGhc newName

                -- liftIO $ putStrLn ("DupDef: nameAlreadyInScope =" ++ (show nameAlreadyInScope)) -- ++AZ++ debug
                liftIO $ putStrLn ("DupDef: ln =" ++ (show ln)) -- ++AZ++ debug
                -- liftIO $ putStrLn ("DupDef: duplicatedDecls =" ++ (GHC.showPpr duplicatedDecls)) -- ++AZ++ debug
                -- liftIO $ putStrLn ("DupDef: duplicatedDecls =" ++ (SYB.showData SYB.Renamer 0 $ duplicatedDecls)) -- ++AZ++ debug
                -- liftIO $ putStrLn ("DupDef: declsr =" ++ (SYB.showData SYB.Renamer 0 $ declsr)) -- ++AZ++ debug

                -- if elem newName vars || (isInScopeAndUnqualified newName inscps && findEntity ln duplicatedDecls) 
                if elem newName vars || (nameAlreadyInScope && findEntity ln duplicatedDecls) 
                   then error ("The new name'"++newName++"' will cause name clash/capture or ambiguity problem after "
                               ++ "duplicating, please select another name!")
                   else do newBinding <- duplicateDecl declsr n newNameGhc
                           -- liftIO $ putStrLn ("DupDef: newBinding =" ++ (GHC.showPpr newBinding)) -- ++AZ++ debug
                           -- liftIO $ putStrLn ("DupDef: declsr =" ++ (GHC.showPpr declsr)) -- ++AZ++ debu

                           -- let newDecls = replaceDecls declsr (reverse before++ newBinding++ reverse after)
                           let newDecls = replaceDecls declsr (declsr ++ newBinding)
                           -- return (GHC.L lp (hsMod {GHC.hsmodDecls = newDecls}))
                           -- return $ g { GHC.hs_valds = (GHC.ValBindsIn (GHC.listToBag newDecls) []) } -- ++AZ++ what about GHC.ValBindsOut?
                           return $ replaceBinds parentr newDecls


{-
--Find the the new definition name in PName format.
findNewPName name
  =(fromMaybe defaultPN). applyTU (once_buTU (failTU `adhocTU` worker))
     where
        worker  pname
           |pNtoName pname == name = Just pname
        worker _ =mzero
-}

{-
--Do refactoring in the client module.
-- that is to hide the identifer in the import declaration if it will cause any problem in the client module.
refactorInClientMod serverModName newPName (modName, fileName)
  = do (inscps, exps,parsed ,ts) <- parseSourceFile fileName
       let modNames = willBeUnQualImportedBy serverModName parsed
       if isJust modNames && needToBeHided (pNtoName newPName) exps parsed
        then do (parsed', ((ts',m),_))<-runStateT (addHiding serverModName parsed [newPName]) ((ts,unmodified),fileName)
                return ((fileName,m), (ts',parsed'))
        else return ((fileName,unmodified),(ts,parsed))
   where
     needToBeHided name exps parsed
         =usedWithoutQual name (hsModDecls parsed)
          || causeNameClashInExports newPName name parsed exps
-}

{-
--Check here:
--get the module name or alias name by which the duplicated definition will be imported automatically.
willBeUnQualImportedBy::HsName.ModuleName->HsModuleP->Maybe [HsName.ModuleName]
willBeUnQualImportedBy modName parsed
   = let imps = hsModImports parsed
         ms   = filter (\(HsImportDecl _ (SN modName1 _) qualify  as h)->modName==modName1 && (not qualify) && 
                          (isNothing h || (isJust h && ((fst (fromJust h))==True)))) imps
         in if ms==[] then Nothing
                      else Just $ nub $ map getModName ms

         where getModName (HsImportDecl _ (SN modName _) qualify  as h)
                 = if isJust as then simpModName (fromJust as)
                                else modName
               simpModName (SN m loc) = m

-}