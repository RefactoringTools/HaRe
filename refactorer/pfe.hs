
--import System(getArgs)
import PPU(getPPopts)

import HsParser(parse)
import HsLexerPass1(lexerPass0)
--import DefinedNamesBase()
import FreeNamesBase()
import ScopeNamesBase()
import NameMapsBase()
import ReAssocBase()
import RemoveListCompBase()
import SimpPatMatchBase()

import TiDecorate(TiDecls) -- to choose result type from the type checker
import HsModule
import qualified IO
import Pfe0Cmds(addHelpCmd)
import Pfe4Cmds(pfe4Cmds)
import PFE4(PFE4Info)
import Pfe3Metrics(pfe3MetricsCmds)
import PFEdeps(clean5)
import PfeHtmlCmds(pfeHtmlCmds)
import PfeChase(pfeChaseCmds)
import PfeTransformCmds(pfeTransformCmds)
import PfeDepCmds(runPFE5Cmds,pfeDepCmds)
import PfeCleanCmd(pfeCleanCmd)
-- import PfeInteractive(pfeiAllCmds,runSIO)
import MapDeclMBase() -- for removing pattern bindings in PfeTransformCmds.
--import RemoveIrrefPatsBase()

import PfeRefactoringCmds(pfeRefactoringCmds) 

main = do
          IO.hSetBuffering IO.stdout IO.NoBuffering
          x <- getPPopts
          runPFE5Cmds () pfeCmds (lexerPass0,parse) x   


-- main = runPFE5Cmds () pfeCmds (lexerPass0,parse) =<< getPPopts

pfeCmds = pfe4Cmds tcOutput++pfeTransformCmds
          ++pfeChaseCmds++pfeHtmlCmds++pfeDepCmds++pfeCleanCmd clean5
          ++pfeRefactoringCmds 

tcOutput = id :: I (PFE4Info i2 (TiDecls i2))
--tcOutput = id :: I [[HsModuleR]]
type I a = a->a
