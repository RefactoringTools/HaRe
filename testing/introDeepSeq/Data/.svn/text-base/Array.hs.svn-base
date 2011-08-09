{-# OPTIONS_GHC -fno-implicit-prelude #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Array 
-- Copyright   :  (c) The University of Glasgow 2001
-- License     :  BSD-style (see the file libraries/base/LICENSE)
-- 
-- Maintainer  :  libraries@haskell.org
-- Stability   :  provisional
-- Portability :  portable
--
-- Basic non-strict arrays.
--
-- /Note:/ The "Data.Array.IArray" module provides more general interface
-- to immutable arrays: it defines operations with the same names as
-- those defined below, but with more general types, and also defines
-- 'Array' instances of the relevant classes.  To use that more general
-- interface, import "Data.Array.IArray" but not "Data.Array".
-----------------------------------------------------------------------------

module  Data.Array 

    ( 
    -- * Immutable non-strict arrays
    -- $intro
      module Data.Ix		-- export all of Ix 

    -- * Array construction
    -- * Accessing arrays
    -- * Incremental array updates
    -- * Derived arrays

    -- Array instances:
    --
    --   Ix a => Functor (Array a)
    --   (Ix a, Eq b)  => Eq   (Array a b)
    --   (Ix a, Ord b) => Ord  (Array a b)
    --   (Ix a, Show a, Show b) => Show (Array a b)
    --   (Ix a, Read a, Read b) => Read (Array a b)
    -- 

    -- Implementation checked wrt. Haskell 98 lib report, 1/99.

    ) where

import Data.Ix


import Data.Typeable

{- $intro
Haskell provides indexable /arrays/, which may be thought of as functions
whose domains are isomorphic to contiguous subsets of the integers.
Functions restricted in this way can be implemented efficiently;
in particular, a programmer may reasonably expect rapid access to
the components.  To ensure the possibility of such an implementation,
arrays are treated as data, not as general functions.

Since most array functions involve the class 'Ix', this module is exported
from "Data.Array" so that modules need not import both "Data.Array" and
"Data.Ix".
-}
