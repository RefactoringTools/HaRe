###############################################################################
#
# Environment for makerules
# This model only works with >= GHC 6.2
#

StrategyLib = ../..
Model       = deriving


###############################################################################
#
# Run targets for a specific GHC version
#

run-ghci:
	ghci ${ghc-opts} Main.hs < ${StrategyLib}/scripts/TestMain
	diff Test.log Test.correct

run-ghc:
	@echo "To be implemented."


###############################################################################
#
# Remaining run and check targets are empty because:
#  - it does not work for hugs anyway (so no run-hugs and check-hugs),
#  - and only works for specific version of ghc (so no check-ghc*).
#

run-hugs:

check-hugs:

check-ghc:

check-ghci:


###############################################################################
#
# Reusable includes
#

include ${StrategyLib}/scripts/makerules.opts
include ${StrategyLib}/scripts/makerules.drift
include ${StrategyLib}/scripts/makerules.clean
include ${StrategyLib}/scripts/makerules.recurse
