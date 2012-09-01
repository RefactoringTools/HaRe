{-# LANGUAGE RankNTypes #-}
module GhcUtils where


import Data.Generics
import GHC
import GHC.SYB.Utils
import NameSet


{-

From Data.Generics

-- | Summarise all nodes in top-down, left-to-right order
everything :: (r -> r -> r) -> GenericQ r -> GenericQ r

-- Apply f to x to summarise top-level node;
-- use gmapQ to recurse into immediate subterms;
-- use ordinary foldl to reduce list of intermediate results
-- 
everything k f x = foldl k (f x) (gmapQ (everything k f) x)

-- | A variation of 'everything', using a 'GenericQ Bool' to skip
--   parts of the input 'Data'.
everythingBut :: GenericQ Bool -> (r -> r -> r) -> r -> GenericQ r -> GenericQ r
everythingBut q k z f x 
 | q x       = z
 | otherwise = foldl k (f x) (gmapQ (everythingBut q k z f) x)



-- From GHC SYB Utils
-- | Like 'everything', but avoid known potholes, based on the 'Stage' that
--   generated the Ast.
everythingStaged :: Stage -> (r -> r -> r) -> r -> GenericQ r -> GenericQ r
everythingStaged stage k z f x 
  | (const False `extQ` postTcType `extQ` fixity `extQ` nameSet) x = z
  | otherwise = foldl k (f x) (gmapQ (everythingStaged stage k z f) x)
  where nameSet    = const (stage `elem` [Parser,TypeChecker]) :: NameSet -> Bool
        postTcType = const (stage<TypeChecker)                 :: PostTcType -> Bool
        fixity     = const (stage<Renamer)                     :: GHC.Fixity -> Bool


-}

-- TODO: pass this routine back to syb-utils (when it works properly)
-- Question: how to handle partial results in the otherwise step?
everythingButStaged :: Stage -> (r -> r -> r) -> r -> GenericQ (r,Bool) -> GenericQ r
everythingButStaged stage k z f x
  | (const False `extQ` postTcType `extQ` fixity `extQ` nameSet) x = z
  | stop == True = v
  | otherwise = foldl k v (gmapQ (everythingButStaged stage k z f) x)
  where (v, stop) = f x
        nameSet    = const (stage `elem` [Parser,TypeChecker]) :: NameSet -> Bool
        postTcType = const (stage<TypeChecker)                 :: PostTcType -> Bool
        fixity     = const (stage<Renamer)                     :: GHC.Fixity -> Bool



{-
-- | Look up a subterm by means of a maybe-typed filter
something :: GenericQ (Maybe u) -> GenericQ (Maybe u)

-- "something" can be defined in terms of "everything"
-- when a suitable "choice" operator is used for reduction
-- 
something = everything orElse
-}

-- | Look up a subterm by means of a maybe-typed filter
somethingStaged :: Stage -> (Maybe u) -> GenericQ (Maybe u) -> GenericQ (Maybe u)

-- "something" can be defined in terms of "everything"
-- when a suitable "choice" operator is used for reduction
-- 
somethingStaged stage z = everythingStaged stage orElse z

