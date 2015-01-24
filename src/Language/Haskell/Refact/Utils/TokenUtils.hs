{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE StandaloneDeriving   #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

-- |
--
-- This module contains an API to manage a token stream.
--
-- This API is used internally by MonadFunctions and the other utility
-- modules, it should probably never be used directly in a refactoring.

module Language.Haskell.Refact.Utils.TokenUtils (
         posToSrcSpanTok

       -- , showSrcSpan
       ) where

import qualified GHC           as GHC

import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.Types

-- ---------------------------------------------------------------------

-- |Convert a simple (start,end) position to a SrcSpan belonging to
-- the file in the given token
posToSrcSpanTok :: PosToken -> (SimpPos,SimpPos) -> GHC.SrcSpan
posToSrcSpanTok tok ((rs,cs),(re,ce)) = sspan
  where
    (GHC.L l _,_) = tok
    sspan =  case l of
      GHC.RealSrcSpan ss ->
        let
          locStart = GHC.mkSrcLoc (GHC.srcSpanFile ss) rs cs
          locEnd   = GHC.mkSrcLoc (GHC.srcSpanFile ss) re ce
        in
          GHC.mkSrcSpan locStart locEnd
      _ -> error "posToSrcSpan: invalid SrcSpan in first tok"


-- EOF
