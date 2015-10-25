{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}
import           Control.Exception
import           Control.Monad.IO.Class
import           Data.Foldable
import           Data.IORef
import           Data.Traversable
import           Data.Version (showVersion)
import           Development.GitRev (gitCommitCount)
import           Distribution.System (buildArch)
import           Distribution.Text (display)
-- import           Haskell.Ide.Monad
-- import           Haskell.Ide.Options
-- import           Haskell.Ide.Plugin
-- import           Haskell.Ide.Types
import           Options.Applicative.Simple

import Control.Exception
import Data.List
import Data.Typeable
import Data.Version
import qualified Language.Haskell.GhcMod as GM
import Language.Haskell.Refact.HaRe
import qualified Paths_HaRe as Meta
import Prelude
import System.Console.GetOpt
import System.Environment (getArgs)
import System.IO (hPutStr, hPutStrLn, stdout, stderr, hSetEncoding, utf8)


import Options.Applicative.Simple
import Text.Parsec.Combinator
-- import Text.Parsec.Prim
import Text.Parsec.Char

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
            "haskell-ide - Provide a common engine to power any Haskell IDE"
            ""
            (numericVersion <*> globalOptsParser)
            (do addCommand "demote"
                           "Demote a declaration"
                           demoteCmd
                           demoteCmdOpts)
    -- run global
    run global

-- ---------------------------------------------------------------------

type Row = Int
type Col = Int
data DemoteCmd = DemoteCmd FilePath Row Col
               deriving Show

demoteCmdOpts :: Parser DemoteCmd
demoteCmdOpts =
    DemoteCmd
      <$> (strArgument
            ( metavar "FILE"
            <> help "Specify Haskell file to process"
            ))
      <*> (argument auto
            ((metavar "line")
           <> help "The line the declaration is on"))
      <*> (argument auto
            ((metavar "col")
           <> help "The col the declaration starts at"))

-- lineVal :: Parser Int
-- lineVal = argument auto
--             ( metavar "line"
--            <> short 'n'
--            <> metavar "K"
--            <> help "Output the last K lines" )


demoteCmd :: DemoteCmd -> RefactSettings -> IO ()
demoteCmd (DemoteCmd fileName r c) opt
  = runFunc $ demote opt GM.defaultOptions fileName (r,c)

-- ---------------------------------------------------------------------

globalOptsParser :: Parser RefactSettings
globalOptsParser = RefSet
     <$> ((\b -> if b then Debug else Normal) <$> switch
         ( long "debug"
        <> short 'd'
        <> help "Generate debug output" ))
    <*> tgts

tgts :: Parser (Bool,Bool,Bool,Bool)
tgts = undefined -- (True,True,True,True)

