-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Port of tests/unit_test.ts to Idris2, estate-rollout port 10/11.
-- 13 of 13 tests ported. Hybrid pure-logic (SPDX parse, placeholder detect)
-- + content-validation (a2ml/LICENSE/manifest reads) shape.

module UnitTest

import Test.Spec
import Data.String
import Data.List
import System.File

%default covering

-- ---------------------------------------------------------------------------
-- Helpers (content-validation)
-- ---------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------
-- Pure logic: SPDX header extraction
-- ---------------------------------------------------------------------------

-- Drop the SPDX label prefix and any leading whitespace, returning the
-- bare identifier up to the next whitespace character.
-- Mirrors the TS /SPDX-License-Identifier:\s*(\S+)/ regex behaviour.
takeNonWS : List Char -> List Char
takeNonWS [] = []
takeNonWS (c :: cs) =
  if c == ' ' || c == '\t' || c == '\n' || c == '\r'
    then []
    else c :: takeNonWS cs

dropWS : List Char -> List Char
dropWS [] = []
dropWS (c :: cs) =
  if c == ' ' || c == '\t'
    then dropWS cs
    else c :: cs

||| Extract the SPDX identifier from file content. Returns "" if not found.
||| Pure-logic port of the TS regex /SPDX-License-Identifier:\s*(\S+)/ .
export
extractSpdxId : String -> String
extractSpdxId content =
  let needle = "SPDX-License-Identifier:"
      cs = unpack content
      ns = unpack needle in
  case findRest ns cs of
    Nothing => ""
    Just rest =>
      let trimmed = dropWS rest
          token = takeNonWS trimmed in
      pack token
  where
    -- Find needle in haystack and return everything after the needle.
    isPrefix : List Char -> List Char -> Bool
    isPrefix [] _ = True
    isPrefix (_ :: _) [] = False
    isPrefix (n :: ns) (h :: hs) =
      if n == h then isPrefix ns hs else False

    findRest : List Char -> List Char -> Maybe (List Char)
    findRest needle [] = if isPrefix needle [] then Just [] else Nothing
    findRest needle haystack@(_ :: hs) =
      if isPrefix needle haystack
        then Just (drop (length needle) haystack)
        else findRest needle hs

-- ---------------------------------------------------------------------------
-- Pure logic: unresolved Mustache-style placeholder detection
-- ---------------------------------------------------------------------------

-- True if c is an uppercase ASCII letter or underscore.
isUpperOrUnder : Char -> Bool
isUpperOrUnder c =
  (c >= 'A' && c <= 'Z') || c == '_'

-- Returns True if content contains a {{NAME}} where NAME is one or more
-- uppercase letters / underscores. Pure-logic port of /\{\{[A-Z_]+\}\}/.
export
containsUnresolvedPlaceholder : String -> Bool
containsUnresolvedPlaceholder content = scan (unpack content)
  where
    -- After consuming "{{", consume one-or-more [A-Z_] then expect "}}".
    closesPlaceholder : List Char -> Bool
    closesPlaceholder ('}' :: '}' :: _) = True
    closesPlaceholder _ = False

    matchAfterBraces : Nat -> List Char -> Bool
    matchAfterBraces n [] = False
    matchAfterBraces n cs@(c :: rest) =
      if isUpperOrUnder c
        then matchAfterBraces (S n) rest
        else case n of
               Z => False
               _ => closesPlaceholder cs

    scan : List Char -> Bool
    scan [] = False
    scan ('{' :: '{' :: rest) =
      if matchAfterBraces 0 rest then True else scan rest
    scan (_ :: rest) = scan rest

-- ---------------------------------------------------------------------------
-- Test cases
-- ---------------------------------------------------------------------------

public export
allSuites : List TestCase
allSuites =
  -- SPDX header parsing (pure-logic)
  [ test "unit: extractSpdxId parses valid SPDX line" $ do
      assertEq (extractSpdxId "// SPDX-License-Identifier: MPL-2.0\ncode")
               "MPL-2.0"

  , test "unit: extractSpdxId handles TOML-style comment" $ do
      assertEq (extractSpdxId "# SPDX-License-Identifier: MPL-2.0\n[section]")
               "MPL-2.0"

  , test "unit: extractSpdxId returns empty when header absent" $ do
      assertEq (extractSpdxId "no license here") ""

  , test "unit: extractSpdxId handles leading whitespace" $ do
      assertEq (extractSpdxId "   // SPDX-License-Identifier: MIT\n") "MIT"

  -- Placeholder detection (pure-logic)
  , test "unit: containsUnresolvedPlaceholder detects {{PROJECT}}" $ do
      assertEq (containsUnresolvedPlaceholder "name: {{PROJECT}}") True

  , test "unit: containsUnresolvedPlaceholder ignores lowercase placeholders" $ do
      assertEq (containsUnresolvedPlaceholder "fn {{project}}_init()") False

  , test "unit: containsUnresolvedPlaceholder allows clean content" $ do
      assertEq (containsUnresolvedPlaceholder "thunderbird-template-reloaded") False

  -- STATE.a2ml metadata parsing
  , test "unit: STATE.a2ml exists and has valid project name" $ do
      mb <- readFileMaybe ".machine_readable/6a2/STATE.a2ml"
      case mb of
        Nothing => assertTrue "STATE.a2ml must exist" False
        Just content =>
          assertTrue "project = \"thunderbird-template-reloaded\""
                     (isInfixOf "project = \"thunderbird-template-reloaded\"" content)

  , test "unit: STATE.a2ml has SPDX header" $ do
      mb <- readFileMaybe ".machine_readable/6a2/STATE.a2ml"
      case mb of
        Nothing => assertTrue "STATE.a2ml must exist" False
        Just content => assertEq (extractSpdxId content) "MPL-2.0"

  , test "unit: STATE.a2ml has version field" $ do
      mb <- readFileMaybe ".machine_readable/6a2/STATE.a2ml"
      case mb of
        Nothing => assertTrue "STATE.a2ml must exist" False
        Just content => assertTrue "version = field" (isInfixOf "version =" content)

  -- LICENSE content
  , test "unit: LICENSE file exists and is non-empty" $ do
      mb <- readFileMaybe "LICENSE"
      case mb of
        Nothing => assertTrue "LICENSE must exist" False
        Just content => assertTrue "LICENSE must not be empty" (length content > 0)

  , test "unit: LICENSES directory contains PMPL text" $ do
      ok <- fileExists "LICENSES/MPL-2.0.txt"
      assertTrue "LICENSES/MPL-2.0.txt must exist" ok

  -- AI manifest
  , test "unit: 0-AI-MANIFEST.a2ml exists" $ do
      ok <- fileExists "0-AI-MANIFEST.a2ml"
      assertTrue "0-AI-MANIFEST.a2ml must exist" ok

  , test "unit: 0-AI-MANIFEST.a2ml is non-empty" $ do
      mb <- readFileMaybe "0-AI-MANIFEST.a2ml"
      case mb of
        Nothing => assertTrue "0-AI-MANIFEST.a2ml must exist" False
        Just content => assertTrue "non-empty" (length content > 0)
  ]
