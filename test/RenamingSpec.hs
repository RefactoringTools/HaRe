module RenamingSpec (main, spec) where

import           Test.Hspec

import Language.Haskell.Refact.Renaming

import TestUtils

-- ---------------------------------------------------------------------

main :: IO ()
main = do
  hspec spec

spec :: Spec
spec = do

  describe "Renaming" $ do
    it "Renames in D1 B1 C1 A1 6 6" $ do
     r <- rename (testSettingsMainfile "./test/testdata/Renaming/A1.hs") testCradle "./test/testdata/Renaming/D1.hs" "AnotherTree" (6,6)
     -- rename logTestSettings testCradle (Just "./test/testdata/Renaming/A1.hs") "./test/testdata/Renaming/D1.hs" "AnotherTree" (6,6)

     r `shouldBe` [ "./test/testdata/Renaming/D1.hs"
                  , "./test/testdata/Renaming/C1.hs"
                  , "./test/testdata/Renaming/A1.hs"
                  , "./test/testdata/Renaming/B1.hs"
                  ]

     diffD <- compareFiles "./test/testdata/Renaming/D1.hs.expected"
                           "./test/testdata/Renaming/D1.hs.refactored"
     diffD `shouldBe` []

     diffC <- compareFiles "./test/testdata/Renaming/C1.hs.expected"
                           "./test/testdata/Renaming/C1.hs.refactored"
     diffC `shouldBe` []

     diffB <- compareFiles "./test/testdata/Renaming/B1.hs.expected"
                           "./test/testdata/Renaming/B1.hs.refactored"
     diffB `shouldBe` []

     diffA <- compareFiles "./test/testdata/Renaming/A1.hs.expected"
                           "./test/testdata/Renaming/A1.hs.refactored"
     diffA `shouldBe` []

    -- ---------------------------------

    it "Renames in D2 B2 C2 A2 6 24" $ do
     r <- rename (testSettingsMainfile "./test/testdata/Renaming/A2.hs") testCradle "./test/testdata/Renaming/D2.hs" "SubTree" (6,24)
     -- rename logTestSettings testCradle (Just "./test/testdata/Renaming/A2.hs") "./test/testdata/Renaming/D2.hs" "SubTree" (6,24)

     r `shouldBe` [ "./test/testdata/Renaming/D2.hs"
                  , "./test/testdata/Renaming/C2.hs"
                  -- , "./test/testdata/Renaming/A2.hs"
                  , "./test/testdata/Renaming/B2.hs"
                  ]

     diffD <- compareFiles "./test/testdata/Renaming/D2.hs.expected"
                           "./test/testdata/Renaming/D2.hs.refactored"
     diffD `shouldBe` []

     diffC <- compareFiles "./test/testdata/Renaming/C2.hs.expected"
                           "./test/testdata/Renaming/C2.hs.refactored"
     diffC `shouldBe` []

     diffB <- compareFiles "./test/testdata/Renaming/B2.hs.expected"
                           "./test/testdata/Renaming/B2.hs.refactored"
     diffB `shouldBe` []

     -- diffA <- compareFiles "./test/testdata/Renaming/A2.hs.expected"
     --                       "./test/testdata/Renaming/A2.hs.refactored"
     -- diffA `shouldBe` []

    -- ---------------------------------

    it "Renames in D3 B3 C3 A3 12 7" $ do
     --     (["D3.hs","B3.hs","C3.hs","A3.hs"],["Same","12","7"]),
     r <- rename (testSettingsMainfile "./test/testdata/Renaming/A3.hs") testCradle "./test/testdata/Renaming/D3.hs" "Same" (12,7)
     -- rename logTestSettings testCradle (Just "./test/testdata/Renaming/A3.hs") "./test/testdata/Renaming/D3.hs" "Same" (12,7)

     r `shouldBe` [ "./test/testdata/Renaming/D3.hs"
                  , "./test/testdata/Renaming/C3.hs"
                  -- , "./test/testdata/Renaming/A3.hs"
                  , "./test/testdata/Renaming/B3.hs"
                  ]

     diffD <- compareFiles "./test/testdata/Renaming/D3.hs.expected"
                           "./test/testdata/Renaming/D3.hs.refactored"
     diffD `shouldBe` []

     diffC <- compareFiles "./test/testdata/Renaming/C3.hs.expected"
                           "./test/testdata/Renaming/C3.hs.refactored"
     diffC `shouldBe` []

     diffB <- compareFiles "./test/testdata/Renaming/B3.hs.expected"
                           "./test/testdata/Renaming/B3.hs.refactored"
     diffB `shouldBe` []

     -- diffA <- compareFiles "./test/testdata/Renaming/A3.hs.expected"
     --                       "./test/testdata/Renaming/A3.hs.refactored"
     -- diffA `shouldBe` []

    -- ---------------------------------

    it "Renames in D4 B4 C4 A4 13 4" $ do
     --     (["D4.hs","B4.hs","C4.hs","A4.hs"],["isSameOrNot","13","4"]),
     r <- rename (testSettingsMainfile "./test/testdata/Renaming/A4.hs") testCradle "./test/testdata/Renaming/D4.hs" "isSameOrNot" (13,4)
     -- rename logTestSettings testCradle (Just "./test/testdata/Renaming/A4.hs") "./test/testdata/Renaming/D4.hs" "isSameOrNot" (13,4)

     r `shouldBe` [ "./test/testdata/Renaming/D4.hs"
                  , "./test/testdata/Renaming/C4.hs"
                  , "./test/testdata/Renaming/A4.hs"
                  , "./test/testdata/Renaming/B4.hs"
                  ]

     diffD <- compareFiles "./test/testdata/Renaming/D4.hs.expected"
                           "./test/testdata/Renaming/D4.hs.refactored"
     diffD `shouldBe` []

     diffC <- compareFiles "./test/testdata/Renaming/C4.hs.expected"
                           "./test/testdata/Renaming/C4.hs.refactored"
     diffC `shouldBe` []

     diffB <- compareFiles "./test/testdata/Renaming/B4.hs.expected"
                           "./test/testdata/Renaming/B4.hs.refactored"
     diffB `shouldBe` []

     diffA <- compareFiles "./test/testdata/Renaming/A4.hs.expected"
                           "./test/testdata/Renaming/A4.hs.refactored"
     diffA `shouldBe` []

    -- ---------------------------------

    it "Renames in D5 B5 C5 A5 24 1" $ do
     --     (["D5.hs","B5.hs","C5.hs","A5.hs"],["sum","24","1"]),
     r <- rename (testSettingsMainfile "./test/testdata/Renaming/A5.hs") testCradle "./test/testdata/Renaming/D5.hs" "sum" (24,1)
     -- rename logTestSettings testCradle (Just "./test/testdata/Renaming/A5.hs") "./test/testdata/Renaming/D5.hs" "sum" (24,1)

     r `shouldBe` [ "./test/testdata/Renaming/D5.hs"
                  , "./test/testdata/Renaming/C5.hs"
                  , "./test/testdata/Renaming/A5.hs"
                  , "./test/testdata/Renaming/B5.hs"
                  ]

     diffD <- compareFiles "./test/testdata/Renaming/D5.hs.expected"
                           "./test/testdata/Renaming/D5.hs.refactored"
     diffD `shouldBe` []

     diffC <- compareFiles "./test/testdata/Renaming/C5.hs.expected"
                           "./test/testdata/Renaming/C5.hs.refactored"
     diffC `shouldBe` []

     diffB <- compareFiles "./test/testdata/Renaming/B5.hs.expected"
                           "./test/testdata/Renaming/B5.hs.refactored"
     diffB `shouldBe` []

     diffA <- compareFiles "./test/testdata/Renaming/A5.hs.expected"
                           "./test/testdata/Renaming/A5.hs.refactored"
     diffA `shouldBe` []

    -- ---------------------------------

    it "Renames in D7 C7  10 1" $ do
     --     (["D7.hs","C7.hs"],["myFringe","10","1"]),
     r <- rename (testSettingsMainfile "./test/testdata/Renaming/C7.hs") testCradle "./test/testdata/Renaming/D7.hs" "myFringe" (10,1)
     -- rename logTestSettings testCradle (Just "./test/testdata/Renaming/C7.hs") "./test/testdata/Renaming/D7.hs" "myFringe" (10,1)

     r `shouldBe` [ "./test/testdata/Renaming/D7.hs"
                  , "./test/testdata/Renaming/C7.hs"
                  ]

     diffD <- compareFiles "./test/testdata/Renaming/D7.hs.expected"
                           "./test/testdata/Renaming/D7.hs.refactored"
     diffD `shouldBe` []

     diffC <- compareFiles "./test/testdata/Renaming/C7.hs.expected"
                           "./test/testdata/Renaming/C7.hs.refactored"
     diffC `shouldBe` []


    -- ---------------------------------

    it "Renames in Field1 5 18" $ do
     r <- rename defaultTestSettings testCradle "./test/testdata/Renaming/Field1.hs" "pointx1" (5,18)
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/Field1.hs" "pointx1" (5,18)
     r `shouldBe` [ "./test/testdata/Renaming/Field1.hs"
                  ]
     diff <- compareFiles "./test/testdata/Renaming/Field1.hs.expected"
                          "./test/testdata/Renaming/Field1.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "Renames in Field3 9 1" $ do
     r <- rename defaultTestSettings testCradle "./test/testdata/Renaming/Field3.hs" "abs" (9,1)
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/Field3.hs" "abs" (9,1)
     r `shouldBe` [ "./test/testdata/Renaming/Field3.hs"
                  ]
     diff <- compareFiles "./test/testdata/Renaming/Field3.hs.expected"
                          "./test/testdata/Renaming/Field3.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "Renames in Field4 5 23" $ do
     --     (["Field4.hs"],["value2","5","23"]),
     r <- rename defaultTestSettings testCradle "./test/testdata/Renaming/Field4.hs" "value2" (5,23)
     -- rename logTestSettings Nothing "./test/testdata/Renaming/Field4.hs" "value2" (5,23)
     r `shouldBe` [ "./test/testdata/Renaming/Field4.hs"
                  ]
     diff <- compareFiles "./test/testdata/Renaming/Field4.hs.expected"
                          "./test/testdata/Renaming/Field4.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "Renames in IdIn1 11 1" $ do
     --     (["IdIn1.hs"],["x1","11","1"]),
     r <- rename defaultTestSettings testCradle "./test/testdata/Renaming/IdIn1.hs" "x1" (11,1)
     -- rename logTestSettings Nothing "./test/testdata/Renaming/IdIn1.hs" "x1" (11,1)
     r `shouldBe` [ "./test/testdata/Renaming/IdIn1.hs"
                  ]
     diff <- compareFiles "./test/testdata/Renaming/IdIn1.hs.expected"
                          "./test/testdata/Renaming/IdIn1.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "Renames in IdIn2 15 7" $ do
     --     (["IdIn2.hs"],["x1","15","7"]),
     r <- rename defaultTestSettings testCradle "./test/testdata/Renaming/IdIn2.hs" "x1" (15,7)
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/IdIn2.hs" "x1" (15,7)
     r `shouldBe` [ "./test/testdata/Renaming/IdIn2.hs"
                  ]
     diff <- compareFiles "./test/testdata/Renaming/IdIn2.hs.expected"
                          "./test/testdata/Renaming/IdIn2.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "Renames in ClassIn1 7 7" $ do
     --     (["ClassIn1.hs"],["MyReversable","7","7"]),
     r <- rename defaultTestSettings testCradle "./test/testdata/Renaming/ClassIn1.hs" "MyReversable" (7,7)
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/ClassIn1.hs" "MyReversable" (7,7)
     r `shouldBe` [ "./test/testdata/Renaming/ClassIn1.hs"
                  ]
     diff <- compareFiles "./test/testdata/Renaming/ClassIn1.hs.expected"
                          "./test/testdata/Renaming/ClassIn1.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "Renames in ClassIn2 8 3" $ do
     --     (["ClassIn2.hs"],["reversable","8","3"]),
     r <- rename defaultTestSettings testCradle "./test/testdata/Renaming/ClassIn2.hs" "reversable" (8,3)
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/ClassIn2.hs" "reversable" (8,3)
     r `shouldBe` [ "./test/testdata/Renaming/ClassIn2.hs"
                  ]
     diff <- compareFiles "./test/testdata/Renaming/ClassIn2.hs.expected"
                          "./test/testdata/Renaming/ClassIn2.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "Renames in ConstructorIn1 8 6" $ do
     --     (["ConstructorIn1.hs"],["MyBTree","8","6"]),
     r <- rename defaultTestSettings testCradle "./test/testdata/Renaming/ConstructorIn1.hs" "MyBTree" (8,6)
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/ConstructorIn1.hs" "MyBTree" (8,6)
     r `shouldBe` [ "./test/testdata/Renaming/ConstructorIn1.hs"
                  ]
     diff <- compareFiles "./test/testdata/Renaming/ConstructorIn1.hs.expected"
                          "./test/testdata/Renaming/ConstructorIn1.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "Renames in ConstructorIn2 8 6" $ do
     --     (["ConstructorIn2.hs"],["Tree","8","24"]),
     r <- rename defaultTestSettings testCradle "./test/testdata/Renaming/ConstructorIn2.hs" "Tree" (8,24)
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/ConstructorIn2.hs" "Tree" (8,24)
     r `shouldBe` [ "./test/testdata/Renaming/ConstructorIn2.hs"
                  ]
     diff <- compareFiles "./test/testdata/Renaming/ConstructorIn2.hs.expected"
                          "./test/testdata/Renaming/ConstructorIn2.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "Renames in ConstructorIn3 9 12" $ do
     --     (["ConstructorIn3.hs"],["b","9","12"]),
     r <- rename defaultTestSettings testCradle "./test/testdata/Renaming/ConstructorIn3.hs" "b" (9,13)
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/ConstructorIn3.hs" "b" (9,13)
     r `shouldBe` [ "./test/testdata/Renaming/ConstructorIn3.hs"
                  ]
     diff <- compareFiles "./test/testdata/Renaming/ConstructorIn3.hs.expected"
                          "./test/testdata/Renaming/ConstructorIn3.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "Renames in LayoutIn1 7 17" $ do
     --     (["LayoutIn1.hs"],["square","7","17"]),
     r <- rename defaultTestSettings testCradle "./test/testdata/Renaming/LayoutIn1.hs" "square" (7,17)
     -- rename logTestSettings testCradle "./test/testdata/Renaming/LayoutIn1.hs" "square" (7,17)
     r `shouldBe` [ "./test/testdata/Renaming/LayoutIn1.hs"
                  ]
     diff <- compareFiles "./test/testdata/Renaming/LayoutIn1.hs.expected"
                          "./test/testdata/Renaming/LayoutIn1.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "Renames in LayoutIn2 8 7" $ do
     --     (["LayoutIn2.hs"],["ls","8","7"]),
     r <- rename defaultTestSettings testCradle "./test/testdata/Renaming/LayoutIn2.hs" "ls" (8,7)
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/LayoutIn2.hs" "ls" (8,7)
     r `shouldBe` [ "./test/testdata/Renaming/LayoutIn2.hs"
                  ]
     diff <- compareFiles "./test/testdata/Renaming/LayoutIn2.hs.expected"
                          "./test/testdata/Renaming/LayoutIn2.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "Renames in LayoutIn3 7 13" $ do
     --     (["LayoutIn3.hs"],["anotherX","7","13"]),
     r <- rename defaultTestSettings testCradle "./test/testdata/Renaming/LayoutIn3.hs" "anotherX" (7,13)
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/LayoutIn3.hs" "anotherX" (7,13)
     r `shouldBe` [ "./test/testdata/Renaming/LayoutIn3.hs"
                  ]
     diff <- compareFiles "./test/testdata/Renaming/LayoutIn3.hs.expected"
                          "./test/testdata/Renaming/LayoutIn3.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "Renames in LayoutIn4 7 8" $ do
     --     (["LayoutIn4.hs"],["io","7","8"])],
     r <- rename defaultTestSettings testCradle "./test/testdata/Renaming/LayoutIn4.hs" "io" (7,8)
     -- rename logTestSettings testCradle "./test/testdata/Renaming/LayoutIn4.hs" "io" (7,8)
     r `shouldBe` [ "./test/testdata/Renaming/LayoutIn4.hs"
                  ]
     diff <- compareFiles "./test/testdata/Renaming/LayoutIn4.hs.expected"
                          "./test/testdata/Renaming/LayoutIn4.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------
    -- Negative tests
    -- ---------------------------------

    it "naming clash at top level IdIn3" $ do
     -- (["IdIn3.hs"],["foo","10","1"]),
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/IdIn3.hs" "foo" (10,1)
     res <- catchException (rename defaultTestSettings testCradle "./test/testdata/Renaming/IdIn3.hs" "foo" (10,1))
     (show res) `shouldBe` "Just \"Name 'foo'  already existed\\n\""

    -- ---------------------------------

    it "upper case name for fn fails IdIn4" $ do
     --     (["IdIn4.hs"],["Foo","12","1"]),
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/IdIn4.hs" "Foo" (12,1)
     res <- catchException (rename defaultTestSettings testCradle "./test/testdata/Renaming/IdIn4.hs" "Foo" (12,1))
     (show res) `shouldBe` "Just \"The new name should be an identifier!\""

    -- ---------------------------------

    it "naming clash IdIn5" $ do
     --     (["IdIn5.hs"],["y","10","1"]),
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/IdIn5.hs" "y" (10,1)
     res <- catchException (rename defaultTestSettings testCradle "./test/testdata/Renaming/IdIn5.hs" "y" (10,1))
     (show res) `shouldBe` "Just \"Name 'y'  already existed, or rename 'IdIn5.x' to 'y' will change the program's semantics!\\n\""

    -- ---------------------------------

    it "must rename in home module ClassIn3" $ do
     --     (["ClassIn3.hs"],["Eq1","16","10"]),
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/ClassIn3.hs" "Eq1" (16,10)
     res <- catchException (rename defaultTestSettings testCradle "./test/testdata/Renaming/ClassIn3.hs" "Eq1" (16,10))
     (show res) `shouldBe` "Just \"This identifier is defined in module GHC.Classes, please do renaming in that module!\""

    -- ---------------------------------

    it "will not rename existing name Field2" $ do
     --     (["Field2.hs"], ["absPoint", "5", "18"]),
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/Field2.hs" "absPoint" (5,18)
     res <- catchException (rename defaultTestSettings testCradle "./test/testdata/Renaming/Field2.hs" "absPoint" (5,18))
     (show res) `shouldBe` "Just \"Name 'absPoint'  already existed\\n\""

    -- ---------------------------------

    it "must qualify clashes Qualifier" $ do
     --     (["Qualifier.hs"],["sum","13","1"]),
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/Qualifier.hs" "sum" (13,1)
     res <- catchException (rename defaultTestSettings testCradle "./test/testdata/Renaming/Qualifier.hs" "sum" (13,1))
     (show res) `shouldBe` "Just \"The new name will cause ambiguous occurrence problem, please select another new name or qualify the use of ' sum' before renaming!\\n\""

    -- ---------------------------------

    it "cannot rename main Main" $ do
     --     (["Main.hs"],["main1", "11","1"]),
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/Main.hs" "main1" (11,1)
     res <- catchException (rename defaultTestSettings testCradle "./test/testdata/Renaming/Main.hs" "main1" (11,1))
     (show res) `shouldBe` "Just \"The 'main' function defined in a 'Main' module should not be renamed!\""

    -- ---------------------------------

    it "cannot rename main Main2" $ do
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/Main2.hs" "main1" (4,1)
     res <- catchException (rename defaultTestSettings testCradle "./test/testdata/Renaming/Main2.hs" "main1" (4,1))
     (show res) `shouldBe` "Just \"The 'main' function defined in a 'Main' module should not be renamed!\""

    -- ---------------------------------

    it "rename with default main Main2" $ do
     -- rename logTestSettings testCradle Nothing "./test/testdata/Renaming/Main2.hs" "baz" (6,1)
     r <- rename defaultTestSettings testCradle "./test/testdata/Renaming/Main2.hs" "baz" (6,1)

     r `shouldBe` [ "./test/testdata/Renaming/Main2.hs"
                  ]
     diff <- compareFiles "./test/testdata/Renaming/Main2.hs.expected"
                          "./test/testdata/Renaming/Main2.hs.refactored"
     diff `shouldBe` []

    -- ---------------------------------

    it "ConflictExports" $ do
     --     (["ConflictExport.hs","D6.hs"],["fringe","7","1"])]
     -- rename (logTestSettingsMainfile "./test/testdata/Renaming/ConflictExport.hs") testCradle "./test/testdata/Renaming/ConflictExport.hs" "fringe" (7,1)
     res <- catchException (rename (testSettingsMainfile "./test/testdata/Renaming/ConflictExport.hs") testCradle "./test/testdata/Renaming/ConflictExport.hs" "fringe" (7,1))
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

-- ---------------------------------------------------------------------
-- Helper functions

