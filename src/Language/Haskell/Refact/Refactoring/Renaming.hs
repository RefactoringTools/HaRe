module Language.Haskell.Refact.Refactoring.Renaming (rename) where

import qualified Data.Generics.Schemes as SYB
import qualified Data.Generics.Aliases as SYB
import qualified GHC.SYB.Utils         as SYB

import qualified GHC
import qualified Name                  as GHC
import qualified RdrName               as GHC

import Control.Monad
import Data.List

import qualified Language.Haskell.GhcMod as GM (Options(..))
import Language.Haskell.Refact.API
import Language.Haskell.Refact.Utils.GhcVersionSpecific


{-This refactoring renames an indentifier to a user-specified name.

  Conditions:
    a: the indentifier to be renamed should be defined in the current module.
    b. the user provided name should be a valid name with regard to the name
       space of the identifier.
    c. the new name should not change the semantics of the program, and
       should not cause any name clash/conflict/ambiguity problem in the
       program.

  Attention:
    a. To select an identifier, stop the cursor at the beginning position of
       any occurrence of the identifier.
    b. Renaming a qualified name will not change the qualifier;
    c. In current module, an unqualified name won't become qualified after
       renaming; but, in client modules, an unqualified name might become
       qualified after renaming to avoid ambiguity prolem. In case the new
       name, say 'f', will cause ambiguous occurrence in the current module
       (this is because the identifier 'f' is imported from other modules),
       the user will be prompted to choose another new name or qualify the
       use of 'f' before doing renaming.
  -}

{-In the current implementation, we assume that module name is same as
the file name, but we should keep in mind that people also use unnamed
modules.
-}

-- | Rename the given identifier.
rename :: RefactSettings -> GM.Options
   -> FilePath -> String -> SimpPos
   -> IO [FilePath]
rename settings opts fileName newName (row,col) =
  runRefacSession settings opts [Left fileName] (comp fileName newName (row,col))

-- | Body of the refactoring
comp :: FilePath -> String -> SimpPos -> RefactGhc [ApplyRefacResult]
comp fileName newName (row,col) = do
    logm $ "Renaming.comp: (fileName,newName,(row,col))=" ++ show (fileName,newName,(row,col))
    getModuleGhc fileName
    renamed <- getRefactRenamed
    parsed  <- getRefactParsed

    modu <- getModule
    targetModule <- getRefactTargetModule
    let modName = case getModuleName parsed of
                    Just (mn,_) -> mn
                    Nothing -> GHC.mkModuleName "Main"
    let maybePn = locToName (row, col) renamed
    logm $ "Renamed.comp:maybePn=" ++ showGhc maybePn -- ++AZ++
    case maybePn of
        Just pn@(GHC.L _ n) -> do
           logm $ "Renaming:(n,modu)=" ++ showGhc (n,modu)

           let (GHC.L _ rdrName) = gfromJust "Renaming.comp.2" $ locToRdrName (row, col) parsed
           let rdrNameStr = GHC.occNameString $ GHC.rdrNameOcc rdrName
           logm $ "Renaming: rdrName=" ++ SYB.showData SYB.Parser 0 rdrName
           logm $ "Renaming: occname rdrName=" ++ show (GHC.occNameString $ GHC.rdrNameOcc rdrName)

           unless (nameToString n /= newName) $ error "The new name is same as the old name"
           unless (isValidNewName n rdrNameStr newName) $ error $ "Invalid new name:" ++ newName ++ "!"


           logm $ "Renaming.comp: before GHC.nameModule,n=" ++ showGhc n

           let defineMod = case GHC.nameModule_maybe n of
                            Just mn -> GHC.moduleName mn
                            Nothing -> modName

           -- TODO: why do we have this restriction?
           unless (defineMod == modName ) ( error ("This identifier is defined in module " ++ GHC.moduleNameString defineMod ++
                                         ", please do renaming in that module!"))
           logm $ "Renaming.comp:(isMainModule modu,pn)=" ++ (showGhcQual (isMainModule modu,pn))
           if isMainModule modu && showGhcQual pn == "Main.main"
             then error "The 'main' function defined in a 'Main' module should not be renamed!"
             else do
               logm $ "Renaming.comp: not main module"
               newNameGhc <- mkNewGhcName (Just modu) newName
               (refactoredMod,nIsExported) <- applyRefac (doRenaming pn rdrNameStr newName newNameGhc modName) RSAlreadyLoaded
               logm $ "Renaming:nIsExported=" ++ show nIsExported
               if nIsExported  --no matter whether this pn is used or not.
                   then do clients <- clientModsAndFiles targetModule
                           logm ("Renaming: clients=" ++ show clients) -- ++AZ++ debug
                           refactoredClients <- mapM (renameInClientMod n newName newNameGhc) clients
                           return $ refactoredMod:(concat refactoredClients)
                   else  return [refactoredMod]
        Nothing -> error "Invalid cursor position!"


