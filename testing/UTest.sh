#!/bin/sh
#BASH="d:\\cygwin\\bin\\bash.exe"
BASH="bash"
HARE="../../refactorer/pfe"
#HARE="..\\..\\refactorer\\pfe"
DIRS="asPatterns \ 
      refacRedunDec \
      refacSlicing \
      typeSigs \
      renaming \
      demote   \
      liftOneLevel \
      duplication \
      liftToToplevel \
      rmOneParameter \
      addOneParameter \
      introNewDef     \
      removeDef   \
      generaliseDef \
      unfoldDef \
      addToExport \
      cleanImports \
      fromConcreteToAbstract \
      mkImpExplicit \
      moveDefBtwMods \
      rmFromExport \
      pointwiseToPointfree 
    "

ghc --make -i../../HUnit-1.0 -o UTest UTest.hs
rm *.o *.hi

# avoid spurious error reports due to line-ending conventions..
case `uname` in
  CYGWIN*) 
    unix2dos */*.hs */*/*.hs
    ;;
esac

for d in $DIRS
do
   echo "-- testing $d"
   cd $d
   ../UTest $BASH $HARE 2>&1 | tee log.txt
   rm -r hi
   cd ..
done   
