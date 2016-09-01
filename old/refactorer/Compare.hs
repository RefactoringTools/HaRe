{-# LANGUAGE ScopedTypeVariables #-}
module Language.Haskell.Refact.Utils.Compare where
import Data.Generics as SYB hiding (Proxy)
import qualified GHC as GHC
import qualified GHC.SYB.Utils as SYB

{-
The goal of this module was to provide way to compare arbitrary chunks of Named AST. The idea was that if shape and type of the trees were the same and the leaves contained the same name then the two abstract syntax trees would be considered the same. This didn't pan out and I worked around it so I've moved the file to old for preservation.

September 2016
--Stephen Adams 
-}

data Comp = Rep SYB.TypeRep [Comp]
          | Comp GHC.RdrName

instance Eq Comp where
 Comp a == Comp b = a == b
 Rep t1 lst1 == Rep t2 lst2 = t1 == t2 && lst1 == lst2
 _ == _ = False

instance Show Comp where
  show (Rep t1 lst) = "{Rep: " ++ (show t1) ++ "\n\tchildren: " ++ (show lst) ++ "}"
  show (Comp nm) = "[Comp: " ++ (SYB.showData SYB.Parser 3 nm) ++"]"


constructComp :: (SYB.Data a) => a -> Comp
constructComp a = case mNm of
  (Just n) -> Comp n
  Nothing  -> (Rep (typeOf a) (gmapQ constructComp a))
  where mNm :: Maybe GHC.RdrName = (cast a)