-- |Actually do the renaming, split into the various things that can
-- be renamed. Returns True if the name is exported
doRenaming :: GHC.Located GHC.Name -> String -> String -> GHC.Name -> GHC.ModuleName -> RefactGhc Bool

--------Rename a value variable name--------------------------------
doRenaming pn@(GHC.L _ oldn) rdrNameStr newNameStr newNameGhc modName = do
  logm $ "doRenaming:(pn,rdrNameStr,newNameStr) = " ++ (showGhc (pn,rdrNameStr,newNameStr))
  renamed <- getRefactRenamed
  {-
  r' <- applyTP (once_buTPGhc (failTP `adhocTP` renameInMod
                                -- `adhocTP` renameInMatch
                                -- `adhocTP` renameInPattern
                                -- `adhocTP` renameInExp
                                -- `adhocTP` renameInAlt
                                -- `adhocTP` renameInStmts
                                )) renamed
                                -}
  void $ SYB.everywhereM (SYB.mkM renameInMod
                         ) renamed
  logm "doRenaming done"
  nIsExported <- isExported oldn
  return nIsExported
   where
     -- 1. The name is declared in a module(top level name)
     renameInMod :: GHC.RenamedSource -> RefactGhc GHC.RenamedSource
     renameInMod ren
        | True = do
           logm $ "renameInMod"
           renameTopLevelVarName oldn newNameStr newNameGhc modName ren True True


renameTopLevelVarName :: GHC.Name -> String -> GHC.Name -> GHC.ModuleName -> GHC.RenamedSource
                         -> Bool -> Bool -> RefactGhc GHC.RenamedSource
