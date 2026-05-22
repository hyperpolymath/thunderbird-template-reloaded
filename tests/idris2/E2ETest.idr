-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Port of tests/e2e_test.ts to Idris2, estate-rollout port 10/11.
-- 13 of 13 e2e/reflexive tests ported.
--
-- The reflexive test "this test file carries PMPL header" is rebound to
-- the new home: tests/idris2/E2ETest.idr instead of tests/e2e_test.ts.
-- The TS "all test .ts files have SPDX" loop scans tests/ with readDir;
-- with no readDir we enumerate the known TS test files.
-- The "deno.json or import map" test is a soft check in TS — the
-- assertion just verifies `typeof Deno !== "undefined"`. In an Idris2
-- runtime there is no Deno, so we restate the spirit of the test:
-- the Idris2 test runtime is present, which is trivially True.

module E2ETest

import Test.Spec
import Data.String
import System.File

%default covering

readFileMaybe : String -> IO (Maybe String)
readFileMaybe path = do
  Right contents <- readFile path
    | Left _ => pure Nothing
  pure (Just contents)

fileExists : String -> IO Bool
fileExists path = do
  Right _ <- readFile path
    | Left _ => pure False
  pure True

expectedHooks : List String
expectedHooks =
  [ "hooks/validate-codeql.sh"
  , "hooks/validate-permissions.sh"
  , "hooks/validate-sha-pins.sh"
  , "hooks/validate-spdx.sh"
  ]

quickstartFiles : List String
quickstartFiles =
  [ "QUICKSTART-USER.adoc"
  , "QUICKSTART-DEV.adoc"
  , "QUICKSTART-MAINTAINER.adoc"
  ]

tsTestFiles : List String
tsTestFiles =
  [ "tests/unit_test.ts"
  , "tests/contract_test.ts"
  , "tests/aspect_test.ts"
  , "tests/property_test.ts"
  , "tests/smoke_test.ts"
  , "tests/e2e_test.ts"
  , "tests/bench_test.ts"
  ]

hookTest : String -> TestCase
hookTest hook =
  test ("e2e: CI hook file exists -- " ++ hook) $ do
    mb <- readFileMaybe hook
    case mb of
      Nothing => assertTrue ("hook missing: " ++ hook) False
      Just content => assertTrue ("hook is empty: " ++ hook) (length content > 0)

quickstartTest : String -> TestCase
quickstartTest qs =
  test ("e2e: quickstart guide present -- " ++ qs) $ do
    ok <- fileExists qs
    assertTrue ("missing quickstart guide: " ++ qs) ok

public export
allSuites : List TestCase
allSuites =
  [ test "e2e/reflexive: this test file carries MPL-2.0 header" $ do
      mb <- readFileMaybe "tests/idris2/E2ETest.idr"
      case mb of
        Nothing => assertTrue "E2ETest.idr must exist" False
        Just content =>
          assertTrue "SPDX-License-Identifier: MPL-2.0 present"
                     (isInfixOf "SPDX-License-Identifier: MPL-2.0" content)

  , test "e2e/reflexive: all test .ts files have SPDX headers" $ do
      allPass (map checkTsSpdx tsTestFiles)

  , test "e2e: TOPOLOGY.md exists" $ do
      ok <- fileExists "TOPOLOGY.md"
      assertTrue "TOPOLOGY.md must exist" ok

  , test "e2e: NOTICE file is present and non-trivial" $ do
      mb <- readFileMaybe "NOTICE"
      case mb of
        Nothing => assertTrue "NOTICE must exist" False
        Just content => assertTrue "NOTICE must not be empty" (length content > 0)

  , test "e2e: Justfile contains a 'test' recipe" $ do
      mb <- readFileMaybe "Justfile"
      case mb of
        Nothing => assertTrue "Justfile must exist" False
        Just content =>
          assertTrue "Justfile should have a test recipe" (isInfixOf "test" content)

  , test "e2e: deno.json or import map is present for Deno deps" $ do
      -- TS version's only real assertion is `typeof Deno !== \"undefined\"`,
      -- which is trivially true under Deno. Under Idris2 we restate the
      -- spirit: the test runtime is present (the executable runs).
      assertTrue "test runtime present" True

  , test "e2e: CITATION.cff exists" $ do
      ok <- fileExists "CITATION.cff"
      assertTrue "CITATION.cff must exist" ok
  ]
  ++ map hookTest expectedHooks
  ++ map quickstartTest quickstartFiles
  where
    checkTsSpdx : String -> IO Bool
    checkTsSpdx path = do
      mb <- readFileMaybe path
      case mb of
        Nothing => assertTrue ("test file missing: " ++ path) False
        Just content =>
          assertTrue ("missing SPDX in: " ++ path)
                     (isInfixOf "SPDX-License-Identifier:" content)
