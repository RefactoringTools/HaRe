{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Language.Haskell.Refact.Utils.LocUtils(
                     {-
                     module HsTokens,
                     PosToken,simpPos,
                     -}
                     SimpPos,unmodified,modified
                     , simpPos0
                     , nullSrcSpan
                     -- , emptyList, nonEmptyList
                     , showToks
                     -- , tokenLen
                     -- ,lengthOfToks
                     -- , mkToken, mkZeroToken {-,defaultToken, -}
                     {-whiteSpacesToken -}
                     ,whiteSpaceTokens
                     , realSrcLocFromTok
                     , isWhite
                     , notWhite
                     -- , isWhiteSpace
                     {-
                     ,isNewLn,isCommentStart -},isComment {-,
                     isNestedComment-},isMultiLineComment {-,isOpenBracket,isCloseBracket, -}
                     ,isOpenSquareBracket,isCloseSquareBracket {- ,isOpenBrace,isConid,
                     isLit,isWhereOrLet,isWhere,isLet-},isIn {- ,isCase,isDo,isIf,isForall,
                     isHiding,isModule-} ,isComma {-,isEqual,isLambda,isIrrefute -},isBar --,isMinus,
                     ,endsWithNewLn,startsWithNewLn,hasNewLn {- ,startsWithEmptyLn,
                     lastNonSpaceToken,firstNonSpaceToken -} ,compressPreNewLns,compressEndNewLns

                     , lengthOfLastLine
                     , getToks
                     -- , replaceToks,replaceTok
                     ,replaceTokNoReAlign,deleteToks,doRmWhites -- ,doAddWhites
                     , srcLocs
                     , getSrcSpan, getAllSrcLocs
                     -- , ghcSrcLocs -- Test version
                     -- , getLocatedStart
                     -- , getLocatedEnd
                     , getBiggestStartEndLoc
                     {-
                     , getStartEndLoc2,
                     startEndLoc,extendBothSides -},extendForwards,extendBackwards
                     , startEndLocIncFowComment{- ,startEndLocIncFowNewLn -}
                     , startEndLocIncComments, startEndLocIncComments'
                     {-,
                     prettyprint ,deleteFromToks, prettyprintGuardsAlt,
                     -}
                     {-, addFormalParams -} {- ,  adjustOffset, -- try to remove it
                     StartEndLoc, isArrow,-- swapInToks,
                     commentToks
                     -}
                     , tokenise
                     , basicTokenise
                     , lexStringToRichTokens
                     , prettyprint -- , prettyprintGhc
                     , prettyprintPatList
                     , groupTokensByLine
                     , addLocInfo
                     -- , getIndentOffset
                     , getLineOffset
                     -- , splitToks
                     -- , splitOnNewLn
                     {-
                     , insertComments,
                     extractComments, insertTerms
                     -}
                     , tokenCol
                     , tokenColEnd
                     , tokenRow
                     , tokenPos
                     , tokenPosEnd
                     , tokenCon
                     , increaseSrcSpan
                     , getGhcLoc
                     , getGhcLocEnd
                     , getLocatedStart
                     , getLocatedEnd
                     , getStartEndLoc
                     , startEndLocGhc
                     , realSrcLocEndTok
                     , fileNameFromTok
                     , splitToks
                     , emptyList, nonEmptyList
                     , divideComments
                     , isWhiteSpace
                     , notWhiteSpace
                     , isDoubleColon
                     , isEmpty
                     , isWhereOrLet
                     , isWhere
                     , isLet
                     , isElse
                     , isThen
                     , isOf
                     , isDo
                     , getIndentOffset
                     , splitOnNewLn
                     , tokenLen
                     , newLnToken
                     , newLinesToken
                     , monotonicLineToks
                     , reSequenceToks
                     , mkToken
                     , mkZeroToken
                     , markToken
                     , isMarked
                     , addOffsetToToks
                     , matchTokenPos
  ) where


-- import qualified BasicTypes    as GHC
--  import qualified DynFlags      as GHC
import qualified FastString    as GHC
import qualified GHC           as GHC
-- import qualified GHC.Paths     as GHC
-- import qualified HsSyn         as GHC
import qualified Lexer         as GHC
-- import qualified Module        as GHC
-- import qualified MonadUtils    as GHC
-- import qualified Outputable    as GHC
-- import qualified RdrName       as GHC
import qualified SrcLoc        as GHC
-- import qualified StringBuffer  as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.GhcVersionSpecific
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn

import Data.Maybe
import Data.List
-- import Debug.Trace

-- ---------------------------------------------------------------------


showToks :: [PosToken] -> String
showToks toks = show $ map (\(t@(GHC.L _ tok),s) ->
                 ((getLocatedStart t, getLocatedEnd t),tok,s)) toks

instance Show (GHC.GenLocated GHC.SrcSpan GHC.Token) where
  show t@(GHC.L _l tok) = show ((getLocatedStart t, getLocatedEnd t),tok)


--A flag used to indicate whether the token stream has been modified or not.
unmodified, modified :: Bool
unmodified = False
modified   = True

--- some default values----
simpPos0 :: (Int,Int)
simpPos0 = (0,0)
{-
extractComments :: (SimpPos, SimpPos) -> [PosToken] -> [PosToken]
extractComments ((startPosl, startPosr), endPos) toks
   = let (toks1, toks21, toks22) = splitToks ((startPosl, startPosr), endPos) toks
      in toks1

------------------------------------------------
-}

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
{-
isOpenBrace  (t,(_,s))         = t==Special && s=="{"
isCloseBrace (t,(_,s))         = t==Special && s=="}"

isConid (t,(_,_))              = t==Conid
isLit (t,(_,s)) = t==IntLit || t==FloatLit || t==CharLit || t==StringLit
-}
-- isWhereOrLet  t   = isWhere t || isLet t
{-
isImport (t, (_,s))= t == Reservedid && s=="import"
isType (t, (_,s))= t  == Reservedid && s=="type"
isData (t, (_,s))= t == Reservedid && s=="data"
isFixty (t, (_,s)) = t==Reservedid && (s=="infix" || s=="infixl" || s=="infixr")
isDefault (t, (_,s)) = t == Reservedid && s=="default"
isClass (t, (_,s)) = t == Reservedid && s=="class"
isInstance (t, (_,s)) = t == Reservedid && s=="instance"
isNewtype (t, (_,s)) = t == Reservedid && s=="newtype"
-}
isIn :: PosToken -> Bool
isIn    ((GHC.L _ t),_s) = case t of
                      GHC.ITin -> True
                      _        -> False
{-
isCase  (t,(_,s))  = t==Reservedid && s=="case"
isDo    (t,(_,s))  = t==Reservedid && s=="do"
isIf    (t,(_,s))  = t==Reservedid && s=="if"
isForall (t,(_,s)) = t==Reservedid && s=="forall"
isHiding (t,(_,s)) = s=="hiding"
isModule (t,(_,s)) = t==Reservedid && s=="module"
-}
isComma :: PosToken -> Bool
isComma ((GHC.L _ t),_s) = case t of
                         GHC.ITcomma -> True
                         _           -> False
{-
isEqual  (t,(_,s))   = t==Reservedop && s=="="
isLambda (t,(_,s))   = t==Reservedop && s=="\\"
isIrrefute (t,(_,s)) = t==Reservedop && s=="~"
-}
isBar :: PosToken -> Bool
isBar   ((GHC.L _ t),_s) = case t of -- "|"
                         GHC.ITvbar -> True
                         _          -> False
{-
isArrow (t,(_,s))    = t==Reservedop && s=="->"
isMinus (t,(_,s))    = t==Varsym && s=="-"
-}

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
--Returns True if a token stream starts with a newline token (apart from the white spaces tokens)
startsWithEmptyLn::[PosToken]->Bool
startsWithEmptyLn toks=isJust (find isNewLn $ takeWhile (\t->isWhiteSpace t || isNewLn t) toks)
-}

