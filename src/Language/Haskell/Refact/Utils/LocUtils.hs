{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Language.Haskell.Refact.Utils.LocUtils(
    unmodified,modified
  , nullSrcSpan
  , getSrcSpan
  , prettyprintPatList
  , getGhcLoc
  , getGhcLocEnd
  , getLocatedStart
  , getLocatedEnd
  , ghcSpanStartEnd
  , getStartEndLoc
  , startEndLocGhc
  , emptyList
  , nonEmptyList
  ) where


import qualified FastString    as GHC
import qualified GHC           as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import Language.Haskell.Refact.Utils.Types

-- ---------------------------------------------------------------------

--A flag used to indicate whether the token stream has been modified or not.
unmodified, modified :: Bool
unmodified = False
modified   = True

nullSrcSpan :: GHC.SrcSpan
nullSrcSpan = GHC.UnhelpfulSpan $ GHC.mkFastString "HaRe nullSrcSpan"
-- ---------------------------------------------------------------------

prettyprintPatList :: (t -> String) -> Bool -> [t] -> String
prettyprintPatList prpr beginWithSpace t
     = replaceTabBySpaces $ if beginWithSpace then format1 t else format2 t
 where
   format1 tt = foldl (\x y -> x++ " "++ prpr y) "" tt

   format2 [] = ""
   format2 [p] = (prpr p) --  (render.ppi) p
   format2 (p:ps) = (prpr p) ++ " " ++ format2 ps

-- AZ: This must go, when its user is cleaned up

--Replace Tab by white spaces. (1 Tab=8 white spaces)
-- TODO: need to be aware of underlying tab stops, advance to next one only
replaceTabBySpaces::String->String
replaceTabBySpaces []=[]
replaceTabBySpaces (s:ss)
  =if s=='\t' then replicate 8 ' ' ++replaceTabBySpaces ss
              else s:replaceTabBySpaces ss

-- ---------------------------------------------------------------------

-- | gets the (row,col) of the start of the @GHC.SrcSpan@, or (-1,-1)
-- if there is an @GHC.UnhelpfulSpan@
getGhcLoc :: GHC.SrcSpan -> (Int, Int)
getGhcLoc (GHC.RealSrcSpan ss)  = (GHC.srcSpanStartLine ss, GHC.srcSpanStartCol ss)
getGhcLoc (GHC.UnhelpfulSpan _) = (-1,-1)

-- | gets the (row,col) of the end of the @GHC.SrcSpan@, or (-1,-1)
-- if there is an @GHC.UnhelpfulSpan@
getGhcLocEnd :: GHC.SrcSpan -> (Int, Int)
getGhcLocEnd (GHC.RealSrcSpan ss)  = (GHC.srcSpanEndLine ss, GHC.srcSpanEndCol ss)
getGhcLocEnd (GHC.UnhelpfulSpan _) = (-1,-1)

getLocatedStart :: GHC.GenLocated GHC.SrcSpan t -> (Int, Int)
getLocatedStart (GHC.L l _) = getGhcLoc l

getLocatedEnd :: GHC.GenLocated GHC.SrcSpan t -> (Int, Int)
getLocatedEnd (GHC.L l _) = getGhcLocEnd l

-- ---------------------------------------------------------------------

ghcSpanStartEnd :: GHC.SrcSpan -> ((Int, Int), (Int, Int))
ghcSpanStartEnd sspan = (getGhcLoc sspan,getGhcLocEnd sspan)

-- ---------------------------------------------------------------------

getStartEndLoc :: (SYB.Data t) => t -> (SimpPos,SimpPos)
getStartEndLoc t =
  -- error $ "getStartEndLoc:" ++ (SYB.showData SYB.Parser 0 t)
  let
    ss = getSrcSpan t
  in
    case ss of
      Just l -> startEndLocGhc (GHC.L l ss)
      Nothing -> ((0,0),(0,0))

-- ---------------------------------------------------------------------

startEndLocGhc :: GHC.Located b -> (SimpPos,SimpPos)
startEndLocGhc (GHC.L l _) =
  case l of
    (GHC.RealSrcSpan ss) ->
      ((GHC.srcSpanStartLine ss,GHC.srcSpanStartCol ss),
       (GHC.srcSpanEndLine ss,  GHC.srcSpanEndCol ss))
    (GHC.UnhelpfulSpan _) -> ((0,0),(0,0))

-- ---------------------------------------------------------------------

-- |Get around lack of instance Eq when simply testing for empty list
-- TODO: get rid of this in favour of `null` built in fn
emptyList :: [t] -> Bool
emptyList [] = True
emptyList _  = False

nonEmptyList :: [t] -> Bool
nonEmptyList [] = False
nonEmptyList _  = True

-- ---------------------------------------------------------------------

-- | Get the first SrcSpan found, in top down traversal
getSrcSpan::(SYB.Data t) => t -> Maybe GHC.SrcSpan
getSrcSpan t = res t
  where
    res = SYB.somethingStaged SYB.Parser Nothing
            (Nothing
                    `SYB.mkQ`  bind
                    `SYB.extQ` decl
                    `SYB.extQ` sig
                    `SYB.extQ` pnt
                    `SYB.extQ` literalInExp
                    `SYB.extQ` literalInPat
                    `SYB.extQ` importDecl
                    `SYB.extQ` ty
            )

    bind :: GHC.GenLocated GHC.SrcSpan (GHC.HsBind GHC.RdrName) -> Maybe GHC.SrcSpan
    bind (GHC.L l _)              = Just l

    decl :: GHC.GenLocated GHC.SrcSpan (GHC.HsDecl GHC.RdrName) -> Maybe GHC.SrcSpan
    decl (GHC.L l _)              = Just l

    sig :: (GHC.LSig GHC.RdrName) -> Maybe GHC.SrcSpan
    sig (GHC.L l _)              = Just l

    ty :: (GHC.LHsType GHC.RdrName) -> Maybe GHC.SrcSpan
    ty (GHC.L l _) = Just l

    pnt :: GHC.GenLocated GHC.SrcSpan GHC.RdrName -> Maybe GHC.SrcSpan
    pnt (GHC.L l _)              = Just l

    literalInExp :: GHC.LHsExpr GHC.RdrName -> Maybe GHC.SrcSpan
    literalInExp (GHC.L l _) = Just l

    literalInPat :: GHC.LPat GHC.RdrName -> Maybe GHC.SrcSpan
    literalInPat (GHC.L l _) = Just l

    importDecl :: GHC.LImportDecl GHC.RdrName -> Maybe GHC.SrcSpan
    importDecl (GHC.L l _) = Just l

-- ---------------------------------------------------------------------
