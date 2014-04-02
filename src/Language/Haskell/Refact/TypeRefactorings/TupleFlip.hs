module TupleFlip where
import Language.Haskell.Refact.Utils.Monad
import Language.Haskell.GhcMod
import Language.Haskell.Refact.Utils

tupleFlip :: RefactSettings -> Cradle -> FilePath -> IO [FilePath]
tupleFlip settings cradle fp = runRefacSession settings cradle (comp fp)

comp :: FilePath -> RefactGhc [ApplyRefacResult]
comp fp = do 
   getModuleGhc fp
   renamed <- getRefactRenamed
   parsed  <- getRefactParsed
   return []