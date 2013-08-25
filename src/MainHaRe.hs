{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}

-- Based on
-- https://github.com/kazu-yamamoto/ghc-mod/blob/master/src/GHCMod.hs

import Control.Applicative
import Control.Exception
import Data.List
import Data.Maybe
import Data.Typeable
import Data.Version
import Exception
import Language.Haskell.GhcMod
import Language.Haskell.Refact.Case
import Language.Haskell.Refact.DupDef
import Language.Haskell.Refact.MoveDef
import Language.Haskell.Refact.Renaming
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn
import Paths_HaRe
import Prelude
import System.Console.GetOpt
import System.Directory
import System.Environment (getArgs)
import System.IO (hPutStr, hPutStrLn, stdout, stderr, hSetEncoding, utf8)

import qualified Data.Text as T
import Data.Text (Text)
import Text.Parsec.Combinator
import Text.Parsec.Prim
import Text.Parsec.Error
import Text.Parsec.Char
import Text.Parsec.Token

----------------------------------------------------------------

ghcOptHelp :: String
ghcOptHelp = " [-g GHC_opt1 -g GHC_opt2 ...] "

usage :: String
usage =    "ghc-hare version " ++ showVersion version ++ "\n"
        ++ "Usage:\n"
        ++ "\t ghc-hare iftocase" ++ ghcOptHelp ++ "[-l]\n"
        ++ "\t ghc-hare dupdef" ++ ghcOptHelp ++ "[-l]\n"
        ++ "\t ghc-hare liftToTopLevel" ++ ghcOptHelp ++ "[-l]\n"
        ++ "\t ghc-hare liftOneLevel" ++ ghcOptHelp ++ "[-l]\n"
        ++ "\t ghc-hare demote" ++ ghcOptHelp ++ "[-l]\n"
        ++ "\t ghc-hare rename" ++ ghcOptHelp ++ "[-l]\n"
        ++ "\t ghc-hare help\n"

{-
        ++ "\t ghc-hare list" ++ ghcOptHelp ++ "[-l]\n"
        ++ "\t ghc-hare lang [-l]\n"
        ++ "\t ghc-hare flag [-l]\n"
        ++ "\t ghc-hare browse" ++ ghcOptHelp ++ "[-l] [-o] [-d] <module> [<module> ...]\n"
        ++ "\t ghc-hare check" ++ ghcOptHelp ++ "<HaskellFile>\n"
        ++ "\t ghc-hare expand" ++ ghcOptHelp ++ "<HaskellFile>\n"
        ++ "\t ghc-hare debug" ++ ghcOptHelp ++ "<HaskellFile>\n"
        ++ "\t ghc-hare info" ++ ghcOptHelp ++ "<HaskellFile> <module> <expression>\n"
        ++ "\t ghc-hare type" ++ ghcOptHelp ++ "<HaskellFile> <module> <line-no> <column-no>\n"
        ++ "\t ghc-hare lint [-h opt] <HaskellFile>\n"
        ++ "\t ghc-hare boot\n"
        ++ "\t ghc-hare help\n"
-}
----------------------------------------------------------------

