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
import qualified Bag           as GHC
import qualified BasicTypes    as GHC
import qualified Coercion      as GHC
import qualified HsDecls       as GHC
import qualified Digraph       as GHC
import qualified DynFlags      as GHC
import qualified ErrUtils      as GHC
import qualified FastString    as GHC
import qualified ForeignCall   as GHC
import qualified GHC           as GHC
import qualified GHC.Paths     as GHC
import qualified HsPat         as GHC
import qualified HsSyn         as GHC
import qualified InstEnv       as GHC
import qualified Module        as GHC
import qualified MonadUtils    as GHC
import qualified Name          as GHC
import qualified NameSet       as GHC
import qualified OccName       as GHC
import qualified Outputable    as GHC
import qualified RdrName       as GHC
import qualified SrcLoc        as GHC
import qualified TcEvidence    as GHC
import qualified TcType        as GHC
import qualified TypeRep       as GHC
import qualified Var           as GHC

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
    bind ((GHC.PatBind _ _ _ fvs _)::(GHC.HsBindLR GHC.Name GHC.Name)) = [fvs]
    bind _ = []




