{-# LANGUAGE ScopedTypeVariables #-}
module LiftToToplevel.LiftInLambda where

foo :: IO ()
foo = do
  let
    otherBinds = []
    xx = map (\b -> (b,uses declaredPns [b])) otherBinds
    uselist = concatMap (\(b,r) -> if (emptyList r) then [] else [b]) xx
    useCount = sum $ concatMap snd xx
  logm $ "doDemoting': uses xx=" ++ (showGhc xx)
  logm $ "doDemoting': uses uselist=" ++ (showGhc uselist)
  logm $ "doDemoting': uses useCount=" ++ (show useCount)
  return ()

  where
    uses pns t2
         = concat $ everythingStaged Renamer (++) []
             -- ([] `mkQ`  usedInMatch
             --     `extQ` usedInPat ) t2
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

    declaredPns = undefined
    emptyList = undefined
    logm = undefined
    showGhc = undefined
    everythingStaged = undefined
    mkQ = undefined
    extQ = undefined
    findPNs = undefined

data Match a = Match Int a Int
data HsBind a = PatBind Int Int a Int Int
data Name = Name
data Renamer = Renamer
