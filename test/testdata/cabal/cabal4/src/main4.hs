-- | Testing that HaRe can find source files from a cabal file

import qualified Foo.Bar as B

import Text.Parsec.Combinator
import Text.Parsec.Prim
import Text.Parsec.Char

main = putStrLn "foo"

baz = 3 + B.baz
