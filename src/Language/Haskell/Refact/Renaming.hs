module Language.Haskell.Refact.Renaming(rename) where

-- import qualified Data.Generics.Schemes as SYB
import qualified Data.Generics.Aliases as SYB
import qualified GHC.SYB.Utils         as SYB

import qualified GHC
import qualified Name                  as GHC
import qualified RdrName               as GHC

import Control.Monad
import Data.List
import Exception

import Language.Haskell.GhcMod
import Language.Haskell.Refact.Utils.Utils
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

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
rename :: RefactSettings -> Cradle
   -> FilePath -> String -> SimpPos
   -> IO [FilePath]
rename settings cradle fileName newName (row,col) =
  runRefacSession settings cradle (comp fileName newName (row,col))

-- | Body of the refactoring
comp :: FilePath -> String -> SimpPos -> RefactGhc [ApplyRefacResult]
comp fileName newName (row,col) = do
    logm $ "Renaming.comp: (fileName,newName,(row,col))=" ++ (show (fileName,newName,(row,col)))
    getModuleGhc fileName
    renamed <- getRefactRenamed
    parsed  <- getRefactParsed
    -- logm $ "comp:renamed=" ++ (SYB.showData SYB.Renamer 0 renamed) -- ++AZ++
    -- logm $ "comp:parsed=" ++ (SYB.showData SYB.Parser 0 parsed) -- ++AZ++

    modu <- getModule
    -- let (Just (modName,_)) = getModuleName parsed
    let modName = case (getModuleName parsed) of
                    Just (mn,_) -> mn
                    Nothing -> GHC.mkModuleName "Main"
    let maybePn = locToName (row, col) renamed
    logm $ "Renamed.comp:maybePn=" ++ (showGhc maybePn) -- ++AZ++
    case maybePn of
        Just pn@(GHC.L _ n) -> do
           logm $ "Renaming:(n,modu)=" ++ (showGhc (n,modu))
           -- let (GHC.L _ rdrName') = gfromJust "Renaming.comp.1" $ locToRdrName (row, col) parsed
           -- logm $ "Renaming.comp:rdrName'=" ++ (showGhc rdrName')

           let (GHC.L _ rdrName) = gfromJust "Renaming.comp.2" $ locToRdrName (row, col) parsed
           let rdrNameStr = GHC.occNameString $ GHC.rdrNameOcc rdrName
           logm $ "Renaming: rdrName=" ++ (SYB.showData SYB.Parser 0 rdrName)
           logm $ "Renaming: occname rdrName=" ++ (show $ GHC.occNameString $ GHC.rdrNameOcc rdrName)

           unless (nameToString n /= newName) $ error "The new name is same as the old name"
           unless (isValidNewName n rdrNameStr newName) $ error $ "Invalid new name:" ++ newName ++ "!"


           logm $ "Renaming.comp: before GHC.nameModule,n=" ++ (showGhc n)
           -- let defineMod = GHC.moduleName $ GHC.nameModule n

           let defineMod = case GHC.nameModule_maybe n of
                            Just mn -> GHC.moduleName mn
                            Nothing -> modName

           -- TODO: why do we have this restriction?
           unless (defineMod == modName ) ( error ("This identifier is defined in module " ++ (show defineMod) ++
                                         ", please do renaming in that module!"))
           -- logm $ "Renaming.comp:(isMainModule modu,pn)=" ++ (showGhc (isMainModule modu,pn))
           if isMainModule modu && (showGhc pn) == "Main.main"
             then error ("The 'main' function defined in a 'Main' module should not be renamed!")
             else do
               logm $ "Renaming.comp: not main module"
               newNameGhc <- mkNewGhcName (Just modu) newName
               (refactoredMod,nIsExported) <- applyRefac (doRenaming pn rdrNameStr newName newNameGhc modName) RSAlreadyLoaded
               logm $ "Renaming:nIsExported=" ++ (show nIsExported)
               if nIsExported  --no matter whether this pn is used or not.
                   then do clients <- clientModsAndFiles modName
                           logm ("Renaming: clients=" ++ (showGhc clients)) -- ++AZ++ debug
                           refactoredClients <- mapM (renameInClientMod n newName newNameGhc) clients
                           return $ refactoredMod:(concat refactoredClients)
                   else  return [refactoredMod]
        Nothing -> error "Invalid cursor position!"

{- original

rename args
 = do let fileName  = args!!0
          newName   = args!!1
          row       = read (args!!2)::Int
          col       = read (args!!3)::Int

      modName <- fileNameToModName fileName
      AbstractIO.putStrLn $ show modName
      (inscps, exps, mod,tokList) <- parseSourceFile fileName


      --AbstractIO.putStrLn x
   --   i <- lift $ ghcTypeCheck "Fish.hs"
   --   AbstractIO.putStrLn i
      let pnt       = locToPNT fileName (row, col) mod
          defineMod = if isTopLevelPN (pNTtoPN pnt)
                           then (fromJust (hasModName pnt))
                           else modName

      unless (pnt /= defaultPNT  && isValidNewName pnt newName)
         $ error "Invalid cursor position or the new name is invalid!\n"
      unless (pNTtoName pnt/=newName) $ error "The new name is same as the old name" 
      unless (defineMod == modName ) ( error ("This idenifier is defined in module " ++ modNameToStr defineMod ++ 
                                             ", please do renaming in that module!"))
      if isMainModule modName && pNTtoName pnt == "main"
          then error ("The 'main' function defined in a 'Main' module should not be renamed!")
          else do (mod',((tokList',modified),_))<-doRenaming pnt newName modName mod inscps exps
                                                  ((tokList,unmodified),fileName)
                  if isExported pnt exps  --no matter whether this pn is used or not.
                     then do clients<-clientModsAndFiles modName  --returns [(module name ,filename)] 
                             refactoredClients <- mapM (renameInClientMod pnt newName) clients                           
                             writeRefactoredFiles False $ ((fileName,modified),(tokList',mod')):refactoredClients
                     else writeRefactoredFiles False [((fileName,modified), (tokList',mod'))]
-}


