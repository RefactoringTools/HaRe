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





targetFile = "./refactorer/B.hs"
-- targetFile = "B.hs"



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
--   ...


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

        let ps = pm_parsed_source p
        let res = showData Parser 4 ps
        return res

