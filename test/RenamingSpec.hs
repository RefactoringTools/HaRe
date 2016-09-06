module RenamingSpec (main, spec) where

import           Test.Hspec

import Language.Haskell.Refact.Refactoring.Renaming

import TestUtils

import System.Directory

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do

  describe "Renaming" $ do
    it "renames in D1 B1 C1 A1 6 6" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/D1.hs" "AnotherTree" (6,6)
     -- r <- ct $ rename logTestSettings testOptions "./Renaming/D1.hs" "AnotherTree" (6,6)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r

     r' `shouldBe` [ "Renaming/D1.hs"
                   , "Renaming/A1.hs"
                   , "Renaming/B1.hs"
                   , "Renaming/C1.hs"
                   ]

     diffD <- ct $ compareFiles "./Renaming/D1.hs.expected"
                                "./Renaming/D1.refactored.hs"
     diffD `shouldBe` []

     diffC <- ct $ compareFiles "./Renaming/C1.hs.expected"
                                "./Renaming/C1.refactored.hs"
     diffC `shouldBe` []

     diffB <- ct $ compareFiles "./Renaming/B1.hs.expected"
                                "./Renaming/B1.refactored.hs"
     diffB `shouldBe` []

     diffA <- ct $ compareFiles "./Renaming/A1.hs.expected"
                                "./Renaming/A1.refactored.hs"
     diffA `shouldBe` []

    -- ---------------------------------

    it "renames in D2 B2 C2 A2 6 24" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/D2.hs" "SubTree" (6,24)
     -- r <- ct $ rename logTestSettings testOptions "./Renaming/D2.hs" "SubTree" (6,24)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r

     r' `shouldBe` [ "Renaming/D2.hs"
                   , "Renaming/B2.hs"
                   , "Renaming/C2.hs"
                   ]

     diffD <- ct $  compareFiles "./Renaming/D2.hs.expected"
                                 "./Renaming/D2.refactored.hs"
     diffD `shouldBe` []

     diffC <- ct $ compareFiles "./Renaming/C2.hs.expected"
                                "./Renaming/C2.refactored.hs"
     diffC `shouldBe` []

     diffB <- ct $ compareFiles "./Renaming/B2.hs.expected"
                                "./Renaming/B2.refactored.hs"
     diffB `shouldBe` []

    -- ---------------------------------

    it "renames in D3 B3 C3 A3 12 7" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/D3.hs" "Same" (12,7)
     -- r <- ct $ rename logTestSettings testOptions "./Renaming/D3.hs" "Same" (12,7)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r

     r' `shouldBe` [ "Renaming/D3.hs"
                   , "Renaming/B3.hs"
                   , "Renaming/C3.hs"
                   ]

     diffD <- ct $ compareFiles "./Renaming/D3.hs.expected"
                                "./Renaming/D3.refactored.hs"
     diffD `shouldBe` []

     diffC <- ct $ compareFiles "./Renaming/C3.hs.expected"
                                "./Renaming/C3.refactored.hs"
     diffC `shouldBe` []

     diffB <- ct $ compareFiles "./Renaming/B3.hs.expected"
                                "./Renaming/B3.refactored.hs"
     diffB `shouldBe` []

    -- ---------------------------------

    it "renames in D4 B4 C4 A4 13 4" $ do
     --     (["D4.hs","B4.hs","C4.hs","A4.hs"],["isSameOrNot","13","4"]),
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/D4.hs" "isSameOrNot" (13,4)
     -- r <- ct $ rename logTestSettings testOptions "./Renaming/D4.hs" "isSameOrNot" (13,4)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r

     r' `shouldBe` [ "Renaming/D4.hs"
                   , "Renaming/A4.hs"
                   , "Renaming/B4.hs"
                   , "Renaming/C4.hs"
                  ]

     diffD <- ct $ compareFiles "./Renaming/D4.hs.expected"
                                "./Renaming/D4.refactored.hs"
     diffD `shouldBe` []

     diffC <- ct $ compareFiles "./Renaming/C4.hs.expected"
                                "./Renaming/C4.refactored.hs"
     diffC `shouldBe` []

     diffB <- ct $ compareFiles "./Renaming/B4.hs.expected"
                                "./Renaming/B4.refactored.hs"
     diffB `shouldBe` []

     diffA <- ct $ compareFiles "./Renaming/A4.hs.expected"
                                "./Renaming/A4.refactored.hs"
     diffA `shouldBe` []

    -- ---------------------------------

    it "renames in D5 B5 C5 A5 24 1" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/D5.hs" "sum" (24,1)
     -- r <- ct $ rename logTestSettings testOptions "./Renaming/D5.hs" "sum" (24,1)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r

     r' `shouldBe` [ "Renaming/D5.hs"
                   , "Renaming/A5.hs"
                   , "Renaming/B5.hs"
                   , "Renaming/C5.hs"
                   ]

     diffD <- ct $ compareFiles "./Renaming/D5.hs.expected"
                                "./Renaming/D5.refactored.hs"
     diffD `shouldBe` []

     diffC <- ct $ compareFiles "./Renaming/C5.hs.expected"
                                "./Renaming/C5.refactored.hs"
     diffC `shouldBe` []

     diffB <- ct $ compareFiles "./Renaming/B5.hs.expected"
                                "./Renaming/B5.refactored.hs"
     diffB `shouldBe` []

     diffA <- ct $ compareFiles "./Renaming/A5.hs.expected"
                                "./Renaming/A5.refactored.hs"
     diffA `shouldBe` []

    -- ---------------------------------

    it "renames in D7 C7  10 1" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/D7.hs" "myFringe" (10,1)
     -- r <- ct $ rename logTestSettings testOptions "./Renaming/D7.hs" "myFringe" (10,1)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r

     r' `shouldBe` [ "Renaming/D7.hs"
                   , "Renaming/C7.hs"
                   ]

     diffD <- ct $ compareFiles "./Renaming/D7.hs.expected"
                               "./Renaming/D7.refactored.hs"
     diffD `shouldBe` []

     diffC <- ct $ compareFiles "./Renaming/C7.hs.expected"
                                "./Renaming/C7.refactored.hs"
     diffC `shouldBe` []


    -- ---------------------------------

    it "renames in Field1 5 18" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/Field1.hs" "pointx1" (5,18)
     -- r <- ct $ rename logTestSettings testOptions "./Renaming/Field1.hs" "pointx1" (5,18)
     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/Field1.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/Field1.hs.expected"
                               "./Renaming/Field1.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------

    it "renames in Field3 9 1" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/Field3.hs" "abs" (9,1)
     -- r <- ct $ rename logTestSettings testOptions "./Renaming/Field3.hs" "abs" (9,1)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/Field3.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/Field3.hs.expected"
                               "./Renaming/Field3.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------

    it "renames in Field4 5 23" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/Field4.hs" "value2" (5,23)
     -- ct $ rename logTestSettings Nothing "./Renaming/Field4.hs" "value2" (5,23)
     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/Field4.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/Field4.hs.expected"
                               "./Renaming/Field4.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------

    it "renames in IdIn1 11 1" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/IdIn1.hs" "x1" (11,1)
     -- ct $ rename logTestSettings testOptions "./Renaming/IdIn1.hs" "x1" (11,1)
     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/IdIn1.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/IdIn1.hs.expected"
                               "./Renaming/IdIn1.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------

    it "renames in IdIn2 15 7" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/IdIn2.hs" "x1" (15,7)
     -- r <- ct $ rename logTestSettings testOptions "./Renaming/IdIn2.hs" "x1" (15,7)
     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/IdIn2.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/IdIn2.hs.expected"
                               "./Renaming/IdIn2.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------

    it "renames in ClassIn1 7 7" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/ClassIn1.hs" "MyReversable" (7,7)
     -- ct $ rename logTestSettings testOptions Nothing "./Renaming/ClassIn1.hs" "MyReversable" (7,7)
     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/ClassIn1.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/ClassIn1.hs.expected"
                               "./Renaming/ClassIn1.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------

    it "renames in ClassIn2 8 3" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/ClassIn2.hs" "reversable" (8,3)
     -- ct $ rename logTestSettings testOptions Nothing "./Renaming/ClassIn2.hs" "reversable" (8,3)
     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/ClassIn2.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/ClassIn2.hs.expected"
                               "./Renaming/ClassIn2.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------

    it "renames in ConstructorIn1 8 6" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/ConstructorIn1.hs" "MyBTree" (8,6)
     -- ct $ rename logTestSettings testOptions "./Renaming/ConstructorIn1.hs" "MyBTree" (8,6)
     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/ConstructorIn1.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/ConstructorIn1.hs.expected"
                               "./Renaming/ConstructorIn1.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------

    it "renames in ConstructorIn2 8 6" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/ConstructorIn2.hs" "Tree" (8,24)
     -- ct $ rename logTestSettings testOptions Nothing "./Renaming/ConstructorIn2.hs" "Tree" (8,24)
     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/ConstructorIn2.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/ConstructorIn2.hs.expected"
                               "./Renaming/ConstructorIn2.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------

    it "renames in ConstructorIn3 9 12" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/ConstructorIn3.hs" "b" (9,13)
     -- ct $ rename logTestSettings testOptions "./Renaming/ConstructorIn3.hs" "b" (9,13)
     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/ConstructorIn3.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/ConstructorIn3.hs.expected"
                               "./Renaming/ConstructorIn3.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------

    it "renames in LayoutIn1 7 17" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/LayoutIn1.hs" "square" (7,17)
     -- ct $ rename logTestSettings testOptions "./Renaming/LayoutIn1.hs" "square" (7,17)
     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/LayoutIn1.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/LayoutIn1.hs.expected"
                               "./Renaming/LayoutIn1.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------

    it "renames in LayoutIn2 8 7" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/LayoutIn2.hs" "ls" (8,7)
     -- ct $ rename logTestSettings testOptions Nothing "./Renaming/LayoutIn2.hs" "ls" (8,7)
     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/LayoutIn2.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/LayoutIn2.hs.expected"
                               "./Renaming/LayoutIn2.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------

    it "renames in LayoutIn3 7 13" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/LayoutIn3.hs" "anotherX" (7,13)
     -- ct $ rename logTestSettings testOptions "./Renaming/LayoutIn3.hs" "anotherX" (7,13)
     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/LayoutIn3.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/LayoutIn3.hs.expected"
                               "./Renaming/LayoutIn3.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------

    it "renames in LayoutIn4 7 8" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/LayoutIn4.hs" "io" (7,8)
     -- ct $ rename logTestSettings testOptions "./Renaming/LayoutIn4.hs" "io" (7,8)
     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/LayoutIn4.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/LayoutIn4.hs.expected"
                               "./Renaming/LayoutIn4.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------
    -- Negative tests
    -- ---------------------------------

    it "naming clash at top level IdIn3" $ do
     -- rename logTestSettings testOptions Nothing "./Renaming/IdIn3.hs" "foo" (10,1)
     res <- catchException (ct $ rename defaultTestSettings testOptions "./Renaming/IdIn3.hs" "foo" (10,1))
     (show res) `shouldBe` "Just \"Name 'foo' already exists in this module\\n\""

    -- ---------------------------------

    it "upper case name for fn fails IdIn4" $ do
     -- rename logTestSettings testOptions Nothing "./Renaming/IdIn4.hs" "Foo" (12,1)
     res <- catchException (ct $ rename defaultTestSettings testOptions "./Renaming/IdIn4.hs" "Foo" (12,1))
     (show res) `shouldBe` "Just \"The new name should be an identifier!\""

    -- ---------------------------------

    it "naming clash IdIn5" $ do
     -- ct $ rename logTestSettings testOptions "./Renaming/IdIn5.hs" "y" (10,1)
     res <- catchException (ct $ rename defaultTestSettings testOptions "./Renaming/IdIn5.hs" "y" (10,1))
     (show res) `shouldBe` "Just \"Name 'y' already exists, or renaming 'IdIn5.x' to 'y' will change the program's semantics!\\n\""

    -- ---------------------------------

    it "must rename in home module ClassIn3" $ do
     -- rename logTestSettings testOptions Nothing "./Renaming/ClassIn3.hs" "Eq1" (16,10)
     res <- catchException (ct $ rename defaultTestSettings testOptions "./Renaming/ClassIn3.hs" "Eq1" (16,10))
     (show res) `shouldBe` "Just \"This identifier is defined in module GHC.Classes, please do renaming in that module!\""

    -- ---------------------------------

    it "will not rename existing name Field2" $ do
     -- rename logTestSettings testOptions Nothing "./Renaming/Field2.hs" "absPoint" (5,18)
     res <- catchException (ct $ rename defaultTestSettings testOptions "./Renaming/Field2.hs" "absPoint" (5,18))
     (show res) `shouldBe` "Just \"Name 'absPoint' already exists in this module\\n\""

    -- ---------------------------------

    it "must qualify clashes Qualifier" $ do
     -- rename logTestSettings testOptions "./Renaming/Qualifier.hs" "sum" (13,1)
     res <- catchException (ct $ rename defaultTestSettings testOptions "./Renaming/Qualifier.hs" "sum" (13,1))
     (show res) `shouldBe` "Just \"The new name will cause an ambiguous occurrence problem, please select another new name or qualify the use of 'sum' before renaming!\\n\""

    -- ---------------------------------

    it "cannot rename main Main" $ do
     -- rename logTestSettings testOptions "./Renaming/Main.hs" "main1" (11,1)
     res <- catchException (ct $ rename defaultTestSettings testOptions "./Renaming/Main.hs" "main1" (11,1))
     (show res) `shouldBe` "Just \"The 'main' function defined in a 'Main' module should not be renamed!\""

    -- ---------------------------------

    it "cannot rename main Main2" $ do
     -- res <- catchException (ct $ rename logTestSettings testOptions "./Renaming/Main2.hs" "main1" (4,1))
     res <- catchException (ct $ rename defaultTestSettings testOptions "./Renaming/Main2.hs" "main1" (4,1))
     (show res) `shouldBe` "Just \"The 'main' function defined in a 'Main' module should not be renamed!\""

    -- ---------------------------------

    it "rename with default main Main2" $ do
     -- ct $ rename logTestSettings testOptions "./Renaming/Main2.hs" "baz" (6,1)
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/Main2.hs" "baz" (6,1)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/Main2.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/Main2.hs.expected"
                               "./Renaming/Main2.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------

    it "rename in a do statement" $ do
     -- ct $ rename logTestSettings testOptions "./Layout/Do1.hs" "g2" (10,3)
     r <- ct $ rename defaultTestSettings testOptions "./Layout/Do1.hs" "g2" (10,3)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Layout/Do1.hs"
                  ]
     diff <- ct $ compareFiles "./Layout/Do1.hs.expected"
                               "./Layout/Do1.refactored.hs"
     diff `shouldBe` []

    -- ---------------------------------

    it "renames in QualServer QualClient" $ do
     r <- ct $ rename defaultTestSettings testOptions  "./Renaming/QualServer.hs" "foo1" (11,1)
     -- r <- ct $ rename logTestSettings testOptions  "./Renaming/QualServer.hs" "foo1" (11,1)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r

     r' `shouldBe` ["Renaming/QualServer.hs",
                    "Renaming/QualClient.hs"
                  ]

     diffD <- ct $ compareFiles "./Renaming/QualServer.expected.hs"
                                "./Renaming/QualServer.refactored.hs"
     diffD `shouldBe` []

     diffC <- ct $ compareFiles "./Renaming/QualClient.expected.hs"
                                "./Renaming/QualClient.refactored.hs"
     diffC `shouldBe` []

    -- ---------------------------------

    it "renames in lib and in main 1" $ do
     let ct4 = cdAndDo "./test/testdata/cabal/cabal4"
     r <- ct4 $ rename defaultTestSettings testOptions  "./src/Foo/Bar.hs" "baz1" (3,1)
     -- r <- cdAndDo "./test/testdata/cabal/cabal4" $ rename logTestSettings testOptions  "./src/Foo/Bar.hs" "baz1" (3,1)

     r' <- ct4 $ mapM makeRelativeToCurrentDirectory r

     r' `shouldBe` ["src/Foo/Bar.hs",
                    "src/main4.hs"
                  ]

     diffD <- ct4 $ compareFiles "./src/Foo/Bar.expected.hs"
                                 "./src/Foo/Bar.refactored.hs"
     diffD `shouldBe` []

     diffC <- ct4 $ compareFiles "./src/main4.expected.hs"
                                 "./src/main4.refactored.hs"
     diffC `shouldBe` []

    -- ---------------------------------

    it "renames in lib and in main 2" $ do
     let ctf = cdAndDo "./test/testdata/cabal/foo"
     r <- ctf $ rename defaultTestSettings testOptions  "./src/Foo/Bar.hs" "bar1" (3,1)
     -- r <- cdAndDo "./test/testdata/cabal/foo" $ rename logTestSettings testOptions  "./src/Foo/Bar.hs" "bar1" (3,1)

     r' <- ctf $ mapM makeRelativeToCurrentDirectory r

     r' `shouldBe` ["src/Foo/Bar.hs",
                    "src/Main.hs"
                  ]

     diffD <- ctf $ compareFiles "./src/Foo/Bar.expected.hs"
                                 "./src/Foo/Bar.refactored.hs"
     diffD `shouldBe` []

     diffC <- ctf $ compareFiles "./src/Main.expected.hs"
                                 "./src/Main.refactored.hs"
     diffC `shouldBe` []

    -- ---------------------------------

