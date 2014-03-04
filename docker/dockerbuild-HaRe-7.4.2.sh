#!/bin/bash

cp ../HaRe.cabal ./HaRe-7.4.2/

docker build -t alanz/HaRe-7.4.2-64 ./HaRe-7.4.2

# docker push alanz/HaRe-7.4.2-64



# Note: to debug the partial build do the following
# docker run -i -t alanz/HaRe-7.4.2-64 /bin/bash
