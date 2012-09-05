module HaskellGhcParser where

-- container
import Data.Tree (Tree(Node,rootLabel))

-- syb
import Data.Generics (Data)

-- base
import Unsafe.Coerce (unsafeCoerce)


import Data.Generics
import qualified Data.Generics.Schemes as SYB
import qualified Data.Generics.Aliases as SYB
import qualified GHC.SYB.Utils         as SYB

import qualified GHC
import qualified GHC.Paths             as GHC
import qualified DynFlags              as GHC
import qualified Outputable            as GHC
import qualified MonadUtils            as GHC
import qualified FastString            as GHC
import qualified SrcLoc                as GHC
import qualified ErrUtils              as GHC

import GHC.Paths ( libdir )
import System.IO.Unsafe


-- local imports
import Language.Astview.Parser as Astview
import Language.Astview.DataTree
import Data.Tree (Tree(Node,rootLabel))

import Language.Haskell.Exts (parseFileContents)
import Language.Haskell.Exts.Parser (ParseResult(ParseOk))
import Language.Haskell.Exts.Syntax (Module)

haskellghc = Parser "Haskell" [".hs"] buildTreeHaskellExt

buildTreeHaskellExt :: String -> Tree String
buildTreeHaskellExt s = case parseHaskellGhc s of
     Right ast -> flat $ data2treeGhc (ast::GHC.Located (GHC.HsModule GHC.RdrName))
     Left ParseError -> Node "ParseError" []

-- parseHaskellGhc :: (Data a) => String -> Either ParseError a
parseHaskellGhc :: String -> Either ParseError (GHC.Located (GHC.HsModule GHC.RdrName))
{-
parseHaskellGhc s = case parseFileContents s of
  ParseOk p -> unsafeCoerce $ Right p
  _         -> Left ParseError
-}
-- parseHaskellGhc s = Left ParseError
parseHaskellGhc s = case (foo s) of
    -- Right (_,p)  -> unsafeCoerce $ Right p
    Right (_,p)  -> Right p
    Left err -> Left ParseError




-- | Trealise Data to Tree (from SYB 2, sec. 3.4 )
--   bearing in mind the GHC parser stage holes
data2treeGhc :: Data a => a -> Tree String
data2treeGhc = gdefault `extQ` atString
  where 
    atString x = Node x []
    gdefault x = Node (showConstr $ toConstr x) (gmapQ data2tree x) 



parseHaskellGhc' ::
  String
  -> Either
       ParseError
       (GHC.WarningMessages, GHC.Located (GHC.HsModule GHC.RdrName))
parseHaskellGhc' s = case (foo s) of
    Right p  -> Right p
    Left err -> Left ParseError


foo s = do
  res <- unsafePerformIO $ parseSourceFile s
  return res


parseSourceFile ::
  String
  -> IO
       (Either
          GHC.ErrorMessages
          (GHC.WarningMessages, GHC.Located (GHC.HsModule GHC.RdrName)))
parseSourceFile s =
  GHC.defaultErrorHandler GHC.defaultLogAction $ do
    GHC.runGhc (Just GHC.libdir) $ do
      dflags <- GHC.getSessionDynFlags
      let dflags' = foldl GHC.xopt_set dflags
                    [GHC.Opt_Cpp, GHC.Opt_ImplicitPrelude, GHC.Opt_MagicHash]
      GHC.setSessionDynFlags dflags
      let result = GHC.parser s  dflags' "filename.hs"
          -- -> Either ErrorMessages (WarningMessages, Located (HsModule RdrName))	 
      return result