{-
    it "rename gives noRebindableInfo MoveDef" $ do
     -- ct $ rename logTestSettings testOptions "./src/Language/Haskell/Refact/MoveDef.hs" "t2" (1105,20)
     r <- ct $ rename defaultTestSettings (testOptions { cradleCabalDir = Just ".", cradleCabalFile = Just "HaRe.cabal"}) "./src/Language/Haskell/Refact/MoveDef.hs" "t2" (1105,20)

     r `shouldBe` [ "Renaming/Main2.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/Main2.hs.expected"
                               "./Renaming/Main2.refactored.hs"
     diff `shouldBe` []
-}

    -- ---------------------------------

    it "ConflictExports" $ do
     -- rename (logTestSettingsMainfile "./Renaming/ConflictExport.hs") testOptions "./Renaming/ConflictExport.hs" "fringe" (7,1)
     res <- catchException (ct $ rename defaultTestSettings testOptions "./Renaming/ConflictExport.hs" "fringe" (7,1))
     -- res <- catchException (ct $ rename (testSettingsMainfile "./Renaming/ConflictExport.hs") testOptions "./Renaming/ConflictExport.hs" "fringe" (7,1))
     (show res) `shouldBe` "Just \"The new name will cause conflicting exports, please select another new name!\""

{-
TestCases{refactorCmd="rename",
positive=[
          (["D1.hs","B1.hs","C1.hs","A1.hs"],["AnotherTree", "6", "6"]),
          (["D2.hs","B2.hs","C2.hs","A2.hs"],["SubTree" , "6", "24"]),
          (["D3.hs","B3.hs","C3.hs","A3.hs"],["Same","12","7"]),
          (["D4.hs","B4.hs","C4.hs","A4.hs"],["isSameOrNot","13","4"]),
          (["D5.hs","B5.hs","C5.hs","A5.hs"],["sum","24","1"]),
          (["D7.hs","C7.hs"],["myFringe","10","1"]),
          (["Field1.hs"],["pointx1","5","18"]),
          (["Field3.hs"],["abs", "9","1"]),
          (["Field4.hs"],["value2","5","23"]),
          (["IdIn1.hs"],["x1","11","1"]),
          (["IdIn2.hs"],["x1","15","7"]),
          (["ClassIn1.hs"],["MyReversable","7","7"]),
          (["ClassIn2.hs"],["reversable","8","3"]),
          (["ConstructorIn1.hs"],["MyBTree","8","6"]),
          (["ConstructorIn2.hs"],["Tree","8","24"]),
          (["ConstructorIn3.hs"],["b","9","12"]),
          (["LayoutIn1.hs"],["square","7","17"]),
          (["LayoutIn2.hs"],["ls","8","7"]),
          (["LayoutIn3.hs"],["anotherX","7","13"]),
          (["LayoutIn4.hs"],["io","7","8"])],
negative=[(["IdIn3.hs"],["foo","10","1"]),
          (["IdIn4.hs"],["Foo","12","1"]),
          (["IdIn5.hs"],["y","10","1"]),
          (["ClassIn3.hs"],["Eq1","16","10"]),
          (["Field2.hs"], ["absPoint", "5", "18"]),
          (["Qualifier.hs"],["sum","13","1"]),
          (["Main.hs"],["main1", "11","1"]),
          (["ConflictExport.hs","D6.hs"],["fringe","7","1"])]
}
-}

    -- ---------------------------------

    it "rename preserving layout Utils.hs" $ do
     -- ct $ rename logTestSettings testOptions "./Renaming/Utils.hs" "parsed1" (5,11)
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/Utils.hs" "parsed1" (5,11)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     r' `shouldBe` [ "Renaming/Utils.hs"
                  ]
     diff <- ct $ compareFiles "./Renaming/Utils.expected.hs"
                               "./Renaming/Utils.refactored.hs"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

    it "passes RenameInExportedType.hs 1" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/RenameInExportedType.hs" "NewType" (6,6)
     -- ct $ rename logTestSettings testOptions "./Renaming/RenameInExportedType.hs" "NewType" (6,6)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     (show r') `shouldBe` "[\"Renaming/RenameInExportedType.hs\"]"
     diff <- ct $ compareFiles "./Renaming/RenameInExportedType.refactored.hs"
                               "./Renaming/RenameInExportedType.expected.hs"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

    it "passes RenameInExportedType2.hs" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/RenameInExportedType2.hs" "NewType" (6,24)
     -- ct $ rename logTestSettings testOptions "./Renaming/RenameInExportedType2.hs" "NewType" (6,24)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     (show r') `shouldBe` "[\"Renaming/RenameInExportedType2.hs\"]"
     diff <- ct $ compareFiles "./Renaming/RenameInExportedType2.refactored.hs"
                               "./Renaming/RenameInExportedType2.expected.hs"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

    it "passes WildCard.hs" $ do
     r <- ct $ rename defaultTestSettings testOptions "./Renaming/WildCard.hs" "taggedPlugins2" (7,1)
     -- r <- ct $ rename logTestSettings testOptions "./Renaming/WildCard.hs" "taggedPlugins2" (7,1)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     (show r') `shouldBe` "[\"Renaming/WildCard.hs\"]"
     diff <- ct $ compareFiles "./Renaming/WildCard.refactored.hs"
                               "./Renaming/WildCard.expected.hs"
     diff `shouldBe` []

    -- -----------------------------------------------------------------

{-
    it "renames in slack-api" $ do
     let cts = cdAndDo "/home/alanz/tmp/hackage/slack-api-0.6"
     r <- cts $ rename defaultTestSettings testOptions "./src/Web/Slack/Utils.hs" "anyName" (14,1)
     -- cdAndDo "/home/alanz/tmp/hackage/slack-api-0.6" $ rename logTestSettings testOptions "./src/Web/Slack/Utils.hs" "anyName" (14,1)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     (show r') `shouldBe` "[\"Renaming/RenameInExportedType2.hs\"]"
-}

    -- -----------------------------------------------------------------

    it "renames in ghc-mod with CPP" $ do
     pendingWith "get to the bottom of this"
     {-
     let cts = cdAndDo "/home/alanz/tmp/hackage/ghc-mod-5.4.0.0"
     r <- cts $ rename defaultTestSettings testOptions "Language/Haskell/GhcMod/Target.hs" "putNewSession2" (81,6)
     -- cdAndDo "/home/alanz/tmp/hackage/ghc-mod-5.4.0.0" $ rename logTestSettings testOptions  "Language/Haskell/GhcMod/Target.hs" "putNewSession2" (81,6)

     r' <- ct $ mapM makeRelativeToCurrentDirectory r
     (show r') `shouldBe` "[\"Renaming/RenameInExportedType2.hs\"]"
     -}

-- ---------------------------------------------------------------------
-- Helper functions
