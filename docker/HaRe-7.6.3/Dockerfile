FROM alanz/haskell-platform-2013.2.0.0-64

MAINTAINER alan.zimm@gmail.com

ENV WD /opt/haskell

ADD HaRe.cabal /opt/haskell/HaRe.cabal

CMD cabal update

CMD cd WD && cabal install --only-dependencies

# Note: to debug the partial build do the following
# docker run -i -t alanz/HaRe-7.6.3-64 /bin/bash
