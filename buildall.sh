#!/bin/sh

cabal clean && cabal configure --enable-tests --enable-library-coverage -fhpc --enable-library-profiling --enable-executable-profiling && cabal build && cabal test
#cabal clean && cabal configure --enable-tests && cabal build && cabal test
#mkdir ./dist/coverage
#hpc report  ./dist/hpc/tix/spec/spec.tix
#hpc markup --destdir=./dist/coverage ./dist/hpc/tix/spec/spec.tix

