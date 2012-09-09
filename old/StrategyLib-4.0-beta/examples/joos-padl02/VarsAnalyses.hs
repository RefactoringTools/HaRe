------------------------------------------------------------------------------

module VarsAnalyses where

import Datatypes
import DatatypesTermInstances
import StrategyLib hiding (replaceFocus)
import Control.Monad
import Data.Monoid
import Data.List

--- Variable analyses --------------------------------------------------------

                                                        --- Used variables ---

useVar (Identifier i) = return [i]
useVar _              = return []

collectVars 	:: Monad m => TU [Identifier] m
collectVars 	 = full_tdTU (adhocTU (constTU []) useVar)


                                        --- Declared variables (with type) ---

declVars	:: Monad m => TU [(Identifier,Type)] m
declVars	 = adhocTU (adhocTU (constTU []) declVarsBlock) declVarsMeth
	where declVarsBlock (BlockStatements vds _)
                = return (map (\(VariableDecl t i) -> (i,t)) vds)
              declVarsMeth (MethodDecl _ _ (FormalParams fps) _)
                = return (map (\(FormalParam t i) -> (i,t)) fps)


-- To take field declarations and formal parameters of constructor 
-- methods into account as well, we could have used the the following
-- code.

declVarsConstr (ConstructorDecl _ (FormalParams fps) _ _)
  = return (map (\(FormalParam t i) -> (i,t)) fps)
declVarsClass  (ClassDecl _ _ _ fds _ _)
  = return (map (\(FieldDecl t i) -> (i,t)) fds)

                                                     --- Defined variables ---

defVar (Assignment i _) = return [i]

                                   --- Two kinds of free variable analysis ---

freeUseVars env
  = dotTU nubMap (typed_free_vars env (adhocTU (constTU []) useVar) declVars)
freeDefVars env
  = dotTU nubMap (typed_free_vars env (adhocTU (constTU []) defVar) declVars)


{-----------------------------------------------------------------------------

NOTE:

Generic functionality for variable analyses is to be found in the
library/NameTheme.hs. The below analyses are variations on some of the
functions in the NameTheme. These variations are kept to avoid deviation
from the code that was published in "Typed Combinators for Generic 
Traversal".


There are the following generic algorithms for free variable analysis:

   free_vars:       strategy that returns the set of free variables of a term
   typed_free_vars: strategy that returns a map of the free variables of a
                      term to their types.

   Parameters:
     getvars:    strategy that returns the variables used in a node
     declvars:   strategy that returns the variables declared in a node

-----------------------------------------------------------------------------}

------------------------------------------------------------------------------

free_vars :: (Monad m, Eq var) => TU [var] m -> TU [var] m -> TU [var] m
free_vars getvars declvars
  = op2TU union 
    getvars
    ( op2TU (\\) (allTU union [] (free_vars getvars declvars))
                  declvars )

typed_free_vars :: (Monad m, Eq v)
                => [(v,t)] -> TU [v] m -> TU [(v,t)] m -> TU [(v,t)] m
typed_free_vars env getvars declvars
  = dotTU (flip appendMap env) declvars `passTU` \env' ->
    op2TU appendMap
          (dotTU (flip restrictMap env') getvars)
          (op2TU diffMap 
                 (allTU (++) [] (typed_free_vars env' getvars declvars))
                 declvars)


--- Map operations -----------------------------------------------------------

keyEq (k1,_) (k2,_)		 = k1 == k2
nubMap map			 = nubBy keyEq map
appendMap map1 map2		 = map1++map2
filterMap map keys		 = filter (\(k,_) -> k `elem` keys) map
diffMap map1 map2		 = diffMap' map1 (map fst map2)
restrictMap keys map		 = filter (\(k,_) -> k `elem` keys) map

diffMap' [] keys      		 = []
diffMap' (kv@(k,v):map) keys	 = if (k `elem` keys) 
					then (diffMap' map keys) 
					else (kv:diffMap' map keys)


------------------------------------------------------------------------------
