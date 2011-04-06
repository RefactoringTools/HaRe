###############################################################################
#
# Environment for makerules
#

StrategyLib = .
Model       = drift-default
subdirs     = library models scripts examples
version     = ${shell cat VERSION}
www	    = fluit.cs.vu.nl:/home/ralf/www/Strafunski/


###############################################################################
#
# Create awareness of different checking options
#

check:
	@echo
	@echo " Options:"
	@echo "  Enter \"${MAKE} check-hugs\" to check with hugs Nov 2002."
	@echo "  Enter \"${MAKE} check-ghci\" to check with ghci 6.0.1/6.2."
	@echo "  Enter \"${MAKE} check-ghc\"  to check with ghc  6.0.1/6.2."
	@echo "  Enter \"${MAKE} check-all\"  to check everything, i.e.:"
	@echo "         - check with hugs, ghci, and ghc"
	@echo "         - regenerate all derived instances with DrIFT 2.0.1"
	@echo



###############################################################################
#
# Check everything
#

check-all:
	${MAKE} very-clean
	${MAKE} check-ghci
	${MAKE} check-ghc
#	${MAKE} check-hugs


###############################################################################
#
# Build a distribution
#

dist:
	@${RM} -r /tmp/StrategyLib-${version}
	@ln -s ${PWD} /tmp/StrategyLib-${version}
	@(cd /tmp;\
	  zip -q -r StrategyLib-${version}.zip \
	   `find StrategyLib-${version} -follow \
             -name Makefile -or -name "makerules.*" -or \
	     -name "*.hs" -or -name "*.lhs" -or\
	     -name "*.html" -or -name "*.css" -or -name "haskell_icon.gif" -or \
	     -name README -or -name AUTHORS -or -name COPYING -or \
	     -name ChangeLog -or -name INSTALL -or -name VERSION -or \
	     -name TODO -or -name TestMain -or -name "*.correct" -or \
	     -name "*.joos" | grep -v "/out/" | grep -v "out.hs"` \
	 )
	@${RM} -r /tmp/StrategyLib-${version}
	@echo "Created distribution in: /tmp/StrategyLib-${version}.zip"

distcheck:
	$(MAKE) dist
	@(cd /tmp; \
	  unzip -q /tmp/StrategyLib-${version}.zip \
	 )
	@(cd /tmp/StrategyLib-${version}; \
	  ${MAKE} check-all \
	 )
	@${RM} -rf /tmp/StrategyLib-${version}
	@echo "****************"
	@echo "/tmp/StrategyLib-${version}.zip is ready for distribution"
	@echo "****************"


###############################################################################
#
# Documentation
#

docDir		= ./documentation

haddock:
	mkdir -p ${docDir}
	haddock -o ${docDir} -h --title=StrategyLib \
	  `find ./library -name "*.hs" -or -name "*.lhs"` \
	  `find ./models/${Model} -name "*.hs" -or -name "*.lhs"`


###############################################################################
#
# Release to the Strafunski site
#

release-cp:
	scp -p /tmp/StrategyLib-${version}.zip ${www}
	scp -p -r ${docDir} ${www}

release: distcheck haddock
	gmake release-cp


###############################################################################
#
# Reusable includes
#

include ${StrategyLib}/scripts/makerules.clean
include ${StrategyLib}/scripts/makerules.check
include ${StrategyLib}/scripts/makerules.recurse

