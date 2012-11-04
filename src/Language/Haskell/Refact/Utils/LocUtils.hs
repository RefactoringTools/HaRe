{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}

module Language.Haskell.Refact.Utils.LocUtils(
                     {-
                     module HsTokens,
                     PosToken,simpPos,
                     -}
                     SimpPos,unmodified,modified
                     {-
                     ,simpPos0
                     -}
                     , emptyList
                     , showToks
                     , tokenCol, tokenRow
                     , tokenPos
                     , tokenCon
                     , tokenLen
                     -- ,lengthOfToks
                     , mkToken {-,defaultToken-},newLnToken{-,whiteSpacesToken,whiteSpaceTokens
                     -}
                     , isWhite
                     , notWhite
                     , isWhiteSpace
                     {-
                     ,isNewLn,isCommentStart -},isComment {-,
                     isNestedComment,isMultiLineComment,isOpenBracket,isCloseBracket,
                     isOpenSquareBracket,isCloseSquareBracket,isOpenBrace,isConid,
                     isLit,isWhereOrLet,isWhere,isLet,isIn,isCase,isDo,isIf,isForall,
                     isHiding,isModule,isComma,isEqual,isLambda,isIrrefute,isBar,isMinus,
                     endsWithNewLn,startsWithNewLn,hasNewLn,startsWithEmptyLn,
                     lastNonSpaceToken,firstNonSpaceToken,compressPreNewLns,compressEndNewLns
                     -}
                     , lengthOfLastLine
                     , updateToks, updateToksList
                     , getToks
                     , replaceToks -- ,deleteToks, doRmWhites,doAddWhites
                     , srcLocs
                     , getSrcSpan
                     -- , ghcSrcLocs -- Test version
                     , getGhcLoc
                     , getGhcLocEnd
                     , getLocatedStart
                     , getLocatedEnd
                     , getStartEndLoc
                     {-
                     , getStartEndLoc2,
                     startEndLoc,extendBothSides,extendForwards,extendBackwards,
                     startEndLocIncFowComment,startEndLocIncFowNewLn -},startEndLocIncComments {-,
                     prettyprint ,deleteFromToks, prettyprintGuardsAlt,
                     addFormalParams,  adjustOffset, -- try to remove it
                     StartEndLoc, isArrow,-- swapInToks,
                     commentToks
                     -}
                     , tokenise
                     , lexStringToRichTokens
                     , prettyprintPatList
                     , groupTokensByLine
                     -- , addLocInfo
                     , getOffset
                     , splitToks
                     {-
                     , insertComments,
                     extractComments, insertTerms
                     -}
  ) where


import qualified BasicTypes    as GHC
import qualified DynFlags      as GHC
import qualified FastString    as GHC
import qualified GHC           as GHC
import qualified GHC.Paths     as GHC
import qualified HsSyn         as GHC
import qualified Lexer         as GHC
import qualified Module        as GHC
import qualified MonadUtils    as GHC
import qualified Outputable    as GHC
import qualified RdrName       as GHC
import qualified SrcLoc        as GHC
import qualified StringBuffer  as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn

import Data.Maybe
import Data.List
import Debug.Trace

------------------------
import Control.Monad.State
import System.IO.Unsafe

--In the token stream, locations are unique except the default locs.

{- Some related data types defined by Programatica's Lexer:
type Lexer = String -> LexerOutPut

type LexerOutput = [PosToken]

type PosToken = (Token,(Pos,String))

data Pos = Pos { char, line, column :: !Int } deriving (Show)
-- it seems that the field char is used to handle special characters including the '\t'


data Token
  = Varid | Conid | Varsym | Consym
  | Reservedid | Reservedop  | Specialid
  | IntLit | FloatLit | CharLit | StringLit
  | Qvarid | Qconid | Qvarsym | Qconsym
  | Special | Whitespace
  | NestedCommentStart -- will cause a call to an external function
  | NestedComment  -- from the external function
  | Commentstart  -- dashes
  | Comment -- what follows the dashes
  | ErrorToken | GotEOF | TheRest
  | ModuleName | ModuleAlias -- recognized in a later pass
  -- Inserted during layout processing (see Haskell 98, 9.3):
  | Layout     -- for implicit braces
  | Indent Int -- <n>, to preceed first token on each line
  | Open Int   -- {n}, after let, where, do or of, if not followed by a "{"
  deriving (Show,Eq,Ord)
-}

showToks :: [PosToken] -> String
showToks toks = show $ map (\(t@(GHC.L _ tok),s) ->
                 ((getLocatedStart t, getLocatedEnd t),tok,s)) toks

--A flag used to indicate whether the token stream has been modified or not.
unmodified = False
modified   = True

--- some default values----
pos0=Pos 0 0 0
simpPos0 = (0,0)
{-
extractComments :: (SimpPos, SimpPos) -> [PosToken] -> [PosToken]
extractComments ((startPosl, startPosr), endPos) toks
   = let (toks1, toks21, toks22) = splitToks ((startPosl, startPosr), endPos) toks
      in toks1

------------------------------------------------
-}
--Some functions for fetching a specific field of a token
tokenCol (GHC.L l _,_) = c where (_,c) = getGhcLoc l