-- |get the last non-space token in a token stream.
lastNonSpaceToken::[PosToken] -> PosToken
lastNonSpaceToken toks=case dropWhile isWhiteSpace (reverse toks) of
                         [] -> defaultToken
                         l  -> ghead "lastNonSpaceToken" l
{-
--get the first non-space token in a token stream.
firstNonSpaceToken::[PosToken]->PosToken
firstNonSpaceToken toks=case dropWhile isWhiteSpace toks of
                         [] ->defaultToken
                         l -> ghead "firstNonSpaceToken" l
-}

-- | Remove the extra preceding  empty lines.
compressPreNewLns::[PosToken] -> [PosToken]
compressPreNewLns toks = toks
{- ++AZ++: is this still needed?
compressPreNewLns toks= let (toks1, toks2) = break (not.(\t->isNewLn t || isWhiteSpace t)) toks
                            groupedToks    = groupTokensByLine toks1
                        in if length groupedToks>1 then (last groupedToks)++toks2
                                                   else toks
-}


-- |Remove the following extra empty lines.
compressEndNewLns::[PosToken]->[PosToken]
compressEndNewLns toks = toks
{- ++AZ++: is this still needed?
compressEndNewLns toks=let (toks1, toks2) = break (not.(\t->isNewLn t || isWhiteSpace t)) (reverse toks)
                           groupedToks    = groupTokensByLine toks1
                       in if length groupedToks>1 then reverse ((ghead "compressEndNewLns" groupedToks)++toks2)
                                                  else toks
-}
{-
prettyprintPatList beginWithSpace t
     = replaceTabBySpaces $ if beginWithSpace then format1 t else format2 t
 where
   format1 t = foldl (\x y -> x++ " "++(render.ppi) y) "" t

   format2 [] = ""
   format2 [p] = (render.ppi) p
   format2 (p:ps) = (render.ppi) p ++" " ++ format2 ps

prettyprint = replaceTabBySpaces.render.ppi

prettyprintGuardsAlt = replaceTabBySpaces.render.(ppRhs rarrow)


--Replace Tab by white spaces. (1 Tab=8 white spaces)
replaceTabBySpaces::String->String
replaceTabBySpaces []=[]
replaceTabBySpaces (s:ss)
  =if s=='\t' then replicate 8 ' ' ++replaceTabBySpaces ss
              else s:replaceTabBySpaces ss

-}

{-
-- |Compose a new token using the given arguments.
mkToken::GHC.Token -> SimpPos -> String -> PosToken
mkToken t (row,col) c = ((GHC.L l t),c)
  where
    filename = (GHC.mkFastString "f")
    l = GHC.mkSrcSpan (GHC.mkSrcLoc filename row col) (GHC.mkSrcLoc filename row (col + (length c) ))


mkZeroToken :: PosToken
mkZeroToken = mkToken GHC.ITsemi (0,0) ""
-}
---Restriction: the refactorer should not modify refactorer-modified/created tokens.
defaultToken :: PosToken
defaultToken = (GHC.noLoc (GHC.ITlineComment "defaultToken"), "defaultToken")

-- defaultToken = (Whitespace, (pos0," "))

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

