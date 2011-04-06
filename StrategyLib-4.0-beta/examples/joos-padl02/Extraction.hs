------------------------------------------------------------------------------

module Extraction where

import Monad
import StrategyLib hiding (replaceFocus)
import VarsAnalyses
import Datatypes


--- Method extraction --------------------------------------------------------

                                                         --- Main strategy ---

extractMethod :: (Term t, MonadPlus m) => t -> m t
extractMethod joos = applyTP (once_tdTP (monoTP extrMethFromCls)) joos

extrMethFromCls :: MonadPlus m => ClassDeclaration -> m ClassDeclaration
extrMethFromCls (ClassDecl fin nm sup fs cs ds)
  = do (pars,body) <- ifLegalGetParsAndBody ds
       ds' <- replaceFocus pars (ds++[constructMethod pars body])
       return (ClassDecl fin nm sup fs cs ds')

                        --- Check legality and extract parameters and body ---

ifLegalGetParsAndBody :: (Term t, MonadPlus m)
                      => t -> m ([([Char],Type)],Statement)
ifLegalGetParsAndBody ds
  = applyTU (once_peTU [] appendLocals ifLegalGetParsAndBody1) ds
  where ifLegalGetParsAndBody1 env
          = getFocus `passTU` \s ->
            ifthenTU (voidTP (isLegal env))
            ( freeUseVars env `passTU` \pars ->
              constTU (pars,s) )
        appendLocals env = op2TU appendMap (tryTU declVars) (constTU env)

                     --- Replace focussed statement with method invocation ---

replaceFocus :: (Term t, MonadPlus m) => [(Identifier,Type)] -> t -> m t
replaceFocus pars ds = applyTP (once_tdTP (replaceFocus1 pars)) ds
  where replaceFocus1 pars = getFocus `passTP` \_ -> 
                             monoTP (const (return (constructMethodCall pars)))

                                                        --- Legality check ---

isLegal :: MonadPlus m => [([Char],Type)] -> TP m
isLegal env        = freeDefVars env `passTP` \env' ->
                     if null env' then notTU (once_tdTU getReturn) else failTP

                                            --- Retreive focused statement ---

getFocus :: MonadPlus m => TU Statement m
getFocus =  monoTU (\s -> case s of (StatFocus s') -> return s'
                                    _              -> mzero )

                                           --- Test for a return statement ---

getReturn :: MonadPlus m => TU (Maybe Expression) m
getReturn =  monoTU (\s -> case s of (ReturnStat x) -> return x
                                     _              -> mzero )

                                                      --- Code generattion ---

constructMethod :: [(Identifier,Type)] -> Statement -> MethodDeclaration
constructMethod pars body
  = MethodDecl Nothing "newMethod"
       (FormalParams fpars) (BlockStatements [] [body])
    where fpars = map (\(v,t) -> FormalParam t v) pars

constructMethodCall :: [(Identifier,Type)] -> Statement
constructMethodCall pars
  = MethodInvocationStat 
       (ExpressionInvocation This "newMethod" (Arguments args))
    where args = map (\(v,t) -> Identifier v) pars

------------------------------------------------------------------------------
