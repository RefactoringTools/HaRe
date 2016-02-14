#!/bin/sh

(cd ../../ekmett/either             && cabal clean && cabal install --allow-newer)
(cd ../../alanz/fclabels            && cabal clean && cabal install --allow-newer)
(cd ../../DanielG/cabal-helper      && cabal clean && cabal install --allow-newer)
(cd ../../DanielG/ghc-mod           && cabal clean && cabal install --allow-newer)
(cd ../../alanz/ghc-exactprint      && cabal clean && cabal install --allow-newer)
cabal install Strafunski-StrategyLib --allow-newer

cabal clean && cabal install    --enable-tests --dependencies-only --allow-newer
cabal clean && cabal configure  --enable-tests

