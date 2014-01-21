{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE RankNTypes #-}

module Language.Haskell.Refact.Utils
       (
         sameOccurrence

       -- * Managing the GHC / project environment
       -- , loadModuleGraphGhc
       , getModuleGhc
       , parseSourceFileGhc
       , getModuleDetails

       -- * The bits that do the work
       , runRefacSession
       , applyRefac
       , refactDone
       , ApplyRefacResult
       , RefacSource(..)

       , update
       -- , writeRefactoredFiles
       -- , Refact -- ^ deprecated
       , fileNameToModName
       , fileNameFromModSummary
       , getModuleName
       , clientModsAndFiles
       , serverModsAndFiles
       -- , getCurrentModuleGraph
       -- , sortCurrentModuleGraph

       -- * For testing
       -- , initGhcSession
       -- , prettyprint
       -- , pwd
       -- , cd
       ) where

import Control.Monad.State
import Data.List
import Data.Maybe
import Language.Haskell.GhcMod
import Language.Haskell.Refact.Utils.DualTree
import Language.Haskell.Refact.Utils.GhcBugWorkArounds
import Language.Haskell.Refact.Utils.GhcModuleGraph
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils
import System.Directory

import qualified Digraph       as GHC
import qualified FastString    as GHC
import qualified GHC
import qualified Outputable    as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

-- import Debug.Trace

-- ---------------------------------------------------------------------

-- | From file name to module name.
fileNameToModName :: FilePath -> RefactGhc GHC.ModuleName
fileNameToModName fileName = do
{-
  graph <- GHC.getModuleGraph
  cgraph <- liftIO $ canonicalizeGraph graph
  cfileName <- liftIO $ canonicalizePath fileName

  let mm = filter (\(mfn,_ms) -> mfn == Just cfileName) cgraph

  -- let mm = filter (\(mfn,_ms) -> mfn == Just fileName) $
  --       map (\m -> (GHC.ml_hs_file $ GHC.ms_location m, m)) graph

  case mm of
    [] -> error $ "Can't find module name"
    _ ->  return $ GHC.moduleName $ GHC.ms_mod $ snd $ head mm
-}
  mm <- getModuleMaybe fileName
  case mm of
    Nothing -> error $ "Can't find module name"
    Just ms ->  return $ GHC.moduleName $ GHC.ms_mod ms

-- ---------------------------------------------------------------------

getModuleMaybe :: FilePath -> RefactGhc (Maybe GHC.ModSummary)
getModuleMaybe fileName = do
  cfileName <- liftIO $ canonicalizePath fileName

  graphs <- gets rsGraph
  logm $ "getModuleMaybe " ++ show fileName ++ ":" ++ show (length graphs)

  let cgraph = concatMap (\(_,cg) -> cg) graphs
  -- graph <- GHC.getModuleGraph
  -- cgraph <- liftIO $ canonicalizeGraph graph

  let mm = filter (\(mfn,_ms) -> mfn == Just cfileName) cgraph

  case mm of
    [] -> return Nothing
    _ -> return $ Just $ snd (ghead "getModuleMaybe" mm)

-- ---------------------------------------------------------------------

-- | Extract the module name from the parsed source, if there is one
getModuleName :: GHC.ParsedSource -> Maybe (GHC.ModuleName,String)
getModuleName (GHC.L _ modn) =
  case (GHC.hsmodName modn) of
    Nothing -> Nothing
    Just (GHC.L _ modname) -> Just $ (modname,GHC.moduleNameString modname)

-- ---------------------------------------------------------------------

-- | Once the module graph has been loaded, load the given module into
-- the RefactGhc monad
-- TODO: relax the equality test, if the file is loaded via cabal it
-- may have a full filesystem path.
getModuleGhc ::
  FilePath -> RefactGhc ()
getModuleGhc targetFile = do
{-
  graph <- GHC.getModuleGraph

  let mm = filter (\(mfn,_ms) -> mfn == Just targetFile) $
       map (\m -> (GHC.ml_hs_file $ GHC.ms_location m, m)) graph

--  let mm = filter (\(mfn,_ms) -> mfn == Just targetFile) $
--       map (\m -> (GHC.ml_hs_file $ GHC.ms_location m, m)) graph

  case mm of
    [(_,modSum)] -> getModuleDetails modSum
    _            -> parseSourceFileGhc targetFile
-}

  -- TODO: consult cached store of multiple module graphs, one for
  --       each main file.
  mm <- getModuleMaybe targetFile
  case mm of
    Just ms -> getModuleDetails ms
    Nothing -> parseSourceFileGhc targetFile

-- ---------------------------------------------------------------------

-- | In the existing GHC session, put the requested TypeCheckedModule
-- into the RefactGhc monad

-- TODO: rename this function, it is not clear in a refactoring what
-- it does
getModuleDetails :: GHC.ModSummary -> RefactGhc ()
getModuleDetails modSum = do
      p <- GHC.parseModule modSum
      t <- GHC.typecheckModule p

      -- GHC.setContext [GHC.IIModule (GHC.moduleName $ GHC.ms_mod modSum)]
      setGhcContext modSum

      -- Use the workaround to get the tokens, the existing one does
      -- not return tokens for CPP processed files.
      -- tokens <- GHC.getRichTokenStream (GHC.ms_mod modSum)
      tokens <- getRichTokenStreamWA (GHC.ms_mod modSum)
      mtm <- gets rsModule
      case mtm of
        Just tm -> if ((rsStreamModified tm == False)
                      && ((GHC.mkFastString $ fileNameFromModSummary modSum) ==
                          (fileNameFromTok $ ghead "getModuleDetails" tokens)))
                     then return ()
                     else error "getModuleDetails: trying to load a module without finishing with active one"

        Nothing -> putParsedModule t tokens

      return ()

-- ---------------------------------------------------------------------

-- | Parse a single source file into a GHC session
parseSourceFileGhc :: FilePath -> RefactGhc ()
parseSourceFileGhc targetFile = do
     {-
      target <- GHC.guessTarget ("*" ++ targetFile) Nothing -- The *
                                     -- is to force interpretation, for inscopes
      GHC.setTargets [target]
      void $ GHC.load GHC.LoadAllTargets -- Loads and compiles, much as calling ghc --make
     -}
      loadModuleGraphGhc (Just targetFile)

      mm <- getModuleMaybe targetFile
      case mm of
        Nothing -> error $ "HaRe:unexpected error parsing " ++ targetFile
        Just modSum -> getModuleDetails modSum

-- ---------------------------------------------------------------------

-- | The result of a refactoring is the file, a flag as to whether it
-- was modified, the updated token stream, and the updated AST
-- type ApplyRefacResult = ((FilePath, Bool), ([Ppr],[PosToken], GHC.RenamedSource))
type ApplyRefacResult = ((FilePath, Bool), ([Line],[PosToken], GHC.RenamedSource))


-- | Manage a whole refactor session. Initialise the monad, load the
-- whole project if required, and then apply the individual
-- refactorings, and write out the resulting files.
--
-- It is intended that this forms the umbrella function, in which
-- applyRefac is called
--
runRefacSession ::
       RefactSettings
    -> Cradle                       -- ^ Identifies the surrounding
                                    -- project
    -> RefactGhc [ApplyRefacResult] -- ^ The computation doing the
                                    -- refactoring. Normally created
                                    -- via 'applyRefac'
    -> IO [FilePath]
runRefacSession settings cradle comp = do
  let
   initialState = RefSt
        { rsSettings = settings
        , rsUniqState = 1
        , rsFlags = RefFlags False
        , rsStorage = StorageNone
        , rsGraph = []
        , rsModule = Nothing
        }

  (refactoredMods,_s) <- runRefactGhc (initGhcSession cradle (rsetImportPaths settings) >>
                                       comp) initialState

  let verbosity = rsetVerboseLevel (rsSettings initialState)
  writeRefactoredFiles verbosity refactoredMods
  return $ modifiedFiles refactoredMods

-- ---------------------------------------------------------------------

data RefacSource = RSFile FilePath
                 | RSMod GHC.ModSummary
                 | RSAlreadyLoaded

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

    mod'   <- getRefactRenamed
    toks'  <- fetchToksFinal
    -- pprVal <- fetchPprFinal
    linesVal <- fetchLinesFinal
    m      <- getRefactStreamModified

    -- Clear the refactoring state
    clearParsedModule

    return (((fileName,m),(linesVal,toks', mod')),res)


-- ---------------------------------------------------------------------

-- |Returns True if any of the results has its modified flag set
refactDone :: [ApplyRefacResult] -> Bool
refactDone rs = any (\((_,d),_) -> d) rs

-- ---------------------------------------------------------------------

{-
applyRefacToClientMods refac fileName
   = do clients <- clientModsAndFiles =<< fileNameToModName fileName
        mapM (applyRefac refac Nothing) (map snd clients)
-}

-- ---------------------------------------------------------------------


modifiedFiles :: [ApplyRefacResult] -> [String]
modifiedFiles refactResult = map (\((s,_),_) -> s)
                           $ filter (\((_,b),_) -> b) refactResult

-- ---------------------------------------------------------------------

fileNameFromModSummary :: GHC.ModSummary -> FilePath
fileNameFromModSummary modSummary = fileName
  where
    -- TODO: what if we are loading a compiled only client and do not
    -- have the original source?
    Just fileName = GHC.ml_hs_file (GHC.ms_location modSummary)

-- ---------------------------------------------------------------------

class (SYB.Data t, SYB.Data t1) => Update t t1 where

  -- | Update the occurrence of one syntax phrase in a given scope by
  -- another syntax phrase of the same type
  update::  t     -- ^ The syntax phrase to be updated.
         -> t     -- ^ The new syntax phrase.
         -> t1    -- ^ The contex where the old syntax phrase occurs.
         -> RefactGhc t1  -- ^ The result.

instance (SYB.Data t, GHC.OutputableBndr n, SYB.Data n) => Update (GHC.Located (GHC.HsExpr n)) t where
    update oldExp newExp t
           = everywhereMStaged SYB.Parser (SYB.mkM inExp) t
       where
        inExp (e::GHC.Located (GHC.HsExpr n))
          | sameOccurrence e oldExp
               = do
                    drawTokenTree "update Located HsExpr starting" -- ++AZ++
                    _ <- updateToks oldExp newExp prettyprint False
                    drawTokenTree "update Located HsExpr done" -- ++AZ++

                -- error "update: updated tokens" -- ++AZ++ debug
                    -- TODO: make sure to call syncAST
                    return newExp
          | otherwise = return e

instance (SYB.Data t, GHC.OutputableBndr n, SYB.Data n) => Update (GHC.LPat n) t where
    update oldPat newPat t
           = everywhereMStaged SYB.Parser (SYB.mkM inPat) t
        where
          inPat (p::GHC.LPat n)
            | sameOccurrence p oldPat
                = do
                     _ <- updateToks oldPat newPat prettyprint False
                     -- TODO: make sure to call syncAST
                     return newPat
            | otherwise = return p

instance (SYB.Data t, GHC.OutputableBndr n, SYB.Data n) => Update (GHC.LHsType n) t where
     update oldTy newTy t
           = everywhereMStaged SYB.Parser (SYB.mkM inTyp) t
        where
          inTyp (t'::GHC.LHsType n)
            | sameOccurrence t' oldTy
                = do
                     _ <- updateToks oldTy newTy prettyprint False
                     -- TODO: make sure to call syncAST
                     return newTy
            | otherwise = return t'

instance (SYB.Data t, GHC.OutputableBndr n1, GHC.OutputableBndr n2, SYB.Data n1, SYB.Data n2) => Update (GHC.LHsBindLR n1 n2) t where
       update oldBind newBind t
             = everywhereMStaged SYB.Parser (SYB.mkM inBind) t
          where
            inBind (t'::GHC.LHsBindLR n1 n2)
              | sameOccurrence t' oldBind
                  = do
                       _ <- updateToks oldBind newBind prettyprint False
                       -- TODO: make sure to call syncAST
                       return newBind
              | otherwise = return t'

{- instance (SYB.Data t, GHC.OutputableBndr n, SYB.Data n) => Update [GHC.LPat n] t where
    update oldPat newPat t
           = everywhereMStaged SYB.Parser (SYB.mkM inPat) t
        where
          inPat (p::[GHC.LPat n])
            | and $ zipWith sameOccurrence p oldPat
                = do _ <- {- zipUpdateToks -} updateToks oldPat newPat prettyprint
                     return newPat
            | otherwise = return p -}

{-
zipUpdateToks f [] [] c = return []
zipUpdateToks f [] _ _  = return []
zipUpdateToks f _ [] _  = return []
zipUpdateToks f (a:as) (b:bs) c = do res <- f a b c
                                     rest <- zipUpdateToks f as bs c
                                     return (res:rest)
-}

-- ---------------------------------------------------------------------
-- TODO: ++AZ++ get rid of the following instances, merge them into a
-- single function above
{-
instance (SYB.Data t) => Update (GHC.Located HsExpP) t where
    update oldExp newExp t
           = everywhereMStaged SYB.Parser (SYB.mkM inExp) t
       where
        inExp (e::GHC.Located HsExpP)
          | sameOccurrence e oldExp
               = do (newExp', _) <- updateToks oldExp newExp prettyprint
                -- error "update: up`dated tokens" -- ++AZ++ debug
                    return newExp'
          | otherwise = return e
-}

{- ++AZ++ comment out for now, see what breaks
instance (SYB.Data t) => Update (GHC.Located HsPatP) t where
    update oldPat newPat t
        = everywhereMStaged SYB.Parser (SYB.mkM inPat) t
     where
        inPat (p::GHC.Located HsPatP) -- = error "here"
            | sameOccurrence p oldPat
                = do (newPat', _) <- updateToksList [oldPat] newPat (prettyprintPatList prettyprint False)
                     return $ head newPat'
            | otherwise = return p

instance (SYB.Data t) => Update [GHC.Located HsPatP] t where
 update oldPat newPat  t
   = everywhereMStaged SYB.Parser (SYB.mkM inPat) t
   where
    inPat (p::[GHC.Located HsPatP])
     | and $ zipWith sameOccurrence p oldPat
        =  do  liftIO $ putStrLn (">" ++ SYB.showData SYB.Parser 0 p ++ "<")
               (newPat', _) <- (updateToksList oldPat newPat (prettyprintPatList prettyprint False))
               liftIO $ putStrLn (">" ++ SYB.showData SYB.Parser 0 newPat' ++ "<") 
               return newPat'
    inPat p = return p
--++AZ++ comment out for now ends -}

-- ---------------------------------------------------------------------

-- | Write refactored program source to files.
writeRefactoredFiles ::
  VerboseLevel -> [ApplyRefacResult] -> IO ()
writeRefactoredFiles verbosity files
  = do let filesModified = filter (\((_f,m),_) -> m == modified) files

       -- TODO: restore the history function
       -- ++AZ++ PFE0.addToHistory isSubRefactor (map (fst.fst) filesModified)
       sequence_ (map modifyFile filesModified)
       -- mapM_ writeTestDataForFile files   -- This should be removed for the release version.

     where
       modifyFile ((fileName,_),(finalLines,ts,renamed)) = do
           -- let source = concatMap (snd.snd) ts

           let ts' = bypassGHCBug7351 ts
           -- let source = GHC.showRichTokenStream ts'

           -- let source = renderPpr ppr
           let source = renderLines finalLines

           -- (Julien personnal remark) seq forces the evaluation of
           -- its first argument and returns its second argument. It
           -- is unclear for me why (length source) evaluation is
           -- forced.
           seq (length source) (writeFile (fileName ++ ".refactored") source)

           when (verbosity == Debug) $
             do
               writeFile (fileName ++ ".tokens") (showToks ts')
               writeFile (fileName ++ ".renamed_out") (showGhc renamed)
               writeFile (fileName ++ ".AST_out") $ ((showGhc renamed) ++
                      "\n\n----------------------\n\n" ++
                      (SYB.showData SYB.Renamer 0 renamed))

-- ---------------------------------------------------------------------

-- | Return the client modules and file names. The client modules of
-- module, say m, are those modules which directly or indirectly
-- import module m.

-- TODO: deal with an anonymous main module, by taking Maybe GHC.ModuleName
-- TODO: deal with multiple main modules for this, each with their own dependency graph.
clientModsAndFiles
  :: GHC.GhcMonad m => GHC.ModuleName -> m [GHC.ModSummary]
clientModsAndFiles m = do
  ms <- GHC.getModuleGraph
  modsum <- GHC.getModSummary m
  let mg = getModulesAsGraph False ms Nothing
      rg = GHC.transposeG mg
      modNode = fromJust $ find (\(msum',_,_) -> mycomp msum' modsum) (GHC.verticesG rg)
      clientMods = filter (\msum' -> not (mycomp msum' modsum))
                 $ map summaryNodeSummary $ GHC.reachableG rg modNode

  return clientMods

-- TODO : find decent name and place for this.
mycomp :: GHC.ModSummary -> GHC.ModSummary -> Bool
mycomp ms1 ms2 = (GHC.ms_mod ms1) == (GHC.ms_mod ms2)


-- ---------------------------------------------------------------------

-- | Return the server module and file names. The server modules of
-- module, say m, are those modules which are directly or indirectly
-- imported by module m. This can only be called in a live GHC session
serverModsAndFiles
  :: GHC.GhcMonad m => GHC.ModuleName -> m [GHC.ModSummary]
serverModsAndFiles m = do
  ms <- GHC.getModuleGraph
  modsum <- GHC.getModSummary m
  let mg = getModulesAsGraph False ms Nothing
      modNode = fromJust $ find (\(msum',_,_) -> mycomp msum' modsum) (GHC.verticesG mg)
      serverMods = filter (\msum' -> not (mycomp msum' modsum))
                 $ map summaryNodeSummary $ GHC.reachableG mg modNode

  return serverMods

-- ---------------------------------------------------------------------

instance (Show GHC.ModuleName) where
  show = GHC.moduleNameString

-- ---------------------------------------------------------------------

{- ++AZ++ what is using this?
-- | Get the current module graph, provided we are in a live GHC session
getCurrentModuleGraph :: RefactGhc GHC.ModuleGraph
getCurrentModuleGraph = GHC.getModuleGraph

sortCurrentModuleGraph :: RefactGhc [GHC.SCC GHC.ModSummary]
sortCurrentModuleGraph = do
  g <- getCurrentModuleGraph
  let scc = GHC.topSortModuleGraph False g Nothing
  return scc


++AZ++ -}