tokenRow (GHC.L l _,_) = r where (r,_) = getGhcLoc l

tokenPos :: (GHC.GenLocated GHC.SrcSpan t1, t) -> SimpPos
tokenPos (GHC.L l _,_)     = getGhcLoc l

tokenCon (_,s)     = s

tokenLen (_,s)     = length s   --check this again! need to handle the tab key.
{-
lengthOfToks::[PosToken]->Int
lengthOfToks=length.(concatMap tokenCon)
-}
--Some functions for checking whether a token is of a specific type of token.


-- ++WARNING++ : there is no explicit Whitespace token in GHC.
--isWhite (GHC.L _ t,_)                = t==Whitespace || t==Commentstart || t==Comment || t==NestedComment
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

notWhite  = not.isWhite

-- ++WARNING++ : there is no explicit Whitespace token in GHC.
-- isWhiteSpace (t,(_,s))       = t==Whitespace && s==" "
isWhiteSpace _  = False

{-
isNewLn (t,(_,s))            = t==Whitespace && s=="\n"

isCommentStart (t,(_,s))     = t==Commentstart && s=="--"
-}

-- isComment (t,(_,s))          = t==Comment || t ==NestedComment
isComment ((GHC.L _ (GHC.ITdocCommentNext _)),s)  = True
isComment ((GHC.L _ (GHC.ITdocCommentPrev _)),s)  = True
isComment ((GHC.L _ (GHC.ITdocCommentNamed _)),s) = True
isComment ((GHC.L _ (GHC.ITdocSection _ _)),s)    = True
isComment ((GHC.L _ (GHC.ITdocOptions _)),s)      = True
isComment ((GHC.L _ (GHC.ITdocOptionsOld _)),s)   = True
isComment ((GHC.L _ (GHC.ITlineComment _)),s)     = True
isComment ((GHC.L _ (GHC.ITblockComment _)),s)    = True
isComment ((GHC.L _ _),s)                         = False

{-
isNestedComment (t,(_,s))    = t==NestedComment
isMultiLineComment (t,(_,s)) = t==NestedComment && (isJust (find (=='\n') s))

isOpenBracket  (t,(_,s))       = t==Special && s=="("
isCloseBracket (t,(_,s))       = t==Special && s==")"

isOpenSquareBracket  (t,(_,s)) = t==Special && s=="["
isCloseSquareBracket (t,(_,s)) = t==Special && s=="]"

isOpenBrace  (t,(_,s))         = t==Special && s=="{"
isCloseBrace (t,(_,s))         = t==Special && s=="}"

isConid (t,(_,_))              = t==Conid
isLit (t,(_,s)) = t==IntLit || t==FloatLit || t==CharLit || t==StringLit

isWhereOrLet  t   = isWhere t || isLet t
isWhere (t,(_,s)) = t==Reservedid && s=="where"
isLet   (t,(_,s)) = t==Reservedid && s=="let"
isImport (t, (_,s))= t == Reservedid && s=="import"
isType (t, (_,s))= t  == Reservedid && s=="type"
isData (t, (_,s))= t == Reservedid && s=="data"
isFixty (t, (_,s)) = t==Reservedid && (s=="infix" || s=="infixl" || s=="infixr")
isDefault (t, (_,s)) = t == Reservedid && s=="default"
isClass (t, (_,s)) = t == Reservedid && s=="class"
isInstance (t, (_,s)) = t == Reservedid && s=="instance"
isNewtype (t, (_,s)) = t == Reservedid && s=="newtype"

isIn    (t,(_,s))  = t==Reservedid && s=="in"
isCase  (t,(_,s))  = t==Reservedid && s=="case"
isDo    (t,(_,s))  = t==Reservedid && s=="do"
isIf    (t,(_,s))  = t==Reservedid && s=="if"
isForall (t,(_,s)) = t==Reservedid && s=="forall"
isHiding (t,(_,s)) = s=="hiding"
isModule (t,(_,s)) = t==Reservedid && s=="module"

isComma (t,(_,s))    = t==Special && s==","
isEqual  (t,(_,s))   = t==Reservedop && s=="="
isLambda (t,(_,s))   = t==Reservedop && s=="\\"
isIrrefute (t,(_,s)) = t==Reservedop && s=="~"
isBar   (t,(_,s))    = t==Reservedop && s=="|"
isArrow (t,(_,s))    = t==Reservedop && s=="->"
isMinus (t,(_,s))    = t==Varsym && s=="-"

-----------------------------------------------------------------

--Returns True if the token ends with '\n'
endsWithNewLn::PosToken->Bool
endsWithNewLn   (_,(_,s)) =if s==[] then False
                                    else (glast "endsWithNewLn"  s=='\n')

--Returns True if the token starts with `\n`.
startsWithNewLn::PosToken->Bool
startsWithNewLn (_,(_,s)) =if s==[] then False
                                    else ((ghead "starsWithNewLn" s)=='\n')
-}
--Returns True if there is a '\n' in the token.
hasNewLn :: PosToken -> Bool
hasNewLn (GHC.L l _,_) = case l of
  GHC.RealSrcSpan ss -> (GHC.srcSpanStartLine ss /= GHC.srcSpanEndLine ss)
  _ -> False

