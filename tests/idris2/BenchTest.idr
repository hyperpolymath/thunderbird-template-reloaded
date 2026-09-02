-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Port of tests/bench_test.ts to Idris2, estate-rollout port 10/11.
-- 8 of 8 benchmark assertions ported (assertions only, no timing).
--
-- The TS benches use Deno.bench{ fn() { ... } } to measure throughput.
-- Per the port spec we drop the timing layer and assert the functional
-- preconditions each bench depends on: the file is readable, the sample
-- content is well-formed, the regex-equivalent finds the expected token.

module BenchTest

import Test.Spec
import UnitTest -- reuse extractSpdxId, containsUnresolvedPlaceholder
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

-- Concatenate a list of strings (no Idris2 String.concat in base).
strConcat : List String -> String
strConcat [] = ""
strConcat (x :: xs) = x ++ strConcat xs

-- 20-fold repetition of a single TOML-ish chunk (mirrors TS .repeat(20))
chunk : String
chunk =
  "# SPDX-License-Identifier: MPL-2.0\n" ++
  "# Copyright (c) 2026 Jonathan D.A. Jewell\n\n" ++
  "[metadata]\n" ++
  "project = \"thunderbird-template-reloaded\"\n" ++
  "version = \"0.1.0\"\n"

sampleContent : String
sampleContent =
  strConcat (replicate 20 chunk)

-- Approximate JSON serialisation of the bench metadata object (size only).
jsonSample : String
jsonSample =
  "{\"project\":\"thunderbird-template-reloaded\",\"version\":\"0.1.0\","
  ++ "\"crg_grade\":\"C\",\"files\":["
  ++ strConcat (intersperse "," (map mkFile [0 .. 49]))
  ++ "]}"
  where
    intersperse : String -> List String -> List String
    intersperse _ [] = []
    intersperse _ [x] = [x]
    intersperse sep (x :: xs) = x :: sep :: intersperse sep xs

    mkFile : Nat -> String
    mkFile n = "\"file-" ++ show n ++ ".adoc\""

public export
allSuites : List TestCase
allSuites =
  -- File-IO precondition: each bench-read target is present and non-empty.
  [ test "bench-pre: LICENSE is readable" $ do
      mb <- readFileMaybe "LICENSE"
      case mb of
        Nothing => assertTrue "LICENSE readable" False
        Just content => assertTrue "non-empty" (length content > 0)

  , test "bench-pre: README.adoc is readable" $ do
      mb <- readFileMaybe "README.adoc"
      case mb of
        Nothing => assertTrue "README.adoc readable" False
        Just content => assertTrue "non-empty" (length content > 0)

  , test "bench-pre: STATE.a2ml is readable" $ do
      mb <- readFileMaybe ".machine_readable/6a2/STATE.a2ml"
      case mb of
        Nothing => assertTrue "STATE.a2ml readable" False
        Just content => assertTrue "non-empty" (length content > 0)

  -- Regex preconditions: invariants the bench measures must still hold.
  , test "bench-pre: SPDX extractor finds MPL-2.0 in 1KB sample" $ do
      assertEq (extractSpdxId sampleContent) "MPL-2.0"

  , test "bench-pre: placeholder detection is False on 1KB sample" $ do
      assertEq (containsUnresolvedPlaceholder sampleContent) False

  , test "bench-pre: AsciiDoc-heading regex matches nothing on TOML sample" $ do
      -- The TS bench just times the match; no = lines exist in the sample,
      -- so the count is zero.
      let hasAdoc = isInfixOf "\n= " sampleContent || isPrefixOf "= " sampleContent
      assertEq hasAdoc False

  -- Stat preconditions.
  , test "bench-pre: stat .machine_readable/ probe succeeds" $ do
      ok <- fileExists ".machine_readable/CLADE.a2ml"
      assertTrue "marker file present" ok

  -- JSON parse precondition: sample is non-empty.
  , test "bench-pre: jsonSample is non-empty and contains project name" $ do
      assertTrue "jsonSample shape"
                 (isInfixOf "thunderbird-template-reloaded" jsonSample
                  && length jsonSample > 0)
  ]
