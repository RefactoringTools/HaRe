{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Language.Haskell.Refact.Utils.LocUtils(
                     {-
                     module HsTokens,
                     PosToken,simpPos,
                     -}
                       unmodified,modified
                     , simpPos0
                     , nullSrcSpan
                     -- , emptyList, nonEmptyList
                     -- , showToks
                     -- , tokenLen
                     -- ,lengthOfToks
                     -- , mkToken, mkZeroToken {-,defaultToken, -}
                     {-whiteSpacesToken -}
                     , whiteSpaceTokens
                     , realSrcLocFromTok
                     , isWhite
                     , notWhite
                     -- , isWhiteSpace
                     -- , isWhiteSpaceOrIgnored
                     -- , isIgnored
                     {-
                     isNestedComment-},isMultiLineComment {-,isOpenBracket,isCloseBracket, -}
                     ,isOpenSquareBracket,isCloseSquareBracket {- ,isOpenBrace,isConid,
                     isLit,isWhereOrLet,isWhere,isLet,isIn,isCase,isDo,isIf,isForall,
                     isHiding,isModule-} ,isComma, isOpenParen {-,isEqual,isLambda,isIrrefute -},isBar --,isMinus,
                     ,endsWithNewLn,startsWithNewLn,hasNewLn {- ,startsWithEmptyLn,
                     lastNonSpaceToken,firstNonSpaceToken -} ,compressPreNewLns,compressEndNewLns

                     -- , lengthOfLastLine
                     -- , getToks
                     -- , replaceToks,replaceTok
                     -- ,replaceTokNoReAlign
                     {-,deleteToks-},doRmWhites -- ,doAddWhites
                     , srcLocs
                     , getSrcSpan, getAllSrcLocs
                     -- , ghcSrcLocs -- Test version
                     -- , getLocatedStart
                     -- , getLocatedEnd
                     , getBiggestStartEndLoc
                     {-
                     , getStartEndLoc2,
                     startEndLoc,extendBothSides -}-- ,extendForwards,extendBackwards
                     -- , startEndLocIncFowComment{- ,startEndLocIncFowNewLn -}
                     -- , startEndLocIncComments, startEndLocIncComments'
                     {-,
                     prettyprint ,deleteFromToks, prettyprintGuardsAlt,
                     -}
                     -- , tokenise
                     -- , basicTokenise
                     -- , prettyprint -- , prettyprintGhc
                     , prettyprintPatList
                     -- , groupTokensByLine
                     -- , toksOnSameLine
                     , addLocInfo
                     -- , getIndentOffset
                     -- , getLineOffset
                     -- , splitToks
                     -- , splitOnNewLn
                     {-
                     , insertComments,
                     extractComments, insertTerms
                     -}
                     , tokenSrcSpan
                     , tokenCon
                     -- , increaseSrcSpan
                     , getGhcLoc
                     , getGhcLocEnd
                     , getLocatedStart
                     , getLocatedEnd
                     , ghcSpanStartEnd
                     , getStartEndLoc
                     , startEndLocGhc
                     , realSrcLocEndTok
                     , fileNameFromTok
                     -- , splitToks
                     , emptyList, nonEmptyList
                     -- , divideComments
                     -- , notWhiteSpace
                     , isDoubleColon
                     -- , isEmpty
                     -- , isWhereOrLet
                     -- , isWhere
                     -- , isLet
                     -- , isElse
                     -- , isThen
                     -- , isOf
                     -- , isDo
                     -- , getIndentOffset
                    --  , splitOnNewLn
                     -- , tokenLen
                     -- , newLnToken
                     -- , newLinesToken
                     -- , monotonicLineToks
                     , reSequenceToks
                     -- , mkToken
                     -- , mkZeroToken
                     -- , markToken
                     -- , isMarked
                     -- , matchTokenPos
                     -- , rmOffsetFromToks
  ) where


import qualified FastString    as GHC
import qualified GHC           as GHC
import qualified Lexer         as GHC
import qualified SrcLoc        as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

--import Language.Haskell.Refact.Utils.GhcUtils
--import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.Types

import Language.Haskell.GHC.ExactPrint.Utils

{-
import Language.Haskell.TokenUtils.GHC.Layout
import Language.Haskell.TokenUtils.TokenUtils
import Language.Haskell.TokenUtils.Types
import Language.Haskell.TokenUtils.Utils
-}

import Data.Maybe
import Data.List

-- ---------------------------------------------------------------------

{-
showToks :: [PosToken] -> String
showToks toks = show $ map (\(t@(GHC.L _ tok),s) ->
                 ((getLocatedStart t, getLocatedEnd t),tok,s)) toks
-}
{- moved to haskell-token-utils
instance Show (GHC.GenLocated GHC.SrcSpan GHC.Token) where
  show t@(GHC.L _l tok) = show ((getLocatedStart t, getLocatedEnd t),tok)
-}

--A flag used to indicate whether the token stream has been modified or not.
unmodified, modified :: Bool
unmodified = False
modified   = True

--- some default values----
simpPos0 :: (Int,Int)
simpPos0 = (0,0)

nullSrcSpan :: GHC.SrcSpan
nullSrcSpan = GHC.UnhelpfulSpan $ GHC.mkFastString "HaRe nullSrcSpan"

------------------------------------------------

--Some functions for checking whether a token is of a specific type of token.


isWhite :: PosToken -> Bool
isWhite (GHC.L _ (GHC.ITeof),_) = True
isWhite (GHC.L _ (GHC.ITdocCommentNext _) ,_) = True
isWhite (GHC.L _ (GHC.ITdocCommentPrev _) ,_) = True
isWhite (GHC.L _ (GHC.ITdocCommentNamed _),_) = True
isWhite (GHC.L _ (GHC.ITdocSection _ _)   ,_) = True
isWhite (GHC.L _ (GHC.ITdocOptions _)     ,_) = True
isWhite (GHC.L _ (GHC.ITdocOptionsOld _)  ,_) = True
isWhite (GHC.L _ (GHC.ITlineComment _)    ,_) = True
isWhite (GHC.L _ (GHC.ITblockComment _)   ,_) = True
isWhite (GHC.L _ _                        ,_) = False

notWhite :: PosToken -> Bool
notWhite  = not.isWhite


isMultiLineComment :: PosToken -> Bool
isMultiLineComment ((GHC.L _ t),s) = case t of -- ==NestedComment && (isJust (find (=='\n') s))
                                        GHC.ITblockComment _ -> (isJust (find (=='\n') s))
                                        _                    -> False
{-
isOpenBracket  (t,(_,s))       = t==Special && s=="("
isCloseBracket (t,(_,s))       = t==Special && s==")"
-}
isOpenSquareBracket :: PosToken -> Bool
isOpenSquareBracket  ((GHC.L _ t),_s) = case t of
                                   GHC.ITobrack -> True
                                   _            -> False
isCloseSquareBracket :: PosToken -> Bool
isCloseSquareBracket ((GHC.L _ t),_s) = case t of
                                   GHC.ITcbrack -> True
                                   _            -> False
isComma :: PosToken -> Bool
isComma ((GHC.L _ t),_s) = case t of
                         GHC.ITcomma -> True
                         _           -> False

isOpenParen :: PosToken -> Bool
isOpenParen ((GHC.L _ t),_s) = case t of
                         GHC.IToparen -> True
                         _            -> False

isBar :: PosToken -> Bool
isBar   ((GHC.L _ t),_s) = case t of -- "|"
                         GHC.ITvbar -> True
                         _          -> False

-----------------------------------------------------------------

-- |Returns True if the token ends with '\n'
-- ++AZ++: is this meaningful?
endsWithNewLn::PosToken->Bool
endsWithNewLn  (_,s) =if s==[] then False
                               else (glast "endsWithNewLn"  s=='\n')

-- |Returns True if the token starts with `\n`.
-- ++AZ++: is this meaningful?
startsWithNewLn::PosToken->Bool
startsWithNewLn (_,s) =if s==[] then False
                                else ((ghead "starsWithNewLn" s)=='\n')

--Returns True if there is a '\n' in the token.
hasNewLn :: PosToken -> Bool
hasNewLn (GHC.L l _,_) = case l of
  GHC.RealSrcSpan ss -> (GHC.srcSpanStartLine ss /= GHC.srcSpanEndLine ss)
  _ -> False

{-
-- |get the last non-ignored token in a token stream.
lastNonSpaceToken::[PosToken] -> PosToken
lastNonSpaceToken toks=case dropWhile isWhiteSpaceOrIgnored (reverse toks) of
                         [] -> defaultToken
                         l  -> ghead "lastNonSpaceToken" l
-}

-- | Remove the extra preceding  empty lines.
compressPreNewLns::[PosToken] -> [PosToken]
compressPreNewLns toks = toks

-- |Remove the following extra empty lines.
compressEndNewLns::[PosToken]->[PosToken]
compressEndNewLns toks = toks

{-
---Restriction: the refactorer should not modify refactorer-modified/created tokens.
defaultToken :: PosToken
defaultToken = (GHC.noLoc (GHC.ITlineComment "defaultToken"), "defaultToken")
-}

-- ---------------------------------------------------------------------

prettyprintPatList :: (t -> String) -> Bool -> [t] -> String
prettyprintPatList prpr beginWithSpace t
     = replaceTabBySpaces $ if beginWithSpace then format1 t else format2 t
 where
   format1 tt = foldl (\x y -> x++ " "++ prpr y) "" tt

   format2 [] = ""
   format2 [p] = (prpr p) --  (render.ppi) p
   format2 (p:ps) = (prpr p) ++ " " ++ format2 ps

--Replace Tab by white spaces. (1 Tab=8 white spaces)
-- TODO: need to be aware of underlying tab stops, advance to next one only
replaceTabBySpaces::String->String
replaceTabBySpaces []=[]
replaceTabBySpaces (s:ss)
  =if s=='\t' then replicate 8 ' ' ++replaceTabBySpaces ss
              else s:replaceTabBySpaces ss

-- ---------------------------------------------------------------------

--Should add cases for literals.
addLocInfo :: (GHC.LHsBind GHC.Name,[PosToken])
           -> RefactGhc (GHC.LHsBind GHC.Name,[PosToken])
addLocInfo (decl, toks) = return (decl, toks)

-- ---------------------------------------------------------------------
{-
-- |Given a token stream covering multi-lines, calculate the length of the last line
-- AZ: should be the last token start col, plus length of token.
lengthOfLastLine::[PosToken]->Int
lengthOfLastLine [] = 0
lengthOfLastLine toks
   -- = let (toks1,toks2)=break hasNewLn $ reverse toks
   = let rtoks = reverse toks
         x = head rtoks
         (toks1,toks2)=break (\x' -> tokenRow x /= tokenRow x') rtoks
     -- in  if toks2==[]
     in  if length toks2 == 0
          then sum (map tokenLen toks1)
          else sum (map tokenLen toks1) + lastLineLenOfToken (ghead "lengthOfLastLine" toks2)
  where
   --Compute the length of a token, if the token covers multi-line, only count the last line.
   --What about tab keys?
   lastLineLenOfToken (_,s)=(length.(takeWhile (\x->x/='\n')).reverse) s
-}
-- ---------------------------------------------------------------------

{-
-- | get a token stream specified by the start and end position.
getToks :: (SimpPos,SimpPos) -> [PosToken] -> [PosToken]
getToks (startPos,endPos) toks =
  -- TODO: use splitToks
  -- error $ "getToks:startPos=" ++ (show startPos) ++ ",endPos=" ++ (show endPos) ++ ",toks=" ++ (showToks toks) -- ++AZ++ debug
  let (_,toks2)        = break (\t -> tokenPos t >= startPos) toks
      (toks21,_toks22) = break (\t -> tokenPos t >  endPos) toks2
  in
    (toks21)   -- Should add error message for empty list?
    -- error $ "getToks:startPos=" ++ (show startPos) ++ ",endPos=" ++ (show endPos) ++ ",toks21=" ++ (showToks toks21) -- ++AZ++ debug
-}
-- ---------------------------------------------------------------------
{-
-- | Get the start of the line before the pos,
getLineOffset :: [PosToken] -> SimpPos -> Int
getLineOffset toks pos
  = let (ts1, ts2) = break (\t->tokenPos t >= pos) toks
    in if (emptyList ts2)
         then error "HaRe error: position does not exist in the token stream!"
         else let (sl,_) = splitOnNewLn $ reverse ts1
              in tokenCol (glast "getLineOffset" sl)
              -- in error ("getOffset: sl=" ++ (showToks sl)) -- ++AZ++
-}

-- ---------------------------------------------------------------------

{-
-- |Delete a sequence of tokens specified by the start position and
-- end position from the token stream, then adjust the remaining token
-- stream to preserve layout
deleteToks:: [PosToken] -> SimpPos -> SimpPos -> [PosToken]
deleteToks toks startPos endPos
  = case after of
      (_:_) ->    let nextPos =tokenPos $ ghead "deleteToks1" after
                      oldOffset = getIndentOffset toks nextPos
                      newOffset = getIndentOffset (toks1++before++after) nextPos
                  in  toks1++before++adjustLayout (after++toks22) oldOffset newOffset
                  -- in error $ "deleteToks:newOffset=" ++ (show (newOffset)) -- ++AZ++
                  -- in error $ "deleteToks:after=" ++ (showToks (after)) -- ++AZ++
      _     -> if (emptyList toks22)
                 then toks1++before
                 else let toks22'=let nextOffset = getIndentOffset toks (tokenPos (ghead "deleteToks2" toks22))
                                  in if isMultiLineComment (lastNonSpaceToken toks21)
                                       then whiteSpaceTokens (-1111, 0) (nextOffset-1) ++ toks22
                                       else toks22
                      in if endsWithNewLn (last (toks1++before)) || startsWithNewLn (ghead "deleteToks3" toks22')
                           then  toks1++before++toks22'
                           --avoiding layout adjustment by adding a `\n', sometimes may produce extra lines.
                             else  toks1++before++[newLnToken (last before)]++toks22'
                            --  else toks1 ++ before ++ toks22'
     where

      (toks1, toks2) = let (ts1, ts2)   = break (\t->tokenPos t >= startPos) toks
                           (ts11, ts12) = break hasNewLn (reverse ts1)
                       in (reverse ts12, reverse ts11 ++ ts2)
      (toks21, toks22)=let (ts1, ts2) = break (\t -> tokenPos t >= endPos) toks2
                           (ts11, ts12) = break hasNewLn ts2
                       in (ts1++ts11++if (emptyList ts12) then [] else [ghead "deleteToks4" ts12], if (emptyList ts12) then [] else gtail "deleteToks5"  ts12)

      -- NOTE: toks === toks1 ++ toks21 ++ toks22, where toks21 are the ones to be deleted

      -- tokens before the tokens to be deleted at the same line
      before = takeWhile (\t->tokenPos t<startPos) toks21

      -- tokens after the tokens to be deleted at the same line.
      after = let ts= dropWhile (\t -> tokenPosEnd t <= endPos) toks21
              in  if (emptyList ts) then ts -- ++AZ++ error "Sorry, HaRe failed to finish this refactoring. deleteToks"
                                    else ts
-}
-- ---------------------------------------------------------------------
{-
-- | Adjust the layout to compensate the change in the token stream.
adjustLayout:: [PosToken] -> Int -> Int -> [PosToken]
adjustLayout [] _ _ = []
adjustLayout toks _oldOffset _newOffset = toks -- ++AZ++ temporary while plumbing the rest
-}

-- | remove at most n white space tokens from the beginning of ts
doRmWhites::Int -> [PosToken] -> [PosToken]
doRmWhites 0 ts = ts
doRmWhites _ [] = []
doRmWhites _ ts = ts


{-
--add n white space tokens to the beginning of ts
doAddWhites::Int->[PosToken]->[PosToken]
doAddWhites n []=[]
doAddWhites n ts@(t:_)= whiteSpacesToken (tokenRow t,0) n ++ts
-}

-- ++AZ++ : not sure if this is still needed
whiteSpaceTokens :: (Int,Int) -> Int -> [PosToken]
whiteSpaceTokens (_row, _col) _n = []

-- ---------------------------------------------------------------------

-- | get all the source locations (use locations) in an AST phrase t
-- according the the occurrence order of identifiers.
srcLocs::(SYB.Data t) => t -> [SimpPos]
srcLocs t =(nub.srcLocs') t \\ [simpPos0]
   where srcLocs'= SYB.everythingStaged SYB.Parser (++) []
                   ([]
                    `SYB.mkQ` pnt
                    `SYB.extQ` sn
                    `SYB.extQ` literalInExp
                    `SYB.extQ` literalInPat)

         pnt :: GHC.GenLocated GHC.SrcSpan GHC.Name -> [SimpPos]
         pnt (GHC.L l _)              = [getGhcLoc l]

         sn :: GHC.HsModule GHC.RdrName -> [SimpPos]
         sn (GHC.HsModule (Just (GHC.L l _)) _ _ _ _ _) = [getGhcLoc l]
         sn _ = []

         literalInExp :: GHC.LHsExpr GHC.Name -> [SimpPos]
         literalInExp (GHC.L l _) = [getGhcLoc l]

         literalInPat :: GHC.LPat GHC.Name -> [SimpPos]
         literalInPat (GHC.L l _) = [getGhcLoc l]

-- ---------------------------------------------------------------------

getBiggestStartEndLoc :: (SYB.Data t) => t -> (SimpPos,SimpPos)
getBiggestStartEndLoc t = (start,end)
  where
    locs  = getAllSrcLocs t
    start = minimum $ map fst locs
    end   = maximum $ map snd locs

-- ---------------------------------------------------------------------

-- | Get all the source locations in a given syntax fragment
getAllSrcLocs::(SYB.Data t) => t -> [(SimpPos,SimpPos)]
getAllSrcLocs t = res t
  where
    res = SYB.everythingStaged SYB.Renamer (++) []
            ([]
                    `SYB.mkQ` bind
                    `SYB.extQ` sig
                    `SYB.extQ` pnt
                    `SYB.extQ` sn
                    `SYB.extQ` literalInExp
                    `SYB.extQ` literalInPat
                    `SYB.extQ` importDecl
                    `SYB.extQ` ty
            )

    bind :: GHC.GenLocated GHC.SrcSpan (GHC.HsBind GHC.Name) -> [(SimpPos,SimpPos)]
    bind (GHC.L l _)              = [(getGhcLoc l,getGhcLocEnd l)]

    sig :: (GHC.LSig GHC.Name) -> [(SimpPos,SimpPos)]
    sig (GHC.L l _)              = [(getGhcLoc l,getGhcLocEnd l)]

    ty :: (GHC.LHsType GHC.Name) -> [(SimpPos,SimpPos)]
    ty (GHC.L l _) = [(getGhcLoc l,getGhcLocEnd l)]

    pnt :: GHC.GenLocated GHC.SrcSpan GHC.Name -> [(SimpPos,SimpPos)]
    pnt (GHC.L l _)              = [(getGhcLoc l,getGhcLocEnd l)]

    sn :: GHC.HsModule GHC.RdrName -> [(SimpPos,SimpPos)]
    sn (GHC.HsModule (Just (GHC.L l _)) _ _ _ _ _) = [(getGhcLoc l,getGhcLocEnd l)]
    sn _ = []

    literalInExp :: GHC.LHsExpr GHC.Name -> [(SimpPos,SimpPos)]
    literalInExp (GHC.L l _) = [(getGhcLoc l,getGhcLocEnd l)]

    literalInPat :: GHC.LPat GHC.Name -> [(SimpPos,SimpPos)]
    literalInPat (GHC.L l _) = [(getGhcLoc l,getGhcLocEnd l)]

    importDecl :: GHC.LImportDecl GHC.Name -> [(SimpPos,SimpPos)]
    importDecl (GHC.L l _) = [(getGhcLoc l,getGhcLocEnd l)]

-- ---------------------------------------------------------------------
{-
-- |Extend the given position backwards to the front of the file while
-- the supplied condition holds
extendBackwards :: [PosToken] -> (SimpPos ,SimpPos) -> (PosToken -> Bool)
  -> (SimpPos,SimpPos)
extendBackwards toks (startLoc,endLoc) condFun
    = let toks1 = takeWhile (\t->tokenPos t /= startLoc) toks
          firstLoc = case (dropWhile (not.condFun) (reverse toks1)) of
                       [] -> startLoc  -- is this the correct default?
                       l  -> (tokenPos.ghead "extendBackwards") l
      in (firstLoc, endLoc)
-}
{-
-- |Extend the given position forwards to the end of the file while
-- the supplied condition holds
extendForwards :: [PosToken] -> (SimpPos ,SimpPos) -> (PosToken -> Bool)
  -> (SimpPos,SimpPos)
extendForwards toks (startLoc,endLoc) condFun
    = let toks1 = gtail "extendForwards"  $ dropWhile (\t->tokenPosEnd t /= endLoc) toks
          lastLoc = case (dropWhile (condFun) toks1) of
                          [] ->endLoc -- is this the correct default?
                          l ->(tokenPos. ghead "extendForwards") l
      in (startLoc, lastLoc)
-}

{-
------------------Some functions for associating comments with syntax phrases.---------------------------
{- Note: We assume that a comment before t belongs to t only if there is at most one blank line between them,
         and a cooment after t belongs to t only it the comment starts at the last line of t.
-}
-}

{-
-- |Get the start&end location of syntax phrase t, then extend the end
-- location to cover the comment/white spaces or new line which starts
-- in the same line as the end location
-- TODO: deprecate this in favour of startEndLocIncComments
startEndLocIncFowComment::(SYB.Data t)=>[PosToken]->t->(SimpPos,SimpPos)
startEndLocIncFowComment toks t
  = let (startLoc,_endLoc)=getStartEndLoc t
        (_,endLocIncComments) = startEndLocIncComments toks t
    in (startLoc, endLocIncComments)
-}

-- ---------------------------------------------------------------------

--Some functions for fetching a specific field of a token
tokenSrcSpan :: (GHC.Located t1, t) -> GHC.SrcSpan
tokenSrcSpan (GHC.L l _,_)     = l

-- TODO: badly named function
tokenCon :: PosToken -> String
tokenCon (_,s)     = s

-- ---------------------------------------------------------------------
{-
increaseSrcSpan :: SimpPos -> PosToken -> PosToken
increaseSrcSpan (lineAmount,colAmount) posToken@(lt@(GHC.L _l t), s)
    = (GHC.L newL t, s)
    where
        filename = fileNameFromTok posToken
        newL = GHC.mkSrcSpan (GHC.mkSrcLoc filename startLine startCol)
                             (GHC.mkSrcLoc filename endLine endCol)
        (startLine, startCol) = add1 $ getLocatedStart lt
        (endLine, endCol)     = add1 $ getLocatedEnd   lt

        add1 :: (Int, Int) -> (Int, Int)
        add1 (r,c) = (r+lineAmount,c+colAmount)

-}
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
  -- error $ "getStartEndLoc:" ++ (SYB.showData SYB.Renamer 0 t)
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

realSrcLocFromTok :: PosToken -> GHC.RealSrcLoc
realSrcLocFromTok (GHC.L (GHC.RealSrcSpan srcspan) _,_) = GHC.realSrcSpanStart srcspan
realSrcLocFromTok (GHC.L _ _,_) = GHC.mkRealSrcLoc (GHC.mkFastString "") 1 1

realSrcLocEndTok :: PosToken -> GHC.RealSrcLoc
realSrcLocEndTok (GHC.L (GHC.RealSrcSpan srcspan) _,_) = GHC.realSrcSpanEnd srcspan
realSrcLocEndTok (GHC.L _ _,_) = GHC.mkRealSrcLoc (GHC.mkFastString "") 1 1

fileNameFromTok :: PosToken -> GHC.FastString
fileNameFromTok (GHC.L (GHC.RealSrcSpan srcspan) _,_) = GHC.srcSpanFile srcspan
fileNameFromTok (GHC.L _ _,_) = GHC.mkFastString "f"

-- ---------------------------------------------------------------------
{-
-- | Split the token stream into three parts: the tokens before the
-- startPos, the tokens between startPos and endPos, and the tokens
-- after endPos.
-- Note: The startPos and endPos refer to the startPos of a token only.
--       So a single token will have the same startPos and endPos
--    NO^^^^
splitToks::(SimpPos,SimpPos)->[PosToken]->([PosToken],[PosToken],[PosToken])
splitToks (startPos, endPos) toks =
  let (toks1,toks2)   = break (\t -> tokenPos t >= startPos) toks
      (toks21,toks22) = break (\t -> tokenPos t >=   endPos) toks2
  in
    (toks1,toks21,toks22)

-}
-- ----------------------------------------------------------------------

-- |Get around lack of instance Eq when simply testing for empty list
-- TODO: get rid of this in favour of `null` built in fn
emptyList :: [t] -> Bool
emptyList [] = True
emptyList _  = False

nonEmptyList :: [t] -> Bool
nonEmptyList [] = False
nonEmptyList _  = True

{-
-- | Get the start&end location of t in the token stream, then extend
-- the start and end location to cover the preceding and following
-- comments.
--
-- In this routine, 'then','else','do' and 'in' are treated as comments.
startEndLocIncComments::(SYB.Data t) => [PosToken] -> t -> (SimpPos,SimpPos)
startEndLocIncComments toks t = startEndLocIncComments' toks (getStartEndLoc t)
-}

-- ---------------------------------------------------------------------

-- isWhiteSpace :: PosToken -> Bool
-- isWhiteSpace tok = isComment tok || isEmpty tok
{-
notWhiteSpace :: PosToken -> Bool
notWhiteSpace tok = not (isWhiteSpace tok)

-- Tokens that are ignored when allocating tokens to a SrcSpan
isIgnored :: PosToken -> Bool
isIgnored tok = isThen tok || isElse tok || isIn tok || isDo tok
-}
-- ---------------------------------------------------------------------

isDoubleColon :: PosToken -> Bool
isDoubleColon ((GHC.L _ (GHC.ITdcolon)), "::") = True
isDoubleColon _                                = False

-- ---------------------------------------------------------------------

-- | Get the first SrcSpan found, in top down traversal
getSrcSpan::(SYB.Data t) => t -> Maybe GHC.SrcSpan
getSrcSpan t = res t
  where
    res = SYB.somethingStaged SYB.Renamer Nothing
            (Nothing
                    `SYB.mkQ`  bind
                    `SYB.extQ` sig
                    `SYB.extQ` pnt
                    `SYB.extQ` literalInExp
                    `SYB.extQ` literalInPat
                    `SYB.extQ` importDecl
                    `SYB.extQ` ty
            )

    bind :: GHC.GenLocated GHC.SrcSpan (GHC.HsBind GHC.Name) -> Maybe GHC.SrcSpan
    bind (GHC.L l _)              = Just l

    sig :: (GHC.LSig GHC.Name) -> Maybe GHC.SrcSpan
    sig (GHC.L l _)              = Just l

    ty :: (GHC.LHsType GHC.Name) -> Maybe GHC.SrcSpan
    ty (GHC.L l _) = Just l

    pnt :: GHC.GenLocated GHC.SrcSpan GHC.Name -> Maybe GHC.SrcSpan
    pnt (GHC.L l _)              = Just l

    literalInExp :: GHC.LHsExpr GHC.Name -> Maybe GHC.SrcSpan
    literalInExp (GHC.L l _) = Just l

    literalInPat :: GHC.LPat GHC.Name -> Maybe GHC.SrcSpan
    literalInPat (GHC.L l _) = Just l

    importDecl :: GHC.LImportDecl GHC.Name -> Maybe GHC.SrcSpan
    importDecl (GHC.L l _) = Just l

-- ---------------------------------------------------------------------

-- groupTokensByLine :: [PosToken] -> [[PosToken]]
-- groupTokensByLine xs = groupBy toksOnSameLine xs
{-
toksOnSameLine :: PosToken -> PosToken -> Bool
toksOnSameLine t1 t2 = tokenRow t1 == tokenRow t2
-}
-- ---------------------------------------------------------------------

-- |Adjust token stream to cater for changes in token length due to
-- token renaming
reSequenceToks :: [PosToken] -> [PosToken]
reSequenceToks toks = toks

-- ---------------------------------------------------------------------
{-
rmOffsetFromToks :: [PosToken] -> [PosToken]
rmOffsetFromToks [] = []
rmOffsetFromToks toks = toks'
  where
    ro' = tokenRow $ head toks
    co' = tokenCol $ head toks
    -- (ro,co) = srcPosToSimpPos (tokenRow $ head toks, tokenCol $ head toks)
    toks' = addOffsetToToks (-ro',-co') toks
-}
-- ---------------------------------------------------------------------


