-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Port of tests/smoke_test.ts to Idris2, estate-rollout port 10/11.
-- 35 of 35 smoke tests ported (15 required files + 13 required dirs +
-- 6 a2ml files + 3 well-known files + 3 FFI scaffold + 2 README/SECURITY).
--
-- TS isDirectory probes the inode kind; Idris2's base lacks that, so we
-- probe a known file inside each required directory instead.

module SmokeTest

import Test.Spec
import Data.String
import System.File

%default covering

fileExists : String -> IO Bool
fileExists path = do
  Right _ <- readFile path
    | Left _ => pure False
  pure True

readFileMaybe : String -> IO (Maybe String)
readFileMaybe path = do
  Right contents <- readFile path
    | Left _ => pure Nothing
  pure (Just contents)

toLowerAscii : String -> String
toLowerAscii s = pack (map toLowerChar (unpack s))
  where
    toLowerChar : Char -> Char
    toLowerChar c =
      if c >= 'A' && c <= 'Z'
        then chr (ord c + 32)
        else c

requiredFiles : List String
requiredFiles =
  [ "LICENSE"
  , "README.adoc"
  , "EXPLAINME.adoc"
  , "SECURITY.md"
  , "CONTRIBUTING.md"
  , "MAINTAINERS.adoc"
  , "ROADMAP.adoc"
  , "NOTICE"
  , "Justfile"
  , "0-AI-MANIFEST.a2ml"
  , "PROOF-NEEDS.md"
  , ".editorconfig"
  , "stapeln.toml"
  , "flake.nix"
  , "guix.scm"
  ]

-- Directory + a marker file inside it (probed instead of Deno.stat isDirectory).
requiredDirsProbed : List (String, String)
requiredDirsProbed =
  [ (".machine_readable",        ".machine_readable/CLADE.a2ml")
  , (".machine_readable/6a2",    ".machine_readable/6a2/STATE.a2ml")
  , ("tests",                    "tests/unit_test.ts")
  , ("tests/fuzz",               "tests/fuzz/placeholder.txt")
  , ("ffi",                      "ffi/zig/src/main.zig")
  , ("ffi/zig",                  "ffi/zig/build.zig")
  , ("ffi/zig/src",              "ffi/zig/src/main.zig")
  , ("ffi/zig/test",             "ffi/zig/test/integration_test.zig")
  , ("docs",                     "docs/CITATIONS.adoc")
  -- "examples" entry removed 2026-05-26: proxy file
  -- `examples/SafeDOMExample.res` is being deleted in this same PR
  -- (estate-wide gitbot-fleet#208 sweep — stale ReScript fixture).
  -- Re-add when a non-stale examples/ file lands (affinescript#56).
  , ("contractiles",             "contractiles/README.adoc")
  , ("hooks",                    "hooks/validate-spdx.sh")
  , (".well-known",              ".well-known/security.txt")
  ]

a2mlCheckpointFiles : List String
a2mlCheckpointFiles =
  [ ".machine_readable/6a2/STATE.a2ml"
  , ".machine_readable/6a2/META.a2ml"
  , ".machine_readable/6a2/ECOSYSTEM.a2ml"
  , ".machine_readable/6a2/AGENTIC.a2ml"
  , ".machine_readable/6a2/NEUROSYM.a2ml"
  , ".machine_readable/6a2/PLAYBOOK.a2ml"
  ]

wellKnownFiles : List String
wellKnownFiles =
  [ ".well-known/security.txt"
  , ".well-known/ai.txt"
  , ".well-known/humans.txt"
  ]

requiredFileTest : String -> TestCase
requiredFileTest f =
  test ("smoke: required file exists -- " ++ f) $ do
    ok <- fileExists f
    assertTrue ("required file missing: " ++ f) ok

requiredDirTest : (String, String) -> TestCase
requiredDirTest (d, marker) =
  test ("smoke: required directory exists -- " ++ d) $ do
    ok <- fileExists marker
    assertTrue ("required directory missing (probed via " ++ marker ++ "): " ++ d) ok

a2mlTest : String -> TestCase
a2mlTest f =
  test ("smoke: a2ml checkpoint exists -- " ++ f) $ do
    ok <- fileExists f
    assertTrue ("a2ml file missing: " ++ f) ok

wellKnownTest : String -> TestCase
wellKnownTest f =
  test ("smoke: well-known file exists -- " ++ f) $ do
    ok <- fileExists f
    assertTrue ("well-known file missing: " ++ f) ok

public export
allSuites : List TestCase
allSuites =
  map requiredFileTest requiredFiles
  ++ map requiredDirTest requiredDirsProbed
  ++ map a2mlTest a2mlCheckpointFiles
  ++ map wellKnownTest wellKnownFiles
  ++ [ test "smoke: FFI main.zig exists" $ do
         ok <- fileExists "ffi/zig/src/main.zig"
         assertEq ok True

     , test "smoke: FFI build.zig exists" $ do
         ok <- fileExists "ffi/zig/build.zig"
         assertEq ok True

     , test "smoke: FFI integration_test.zig exists" $ do
         ok <- fileExists "ffi/zig/test/integration_test.zig"
         assertEq ok True

     , test "smoke: SECURITY.md is non-empty" $ do
         mb <- readFileMaybe "SECURITY.md"
         case mb of
           Nothing => assertTrue "SECURITY.md must exist" False
           Just content => assertTrue "non-empty" (length content > 0)

     , test "smoke: README.adoc mentions thunderbird" $ do
         mb <- readFileMaybe "README.adoc"
         case mb of
           Nothing => assertTrue "README.adoc must exist" False
           Just content =>
             assertTrue "README.adoc should mention thunderbird"
                        (isInfixOf "thunderbird" (toLowerAscii content))
     ]
