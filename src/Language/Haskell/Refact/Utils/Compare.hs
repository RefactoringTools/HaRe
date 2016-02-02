{-# LANGUAGE MultiParamTypeClasses, TypeFamilies, FlexibleInstances, UndecidableInstances, OverlappingInstances #-} --, RankNTypes, FlexibleInstances, FlexibleContexts, UndecidableInstances #-}
module Language.Haskell.Refact.Utils.Compare where
import Data.Generics hiding (Proxy)
import qualified GHC as GHC
import qualified GHC.SYB.Utils as SYB
--import qualified Data.Generics.SYB.WithClass.Basics as SYB
--import qualified Data.Generics.SYB.WithClass.Context as SYB

data Compare = Rep TypeRep [Compare]
               |Comp GHC.RdrName

class Comparable a where constructCompare :: a -> Compare

class Comparable' flag a where
  constructCompare' :: flag -> a -> Compare

data CTrue
data CFalse

type family CompPred a where
  CompPred GHC.RdrName = CTrue
  CompPred a           = CFalse

instance Comparable' CTrue GHC.RdrName where
  constructCompare' _ x = Comp x
instance (Data a) => Comparable' CFalse a where
  constructCompare' _ a = Rep (typeOf a) (gmapQ constructCompare' a)
{-instance Comparable GHC.RdrName where
  constructCompare n = Comp n

instance {-# INCOHERENT #-} (Data t) => Comparable t where
  constructCompare t = Rep (typeOf t) (gmapQ constructCompare t)
-}
instance Eq Compare where
  Comp a == Comp b = a == b
  Rep a lst1 == Rep b lst2 = (a == b) && (lst1 == lst2)
  _ == _ = False
  a /= b = not (a == b)

instance Show Compare where
  show (Rep a lst) = "Rep " ++ show a ++ "\n\tChildren: " ++ (show lst)
  show (Comp a) = "Comp " ++ (SYB.showData SYB.Parser 0 a)



{-class Comparable a where constructCompare :: a -> Compare t

instance Comparable GHC.RdrName where
  constructCompare = Comp

instance (Data t) => Comparable t where
  constructCompare t = Rep (typeOf t) (gmapQ constructCompare t)
-}
{-class Comparable a where constructCompare :: a -> Compare GHC.RdrName

data ComparableD a = ComparableD {conCompD :: a -> Compare GHC.RdrName}

compDProxy :: SYB.Proxy ComparableD
compDProxy = error "urk"

instance Comparable t => SYB.Sat (ComparableD t) where
  dict = ComparableD {conCompD = constructCompare}

instance (SYB.Data ComparableD t, Typeable t) => Comparable t where
  constructCompare t = Rep (typeOf t) (SYB.gmapQ compDProxy (conCompD SYB.dict) t)

instance Comparable GHC.RdrName where
  constructCompare = Comp   
-}
{-foo :: Eq b => GHC.GenLocated GHC.SrcSpan (GHC.HsExpr GHC.RdrName) -> [Compare b]
foo (GHC.L _ _) = []  

constructCompare :: (Data a, Typeable a) => a -> [Compare GHC.RdrName]
constructCompare = SYB.everything (++) ([] `SYB.mkQ` isEq `SYB.extQ` getTypeRep)
  where isEq :: GHC.RdrName -> [Compare GHC.RdrName]
        isEq a = [Comp a]
        getTypeRep :: a -> [Compare GHC.RdrName]
        getTypeRep a = [res]
          where res = (Rep . typeOf) a-}
