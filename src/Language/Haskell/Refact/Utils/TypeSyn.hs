{-# OPTIONS_GHC -fno-warn-orphans #-}

-- | This is a legacy module from the pre-GHC HaRe, and will disappear
-- eventually.

module Language.Haskell.Refact.Utils.TypeSyn where


-- Modules from GHC
import qualified GHC        as GHC
import qualified Name       as GHC
import qualified Outputable as GHC

type HsExpP    = GHC.HsExpr GHC.RdrName
type HsPatP    = GHC.Pat GHC.RdrName
type HsDeclP   = GHC.LHsDecl GHC.RdrName

type HsDeclsP = GHC.HsGroup GHC.Name

-- type InScopes=((Relations.Rel Names.QName (Ents.Ent PosName.Id)))
type InScopes = [GHC.Name]

type SimpPos = (Int,Int) -- Line, column

-- Additions for GHC
type PosToken = (GHC.Located GHC.Token, String)

type Export = GHC.LIE GHC.RdrName

-- ---------------------------------------------------------------------
-- From old/tools/base/defs/PNT.hs

-- | HsName is a name as it is found in the source
-- This seems to be quite a close correlation
type HsName = GHC.RdrName

-- |The PN is the name as it occurs to the parser, and
-- corresponds with the GHC.RdrName
-- type PN     = GHC.RdrName
newtype PName = PN HsName deriving (Eq)

-- | The PNT is the unique name, after GHC renaming. It corresponds to
-- GHC.Name data PNT = PNT GHC.Name deriving (Data,Typeable) -- Note:
-- GHC.Name has SrcLoc in it already

instance Show GHC.NameSpace where
  show ns
    | ns == GHC.tcName   = "TcClsName"
    | ns == GHC.dataName = "DataName"
    | ns == GHC.varName  = "VarName"
    | ns == GHC.tvName   = "TvName"
    | otherwise          = "UnknownNamespace"

instance GHC.Outputable GHC.NameSpace where
  ppr x = GHC.text $ show x

-- ---------------------------------------------------------------------

type HsModuleP = GHC.Located (GHC.HsModule GHC.RdrName)

-- ---------------------------------------------------------------------
-- Putting these here for the time being, to avoid import loops

ghead :: String -> [a] -> a
ghead  info []    = error $ "ghead "++info++" []"
ghead _info (h:_) = h

glast :: String -> [a] -> a
glast  info []    = error $ "glast " ++ info ++ " []"
glast _info h     = last h

gtail :: String -> [a] -> [a]
gtail  info []   = error $ "gtail " ++ info ++ " []"
gtail _info h    = tail h

gfromJust :: [Char] -> Maybe a -> a
gfromJust _info (Just h) = h
gfromJust  info Nothing = error $ "gfromJust " ++ info ++ " Nothing"

-- ---------------------------------------------------------------------