-- |Actually do the renaming, split into the various things that can
-- be renamed. Returns True if the name is exported
doRenaming :: GHC.Located GHC.Name -> String -> String -> GHC.Name -> GHC.ModuleName -> RefactGhc Bool
-- doRenaming pn@(GHC.L _ n) rdrNameStr newNameStr = do
--   logm $ "doRenaming:(pn,rdrNameStr,newNameStr) = " ++ (showGhc (pn,rdrNameStr,newNameStr))
--   error "fubar"
{-
doRenaming pn@(GHC.L _ n) newNameStr = do
  logm $ "doRenaming:(pn,newNameStr) = " ++ (showGhc (pn,newNameStr))
  renamed <- getRefactRenamed
  logm $ "doRenaming:renamed=" ++ (SYB.showData SYB.Renamer 0 renamed) -- ++AZ++
  newName <- mkNewGhcName newNameStr
  renamePN n newName True renamed
  return ()
-}

{-
---------Rename a type constructor--------------------------
doRenaming oldPNT@(PNT (PN _ (G _ _ _)) (Type _) _) newName modName mod inscps exps env
  =doRenaming' oldPNT newName  mod mod (hsTypeConstrsAndClasses modName) exps env

---------Rename a class name---------------------------------
doRenaming oldPNT@(PNT _ (Class _ _) _) newName modName mod inscps exps env
  =doRenaming' oldPNT newName  mod mod (hsTypeConstrsAndClasses modName) exps env 

---------Rename a data structure-----------------------------
doRenaming oldPNT@(PNT _ (ConstrOf _  _) _) newName modName mod inscps exps env
  =doRenaming' oldPNT newName mod mod (hsDataConstrs modName)  exps env

---------Rename an instance name-----------------------------
doRenaming oldPNT@(PNT _ (MethodOf i _  _) _) newName modName mod inscps exps env -- Claus
   =runStateT (renameTopLevelVarName oldPNT newName modName inscps  exps mod True True) env

---------Rename a type variable name------------------------------
doRenaming oldPNT@(PNT oldPN@(PN i (S loc)) (Type _) _) newName modName mod inscps exps env
   = do let (before, parent, after)=divideDecls (hsDecls mod) oldPNT
        (parent',toks)<-doRenaming' oldPNT newName parent mod  hsTypeVbls exps  env
        return ((replaceDecls mod (before++parent'++after)),toks)
-}

{-
---------Rename a field name -------------------------------------
doRenaming pn@(GHC.L _ n) newNameStr
  | isFieldName n = do
  logm $ "doRenaming:fieldName=" ++ (showGhc n)
-}
{- old
doRenaming oldPNT@(PNT _ (FieldOf con typeInfo) _) newName modName mod inscps exps env 
  =do let (before,parent,after)=divideDecls (hsDecls mod) oldPNT
          siblingNames=siblingFieldNames oldPNT
      (f',d') <- hsFDsFromInside (before++after)
      if elem newName (siblingNames ++ map pNtoName d')
        then error("Name '"++newName++"'  already existed\n")
        else if elem newName $ fieldNames oldPNT
               then runStateT (renameTopLevelVarName oldPNT newName modName inscps exps mod False False) env
               else runStateT (renameTopLevelVarName oldPNT newName modName inscps exps mod False True) env
-}


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
  -- somewhereMStagedBu SYB.Renamer (SYB.mkM renameInMod
  void $ everywhereMStaged SYB.Renamer (SYB.mkM renameInMod
                                 ) renamed
  logm $ "doRenaming done"
  nIsExported <- isExported oldn
  return nIsExported
   where
     -- 1. The name is declared in a module(top level name)
     -- renameInMod (mod::HsModuleP)
     renameInMod :: GHC.RenamedSource -> RefactGhc GHC.RenamedSource
     renameInMod ren
        -- was | isDeclaredIn oldn ren = do
        | True = do
           logm $ "renameInMod"
           renameTopLevelVarName oldn newNameStr newNameGhc modName ren True True
     -- renameInMod _ren = mzero

{- original
doRenaming oldPNT@(PNT oldPN Value loc) newName modName mod inscps exps env
 = runStateT (applyTP (once_buTP (failTP `adhocTP` renameInMod
                             `adhocTP` renameInMatch
                             `adhocTP` renameInPattern
                             `adhocTP` renameInExp
                             `adhocTP` renameInAlt
                             `adhocTP` renameInStmts)) mod) env
   where
     -- 1. The name is declared in a module(top level name)
     renameInMod (mod::HsModuleP)
        |isDeclaredIn oldPN mod=renameTopLevelVarName oldPNT newName modName inscps exps mod True True
     renameInMod mod=mzero

     -- 2. The name is declared in a match
     renameInMatch (match::HsMatchP)
        |isDeclaredIn oldPN match=renameLocalVarName oldPN newName match
     renameInMatch match=mzero

     -- 3. The name is declared in a pattern binding.
     renameInPattern (pat:: HsDeclP)
        |isDeclaredIn oldPN pat=renameLocalVarName oldPN newName pat
     renameInPattern pat=mzero

     --4.The name is declared in a expression
     renameInExp (exp::HsExpP)
       |isDeclaredIn oldPN exp=renameLocalVarName oldPN newName exp
     renameInExp exp=mzero

     --5.The name is declared in a case alternative
     renameInAlt (alt::HsAltP)
       |isDeclaredIn oldPN alt=renameLocalVarName oldPN newName alt
     renameInAlt alt=mzero

     --6: The name is declared in a statment expression
     renameInStmts (stmts::HsExpP)
       |isDeclaredIn oldPN stmts=renameLocalVarName oldPN newName stmts
     renameInStmts stmts=mzero
-}

{-
doRenaming' :: GHC.Name -> String  -> RefactGhc ()
-- doRenaming' oldPNT@(PNT oldPN _ _) newName parent mod fun exps env
doRenaming' oldPN newName
 = error "undefined doRenaming'"
-}
{-
 = let (f',d')= fun parent
       (f,d)  =((nub.map pNtoName.filter (not.isQualifiedPN)) f', (nub.map pNtoName) d')
   in if elem newName (d \\ [pNtoName oldPN])
         then error("Name '"++newName++"'  already existed\n")
         else if elem newName f
               then error ("The new name will cause ambiguous occurrence problem,"
                           ++" please select another new name or qualify the use of "
                           ++ newName ++ " before renaming!\n")
               else if causeNameClashInExports oldPN newName mod exps
                    then error ("The new name will cause cause conflicting exports, please select another new name!")
                    else runStateT (renamePN oldPN Nothing newName True parent) env 
-}

{- old
doRenaming' oldPNT@(PNT oldPN _ _) newName parent mod fun exps env
 = let (f',d')= fun parent
       (f,d)  =((nub.map pNtoName.filter (not.isQualifiedPN)) f', (nub.map pNtoName) d')
   in if elem newName (d \\ [pNtoName oldPN])
         then error("Name '"++newName++"'  already existed\n")
         else if elem newName f
               then error ("The new name will cause ambiguous occurrence problem,"
                           ++" please select another new name or qualify the use of "
                           ++ newName ++ " before renaming!\n")
               else if causeNameClashInExports oldPN newName mod exps
                    then error ("The new name will cause cause conflicting exports, please select another new name!")
                    else runStateT (renamePN oldPN Nothing newName True parent) env 
-}

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
     -- if elem newNameStr f
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

                                 -- isInScopeUnqual <- isInScopeAndUnqualifiedGhc newName Nothing
                                 isInScopeUnqual <- isInScopeAndUnqualifiedGhc newName (Just newNameGhc)
                                 logm $ "renameTopLevelVarName:after isInScopeUnqual"
                                 logm $ "renameTopLevelVarName:oldPN=" ++ showGhc oldPN
                                 ds <- hsVisibleNames oldPN renamed
                                 logm $ "renameTopLevelVarName:ds computed=" ++ (show ds)
                                 -- '\\[pNtoName oldPN]' handles the case in which the new name is same as the old name   
                                 if existChecking && elem newName ((nub (ds `union` f)) \\[nameToString oldPN])
                                   then error ("Name '"++newName++"'  already existed, or rename '"
                                                ++nameToString oldPN++ "' to '"++newName++
                                                "' will change the program's semantics!\n")
                                   else if exportChecking && isInScopeUnqual -- isInScopeAndUnqualifiedGhc newName Nothing
                                          then do
                                               logm $ "renameTopLevelVarName start..:should have qualified"
                                               void $ renamePN oldPN newNameGhc True True renamed
                                               logm $ "renameTopLevelVarName done:should have qualified"
                                               -- drawTokenTreeDetailed "should be qualified" -- ++AZ++ debug
                                               r' <- getRefactRenamed
                                               return r'
                                          else do
                                               logm $ "renameTopLevelVarName start.."
                                               void $ renamePN oldPN newNameGhc True False renamed
                                               logm $ "renameTopLevelVarName done"
                                               r' <- getRefactRenamed
                                               return r'

{- original
renameTopLevelVarName oldPNT@(PNT oldPN _ _) newName modName inscps exps mod existChecking exportChecking
  =do -- f' contains names imported from other modules;
      -- d' contains the top level names declared in this module;
     (f',d') <- hsFDsFromInside mod
      --filter those qualified free variables in f'
     let (f,d) = ((nub.map pNtoName.filter (not.isQualifiedPN)) f', (nub.map pNtoName) d')
     if elem newName f
       then error ("The new name will cause ambiguous occurrence problem,"
                   ++" please select another new name or qualify the use of ' "
                   ++ newName ++ "' before renaming!\n")  -- Another implementation option is to add the qualifier
                                                         -- to newName automatically.
       else if existChecking && elem newName (d \\ [pNtoName oldPN])  --only check the declared names here.
             then error ("Name '"++newName++"'  already existed\n") --the same name has been declared in this module.
             else if exportChecking && causeNameClashInExports oldPN newName mod exps
                    then error ("The new name will cause  conflicting exports, please select another new name!") 
                    else if exportChecking && causeAmbiguityInExports oldPN  newName inscps mod
                          then error $"The new name will cause ambiguity in the exports of module "++ show modName ++ ", please select another name!"   
                          else do  -- get all of those declared names visible to oldPN at where oldPN is used.
                                 ds<-hsVisibleNames oldPN mod
                                 -- '\\[pNtoName oldPN]' handles the case in which the new name is same as the old name   
                                 if existChecking && elem newName ((nub (ds `union` f)) \\[pNtoName oldPN])
                                   then error ("Name '"++newName++"'  already existed, or rename '"
                                                ++pNtoName oldPN++ "' to '"++newName++
                                                "' will change the program's semantics!\n")
                                   else if exportChecking && isInScopeAndUnqualified newName inscps
                                          then renamePN oldPN (Just modName) newName True mod
                                          else renamePN oldPN  Nothing newName True mod 
-}

{-
renameLocalVarName oldPN newName t
  =do (f,d) <- hsFDNamesFromInside t
      if elem newName (d \\ [pNtoName oldPN])  --only check the declared names here.
        then error ("Name '"++newName++"'  already existed\n")
        else do -- get all of those declared names visible to oldPN at where oldPN is used.
                ds<-hsVisibleNames oldPN t
                -- '\\[pNtoName oldPN]' handles the case in which the new name is same as the old name   
                if elem newName ((nub (ds `union` f)) \\[pNtoName oldPN])
                  then error ("Name '"++newName++"'  already existed, or rename '"
                               ++pNtoName oldPN++ "' to '"++newName++
                              "' will change the program's semantics!\n")
                  else renamePN oldPN Nothing newName True t
-}

renameInClientMod :: GHC.Name -> String -> GHC.Name -> TargetModule
 -> RefactGhc [ApplyRefacResult]
renameInClientMod oldPN newName newNameGhc targetModule@(_,modSummary) = do
      logm $ "renameInClientMod:(oldPN,newNameGhc,modSummary)=" ++ (showGhc (oldPN,newNameGhc,targetModule)) -- ++AZ++
      void $ activateModule targetModule
      {- ++AZ++ debug stuff -}
      names <- ghandle handler (GHC.parseName $ nameToString oldPN)
      nameInfo <- mapM GHC.lookupName names
      logm $ "renameInClientMod: nameInfo=" ++ (showGhc nameInfo)
      {- ++AZ++ debug stuff end -}

      renamed <- getRefactRenamed
      let modName = GHC.moduleName $ GHC.ms_mod modSummary
      -- causeNameClashInExports oldPN newName mod exps
      -- logm $ "renameInClientMod:causeNameClashInExports oldPN modName renamed=" ++ (show $ causeNameClashInExports oldPN modName renamed)

      -- There are two different tests we need to do here
      -- 1. Does the new name clash with some existing name in the
      --    client mod, in which case it must be qualified
      -- 2. Is the new name module imported qualified, and so needs to
      --    be qualified in the replacement, according to the import
      isInScopeUnqual <- isInScopeAndUnqualifiedGhc (nameToString oldPN) Nothing
      isInScopeUnqualNew <- isInScopeAndUnqualifiedGhc newName Nothing
      logm $ "renameInClientMod: (isInScopeAndUnqual,isInScopeUnqualNew)=" ++ (show (isInScopeUnqual,isInScopeUnqualNew)) -- ++AZ++
      -- if  qualifier == []  --this name is not imported, but it maybe used in the import list
      -- if isInScopeUnqual
      if isInScopeUnqualNew
       then
        -- do (mod', ((ts',m),f))<-runStateT (renamePN oldPN Nothing newName True mod) ((ts,unmodified), fileName)
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
     handler:: (GHC.GhcMonad m) => SomeException -> m [GHC.Name]
     handler _ = return []

     refactRenameSimple :: GHC.Name -> String -> GHC.Name -> Bool -> RefactGhc ()
     refactRenameSimple old newStr new useQual = do
       qualifyTopLevelVar newStr
       renamed <- getRefactRenamed
       logm $ "renameInClientMod.refactRename:renamed=" ++ (SYB.showData SYB.Renamer 0 renamed) -- ++AZ++
       void $ renamePN old new True useQual renamed
       return ()

     refactRenameComplex :: GHC.Name -> String -> GHC.Name -> RefactGhc ()
     refactRenameComplex old new newGhc = do
       qualifyTopLevelVar new
       worker old new newGhc

     qualifyTopLevelVar :: String -> RefactGhc ()
     qualifyTopLevelVar new = do
       toQualify <- inScopeNames new
       logm $ "renameInClientMod.qualifyTopLevelVar:new:toQualify=" ++ (show new) ++ ":" ++ (showGhc toQualify)
       -- renamed <- getRefactRenamed
       -- renamePN new new True True renamed
       mapM_ qualifyToplevelName toQualify
       return ()

     worker :: GHC.Name -> String -> GHC.Name -> RefactGhc ()
     worker oldPN' newName' newNameGhc' = do
       logm $ "renameInClientMod.worker"
       renamed <- getRefactRenamed
       isInScopeUnqualNew <- isInScopeAndUnqualifiedGhc newName' Nothing
       vs <- hsVisibleNames oldPN' renamed   --Does this check names other than variable names?
       if elem newName' ((nub vs) \\ [nameToString oldPN'])  || isInScopeUnqualNew
         then void $ renamePN oldPN' newNameGhc' True True renamed --rename to qualified Name
         else void $ renamePN oldPN' newNameGhc' True False renamed -- do not qualify
       return ()

{- original
renameInClientMod pnt@(PNT oldPN _ _) newName (m, fileName)
  =do (inscps, exps ,mod ,ts) <-parseSourceFile fileName
      let qualifier= hsQualifier pnt inscps
      if  qualifier == []  --this name is not imported, but it maybe used in the import list
       then
        do (mod', ((ts',m),f))<-runStateT (renamePN oldPN Nothing newName True mod) ((ts,unmodified), fileName)   
           return ((f,m),(ts',mod'))
       else
         do if causeNameClashInExports oldPN newName mod exps
             then error $"The new name will cause conflicting exports in module "++ show m ++ ", please select another name!"
             else do (mod',((ts',modified),f))<-runStateT (do mod'<-qualifyTopLevelVar newName inscps mod
                                                              worker oldPN newName mod' inscps (head qualifier))
                                                           ((ts,unmodified),fileName)
                     return ((f,modified), (ts',mod'))

  where
     qualifyTopLevelVar name inscps t
       = applyTP(full_tdTP(adhocTP idTP atPnt)) t
        where
           atPnt pnt@(PNT pn ty loc@(N (Just (SrcLoc fileName _  row col))))
              | isTopLevelPNT pnt &&  pNTtoName pnt == name && canBeQualified pnt t 
               = do let qualifier = ghead "qualfyTopLevelVar" $ hsQualifier  pnt inscps                              
                    renamePN pn (Just qualifier) name True pnt
           atPnt x = return x

     worker oldPN newName mod inscps qual
        = do  vs<-hsVisibleNames oldPN mod   --Does this check names other than variable names?
              if elem newName ((nub vs) \\[pNtoName oldPN])  || isInScopeAndUnqualified newName inscps
                 then renamePN oldPN (Just qual) newName True mod  --rename to qualified Name
                 else do renamePN oldPN Nothing newName True mod

---------------------------------------------
-}

