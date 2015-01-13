#!/bin/sh

(cd ../ghc-syb/utils                && cabal clean && cabal install --allow-newer)
(cd ../hslogger                     && cabal clean && cabal install --allow-newer)
(cd ../../DanielG/ghc-mod           && cabal clean && cabal install --allow-newer)
(cd ../ghc-exactprint               && cabal clean && cabal install --allow-newer)

cabal clean && cabal install   --allow-newer --enable-tests --dependencies-only
cabal clean && cabal configure --allow-newer --enable-tests

# Make sure the tests run against the newly installed environment
(cd test/testdata && cabal clean && cabal configure)

