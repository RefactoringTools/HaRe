#!/bin/sh

#(cd ../../alanz/ghc-mod             && cabal clean && cabal install --allow-newer)

cabal clean && cabal install    --enable-tests --dependencies-only
cabal clean && cabal configure  --enable-tests

# Make sure the tests run against the newly installed environment
(cd test/testdata && cabal clean && cabal configure)

(cd test/testdata/cabal/cabal3 && cabal clean && cabal configure)
(cd test/testdata/cabal/cabal1 && cabal clean && cabal configure)
(cd test/testdata/cabal/cabal2 && cabal clean && cabal configure)
