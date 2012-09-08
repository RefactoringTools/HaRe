{-# LANGUAGE Rank2Types #-}
module Main where

-- order of imports analogous to cabal build-depends

-- base
import System.Environment(getArgs)
import Data.IORef 
import Control.Monad ((=<<))

-- gtk
import Graphics.UI.Gtk hiding (get) 

-- hint
import Language.Haskell.Interpreter hiding ((:=),set,get)

-- astview-utils
import Language.Astview.Language

-- local
import Language.Astview.GUIActions (actionEmptyGUI,actionLoadHeadless) 
import Language.Astview.GUIData
import Language.Astview.Registry (loadLanguages)
import Language.Astview.GUI (buildAststate)


-- --------------------------------------------------------
-- * main ()
-- --------------------------------------------------------

-- | loads LanguageRegistration, inits GTK-GUI, checks for a 
-- CLI-argument (one file to parse) and finally starts the GTK-GUI
main :: IO ()
main = do 
  let os = Options "Monospace" 9
  ref <- buildAststate os =<< loadLanguages
  
  args <- getArgs
  case length args of
    0 -> actionEmptyGUI ref
    1 -> actionLoadHeadless L (head args) ref 
    2 -> do
      actionLoadHeadless L (head args) ref 
      actionLoadHeadless R (last args) ref
    _ -> error "Zero, one or two parameter expected"
  
  gui <- getGui ref 
   -- show UI
  widgetShowAll $ window gui
  mainGUI
