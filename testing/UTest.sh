#!/bin/sh
#BASH="d:\\cygwin\\bin\\bash.exe"
BASH="bash"
HARE="../../refactorer/pfe"
#HARE="..\\..\\refactorer\\pfe"
DIRS_OLD="asPatterns  
      refacRedunDec 
      refacSlicing 
      typeSigs 
      renaming 
      demote   
      liftOneLevel 
      duplication 
      liftToToplevel 
      rmOneParameter 
      addOneParameter 
      introNewDef     
      removeDef   
      generaliseDef 
      unfoldDef 
      addToExport 
      cleanImports 
      fromConcreteToAbstract 
      mkImpExplicit 
      moveDefBtwMods 
      rmFromExport 
      pointwiseToPointfree 
    "

DIRS="addCon
addField
addOneParameter
addToExport
asPatterns
cleanImports
demote
duplication
evalAddEvalMon
evalAddEvalMonCache
evalMonad
foldDef
foldPatterns
fromConcreteToAbstract
generaliseDef
generativeFold
instantiate
introCase
introNewDef
introPattern
introThreshold
letToWhere
liftOneLevel
liftToToplevel
merging
mkImpExplicit
moveDefBtwMods
pointwiseToPointfree
refacDataNewType
refacFunDef
refacRedunDec
refacSlicing
removeCon
removeDef
removeField
renaming
rmFromExport
rmOneParameter
simplifyExpr
subIntroPattern
unfoldAsPatterns
unfoldDef
whereToLet
"

ghc --make -i./HUnit-1.0 -o UTest UTest.hs
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
   cd $d &&
   ../UTest $BASH $HARE 2>&1 | tee log.txt &&
   rm -r hi &&
   cd ..
done   
