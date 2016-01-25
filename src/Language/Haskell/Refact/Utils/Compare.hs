{-# LANGUAGE DeriveDataTypeable #-}
module Language.Haskell.Refact.Utils.Compare
(constructCompare, Compare) where
import Data.Generics as SYB
import qualified GHC as GHC
data Compare a = Rep TypeRep
               | Comp a
                 deriving (Show, Eq, Typeable, Data)


constructCompare :: (Data a, Eq b, Data b) => a -> [Compare b]
constructCompare = SYB.everything (++) ([] `SYB.mkQ` isLocated `SYB.extQ` isEq `SYB.extQ` getTypeRep)
  where isLocated :: (GHC.Located a) -> [Compare a]
        isLocated l = []
        isEq :: (Eq a) => a -> [Compare a]
        isEq a = [Comp a]
        getTypeRep :: (Typeable a) => a -> [Compare a]
        getTypeRep a = [res]
          where res = (Rep . typeOf) a
