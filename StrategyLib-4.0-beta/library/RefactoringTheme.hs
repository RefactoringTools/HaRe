------------------------------------------------------------------------------
-- | 
-- Maintainer	: Ralf Laemmel, Joost Visser
-- Stability	: experimental
-- Portability	: portable
--
-- This module is part of 'StrategyLib', a library of functional strategy
-- combinators, including combinators for generic traversal. This module 
-- defines generic refactoring functionality. See the paper "Towards
-- Generic Refactoring" by Ralf Laemmel. See also 
-- generic-refactoring in the examples directory.

------------------------------------------------------------------------------

module RefactoringTheme where

import StrategyPrelude
import Control.Monad.Identity hiding (fail)
import KeyholeTheme
import NameTheme


------------------------------------------------------------------------------
-- * The abstraction interface

-- | Class of abstractions
class (
       -- Syntactical domains
       Term abstr,	-- Term type for abstraction
       Eq name,		-- Names of abstraction
       Term [abstr],	-- Lists of abstractions
       Term apply	-- Applications
      )
        => Abstraction abstr name tpe apply

      -- Dependencies between syntactical domains
      | abstr            -> name,
        abstr            -> tpe,
        abstr            -> apply,
        apply            -> name,
        apply            -> abstr

  where

    -- Observers
    getAbstrName  :: abstr -> Maybe name
    getAbstrParas :: abstr -> Maybe [(name,tpe)]
    getAbstrBody  :: abstr -> Maybe apply
    getApplyName  :: apply -> Maybe name
    getApplyParas :: apply -> Maybe [(name,tpe)]

    -- Constructors
    constrAbstr   :: name -> [(name,tpe)] -> apply -> Maybe abstr
    constrApply   :: name -> [(name,tpe)] -> Maybe apply



------------------------------------------------------------------------------
-- * Removal

-- | Remove an unused abstraction
eliminate :: (Term prog, Abstraction abstr name tpe apply)
          => TU [(name,tpe)] Identity	-- ^ Identify declarations
	  -> TU [name] Identity		-- ^ Identify references
          -> (abstr -> Maybe abstr)	-- ^ Unwrap abstraction
          -> prog			-- ^ Input program
          -> Maybe prog			-- ^ Output program

eliminate declared referenced unwrap prog
  = do { abstr <- selectFocus unwrap prog;
         name  <- getAbstrName abstr;
         ()    <- unusedAbstr name;
                  deleteFocus unwrap prog
       }

  where

    -- Check if name is unused by optionally navigating to the relevant scope
    unusedAbstr name = maybe (notIsFree prog) notIsFree selectScope
      where
        argtype   :: Monad m => (x -> y) -> x -> m x
        argtype _ =  return  
        selectScope = selectHost unwrap (argtype unwrap) prog
        notIsFree scope
          = do 
               scope' <- deleteFocus unwrap scope
               names  <- return (freeNames declared referenced scope')
               guard (not (elem name names))


------------------------------------------------------------------------------
-- * Insertion

-- | Insert a new abstraction
introduce :: (Term prog, Abstraction abstr name tpe apply)
        => TU [(name,tpe)] Identity 	-- ^ Identify declarations
        -> TU [name] Identity		-- ^ Identify references
        -> ([abstr] -> Maybe [abstr])	-- ^ Unwrap scope with abstractions
        -> abstr			-- ^ Abstraction to be inserted
        -> prog				-- ^ Input program
        -> Maybe prog			-- ^ Output program

introduce declared referenced unwrap abstr =
 replaceFocus (\abstrlist -> 
   do
       abstrlist' <- unwrap abstrlist
       name       <- getAbstrName abstr
       free       <- return $ freeNames declared referenced abstrlist'
       def        <- mapM getAbstrName abstrlist'
       guard (and [not (elem name free), not (elem name def)])
       return (abstr:abstrlist') )


------------------------------------------------------------------------------
-- * Generic extraction (say fold)

-- | Extract an abstraction
extract :: (Term prog, Abstraction abstr name tpe apply)
        => TU [(name,tpe)] Identity	    	-- ^ Identify declarations
	-> TU [name] Identity		    	-- ^ Identify references
        -> (apply -> Maybe apply)	    	-- ^ Unwrap focus
        -> ([abstr] -> [abstr])	    	    	-- ^ Wrap host
        -> ([abstr] -> Maybe [abstr])	    	-- ^ Unwrap host
        -> ([(name,tpe)] -> apply -> Bool)	-- ^ Check focus
	-> name				    	-- ^ Name for abstraction
        -> prog				    	-- ^ Input program
        -> Maybe prog			    	-- ^ Output program

extract declared referenced unwrap wrap unwrap' check name prog
  = do
       -- Operate on focus
       (bound,focus) <- boundTypedNames declared unwrap prog
       free          <- return $ freeTypedNames declared referenced bound focus
       guard (check bound focus)
 
       -- Construct abstraction
       abstr       <- constrAbstr name free focus
 
       -- Insert abstraction
       prog'       <- markHost (maybe False (const True) . unwrap) wrap prog
       prog''      <- introduce declared referenced unwrap' abstr prog'
    
       -- Construct application
       apply       <- constrApply name free

       -- Replace focus by application
       replaceFocus (maybe Nothing (const (Just apply)) . unwrap) prog''

------------------------------------------------------------------------------