-- | Convert a string into a set of Haskell tokens, following the
-- given position, with each line indented by a given column offset if
-- required
-- TODO: replace 'colOffset withFirstLineIndent' with a Maybe Int ++AZ++
tokenise :: GHC.RealSrcLoc -> Int -> Bool -> String -> IO [PosToken]
tokenise  _ _ _ [] = return []
tokenise  startPos colOffset withFirstLineIndent str
  = let str' = case lines str of
                    (ln:[]) -> addIndent ln ++ if glast "tokenise" str=='\n' then "\n" else ""
                    (ln:lns)-> addIndent ln ++ "\n" ++ concatMap (\n->replicate colOffset ' '++n++"\n") lns
                    []      -> []
        str'' = if glast "tokenise" str' == '\n' && glast "tokenise" str /= '\n'
                  then genericTake (length str' -1) str'
                  else str'
        toks = lexStringToRichTokens startPos str''

    in toks
    -- in error $ "tokenise:" ++ (showToks $ head toks)
   where
     addIndent ln = if withFirstLineIndent
                      then replicate colOffset ' '++ ln
                      else ln

-- ---------------------------------------------------------------------

-- |Convert a string into a set of Haskell tokens. It has default
-- position and offset, since it will be stitched into place in TokenUtils
basicTokenise :: String -> IO [PosToken]
basicTokenise str = tokenise startPos 0 False str
  where
    -- startPos = (GHC.mkRealSrcLoc tokenFileMark 0 1)
    startPos = (GHC.mkRealSrcLoc (GHC.mkFastString "foo") 0 1)

-- ---------------------------------------------------------------------

--Should add cases for literals.
addLocInfo :: (GHC.LHsBind GHC.Name,[PosToken])
           -> RefactGhc (GHC.LHsBind GHC.Name,[PosToken])
addLocInfo (decl, toks) = return (decl, toks)
  -- = error "undefined addLocInfo"
{-++AZ++ Need to see it this is actually needed....
  --  = runStateT (applyTP (full_tdTP (idTP `adhocTP` inPnt
  --                                        `adhocTP` inSN)) decl) toks
   = everywhereMStaged SYB.Renamer (SYB.mkM inPnt `SYB.extM` inSN)
       where
         inPnt (PNT pname ty (N (Just loc)))
            = do loc' <- findLoc (pNtoName pname)
                 return (PNT pname ty (N (Just loc')))
         inPnt x = return x

         inSN (SN (PlainModule modName) (SrcLoc _ _ row col))
             = do loc' <- findLoc modName
                  return (SN (PlainModule modName) loc')
         inSN x = return x

         pNtoName (PN (UnQual i) _)=i
         pNtoName (PN (Qual (PlainModule modName) i) _) = modName++"."++i
         pNtoName (PN (Qual (MainModule _) i) _)        = "Main."++i

         findLoc name
          = do  let name' = if name =="Prelude.[]" || name == "[]"  then "["
                               else if name=="Prelude.(,)" || name == "(,)" || name == "()"  then "("
                                                                                             else name   ----Check this again.
                    toks' = dropWhile (\t->tokenCon t /= name') toks
                    (row, col) =if toks'==[] then error ("HaRe: Error in addLocInfo while looking for" ++ name' ++ " !")
                                              else tokenPos $ ghead "findLoc" toks'
                return (SrcLoc "unknown" 0 row col)
++AZ++ end -}


{- ++original++
--Should add cases for literals.
addLocInfo (decl, toks)
    = runStateT (applyTP (full_tdTP (idTP `adhocTP` inPnt
                                          `adhocTP` inSN)) decl) toks
       where
         inPnt (PNT pname ty (N (Just loc)))
            = do loc' <- findLoc (pNtoName pname)
                 return (PNT pname ty (N (Just loc')))
         inPnt x = return x

         inSN (SN (PlainModule modName) (SrcLoc _ _ row col))
             = do loc' <- findLoc modName
                  return (SN (PlainModule modName) loc')
         inSN x = return x


         pNtoName (PN (UnQual i) _)=i
         pNtoName (PN (Qual (PlainModule modName) i) _) = modName++"."++i
         pNtoName (PN (Qual (MainModule _) i) _)        = "Main."++i
         findLoc name
          = do  let name' = if name =="Prelude.[]" || name == "[]"  then "["
                               else if name=="Prelude.(,)" || name == "(,)" || name == "()"  then "("
                                                                                             else name   ----Check this again.
                    toks' = dropWhile (\t->tokenCon t /= name') toks
                    (row, col) =if toks'==[] then error ("HaRe: Error in addLocInfo while looking for" ++ name' ++ " !")
                                              else tokenPos $ ghead "findLoc" toks'
                return (SrcLoc "unknown" 0 row col)



++original end -}

-- ---------------------------------------------------------------------

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

-- ---------------------------------------------------------------------

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

-- ---------------------------------------------------------------------
{-
-- | Add tokens corresponding to the new parameters to the end of the
-- syntax element provided
addFormalParams :: (SYB.Data t, SYB.Typeable t) =>
                t -> [GHC.Located (GHC.Pat GHC.Name)] -> RefactGhc ()
addFormalParams t newParams
  = do
       let (startPos,endPos) = getStartEndLoc t

       newToks <- liftIO $ basicTokenise (prettyprintPatList prettyprint True newParams)
       -- error $ "addFormalParams:newToks=" ++ (showToks newToks) -- ++AZ++
       _ <- putToksAfterPos (startPos,endPos) PlaceAdjacent $ map markToken newToks

       return ()
-}
-- ---------------------------------------------------------------------

{-
-- |Replace a list of tokens in the token stream by a new list of
-- tokens, adjust the layout as well. To use this function make sure
-- the start and end positions really exist in the token stream.
-- QN: what happens if the start or end position does not exist?

-- TODO: ++AZ++ pretty sure this should be deprecated
replaceToks::[PosToken]->SimpPos->SimpPos->[PosToken]->[PosToken]
replaceToks toks startPos endPos newToks =
 -- error $ "replaceToks: startPos=" ++ (show startPos)
    (if length toks22 == 0
        then toks1 ++ newToks'
        else let {-(pos::(Int,Int)) = tokenPos (ghead "replaceToks" toks22)-} -- JULIEN
                 -- oldOffset = {-getOffset toks pos  -}  lengthOfLastLine (toks1++toks21) --JULIEN
                 -- newOffset = {-getOffset (toks1++newToks'++ toks22) pos -} lengthOfLastLine (toks1++newToks) -- JULIEN
             in  toks1 ++ (newToks' ++ toks22))  -- adjustLayout toks22 oldOffset newOffset) ) 
   where
      (toks1, _toks21, toks22) = splitToks (startPos, endPos) toks
      newToks' = map markToken newToks
-}

-- ---------------------------------------------------------------------

-- |Replace a single token in the token stream by a new token, without
-- adjusting the layout.
-- Note1: does not re-align, else other later replacements may fail.
-- Note2: must keep original end col, to know what the inter-token gap
--        was when re-aligning
replaceTokNoReAlign::[PosToken]->SimpPos->PosToken->[PosToken]
replaceTokNoReAlign toks pos newTok =
    toks1 ++ [newTok'] ++ toksRest
   where
      (toks1,toks2) = break (\t -> tokenPos t >= pos && tokenLen t > 0) toks
      toksRest = if (emptyList toks2) then [] else (gtail "replaceTokNoReAlign" toks2)
      oldTok =  if (emptyList toks2) then newTok else (ghead "replaceTokNoReAlign" toks2)
      -- newTok' = markToken newTok
      newTok' = markToken $ matchTokenPos oldTok newTok

-- ---------------------------------------------------------------------

-- |Transfer the location information from the first param to the second
matchTokenPos :: PosToken -> PosToken -> PosToken
matchTokenPos (GHC.L l _,_) (GHC.L _ t,s) = (GHC.L l t,s)

-- ---------------------------------------------------------------------

-- | Get the start of the line before the pos,
getLineOffset :: [PosToken] -> SimpPos -> Int
getLineOffset toks pos
  = let (ts1, ts2) = break (\t->tokenPos t >= pos) toks
    in if (emptyList ts2)
         then error "HaRe error: position does not exist in the token stream!"
         else let (sl,_) = splitOnNewLn $ reverse ts1
              in tokenCol (glast "getLineOffset" sl)
              -- in error ("getOffset: sl=" ++ (showToks sl)) -- ++AZ++


-- ---------------------------------------------------------------------


{-
srcLocs::(Data t)=> t->[SimpPos]
srcLocs t =(nub.srcLocs') t \\ [simpPos0]
   where srcLocs' = everywhere (++) ([] `mkQ`


        srcLocs'=runIdentity.(applyTU (full_tdTU (constTU []
                                                  `adhocTU` pnt
                                                  `adhocTU` sn
                                                  `adhocTU` literalInExp
                                                  `adhocTU` literalInPat)))

         pnt (PNT pname _ (N (Just (SrcLoc _  _ row col))))=return [(row,col)]
         pnt _=return []

         sn (SN (PlainModule modName) (SrcLoc _ _ row col))
             = return [(row, col)]
         sn _ = return []

         literalInExp ((Exp (HsLit (SrcLoc _  _ row col) _))::HsExpP) = return [(row,col)]
         literalInExp (Exp _) =return []

         literalInPat ((Pat (HsPLit (SrcLoc _ _ row col) _))::HsPatP) = return [(row,col)]
         literalInPat (Pat (HsPNeg (SrcLoc _  _ row col) _)) = return [(row,col)]
         literalInPat _ =return []
-}



{-
---REFACTORING: GENERALISE THIS FUNCTION.
addFormalParams t newParams
  = do ((toks,_),(v1, v2))<-get
       let (startPos,endPos) = getStartEndLoc toks t
           tToks     = getToks (startPos, endPos) toks
           (toks1, _) = let (toks1', toks2') = break (\t-> tokenPos t == endPos) toks
                        in (toks1' ++ [ghead "addFormalParams" toks2'], gtail "addFormalParams"  toks2')
           offset  = lengthOfLastLine toks1
           newToks = tokenise (Pos 0 v1 1) offset False (prettyprintPatList True newParams )
           toks'   = replaceToks toks startPos endPos (tToks++newToks)
       put ((toks',modified), ((tokenRow (glast "addFormalParams" newToks) -10), v2))
       addLocInfo (newParams, newToks)
-}




{-
{- Delete an syntax phrase from the token stream, this function (instead of the following one)
   should be the interface function for deleting tokens.
-}
-- deleteFromToks::( (MonadState (([PosToken], Bool), t1) m), StartEndLoc t,Printable t,Term t)=>t->m ()
deleteFromToks t getLocFun
   =do ((toks,_),others)<-get
       let (startPos,endPos)=getLocFun toks t
           toks'=deleteToks toks startPos endPos
       put ((toks',modified),others)
-}

-- ---------------------------------------------------------------------

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

{- ++ original ++
{-Delete a sequence of tokens specified by the start position and end position from the token stream,
  then adjust the remaining token stream to preserve layout-}
deleteToks::[PosToken]->SimpPos->SimpPos->[PosToken]
deleteToks toks startPos@(startRow, startCol) endPos@(endRow, endCol)
  = case after of
      (_:_) ->    let nextPos =tokenPos $ ghead "deleteToks1" after
                      oldOffset = getOffset toks nextPos
                      newOffset = getOffset (toks1++before++after) nextPos
                  in  toks1++before++adjustLayout (after++toks22) oldOffset newOffset
      _     -> if toks22 == []
                 then toks1++before
                 else let toks22'=let nextOffset = getOffset toks (tokenPos (ghead "deleteToks2" toks22))
                                  in if isMultiLineComment (lastNonSpaceToken toks21)
                                       then whiteSpaceTokens (-1111, 0) (nextOffset-1) ++ toks22
                                       else toks22
                      in if endsWithNewLn (last (toks1++before)) || startsWithNewLn (ghead "deleteToks3" toks22')
                           then  toks1++before++toks22'
                           --avoiding layout adjustment by adding a `\n', sometimes may produce extra lines.
                             else  toks1++before++[newLnToken]++toks22'
                            --  else toks1 ++ before ++ toks22'
     where

      (toks1, toks2) = let (ts1, ts2)   = break (\t->tokenPos t == startPos) toks
                           (ts11, ts12) = break hasNewLn (reverse ts1)
                       in (reverse ts12, reverse ts11 ++ ts2)
      (toks21, toks22)=let (ts1, ts2) = break (\t -> tokenPos t == endPos) toks2
                           (ts11, ts12) = break hasNewLn ts2
                       in (ts1++ts11++if ts12==[] then [] else [ghead "deleteToks4" ts12], if ts12==[] then [] else gtail "deleteToks5"  ts12)

      -- tokens before the tokens to be deleted at the same line
      before = takeWhile (\t->tokenPos t/=startPos) toks21

      -- tokens after the tokens to be deleted at the same line.
      after = let t= dropWhile (\t->tokenPos t /=endPos) toks21
              in  if t == [] then error "Sorry, HaRe failed to finish this refactoring. DeleteToks"
                             else  gtail "deleteToks6" t

-}

-- ---------------------------------------------------------------------

-- | Adjust the layout to compensate the change in the token stream.
adjustLayout:: [PosToken] -> Int -> Int -> [PosToken]
adjustLayout [] _ _ = []
adjustLayout toks _oldOffset _newOffset = toks -- ++AZ++ temporary while plumbing the rest
{- ++AZ++ TODO: restore and fix this
adjustLayout toks oldOffset newOffset
 | oldOffset == newOffset  = toks

adjustLayout toks oldOffset newOffset
  = case layoutRuleApplies of
    True -> let (ts:ts') = groupTokensByLine  toks
            in ts ++ addRmSpaces (newOffset-oldOffset) oldOffset  ts'  -- THIS IS PROBLEMETIC.
    _    -> toks
  where

  layoutRuleApplies
    = let ts = dropWhile (\t-> (not.elem (tokenCon t)) keyWords)
               -- $ filter notWhite
               $ takeWhile (not.hasNewLn) toks -- ++AZ++ TODO: pretty sure hasNewLn will not give expected result, no whitespace toks in GHC
      in case ts of
         (_: t: _) -> tokenCon t /= "{"
         _         -> False

  keyWords = ["where","let","do","of"]

  addRmSpaces n col [] = []
  addRmSpaces n col toks@(ts:ts')
    =case find notWhite ts of
      Just t  -> if length (concatMap tokenCon ts1) >= col
                 then (addRmSpaces' n ts) ++ addRmSpaces n col ts'
                 else concat toks
      _       -> ts ++ addRmSpaces n col ts'
     where
      (ts1, ts2) = break notWhite ts

  addRmSpaces' 0 ts = ts
  addRmSpaces' _ [] = []
  addRmSpaces' n ts@(t:ts')
    = case n >0 of
       True -> whiteSpaceTokens (tokenRow t,0) n ++ ts   -- CHECK THIS.
       _    -> if isWhiteSpace t
               then addRmSpaces' (n+1) ts'
               else error $ "Layout adjusting failed at line:"
                           ++ show (tokenRow t)++ "."
++AZ++ -}

-- | remove at most n white space tokens from the beginning of ts
doRmWhites::Int -> [PosToken] -> [PosToken]
doRmWhites 0 ts = ts
doRmWhites _ [] = []
doRmWhites _ ts = ts
-- ++AZ++ IS this still needed?
-- doRmWhites n toks@(t:ts)=if isWhiteSpace t then doRmWhites (n-1) ts
--                                            else toks


{-
--add n white space tokens to the beginning of ts
doAddWhites::Int->[PosToken]->[PosToken]
doAddWhites n []=[]
doAddWhites n ts@(t:_)= whiteSpacesToken (tokenRow t,0) n ++ts
-}

-- ++AZ++ : not sure if this is still needed
whiteSpaceTokens :: (Int,Int) -> Int -> [PosToken]
whiteSpaceTokens (_row, _col) _n = []
{-
whiteSpaceTokens (row, col) n
 = if n<=0
    then []
    else (mkToken Whitespace (row,col) " "):whiteSpaceTokens (row,col+1) (n-1)
-}

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

{-
--given an AST phrase, 'startEndLoc' gets its start and end position in the program source.
-- TODO: ++AZ++ get rid of this class
class StartEndLoc t where
   startEndLoc :: [PosToken]-> t ->(SimpPos,SimpPos)


instance StartEndLoc (GHC.HsExpr GHC.RdrName) where
  -- TODO: do this properly
  startEndLoc toks e =
    case e of
      GHC.HsVar id	-> ((0,0),(0,0))

instance StartEndLoc (GHC.Pat GHC.RdrName) where

   startEndLoc toks p =
	case p of
	  GHC.VarPat id -> ((0,0),(0,0))

instance StartEndLoc [GHC.Pat GHC.RdrName] where

   startEndLoc toks ps = ((0,0),(0,0))
-}

-- ---------------------------------------------------------------------
{-
-- | Get the start and end location of the given AST phrase in the
-- original source
getStartEndLoc::(SYB.Data t)=> t -> (SimpPos,SimpPos)
getStartEndLoc t
  = let (startPos',endPos') = (simpPos0,simpPos0)
        locs = srcLocs t
        (startPos,endPos) = (if startPos' == simpPos0 && locs /=[] then ghead "getStartEndLoc" locs
                                                                   else startPos',
                             if endPos' == simpPos0 && locs /= [] then glast "getStartEndLoc" locs
                                                                  else endPos')
    in (startPos, endPos)
{-
getStartEndLoc t
  = let (startPos',endPos') = startEndLocGhc t
        locs = srcLocs t
        (startPos,endPos) = (if startPos' == simpPos0 && locs /=[] then ghead "getStartEndLoc" locs
                                                                   else startPos',
                             if endPos' == simpPos0 && locs /= [] then glast "getStartEndLoc" locs
                                                                  else endPos')
    in (startPos, endPos)
-}
-}
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
getStartEndLoc2::(SYB.Data t)=>[PosToken]->[GHC.GenLocated GHC.SrcSpan t] ->(SimpPos,SimpPos)
getStartEndLoc2 toks ts
  = let (startPos',_) = startEndLocGhc (ghead "getStartEndLoc2" ts)
        (_ , endPos') = startEndLocGhc (glast "getStartEndLoc2" ts)
        locs = srcLocs ts
        (startPos,endPos) = (if startPos' == simpPos0 && locs /=[] then ghead "getStartEndLoc" locs
                                                                   else startPos',
                             if endPos' == simpPos0 && locs /= [] then glast "getStartEndLoc" locs
                                                                  else endPos')
    in (startPos, endPos)
-}

-- ---------------------------------------------------------------------


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

{-
------------------Some functions for associating comments with syntax phrases.---------------------------
{- Note: We assume that a comment before t belongs to t only if there is at most one blank line between them,
         and a cooment after t belongs to t only it the comment starts at the last line of t.
-}
-}

-- |Get the start&end location of syntax phrase t, then extend the end
-- location to cover the comment/white spaces or new line which starts
-- in the same line as the end location
-- TODO: deprecate this in favour of startEndLocIncComments
startEndLocIncFowComment::(SYB.Data t)=>[PosToken]->t->(SimpPos,SimpPos)
startEndLocIncFowComment toks t
  = let (startLoc,_endLoc)=getStartEndLoc t
        (_,endLocIncComments) = startEndLocIncComments toks t
    in (startLoc, endLocIncComments)

{-
adjustOffset::Int->[PosToken]->Bool->[PosToken]
adjustOffset offset [] _ = []
adjustOffset offset toks firstLineIncluded
     = let groupedToks = groupBy (\x y->tokenRow x==tokenRow y) toks  --groupedToks/=[], no problem with 'head'
           --if firstLineIncluded is False, the offset of the first line won't be ajusted.
       in if offset>=0 then if firstLineIncluded
                               then concatMap (doAddWhites offset) groupedToks
                               else ghead "adjustOffset" groupedToks ++ concatMap (doAddWhites offset) (tail groupedToks)
                       else if firstLineIncluded
                               then concatMap (doRmWhites  (-offset)) groupedToks
                               else ghead "adjustOffset" groupedToks ++ concatMap (doRmWhites  (-offset)) (tail groupedToks)

-}

-- ---------------------------------------------------------------------
-- Returned from TokenUtils


--Some functions for fetching a specific field of a token
tokenCol :: PosToken -> Int
tokenCol (GHC.L l _,_) = c where (_,c) = getGhcLoc l

tokenColEnd :: PosToken -> Int
tokenColEnd (GHC.L l _,_) = c where (_,c) = getGhcLocEnd l

tokenRow :: PosToken -> Int
tokenRow (GHC.L l _,_) = r where (r,_) = getGhcLoc l

tokenPos :: (GHC.GenLocated GHC.SrcSpan t1, t) -> SimpPos
tokenPos (GHC.L l _,_)     = getGhcLoc l

tokenPosEnd :: (GHC.GenLocated GHC.SrcSpan t1, t) -> SimpPos
tokenPosEnd (GHC.L l _,_)     = getGhcLocEnd l

-- TODO: badly named function
tokenCon :: PosToken -> String
tokenCon (_,s)     = s

-- ---------------------------------------------------------------------

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


-- ---------------------------------------------------------------------

getGhcLoc :: GHC.SrcSpan -> (Int, Int)
getGhcLoc (GHC.RealSrcSpan ss)  = (GHC.srcSpanStartLine ss, GHC.srcSpanStartCol ss)
getGhcLoc (GHC.UnhelpfulSpan _) = (-1,-1)

getGhcLocEnd :: GHC.SrcSpan -> (Int, Int)
getGhcLocEnd (GHC.RealSrcSpan ss)  = (GHC.srcSpanEndLine ss, GHC.srcSpanEndCol ss)
getGhcLocEnd (GHC.UnhelpfulSpan _) = (-1,-1)

getLocatedStart :: GHC.GenLocated GHC.SrcSpan t -> (Int, Int)
getLocatedStart (GHC.L l _) = getGhcLoc l

getLocatedEnd :: GHC.GenLocated GHC.SrcSpan t -> (Int, Int)
getLocatedEnd (GHC.L l _) = getGhcLocEnd l

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



-- ----------------------------------------------------------------------

-- |Get around lack of instance Eq when simply testing for empty list
emptyList :: [t] -> Bool
emptyList [] = True
emptyList _  = False

nonEmptyList :: [t] -> Bool
nonEmptyList [] = False
nonEmptyList _  = True

-- | Get the start&end location of t in the token stream, then extend
-- the start and end location to cover the preceding and following
-- comments.
--
startEndLocIncComments::(SYB.Data t) => [PosToken] -> t -> (SimpPos,SimpPos)
startEndLocIncComments toks t = startEndLocIncComments' toks (getStartEndLoc t)

{-
startEndLocIncComments' :: [PosToken] -> (SimpPos,SimpPos) -> (SimpPos,SimpPos)
startEndLocIncComments' toks (startLoc,endLoc) =
  let
    (begin,middle,end) = splitToks (startLoc,endLoc) toks

    (leadinr,leadr) = break notWhiteSpace $ reverse begin
    leadr' = filter (\t -> not (isEmpty t)) leadr
    prevLine  = if (emptyList leadr') then 0 else (tokenRow $ ghead "startEndLocIncComments'1" leadr')
    firstLine = if (emptyList middle) then 0 else (tokenRow $ ghead "startEndLocIncComments'1" middle)
    (_,leadComments) = divideComments prevLine firstLine $ reverse leadinr

    (trail,trailrest) = break notWhiteSpace end
    trail' = filter (\t -> not (isEmpty t)) trail
    lastLine = if (emptyList middle)    then    0 else (tokenRow $ glast "startEndLocIncComments'2" middle)
    nextLine = if (emptyList trailrest) then 1000 else (tokenRow $ ghead "startEndLocIncComments'2" trailrest)
    (trailComments,_) =  divideComments lastLine nextLine trail'

    middle' = leadComments ++ middle ++ trailComments
  in
    if (emptyList middle')
      then ((0,0),(0,0))
      else ((tokenPos $ ghead "startEndLocIncComments 4" middle'),(tokenPosEnd $ last middle'))
      -- else error $ "startEndLocIncComments: (prevLine,firstLine) reverse leadr =" ++ (show (prevLine,firstLine)) ++ "," ++ (showToks $ reverse leadr)
-}

startEndLocIncComments' :: [PosToken] -> (SimpPos,SimpPos) -> (SimpPos,SimpPos)
startEndLocIncComments' toks (startLoc,endLoc) =
  let
    (begin,middle,end) = splitToks (startLoc,endLoc) toks

    notIgnored tt = not (isWhiteSpace tt || isThen tt || isElse tt)

    -- (leadinr,leadr) = break notWhiteSpace $ reverse begin
    (leadinr,leadr) = break notIgnored $ reverse begin
    leadr' = filter (\t -> not (isEmpty t)) leadr
    prevLine  = if (emptyList leadr') then 0 else (tokenRow $ ghead "startEndLocIncComments'1" leadr')
    firstLine = if (emptyList middle) then 0 else (tokenRow $ ghead "startEndLocIncComments'1" middle)
    (_nonleadComments,leadComments') = divideComments prevLine firstLine $ reverse leadinr
    leadComments = dropWhile (\tt -> (isThen tt || isElse tt || isEmpty tt)) leadComments'

    (trail,trailrest) = break notWhiteSpace end
    trail' = filter (\t -> not (isEmpty t)) trail
    lastLine = if (emptyList middle)    then    0 else (tokenRow $ glast "startEndLocIncComments'2" middle)
    nextLine = if (emptyList trailrest) then 1000 else (tokenRow $ ghead "startEndLocIncComments'2" trailrest)
    (trailComments,_) =  divideComments lastLine nextLine trail'

    middle' = leadComments ++ middle ++ trailComments
  in
    if (emptyList middle')
      then ((0,0),(0,0))
      else ((tokenPos $ ghead "startEndLocIncComments 4" middle'),(tokenPosEnd $ last middle'))
      -- else error $ "startEndLocIncComments: (prevLine,firstLine) reverse leadr =" ++ (show (prevLine,firstLine)) ++ "," ++ (showToks $ reverse leadr)
      -- else error $ "startEndLocIncComments: (prevLine,firstLine) reverse leadinr =" ++ (show (prevLine,firstLine)) ++ "," ++ (showToks $ reverse leadinr) ++ (show (_nonleadComments,leadComments'))

-- ---------------------------------------------------------------------

-- |Split a set of comment tokens into the ones that belong with the startLine
-- and those that belong with the endLine
divideComments :: Int -> Int -> [PosToken] -> ([PosToken],[PosToken])
divideComments startLine endLine toks = (first,second)
 -- error $ "divideComments:groupGaps=" ++ (show groupGaps)
 -- error $ "divideComments:(firsts,seconds)=" ++ (show (firsts,seconds))
  where
    groups = groupBy groupByAdjacent toks
    groupLines = map (\ts -> ((tokenRow $ ghead "divideComments" ts,tokenRow $ glast "divideComments" ts),ts)) groups
    groupLines' = [((startLine,startLine),[])] ++ groupLines ++ [((endLine,endLine),[])]
    groupGaps = go [] groupLines'
    -- groupGaps is now a list of gaps followed by the tokens. The
    -- last gap has an empty token list, since there is one more gap
    -- than token groups

    -- e.g [(0,[comments1]),(3,[comments2]),(1,[]) captures
    --  ---------------------
    --      b + bar -- ^trailing comment
    --
    --
    -- -- leading comment
    -- foo x y =
    -- ----------------------

    biggest = maximum $ map fst groupGaps

    (firsts,seconds) = break (\(g,_) -> g >= biggest) groupGaps

    first = concatMap snd firsts
    second = concatMap snd seconds

    -- Helpers
    groupByAdjacent :: PosToken -> PosToken -> Bool
    groupByAdjacent a b = 1 + tokenRow a == tokenRow b

    go :: [(Int,[PosToken])] -> [((Int,Int),[PosToken])] -> [(Int,[PosToken])]
    go acc []  = acc
    go acc [_x] = acc
    go acc (((_s1,e1),_t1):b@((s2,_e2),t2):xs) = go (acc ++ [((s2 - e1),t2)] ) (b:xs)


-- ---------------------------------------------------------------------

isWhiteSpace :: PosToken -> Bool
isWhiteSpace tok = isComment tok || isEmpty tok

notWhiteSpace :: PosToken -> Bool
notWhiteSpace tok = not (isWhiteSpace tok)

-- ---------------------------------------------------------------------

isDoubleColon :: PosToken -> Bool
isDoubleColon ((GHC.L _ (GHC.ITdcolon)), "::") = True
isDoubleColon _                                = False

isComment :: PosToken -> Bool
isComment ((GHC.L _ (GHC.ITdocCommentNext _)),_s)  = True
isComment ((GHC.L _ (GHC.ITdocCommentPrev _)),_s)  = True
isComment ((GHC.L _ (GHC.ITdocCommentNamed _)),_s) = True
isComment ((GHC.L _ (GHC.ITdocSection _ _)),_s)    = True
isComment ((GHC.L _ (GHC.ITdocOptions _)),_s)      = True
isComment ((GHC.L _ (GHC.ITdocOptionsOld _)),_s)   = True
isComment ((GHC.L _ (GHC.ITlineComment _)),_s)     = True
isComment ((GHC.L _ (GHC.ITblockComment _)),_s)    = True
isComment ((GHC.L _ _),_s)                         = False

isEmpty :: PosToken -> Bool
isEmpty ((GHC.L _ (GHC.ITsemi)),    "") = True
isEmpty ((GHC.L _ (GHC.ITvocurly)), "") = True
isEmpty ((GHC.L _ _),               "") = True
isEmpty _                               = False

isWhereOrLet :: PosToken -> Bool
isWhereOrLet t = isWhere t || isLet t

-- ---------------------------------------------------------------------
-- This section is horrible because there is no Eq instance for
-- GHC.Token

isWhere :: PosToken -> Bool
isWhere ((GHC.L _ t),_s) =  case t of
                       GHC.ITwhere -> True
                       _           -> False
isLet :: PosToken -> Bool
isLet   ((GHC.L _ t),_s) =  case t of
                       GHC.ITlet -> True
                       _         -> False

isElse :: PosToken -> Bool
isElse   ((GHC.L _ t),_s) =  case t of
                       GHC.ITelse -> True
                       _         -> False

isThen :: PosToken -> Bool
isThen   ((GHC.L _ t),_s) =  case t of
                       GHC.ITthen -> True
                       _         -> False

isOf :: PosToken -> Bool
isOf   ((GHC.L _ t),_s) =  case t of
                       GHC.ITof -> True
                       _        -> False

isDo :: PosToken -> Bool
isDo   ((GHC.L _ t),_s) =  case t of
                       GHC.ITdo -> True
                       _        -> False


-- ---------------------------------------------------------------------


-- ---------------------------------------------------------------------

-- | Get the first SrcSpan found, in top down traversal
getSrcSpan::(SYB.Data t) => t -> Maybe GHC.SrcSpan
getSrcSpan t = res t
  where
    res = somethingStaged SYB.Renamer Nothing
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

-- | Get the indent of the line before, taking into account in-line
-- 'where', 'let', 'in' and 'do' tokens
getIndentOffset :: [PosToken] -> SimpPos -> Int
getIndentOffset [] _pos     = 1
getIndentOffset _toks (0,0) = 1
getIndentOffset toks pos
  = let (ts1, ts2) = break (\t->tokenPos t >= pos) toks
    in if (emptyList ts2)
         then error "HaRe error: position does not exist in the token stream!"
         else let (sl,_) = splitOnNewLn $ reverse ts1
                -- sl is the reversed tokens of the previous line
                  (sls,_) = break isWhereOrLet $ filter (\t -> tokenLen t > 0) sl
                  firstTok = (glast "getIndentOffset" sls)
              in if startLayout firstTok
                  then if (length sls > 1)
                          then tokenOffset (last $ init sls)
                          else 4 + tokenOffset firstTok
                  else tokenOffset firstTok

      where
        tokenOffset t = (tokenCol t) - 1

        startLayout ((GHC.L _ (GHC.ITdo)),_)    = True
        startLayout ((GHC.L _ (GHC.ITin)),_)    = True
        startLayout ((GHC.L _ (GHC.ITlet)),_)   = True
        startLayout ((GHC.L _ (GHC.ITwhere)),_) = True
        startLayout _  = False

-- ---------------------------------------------------------------------

splitOnNewLn :: [PosToken] -> ([PosToken],[PosToken])
splitOnNewLn toks = go [] toks
  -- ++AZ++ : TODO: is this simpler? : (toks1,toks2)=break (\x' -> tokenRow x /= tokenRow x') rtoks

  where
    go [] [] = ([],[])
    go ss [] = (ss,[])
    go [] xs = go [head xs] (tail xs)
    go ss xs
      | onSameLn (glast "splitOnNewLn" ss) (head xs) = go (ss ++ [head xs]) (tail xs)
      | otherwise = (ss,xs)


-- ---------------------------------------------------------------------

tokenLen :: PosToken -> Int
tokenLen (_,s)     = length s   --check this again! need to handle the tab key.

-- ---------------------------------------------------------------------

newLnToken :: PosToken -> PosToken
newLnToken tok = newLinesToken 1 tok

-- ---------------------------------------------------------------------

newLinesToken :: Int -> PosToken -> PosToken
newLinesToken jump (GHC.L l _,_) = (GHC.L l' GHC.ITvocurly,"")
  where
   l' =  case l of
     GHC.RealSrcSpan ss ->
       let
         loc = GHC.mkSrcLoc (GHC.srcSpanFile ss) (jump + GHC.srcSpanEndLine ss) 1
       in
         GHC.mkSrcSpan loc loc
     _ -> l

-- ---------------------------------------------------------------------

groupTokensByLine :: [PosToken] -> [[PosToken]]
groupTokensByLine xs = groupBy fn xs
  where
    fn t1 t2 = tokenRow t1 == tokenRow t2

{-
groupTokensByLine :: [PosToken] -> [[PosToken]]
groupTokensByLine [] = []
groupTokensByLine (xs) =
  let x = head xs
      (xs', xs'') = break (\x' -> tokenRow x /= tokenRow x') xs
  in case xs'' of
      [] -> [xs']
      _  -> (xs'++ [ghead "groupTokensByLine" xs''])
             : groupTokensByLine (gtail "groupTokensByLine" xs'')
-}

-- ---------------------------------------------------------------------

-- | sort out line numbering so that they are always monotonically
-- increasing.
monotonicLineToks :: [PosToken] -> [PosToken]
monotonicLineToks toks = goMonotonicLineToks (0,0) toks

goMonotonicLineToks :: SimpPos -> [PosToken] -> [PosToken]
goMonotonicLineToks _ [] = []
goMonotonicLineToks _ [t] = [t]
goMonotonicLineToks (orow,ocol) (t1:t2:ts)
  = t1:goMonotonicLineToks offset' (t2':ts)
  where
    offset' = if (tokenRow t1 - orow) > (tokenRow t2)
               then (orow + (tokenRow t1) - tokenRow t2 + 1, ocol)
               else (orow,ocol)

    -- t1' = increaseSrcSpan (orow,ocol) t1
    t2' = increaseSrcSpan offset'     t2

-- ---------------------------------------------------------------------

-- |Adjust token stream to cater for changes in token length due to
-- token renaming
reSequenceToks :: [PosToken] -> [PosToken]
reSequenceToks toks = toks

-- ---------------------------------------------------------------------

-- |Compose a new token using the given arguments.
mkToken::GHC.Token -> SimpPos -> String -> PosToken
mkToken t (row,col) c = ((GHC.L l t),c)
  where
    filename = (GHC.mkFastString "f")
    l = GHC.mkSrcSpan (GHC.mkSrcLoc filename row col) (GHC.mkSrcLoc filename row (col + (length c) ))


mkZeroToken :: PosToken
mkZeroToken = mkToken GHC.ITsemi (0,0) ""

-- ---------------------------------------------------------------------

-- |Add a constant line and column offset to a span of tokens
addOffsetToToks :: SimpPos -> [PosToken] -> [PosToken]
addOffsetToToks (r,c) toks = map (\t -> increaseSrcSpan (r,c) t) toks

-- ---------------------------------------------------------------------

onSameLn :: PosToken -> PosToken -> Bool
onSameLn (GHC.L l1 _,_) (GHC.L l2 _,_) = r1 == r2
  where
    (r1,_) = getGhcLoc l1
    (r2,_) = getGhcLoc l2

-- ---------------------------------------------------------------------

-- |Used as a marker in the filename part of the SrcSpan on modified
-- tokens, to trigger re-alignment when retrieving the tokens.
tokenFileMark :: GHC.FastString
tokenFileMark = GHC.mkFastString "HaRe"

-- |Mark a token so that it can be use to trigger layout checking
-- later when the toks are retrieved
markToken :: PosToken -> PosToken
markToken tok = tok'
  where
      (GHC.L l t,s) = tok
      tok' = (GHC.L (GHC.RealSrcSpan l') t,s)

      l' = case l of
            GHC.RealSrcSpan ss ->
                 GHC.mkRealSrcSpan
                      (GHC.mkRealSrcLoc tokenFileMark (GHC.srcSpanStartLine ss)  (GHC.srcSpanStartCol ss))
                      (GHC.mkRealSrcLoc tokenFileMark (GHC.srcSpanEndLine ss)  (GHC.srcSpanEndCol ss))

            _ -> error $ "markToken: expecting a real SrcSpan, got" -- ++ (showGhc l)


-- |Does a token have the file mark in it
isMarked :: PosToken -> Bool
isMarked (GHC.L l _,_) =
  case l of
    GHC.RealSrcSpan ss -> GHC.srcSpanFile ss == tokenFileMark
    _                  -> False

-- ---------------------------------------------------------------------