causeAmbiguityInExports :: GHC.Name -> GHC.Name -> RefactGhc Bool
causeAmbiguityInExports old newName {- inscps -}  = do
    (GHC.L _ (GHC.HsModule _ exps _imps _decls _ _)) <- getRefactParsed
    isInScopeUnqual <- isInScopeAndUnqualifiedGhc (nameToString old) Nothing
    let usedUnqual = usedWithoutQualR newName exps
    logm $ "causeAmbiguityInExports:(isInScopeUnqual,usedUnqual)" ++ (show (isInScopeUnqual,usedUnqual))
    return (isInScopeUnqual && usedUnqual)

{-
siblingFieldNames (PNT pn (FieldOf con typeInfo) loc)
  = let cons=constructors typeInfo
        orig1 = pNtoLoc pn
        con=filter (\x->elem orig1 (map pNtoLoc (fromMaybe [] (conFields x)))) cons
    in if con==[] then []
                  else (map pNtoName1 (fromMaybe [] (conFields (head con))))\\ [pNtoName pn]
   where
     pNtoLoc (PN _ orig1) = orig1
     pNtoName1 (PN i _) = i

fieldNames  (PNT pn (FieldOf con typeInfo) _)
 =let cons=constructors typeInfo
  in  (nub. map pNtoName) $ concatMap (fromMaybe [].conFields) cons
  where  pNtoName (PN i _) = i
-}

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

   -- classOk = if isClassName oldName && isConId newName
   --            then True
   --            else error "Invalid class name!"

   dataConOk = doTest (GHC.isDataConName oldName)
                      (isConId newName)
                      "Invalid data constructor name!"

   -- fieldOk = doTest (isFieldName oldName)
   --                  (isVarId newName)
   --                  "Invalid field name!"

   -- instanceOk = doTest (isInstanceName oldName)
   --                     (isVarId newName)
   --                     "Invalid class instance name!"

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

   -- res = error $ "isValidNewName:(tyconOk,dataConOk`,fieldOk,instanceOk,tyVarOk,matchNamesOk)=" ++ (show (tyconOk,dataConOk,fieldOk,instanceOk,tyVarOk,matchNamesOk))