renameTopLevelVarName oldPN newName newNameGhc modName renamed existChecking exportChecking = do
     logm $ "renameTopLevelVarName:(existChecking,exportChecking)=" ++ (show (existChecking,exportChecking))
     causeAmbiguity <- causeAmbiguityInExports oldPN newNameGhc
      -- f' contains names imported from other modules;
      -- d' contains the top level names declared in this module;
     (f',d') <- hsFDsFromInside renamed
      --filter those qualified free variables in f'
     -- let (f,d) = ((nub.map pNtoName.filter (not.isQualifiedPN)) f', (nub.map pNtoName) d')
     let (f,d) = (map nameToString f',map nameToString d')
     logm $ "renameTopLevelVarName:f=" ++ (show f)
     logm $ "renameTopLevelVarName:d=" ++ (show d)
     let newNameStr = nameToString newNameGhc
     logm $ "renameTopLevelVarName:(newName,newNameStr)=" ++ (show (newName,newNameStr))
     scopeClashNames <- inScopeNames newName
     logm $ "renameTopLevelVarName:(f')=" ++ (showGhc f')
     logm $ "renameTopLevelVarName:(scopeClashNames,intersection)=" ++ (showGhc (scopeClashNames,intersect scopeClashNames f'))
     logm $ "renameTopLevelVarName:(oldPN,modName)=" ++ (showGhc (oldPN,modName))
     if (nonEmptyList $ intersect scopeClashNames f')
       then error ("The new name will cause ambiguous occurrence problem,"
                   ++" please select another new name or qualify the use of ' "
                   ++ newName ++ "' before renaming!\n") -- Another implementation option is to add the qualifier
                                                         -- to newName automatically.
       else if existChecking && elem newNameStr (d \\ [nameToString oldPN])  --only check the declared names here.
             then error ("Name '"++newName++"'  already existed\n") --the same name has been declared in this module.
             else if exportChecking && causeNameClashInExports oldPN newNameGhc modName renamed
                    then error ("The new name will cause conflicting exports, please select another new name!")
                    else if exportChecking && causeAmbiguity -- causeAmbiguityInExports oldPN  newNameGhc {- inscps -} renamed
                          then error $"The new name will cause ambiguity in the exports of module "++ show modName ++ ", please select another name!"
                          else do  -- get all of those declared names visible to oldPN at where oldPN is used.

                                 logm $ "renameTopLevelVarName:basic tests done"

                                 isInScopeUnqual <- isInScopeAndUnqualifiedGhc newName (Just newNameGhc)
                                 logm $ "renameTopLevelVarName:after isInScopeUnqual"
                                 logm $ "renameTopLevelVarName:oldPN=" ++ showGhc oldPN
                                 ds <- hsVisibleNames oldPN renamed
                                 logm $ "renameTopLevelVarName:ds computed=" ++ (show ds)
                                 if existChecking && elem newName ((nub (ds `union` f)) \\[nameToString oldPN])
                                   then error ("Name '"++newName++"'  already existed, or rename '"
                                                ++nameToString oldPN++ "' to '"++newName++
                                                "' will change the program's semantics!\n")
                                   else if exportChecking && isInScopeUnqual -- isInScopeAndUnqualifiedGhc newName Nothing
                                          then do
                                               logm $ "renameTopLevelVarName start..:should have qualified"
                                               parsed <- getRefactParsed
                                               parsed' <- renamePN' oldPN newNameGhc True parsed
                                               putRefactParsed parsed' mempty
                                               logm $ "renameTopLevelVarName done:should have qualified"
                                               r' <- getRefactRenamed
                                               return r'
                                          else do
                                               logm $ "renameTopLevelVarName start.."
                                               parsed <- getRefactParsed
                                               parsed' <- renamePN' oldPN newNameGhc False parsed
                                               putRefactParsed parsed' mempty
                                               logm $ "renameTopLevelVarName done"
                                               r' <- getRefactRenamed
                                               return r'


renameInClientMod :: GHC.Name -> String -> GHC.Name -> TargetModule
                  -> RefactGhc [ApplyRefacResult]
renameInClientMod oldPN newName newNameGhc targetModule = do
      logm $ "renameInClientMod:(oldPN,newNameGhc,targetModule)=" ++ (showGhc (oldPN,newNameGhc,targetModule)) -- ++AZ++
      getTargetGhc targetModule

      renamed <- getRefactRenamed
      modName <- getRefactModuleName

      -- There are two different tests we need to do here
      -- 1. Does the new name clash with some existing name in the
      --    client mod, in which case it must be qualified
      -- 2. Is the new name module imported qualified, and so needs to
      --    be qualified in the replacement, according to the import
      isInScopeUnqual    <- isInScopeAndUnqualifiedGhc (nameToString oldPN) Nothing
      isInScopeUnqualNew <- isInScopeAndUnqualifiedGhc newName              Nothing
      logm $ "renameInClientMod: (isInScopeAndUnqual,isInScopeUnqualNew)=" ++ (show (isInScopeUnqual,isInScopeUnqualNew)) -- ++AZ++
      if isInScopeUnqualNew
       then
        do
           (refactoredMod,_) <- applyRefac (refactRenameSimple oldPN newName newNameGhc True) RSAlreadyLoaded
           return [refactoredMod]
       else
        do if causeNameClashInExports oldPN newNameGhc modName renamed
             then error $"The new name will cause conflicting exports in module "++ show newName ++ ", please select another name!"
             else do
               (refactoredMod,_) <- applyRefac (refactRenameComplex oldPN newName newNameGhc) RSAlreadyLoaded
               -- TODO: implement rest of this
               return [refactoredMod]
  where
     refactRenameSimple :: GHC.Name -> String -> GHC.Name -> Bool -> RefactGhc ()
     refactRenameSimple old newStr new useQual = do
       qualifyTopLevelVar newStr
       parsed <- getRefactParsed
       parsed' <- renamePN' old new useQual parsed
       putRefactParsed parsed' mempty
       return ()

     refactRenameComplex :: GHC.Name -> String -> GHC.Name -> RefactGhc ()
     refactRenameComplex old new newGhc = do
       qualifyTopLevelVar new
       worker old new newGhc

     qualifyTopLevelVar :: String -> RefactGhc ()
     qualifyTopLevelVar new = do
       toQualify <- inScopeNames new
       logm $ "renameInClientMod.qualifyTopLevelVar:new:toQualify=" ++ (show new) ++ ":" ++ (showGhc toQualify)
       mapM_ qualifyToplevelName toQualify
       return ()

     worker :: GHC.Name -> String -> GHC.Name -> RefactGhc ()
     worker oldPN' newName' newNameGhc' = do
       logm $ "renameInClientMod.worker"
       renamed <- getRefactRenamed
       parsed <- getRefactParsed
       isInScopeUnqualNew <- isInScopeAndUnqualifiedGhc newName' Nothing
       vs <- hsVisibleNames oldPN' renamed   --Does this check names other than variable names?
       parsed' <- if elem newName' ((nub vs) \\ [nameToString oldPN'])  || isInScopeUnqualNew
         then renamePN' oldPN' newNameGhc' True parsed --rename to qualified Name
         else renamePN' oldPN' newNameGhc' False parsed -- do not qualify
       putRefactParsed parsed' mempty
       return ()


causeAmbiguityInExports :: GHC.Name -> GHC.Name -> RefactGhc Bool
causeAmbiguityInExports old newName {- inscps -}  = do
    (GHC.L _ (GHC.HsModule _ exps _imps _decls _ _)) <- getRefactParsed
    isInScopeUnqual <- isInScopeAndUnqualifiedGhc (nameToString old) Nothing
    let usedUnqual = usedWithoutQualR newName exps
    logm $ "causeAmbiguityInExports:(isInScopeUnqual,usedUnqual)" ++ (show (isInScopeUnqual,usedUnqual))
    return (isInScopeUnqual && usedUnqual)


isValidNewName :: GHC.Name -> String -> String -> Bool
isValidNewName oldName rdrNameStr newName = res
 where
   doTest :: Bool -> Bool -> String -> Bool
   doTest isCategory isRightType errStr =
      if isCategory
         then if isRightType
               then True
               else error errStr
         else True

   tyconOk = doTest (GHC.isTyConName oldName)
                    (isConId newName)
                    "Invalid type constructor/class name!"

   dataConOk = doTest (GHC.isDataConName oldName)
                      (isConId newName)
                      "Invalid data constructor name!"

   tyVarOk = doTest (GHC.isTyVarName oldName)
                    (isVarId newName)
                    "Invalid type variable name!"

   oldName' = rdrNameStr
   matchNamesOk
     | {- GHC.isValName oldName || -} GHC.isVarName oldName
              = if isVarId oldName' && not (isVarId newName)
                   then error "The new name should be an identifier!"
                   else if isOperator oldName' && not (isOperator newName)
                          then error "The new name should be an operator!"
                          else if (isVarId oldName' && isVarId newName) ||
                                   (isOperator oldName' && isOperator newName)
                                  then True
                                  -- else error "Invalid new name!"
                                  else error $ "Invalid new name!" ++ (show (oldName',newName,isVarId oldName',isVarId newName,isOperator oldName',isOperator newName))
     | otherwise = True

   res = tyconOk && dataConOk {- && fieldOk && instanceOk -} &&
         tyVarOk && matchNamesOk

