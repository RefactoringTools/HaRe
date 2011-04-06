module TypeCheck where

import System
import Unsafe.Coerce
import Control.Exception
import System.IO.Unsafe
import System.IO
import List
import PackageConfig    ( stringToPackageId )
import GHC hiding (SrcLoc)
import DynFlags (defaultDynFlags)
import HsSyn
import Outputable
import SrcLoc
--import AbstractIO

import LocalSettings

ghcInit args 
 = unsafePerformIO (
    do
       return "GHC Initialised."
   )

ghcTypeCheck args modName =
 unsafePerformIO (
  do
   let newArgs = args ++ ".hs"
   let packageConf = ghcPath
   ses     <- GHC.newSession {-JustTypecheck-} (Just (filter (/= '\n') packageConf))
   dflags0 <- GHC.getSessionDynFlags ses

   (dflags1,fileish_args) <- GHC.parseDynamicFlags dflags0 ["-fglasgow-exts"]
   GHC.setSessionDynFlags ses $ dflags1 {verbosity = 1, hscTarget=HscInterpreted , ghcLink=NoLink }
   target <- GHC.guessTarget args Nothing
   GHC.addTarget ses target
   f <- getSessionDynFlags ses
   res <- defaultCleanupHandler f (load ses LoadAllTargets)
   case res of
      Failed ->
        do
          error "Load Failed"
      Succeeded -> 
        do
          putErrStrLn "Load succeded."
          checked <- GHC.checkModule ses (mkModuleName modName) True
          case checked of
           Nothing   -> return ses
           Just cmod -> 
             do
               let ts = typecheckedSource cmod
               return ses
  )

ghcTypeCheck1 ses2 expr modName =
  unsafePerformIO(
   do

       res <- exprType ses2 (modName ++ "." ++ expr)
       case res of
         Nothing -> error "GHC failed to load module."
         Just ty -> do
                      -- ty' <- cleanType ty
                      return $ showSDoc $ ppr ty
  )

ghcTypeCheckPattern closure closure_name modName ses2 =
  unsafePerformIO(
   do
       usermod <- findModule ses2 (mkModuleName modName) Nothing
       setContext ses2 [usermod] []
       r <- runStmt ses2 ("let " ++ closure) GHC.RunToCompletion
       res <- exprType ses2 closure_name
       
       case res of
         Nothing -> error "GHC failed to load module."
         Just ty -> do
                      -- ty' <- cleanType ty
                      return $ showSDoc $ ppr ty
  )

{- ghcEvalExpr args closure_call modName =
  unsafePerformIO(
   defaultErrorHandler defaultDynFlags $ do
   let newArgs = args ++ ".hs"
   let packageConf = ghcPath
   ses     <- GHC.newSession JustTypecheck (Just (filter (/= '\n') packageConf))
   dflags0 <- GHC.getSessionDynFlags ses

   (dflags1,fileish_args) <- GHC.parseDynamicFlags dflags0 ["-fglasgow-exts"]
   GHC.setSessionDynFlags ses $ dflags1 {verbosity = 1, hscTarget=HscInterpreted , ghcLink=NoLink }
   target <- GHC.guessTarget args Nothing
   GHC.addTarget ses target
   f <- getSessionDynFlags ses
   res <- defaultCleanupHandler f (load ses LoadAllTargets)
   case res of
      Failed ->
        do
          error "Load Failed"
      Succeeded -> 
        do
          putErrStrLn "Load succeded."
          checked <- GHC.checkModule ses (mkModuleName modName) True
          case checked of
           Nothing   -> return "-1"
           Just cmod -> 
             do
               usermod <- findModule ses (mkModuleName modName) Nothing
               putStrLn "d"
               setContext ses [usermod] []
               r <- runStmt ses (closure_call) GHC.RunToCompletion
               putStrLn "2"
               case r of
                GHC.RunOk names    -> do s <- nameToString ses (head names)
                                         case s of 
                                          Nothing -> return "-1"
                                          Just x ->  return x
                GHC.RunFailed      -> error "* Failed"
                GHC.RunException e -> error $ "* Exception: " ++ show e
                GHC.RunBreak _ _ _ -> error "* Break." 
             
               --  let ts = typecheckedSource cmod
               -- return ses
   
   
       putStrLn "first"
       -- f <- getSessionDynFlags ses2
       -- usermod <- defaultCleanupHandler f (findModule ses2 (mkModuleName modName) Nothing)
       dflags0 <- GHC.getSessionDynFlags ses2
       putStrLn "a"
       (dflags1,fileish_args) <- GHC.parseDynamicFlags dflags0 ["-fglasgow-exts"]
       putStrLn "b"
       GHC.setSessionDynFlags ses2 $ dflags1 {verbosity = 1, hscTarget=HscInterpreted , ghcLink=NoLink }
       putStrLn "c"
       usermod <- findModule ses2 (mkModuleName modName) Nothing
       putStrLn "d"
       setContext ses2 [usermod] []
       putStrLn "1"
       
    )
       
-- if -fglasgow-exts is on we show the foralls, otherwise we don't.
--  cleanType :: Type -> GHCi Type
-}
nameToString :: GHC.Session -> Name -> IO (Maybe String)                                                         
nameToString cms name = do                                                             
        dflags  <- GHC.getSessionDynFlags cms                                                                                                                                                   
        -- let noop_log _ _ _ _ = return ()                                                           
        let expr = "show " ++ showSDoc (ppr name)                                                  
        -- GHC.setSessionDynFlags cms dflags{log_action=noop_log}                                     
        mb_txt <- GHC.compileExpr cms expr                                                         
        case mb_txt of                                                                             
            Just txt_ | txt <- unsafeCoerce txt_, not (null txt)                                    
                      -> return $ Just txt                                                           
            _  -> return Nothing  


debugLog :: String -> b -> b
debugLog msg b =
  unsafePerformIO (
    do
      putErrStrLn msg
      return b
    )

logAndDump :: (Outputable a) => String -> a -> b -> b
logAndDump msg a b =
  unsafePerformIO (
    do
      putErrStrLn msg
      putErrStrLn $ showSDoc (ppr a)
      return b
    )

tidyFileName :: String -> String
tidyFileName ('.':'/':str) = str
tidyFileName str           = str

data Tag = Tag TagName TagFile TagLine TagDesc
  deriving (Eq)

instance Ord Tag where
  compare (Tag t1 _ _ _) (Tag t2 _ _ _) = compare t1 t2

instance Show Tag where
  show (Tag t f l d) = makeTagsLine t f l d

type TagName = String
type TagFile = String
type TagLine = Int
type TagDesc = String

makeTagsLine :: String -> String -> Int -> String -> String
makeTagsLine tag file line desc = tag `sep` file `sep` (show line) `sep` ";\t\"" ++ desc ++ "\""
  where a `sep` b = a ++ '\t':b


putErrStrLn = hPutStrLn stderr
putErrStr = hPutStr stderr
 
