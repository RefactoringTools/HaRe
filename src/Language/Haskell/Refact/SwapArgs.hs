{-# LANGUAGE ScopedTypeVariables #-}
module Language.Haskell.Refact.SwapArgs (swapArgs) where

import qualified Data.Generics.Schemes as SYB
import qualified Data.Generics.Aliases as SYB
import qualified GHC.SYB.Utils         as SYB

import qualified FastString            as GHC
import qualified Name          as GHC
import qualified GHC
import qualified DynFlags              as GHC
import qualified Outputable            as GHC
import qualified MonadUtils            as GHC
import qualified RdrName               as GHC
import qualified OccName               as GHC
 
import GHC.Paths ( libdir )
import Control.Monad
import Control.Monad.State
import Data.Data
import Data.Maybe
-----------------

import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

import Debug.Trace

swapArgs :: [String] -> IO () -- For now
swapArgs args
  = do let fileName = args!!0              
           row = (read (args!!1)::Int)
           col = (read (args!!2)::Int)
       runRefacSession Nothing (comp Nothing fileName (row,col))
       
       
comp :: Maybe FilePath -> String -> SimpPos
     -> RefactGhc [ApplyRefacResult]	
comp maybeMainFile fileName (row, col) = do
       loadModuleGraphGhc maybeMainFile
       modInfo@(t, _tokList) <- getModuleGhc fileName
       renamed <- getRefactRenamed
       parsed  <- getRefactParsed
       -- modInfo@((_, renamed, mod), toks) <- parseSourceFileGhc fileName 
       -- putStrLn $ showParsedModule mod
       -- let pnt = locToPNT fileName (row, col) mod  

       let pnt = locToPNT (GHC.mkFastString fileName) (row, col) renamed
       let name = locToName (GHC.mkFastString fileName) (row, col) renamed
       -- error (SYB.showData SYB.Parser 0 name)
       
       case name of
            (Just pn) -> do refactoredMod@(_, (t, s)) <- applyRefac (doSwap pnt pn) (Just modInfo) fileName
                            return [refactoredMod]
            Nothing   -> error "Incorrect identifier selected!"
       --if isFunPNT pnt mod    -- Add this back in ++ CMB +++
       -- then do 
              --        rs <-if isExported pnt exps 
       --               then  applyRefacToClientMods (doSwap pnt) fileName
       --               else  return []
       -- writeRefactoredFiles False (r:rs)      
       -- else error "\nInvalid cursor position!"
       
       -- putStrLn (showToks t)
       -- writeRefactoredFiles False [refactoredMod]  
       -- putStrLn ("here" ++ (SYB.showData SYB.Parser 0 mod))  -- $ show [fileName, beginPos, endPos]
       -- putStrLn "Completd"


doSwap ::
 PNT -> (GHC.Located GHC.Name) -> RefactGhc () -- m GHC.ParsedSource
doSwap pnt@(PNT (GHC.L _ _)) name@(GHC.L s n) = do
    inscopes <- getRefactInscopes
    renamed  <- getRefactRenamed
    parsed   <- getRefactParsed
    reallyDoSwap pnt name renamed

reallyDoSwap :: PNT -> (GHC.Located GHC.Name) -> GHC.RenamedSource -> RefactGhc ()
reallyDoSwap pnt@(PNT (GHC.L _ _)) name@(GHC.L s n1) renamed = do
    renamed' <- everywhereMStaged SYB.Renamer (SYB.mkM inMod `SYB.extM` inExp) renamed -- this needs to be bottom up +++ CMB +++
    putRefactRenamed renamed'
    return ()
    
    where
         -- 1. The definition is at top level...
         inMod (func@(GHC.FunBind (GHC.L x n2) infixity (GHC.MatchGroup matches p) a locals tick)::(GHC.HsBindLR GHC.Name GHC.Name ))
            | GHC.nameUnique n1 == GHC.nameUnique n2 
                    = do liftIO $ putStrLn ("inMatch>" ++ SYB.showData SYB.Parser 0 (GHC.L x n2) ++ "<")
                         newMatches <- updateMatches matches
                         return (GHC.FunBind (GHC.L x n2) infixity (GHC.MatchGroup newMatches p) a locals tick)
         inMod func = return func
         
         -- 2. All call sites of the function...
         inExp exp@((GHC.L x (GHC.HsApp (GHC.L y (GHC.HsApp e e1)) e2))::GHC.Located (GHC.HsExpr GHC.Name))
            | GHC.nameUnique (fromJust $ expToName e) == GHC.nameUnique n1 
                   =  update e2 e1 =<< update e1 e2 exp
         inExp e = return e
         
         -- 3. Type signature...


         updateMatches [] = return []
         updateMatches (i@(GHC.L x m@(GHC.Match pats nothing rhs)::GHC.Located (GHC.Match GHC.Name)):matches)
           = case pats of
               (p1:p2:ps) -> do p1' <- update p1 p2 p1
                                p2' <- update p2 p1 p2
                                matches' <- updateMatches matches
                                return ((GHC.L x (GHC.Match (p1':p2':ps) nothing rhs)):matches')

    
{-        inMatch i@(GHC.L x m@(GHC.Match (p1:p2:ps) nothing rhs)::GHC.Located (GHC.Match GHC.RdrName) )
		  -- = error (SYB.showData SYB.Parser 0 pnt) 
            | GHC.srcSpanStart s == GHC.srcSpanStart x
              = do liftIO $ putStrLn ("inMatch>" ++ SYB.showData SYB.Parser 0 (p1:p2:ps) ++ "<")
                   p1' <- update p1 p2 p1 --pats
                   p2' <- update p2 p1 p2
                   return (GHC.L x (GHC.Match (p1':p2':ps) nothing rhs))
        inMatch i = return i 
        
        inExp exp@((GHC.L x (GHC.HsApp (GHC.L y (GHC.HsApp e e1)) e2))::GHC.Located (GHC.HsExpr GHC.RdrName))
          {- | (fromJust $ expToName e) == (GHC.L s (GHC.nameRdrName n))-} -- = error (SYB.showData SYB.Parser 0 (GHC.L s (GHC.nameRdrName n)))  -- update e2 e1 =<< update e1 e2 exp
       -- inExp e = return e -}
        -- In the call-site.
   {- inExp exp@((Exp (HsApp (Exp (HsApp e e1)) e2))::HsExpP)
      | expToPNT e == pnt     
      = update e2 e1 =<< update e1 e2 exp     
    inExp e = return e -}
-- pats nothing rhss ds)

-- expToPNT x = undefined

prettyprint :: (GHC.Outputable a) => a -> String
prettyprint x = GHC.showSDoc $ GHC.ppr x
