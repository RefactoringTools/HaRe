module Main where

import System
import Control.Exception
import System.IO.Unsafe
import System.IO
import List
import Unsafe.Coerce
-- Package GHC stuff
import GHC
import DynFlags
import ErrUtils
import PackageConfig
import HsSyn
import Outputable
import SrcLoc
import RdrName
import Name 

import LocalSettings

main 
 = defaultErrorHandler defaultDynFlags $
   do
   ar <- getArgs
   putStrLn $ show ar
   let args = ar !! 0
       -- newArgs = (ar !! 1) ++ "hs"
       closure_call = ar !! 1
       modName = ar !! 2
   
   -- let args = "/home/cmb21//HaRe_Project/testing/subIntroPattern/ghc/InfixIn3.hs"
   let newArgs =  args ++ ".hs"

   let packageConf = ghcPath
   
   -- /usr/local/packages/ghc-6.6/lib/ghc-6.6
   session     <- GHC.newSession {-JustTypecheck-} (Just (filter (/= '\n') packageConf))
   
   dflags0 <- getSessionDynFlags session
   (f1,b) <- parseDynamicFlags dflags0 ["-fglasgow-exts", "-fno-monomorphism-restriction"]
   setSessionDynFlags session f1{hscTarget = HscInterpreted,  ghcLink=NoLink}
   
   target <- GHC.guessTarget args Nothing
   
   -- (dflags1,fileish_args) <- GHC.parseDynamicFlags dflags0 []
   -- GHC.setSessionDynFlags session $ dflags1 {verbosity = 1, hscTarget=HscNothing}
   -- targets <- mapM (\a -> GHC.guessTarget a Nothing ) [args]
   GHC.addTarget session target
   
   GHC.load session GHC.LoadAllTargets

   usermod <- findModule session (mkModuleName modName) Nothing   
   setContext session [usermod] []
        
   r <- runStmt session closure_call GHC.RunToCompletion

   
   case r of
       GHC.RunOk names    -> do s <- nameToString session (head names)
                                case s of 
                                          Nothing -> writeFile evaluate_result "-1"
                                          Just x ->  writeFile evaluate_result x
       GHC.RunFailed      -> error "* Failed"
       GHC.RunException e -> error $ "* Exception: " ++ show e
       GHC.RunBreak _ _ _ -> error "* Break." 


showNames :: [GHC.Name] -> String
showNames = Outputable.showSDoc . Outputable.ppr
 
nameToString :: GHC.Session -> Name -> IO (Maybe String)                                                         
nameToString cms name = do                                                             
        dflags  <- GHC.getSessionDynFlags cms                                                                                                                                                   
        let noop_log _ _ _ _ = return ()                                                           
            expr = "show " ++ showSDoc (ppr name)                                                  
        GHC.setSessionDynFlags cms dflags{log_action=noop_log}                                     
        mb_txt <- GHC.compileExpr cms expr                                                         
        case mb_txt of                                                                             
            Just txt_ | txt <- unsafeCoerce txt_, not (null txt)                                    
                      -> return $ Just txt                                                           
            _  -> return Nothing                                                                     
        -- `finally`                                                                                    
        --   GHC.setSessionDynFlags cms dflags 
              
 