argspec :: [OptDescr (RefactSettings -> RefactSettings)]
argspec = [ Option "m" ["mainfile"]
              (ReqArg (\mf opts -> opts { rsetMainFile = Just mf }) "FILE")
              "Main file name if not specified in cabal file"

          -- , Option "l" ["tolisp"]
          --     (NoArg (\opts -> opts { outputStyle = LispStyle }))
          --     "print as a list of Lisp"
          -- , Option "h" ["hlintOpt"]
          --     (ReqArg (\h opts -> opts { hlintOpts = h : hlintOpts opts }) "hlintOpt")
          --     "hlint options"
          , Option "g" ["ghcOpt"]
              (ReqArg (\g opts -> opts { rsetGhcOpts = g : rsetGhcOpts opts }) "ghcOpt")
              "GHC options"
          -- , Option "o" ["operators"]
          --     (NoArg (\opts -> opts { operators = True }))
          --     "print operators, too"
          -- , Option "d" ["detailed"]
          --     (NoArg (\opts -> opts { detailed = True }))
          --     "print detailed info"
          , Option "s" ["sandbox"]
              (ReqArg (\s opts -> opts { rsetSandbox = Just s }) "path")
              "specify cabal-dev sandbox (default 'cabal-dev`)"
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

main :: IO ()
main = flip catches handlers $ do
-- #if __GLASGOW_HASKELL__ >= 611
    hSetEncoding stdout utf8
-- #endif
    args <- getArgs
    let (opt',cmdArg) = parseArgs argspec args
    (strVer,ver) <- getGHCVersion
    let opt'' = optionsFromSettings opt'
    cradle <- findCradle (sandbox opt'') strVer
    let opt = adjustOpts opt' cradle ver
        cmdArg0 = cmdArg !. 0
        cmdArg1 = cmdArg !. 1
        cmdArg2 = cmdArg !. 2
        cmdArg3 = cmdArg !. 3
        cmdArg4 = cmdArg !. 4
    res <- case cmdArg0 of

      -- rename wants FilePath -> String -> SimpPos
      "rename" -> rename opt cradle cmdArg1 cmdArg2 (parseSimpPos cmdArg3 cmdArg4)
{-
      "browse" -> concat <$> mapM (browseModule opt) (tail cmdArg)
      "list"   -> listModules opt
      "check"  -> checkSyntax opt cradle cmdArg1
      "expand" -> checkSyntax opt { expandSplice = True } cradle cmdArg1
      "debug"  -> debugInfo opt cradle strVer cmdArg1
      "type"   -> typeExpr opt cradle cmdArg1 cmdArg2 (read cmdArg3) (read cmdArg4)
      "info"   -> infoExpr opt cradle cmdArg1 cmdArg2 cmdArg3
      "lint"   -> withFile (lintSyntax opt) cmdArg1
      "lang"   -> listLanguages opt
      "flag"   -> listFlags opt
-}
      cmd      -> throw (NoSuchCommand cmd)
    putStr (show res)
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

    withFile cmd file = do
        exist <- doesFileExist file
        if exist
            then cmd file
            else throw (FileNotExist file)
    xs !. idx
      | length xs <= idx = throw SafeList
      | otherwise = xs !! idx

    adjustOpts opt cradle ver = case mPkgConf of
            Nothing      -> opt
            Just pkgConf -> opt {
                rsetGhcOpts = ghcPackageConfOptions ver pkgConf ++ rsetGhcOpts opt
              }
      where
        mPkgConf = cradlePackageConf cradle

----------------------------------------------------------------

parseSimpPos :: String -> String -> SimpPos
parseSimpPos str1 str2 = case (parse rowCol "" (T.pack (str1 ++ " " ++ str2))) of
                          Left err -> throw (CmdArg [(show err)])
                          Right val -> val

rowCol :: P (Int,Int)
rowCol = do
  row <- number "line number"
  _ <- spaces
  col <- number "column number"
  return (fromIntegral row, fromIntegral col)

type P = Parsec Text ()

instance (Monad m) => Stream Text m Char where
    uncons = return . T.uncons

number :: String -> P Integer
number expectedStr = do { ds <- many1 digit; return (read ds) } <?> expectedStr

----------------------------------------------------------------

optionsFromSettings :: RefactSettings -> Options
optionsFromSettings settings = opt
  where
    opt = defaultOptions
            { ghcOpts = rsetGhcOpts settings
            , sandbox = rsetSandbox settings
            }

----------------------------------------------------------------

ghcPackageConfOptions :: Int -> String -> [String]
ghcPackageConfOptions ver file
  | ver >= 706 = ["-package-db",   file, "-no-user-package-db"]
  | otherwise  = ["-package-conf", file, "-no-user-package-conf"]

