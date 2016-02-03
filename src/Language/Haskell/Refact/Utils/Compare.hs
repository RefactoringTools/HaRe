{-# LANGUAGE RankNTypes, ImpredicativeTypes #-}
module Language.Haskell.Refact.Utils.Compare where
import qualified Data.Generics as SYB hiding (Proxy)
import qualified GHC as GHC
import qualified GHC.SYB.Utils as SYB



data Comp = Rep SYB.TypeRep [Comp]
          | Comp GHC.RdrName
          | Empty

instance Eq Comp where
 Comp a == Comp b = a == b
 Rep t1 lst1 == Rep t2 lst2 = t1 == t2 && lst1 == lst2
 _ == _ = False

instance Show Comp where
  show (Rep t1 lst) = (show t1) ++ " children: " ++ (show lst)
  show (Comp nm) = SYB.showData SYB.Parser 3 nm
  show Empty = ""

addComp :: Comp -> Comp -> Comp
addComp Empty c2 = c2
addComp c1 Empty = c1
addComp (Rep rep lst) c2 = Rep rep (c2:lst)
addComp c@(Comp _) _ = c


{-
class Comparable a where
  constructComp :: a -> Comp

instance {-# OVERLAPPING #-} Comparable GHC.RdrName where
  constructComp = Comp

instance {-# OVERLAPPABLE #-} (Data a) => Comparable a where
  constructComp a = Rep (typeOf a) (getChildren a)

getChildren :: (Data a) => a -> [Comp]
getChildren = gmapQ constructComp
-}

mkComp :: (SYB.Data a) => a -> Comp
mkComp = SYB.everything addComp (Empty `SYB.mkQ` isRdrName `SYB.extQ` isLoc)
  where isRdrName :: GHC.RdrName -> Comp
        isRdrName nm = Comp nm
        isLoc (GHC.L _ _) = Empty
