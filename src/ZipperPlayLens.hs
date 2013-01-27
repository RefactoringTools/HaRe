{- # LANGUAGE TypeOperators # -}
{-

Playing with lens zippers, to understand how they can be used to
manage a Data.Tree

-}

-- import Control.Applicative
import Control.Lens
import Control.Lens.Zipper
import Data.Tree
import Data.Tree.Lens

-- ---------------------------------------------------------------------

-- Forest String

-- myTree :: Forest String
myTree = [tree1,tree2]

-- tree1 :: Tree String
tree1 =
    Node "a"
      [Node "aa" []
      ,Node "ab"
         [Node "aba" []
         ,Node "abb" []
         ]
      ]

-- tree2 :: Tree String
tree2 =
  Node "b"
      [Node "ba" []
      ,Node "bb" []
      ]


-- z :: Top :> Forest String
z = zipper myTree


-- Top :>> Tree a :>> a

t1 :: Forest String
t1 = z & fromWithin traverse & rightward <&> view focus

eg1 = zipper ("hello","world")
    & downward _1
    & fromWithin traverse
    & focus .~ 'J'
    & rightmost
    & focus .~ 'y'
    & rezip

{-
-- eg2 :: String
eg2 = zipper tree1
    & downward branches -- branches is in Data.Tree.Lens
    & fromWithin traverse
    & rightward
    & rezip
    -- <&> view focus


-}


-- eg2 :: String
eg2 = zipper tree1
    & fromWithin traverse
    -- & downward  -- branches is in Data.Tree.Lens
    -- & rightward
    -- & focus .~ (Node "new" [])
    & rezip
    -- <&> view focus
