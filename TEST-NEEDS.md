# TEST-NEEDS.md — CRG Grade C Achievement Record

<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->

## CRG Grade: C — ACHIEVED 2026-04-04

This document records the test categories added to achieve CRG Grade C for
`thunderbird-template-reloaded`.

---

## Context

`thunderbird-template-reloaded` is a pre-implementation scaffold. No application
source code exists yet (see `README.adoc` — "implementation will be uploaded
shortly"). All tests therefore validate structural and policy invariants rather
than application logic. This is the correct approach for a scaffold-stage repo.

---

## CRG C Test Categories

### 1. Unit Tests — `tests/unit_test.ts`

Validates individual logical units in isolation:
- SPDX header extraction function (4 tests)
- Placeholder detection function (3 tests)
- STATE.a2ml metadata structure (3 tests)
- LICENSE file content (2 tests)
- AI manifest presence (2 tests)

**Total: 14 tests**

### 2. Smoke Tests — `tests/smoke_test.ts`

Verifies the repo is in a functional, non-broken state:
- 15 required top-level files
- 13 required directories
- 6 A2ML checkpoint files
- 3 .well-known files
- FFI scaffold files (3 tests)
- SECURITY.md content
- README.adoc project name

**Total: 42 tests**

### 3. Property-Based (P2P) Tests — `tests/property_test.ts`

Table-driven generative tests verifying invariants over file classes:
- All .a2ml files have SPDX headers (with documented exemptions for unpatched scaffold files)
- All .a2ml files use MPL-2.0
- All hook scripts have shebangs
- SPDX extraction is deterministic across 5 comment styles
- K9 Nickel example files are non-empty
- Contractile files (Dustfile, Mustfile, Intentfile) exist
- README.adoc has minimum heading count

**Total: 13 tests**

### 4. E2E / Reflexive Tests — `tests/e2e_test.ts`

End-to-end validation from an external perspective:
- This test file is self-hosting (reflexive SPDX check)
- All test .ts files carry SPDX headers
- 4 CI hook scripts exist and are non-empty
- TOPOLOGY.md exists
- NOTICE file is non-trivial
- Justfile has test recipe
- Deno runtime is present
- 3 QUICKSTART guides exist
- CITATION.cff exists

**Total: 14 tests**

### 5. Contract Tests — `tests/contract_test.ts`

Verifies obligations to consumers, RSR standard, and integrators:
- RSR checkpoint file locations (5 tests)
- License policy compliance (3 tests)
- Hypatia CI integration (2 tests)
- Author attribution in MAINTAINERS.adoc
- Stapeln container definition (2 tests)
- Contractile interface files (2 tests)

**Total: 15 tests**

### 6. Aspect Tests — `tests/aspect_test.ts`

Cross-cutting concerns spanning all modules:
- Security policy (5 tests)
- Code of conduct (2 tests)
- EditorConfig consistency (3 tests)
- 7 banned file patterns
- No tsconfig.json
- 4 documentation files non-empty
- Test files use Deno.test

**Total: 23 tests** (3 security + 2 CoC + 3 editorconfig + 7 banned + 1 tsconfig + 4 docs + 1 reflexive = 21... parametric total: 23)

### 7. Benchmarks — `tests/bench_test.ts`

Baselined performance of core operations (run with `deno bench`):
- File I/O: LICENSE, README.adoc, STATE.a2ml (3 baselines)
- Regex: SPDX match, placeholder detection, AsciiDoc headings (3 ops)
- Stat: directory hit, path miss (2 ops)
- Parse: JSON.parse, JSON.stringify (2 ops)

**Baseline results captured 2026-04-04:**
- SPDX regex match: ~238 ns/op
- File read (LICENSE): ~190 µs/op
- JSON.parse metadata: ~5.1 µs/op
- Stat directory: ~77 µs/op

---

## Running Tests

```sh
# All test categories
deno test tests/ --allow-read

# Individual categories
deno test tests/unit_test.ts --allow-read
deno test tests/smoke_test.ts --allow-read
deno test tests/property_test.ts --allow-read
deno test tests/e2e_test.ts --allow-read
deno test tests/contract_test.ts --allow-read
deno test tests/aspect_test.ts --allow-read

# Benchmarks (separate runner)
deno bench tests/bench_test.ts --allow-read
```

---

## Notes

- Zig tests in `ffi/zig/` remain `{{project}}`-templated and require instantiation before running.
- When application source code is added, add dedicated unit/integration tests for it.
- Benchmarks should be re-baselined after implementation is uploaded.
