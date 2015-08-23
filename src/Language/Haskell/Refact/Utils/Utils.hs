{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE UndecidableInstances #-} -- for GHC.DataId

module Language.Haskell.Refact.Utils.Utils
       (
       -- * Managing the GHC / project environment
         getModuleGhc
       , getTargetGhc
       , parseSourceFileGhc
       -- , activateModule
       , getModuleDetails

       -- * The bits that do the work
       , runRefacSession
       , applyRefac
       , refactDone

       , Update(..)
       -- , fileNameToModName
       , fileNameFromModSummary
       , getModuleName
       , clientModsAndFiles
       , serverModsAndFiles

       -- * For testing
       , initGhcSession
       ) where

import Control.Monad.State
import Data.List

import Language.Haskell.GHC.ExactPrint
import Language.Haskell.GHC.ExactPrint.Utils

import qualified Language.Haskell.GhcMod          as GM (Options(..))
import qualified Language.Haskell.GhcMod.Internal as GM (ModulePath(..),GmModuleGraph(..))

import Language.Haskell.Refact.Utils.GhcModuleGraph
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.Types
import Language.Haskell.Refact.Utils.Variables
import System.Directory
import System.FilePath.Posix
import qualified Data.Generics as SYB

import qualified Digraph       as GHC
import qualified GHC           as GHC

import qualified GHC.SYB.Utils as SYB
import qualified Outputable    as GHC

import qualified Data.Map      as Map
import qualified Data.Set      as Set

-- import Debug.Trace

-- ---------------------------------------------------------------------
{-
-- | From file name to module name.
fileNameToModName :: FilePath -> RefactGhc GHC.ModuleName
fileNameToModName fileName = do
  mm <- getModuleMaybe fileName
  case mm of
    Nothing -> error $ "Can't find module name"
    Just ms ->  return $ GHC.moduleName $ GHC.ms_mod ms
-}
-- ---------------------------------------------------------------------
{-
getModuleMaybe :: FilePath -> RefactGhc (Maybe GHC.ModSummary)
getModuleMaybe fileName = do
  cfileName <- liftIO $ canonicalizePath fileName
  logm $ "getModuleMaybe for (fileName,cfileName):" ++ show (fileName,cfileName)

  graphs <- gets rsGraph
  currentTgt <- gets rsCurrentTarget
  logm $ "getModuleMaybe " ++ show fileName ++ ":" ++ show (length graphs,currentTgt)

  let cgraph = concatMap (\(_,cg) -> cg) graphs
  -- graph <- GHC.getModuleGraph
  -- cgraph <- liftIO $ canonicalizeGraph graph

  logm $ "getModuleMaybe: [mfn]=" ++ show (map (\(mfn,_ms) -> mfn) cgraph)

  let mm = filter (\(mfn,_ms) -> mfn == Just cfileName) cgraph
  logm $ "getModuleMaybe: mm=" ++ show mm

  case mm of
    [] -> return Nothing
    _ -> do
      let (_mfn,ms) = (ghead "getModuleMaybe" mm)
      -- activateModule (fromJust mfn,ms)
      return $ Just ms
-}
-- ---------------------------------------------------------------------

-- | Extract the module name from the parsed source, if there is one
getModuleName :: GHC.ParsedSource -> Maybe (GHC.ModuleName,String)
getModuleName (GHC.L _ modn) =
  case (GHC.hsmodName modn) of
    Nothing -> Nothing
    Just (GHC.L _ modname) -> Just $ (modname,GHC.moduleNameString modname)

-- ---------------------------------------------------------------------

getTargetGhc :: TargetModule -> RefactGhc ()
getTargetGhc (GM.ModulePath _mn fp) = getModuleGhc fp

-- ---------------------------------------------------------------------

-- | Once the module graph has been loaded, load the given module into
-- the RefactGhc monad
-- TODO: rename this to something like loadModuleGhc
getModuleGhc ::
  FilePath -> RefactGhc ()
getModuleGhc targetFile = do
  -- TODO: consult cached store of multiple module graphs, one for
  --       each main file.
  {-
  mTarget <- identifyTargetModule targetFile
  logm $ "getModuleGhc:mTarget=" ++ show mTarget
  case mTarget of
    Nothing -> return ()
    Just tm -> do
      void $ activateModule tm
      return ()
  -}

  parseSourceFileGhc targetFile
  {-
  mm <- getModuleMaybe targetFile
  case mm of
    Just ms -> getModuleDetails ms
    Nothing -> parseSourceFileGhc targetFile
  -}

-- ---------------------------------------------------------------------
{-
identifyTargetModule :: FilePath -> RefactGhc (Maybe TargetModule)
identifyTargetModule targetFile = do
  currentDirectory <- liftIO getCurrentDirectory
  target1 <- liftIO $ canonicalizePath targetFile
  target2 <- liftIO $ canonicalizePath (combine currentDirectory targetFile)
  logm $ "identifyTargetModule:(targetFile,target1,target2)=" ++ show (targetFile,target1,target2)
  -- graphs <- gets rsModuleGraph
  graphs <- gets rsGraph
  -- let graphs = concatMap (\(_,cg) -> cg) cgraphs

  logm $ "identifyTargetModule:graphs=" ++ show graphs

  let ff = catMaybes $ map (findInTarget target1 target2) graphs
  logm $ "identifyTargetModule:ff=" ++ show ff
  case ff of
    [] -> return Nothing
    ms -> return (Just (ghead ("identifyTargetModule:" ++ (show ms)) ms))
-}
-- ---------------------------------------------------------------------
{-
findInTarget :: FilePath -> FilePath -> ([FilePath],[(Maybe FilePath,GHC.ModSummary)])
             -> Maybe TargetModule
findInTarget f1 f2 (fps,graph) = r'
  where
    -- We also need to process the case where it is a main file for an exe.
    re :: Maybe TargetModule
    re = case fps of
      [x] -> re' -- single target, could be an exe
       where
         re' = case filter isMainModSummary graph of
           [] -> Nothing
           ms -> if x == f1 || x == f2 then Just (fps,ghead "findInTarget" ms)
                                      else Nothing
      _  -> Nothing
    isMainModSummary (_,ms) = (show $ GHC.ms_mod ms) == "Main"

    r = case filter (compModFiles f1 f2) graph of
          [] -> Nothing
          ms -> Just (fps,ghead "findInTarget.2" ms)
    compModFiles :: FilePath-> FilePath -> (Maybe FilePath,GHC.ModSummary) -> Bool
    compModFiles fileName1 fileName2 (mfp,ms) =
      case GHC.ml_hs_file $ GHC.ms_location ms of
        Nothing -> False
        Just fn -> fn == fileName1 || fn == fileName2
                   || mfp == Just fileName1
                   || mfp == Just fileName2

    r' = listToMaybe $ catMaybes [r,re]
-}
-- ---------------------------------------------------------------------

-- | In the existing GHC session, put the requested TypeCheckedModule
-- into the RefactGhc Monad, after ensuring that its originating
-- target is the currently loaded one
{-
activateModule :: TargetModule -> RefactGhc GHC.ModSummary
activateModule tm@(target, (mfp,modSum)) = do
  logm $ "activateModule:" ++ show (target,mfp,GHC.ms_mod modSum)
  newModSum <- ensureTargetLoaded tm
  getModuleDetails newModSum
  return newModSum
-}
-- ---------------------------------------------------------------------

-- | In the existing GHC session, put the requested TypeCheckedModule
-- into the RefactGhc monad

-- TODO: rename this function, it is not clear in a refactoring what
-- it does
getModuleDetails :: GHC.ModSummary -> RefactGhc ()
getModuleDetails modSum = do
  logm $ "getModuleDetails:modSum=" ++ show modSum
  p <- GHC.parseModule modSum
  t <- GHC.typecheckModule p

  logm $ "getModuleDetails:setting context.."
  -- TODO:AZ: reinstate this, else inscope queries will fail. Or is there a better way to do those?
  setGhcContext modSum
  logm $ "getModuleDetails:context set"

  (mfp,_modSum) <- canonicalizeModSummary modSum
  newTargetModule <- case mfp of
    Nothing -> error $ "HaRe:no file path for module:" ++ showGhc modSum
    Just fp -> return $ GM.ModulePath (GHC.moduleName $ GHC.ms_mod modSum) fp

  oldTargetModule <- gets rsCurrentTarget
  let
    putModule = do
      putParsedModule t
      settings <- get
      put $ settings { rsCurrentTarget = Just newTargetModule }

  mtm <- gets rsModule
  case mtm of
    Just tm -> if ((rsStreamModified tm == RefacUnmodifed)
                  && oldTargetModule == Just newTargetModule)
                 then do
                   logm $ "getModuleDetails:not calling putParsedModule for targetModule=" ++ show newTargetModule
                   return ()
                 else if rsStreamModified tm == RefacUnmodifed
                        then putModule
                        else error $ "getModuleDetails: trying to load a module without finishing with active one."

    Nothing -> putModule

  return ()

-- ---------------------------------------------------------------------

-- | Parse a single source file into a GHC session
-- parseSourceFileGhc :: FilePath -> RefactGhc ()
parseSourceFileGhc targetFile = do
    {-
      -- currentDir <- liftIO getCurrentDirectory
      -- logm $ "parseSourceFileGhc:currentDir=" ++ currentDir
      logm $ "parseSourceFileGhc:about to loadModuleGraphGhc for" ++ (show targetFile)
      loadModuleGraphGhc (Just [targetFile])
      logm $ "parseSourceFileGhc:loadModuleGraphGhc done"

      mm <- getModuleMaybe targetFile
      case mm of
        Nothing -> error $ "HaRe:unexpected error parsing " ++ targetFile
        Just modSum -> getModuleDetails modSum
  -}
  opts <- getTargetGhcOptions [Left targetFile]
  loadTarget opts [targetFile]
  graph  <- GHC.getModuleGraph
  cgraph <- canonicalizeGraph graph
  cfileName <- liftIO $ canonicalizePath targetFile
  let mm = filter (\(mfn,_ms) -> mfn == Just cfileName) cgraph
  case mm of
    [(_,modSum)] -> getModuleDetails modSum
    _ -> error $ "HaRe:unexpected error parsing " ++ targetFile

-- ---------------------------------------------------------------------

-- | Manage a whole refactor session. Initialise the monad, load the
-- whole project if required, and then apply the individual
-- refactorings, and write out the resulting files.
--
-- It is intended that this forms the umbrella function, in which
-- applyRefac is called
--
runRefacSession ::
       RefactSettings
    -> GM.Options                   -- ^ ghc-mod options
    -> Targets                      -- ^ files/modules to load for the session
    -> RefactGhc [ApplyRefacResult] -- ^ The computation doing the
                                    -- refactoring. Normally created
                                    -- via 'applyRefac'
    -> IO [FilePath]
runRefacSession settings opt targets comp = do
  let
    initialState = RefSt
        { rsSettings      = settings
        , rsUniqState     = 1
        , rsSrcSpanCol    = 1
        , rsFlags         = RefFlags False
        , rsStorage       = StorageNone
        -- , rsGraph         = []
        , rsCabalGraph    = []
        , rsModuleGraph   = []
        , rsCurrentTarget = Nothing
        , rsModule        = Nothing
        }

    comp' = initGhcSession targets >> comp
    -- comp' = gmSetLogLevel GmError >> comp
  (refactoredMods,_s) <- runRefactGhc comp' targets initialState opt

  let verbosity = rsetVerboseLevel (rsSettings initialState)
  writeRefactoredFiles verbosity refactoredMods
  return $ modifiedFiles refactoredMods

-- ---------------------------------------------------------------------
-- TODO: the module should be stored in the state, and returned if it
-- has been modified in a prior refactoring, instead of being parsed
-- afresh each time.

-- | Apply a refactoring (or part of a refactoring) to a single module
applyRefac
    :: RefactGhc a       -- ^ The refactoring
    -> RefacSource        -- ^ where to get the module and toks
    -> RefactGhc (ApplyRefacResult,a)

applyRefac refac source = do

    -- TODO: currently a temporary, poor man's surrounding state
    -- management: store state now, set it to fresh, run refac, then
    -- restore the state. Fix this to store the modules in some kind of cache.

    fileName <- case source of
         RSFile fname    -> do getModuleGhc fname
                               return fname
         RSMod  ms       -> do getModuleGhc $ fileNameFromModSummary ms
                               return $ fileNameFromModSummary ms
         RSAlreadyLoaded -> do mfn <- getRefactFileName
                               case mfn of
                                 Just fname -> return fname
                                 Nothing -> error "applyRefac RSAlreadyLoaded: nothing loaded"

    res <- refac  -- Run the refactoring, updating the state as required

    -- mod'   <- getRefactRenamed
    mod'   <- getRefactParsed
    -- toks'  <- fetchToksFinal
    -- let toks' = []
    -- pprVal <- fetchPprFinal
    anns <- fetchAnnsFinal
    m    <- getRefactStreamModified

    -- Clear the refactoring state
    clearParsedModule

    return (((fileName,m),(anns, mod')),res)


-- ---------------------------------------------------------------------

-- |Returns True if any of the results has its modified flag set
refactDone :: [ApplyRefacResult] -> Bool
refactDone rs = any (\((_,d),_) -> d == RefacModified) rs

-- ---------------------------------------------------------------------

modifiedFiles :: [ApplyRefacResult] -> [String]
modifiedFiles refactResult = map (\((s,_),_) -> s)
                           $ filter (\((_,b),_) -> b == RefacModified) refactResult

-- ---------------------------------------------------------------------

-- | Initialise the GHC session, when starting a refactoring.
--   This should never be called directly.
initGhcSession :: Targets -> RefactGhc ()
initGhcSession tgts = do
    {-
    settings <- getRefacSettings
    df <- GHC.getSessionDynFlags
    let df2 = GHC.gopt_set df GHC.Opt_KeepRawTokenStream
    void $ GHC.setSessionDynFlags df2

    -- liftIO $ putStrLn "initGhcSession:entered (IO)"
    logm $ "initGhcSession:entered2"
    cr <- cradle
    logm $ "initGhcSession:cr=" ++ show cr
    case cradleCabalFile cr of
      Just _ -> do
        (cabalGraph,targets) <- cabalAllTargets cr
        logm $ "initGhcSession:targets=" ++ show targets

        -- TODO: Cannot load multiple main modules, must try to load
        -- each main module and retrieve its module graph, and then
        -- set the targets to this superset.

        let targets' = getEnabledTargets settings targets

        case targets' of
          ([],[]) -> return ()
          (libTgts,exeTgts) -> do
                     -- liftIO $ warningM "HaRe" $ "initGhcSession:tgts=" ++ (show (libTgts,exeTgts))
                     logm $ "initGhcSession:(libTgts,exeTgts)=" ++ (show (libTgts,exeTgts))
                     -- setTargetFiles tgts
                     -- void $ GHC.load GHC.LoadAllTargets

                     -- AZ: carry on here, store cabalGraph instead of loadModuleGraphGhc
                     mapM_ loadModuleGraphGhc $ map (\t -> Just [t]) exeTgts

                     -- Load the library last, most likely in context
                     case libTgts of
                       [] -> return ()
                       _ -> loadModuleGraphGhc (Just libTgts)

                     -- moduleGraph <- gets rsModuleGraph
                     -- logm $ "initGhcSession:rsModuleGraph=" ++ (show moduleGraph)

      Nothing -> do
          let maybeMainFile = rsetMainFile settings
          loadModuleGraphGhc maybeMainFile
          return()
    -}
    -- load the first target is specified
    case tgts of
      [] -> return ()
      _ -> case head tgts of
             Left filename -> getModuleGhc filename
             Right modname -> getModuleGhc (GHC.moduleNameString modname)

    return ()

-- ---------------------------------------------------------------------
{-
getEnabledTargets :: RefactSettings -> ([FilePath],[FilePath],[FilePath],[FilePath]) -> ([FilePath],[FilePath])
getEnabledTargets settings (libt,exet,testt,bencht) = (targetsLib,targetsExe)
  where
    (libEnabled, exeEnabled, testEnabled, benchEnabled) = rsetEnabledTargets settings
    targetsLib = on libEnabled libt
    targetsExe = on exeEnabled exet
              ++ on testEnabled testt
              ++ on benchEnabled bencht

    on flag xs = if flag then xs else []
-}
-- ---------------------------------------------------------------------

class (SYB.Data t, SYB.Data t1) => Update t t1 where

  -- | Update the occurrence of one syntax phrase in a given scope by
  -- another syntax phrase of the same type
  update::  t     -- ^ The syntax phrase to be updated.
         -> t     -- ^ The new syntax phrase.
         -> t1    -- ^ The contex where the old syntax phrase occurs.
         -> RefactGhc t1  -- ^ The result.

instance (SYB.Data t, GHC.OutputableBndr n, GHC.DataId n)
  => Update (GHC.Located (GHC.HsExpr n)) t where
    update oldExp newExp t
           = SYB.everywhereMStaged SYB.Parser (SYB.mkM inExp) t
       where
        inExp (e::GHC.Located (GHC.HsExpr n))
          | sameOccurrence e oldExp
               = do
                    -- drawTokenTree "update Located HsExpr starting" -- ++AZ++
                    -- _ <- updateToks oldExp newExp prettyprint False
                    -- drawTokenTree "update Located HsExpr done" -- ++AZ++

                -- error "update: updated tokens" -- ++AZ++ debug
                    -- TODO: make sure to call syncAST
                    return newExp
          | otherwise = return e

instance (SYB.Data t, GHC.OutputableBndr n, GHC.DataId n)
   => Update (GHC.LPat n) t where
    update oldPat newPat t
           = SYB.everywhereMStaged SYB.Parser (SYB.mkM inPat) t
        where
          inPat (p::GHC.LPat n)
            | sameOccurrence p oldPat
                = do
                     -- _ <- updateToks oldPat newPat prettyprint False
                     -- TODO: make sure to call syncAST
                     return newPat
            | otherwise = return p

instance (SYB.Data t, GHC.OutputableBndr n, GHC.DataId n)
  => Update (GHC.LHsType n) t where
     update oldTy newTy t
           = SYB.everywhereMStaged SYB.Parser (SYB.mkM inTyp) t
        where
          inTyp (t'::GHC.LHsType n)
            | sameOccurrence t' oldTy
                = do
                     -- _ <- updateToks oldTy newTy prettyprint False
                     -- TODO: make sure to call syncAST
                     return newTy
            | otherwise = return t'

instance (SYB.Data t, GHC.OutputableBndr n1, GHC.OutputableBndr n2, GHC.DataId n1, GHC.DataId n2)
   => Update (GHC.LHsBindLR n1 n2) t where
       update oldBind newBind t
             = SYB.everywhereMStaged SYB.Parser (SYB.mkM inBind) t
          where
            inBind (t'::GHC.LHsBindLR n1 n2)
              | sameOccurrence t' oldBind
                  = do
                       -- _ <- updateToks oldBind newBind prettyprint False
                       -- TODO: make sure to call syncAST
                       return newBind
              | otherwise = return t'


-- ---------------------------------------------------------------------

-- | Write refactored program source to files.
writeRefactoredFiles ::
  VerboseLevel -> [ApplyRefacResult] -> IO ()
writeRefactoredFiles verbosity files
  = do let filesModified = filter (\((_f,m),_) -> m == RefacModified) files

       -- TODO: restore the history function
       -- ++AZ++ PFE0.addToHistory isSubRefactor (map (fst.fst) filesModified)
       sequence_ (map modifyFile filesModified)
       -- mapM_ writeTestDataForFile files   -- This should be removed for the release version.

     where
       modifyFile ((fileName,_),(ann,parsed)) = do

           let source = exactPrint parsed ann
           let (baseFileName,ext) = splitExtension fileName
           seq (length source) (writeFile (baseFileName ++ ".refactored" ++ ext) source)

           when (verbosity == Debug) $
             do
               writeFile (fileName ++ ".parsed_out") (showGhc parsed)
               writeFile (fileName ++ ".AST_out")   ((showGhc parsed) ++
                      "\n\n----------------------\n\n" ++
                      -- (SYB.showData SYB.Parser 0 parsed) ++
                      (showAnnData ann 0 parsed) ++
                      "\n\n----------------------\n\n" ++
                      (showGhc ann) ++
                      "\n\n----------------------\n\n"
--                      (showAnnData (organiseAnns ann) 0 parsed)
                      )
-- ---------------------------------------------------------------------

-- | Return the client modules and file names. The client modules of
-- module, say m, are those modules which directly or indirectly
-- import module m.

-- clientModsAndFiles :: GHC.ModuleName -> RefactGhc [TargetModule]
clientModsAndFiles :: GM.ModulePath -> RefactGhc [TargetModule]
clientModsAndFiles m = do
  mgs <- cabalModuleGraphs
  -- mgs is [Map ModulePath (Set ModulePath)]
  --  where eack key imports the corresponding set.
  -- There are no cycles

  -- We need the reverse of this, the transitive set of values where if the
  -- ModulePath is in the set, then the key is of interest.

  -- So
  --  Flatten the module graph, reverse the dependencies, then rebuild it
  let
    flattenSwap (GM.GmModuleGraph mg)
      = concatMap (\(k,vs) -> map (\v -> (v,Set.singleton k)) (Set.elems vs)) $ Map.toList mg
    transposed = mgs'
      where
        kvs = concatMap flattenSwap mgs
        mgs' = foldl' (\acc (k,v) -> Map.insertWith Set.union k v acc) Map.empty kvs

    -- transposed is a map from each module to those that import it. We need the
    -- transitive closure of all the importers of the given module.
    check acc k =
      case Map.lookup k transposed of
        Nothing -> (acc,[])
        Just s -> (Set.union acc s, Set.toList $ s Set.\\ acc)
    go (acc,[]) = acc
    go (acc,c:s) = go (acc',s')
      where
        (acc',q) = check acc c
        s' = nub (q ++ s)

    r = go (Set.empty, [m])
  return $ Set.toList r

{-
-- TODO: deal with an anonymous main module, by taking Maybe GHC.ModuleName
clientModsAndFiles :: GHC.ModuleName -> RefactGhc [TargetModule]
clientModsAndFiles m = do
  modsum <- GHC.getModSummary m

  -- ms' <- GHC.getModuleGraph
  ms' <- gets rsModuleGraph
  -- target <- gets rsCurrentTarget

  let getClients ms = clientMods
        where
          mg = getModulesAsGraph False ms Nothing
          rg = GHC.transposeG mg
          maybeModNode = find (\(msum',_,_) -> mycomp msum' modsum) (GHC.verticesG rg)
          clientMods = case maybeModNode of
                         Nothing -> []
                         Just modNode ->
                           filter (\msum' -> not (mycomp msum' modsum))
                           $ map summaryNodeSummary $ GHC.reachableG rg modNode

  let clients = concatMap (\(f,mg) -> zip (repeat f) (getClients mg)) ms'
  -- Need to strip out duplicates, based on the snd of the tuple
      clients' = nubBy cc clients
      cc (_,mg1) (_,mg2)
        = if (show $ GHC.ms_mod mg1) == "Main" || (show $ GHC.ms_mod mg2) == "Main"
            then False
            else mycomp mg1 mg2
      cms (fps,ms) = do
        -- ms1 <- canonicalizeModSummary ms
        -- return (fps,ms1)
        let ms1 = GHC.moduleName $ GHC.ms_mod ms
        return (GM.ModulePath ms1 (ghead "clientModsAndFiles" fps))
  logm $ "clientModsAndFiles:clients=" ++ show clients
  logm $ "clientModsAndFiles:clients'=" ++ show clients'
  clients'' <- mapM cms clients'
  return clients''
-}

-- TODO : find decent name and place for this.
mycomp :: GHC.ModSummary -> GHC.ModSummary -> Bool
mycomp ms1 ms2 = (GHC.ms_mod ms1) == (GHC.ms_mod ms2)


-- ---------------------------------------------------------------------

-- | Return the server module and file names. The server modules of
-- module, say m, are those modules which are directly or indirectly
-- imported by module m. This can only be called in a live GHC session
-- TODO: make sure this works with multiple targets. Is that needed? No?
serverModsAndFiles
  :: GHC.GhcMonad m => GHC.ModuleName -> m [GHC.ModSummary]
serverModsAndFiles m = do
  ms <- GHC.getModuleGraph
  modsum <- GHC.getModSummary m
  let mg = getModulesAsGraph False ms Nothing
      modNode = gfromJust "serverModsAndFiles" $ find (\(msum',_,_) -> mycomp msum' modsum) (GHC.verticesG mg)
      serverMods = filter (\msum' -> not (mycomp msum' modsum))
                 $ map summaryNodeSummary $ GHC.reachableG mg modNode

  return serverMods

