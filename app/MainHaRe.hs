{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}
import           Control.Exception
import           Control.Monad.Writer.Lazy
import           Data.List
import           Data.Version
import           Development.GitRev (gitCommitCount)
import           Distribution.System (buildArch)
import           Distribution.Text (display)
import           Language.Haskell.Refact.API
import           Language.Haskell.Refact.HaRe
import           Options.Applicative.Simple
import qualified Language.Haskell.GhcMod as GM
import qualified Paths_HaRe as Meta

-- temporary until exposed by ghc-mod
-- import           Options
import           Language.Haskell.GhcMod.Options.Options

main :: IO ()
main = do
    -- Version code from stack. Maybe move this stuff into optparse-simple ?
    let commitCount = $gitCommitCount
        versionString' = concat $ concat
            [ [$(simpleVersion Meta.version)]
              -- Leave out number of commits for --depth=1 clone
              -- See https://github.com/commercialhaskell/stack/issues/792
            , [" (" ++ commitCount ++ " commits)" | commitCount /= ("1"::String) &&
                                                    commitCount /= ("UNKNOWN" :: String)]
            , [" ", display buildArch]
            ]
        numericVersion :: Parser (a -> a)
        numericVersion =
            infoOption
                (showVersion Meta.version)
                (long "numeric-version" <>
                 help "Show only version number")
    -- Parse the options and run the specified command.
    (global, run) <-
        simpleOptions
            versionString'
            "HaRe - the haskell refactorer"
            ""
            -- (numericVersion <*> globalOptsParser) $
            (numericVersion <*> allOptsParser) $
            do
              addCommand "demote"
                         "Demote a declaration"
                         runCmd
                         demoteCmdOpts

              addCommand "dupdef"
                         "Duplicate a definition"
                         runCmd
                         dupDefCmdOpts

              addCommand "iftocase"
                         "Convert an if statement to a case statement"
                         runCmd
                         ifToCaseCmdOpts

              addCommand "liftOneLevel"
                         "Lift a definition up one level"
                         runCmd
                         liftOneLevelCmdOpts

              addCommand "liftToTopLevel"
                         "Lift a definition to the top level"
                         runCmd
                         liftToTopLevelCmdOpts

              addCommand "rename"
                         "Rename an identifier"
                         runCmd
                         renameCmdOpts

              addCommand "addOneParam"
                         "Add a new parameter to a function in first position"
                         runCmd
                         addOneParamCmdOpts

              addCommand "rmOneParam"
                         "Remove a new parameter from a function"
                         runCmd
                         rmOneParamCmdOpts
              addCommand "genApplicative"
                         "Generalise a monadic function to use applicative"
                         runCmd
                         genApplicativeOpts
    run global

-- ---------------------------------------------------------------------

type Row = Int
type Col = Int

data HareParams = DemoteCmd      FilePath Row Col
                | DupDefCmd      FilePath String Row Col
                | IfToCaseCmd    FilePath Row Col Row Col
                | LiftOneLevel   FilePath Row Col
                | LiftToTopLevel FilePath Row Col
                | RenameCmd      FilePath String Row Col
                | AddOneParam    FilePath String Row Col
                | RmOneParam     FilePath Row Col
                | GenApplicative FilePath String Row Col
               deriving Show

runCmd :: HareParams -> (RefactSettings,GM.Options) -> IO ()
runCmd (DemoteCmd fileName r c) (opt, gOpt)
  = runFunc $ demote opt gOpt fileName (r,c)

runCmd (DupDefCmd fileName newname r c) (opt, gOpt)
  = runFunc $ duplicateDef opt gOpt fileName newname (r,c)

runCmd (IfToCaseCmd fileName sr sc er ec) (opt, gOpt)
  = runFunc $ ifToCase opt gOpt fileName (sr,sc) (er,ec)

runCmd (LiftOneLevel fileName r c) (opt, gOpt)
  = runFunc $ liftOneLevel opt gOpt fileName (r,c)

runCmd (LiftToTopLevel fileName r c) (opt, gOpt)
  = runFunc $ liftToTopLevel opt gOpt fileName (r,c)

runCmd (RenameCmd fileName newname r c) (opt, gOpt)
  = runFunc $ rename opt gOpt fileName newname (r,c)

runCmd (AddOneParam fileName newname r c) (opt, gOpt)
  = runFunc $ addOneParameter opt gOpt fileName newname (r,c)

runCmd (RmOneParam fileName r c) (opt, gOpt)
  = runFunc $ rmOneParameter opt gOpt fileName (r,c)

runCmd (GenApplicative fileName funNm r c) (opt, gOpt)
  = runFunc $ genApplicative opt gOpt fileName funNm (r,c)

rmOneParamCmdOpts :: Parser HareParams
rmOneParamCmdOpts =
    RmOneParam
      <$> strArgument
            ( metavar "FILE"
           <> help "Specify Haskell file to process"
            )
      <*> argument auto
            ( metavar "line"
           <> help "The line the function name is on")
      <*> argument auto
            ( metavar "col"
           <> help "The col the function name starts at")

-- ---------------------------------------------------------------------

