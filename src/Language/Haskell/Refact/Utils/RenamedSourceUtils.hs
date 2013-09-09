{-# LANGUAGE ScopedTypeVariables #-}
-- |
--
-- This module contains utilities that operate on the GHC RenamedSource
--
module Language.Haskell.Refact.Utils.RenamedSourceUtils
 (
 getFreeVariables
 ) where

-- Modules from GHC
import qualified GHC           as GHC
import qualified NameSet       as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

-- ---------------------------------------------------------------------

getFreeVariables :: (SYB.Data t, SYB.Typeable t) => t -> [GHC.NameSet]
getFreeVariables t = res
  where
    res = SYB.everythingStaged SYB.Renamer (++) []
       ([] `SYB.mkQ` bind) t

    -- bind :: (SYB.Data a, SYB.Typeable a) => a -> [GHC.NameSet]
    bind ((GHC.FunBind _ _ _ _ fvs _)::(GHC.HsBindLR GHC.Name GHC.Name)) = [fvs]
    bind ((GHC.PatBind _ _ _ fvs _)  ::(GHC.HsBindLR GHC.Name GHC.Name)) = [fvs]
    bind _ = []




