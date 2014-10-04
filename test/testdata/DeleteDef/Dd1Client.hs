module DeleteDef.Dd1Client where

import qualified DeleteDef.Dd1 as Dd1

removeNested5s :: [[Integer]] -> [[Integer]]
removeNested5s lst = map Dd1.remove5s lst