addOneParamCmdOpts :: Parser HareParams
addOneParamCmdOpts =
    AddOneParam
      <$> strArgument
            ( metavar "FILE"
           <> help "Specify Haskell file to process"
            )
      <*> strArgument
            ( metavar "NAME"
           <> help "The name for the parameter"
            )
      <*> argument auto
            ( metavar "line"
           <> help "The line the function name is on")
      <*> argument auto
            ( metavar "col"
           <> help "A col inside the function name name")

-- ---------------------------------------------------------------------

renameCmdOpts :: Parser HareParams
renameCmdOpts =
    RenameCmd
      <$> strArgument
            ( metavar "FILE"
           <> help "Specify Haskell file to process"
            )
      <*> strArgument
            ( metavar "NEWNAME"
           <> help "The new name for the identifier"
            )
      <*> argument auto
            ( metavar "line"
           <> help "The line the identifier is on")
      <*> argument auto
            ( metavar "col"
           <> help "A col inside the identifier name")

-- ---------------------------------------------------------------------

liftToTopLevelCmdOpts :: Parser HareParams
liftToTopLevelCmdOpts =
    LiftToTopLevel
      <$> strArgument
            ( metavar "FILE"
           <> help "Specify Haskell file to process"
            )
      <*> argument auto
            ( metavar "line"
           <> help "The line the declaration is on")
      <*> argument auto
            ( metavar "col"
           <> help "The col the declaration starts at")

-- ---------------------------------------------------------------------

liftOneLevelCmdOpts :: Parser HareParams
liftOneLevelCmdOpts =
    LiftOneLevel
      <$> strArgument
            ( metavar "FILE"
           <> help "Specify Haskell file to process"
            )
      <*> argument auto
            ( metavar "line"
           <> help "The line the declaration is on")
      <*> argument auto
            ( metavar "col"
           <> help "The col the declaration starts at")

-- ---------------------------------------------------------------------

ifToCaseCmdOpts :: Parser HareParams
ifToCaseCmdOpts =
    IfToCaseCmd
      <$> strArgument
            ( metavar "FILE"
           <> help "Specify Haskell file to process"
            )
      <*> argument auto
            ( metavar "startline"
           <> help "The line the if statement starts on")
      <*> argument auto
            ( metavar "startcol"
           <> help "The col the if statement starts at")

      <*> argument auto
            ( metavar "endline"
           <> help "The line the if statement ends on")
      <*> argument auto
            ( metavar "endcol"
           <> help "The col the if statement ends at")

-- ---------------------------------------------------------------------

demoteCmdOpts :: Parser HareParams
demoteCmdOpts =
    DemoteCmd
      <$> strArgument
            ( metavar "FILE"
           <> help "Specify Haskell file to process"
            )
      <*> argument auto
            ( metavar "line"
           <> help "The line the declaration is on")
      <*> argument auto
            ( metavar "col"
           <> help "The col the declaration starts at")

dupDefCmdOpts :: Parser HareParams
dupDefCmdOpts =
    DupDefCmd
      <$> strArgument
            ( metavar "FILE"
           <> help "Specify Haskell file to process"
            )
      <*> strArgument
            ( metavar "NEWNAME"
           <> help "The name for the new definition"
            )
      <*> argument auto
            ( metavar "line"
           <> help "The line the definition is on")
      <*> argument auto
            ( metavar "col"
           <> help "A col inside the definition name")

genApplicativeOpts :: Parser HareParams
genApplicativeOpts =
  GenApplicative
     <$> strArgument
          ( metavar "FILE"
         <> help "Specify Haskell file to process"
          )
      <*> strArgument
            ( metavar "FUNNAME"
           <> help "The name of the function to be refactored"
            )
      <*> argument auto
            ( metavar "line"
           <> help "The line the definition is on")
      <*> argument auto
            ( metavar "col"
           <> help "A col inside the definition name")
  


-- ---------------------------------------------------------------------

allOptsParser :: Parser (RefactSettings,GM.Options)
allOptsParser = (,) <$> globalOptsParser <*> globalArgSpec

globalOptsParser :: Parser RefactSettings
globalOptsParser = mkRefSet
     <$> ((\b -> if b then Debug else Normal) <$> switch
         ( long "debug"
        <> short 'd'
        <> help "Generate debug output" ))
  where
    mkRefSet v = RefSet v (True,True,True,True)

-- ---------------------------------------------------------------------

-- | Return the result of an Either as a sexp for emacs etc.
runFunc :: IO [String] -> IO ()
runFunc f = do
  r <- catchException f
  let ret = case r of
       Left s    -> "(error " ++ (show s) ++ ")"
       Right mfs -> "(ok " ++ showLisp mfs ++ ")"
  putStrLn ret

showLisp :: [String] -> String
showLisp xs = "(" ++ (intercalate " " $ map (\str -> "\"" ++ unixSlashes str ++ "\"") xs) ++ ")"
  where unixSlashes = map (\c -> if c == '\\' then '/' else c)

catchException :: (IO t) -> IO (Either String t)
catchException f = do
  res <- handle handler (f >>= \r -> return $ Right r)
  return res
  where
    handler:: SomeException -> IO (Either String t)
    handler e = return (Left (stripCallStack $ show e))
