-- 
-- We use a little trick to turn the Data class into Strafunski's Term class.
-- No idea if this is going to work.
-- Cannot be tested right now because of GHC bugs.
-- 

module TermRep (
 Term
) where

import Data.Generics

class Data x => Term x

instance (Typeable x, Data x) => Term x

