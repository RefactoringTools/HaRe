{-# LANGUAGE ScopedTypeVariables #-}
module Demote.UsedAtLevel where

foo :: IO ()
foo = do
  let xx = map (\b -> (b,uses declaredPns [b])) []
  return ()
    where
          ---find how many matches/pattern bindings use  'pn'-------
          -- uses :: [GHC.Name] -> [GHC.LHsBind GHC.Name] -> [Int]
          uses pns t2
               = concatMap used t2
                where

                  used :: LHsBind Name -> [Int]
                  used (L _ (FunBind _n _ (MatchGroup matches _) _ _ _))
                     = concatMap (usedInMatch pns) matches

                  used (L _ (PatBind pat rhs _ _ _))
                    -- was | hsPNs p `intersect` pns ==[]  && any  (flip findPN pat) pns
                    | (not $ findPNs pns pat) && findPNs pns rhs
                    = [1::Int]
                  used  _ = []

          usedInMatch pns (L _ (Match pats _ rhs))
            -- was | isNothing (find (==pname) pns) && any  (flip findPN match) pns
            | (not $ findPNs pns pats) && findPNs pns rhs
             = [1::Int]
          usedInMatch _ _ = []


          uses' :: [Name] -> [LHsBind Name] -> [Int]
          uses' pns t2
               = concat $ everythingStaged Renamer (++) []
                   -- ([] `mkQ`  usedInMatch
                   --    `extQ` usedInPat) t2
                where
                  -- ++AZ++ Not in pattern, but is in RHS
                  -- usedInMatch (match@(HsMatch _ (PNT pname _ _) _ _ _)::HsMatchP)
                  usedInMatch ((Match pats _ rhs) :: Match Name)
                    -- was | isNothing (find (==pname) pns) && any  (flip findPN match) pns
                    | (not $ findPNs pns pats) && findPNs pns rhs
                     = return [1::Int]
                  usedInMatch _ = return []
                  -- usedInMatch _ = mzero

                  -- usedInPat (pat@(Dec (HsPatBind _ p _ _)):: HsDeclP)
                  usedInPat ((PatBind pat rhs _ _ _) :: HsBind Name)
                    -- was | hsPNs p `intersect` pns ==[]  && any  (flip findPN pat) pns
                    | (not $ findPNs pns pat) && findPNs pns rhs
                    = return [1::Int]
                  usedInPat  _ = return []
                  -- usedInPat  _ = mzero


data HsBind a = FunBind a Int (MatchGroup a) Int Int Int
               | PatBind String String Int Int a
data Name = N String
data Located a = L Int a
data MatchGroup a = MatchGroup [LMatch a] a
findPNs = undefined
type LMatch a = Located (Match a)
data Match a = Match String Int a
everythingStaged = undefined
data Renamer = Renamer
mkQ = undefined
extQ = undefined
type LHsBind a = Located (HsBind a)
declaredPns = undefined
