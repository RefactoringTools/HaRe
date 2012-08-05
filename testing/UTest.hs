
module Main where

import Test.HUnit
import System.IO
-- import System hiding (system)
-- import qualified System
import qualified System.Cmd as System
import System.Exit
import System.Environment
import Data.List


data TestCases = TestCases {refactorCmd::String
                           ,positive::[([String],[String])]
                           ,negative::[([String],[String])]}
  deriving (Show,Read)


createNewFileName str fileName
  =let (name, posfix)=span (/='.') fileName
   in (name++str++posfix)

positiveTest system pfeCmd refactorCmd args
    =TestCase (do let inputFiles=fst args
                      tokExpOutputFiles=map (createNewFileName "_TokOut") inputFiles
                      --astExpOutputFiles=map (createNewFileName "_AstOut") inputFiles
                      --astActOutputFiles=map (createNewFileName "AST") inputFiles
                      tempFiles = map (createNewFileName "_temp") inputFiles
                      params =refactorCmd: ((head inputFiles) : (snd args))
                      inputTemps =zip inputFiles tempFiles
                      inputOutputs1=zip inputFiles tokExpOutputFiles
                      --inputOutputs2=zip astActOutputFiles astExpOutputFiles
                  mapM (createTempFile system) inputTemps
                  system ("echo " ++ concatMap (\t->t ++ " ") params ++ " |" ++ pfeCmd)
                  results1<-mapM (compareResult system) inputOutputs1
                  --results2<-mapM (compareResult system) inputOutputs2
                  -- ++AZ++ mapM (recoverFiles system) inputTemps
                  -- ++AZ++ mapM (rmTempFiles system) tempFiles
                  -- mapM (rmTempFiles system) astActOutputFiles
                  assertEqual (show (refactorCmd,args)) True (all (==ExitSuccess) (results1)) -- ++results2))
              )

negativeTest system pfeCmd refactorCmd args
    =TestCase (do let inputFiles = fst args
                      tokExpOutputFiles=map (createNewFileName "_TokOut") inputFiles
                      tempFiles = map (createNewFileName "_temp") inputFiles
                      params =refactorCmd: ((head inputFiles) : (snd args))
                      inputTemps =zip inputFiles tempFiles
                      inputOutputs=zip inputFiles tokExpOutputFiles
                  mapM (createTempFile system) inputTemps
                  system ("echo " ++ concatMap (\t->t ++ " ") params ++ " |" ++ pfeCmd)
                  results<-mapM (compareResult system) inputOutputs
                  mapM (recoverFiles system) inputTemps
                  mapM (rmTempFiles system) tempFiles
                  assertEqual (show (refactorCmd,args)) True (all (==ExitSuccess) results)
              )

createTempFile system (input, temp)=system ("cp "++ input++ " "++temp)

compareResult system (input,output)=system ("diff "++input++ " " ++ output)

recoverFiles system (input ,temp)= system ("cp " ++ temp ++ " " ++input)

rmTempFiles system temp = system ("rm "++temp)

testCases system pfeCmd refactorCmd positiveTests negativeTests
     =TestList ((map (positiveTest system pfeCmd refactorCmd) positiveTests)
             ++ (map (negativeTest system pfeCmd refactorCmd) negativeTests))


runTesting system hare refactorCmd positiveTests negativeTests
     =do let files=concatMap (\t->t++" ") $ nub (concatMap fst positiveTests ++ concatMap fst negativeTests)
         system ("echo new |" ++ hare)
         system ("echo add " ++ files ++ " |" ++ hare)
         system ("echo chase ../../tools/base/tests/HaskellLibraries/ |" ++ hare)
         system ("echo chase ./evalAddEvalMon/ |" ++ hare) -- ++AZ++
         system ("echo chase . |" ++ hare)
         runTestTT (testCases system hare refactorCmd positiveTests negativeTests)



main  = do
  [bash,hare] <- getArgs
  f <- readFile "UTest.data"
  let testcases = read f::TestCases
  runTesting (system bash) hare
             (refactorCmd testcases)
             (positive testcases)
             (negative testcases)


system bash cmd = --(hPutStrLn stderr cmd')>>
  (System.system cmd')
   where
      -- cmd' = cmd
      cmd' = bash++" -c \""++cmd++" >> log.txt 2>>log.txt\""
