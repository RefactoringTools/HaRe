###############################################################################
#
# Environment for makerules
#

StrategyLib = ../../..
Model       = drift-default

tests =	fowler.log			\
	fowlerAssign.log		\
	fowlerDoubles.log		\
	fowlerWrongAssign.log		\
	fowlerWrongReturn.log


###############################################################################
#
# Reusable includes
#

include ${StrategyLib}/scripts/makerules.all
include ${StrategyLib}/scripts/makerules.opts
include ${StrategyLib}/scripts/makerules.clean
include ${StrategyLib}/scripts/makerules.recurse


###############################################################################
#
# Testsuite is only tested with runhugs.
#

check-hugs:
	(cd ..; ${MAKE} derive)
	rm -f *.log
	${MAKE} ${tests}

check-ghci:

check-ghc:


###############################################################################
#
# Rules for producing test logs
#

%.log: %.joos
	runhugs	${hugs-opts} -P..: Main.hs $*.joos $*.log
	diff $*.log $*.correct
