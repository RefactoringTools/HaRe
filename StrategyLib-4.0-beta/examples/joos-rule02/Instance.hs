module Instance where

import Prelude
import Monad
import Control.Monad.Identity
import Data.List
import StrategyLib
import Datatypes
import DatatypesTermInstances


-- Datatype for types of relevant JOOS identifiers
data TypeJoos = ExprType Type

-- not needed for the present refactorings
              | MethodType (Maybe Type) Formals

                                      
-- Declared names (with type)
declaredJoos :: TU [(Identifier,TypeJoos)] Identity
declaredJoos =  adhocTU (adhocTU (constTU [])  
                  (Identity . declaredBlock))  
                  (Identity . declaredMeth)
  where
    declaredBlock (Block vds _)
      = map (\(VarDecl t i) -> (i,ExprType t)) vds
    declaredMeth (MethodDecl r i f@(Formals fps) _)
      = map (\(Formal t i) -> (i,ExprType t)) fps



-- Defined names (without type)
definedJoos :: TU [Identifier] Identity
definedJoos =  adhocTU (constTU []) (Identity . definedAssignment)
  where
   definedAssignment (Assignment i _) = [i]



-- Used names (without type)
usedJoos :: TU [Identifier] Identity
usedJoos =  adhocTU (adhocTU (constTU [])
              (Identity . usedExpression))
              (Identity . usedInvocation)
  where
    -- needed for extract
    usedExpression (Identifier i) = [i]
    usedExpression _              = []

    -- needed for eliminate but not for introduce and extract
    usedInvocation (ExpressionInvocation _ i _) = [i]
    usedInvocation (SuperInvocation i _)        = [i]



-- Referenced names (without type)
referencedJoos :: TU [Identifier] Identity
referencedJoos =  op2TU (++) definedJoos usedJoos



-- Method abstractions as needed for method extraction
instance Abstraction
           MethodDecl           -- abstr
           Identifier           -- name
           TypeJoos             -- tpe
           Statement            -- apply
  where
    getAbstrName  (MethodDecl _ i _ _) = Just i

    getAbstrParas (MethodDecl _ _ (Formals fps) _) =
      Just (map (\(Formal t i) -> (i,ExprType t)) fps)

    getAbstrBody  (MethodDecl _ _ _ b)  = Just (BlockStat b)

    getApplyName (MethodInvocationStat
                  (ExpressionInvocation This n _)) = Just n

    getApplyParas = undefined

    constrAbstr n l a =
      maybe Nothing
            (\fps -> Just (MethodDecl Nothing n (Formals fps) (toBlock a)))
            (mapM toFormal l)
     where
       toBlock a = Block [] [a]
       toFormal (i,tpe) = case tpe of
                           ExprType t -> Just (Formal t i)
                           _          -> Nothing      

    constrApply n l =
      maybe Nothing
            (\aps -> Just (MethodInvocationStat
                           (ExpressionInvocation This n (Arguments aps))))
            (mapM toActual l)
     where
       toActual (i,tpe) = case tpe of
                           ExprType _ -> Just (Identifier i)
                           _          -> Nothing


-- Focus on statements
wrapStatement = StatementFocus
unwrapStatement (StatementFocus x) = Just x
unwrapStatement _                  = Nothing

-- Focus on a list of method declarations
wrapMethods xs = [MethodDeclFocus xs]
unwrapMethods [MethodDeclFocus xs] = Just xs
unwrapMethods _                    = Nothing

-- Focus on a single method declaration
wrapMethod x = MethodDeclFocus [x]
unwrapMethod (MethodDeclFocus [x]) = Just x
unwrapMethod _                 = Nothing



-- Type of transformation on JOOS programs
type TrafoJoos = Program -> Maybe Program



-- Introduction of a method declaration
introduceJoos :: MethodDecl -> TrafoJoos
introduceJoos =  introduce declaredJoos referencedJoos unwrapMethods



-- Extraction of a statement to constitute a new method declaration
extractJoos :: Identifier -> TrafoJoos
extractJoos = extract
               declaredJoos
               referencedJoos
               unwrapStatement
               wrapMethods
               unwrapMethods
               check
 where
  check _ f = and [noReturns f, noFrees f]
  noReturns = maybe True (const False) .
              applyTU (once_tdTU (adhocTU failTU
                (\s -> case s of
                   ReturnStat _ -> Just ()
                   _            -> Nothing)))
  noFrees = (==) [] . freeNames declaredJoos definedJoos


-- Elimination of JOOS method declarations
eliminateJoos :: TrafoJoos
eliminateJoos = eliminate declaredJoos referencedJoos unwrapMethod
