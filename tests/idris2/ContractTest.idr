-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Port of tests/contract_test.ts to Idris2, estate-rollout port 10/11.
-- 18 of 18 contract obligations ported. All file-existence + substring shape.

module ContractTest

import Test.Spec
import Data.String
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

-- Lowercase ASCII letters; preserves non-letters.
toLowerAscii : String -> String
toLowerAscii s = pack (map toLowerChar (unpack s))
  where
    toLowerChar : Char -> Char
    toLowerChar c =
      if c >= 'A' && c <= 'Z'
        then chr (ord c + 32)
        else c

public export
allSuites : List TestCase
allSuites =
  -- RSR obligations
  [ test "contract/RSR: STATE.a2ml exists in .machine_readable/6a2/" $ do
      ok <- fileExists ".machine_readable/6a2/STATE.a2ml"
      assertEq ok True

  , test "contract/RSR: META.a2ml exists in .machine_readable/6a2/" $ do
      ok <- fileExists ".machine_readable/6a2/META.a2ml"
      assertEq ok True

  , test "contract/RSR: ECOSYSTEM.a2ml exists in .machine_readable/6a2/" $ do
      ok <- fileExists ".machine_readable/6a2/ECOSYSTEM.a2ml"
      assertEq ok True

  , test "contract/RSR: AGENTIC.a2ml exists in .machine_readable/6a2/" $ do
      ok <- fileExists ".machine_readable/6a2/AGENTIC.a2ml"
      assertEq ok True

  , test "contract/RSR: no SCM checkpoint files in repo root" $ do
      a <- fileExists "STATE.scm"
      b <- fileExists "META.scm"
      c <- fileExists "ECOSYSTEM.scm"
      d <- fileExists "AGENTIC.scm"
      assertTrue "no .scm files in root" (not a && not b && not c && not d)

  , test "contract/RSR: no SCM checkpoint files exist anywhere" $ do
      a <- fileExists ".machine_readable/STATE.scm"
      b <- fileExists ".machine_readable/META.scm"
      c <- fileExists ".machine_readable/ECOSYSTEM.scm"
      d <- fileExists ".machine_readable/AGENTIC.scm"
      assertTrue "no .scm files in .machine_readable/" (not a && not b && not c && not d)

  , test "contract/RSR: EXPLAINME.adoc is present" $ do
      ok <- fileExists "EXPLAINME.adoc"
      assertEq ok True

  , test "contract/RSR: ABI-FFI-README.md is present" $ do
      ok <- fileExists "ABI-FFI-README.md"
      assertEq ok True

  -- License policy obligations
  , test "contract/license: LICENSE file uses PMPL" $ do
      mb <- readFileMaybe "LICENSE"
      case mb of
        Nothing => assertTrue "LICENSE must exist" False
        Just content =>
          assertTrue "LICENSE must contain PMPL (Palimpsest) text"
                     (isInfixOf "palimpsest" (toLowerAscii content))

  , test "contract/license: LICENSES/PMPL-1.0-or-later.txt present" $ do
      ok <- fileExists "LICENSES/PMPL-1.0-or-later.txt"
      assertEq ok True

  , test "contract/license: README.adoc has SPDX header" $ do
      mb <- readFileMaybe "README.adoc"
      case mb of
        Nothing => assertTrue "README.adoc must exist" False
        Just content =>
          assertTrue "SPDX-License-Identifier: present"
                     (isInfixOf "SPDX-License-Identifier:" content)

  -- Hypatia CI integration
  , test "contract/hypatia: .hypatia/ directory exists" $ do
      ok <- fileExists ".hypatia/last-visit.json"
      -- fileExists on directory fails on Idris2, so probe a known file inside
      assertTrue ".hypatia/ present (probed via last-visit.json)" ok

  , test "contract/hypatia: .hypatia/last-visit.json exists" $ do
      ok <- fileExists ".hypatia/last-visit.json"
      assertEq ok True

  -- Author attribution
  , test "contract/author: MAINTAINERS.adoc references Jonathan D.A. Jewell" $ do
      mb <- readFileMaybe "MAINTAINERS.adoc"
      case mb of
        Nothing => assertTrue "MAINTAINERS.adoc must exist" False
        Just content =>
          assertTrue "should reference Jonathan or hyperpolymath"
                     (isInfixOf "Jonathan" content || isInfixOf "hyperpolymath" content)

  -- Stapeln
  , test "contract/stapeln: stapeln.toml exists" $ do
      ok <- fileExists "stapeln.toml"
      assertEq ok True

  , test "contract/stapeln: stapeln.toml is non-empty" $ do
      mb <- readFileMaybe "stapeln.toml"
      case mb of
        Nothing => assertTrue "stapeln.toml must exist" False
        Just content => assertTrue "non-empty" (length content > 0)

  -- Contractiles
  , test "contract/contractiles: TRUST.contractile exists in .machine_readable/" $ do
      ok <- fileExists ".machine_readable/TRUST.contractile"
      assertEq ok True

  , test "contract/contractiles: MUST.contractile exists in .machine_readable/" $ do
      ok <- fileExists ".machine_readable/MUST.contractile"
      assertEq ok True
  ]
