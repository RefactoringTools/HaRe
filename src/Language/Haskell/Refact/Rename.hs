module Language.Haskell.Refact.Rename(rename,t1) where

import qualified Data.Generics.Schemes as SYB
import qualified Data.Generics.Aliases as SYB
import qualified GHC.SYB.Utils         as SYB

import qualified GHC
import qualified DynFlags              as GHC
import qualified Outputable            as GHC
import qualified MonadUtils            as GHC
import qualified Name                  as GHC
import qualified RdrName               as GHC
import qualified OccName               as GHC
import qualified Unique                as GHC
import qualified FastString            as GHC

import qualified Data.Generics as SYB
import qualified GHC.SYB.Utils as SYB

import GHC.Paths ( libdir )
import Control.Monad
import Control.Monad.State
import Data.Data
import Data.Maybe

import Language.Haskell.Refact.Utils
import Language.Haskell.Refact.Utils.GhcUtils
import Language.Haskell.Refact.Utils.LocUtils
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.Refact.Utils.TypeSyn
import Language.Haskell.Refact.Utils.TypeUtils

t1 = rename ["../old/refactorer/B.hs","4","7","4","43"]

-- TODO: This boilerplate will be moved to the coordinator, just the refac session will be exposed
rename :: [String] -> IO () -- For now
rename args
  = do let fileName = args!!0
           beginPos = (read (args!!1), read (args!!2))::(Int,Int)
           endPos   = (read (args!!3), read (args!!4))::(Int,Int)
       runRefacSession Nothing (comp fileName beginPos endPos)
       return ()

-- body of refac
comp :: String -> SimpPos -> SimpPos -> RefactGhc [ApplyRefacResult]
comp fileName beginPos endPos = do
       -- modInfo@((_, renamed, ast), toks) <- parseSourceFileGhc fileName
       modInfo@(t, toks) <- parseSourceFileGhc fileName
       let renamed = gfromJust "ifToCase" $ GHC.tm_renamed_source t
       -- let expr = locToExp beginPos endPos renamed
--       case expr of
--         Just exp1@(GHC.L _ (GHC.HsIf _ _ _ _))
       refactoredMod <- applyRefac (renameAll) (Just modInfo ) fileName
       return [refactoredMod]
       --  _      -> error $ "You haven't selected an if-then-else  expression!" --  ++ (show (beginPos,endPos,fileName)) ++ "]:" ++ (SYB.showData SYB.Parser 0 $ ast)


renameAll ::
  -- GHC.Located (GHC.HsExpr GHC.Name)
  RefactGhc ()
renameAll = do
  rs <- getRefactRenamed
  reallyRenameAll rs

reallyRenameAll rs = do
   everywhereMStaged SYB.Renamer (SYB.mkM inFun `SYB.extM` inExp) rs
   return ()
       where
         inExp :: (GHC.Located (GHC.HsExpr GHC.Name)) -> RefactGhc (GHC.Located (GHC.HsExpr GHC.Name))

         inExp exp1@(GHC.L x (GHC.HsVar _))
           -- = let newExp = ifToCaseTransformPs exp1
           -- = let newExp = ifToCaseTransform exp1
           --   in update exp1 newExp exp1
           = do
               let (free, declared) = hsFreeAndDeclaredPNs rs -- free and declared
                   fd = map nameToString (free ++ declared)
                   newNameStr = mkNewName "ge" fd 0 -- TODO: change empty list to list of declared names
                   occName = GHC.mkVarOcc newNameStr
                   unique = GHC.mkVarOccUnique $ GHC.mkFastString newNameStr
                   newName = GHC.mkSystemName unique occName
                   newExp = GHC.L x (GHC.HsVar newName)
               update exp1 newExp exp1
               return newExp

         inExp e = return e
         
         inFun :: (GHC.HsBindLR GHC.Name GHC.Name) -> RefactGhc (GHC.HsBindLR GHC.Name GHC.Name)
         inFun (GHC.FunBind exp1@(GHC.L x y) a b c fvs d) 
            -- = let newExp = ifToCaseTransformPs exp1
            -- = let newExp = ifToCaseTransform exp1
            --   in update exp1 newExp exp1
            = do
                let (free, declared) = hsFreeAndDeclaredPNs rs -- free and declared
                    fd = map nameToString (free ++ declared)
                    newStr = mkNewName "ge" fd 0 -- TODO: change empty list to list of declared names
                    newExp = GHC.mkVarOcc newStr
                    newExp' = GHC.mkSystemName (GHC.mkVarOccUnique (GHC.mkFastString newStr)) newExp
                update exp1 (GHC.L x (GHC.HsVar newExp')) exp1
                return (GHC.FunBind (GHC.L x newExp') a b c fvs d)

         inFun e = return e
          
          -- bind ((GHC.FunBind _ _ _ _ fvs _)::(GHC.HsBindLR GHC.Name GHC.Name)) = [fvs]
          -- bind ((GHC.PatBind _ _ _ fvs _)  ::(GHC.HsBindLR GHC.Name GHC.Name)) = [fvs]
          -- bind _ = []