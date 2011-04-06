module DoElim (doElim) where

-------------------------------------------------------------------------------

--- This module implements a transformation that implements de-sugaring
--- of Haskell's "do" notation

-------------------------------------------------------------------------------

import Language.Haskell.Syntax
import SyntaxTermInstances
import StrategyLib
import Monad

-- Elimination of do notation -------------------------------------------------

doElim 	   :: (Term a, MonadPlus m) => a -> m a
doElim h   =  applyTP (innermost (monoTP doElim1)) h

doElim1    :: MonadPlus m => HsExp -> m HsExp
doElim1 (HsDo [HsQualifier e]) 	
  = return e
doElim1 (HsDo (HsQualifier e:stmts))	
  = return (HsInfixApp e (HsQVarOp (hsSymbol ">>")) (HsDo stmts))
doElim1 (HsDo (HsGenerator _ p e:stmts))
  = do ok <- new_name
       return (letPattern ok p e stmts)
doElim1 (HsDo (HsLetStmt decls:stmts))
  = return (HsLet decls (HsDo stmts))
doElim1 _                      
  = mzero

-- Auxiliaries ----------------------------------------------------------------

letPattern ok p e stmts
  = let fail    = hsIdent "fail"        
        failmsg = "Error: pattern-match failure in do-expression."
        mthen   = HsQVarOp (hsSymbol ">>=")
    in (HsLet [HsFunBind [HsMatch noSrcLoc (HsIdent ok) [p] (HsUnGuardedRhs (HsDo stmts)) []],HsFunBind [HsMatch noSrcLoc (HsIdent ok) [HsPWildCard] (HsUnGuardedRhs (HsApp (HsVar fail) (HsLit (HsString failmsg)))) []]] (HsInfixApp e mthen (HsVar (hsIdent ok))))

noSrcLoc = SrcLoc "" 0 0 

hsSymbol s = (UnQual (HsSymbol s))
hsIdent s  = (UnQual (HsIdent s))

new_name :: Monad m => m String
new_name = return "ok"

-- Test terms -----------------------------------------------------------------

do1
  = let silly  = HsIdent "silly"
        aap    = hsIdent "aap"
        aap'   = HsIdent "aap"
        noot   = hsIdent "noot"
        noot'  = HsIdent "noot"
        return = hsIdent "return" 
        bind   = hsSymbol ">>="
    in HsModule noSrcLoc (Module "Do1") Nothing [] [HsFunBind [HsMatch (SrcLoc "" 3 12) silly [HsPVar noot'] (HsUnGuardedRhs (HsDo [HsGenerator noSrcLoc (HsPVar aap') (HsVar noot),HsQualifier (HsApp (HsVar return) (HsVar aap))])) []]]

nodo1 
  = let silly  = HsIdent "silly"
        aap    = hsIdent "aap"
        aap'   = HsIdent "aap"
        noot   = hsIdent "noot"
        noot'  = HsIdent "noot"
        return = hsIdent "return" 
        bind   = hsSymbol ">>="
    in HsModule noSrcLoc (Module "Do1") Nothing [] [HsFunBind [HsMatch (SrcLoc "" 3 12) silly [HsPVar noot'] (HsUnGuardedRhs (HsInfixApp (HsVar noot) (HsQVarOp bind) (HsLambda noSrcLoc [HsPVar aap'] (HsApp (HsVar return) (HsVar aap))))) []]]

-------------------------------------------------------------------------------
