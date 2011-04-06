{-----------------------------------------------------------------------------

			Example: LITTLE LAMBDA

			     StrategyLib

                   Ralf Laemmel                Joost Visser
               CWI & VU, Amsterdam            CWI, Amsterdam

-----------------------------------------------------------------------------}

module Main where

import StrategyLib
import Monad
import Control.Monad.Identity
import Datatypes
import DatatypesTermInstances

--- Terms for testing --------------------------------------------------------

type1 = TVar "AAP"
type2 = TVar "NOOT"
type3 = Arrow type1 type2

expr1 = Var "aap"
expr2 = Var "noot"
expr3 = Apply expr1 expr2
expr4 = Lambda "mies" type3 expr3

--- Example strategies -------------------------------------------------------

isType :: Type -> Maybe Type
isType = return

containsTypes	       = once_tdTP (adhocTP failTP isType)
testContainsTypes      = applyTP containsTypes expr4

getVar :: Expr -> Identity [Identifier]
getVar (Var i)         = return [i]
getVar (Lambda i _ _ ) = return [i]
getVar _               = return []

testCollect 	:: [Identifier]
testCollect	 = runIdentity
                    (applyTU (full_tdTU (adhocTU (constTU []) getVar)) expr4)

testShow        :: [String]
testShow         = runIdentity
                    (applyTU (full_tdTU myShowTU) expr4)
 where
  myShowTU = constTU []
             `adhocTU` (\(x::Expr)-> return [show x])
             `adhocTU` (\(x::Type)-> return [show x])
             `adhocTU` (\(x::Identifier)-> return [show x])

------------------------------------------------------------------------------

main = writeFile "Test.log"
                 (  show testContainsTypes ++ "\n"
                 ++ show testCollect       ++ "\n"
                 ++ show testShow          ++ "\n"
                 )