{- old
isValidNewName oldName newName
 = case oldName of
        (PNT (PN i (G _ _ _)) (Type _) _) ->if isConId newName then True
                                                               else error "Invalid type constructor name!"  
        (PNT _ (Class _ _) _)               ->if isConId newName then True
                                                               else error "Invalid class name!"
        (PNT _ (ConstrOf _  _) _)         ->if isConId newName then True
                                                               else error "Invalid data constructor name!"

        (PNT _ (FieldOf _ _ ) _ )         ->if isVarId newName then True
                                                               else error "Invalid field name!" 

        (PNT _ (MethodOf i _ _) _)          ->if isVarId newName then True
                                                               else error "Invalid class instance name!"

        (PNT (PN i (S loc)) (Type _) _)   ->if isVarId newName then True
                                                               else error "Invalid type variable name!"

        (PNT oldPN Value loc)
          ->  let oldName' = pNTtoName oldName
              in if isVarId oldName' && not (isVarId newName)
                   then error "The new name should be an identifier!"
                   else if isOperator oldName' && not (isOperator newName)
                          then error "The new name should be an operator!"
                          else if (isVarId oldName' && isVarId newName) ||
                                   (isOperator oldName' && isOperator newName)
                                  then True
                                  else error "Invalid new name!"

-- |Divide a declaration list into three parts (before, parent, after) according to the PNT,
-- where 'parent' is the first decl containing the PNT, 'before' are those decls before 'parent'
-- and 'after' are those decls after 'parent'.

divideDecls::[HsDeclP]->PNT->([HsDeclP],[HsDeclP],[HsDeclP])
divideDecls ds pnt
  = let (before,after)=break (\x->findPNT pnt x) ds
    in if (after/=[])
         then (before, [head after], tail after)
         else (ds,[],[])

-}

