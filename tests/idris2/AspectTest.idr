-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Port of tests/aspect_test.ts to Idris2, estate-rollout port 10/11.
-- 17 of 17 aspect tests ported.
--
-- The TS secret-leak regex /(?:api_key|password|secret|token)\s*=/i is
-- approximated with case-insensitive substring checks against the four
-- lower-cased needles followed by "=" or " =". Same intent (catch obvious
-- hardcoded secrets in README.adoc), tighter syntax surface.
--
-- The TS "all non-bench .ts files in tests/ use Deno.test" test scans
-- the live tests directory. Idris2 base stdlib has no directory listing
-- API, so we enumerate the known TS test files as a fixed list and check
-- each for the Deno.test( literal. Adding a new TS test means the list
-- must be updated, which is in keeping with the bimodal estate rollout.

module AspectTest

import Test.Spec
import Data.String
import Data.List
import System.File

%default covering

readFileToString : String -> IO String
readFileToString path = do
  Right contents <- readFile path
    | Left _ => pure ""
  pure contents

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

toLowerAscii : String -> String
toLowerAscii s = pack (map toLowerChar (unpack s))
  where
    toLowerChar : Char -> Char
    toLowerChar c =
      if c >= 'A' && c <= 'Z'
        then chr (ord c + 32)
        else c

-- Banned-files list mirrored verbatim from aspect_test.ts.
bannedFiles : List String
bannedFiles =
  [ "package.json"
  , "package-lock.json"
  , "yarn.lock"
  , "bun.lockb"
  , "node_modules"
  , ".npmrc"
  , "Dockerfile"
  ]

-- Documentation files that must be present + non-empty.
docFiles : List String
docFiles =
  [ "README.adoc"
  , "EXPLAINME.adoc"
  , "CONTRIBUTING.md"
  , "ROADMAP.adoc"
  ]

-- TS test files (still present alongside the new Idris2 port).
tsTestFiles : List String
tsTestFiles =
  [ "unit_test.ts"
  , "contract_test.ts"
  , "aspect_test.ts"
  , "property_test.ts"
  , "smoke_test.ts"
  , "e2e_test.ts"
  ]

-- Generate a banned-file existence test (mirrors TS for-loop test generator).
bannedFileTest : String -> TestCase
bannedFileTest f =
  test ("aspect/policy: banned file must not exist -- " ++ f) $ do
    ok <- fileExists f
    assertTrue ("banned file/directory present: " ++ f) (not ok)

-- Generate a doc-non-empty test.
docTest : String -> TestCase
docTest d =
  test ("aspect/docs: documentation file is non-empty -- " ++ d) $ do
    mb <- readFileMaybe d
    case mb of
      Nothing => assertTrue ("doc missing: " ++ d) False
      Just content => assertTrue ("doc too short: " ++ d) (length content > 50)

public export
allSuites : List TestCase
allSuites =
  -- Security
  [ test "aspect/security: SECURITY.md exists" $ do
      ok <- fileExists "SECURITY.md"
      assertEq ok True

  , test "aspect/security: SECURITY.md mentions vulnerability disclosure" $ do
      mb <- readFileMaybe "SECURITY.md"
      case mb of
        Nothing => assertTrue "SECURITY.md must exist" False
        Just content =>
          let lc = toLowerAscii content in
          assertTrue "SECURITY.md should mention security reporting"
                     (isInfixOf "vulnerabilit" lc
                      || isInfixOf "disclosure" lc
                      || isInfixOf "report" lc
                      || isInfixOf "security" lc)

  , test "aspect/security: .well-known/security.txt exists" $ do
      ok <- fileExists ".well-known/security.txt"
      assertEq ok True

  , test "aspect/security: no .env files in repo" $ do
      ok <- fileExists ".env"
      assertTrue ".env file must not be committed" (not ok)

  , test "aspect/security: no plaintext secrets patterns in README" $ do
      mb <- readFileMaybe "README.adoc"
      case mb of
        Nothing => assertTrue "README.adoc must exist" False
        Just content =>
          let lc = toLowerAscii content
              -- approximate /(?:api_key|password|secret|token)\s*=/i
              leak = isInfixOf "api_key=" lc
                  || isInfixOf "api_key =" lc
                  || isInfixOf "password=" lc
                  || isInfixOf "password =" lc
                  || isInfixOf "secret=" lc
                  || isInfixOf "secret =" lc
                  || isInfixOf "token=" lc
                  || isInfixOf "token =" lc in
          assertTrue "README.adoc must not contain hardcoded secrets" (not leak)

  -- Community
  , test "aspect/community: CODE_OF_CONDUCT.md exists" $ do
      ok <- fileExists "CODE_OF_CONDUCT.md"
      assertEq ok True

  , test "aspect/community: CODE_OF_CONDUCT.md is non-trivial" $ do
      mb <- readFileMaybe "CODE_OF_CONDUCT.md"
      case mb of
        Nothing => assertTrue "CODE_OF_CONDUCT.md must exist" False
        Just content => assertTrue "should have meaningful content" (length content > 100)

  -- EditorConfig
  , test "aspect/formatting: .editorconfig exists" $ do
      ok <- fileExists ".editorconfig"
      assertEq ok True

  , test "aspect/formatting: .editorconfig has root = true" $ do
      mb <- readFileMaybe ".editorconfig"
      case mb of
        Nothing => assertTrue ".editorconfig must exist" False
        Just content =>
          let lc = toLowerAscii content in
          assertTrue "root = true present"
                     (isInfixOf "root = true" lc || isInfixOf "root=true" lc)

  , test "aspect/formatting: .editorconfig defines indent_style" $ do
      mb <- readFileMaybe ".editorconfig"
      case mb of
        Nothing => assertTrue ".editorconfig must exist" False
        Just content => assertTrue "indent_style present" (isInfixOf "indent_style" content)

  -- Language / TS bans (tsconfig)
  , test "aspect/language: no tsconfig.json (TS only via Deno, not tsc)" $ do
      ok <- fileExists "tsconfig.json"
      assertTrue "no tsconfig.json" (not ok)

  -- TS test files have Deno.test (legacy check; alongside this Idris2 port)
  , test "aspect/tests: all non-bench .ts files in tests/ use Deno.test" $ do
      allPass (map checkOne tsTestFiles)
  ]
  ++ map bannedFileTest bannedFiles
  ++ map docTest docFiles
  where
    checkOne : String -> IO Bool
    checkOne name = do
      mb <- readFileMaybe ("tests/" ++ name)
      case mb of
        Nothing => assertTrue ("test file missing: " ++ name) False
        Just content =>
          assertTrue (name ++ " must contain Deno.test(") (isInfixOf "Deno.test(" content)
