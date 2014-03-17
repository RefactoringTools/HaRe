module Layout.Utils (main, spec) where

main :: IO ()
main = do
  hspec spec

spec :: IO ()
spec = do

  describe "locToExp on ParsedSource" $ do
    it "finds the largest leftmost expression contained in a given region #1" $ do
      (t, _toks) <- parsedFileBGhc
      let parsed1 = pm_parsed_source $ tm_parsed_module t

      let (Just expr) = locToExp (7,7) (7,43) parsed1 :: Maybe (Located (HsExpr RdrName))
      getLocatedStart expr `shouldBe` (7,9)
      getLocatedEnd   expr `shouldBe` (7,42)


parsedFileBGhc :: IO (Int,String)
parsedFileBGhc = undefined
tm_parsed_module = undefined
pm_parsed_source = undefined
locToExp = undefined
getLocatedStart = undefined
getLocatedEnd = undefined
describe = undefined
hspec = undefined
it = undefined
shouldBe = undefined

data Located a = L a
data HsExpr a = HsExpr a
data RdrName = RdrName
data Spec = Spec
