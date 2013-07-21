module HsFreeNames where

-------------------------------------------------------------------------------

-- This module implements free name analysis for Haskell.
-- Under construction!!!
-- We are not yet faithfully dealing with qualified vs. unqualified names.
-- Same holds for module level analysis.

-------------------------------------------------------------------------------

import Language.Haskell.Syntax
import SyntaxTermInstances
import StrategyLib
import Data.List
import Control.Monad
import Data.Monoid


-------------------------------------------------------------------------------

-- The main function of analysis.
-- We use the stop_td scheme.
-- We define ad hoc cases for several syntactical domains.
-- Ad hoc cases are meant to restart recursion.


hsFreeAndDeclared :: (Term t, MonadPlus m) => t -> m ([HsQName],[HsQName])
hsFreeAndDeclared = applyTU (stop_tdTU worker)
  where
    worker = failTU `adhocTU` exp
                    `adhocTU` pat
                    `adhocTU` match
                    `adhocTU` alt
                    `adhocTU` decls
                    `adhocTU` stmts

    exp (HsVar qn)             = return ([qn],[])
    exp (HsCon qn)             = return ([qn],[])
    exp (HsLambda _ pats body)
      = do (pf,pd) <- hsFreeAndDeclared pats
           (bf,bd) <- hsFreeAndDeclared body
           return ((bf `union` pf) \\ pd,[])
    exp (HsLet decls exp)   
      = do (df,dd) <- hsFreeAndDeclared decls
           (ef,ed) <- hsFreeAndDeclared exp
           return (df `union` (ef \\ dd),[])
    exp (HsListComp exp stmts)
      = hsFreeAndDeclared (stmts ++ [HsQualifier exp])
    exp (HsRecConstr qn e)     = addFree qn (hsFreeAndDeclared e)
    exp _                      = mzero
       
    pat (HsPVar n)             = return ([],[UnQual n])
    pat (HsPInfixApp p1 qn p2) = addFree qn (hsFreeAndDeclared [p1,p2])
    pat (HsPApp qn pats)       = addFree qn (hsFreeAndDeclared pats)
    pat (HsPRec qn fields)     = addFree qn (hsFreeAndDeclared fields)
    pat _                      = mzero

    match (HsMatch _ fun pats rhs {-where-} decls)
      = do (pf,pd) <- hsFreeAndDeclared pats
           (rf,rd) <- hsFreeAndDeclared rhs
           (df,dd) <- hsFreeAndDeclared decls
	   let qfun = UnQual fun
           return ( pf `union` (((rf \\ (dd `union` [qfun]) `union` df) \\ pd)),
                    [qfun] )

    alt (HsAlt _ pat exp decls) 
      = do (pf,pd) <- hsFreeAndDeclared pat
           (ef,ed) <- hsFreeAndDeclared exp
           (df,dd) <- hsFreeAndDeclared decls
           return (pf `union` (((ef \\ dd) `union` df) \\ pd),[])

    decls (ds::[HsDecl])
      = do (f,d) <- hsFreeAndDeclaredList ds
           return (f \\ d, d)

    stmts (HsGenerator _ pat exp:stmts)
      = do (pf,pd) <- hsFreeAndDeclared pat
           (ef,ed) <- hsFreeAndDeclared exp
           (sf,sd) <- hsFreeAndDeclared stmts
           return (pf `union` ef `union` (sf \\ pd),[])
    stmts (HsLetStmt decls:stmts)
      = do (df,dd) <- hsFreeAndDeclared decls
           (sf,sd) <- hsFreeAndDeclared stmts
           return (df `union` (sf \\ dd),[])
    stmts _ = mzero

    addFree free mfd = do (f,d) <- mfd
                          return ([free] `union` f,d)

hsFreeAndDeclaredList :: (Term t, MonadPlus m) => [t] -> m ([HsQName],[HsQName])
hsFreeAndDeclaredList l
  = do fds <- mapM hsFreeAndDeclared l
       return ( foldr union [] (map fst fds),
                foldr union [] (map snd fds) )

-------------------------------------------------------------------------------

-- This should go somewhere else.

-- instance (Monoid a, Monoid b) => Monoid (a,b) where
--   mappend (a,b) (a',b') = (mappend a a', mappend b b')
--   mempty                = (mempty,mempty)
 
-------------------------------------------------------------------------------
