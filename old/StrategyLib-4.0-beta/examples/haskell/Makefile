# refer to StrategyLib top-level directory
StrategyLib = ../..
Model       = drift-default

# find source of Language.Haskell.Syntax
Syntax      = ${shell locate -n1 libraries/Language/Haskell/Syntax.hs}

# list the modules to be derived with DrIFT
derive=SyntaxTermInstances.hs

# include the reusable makerules
include ${StrategyLib}/scripts/makerules.opts
include ${StrategyLib}/scripts/makerules.run
include ${StrategyLib}/scripts/makerules.drift
include ${StrategyLib}/scripts/makerules.clean
include ${StrategyLib}/scripts/makerules.recurse

hugs-opts   += +N +o

## The top level targets:

check-hugs: check-HsTransform-hugs check-HsExtract-hugs

check-ghci:

check-ghc: check-HsTransform-ghc check-HsExtract-ghc

## Auxiliary targets:

check-HsExtract-hugs: derive
	(cd testsuite; runhugs Top)
	$(RM) -rf out
	mkdir out
	runhugs ${hugs-opts} HsExtract.hs testsuite Top out
	(cd out; runhugs Top)
	
check-HsExtract-ghc: derive
	(cd testsuite; runhugs Top)
	$(RM) -rf out
	mkdir out
	ghc ${ghc-opts} --make HsExtract.hs -o HsExtract
	./HsExtract testsuite Top out
	(cd out; runhugs Top)

check-HsTransform-hugs: derive
	$(RM) -f TestDoElim_out.hs
	runhugs ${hugs-opts} HsTransform.hs TestDoElim.hs TestDoElim_out.hs
	diff TestDoElim_out.hs TestDoElim_correct.hs

check-HsTransform-ghc: derive
	$(RM) -f TestDoElim_out.hs
	ghc ${ghc-opts} --make HsTransform.hs -o HsTransform
	./HsTransform TestDoElim.hs TestDoElim_out.hs
	diff TestDoElim_out.hs TestDoElim_correct.hs

SyntaxTermInstances.hs: ${Syntax}
	echo "module SyntaxTermInstances where" > $@
	echo "import Language.Haskell.Syntax" >> $@
	echo "import TermRep" >> $@
	DrIFT -g Term -g Typeable -r $< >> $@
	
