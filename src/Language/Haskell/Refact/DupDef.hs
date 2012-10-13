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
import Data.Maybe
import GHC.Paths ( libdir )

import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

{-

This refactoring duplicates a definition(function binding or simple
pattern binding) at same level with a new name provided by the user.
The new name should not cause name clash/capture.

-}

-- ---------------------------------------------------------------------

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
                       do ((fileName',m),(tokList',parsed')) <- applyRefac (doDuplicating pn newName) (Just modInfo) fileName
                          if modIsExported parsed
                           then do clients <- clientModsAndFiles modName
                                   -- TODO: uncomment and complete this
                                   -- refactoredClients <- mapM (refactorInClientMod modName 
                                   --                            (findNewPName newName parsed')) clients
                                   let refactoredClients = [] -- ++AZ++ temporary
                                   -- writeRefactoredFiles False $ ((fileName,m),(tokList',parsed')):refactoredClients 
                                   return $ ((fileName',m),(tokList',parsed')):refactoredClients 
                           -- else  writeRefactoredFiles False [((fileName,m), (tokList',parsed'))]
                           else  return [((fileName,m), (tokList',parsed'))]
                  Nothing -> error "Invalid cursor position!"
        else error $ "Invalid new function name:" ++ newName ++ "!"


-- type PN     = GHC.RdrName

doDuplicating :: GHC.Located GHC.Name -> String -> ParseResult
              -> RefactGhc GHC.ParsedSource
doDuplicating pn newName (_,Just renamed,parsed) =

   everywhereMStaged SYB.Parser (SYB.mkM dupInMod) parsed
        where
        --1. The definition to be duplicated is at top level.
        -- dupInMod (parsed@(HsModule loc name exps imps ds):: HsModuleP)
        dupInMod :: (GHC.Located (GHC.HsModule GHC.RdrName))-> RefactGhc (GHC.Located (GHC.HsModule GHC.RdrName))
        dupInMod (parsed@(GHC.L l (GHC.HsModule name exps imps ds _ _)))
          -- |findFunOrPatBind pn ds /= [] = doDuplicating' parsed pn
          | length (findFunOrPatBind pn ds) == 0 = doDuplicating' renamed parsed pn
        -- dupInMod _ =mzero
        dupInMod parsed = return parsed

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

        findFunOrPatBind :: (SYB.Data t) => GHC.Located GHC.Name -> t -> [GHC.LHsBind GHC.Name]
        findFunOrPatBind (GHC.L _ n) ds = filter (\d->isFunBind d || isSimplePatBind d) $ definingDeclsNames [n] ds True False

        -- doDuplicating' :: GHC.ParsedSource -> GHC.Located GHC.Name -> RefactGhc GHC.ParsedSource
        doDuplicating' parentr parentp pn@(GHC.L _ n)
           = do let -- decls           = hsDecls parent -- TODO: reinstate this
                    decls = GHC.bagToList $ getDecls parentr  
                    -- TODO: There is an assumption that the decls are in lexical order. Hmm.
                    duplicatedDecls = definingDeclsNames [n] decls True False
                    (after,before)  = break (defines n) (reverse decls)

                    (f,d) = hsFDNamesFromInside parentr
                    --f: names that might be shadowd by the new name, d: names that might clash with the new name

                return parentp -- ++AZ++ to keep GHC happy
{-
                dv <- hsVisibleNames pn decls --dv: names may shadow new name
                let inscpsNames = map ( \(x,_,_,_)-> x) $ inScopeInfo inscps
                    vars        = nub (f `union` d `union` dv)
                -- TODO: Where definition is of form tup@(h,t), test each element of it for clashes, or disallow    
                if elem newName vars || (isInScopeAndUnqualified newName inscps && findEntity pn duplicatedDecls) 
                   then error ("The new name'"++newName++"' will cause name clash/capture or ambiguity problem after "
                               ++ "duplicating, please select another name!")
                   else do newBinding<-duplicateDecl decls pn newName
                           return (replaceDecls parent (reverse before++ newBinding++ reverse after)) 
-}

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