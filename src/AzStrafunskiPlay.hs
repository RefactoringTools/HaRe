{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}

import           TestUtils

import qualified Data.Generics         as SYB
import qualified GHC.SYB.Utils         as SYB

import qualified Bag        as GHC
import qualified FastString as GHC
import qualified GHC        as GHC
import qualified GhcMonad   as GHC
import qualified Name       as GHC
import qualified NameSet    as GHC
import qualified OccName    as GHC
import qualified Outputable as GHC
import qualified RdrName    as GHC
import qualified SrcLoc     as GHC
import qualified Module     as GHC

import Control.Monad.State
import Data.Maybe
import Language.Haskell.Refact.Utils
-- import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.MonadFunctions
import Language.Haskell.Refact.Utils.TokenUtils
import Language.Haskell.Refact.Utils.TokenUtilsTypes
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils


import Data.List

import Data.Generics.Strafunski.StrategyLib.StrategyLib

-- ---------------------------------------------------------------------

main :: IO ()
main = pp


pp :: IO ()
pp = do
  (t, _toks) <- parsedFileDeclareSGhc
  let renamed = fromJust $ GHC.tm_renamed_source t
  putStrLn $ "GHC AST:" ++ (SYB.showData SYB.Renamer 0 renamed)
  r <- traverseTU2 renamed
  putStrLn $ "r=" ++ (show r)

-- ---------------------------------------------------------------------

traverseTU2 :: (SYB.Data t, MonadPlus m) => t -> m [String]
traverseTU2 t = do
   applyTU (full_tdTUGhc (failTU -- `adhocTU` expr
   -- applyTU (full_tdTUGhc (failTU `adhocTU` ff
   -- applyTU (full_tdTUGhc (gg `adhocTU` ff
                                      )) t

-- ---------------------------------------------------------------------

-- | Full type-unifying traversal in top-down order.
full_tdTUGhc 	:: (MonadPlus m, Monoid a) => TU a m -> TU a m
full_tdTUGhc s	=  op2TU mappend s (allTUGhc' (full_tdTUGhc s))

allTUGhc :: (MonadPlus m) => (a -> a -> a) -> a -> TU a m -> TU a m
allTUGhc op2 u s  = ifTU checkItemRenamer' (const $ constTU u) (allTU op2 u s)

allTUGhc' :: (MonadPlus m, Monoid a) => TU a m -> TU a m
allTUGhc' = allTUGhc mappend mempty

{-

-- | If 'c' succeeds, pass its value to the then-clause 't',
--   otherwise revert to the else-clause 'e'.
ifS       :: StrategyPlus s m => TU u m -> (u -> s m) -> s m -> s m
ifS c t e =  ((c `passTU` (constTU . Just)) `choiceTU` constTU Nothing)
             `passS`
             maybe e t

-- | If 'c' succeeds, pass its value to the then-clause 't',
--   otherwise revert to the else-clause 'e'.
ifTU      :: MonadPlus m => TU u m -> (u -> TU u' m) -> TU u' m -> TU u' m
ifTU      =  ifS

choiceTU 	:: MonadPlus m => TU a m -> TU a m -> TU a m
choiceTU f g	=  MkTU ((unTU f) `mchoice` (unTU g))

newtype Monad m =>
        TU a m =
                 MkTU (forall x. Data x => x -> m a)

unTU (MkTU f)	 = f

paraTU 		:: Monad m => (forall t. t -> m a) -> TU a m
paraTU f	=  MkTU f


-- | Type-unifying failure. Always fails, independent of the incoming
--   term. Uses 'MonadPlus' to model partiality.
failTU          :: MonadPlus m => TU a m
failTU          =  paraTU (const mzero)

applyTU 	:: (Monad m, Data x) => TU a m -> x -> m a
applyTU         =  unTU

-- | Parallel combination of two type-unifying strategies with a binary
--   combinator. In other words, the values resulting from applying the
--   type-unifying strategies are combined to a final value by applying
--   the combinator 'o'.

op2TU :: Monad m => (a -> b -> c) -> TU a m -> TU b m -> TU c m
op2TU o s s' =  s  `passTU` \a ->
                s' `passTU` \b ->
                constTU (o a b)

passTU 		:: Monad m => TU a m -> (a -> TU b m) -> TU b m
passTU f g	=  MkTU ((unTU f) `mlet` (\y -> unTU (g y)))

-- | Sequential composition with value passing; a kind of monadic let.
mlet 		:: Monad m => (a -> m b) -> (b -> a -> m c) -> a -> m c
f `mlet` g    	=  \x -> f x >>= \y -> g y x

-- | Choice combinator for monadic functions
mchoice 	:: MonadPlus m => (a -> m b) -> (a -> m b) -> a -> m b
f `mchoice` g 	=  \x -> (f x) `mplus` (g x)

adhocTU :: (Monad m, Data t) => TU a m -> (t -> m a) -> TU a m
adhocTU s f = MkTU (unTU s `extQ` f)

-}


checkItemStage' :: forall m. (MonadPlus m) => SYB.Stage -> TU () m
checkItemStage' stage = failTU `adhocTU` postTcType `adhocTU` fixity `adhocTU` nameSet
  where nameSet    = const (guard $ stage `elem` [SYB.Parser,SYB.TypeChecker]) :: GHC.NameSet -> m ()
        postTcType = const (guard $ stage < SYB.TypeChecker                  ) :: GHC.PostTcType -> m ()
        fixity     = const (guard $ stage < SYB.Renamer                      ) :: GHC.Fixity -> m ()

checkItemRenamer' :: (MonadPlus m) => TU () m
checkItemRenamer' = checkItemStage' SYB.Renamer

-- ---------------------------------------------------------------------

parsedFileDeclareSGhc :: IO (ParseResult,[PosToken])
parsedFileDeclareSGhc = parsedFileGhc "./test/testdata/FreeAndDeclared/DeclareS.hs"


