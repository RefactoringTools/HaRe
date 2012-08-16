-- Sample refactoring based on ifToCase


import Bag
import Bag(Bag,bagToList)
import Data.Generics
import DynFlags
import FastString(FastString)
import GHC
import GHC.Paths ( libdir )
import GHC.SYB.Utils
import Name
import NameSet(NameSet,nameSetToList)
import Outputable
import PprTyThing
import SrcLoc
import Var(Var)
import qualified OccName(occNameString)


-----------------
import qualified Data.Generics.Schemes as SYB
import qualified Data.Generics.Aliases as SYB
import qualified GHC.SYB.Utils         as SYB

import qualified GHC
import qualified DynFlags              as GHC
import qualified Outputable            as GHC
import qualified MonadUtils            as GHC
 
import GHC.Paths ( libdir )
 
-----------------


targetFile = "./refactorer/" ++ targetMod ++ ".hs"
-- targetFile = "B.hs"
targetMod = "B"



-- import RefacUtils 
{-
ifToCase args  
  = do let fileName = args!!0              
           beginPos = (read (args!!1), read (args!!2))::(Int,Int)
           endPos   = (read (args!!3), read (args!!4))::(Int,Int)
       modInfo@(_, _, mod, toks) <- parseSourceFile fileName 
       let exp = locToExp beginPos endPos toks mod
       case exp of 
           (Exp (HsIf _ _ _))   
                -> do refactoredMod <- applyRefac (ifToCase exp) (Just modInfo) fileName          
                      writeRefactoredFiles False [refactoredMod]
           _   -> error "You haven't selected an if-then-else  expression!"
    where 

     ifToCase exp (_, _, mod)= applyTP (once_buTP (failTP `adhocTP` inExp)) mod
       where 
         inExp exp1@((Exp (HsIf  e e1 e2))::HsExpP)
           | sameOccurrence exp exp1       
           = let newExp =Exp (HsCase e [HsAlt loc0 (nameToPat "True") (HsBody e1) [],
                                        HsAlt loc0 (nameToPat "False")(HsBody e2) []])
             in update exp1 newExp exp1
         inExp _ = mzero
-}

-- data HsExpr id
--   ...
--   HsIf (Maybe (SyntaxExpr id)) (LHsExpr id) (LHsExpr id) (LHsExpr id)
--                                  ^1            ^2           ^3
--   ...
--  HsCase (LHsExpr id) (MatchGroup id)
--            ^1

-- data MatchGroup id
--   MatchGroup [LMatch id] PostTcType	

-- type LMatch id = Located (Match id)

-- data Match id 
--   Match [LPat id] (Maybe (LHsType id)) (GRHSs id)	 

getStuff =
    defaultErrorHandler defaultLogAction $ do
      runGhc (Just libdir) $ do
        dflags <- getSessionDynFlags
        let dflags' = foldl xopt_set dflags
                            [Opt_Cpp, Opt_ImplicitPrelude, Opt_MagicHash]
        setSessionDynFlags dflags'
        target <- guessTarget targetFile Nothing
        setTargets [target]
        load LoadAllTargets -- Loads and compiles, much as calling make
        modSum <- getModSummary $ mkModuleName "B"
        p <- parseModule modSum
        
        t <- typecheckModule p
        d <- desugarModule t
        l <- loadModule d
        n <- getNamesInScope
        c <- return $ coreModule d

        g <- getModuleGraph
        -- mapM showModule g
        -- return $ (parsedSource d,"/n-----/n",  typecheckedSource d, "/n-=-=-=-=-=-=-/n", modInfoTyThings $ moduleInfo t)
        -- return $ (parsedSource d,"/n-----/n",  typecheckedSource d, "/n-=-=-=-=-=-=-/n")
        -- return $ (typecheckedSource d)
        
        -- res <- getRichTokenStream (ms_mod modSum)
        -- return $ showRichTokenStream res

        let ps = convertSource $ pm_parsed_source p
        -- let res = showData Parser 4 ps
        let res = showPpr ps
        return res

convertSource ps =
  ps

-- -----------------------------------------------------------------------------------------
-- From http://hpaste.org/65775
{-
   1. install first: ghc-paths, ghc-syb-utils
   2. make a file Test1.hs in this dir with what you want to parse/transform
   3 .run with: ghci -package ghc
-}

-- module Main where

 
main = example

example =
   GHC.runGhc (Just libdir) $ do
        dflags <- GHC.getSessionDynFlags
        let dflags' = foldl GHC.xopt_set dflags
                            [GHC.Opt_Cpp, GHC.Opt_ImplicitPrelude, GHC.Opt_MagicHash]
        GHC.setSessionDynFlags dflags'
        -- target <- GHC.guessTarget (targetMod ++ ".hs") Nothing
        target <- GHC.guessTarget targetFile Nothing
        GHC.setTargets [target]
        GHC.load GHC.LoadAllTargets
        modSum <- GHC.getModSummary $ GHC.mkModuleName targetMod
        p <- GHC.parseModule modSum
        let p' = processParsedMod shortenLists p
        -- GHC.liftIO (putStrLn . showParsedModule $ p)
        -- GHC.liftIO (putStrLn . showParsedModule $ p')
        GHC.liftIO (putStrLn $ showPpr $ GHC.pm_parsed_source p')

showParsedModule p = SYB.showData SYB.Parser 0 (GHC.pm_parsed_source p)

processParsedMod f pm = pm { GHC.pm_parsed_source = ps' }
  where
   ps  = GHC.pm_parsed_source pm
   -- ps' = SYB.everythingStaged SYB.Parser (SYB.mkT f) -- does not work yet
   -- everythingStaged :: Stage -> (r -> r -> r) -> r -> GenericQ r -> GenericQ r
   
   ps' :: GHC.ParsedSource
   ps' = SYB.everywhere (SYB.mkT f) ps -- exception


shortenLists :: GHC.HsExpr GHC.RdrName -> GHC.HsExpr GHC.RdrName
shortenLists (GHC.ExplicitList t exprs) = GHC.ExplicitList t []
shortenLists x                          = x

