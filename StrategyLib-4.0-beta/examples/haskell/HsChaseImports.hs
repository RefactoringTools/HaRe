module HsChaseImports where

-------------------------------------------------------------------------------    

-- This module implements import chasing for Haskell.

-------------------------------------------------------------------------------    

import HsIOWrap(parseWrap')
import StrategyLib
import HsModuleCollection
import Language.Haskell.Syntax
import Language.Haskell.Parser
import Language.Haskell.Pretty
import SyntaxTermInstances
import IO
import System
import qualified Literate
import Monad
import Control.Monad.Identity

-------------------------------------------------------------------------------    

hsIOwrapChasing transform
  = do [pth,m,d] <- getArgs
       errLn "Import chasing..."
       errLn ("Start from:  "++m)
       errLn ("Search path: "++pth)
       errLn ("Writing results in:"++d)
       let dirs = breakPath pth
       ms <- hsChaseFrom dirs m
       ms' <- transform ms
       mapM_ (writeModule d) ms'

writeModule :: String -> (ModuleName,[ModuleName],HsModule) -> IO ()
writeModule d (n,is,m)
  = do let sout = (prettyPrint m)++"\n"
       let fout = d++"/"++n++".hs"
       errLn ("Writing module "++n++" to file "++fout)
       writeFile fout sout
       
-- Break path argument into directory names
breakPath :: String -> [String]
breakPath x = case break (==':') x of
	(p,(_:pp)) -> p: breakPath pp
	(p,[]) -> [p]
 
-- Start chasing from a single module.

hsChaseFrom dirs m
  = hsChaseWith dirs [m] [] [] onModule onMissing
 where
  onModule n i m a = return $ a++[(n,i,m)]
  onMissing _ = return
  
-- General import chase algorithm

hsChaseWith :: [FilePath] -> [ModuleName] -> [ModuleName] -> a 
            -> (ModuleName -> [ModuleName] -> HsModule -> a -> IO a) 
	    -> (ModuleName                             -> a -> IO a)
	    -> IO a
hsChaseWith dirs todo done accu onModule onMissing
 = chase todo done accu
   where
    chase [] done accu
      = do errLn "Import chasing complete."
           return accu
    chase (m:ms) done accu
      | m `elem` done = chase ms done accu
      | otherwise     = processFile `mplus` skipFile
     where
       processFile 
         = do sin <- readHsFile dirs m
	      case (parseWrap' (fromLiterate sin)) of
	        Left pin  
		  -> let is = getImports pin
                     in do accu' <- onModule m is pin accu
		           chase (ms++is) (m:done) accu'
	        Right msg 
		  -> do errLn ("Failed to parse "++m++": "++msg)
		        accu' <- onMissing m accu
		        chase ms (m:done) accu'     
       skipFile    
         = do errLn ("Did not find module "++m++": skipping.")
	      accu' <- onMissing m accu
	      chase ms (m:done) accu'

--- Extraction of imports ----------------------------------------------------

getImports :: HsModule -> [String]
getImports m
 = runIdentity (applyTU (full_tdTU worker) m)
   where
     worker :: TU [String] Identity
     worker =  adhocTU (constTU []) (\i -> return [getName i])

     getName :: HsImportDecl -> String
     getName (HsImportDecl _ (Module mid) _ _ _) = mid


--- I/O Auxilliaries ---------------------------------------------------------

errLn str = hPutStrLn stderr str

readHsFile dirs basename
  = do errLn ("Starting search for: "++basename)
       readFileSearching dirs basename ["hs","lhs"]
  
-- Search for a file in given directories with alternative extensions

readFileSearching dirs basename exts
  = do results <- mapM tryReadFile fnames
       case dropWhile hasFailed results of
         ((Right (fc,fn)):_) 
	     -> errLn ("Read file: "++fn) >> return fc
	 _   -> errLn ("Could not find file: "++basename) >> mzero                  
    where 
      fnames = [d++'/':basename++'.':e | d <- dirs, e <- exts]
      hasFailed (Left _) = True
      hasFailed _        = False
      tryReadFile fn = try ( readFile fn >>= \fc -> return (fc,fn) )
      
      
--handle literate scripts -----------------------------------------------------

fromLiterate str
  = fromLit (isLit str) str
  
isLit :: String -> Bool
isLit =  any isLitLine . lines
         where 
	   isLitLine ('>':_) = True
	   isLitLine _       = False

-- Rest is taken from DrIFT

-- NB we don't do the latex-style literate scripts currently.
fromLit True txt = case Literate.process txt of
			  ([],s) -> s
			  (e,_) -> error e
fromLit False txt = txt

toLit True = unlines . map (\l -> '>':l)  . lines
toLit False = id       
 
isLiterate :: String -> Bool
isLiterate = any ((=='>'). head) . words      

-------------------------------------------------------------------------------    
