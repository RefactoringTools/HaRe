module Language.Haskell.Refact.Refactoring.Renaming
  ( rename
  , compRename
  ) where

import qualified GHC.SYB.Utils         as SYB

import qualified GHC
import qualified Name                  as GHC
import qualified RdrName               as GHC

import Control.Monad
import Data.List

import qualified Language.Haskell.GhcMod as GM (Options(..))
import qualified Language.Haskell.GhcMod.Internal as GM
import Language.Haskell.Refact.API
import System.Directory

import Language.Haskell.Refact.Utils.Utils (initTargetSession, dropTargetSession)


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
rename :: RefactSettings
       -> GM.Options
       -> FilePath
       -> String
       -> SimpPos
       -> IO [FilePath]
rename settings opts fileName newName (row,col) = do
  absFileName <- canonicalizePath fileName
  runRefacSession settings opts (compRename absFileName newName (row,col))

-- | Body of the refactoring
compRename :: FilePath -> String -> SimpPos -> RefactGhc [ApplyRefacResult]
compRename fileName newName (row,col) = do
    logm $ "Renaming.comp: (fileName,newName,(row,col))=" ++ show (fileName,newName,(row,col))
    initTargetSession [fileName]
    parseSourceFileGhc fileName

    parsed       <- getRefactParsed
    modu         <- getModule
    targetModule <- getRefactTargetModule
    nm           <- getRefactNameMap

    -- logDataWithAnns "parsed" parsed

    let modName = maybe (GHC.mkModuleName "Main") fst $ getModuleName parsed
        maybePn = locToRdrName (row, col) parsed

    logm $ "Renamed.comp:maybePn=" ++ showGhc maybePn -- ++AZ++

    case maybePn of
        Just pn'@(GHC.L l _) -> do
            let n = rdrName2NamePure nm pn'
                pn = GHC.L l n
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
            unless (defineMod == modName) . error $ mconcat [ "This identifier is defined in module "
                                                            , GHC.moduleNameString defineMod
                                                            , ", please do renaming in that module!"
                                                            ]
            logm $ "Renaming.comp:(isMainModule modu,pn)=" ++ showGhcQual (isMainModule modu,pn)
            when (isMainModule modu && showGhcQual pn == "Main.main") $
                error "The 'main' function defined in a 'Main' module should not be renamed!"

            logm "Renaming.comp: not main module"
            newNameGhc <- mkNewGhcName (Just modu) newName
            (refactoredMod, nIsExported) <- applyRefac (doRenaming pn rdrNameStr newName newNameGhc modName)
                                           RSAlreadyLoaded
            dropTargetSession

            logm $ "Renaming:nIsExported=" ++ show nIsExported
            if nIsExported  --no matter whether this pn is used or not.
                then do clients <- clientModsAndFiles targetModule
                        logm ("Renaming: clients=" ++ show clients) -- ++AZ++ debug
                        initTargetSession $ fileName : map (\(GM.ModulePath _mn fp) -> fp) clients
                        refactoredClients <- mapM (renameInClientMod n newName newNameGhc) clients
                        dropTargetSession
                        return $ refactoredMod : concat refactoredClients
                else return [refactoredMod]
        Nothing -> do
          dropTargetSession
          error "Invalid cursor position!"


-- |Actually do the renaming, split into the various things that can
-- be renamed. Returns True if the name is exported
doRenaming :: GHC.Located GHC.Name -> String -> String -> GHC.Name -> GHC.ModuleName -> RefactGhc Bool

--------Rename a value variable name--------------------------------
doRenaming pn@(GHC.L _ oldn) rdrNameStr newNameStr newNameGhc modName = do
    logm $ "doRenaming:(pn,rdrNameStr,newNameStr) = " ++ showGhc (pn,rdrNameStr,newNameStr)
    renameTopLevelVarName oldn newNameStr newNameGhc modName True True
    logm "doRenaming done"
    isExported oldn

