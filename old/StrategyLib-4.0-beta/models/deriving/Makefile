###############################################################################
#
# Environment for makerules
# This model only works with GHC HEAD; so put in your path :-)
#

StrategyLib = ../..
Model       = ghc-deriving
ghci        = /home/ralf/cvsprojects/cvs.haskell.org/fptools/ghc/compiler/stage2/ghc-inplace --interactive


###############################################################################
#
# ghci session for debugging purposes 
#

ghci:
	${ghci} ${ghc-opts} StrategyPrimitives.hs

#	${ghci} ${ghc-opts} ${StrategyLib}/library/StrategyLib.hs


###############################################################################
#
# Reusable includes
#

include ${StrategyLib}/scripts/makerules.opts
include ${StrategyLib}/scripts/makerules.clean
include ${StrategyLib}/scripts/makerules.check
include ${StrategyLib}/scripts/makerules.recurse
