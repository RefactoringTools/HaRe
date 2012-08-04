module Main where

import System.Environment
import Control.Exception
-- import System.IO.Unsafe
import System.IO
import Data.List
-- import Unsafe.Coerce
{-
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
-}
import Control.Monad
--import Language.Haskell.Interpreter hiding (runGhc)
import Language.Haskell.Interpreter
import LocalSettings (evaluate_result)




main
 = -- defaultErrorHandler defaultDynFlags $
   do
   ar <- getArgs
   putStrLn "here"
   let args = ar !! 0   -- ++AZ+++ This seems to be a filename
       -- newArgs = (ar !! 1) ++ "hs"
       closure_call = ar !! 1  -- ++AZ++ seems to be pretty print rendering of
       modName = ar !! 2
   -- error $ show (closure_call, modName, args)
   let newArgs =  args ++ ".hs"

   -- ++AZ++ let packageConf = ghcPath
   -- (eval_res, x) <- runEval args modName closure_call packageConf
   -- x <- runInterpreter (runEvalHint args modName closure_call)
   x <- runInterpreter (runEvalHint args modName closure_call)
   -- 
   case x of
     Left err -> printInterpreterError err
     Right x -> do putStrLn $ show (x)
                   writeFile evaluate_result x

printInterpreterError :: InterpreterError -> IO ()
printInterpreterError e = error $ "Ups... " ++ (show e)

runEvalHint args modName closure_call
 = do
      -- ++AZ++ : if this line is in, the loadmodules fails with missing Prelude 
      -- ++AZ++ set [languageExtensions := [OverlappingInstances]]

      loadModules [args]

      setTopLevelModules [modName]
      liftIO (putStrLn ("about to evaluate...>" ++ modName ++ "<"))
      setImportsQ [("Prelude", Nothing)]
      let expr1 = (modName ++ "." ++ closure_call)
      -- eval :: MonadInterpreter m => String -> m StringSource
      -- eval expr will evaluate show expr. It will succeed only if expr has type t and there is a Show instance for t.

      a <- eval expr1 
      liftIO (putStrLn ("done evaluation: got...>" ++ (show a) ++ "<")) -- ++AZ++
      return a


-- NOTE ++AZ++ :this function not present in 0.6.0.2
{-
runEval args modName closure_call pac = runGhc (Just pac) $ do
   -- /usr/local/packages/ghc-6.6/lib/ghc-6.6
   --session     <- GHC.newSession {-JustTypecheck-} (Just (filter (/= '\n') packageConf))

   dflags0 <- getSessionDynFlags
   (f1,_,_) <- parseDynamicFlags dflags0 [noLoc "-fglasgow-exts", noLoc "-fno-monomorphism-restriction"]
   setSessionDynFlags f1{hscTarget = HscInterpreted,  ghcLink=NoLink}

   target <- GHC.guessTarget args Nothing

   -- (dflags1,fileish_args) <- GHC.parseDynamicFlags dflags0 []
   -- GHC.setSessionDynFlags session $ dflags1 {verbosity = 1, hscTarget=HscNothing}
   -- targets <- mapM (\a -> GHC.guessTarget a Nothing ) [args]
   GHC.addTarget {-session-} target

   GHC.load {-session-} GHC.LoadAllTargets

   -- findModule :: GhcMonad m => ModuleName -> Maybe FastString -> m Module
   usermod <- findModule (mkModuleName modName) Nothing
   -- setContext [usermod] []

   -- setContext :: GhcMonad m => [InteractiveImport] -> m ()
   setContext [IIModule usermod]

   r <- runStmt closure_call GHC.RunToCompletion

{-
RunOk [Name]	-- names bound by this evaluation
RunException SomeException	-- statement raised an exception
RunBreak ThreadId [Name] (Maybe BreakInfo)
-}

   case r of
       GHC.RunOk names    -> do s <- nameToString (head names)
                                case s of
                                          Nothing -> return (evaluate_result, "-1")  -- writeFile evaluate_result "-1"
                                          Just x ->  return (evaluate_result, x) -- writeFile evaluate_result x
       -- GHC.RunFailed      -> error "* Failed"
       GHC.RunException e -> error $ "* Exception: " ++ show e
       GHC.RunBreak _ _ _ -> error "* Break."


showNames :: [GHC.Name] -> String
showNames = Outputable.showSDoc . Outputable.ppr

nameToString :: Name -> Ghc (Maybe String)
nameToString name = do
        dflags  <- GHC.getSessionDynFlags
        let noop_log _ _ _ _ = return ()
            expr = "show " ++ showSDoc (ppr name)
        GHC.setSessionDynFlags dflags{log_action=noop_log}
        mb_txt <- GHC.compileExpr expr
        -- case mb_txt of
        txt <- unsafeCoerce mb_txt
        return $ Just txt
        --    _  -> return Nothing
        -- `finally`
        --   GHC.setSessionDynFlags cms dflags

-}