-- =====================================================================
----------------------------------------------------------------
{-
ghcOptHelp :: String
ghcOptHelp = " [-g GHC_opt1 -g GHC_opt2 ...] "

usage :: String
usage =    "ghc-hare version " ++ showVersion version ++ "\n"
        ++ "Usage:\n"
        ++ "\t ghc-hare demote"         ++ ghcOptHelp ++ "filename line col\n"
        ++ "\t ghc-hare dupdef"         ++ ghcOptHelp ++ "filename newname line col\n"
        ++ "\t ghc-hare iftocase"       ++ ghcOptHelp ++ "filename startline startcol endline endcol\n"
        ++ "\t ghc-hare liftOneLevel"   ++ ghcOptHelp ++ "filename line col\n"
        ++ "\t ghc-hare liftToTopLevel" ++ ghcOptHelp ++ "filename line col\n"
        ++ "\t ghc-hare rename"         ++ ghcOptHelp ++ "filename newname line col\n"
        ++ "\t ghc-hare help\n"

----------------------------------------------------------------

argspec :: [OptDescr (RefactSettings -> RefactSettings)]
argspec = [
            Option "v" ["verbose"]
              (NoArg (\opts -> opts { rsetVerboseLevel = Debug }))
              "debug logging on"
          ]

parseArgs :: [OptDescr (RefactSettings -> RefactSettings)] -> [String] -> (RefactSettings, [String])
parseArgs spec argv
    = case getOpt Permute spec argv of
        (o,n,[]  ) -> (foldr id defaultSettings o, n)
        (_,_,errs) -> throw (CmdArg errs)

----------------------------------------------------------------

data HareError = SafeList
                 | NoSuchCommand String
                 | CmdArg [String]
                 | FileNotExist String deriving (Show, Typeable)

instance Exception HareError

----------------------------------------------------------------

_main :: IO ()
_main = flip catches handlers $ do
    hSetEncoding stdout utf8
    args <- getArgs
    let (opt,cmdArg) = parseArgs argspec args
    let cmdArg0 = cmdArg !. 0
        cmdArg1 = cmdArg !. 1
        cmdArg2 = cmdArg !. 2
        cmdArg3 = cmdArg !. 3
        cmdArg4 = cmdArg !. 4
        cmdArg5 = cmdArg !. 5
    -- putStrLn $ "cmdArg0=" ++ cmdArg0
    res <- case cmdArg0 of
      -- demote wants FilePath -> SimpPos
      "demote" -> runFunc $ demote opt defaultOptions cmdArg1 (parseSimpPos cmdArg2 cmdArg3)

      -- dupdef wants FilePath -> String -> SimpPos
      "dupdef" -> runFunc $ duplicateDef opt defaultOptions cmdArg1 cmdArg2 (parseSimpPos cmdArg3 cmdArg4)

      -- iftocase wants FilePath -> SimpPos -> SimpPos
      "iftocase" -> runFunc $ ifToCase opt defaultOptions cmdArg1 (parseSimpPos cmdArg2 cmdArg3) (parseSimpPos cmdArg4 cmdArg5)

      -- liftOneLevel wants FilePath -> SimpPos
      "liftOneLevel" -> runFunc $ liftOneLevel opt defaultOptions cmdArg1 (parseSimpPos cmdArg2 cmdArg3)

      -- liftToTopLevel wants FilePath -> SimpPos
      "liftToTopLevel" -> runFunc $ liftToTopLevel opt defaultOptions cmdArg1 (parseSimpPos cmdArg2 cmdArg3)

      -- rename wants FilePath -> String -> SimpPos
      "rename" -> runFunc $ rename opt defaultOptions cmdArg1 cmdArg2 (parseSimpPos cmdArg3 cmdArg4)

      -- roundtrip wants FilePath
      "roundtrip" -> runFunc $ roundTrip opt defaultOptions cmdArg1

      "show" -> putStrLn  (show (opt))

      cmd      -> throw (NoSuchCommand cmd)
    -- putStr (show res)
    -- putStr $ "(ok " ++ showLisp mfs ++ ")"
    return ()
  where
    handlers = [Handler handler1, Handler handler2]

    handler1 :: ErrorCall -> IO ()
    handler1 = print -- for debug

    handler2 :: HareError -> IO ()
    handler2 SafeList = printUsage
    handler2 (NoSuchCommand cmd) = do
        hPutStrLn stderr $ "\"" ++ cmd ++ "\" not supported"
        printUsage
    handler2 (CmdArg errs) = do
        mapM_ (hPutStr stderr) errs
        printUsage
    handler2 (FileNotExist file) = do
        hPutStrLn stderr $ "\"" ++ file ++ "\" not found"
        printUsage

    printUsage = hPutStrLn stderr $ '\n' : usageInfo usage argspec
    xs !. idx
      | length xs <= idx = throw SafeList
      | otherwise = xs !! idx

-}
----------------------------------------------------------------

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

{-
----------------------------------------------------------------

parseSimpPos :: String -> String -> SimpPos
parseSimpPos str1 str2 = case (parse rowCol "" ((str1 ++ " " ++ str2))) of
                          Left err -> throw (CmdArg [(show err)])
                          Right val -> val

rowCol :: P (Int,Int)
rowCol = do
  row <- number "line number"
  _ <- spaces
  col <- number "column number"
  return (fromIntegral row, fromIntegral col)

type P = Parsec String ()


number :: String -> P Integer
number expectedStr = do { ds <- many1 digit; return (read ds) } <?> expectedStr

----------------------------------------------------------------

-}
