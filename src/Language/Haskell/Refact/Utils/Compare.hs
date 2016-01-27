{-# LANGUAGE DeriveDataTypeable, RankNTypes #-}
module Language.Haskell.Refact.Utils.Compare
(constructCompare, Compare, foo) where
import Data.Generics as SYB
import qualified GHC as GHC
data Compare a = Rep TypeRep 
               | Comp a
                 deriving (Show, Typeable, Data)

instance (Eq a) => Eq (Compare a) where
  Comp a == Comp b = a == b
  Rep a == Rep b = a == b
  _ == _ = False
  a /= b = not (a == b)

foo :: Eq b => GHC.GenLocated GHC.SrcSpan (GHC.HsExpr GHC.RdrName) -> [Compare b]
foo (GHC.L _ _) = []  

constructCompare :: (Data a, Eq b, Typeable a) => a -> [Compare b]
constructCompare = SYB.everything (++) ([] `SYB.mkQ` foo)--`SYB.extQ` isEq `SYB.extQ` getTypeRep)
--   where isLocated :: (Typeable t1) => (GHC.GenLocated GHC.SrcSpan t1) -> [Compare b]
--         isLocated (GHC.L _ _) = []
--         --isEq :: (Eq b, Typeable b) => b -> [Compare b]
--         --isEq a = [Comp a]
--         {-getTypeRep :: (Typeable a) => a -> [Compare b]
--         getTypeRep a = [res]
--           where res = (Rep . typeOf) a-}
