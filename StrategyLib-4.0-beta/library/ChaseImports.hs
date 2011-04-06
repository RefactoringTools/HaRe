-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module is part of 'StrategyLib', a library of functional strategy
-- combinators, including combinators for generic traversal. This module
-- defines a generic algorithm for import chasing. This algorithm is not
-- strategic in nature itself, but usually it will be instantiated with
-- strategic functions for a particular object language.

-----------------------------------------------------------------------------} 

module ChaseImports (
-- * Type synonym
 ChaseName,
-- * Generic import chasing
 chaseWith,
 chaseFile, findFile
) where

import Monad
import IO
import System.Directory
import Control.Monad.Error () -- This import gives us (MonadPlus IO) !!


------------------------------------------------------------------------------
-- * Type synonym

-- | The type of names of chaseable things. Synonym of 'String'.
type ChaseName = String



------------------------------------------------------------------------------
-- * Generic import chasing

-- | A generic import chasing function. The type of the final result is a
--   parameter, which will usually be instantiated to a list of parsed
--   modules.
chaseWith 
  :: [FilePath]		  -- ^ path (list of directories to search)
  -> [ChaseName]	  -- ^ todo (list of modules still to find)
  -> [ChaseName]          -- ^ done (list of modules already found)
  -> accu     		  -- ^ initial (start value of accumulator)
  -> ([FilePath] -> ChaseName -> IO (Either cu String))   
                          -- ^ parse (function that attempt to find and parse a module)
  -> (cu -> [ChaseName])  -- ^ imports (function that extracts imports from
                          --   a parse result)
  -> (ChaseName -> [ChaseName] -> cu -> accu -> IO accu)  
                          -- ^ on module (function that computes a new
			  --   accumulator from a parse result)
  -> (ChaseName -> accu -> IO accu) 		  
                          -- ^ on missing (function that computes a new
			  --   accumulator value when parsing failed)
  -> IO accu              -- ^ result (accumulated value)
chaseWith dirs todo done accu parseFile getImports onModule onMissing
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
         = do parse_result <- parseFile dirs m
	      case parse_result of
	        Left pin  
		  -> let is = getImports pin
                     in do accu' <- onModule m is pin accu
		           chase (ms++is) (m:done) accu'
	        Right msg 
		  -> do errLn ("Failed to parse "++m++": "++msg)
		        accu' <- onMissing m accu
		        chase ms (m:done) accu'     
       skipFile    
         = do errLn ("Could not find module "++m++": skipping.")
	      accu' <- onMissing m accu
	      chase ms (m:done) accu'



-- | Read a file from a number of possible directories, given a
--   base name and a list of possible extensions. Returns the content
--   of the file it found.
chaseFile :: [FilePath]          -- ^ path (directories to search)
          -> String              -- ^ base name
	  -> [String]            -- ^ possible extensions
	  -> IO String           -- ^ contents of file
chaseFile dirs basename exts
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

      
-- | Find a file in a number of possible directories, given a
--   base name and a list of possible extensions. Returns the full
--   name of the file it found.
findFile :: [FilePath]          -- ^ path (directories to search)
         -> String              -- ^ base name
	 -> [String]            -- ^ possible extensions
	 -> IO FilePath         -- ^ contents of file
findFile dirs basename exts
  = do existingFileNames <- filterM doesFileExist fnames
       case existingFileNames of
         (fn:_) 
	     -> errLn ("Found file: "++fn) >> return fn
	 _   -> errLn ("Could not find file: "++basename) >> mzero                  
    where 
      fnames = [d++'/':basename++'.':e | d <- dirs, e <- exts]
      


------------------------------------------------------------------------------
-- * Progress and error messages 

-- | Helper function for reporting errors and progress to stderr
errLn str = hPutStrLn stderr str


------------------------------------------------------------------------------
