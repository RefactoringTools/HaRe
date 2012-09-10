#!/bin/sh

cabal clean && cabal configure --enable-tests && cabal build && cabal test