onSameLn :: PosToken -> PosToken -> Bool
onSameLn (GHC.L l1 _,_) (GHC.L l2 _,_) = r1 == r2
  where
    (r1,_) = getGhcLoc l1
    (r2,_) = getGhcLoc l2

{-
--Returns True if a token stream starts with a newline token (apart from the white spaces tokens)
startsWithEmptyLn::[PosToken]->Bool
startsWithEmptyLn toks=isJust (find isNewLn $ takeWhile (\t->isWhiteSpace t || isNewLn t) toks)

-- get the last non-space token in a token stream.
lastNonSpaceToken::[PosToken]->PosToken
lastNonSpaceToken toks=case dropWhile isWhiteSpace (reverse toks) of
                         [] ->defaultToken
                         l -> ghead "lastNonSpaceToken" l

--get the first non-space token in a token stream.
firstNonSpaceToken::[PosToken]->PosToken
firstNonSpaceToken toks=case dropWhile isWhiteSpace toks of
                         [] ->defaultToken
                         l -> ghead "firstNonSpaceToken" l

-- remove the extra preceding  empty lines.
compressPreNewLns::[PosToken]->[PosToken]
compressPreNewLns toks= let (toks1, toks2) = break (not.(\t->isNewLn t || isWhiteSpace t)) toks
                            groupedToks    = groupTokensByLine toks1
                        in if length groupedToks>1 then (last groupedToks)++toks2
                                                   else toks

--remove the following extra empty lines.
compressEndNewLns::[PosToken]->[PosToken]
compressEndNewLns toks=let (toks1, toks2) = break (not.(\t->isNewLn t || isWhiteSpace t)) (reverse toks)
                           groupedToks    = groupTokensByLine toks1
                       in if length groupedToks>1 then reverse ((ghead "compressEndNewLns" groupedToks)++toks2)
                                                  else toks

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
--Compose a new token using the given arguments.
mkToken::GHC.Token->SimpPos->String->PosToken
mkToken t (row,col) c= ((GHC.L l t),c)
  where 
    filename = (GHC.mkFastString "f")
    l = GHC.mkSrcSpan (GHC.mkSrcLoc filename row col) (GHC.mkSrcLoc filename row (col + (length c) ))


{-
---Restriction: the refactorer should not modify refactorer-modified/created tokens.
defaultToken = (Whitespace, (pos0," "))
newLnToken   = (Whitespace, (pos0,"\n"))
-}
newLnToken :: PosToken
newLnToken = (GHC.L ghcPos0 GHC.ITvocurly,"\n")

ghcPos0 = GHC.mkSrcSpan p0 p0
  where p0 = GHC.mkSrcLoc (GHC.mkFastString "") 1 1

prettyprintPatList :: (t -> String) -> Bool -> [t] -> String
prettyprintPatList prpr beginWithSpace t
     = replaceTabBySpaces $ if beginWithSpace then format1 t else format2 t
 where
   format1 t = foldl (\x y -> x++ " "++ prpr y) "" t

   format2 [] = ""
   format2 [p] = (prpr p) --  (render.ppi) p
   format2 (p:ps) = (prpr p) ++" " ++ format2 ps

--Replace Tab by white spaces. (1 Tab=8 white spaces)
-- TODO: need to be aware of underlying tab stops, advance to next one only
replaceTabBySpaces::String->String
replaceTabBySpaces []=[]
replaceTabBySpaces (s:ss)
  =if s=='\t' then replicate 8 ' ' ++replaceTabBySpaces ss
              else s:replaceTabBySpaces ss

tokenise :: GHC.RealSrcLoc -> Int -> Bool -> [Char] -> IO [PosToken]
tokenise  startPos _ _ [] = return []
tokenise  startPos colOffset withFirstLineIndent str
  = let str' = case lines str of
                    (ln:[]) -> addIndent ln ++ if glast "tokenise" str=='\n' then "\n" else ""
                    (ln:lns)-> addIndent ln ++ "\n" ++ concatMap (\n->replicate colOffset ' '++n++"\n") lns
        str'' = if glast "tokenise" str' == '\n' && glast "tokenise" str /='\n'
                  then genericTake (length str' -1) str'
                  else str'
    -- in expandNewLnTokens $ lexerPass0' startPos str''
    -- in expandNewLnTokens $ GHC.addSourceToTokens startPos

        -- toks = liftIO $ lexStringToRichTokens startPos str''
        toks = lexStringToRichTokens startPos str''
        -- toks = []
    in toks
    -- in error $ "tokenise:" ++ (showToks $ head toks)
   where
     addIndent ln = if withFirstLineIndent
                      then replicate colOffset ' '++ ln
                      else ln

     {- ++AZ++ removed for now. Needed?
     --preprocssing the token stream to expand the white spaces to individual tokens.
     expandNewLnTokens::[PosToken]->[PosToken]
     expandNewLnTokens ts = concatMap expand ts
       where
        expand tok@(Whitespace,(pos,s)) = doExpanding pos s
        expand x = [x]

        doExpanding pos [] =[]
        doExpanding pos@(Pos c row col) (t:ts)
          = case t of
             '\n'  -> (Whitespace, (pos,[t])):(doExpanding (Pos c (row+1) 1) ts)
             _     -> (Whitespace, (pos,[t])):(doExpanding (Pos c row (col+1)) ts)
     -}

-- ---------------------------------------------------------------------

-- lexStringToRichTokens :: GHC.RealSrcLoc -> String -> IO [GHC.Located GHC.Token]
lexStringToRichTokens :: GHC.RealSrcLoc -> String -> IO [PosToken]
lexStringToRichTokens startLoc str = do
  GHC.defaultErrorHandler GHC.defaultLogAction $ do
    GHC.runGhc (Just GHC.libdir) $ do
      dflags <- GHC.getSessionDynFlags
      let dflags' = foldl GHC.xopt_set dflags
                    [GHC.Opt_Cpp, GHC.Opt_ImplicitPrelude, GHC.Opt_MagicHash]
      GHC.setSessionDynFlags dflags'

      -- lexTokenStream :: StringBuffer -> RealSrcLoc -> DynFlags -> ParseResult [Located Token]
      let res = GHC.lexTokenStream (GHC.stringToStringBuffer str) startLoc dflags'
      case res of
        -- GHC.POk _ toks -> return toks
        GHC.POk _ toks -> return $ GHC.addSourceToTokens startLoc (GHC.stringToStringBuffer str) toks 
        GHC.PFailed srcSpan msg -> error $ "lexStringToRichTokens:" -- ++ (show $ GHC.ppr msg)

        -- addSourceToTokens :: RealSrcLoc -> StringBuffer -> [Located Token] -> [(Located Token, String)]

-- ---------------------------------------------------------------------

{-
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

-}

-- ---------------------------------------------------------------------

groupTokensByLine :: [PosToken] -> [[PosToken]]
groupTokensByLine [] = []
groupTokensByLine (xs) = let x = head xs
                             (xs', xs'') = break (\x' -> tokenRow x /= tokenRow x') xs
                      in case xs'' of
                        [] -> [xs']
                        _ ->  (xs'++ [ghead "groupTokensByLine" xs''])
                                : groupTokensByLine (gtail "groupTokensByLine" xs'')
                      -- in if xs''==[] then [xs']
                      --     else (xs'++ [ghead "groupTokensByLine" xs''])
                      --           : groupTokensByLine (gtail "groupTokensByLine" xs'')

{- Old
groupTokensByLine [] = []
groupTokensByLine xs =let (xs', xs'') = break hasNewLn xs
                      in if xs''==[] then [xs']
                          else (xs'++ [ghead "groupTokensByLine" xs''])
                                : groupTokensByLine (gtail "groupTokensByLine" xs'')
-}

-- ---------------------------------------------------------------------

--Give a token stream covering multi-lines, calculate the length of the last line
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
  -- error $ "getToks:startPos=" ++ (show startPos) ++ ",endPos=" ++ (show endPos) ++ ",toks=" ++ (showToks toks)
  let (_,toks2) = break (\t -> tokenPos t >= startPos) toks
      (toks21,toks22) = break (\t -> tokenPos t > endPos) toks2
  -- in (toks21++ [ghead "getToks" toks22])   -- Should add error message for empty list?
  in (toks21)   -- Should add error message for empty list?

-- ---------------------------------------------------------------------

-- | Split the token stream into three parts: the tokens before the
-- startPos, the tokens between startPos and endPos, and the tokens
-- after endPos.
splitToks::(SimpPos, SimpPos)->[PosToken]->([PosToken],[PosToken],[PosToken])
splitToks (startPos, endPos) toks
   = -- trace ("splitToks" ++ (show (startPos,endPos)) ++ (showToks toks))
   (if (startPos, endPos) == (simpPos0, simpPos0)
       then error "Invalid token stream position!"
       else let startPos'= if startPos==simpPos0 then endPos   else startPos
                endPos'  = if endPos == simpPos0 then startPos else endPos
                (toks1, toks2) = break (\t -> tokenPos t == startPos') toks
                (toks21, toks22) = correctBreak startPos' endPos' toks1 toks2 toks

            -- in error ((showToks toks1) ++ "\n" ++ (showToks toks21) ++ "\n" ++ (showToks toks22))
            in      (toks1, toks21 {-++[ghead "splitToks" toks22]-}, toks22) )
  where
    correctBreak startPos' endPos' toks1 toks2 toks
      = if length toks2 == 0
           then let (toks1', toks2) = break (\t -> tokenPos t >= startPos') toks 
                in break (\t -> tokenPos t >= endPos') (drop 2 toks1++toks2)
           else (break (\t -> tokenPos t > endPos') toks2)

-- ---------------------------------------------------------------------

updateToks :: (SYB.Data t)
  => GHC.GenLocated GHC.SrcSpan t -- ^ Old element
  -> GHC.GenLocated GHC.SrcSpan t -- ^ New element
  -> (GHC.GenLocated GHC.SrcSpan t -> [Char]) -- ^ pretty printer
  -- -> RefactGhc (GHC.GenLocated GHC.SrcSpan t, [PosToken]) -- ^ Updated element and toks
  -> RefactGhc () -- ^ Updates the RefactState
updateToks oldAST newAST printFun
  = trace "updateToks" $
    do
       -- st <- get
       -- let toks = rsTokenStream st
       toks <- fetchToks

       let (startPos, endPos) = getStartEndLoc oldAST
           (toks1, _, _)      = splitToks (startPos, endPos) toks
           offset             = lengthOfLastLine toks1

       newToks <- liftIO $ tokenise (GHC.mkRealSrcLoc (GHC.mkFastString "foo") 0 0) 
                           offset False $ printFun newAST  -- TODO: set filename as per loc in oldAST
       let
          toks' = replaceToks toks startPos endPos newToks
       putToks toks' modified
       {-
       if length newToks == 0
         -- then put (RefSt s u toks' modified) -- TODO:how do we flag this? Do we have to?
         then put $ st { rsTokenStream = toks', rsStreamModified = modified} -- TODO:how do we flag this? Do we have to?
         -- else put (RefSt s u toks' modified)
         else put $ st { rsTokenStream = toks', rsStreamModified = modified}
       -}

       -- return (newAST, newToks)
       return ()

-- ---------------------------------------------------------------------

updateToksList :: (SYB.Data t)
  => GHC.GenLocated GHC.SrcSpan t -- ^ Old element
  -> GHC.GenLocated GHC.SrcSpan t -- ^ New element
  -> (GHC.GenLocated GHC.SrcSpan t -> [Char]) -- ^ pretty printer
  -> RefactGhc (GHC.GenLocated GHC.SrcSpan t, [PosToken]) -- ^ Updated element and toks
  -- -> RefactGhc () -- ^ Updates the RefactState
updateToksList oldAST newAST printFun
   = trace "updateToksList" $
     do -- (RefSt s u toks _) <- get
        toks <- fetchToks
        let offset                        = lengthOfLastLine toks1
            (toks1,toks2az, toks3az)      = splitToks (startPos, endPos) toks
            (startPos, endPos)            = getStartEndLoc2 toks [oldAST]
        newToks <- liftIO $ tokenise (GHC.mkRealSrcLoc (GHC.mkFastString "foo") 0 0) offset False $ printFun newAST  -- TODO: set filename as per loc in oldAST
        -- error (GHC.showRichTokenStream newToks)
        -- error ("updateToksList:" ++ (showToks toks1) ++ "\n" ++ (showToks newToks))
        -- error ("updateToksList:" ++ (showToks toks1) ++ "\n" ++ (showToks toks2az) ++ "\n" ++ (showToks toks3az))
        -- error ("updateToksList:" ++ (showToks newToks))
        let
            toks' = replaceToks toks startPos endPos newToks
        putToks toks' modified
        {-
        if length newToks == 0
          then put (RefSt s u toks' modified) -- TODO:how do we flag this? Do we have to?
          else put (RefSt s u toks' modified)
        -}

        return (newAST, newToks)

-- ---------------------------------------------------------------------

-- |Replace a list of tokens in the token stream by a new list of
-- tokens, adjust the layout as well. To use this function make sure
-- the start and end positions really exist in the token stream. QN:
-- what happens if the start or end position does not exist?

replaceToks::[PosToken]->SimpPos->SimpPos->[PosToken]->[PosToken]
replaceToks toks startPos endPos newToks =
 -- error $ "replaceToks: startPos=" ++ (show startPos)
    (if length toks22 == 0
        then toks1 ++ newToks
        else let {-(pos::(Int,Int)) = tokenPos (ghead "replaceToks" toks22)-} -- JULIEN
                 oldOffset = {-getOffset toks pos  -}  lengthOfLastLine (toks1++toks21) --JULIEN
                 newOffset = {-getOffset (toks1++newToks++ toks22) pos -} lengthOfLastLine (toks1++newToks) -- JULIEN
             in  toks1++ (newToks++toks22))  -- adjustLayout toks22 oldOffset newOffset) ) 
   where
      (toks1, toks21, toks22) = splitToks (startPos, endPos) toks

-- ---------------------------------------------------------------------

getOffset toks pos
  = let (ts1, ts2) = break (\t->tokenPos t == pos) toks
    in if (emptyList ts2)
         then error "HaRe error: position does not exist in the token stream!"
         else lengthOfLastLine ts1
{-
getOffset toks pos
  = let (ts1, ts2) = break (\t->tokenPos t == pos) toks
    in if ts2==[]
         then error "HaRe error: position does not exist in the token stream!"
         else lengthOfLastLine ts1
-}

-- ---------------------------------------------------------------------

-- ++AZ++ next bit commented out with --, otherwise ghci complains

-- --comment a token stream specified by the start and end position.
-- commentToks::(SimpPos,SimpPos)->[PosToken]->[PosToken]
-- commentToks (startPos,endPos) toks
--     = let (toks1, toks21, toks22) = splitToks (startPos, endPos) toks
--           toks21' = case toks21 of
--                      []              -> toks21
--                      (t,(l,s)):[]    -> (t, (l, ("{-" ++ s ++ "-}"))):[]
--                      (t1,(l1,s1)):ts -> let lastTok@(t2, (l2, s2)) = glast "commentToks" ts
--                                             lastTok' = (t2, (l2, (s2++" -}")))
--                                         in (t1,(l1, ("{- "++s1))): (reverse (lastTok': gtail "commentToks" (reverse ts)))
--       in (toks1 ++ toks21' ++ toks22)

-- ++AZ++ prev bit commented out with --, otherwise ghci complains

{-
insertTerms :: (SimpPos, SimpPos) -> [PosToken] -> String -> [PosToken]
insertTerms ((startPosl, startPosr), endPos) toks com
    = let (toks1, toks21, toks22) = splitToks ((startPosl, startPosr), endPos) toks
          toks21' = (Commentstart, ((Pos 0 startPosl startPosr) , "")) : [(Comment, ((Pos 0 startPosl startPosr), ("\n" ++ com ++ "\n")))]
      in (toks1 ++ toks21' ++ (toks21 ++ toks22))


insertComments :: (SimpPos, SimpPos) -> [PosToken] -> String -> [PosToken]
insertComments ((startPosl, startPosr), endPos) toks com
    = let (toks1, toks21, toks22) = splitToks ((startPosl, startPosr), endPos) toks
          toks21' = (Commentstart, ((Pos 0 startPosl startPosr) , "")) : [(Comment, ((Pos 0 startPosl startPosr), ("\n{- " ++ com ++ " -}\n")))]
      in (toks1 ++ toks21' ++ (toks21 ++ toks22))

---  - } - }
-}
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
-- Adjust the layout to compensate the change in the token stream.
adjustLayout::[PosToken]->Int->Int->[PosToken]
adjustLayout [] _ _ = []
adjustLayout toks oldOffset newOffset = toks -- ++AZ++ temporary while plumbing the rest
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

{-
-- remove at most n white space tokens from the beginning of ts
doRmWhites::Int->[PosToken]->[PosToken]
doRmWhites 0 ts=ts
doRmWhites n []=[]
doRmWhites n toks@(t:ts)=if isWhiteSpace t then doRmWhites (n-1) ts
                                           else toks

--add n white space tokens to the beginning of ts
doAddWhites::Int->[PosToken]->[PosToken]
doAddWhites n []=[]
doAddWhites n ts@(t:_)= whiteSpacesToken (tokenRow t,0) n ++ts

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

getStartEndLoc :: (SYB.Data t) => t -> (SimpPos,SimpPos)
getStartEndLoc t =
  let
    ss = getSrcSpan t
  in
    case ss of
      Just l -> startEndLocGhc (GHC.L l ss)
      Nothing -> ((0,0),(0,0))

-- ---------------------------------------------------------------------

-- | Get the first SrcSpan found, in top down traversal
getSrcSpan::(SYB.Data t) => t -> Maybe GHC.SrcSpan
getSrcSpan t = res t
  where
    res = somethingStaged SYB.Renamer Nothing
            (Nothing
                    `SYB.mkQ` bind
                    `SYB.extQ` pnt
                    `SYB.extQ` sn
                    `SYB.extQ` literalInExp
                    `SYB.extQ` literalInPat
                    `SYB.extQ` importDecl
            )

    bind :: GHC.GenLocated GHC.SrcSpan (GHC.HsBind GHC.Name) -> Maybe GHC.SrcSpan
    bind (GHC.L l _)              = Just l

    pnt :: GHC.GenLocated GHC.SrcSpan GHC.Name -> Maybe GHC.SrcSpan
    pnt (GHC.L l _)              = Just l

    sn :: GHC.HsModule GHC.RdrName -> Maybe GHC.SrcSpan
    sn (GHC.HsModule (Just (GHC.L l _)) _ _ _ _ _) = Just l
    sn _ = Nothing

    literalInExp :: GHC.LHsExpr GHC.Name -> Maybe GHC.SrcSpan
    literalInExp (GHC.L l _) = Just l

    literalInPat :: GHC.LPat GHC.Name -> Maybe GHC.SrcSpan
    literalInPat (GHC.L l _) = Just l

    importDecl :: GHC.LImportDecl GHC.Name -> Maybe GHC.SrcSpan
    importDecl (GHC.L l _) = Just l

-- ---------------------------------------------------------------------

startEndLocGhc :: GHC.Located b -> (SimpPos,SimpPos)
startEndLocGhc t@(GHC.L l _) =
  case l of
    (GHC.RealSrcSpan ss) ->
      ((GHC.srcSpanStartLine ss,GHC.srcSpanStartCol ss),
       (GHC.srcSpanEndLine ss,GHC.srcSpanEndCol ss))
    (GHC.UnhelpfulSpan _) -> ((0,0),(0,0))

-- ---------------------------------------------------------------------

getStartEndLoc2::(SYB.Data t)=>[PosToken]->[GHC.GenLocated GHC.SrcSpan t] ->(SimpPos,SimpPos)
getStartEndLoc2 toks ts
  = let (startPos',_) = startEndLocGhc (head ts)
        (_ , endPos') = startEndLocGhc (last ts)
        locs = srcLocs ts
        (startPos,endPos) = (if startPos' == simpPos0 && locs /=[] then ghead "getStartEndLoc" locs
                                                                   else startPos',
                             if endPos' == simpPos0 && locs /= [] then glast "getStartEndLoc" locs
                                                                  else endPos')
    in (startPos, endPos)


{- ++AZ++ old version
getStartEndLoc::(Term t, StartEndLoc t)=>[PosToken]->t->(SimpPos,SimpPos)
getStartEndLoc toks t
  = let (startPos',endPos') = startEndLoc toks t
        locs = srcLocs t
        (startPos,endPos) = (if startPos' == simpPos0 && locs /=[] then ghead "getStartEndLoc" locs
                                                                   else startPos',
                             if endPos' == simpPos0 && locs /= [] then glast "getStartEndLoc" locs
                                                                  else endPos')
    in (startPos, endPos)
-}

-- ---------------------------------------------------------------------



{-
-- this function has problems whegtn they encounter sth. like [.....[p]]/
extendBothSides  toks startLoc endLoc  forwardCondFun backwardCondFun
       =let (toks1,toks2)=break (\t->tokenPos t==startLoc) toks
            toks21=gtail ("extendBothSides" ++ (show (startLoc, endLoc, toks2))  ) $ dropWhile (\t->tokenPos t /=endLoc) toks2
            firstLoc=case (dropWhile (not.forwardCondFun) (reverse toks1)) of
                             [] -> startLoc    -- is this the correct default?
                             l  -> (tokenPos.ghead "extendBothSides:lastTok") l
            lastLoc =case (dropWhile (not.backwardCondFun) toks21) of
                            [] ->endLoc   --is this a correct default?
                            l -> (tokenPos.ghead "extendBothSides:lastTok") l
        in (firstLoc, lastLoc)

extendForwards toks startLoc endLoc forwardCondFun
       =let toks1=takeWhile (\t->tokenPos t /= startLoc) toks
            firstLoc=case (dropWhile (not.forwardCondFun) (reverse toks1)) of
                       [] ->startLoc  -- is this the correct default?
                       l -> (tokenPos.ghead "extendForwards") l
        in (firstLoc, endLoc)

extendBackwards toks startLoc endLoc backwardCondFun
       = let toks1= gtail "extendBackwards"  $ dropWhile (\t->tokenPos t /=endLoc) toks
             lastLoc=case (dropWhile (not.backwardCondFun) toks1) of
                          [] ->endLoc -- is this the correct default?
                          l ->(tokenPos. ghead "extendBackwards") l
         in (startLoc, lastLoc)

------------------Some functions for associating comments with syntax phrases.---------------------------
{- Note: We assume that a comment before t belongs to t only if there is at most one blank line between them,
         and a cooment after t belongs to t only it the comment starts at the last line of t.
-}

{-Get the start&end location of syntax phrase t, then extend the end location to cover the comment/white spaces
  or new line which starts in the same line as the end location-}
startEndLocIncFowComment::(Term t, Printable t,StartEndLoc t)=>[PosToken]->t->(SimpPos,SimpPos)
startEndLocIncFowComment toks t
       =let (startLoc,endLoc)=getStartEndLoc toks t
            toks1= gtail "startEndLocIncFowComment"  $ dropWhile (\t->tokenPos t/=endLoc) toks
            toks11 = let (ts1, ts2) = break hasNewLn toks1
                     in (ts1 ++ if ts2==[] then [] else [ghead "startEndLocInFowComment" ts2])
         in  if toks11/=[] && all (\t->isWhite t || endsWithNewLn t) toks11
             then (startLoc, tokenPos (glast "startEndLocIncFowComment" toks11))
             else (startLoc, endLoc)


{-get the start&end location of t in the token stream, then extend the end location to cover
  the following '\n' if there is no other characters (except white space) between t and the '\n'
-}
startEndLocIncFowNewLn::(Term t, Printable t,StartEndLoc t)=>[PosToken]->t->(SimpPos,SimpPos)
startEndLocIncFowNewLn toks t
  =let (startLoc,endLoc)=getStartEndLoc toks t
       toks1 = dropWhile isWhiteSpace $ gtail "startEndLocIncFowNewLn"  $ dropWhile (\t->tokenPos t /=endLoc) toks
       nextTok= if toks1==[] then defaultToken else head toks1
   in if isNewLn nextTok
        then (startLoc, tokenPos nextTok)
        else (startLoc, endLoc)
-}
-- ---------------------------------------------------------------------

-- | Get the start&end location of t in the token stream, then extend
-- the start and end location to cover the preceding and following
-- comments.
startEndLocIncComments::(SYB.Data t) => [PosToken] -> t -> (SimpPos,SimpPos)
startEndLocIncComments toks t

-- ts1 : lead in toks
-- ts2 : start of t to end of file
-- ts11 : reversed leading blank lines of t
-- ts12 : front of file to start of ts11

-- toks11 : front of file to start of blank lines before t
-- toks12 : blank lines, t, to end of file
-- toks12' : just the blank lines

-- TODO: ++AZ++ simplify this, the GHC token stream makes it easier
  =let (startLoc,endLoc) = getStartEndLoc t
       (toks11,toks12)= let (ts1,ts2)    = break (\tok->tokenPos tok == startLoc) toks
                            -- (ts11, ts12) = break hasNewLn (reverse ts1)
                            (ts11, ts12) = break (\tok->tokenRow tok == fst startLoc) (reverse ts1)
                        in (reverse ts12, reverse ts11++ts2)
       toks12'=takeWhile (\tok->tokenPos tok /=startLoc) toks12
       startLoc'=
         if all isWhite toks12'
           then  -- group the toks1 according to lines in a reverse order.
                 let  groupedToks = reverse $ groupTokensByLine toks11
                      -- empty lines right before t
                      -- emptyLns=takeWhile (all (\t->isWhiteSpace t || isNewLn t )) groupedToks
                      emptyLns=[] -- ++AZ++
                      lastComment=if length emptyLns <= 1  -- get the comment if there is any
                                    then takeWhile (all isWhite) $ takeWhile (any isComment) $ groupedToks -- dropWhile
                                             --  (all (\t->isWhiteSpace t || isNewLn t)) groupedToks
                                    else [] -- no comment
                      toks1'=if (not (emptyList lastComment)) then concat $ reverse (emptyLns ++ lastComment)
                                                 else []
                 in if (emptyList toks1')
                       then if (not (emptyList toks12'))
                              then (tokenPos (ghead "startEndLocIncComments"  toks12'))  --there is no comment before t
                              else startLoc
                       --there is a comment before t
                       else tokenPos (ghead "startEndLocIncComments"  toks1')
           else startLoc
       -- tokens after t
       toks2 = gtail "startEndLocIncComments1" $ dropWhile (\tok->(tokenPos tok) < endLoc) toks
       -- toks21 are those tokens that are in the same line with the last line of t
       (toks21,_tok22)= let (ts11, ts12) = break hasNewLn toks2
                       in (ts11 ++ if (emptyList ts12) then [] else [ghead "startEndLocIncComments" ts12],
                                                             gtail "startEndLocIncComments2" ts12)
    in if (emptyList toks21) then (startLoc',endLoc)  -- no following comments.
        else if all (\t->isWhite t {- || endsWithNewLn t -}) toks21 --get the following white tokens in the same
                                                              --line of the last token of t
               then (startLoc', tokenPos (last toks21))
               else (startLoc', endLoc)

emptyList [] = True
emptyList _  = False


{- ++original
{-get the start&end location of t in the token stream, then extend the start and end location to
  cover the preceding and folllowing comments.
-}
startEndLocIncComments::(Term t, StartEndLoc t,Printable t)=>[PosToken]->t->(SimpPos,SimpPos)
startEndLocIncComments toks t
  =let (startLoc,endLoc)=getStartEndLoc toks t
       (toks11,toks12)= let (ts1,ts2) = break (\t->tokenPos t == startLoc) toks
                            (ts11, ts12) = break hasNewLn (reverse ts1)
                        in (reverse ts12, reverse ts11++ts2)
       toks12'=takeWhile (\t->tokenPos t /=startLoc) toks12
       startLoc'=
         if all isWhite  toks12'
           then  -- group the toks1 according to lines in a reverse order.
                 let  groupedToks=reverse $ groupTokensByLine toks11
                      -- empty lines right before t
                      emptyLns=takeWhile (all (\t->isWhiteSpace t || isNewLn t )) groupedToks
                      lastComment=if length emptyLns <=1  -- get the comment if there is any
                                    then takeWhile (all isWhite) $ takeWhile (any isComment) $ dropWhile
                                               (all (\t->isWhiteSpace t || isNewLn t)) groupedToks
                                    else [] -- no comment
                      toks1'=if lastComment /=[] then concat $ reverse (emptyLns ++ lastComment)
                                                 else []
                 in if toks1'==[]
                       then if toks12'/=[]
                              then (tokenPos (ghead "startEndLocIncComments"  toks12'))  --there is no comment before t
                              else startLoc
                       --there is a comment before t
                       else tokenPos (ghead "startEndLocIncComments"  toks1')
           else startLoc
       -- tokens after t
       toks2=gtail "startEndLocIncComments1"  $ dropWhile (\t->tokenPos t/=endLoc) toks
       -- toks21 are those tokens that are in the same line with the last line of t
       (toks21,tok22)= let (ts11, ts12) = break hasNewLn toks2
                       in (ts11 ++ if ts12==[] then [] else [ghead "startEndLocIncComments" ts12],
                                                             gtail "startEndLocIncComments2" ts12)
    in if toks21==[] then (startLoc',endLoc)  -- no following comments.
        else if all (\t->isWhite t || endsWithNewLn t) toks21 --get the following white tokens in the same
                                                              --line of the last token of t
               then (startLoc', tokenPos (last toks21))
               else (startLoc', endLoc)
-}
-- ---------------------------------------------------------------------
{-
--Create a list of white space tokens.
whiteSpacesToken::SimpPos->Int->[PosToken]
whiteSpacesToken (row,col) n
  |n>0        = [(Whitespace,(Pos 0 row col,replicate n ' '))]
  |otherwise  = []

-------------------------------------------------------------------------------------------------

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
