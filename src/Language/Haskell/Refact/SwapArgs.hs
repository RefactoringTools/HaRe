{-# LANGUAGE ScopedTypeVariables #-}
module Language.Haskell.Refact.SwapArgs (swapArgs) where

import qualified Data.Generics.Schemes as SYB
import qualified Data.Generics.Aliases as SYB
import qualified GHC.SYB.Utils         as SYB

import qualified FastString            as GHC
import qualified Name                  as GHC
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
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

import Debug.Trace

swapArgs :: [String] -> IO [FilePath]
swapArgs args
  = do let fileName = args!!0
           row = (read (args!!1)::Int)
           col = (read (args!!2)::Int)
       runRefacSession Nothing Nothing (comp fileName (row,col))


comp :: String -> SimpPos
     -> RefactGhc [ApplyRefacResult]
comp fileName (row, col) = do
       -- loadModuleGraphGhc maybeMainFile
       -- modInfo@(_t, _tokList) <- getModuleGhc fileName
       getModuleGhc fileName
       renamed <- getRefactRenamed
       -- parsed  <- getRefactParsed
       -- modInfo@((_, renamed, mod), toks) <- parseSourceFileGhc fileName
       -- putStrLn $ showParsedModule mod
       -- let pnt = locToPNT fileName (row, col) mod

       let name = locToName (GHC.mkFastString fileName) (row, col) renamed
       -- error (SYB.showData SYB.Parser 0 name)

       case name of
            -- (Just pn) -> do refactoredMod@(_, (_t, s)) <- applyRefac (doSwap pnt pn) (Just modInfo) fileName
            (Just pn) -> do
                            -- let pnt = locToPNT (GHC.mkFastString fileName) (row, col) renamed
                            -- let pnt = gfromJust "SwapArgs.comp" $ locToRdrName (GHC.mkFastString fileName) (row, col) renamed

                            (refactoredMod@(_, (_t, _s)),_) <- applyRefac (doSwap pn) (RSFile fileName)
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
 (GHC.Located GHC.Name) -> RefactGhc () -- m GHC.ParsedSource
doSwap name = do
    -- inscopes <- getRefactInscopes
    renamed  <- getRefactRenamed
    -- parsed   <- getRefactParsed
    reallyDoSwap name renamed

reallyDoSwap :: (GHC.Located GHC.Name) -> GHC.RenamedSource -> RefactGhc ()
reallyDoSwap (GHC.L _s n1) renamed = do
    renamed' <- everywhereMStaged SYB.Renamer (SYB.mkM inMod `SYB.extM` inExp `SYB.extM` inType) renamed -- this needs to be bottom up +++ CMB +++
    putRefactRenamed renamed'
    return ()

    where
         -- 1. The definition is at top level...
         inMod (_func@(GHC.FunBind (GHC.L x n2) infixity (GHC.MatchGroup matches p) a locals tick)::(GHC.HsBindLR GHC.Name GHC.Name ))
            | GHC.nameUnique n1 == GHC.nameUnique n2
                    = do logm ("inMatch>" ++ SYB.showData SYB.Parser 0 (GHC.L x n2) ++ "<")
                         newMatches <- updateMatches matches
                         return (GHC.FunBind (GHC.L x n2) infixity (GHC.MatchGroup newMatches p) a locals tick)
         inMod func = return func

         -- 2. All call sites of the function...
         inExp exp@((GHC.L x (GHC.HsApp (GHC.L y (GHC.HsApp e e1)) e2))::GHC.Located (GHC.HsExpr GHC.Name))
            | GHC.nameUnique (expToName e) == GHC.nameUnique n1
                   =  update e2 e1 =<< update e1 e2 exp
         inExp e = return e

         -- 3. Type signature...
         inType ty@(GHC.L x (GHC.TypeSig [GHC.L x2 name] types)::GHC.LSig GHC.Name)
           | GHC.nameUnique name == GHC.nameUnique n1
                = do let (t1:t2:ts) = tyFunToList types
                     t1' <- update t1 t2 t1
                     t2' <- update t2 t1 t2
                     return (GHC.L x (GHC.TypeSig [GHC.L x2 name] (tyListToFun (t1':t2':ts))))

         inType ty@(GHC.L x (GHC.TypeSig (n:ns) types)::GHC.LSig GHC.Name)
           | GHC.nameUnique n1 `elem` (map (\(GHC.L _ n) -> GHC.nameUnique n) (n:ns))
            = error "Error in swapping arguments in type signature: signauture bound to muliple entities!"

         inType ty = return ty

         tyFunToList (GHC.L _ (GHC.HsForAllTy _ _ _ (GHC.L _ (GHC.HsFunTy t1 t2)))) = t1 : (tyFunToList t2)
         tyFunToList (GHC.L _ (GHC.HsFunTy t1 t2)) = t1 : (tyFunToList t2)
         tyFunToList t = [t]

         tyListToFun [t1] = t1
         tyListToFun (t1:ts) = GHC.noLoc (GHC.HsFunTy t1 (tyListToFun ts))

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
              = do logm ("inMatch>" ++ SYB.showData SYB.Parser 0 (p1:p2:ps) ++ "<")
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

-- prettyprint :: (GHC.Outputable a) => a -> String
-- prettyprint x = GHC.showSDoc $ GHC.ppr x

