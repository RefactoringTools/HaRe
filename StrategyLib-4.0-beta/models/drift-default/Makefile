###############################################################################
#
# Environment for makerules
#

StrategyLib = ../..
Model       = drift-default


###############################################################################
#
# Haskell sessions for debugging purposes 
#

hugs:
	hugs ${hugs-opts} ${StrategyLib}/library/StrategyLib.hs

ghci:
	ghci ${ghc-opts} ${StrategyLib}/library/StrategyLib.hs


###############################################################################
#
# Reusable includes
#

include ${StrategyLib}/scripts/makerules.opts
include ${StrategyLib}/scripts/makerules.clean
include ${StrategyLib}/scripts/makerules.check
include ${StrategyLib}/scripts/makerules.recurse