renameTopLevelVarName :: GHC.Name -> String -> GHC.Name -> GHC.ModuleName
                      -> Bool -> Bool -> RefactGhc ()
renameTopLevelVarName oldPN newName newNameGhc modName existChecking exportChecking = do
    logm $ "renameTopLevelVarName:(existChecking, exportChecking)=" ++ show (existChecking, exportChecking)
    causeAmbiguity <- causeAmbiguityInExports oldPN newNameGhc
    parsed <- getRefactParsed
    nm <- getRefactNameMap
     -- f' contains names imported from other modules;
     -- d' contains the top level names declared in this module;
    let (FN f', DN d') = hsFDsFromInsideRdr nm parsed
     --filter those qualified free variables in f'
    -- let (f,d) = ((nub.map pNtoName.filter (not.isQualifiedPN)) f', (nub.map pNtoName) d')
    let (f, d) = (map nameToString f', map nameToString d')
    logm $ "renameTopLevelVarName:f=" ++ show f
    logm $ "renameTopLevelVarName:d=" ++ show d

    let newNameStr = nameToString newNameGhc
    logm $ "renameTopLevelVarName:(newName,newNameStr)=" ++ show (newName, newNameStr)

    scopeClashNames <- inScopeNames newName

    logm $ "renameTopLevelVarName:(f')=" ++ showGhc f'
    logm $ "renameTopLevelVarName:(scopeClashNames,intersection)=" ++
           showGhc (scopeClashNames, scopeClashNames `intersect` f')
    logm $ "renameTopLevelVarName:(oldPN,modName)=" ++ showGhc (oldPN,modName)

    -- Another implementation option is to add the qualifier to newName automatically.
    when (nonEmptyList $ intersect scopeClashNames f') .
        error $ mconcat [ "The new name will cause an ambiguous occurrence problem, "
                        , "please select another new name or qualify the use of '"
                        , newName ++ "' before renaming!\n"]

    when (existChecking && newNameStr `elem` d \\ [nameToString oldPN]) . -- only check the declared names here
        --the same name has been declared in this module.
        error $ mconcat ["Name '", newName, "' already exists in this module\n"]

    when (exportChecking && causeNameClashInExports nm oldPN newNameGhc modName parsed) $
        error "The new name will cause conflicting exports, please select another new name!"
    when (exportChecking && causeAmbiguity) . -- causeAmbiguityInExports oldPN  newNameGhc {- inscps -} renamed
        error $ mconcat ["The new name will cause ambiguity in the exports of module '"
                        , show modName
                        , "' , please select another name!"]
    -- get all of those declared names visible to oldPN at where oldPN is used.

    logm "renameTopLevelVarName:basic tests done"

    isInScopeUnqual <- isInScopeAndUnqualifiedGhc newName (Just newNameGhc)
    logm "renameTopLevelVarName:after isInScopeUnqual"
    logm $ "renameTopLevelVarName:oldPN=" ++ showGhc oldPN
    ds <- hsVisibleNamesRdr oldPN parsed
    logm $ "renameTopLevelVarName:ds computed=" ++ show ds
    when (existChecking && newName `elem` nub (ds `union` f) \\ [nameToString oldPN]) .
        error $ mconcat [ "Name '", newName, "' already exists, or renaming '", nameToString oldPN,  "' to '"
                        , newName, "' will change the program's semantics!\n"]

    logm "renameTopLevelVarName start..:should have qualified"
    let qual = if (exportChecking && isInScopeUnqual) then Qualify else PreserveQualify
    parsed' <- renamePN oldPN newNameGhc qual parsed
    putRefactParsed parsed' mempty
    logm "renameTopLevelVarName done:should have qualified"

------------------------------------------------------------------------

renameInClientMod :: GHC.Name -> String -> GHC.Name -> TargetModule
                  -> RefactGhc [ApplyRefacResult]
renameInClientMod oldPN newName newNameGhc targetModule@(GM.ModulePath _mn fp) = do
    logm $ "renameInClientMod:(oldPN,newNameGhc,targetModule)=" ++ showGhc (oldPN,newNameGhc,targetModule) -- ++AZ++
    logm $ "renameInClientMod:(newNameGhc module)=" ++ showGhc (GHC.nameModule newNameGhc) -- ++AZ++
    parseSourceFileGhc fp

    modName <- getRefactModuleName
    parsed  <- getRefactParsed
    nm      <- getRefactNameMap

    -- We need to find the old name in the module, and get it as a
    -- GHC.Name to know what to look for in the call to renamePN', as it
    -- checks the GHC.nameUnique value.
    -- gnames <- GHC.getNamesInScope
    -- let clientModule = GHC.nameModule oldPN
    -- let clientInscopes = filter (\n -> clientModule == GHC.nameModule n) gnames
    -- logm $ "renameInClientMod:(clientInscopes)=" ++ showGhcQual (clientInscopes)
    -- let newNames = filter (\n -> showGhcQual n == showGhcQual oldPN) clientInscopes
    newNames <- equivalentNameInNewMod oldPN
    logm $ "renameInClientMod:(newNames)=" ++ showGhcQual newNames

    -- newNames       <- inScopeNames (showGhcQual oldPN)
    -- newNamesUnqual <- inScopeNames (showGhc     oldPN)
    -- logm $ "renameInClientMod:(newNamesUnqual,oldPN)=" ++ showGhcQual (newNamesUnqual,oldPN)
    -- logm $ "renameInClientMod:(newNames,oldPN)=" ++ showGhcQual (newNames,oldPN)
    -- logm $ "renameInClientMod:(uniques:newNames,oldPN)=" ++ showGhcQual (map GHC.nameUnique newNames,GHC.nameUnique oldPN)
    case newNames of
        []        -> return []
        -- [oldName] | findPN oldName renamed -> doRenameInClientMod oldName modName renamed
        [oldName] | findNameInRdr nm oldName parsed -> doRenameInClientMod nm oldName modName parsed
                  | otherwise -> do
                      logm "renameInClientMod: name not present in module, returning"
                      return []
        ns -> error $ "HaRe: renameInClientMod: could not find name to replace, got:" ++ showGhcQual ns

  where
    doRenameInClientMod nm oldNameGhc modName parsed = do
        -- There are two different tests we need to do here
        -- 1. Does the new name clash with some existing name in the
        --    client mod, in which case it must be qualified
        -- 2. Is the new name module imported qualified, and so needs to
        --    be qualified in the replacement, according to the import
        isInScopeUnqual    <- isInScopeAndUnqualifiedGhc (nameToString oldPN) Nothing
        isInScopeUnqualNew <- isInScopeAndUnqualifiedGhc newName              Nothing
        logm $ "renameInClientMod: (isInScopeAndUnqual,isInScopeUnqualNew)=" ++
               show (isInScopeUnqual, isInScopeUnqualNew) -- ++AZ++

        if isInScopeUnqualNew -- ++AZ++: should this be negated?
            then do
                -- (refactoredMod, _) <- applyRefac (refactRenameSimple oldNameGhc newName newNameGhc True)
                (refactoredMod, _) <- applyRefac (refactRenameSimple oldNameGhc newName newNameGhc Qualify)
                                                RSAlreadyLoaded
                return [refactoredMod]
            else do
                when (causeNameClashInExports nm oldPN newNameGhc modName parsed) .
                    error $ mconcat [ "The new name will cause conflicting exports in module"
                                    , show newName, ", please select another name!"]
                -- (refactoredMod,_) <- applyRefac (refactRenameComplex oldPN newName newNameGhc) RSAlreadyLoaded
                (refactoredMod, _) <- applyRefac (refactRenameComplex oldNameGhc newName newNameGhc)
                                                RSAlreadyLoaded
                -- TODO: implement rest of this
                return [refactoredMod]

    refactRenameSimple :: GHC.Name -> String -> GHC.Name -> HowToQual -> RefactGhc ()
    refactRenameSimple old newStr new useQual = do
        logm $ "refactRenameSimple:(old,newStr,new,useQual)=" ++ showGhc (old, newStr, new, useQual)
        qualifyTopLevelVar newStr
        parsed <- renamePN old new useQual =<< getRefactParsed
        putRefactParsed parsed mempty
        return ()

    refactRenameComplex :: GHC.Name -> String -> GHC.Name -> RefactGhc ()
    refactRenameComplex old new newGhc = do
        logm $ "refactRenameComplex:(old,new,newGhc)=" ++ showGhc (old, new, newGhc)
        qualifyTopLevelVar new
        worker old new newGhc

    qualifyTopLevelVar :: String -> RefactGhc ()
    qualifyTopLevelVar new = do
        toQualify <- inScopeNames new
        logm $ "renameInClientMod.qualifyTopLevelVar:new:toQualify=" ++ show new ++ ":" ++ showGhc toQualify
        mapM_ qualifyToplevelName toQualify
        return ()

    worker :: GHC.Name -> String -> GHC.Name -> RefactGhc ()
    worker oldPN' newName' newNameGhc' = do
        logm $ "renameInClientMod.worker:(oldPN',newName',newNameGhc')=" ++
               showGhc (oldPN', newName', newNameGhc')
        isInScopeUnqualNew <- isInScopeAndUnqualifiedGhc newName' Nothing
        vs <- hsVisibleNamesRdr oldPN' =<< getRefactParsed  -- Does this check names other than variable names?
        logm $ "renameInClientMod.worker:(vs,oldPN',isInScopeUnqualNew)=" ++
               showGhc (vs, oldPN', isInScopeUnqualNew)

        -- logParsedSource "worker:parsed"

        let qual = if (newName' `elem` (nub vs \\ [nameToString oldPN']) || isInScopeUnqualNew)
                      then Qualify
                      else PreserveQualify
        parsed <- renamePN oldPN' newNameGhc' qual =<< getRefactParsed
        putRefactParsed parsed mempty
        return ()

causeAmbiguityInExports :: GHC.Name -> GHC.Name -> RefactGhc Bool
causeAmbiguityInExports old newName {- inscps -} = do
    (GHC.L _ (GHC.HsModule _ exps _imps _decls _ _)) <- getRefactParsed
    isInScopeUnqual <- isInScopeAndUnqualifiedGhc (nameToString old) Nothing
    let usedUnqual = usedWithoutQualR newName exps
    logm $ "causeAmbiguityInExports:(isInScopeUnqual,usedUnqual)" ++ show (isInScopeUnqual, usedUnqual)
    return (isInScopeUnqual && usedUnqual)

isValidNewName :: GHC.Name -> String -> String -> Bool
isValidNewName oldName rdrNameStr newName = res
  where
    doTest :: Bool -> Bool -> String -> Bool
    doTest isCategory isRightType errStr = not isCategory || isRightType || error errStr

    tyconOk = doTest (GHC.isTyConName oldName) (isConId newName) "Invalid type constructor/class name!"

    dataConOk = doTest (GHC.isDataConName oldName) (isConId newName) "Invalid data constructor name!"

    tyVarOk = doTest (GHC.isTyVarName oldName) (isVarId newName) "Invalid type variable name!"

    oldName' = rdrNameStr
    matchNamesOk
        | {- GHC.isValName oldName || -} GHC.isVarName oldName
        = if isVarId oldName' && not (isVarId newName)
              then error "The new name should be an identifier!"
              else if isOperator oldName' && not (isOperator newName)
                       then error "The new name should be an operator!"
                       else (isVarId oldName' && isVarId newName)
                         || (isOperator oldName' && isOperator newName)
                         || (error $ "Invalid new name!" ++ show ( oldName', newName
                                                                , isVarId oldName'
                                                                , isVarId newName
                                                                , isOperator oldName'
                                                                , isOperator newName ))
        | otherwise = True

    res = tyconOk && dataConOk {- && fieldOk && instanceOk -} && tyVarOk && matchNamesOk

-- EOF
