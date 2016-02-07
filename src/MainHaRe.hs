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
import           Language.Haskell.Refact.HaRe
import           Options.Applicative.Simple
import qualified Language.Haskell.GhcMod as GM
import qualified Paths_HaRe as Meta

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
            (numericVersion <*> globalOptsParser) $
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
               deriving Show

runCmd :: HareParams -> RefactSettings -> IO ()
runCmd (DemoteCmd fileName r c) opt
  = runFunc $ demote opt GM.defaultOptions fileName (r,c)

runCmd (DupDefCmd fileName newname r c) opt
  = runFunc $ duplicateDef opt GM.defaultOptions fileName newname (r,c)

runCmd (IfToCaseCmd fileName sr sc er ec) opt
  = runFunc $ ifToCase opt GM.defaultOptions fileName (sr,sc) (er,ec)

runCmd (LiftOneLevel fileName r c) opt
  = runFunc $ liftOneLevel opt GM.defaultOptions fileName (r,c)

runCmd (LiftToTopLevel fileName r c) opt
  = runFunc $ liftToTopLevel opt GM.defaultOptions fileName (r,c)

runCmd (RenameCmd fileName newname r c) opt
  = runFunc $ rename opt GM.defaultOptions fileName newname (r,c)

-- ---------------------------------------------------------------------

renameCmdOpts :: Parser HareParams
renameCmdOpts =
    DupDefCmd
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

-- ---------------------------------------------------------------------

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


-- ---------------------------------------------------------------------

globalOptsParser :: Parser RefactSettings
globalOptsParser = mkRefSet
     <$> ((\b -> if b then Debug else Normal) <$> switch
         ( long "debug"
        <> short 'd'
        <> help "Generate debug output" ))
  where
    mkRefSet v = RefSet v (True,True,True,True)

----------------------------------------------------------------

-- | Return the result of an Either as a sexp for emacs etc.
runFunc :: IO [String] -> IO ()
runFunc f = do
  r <- catchException f
  let ret = case r of
       Left s    -> "(error " ++ (show s) ++ ")"
       Right mfs -> "(ok " ++ showLisp mfs ++ ")"
  putStrLn ret

showLisp :: [String] -> String
showLisp xs = "(" ++ (intercalate " " $ map show xs) ++ ")"

catchException :: (IO t) -> IO (Either String t)
catchException f = do
  res <- handle handler (f >>= \r -> return $ Right r)
  return res
  where
    handler:: SomeException -> IO (Either String t)
    handler e = return (Left (show e))
