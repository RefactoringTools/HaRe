module Language.Haskell.Refact.SwapArgs (swapArgs) where

import qualified Data.Generics.Schemes as SYB
import qualified Data.Generics.Aliases as SYB
import qualified GHC.SYB.Utils         as SYB

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
-----------------

import Language.Haskell.Refact.Utils 
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.Monad

swapArgs :: [String] -> IO () -- For now
swapArgs args
  = do let fileName = args!!0              
           row = (read (args!!1)::Int)
           col = (read (args!!2)::Int)	
       modInfo@((_, _, mod), toks) <- parseSourceFile fileName 
       -- putStrLn $ showParsedModule mod
       let pnt = locToPNT fileName (row, col) mod  

       --if isFunPNT pnt mod    -- Add this back in ++ CMB +++
       -- then do 
       r <- applyRefac (doSwap pnt) (Just modInfo) fileName
       --        rs <-if isExported pnt exps 
       --               then  applyRefacToClientMods (doSwap pnt) fileName
       --               else  return []
       -- writeRefactoredFiles False (r:rs)      
       -- else error "\nInvalid cursor position!"
       -- writeRefactoredFiles False [r]  
       -- putStrLn ("here" ++ (SYB.showData SYB.Parser 0 mod))  -- $ show [fileName, beginPos, endPos]
       putStrLn "Completd"


doSwap ::
  GHC.GenLocated GHC.SrcSpan GHC.RdrName  
  -> (t, [GHC.LIE GHC.RdrName], GHC.ParsedSource) -> Refact GHC.ParsedSource -- m GHC.ParsedSource
doSwap pnt@(GHC.L s _) (_ , _, mod) 
   = {-error (SYB.showData SYB.Parser 0 pnt) -- -} everywhereMStaged SYB.Parser (SYB.mkM inFun) mod -- this needs to be bottom up +++ CMB +++
	where
		-- inFun ((GHC.FunBind name isInfix matches coerce localFree _)
                inFun (GHC.L a (GHC.ValD i@(GHC.FunBind (GHC.L x b) bool matchgroup wphole c maybe)):: (GHC.Located HsDeclP))
			| s == x = do matchgroup' <- swapInMatch matchgroup -- error (SYB.showData SYB.Parser 0 i) 
			              return ((GHC.L a (GHC.ValD (GHC.FunBind (GHC.L x b) bool matchgroup' wphole c maybe))))
		inFun f = return f

                swapInMatch (GHC.MatchGroup (m:ms) l)  =  do m' <- swapInMatches m
							     return (GHC.MatchGroup (m':ms) l)
		swapInMatches i@(GHC.L x (GHC.Match pats nothing rhs)) 
		  = -- error (SYB.showData SYB.Parser 0 pats) 
			case pats of
				(p1:p2:ps) -> do -- pats'' <- update p2 p1 =<< update p1 p2 pats
						 -- update p1 p2 pats
						 return (GHC.L x (GHC.Match pats nothing rhs))

-- pats nothing rhss ds)

