#!/bin/sh
#BASH="d:\\cygwin\\bin\\bash.exe"
BASH="bash"
HARE="../../refactorer/pfe"
#HARE="..\\..\\refactorer\\pfe"
cd ..
ghc --make -i../../HUnit-1.0 -o UTest UTest.hs
rm *.o *.hi
# avoid spurious error reports due to line-ending conventions..
case `uname` in
  CYGWIN*) 
    unix2dos *.hs 
    ;;
esac
cd ./rmOneParameter
echo "-- testing rmOneParameter"
../UTest $BASH $HARE 2>&1 | tee log.txt
