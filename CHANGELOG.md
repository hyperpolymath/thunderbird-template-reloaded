<!--
SPDX-License-Identifier: CC-BY-SA-4.0
SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell (hyperpolymath)
-->

# Changelog

All notable changes to `thunderbird-template-reloaded` will be documented in this file.

This file is generated from conventional commits by the
[`changelog-reusable.yml`](https://github.com/hyperpolymath/standards/blob/main/.github/workflows/changelog-reusable.yml)
workflow (`hyperpolymath/standards#206`). Adopt the workflow in this repo's CI to keep this file in sync automatically — see
[`templates/cliff.toml`](https://github.com/hyperpolymath/standards/blob/main/templates/cliff.toml)
for the canonical config.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
this project aims to follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- feat(crg): add crg-grade and crg-badge justfile recipes
- feat: add stapeln.toml container definition
- feat: deploy UX Manifesto infrastructure
- feat: add CLADE.a2ml — clade taxonomy declaration

### Fixed

- fix(licence): #3 isolated — clear scaffold-placeholder leak (thunderbird-template-reloaded) (#61)
- fix(ci): bump a2ml/k9-validate-action pins to canonical (#58)
- fix(ci): sync hypatia-scan.yml to canonical (#57)
- fix(ci): build Hypatia escript from repo root (estate dogfood drift)
- fix(scorecard): enforce granular permissions and add fuzzing placeholder
- fix(ci): Resolve workflow-linter self-matching and metadata issues
- fix: correct email jonathan.jewell → j.d.a.jewell
- fix: global AGPL-3.0-or-later → PMPL-1.0-or-later replacement
- fix(license): SPDX AGPL-3.0 → PMPL-1.0-or-later in dotfiles

### Changed

- refactor: migrate 6SCM → 6A2 (.scm → .a2ml format)

### Documentation

- docs: substantive CRG C annotation (EXPLAINME.adoc)
- docs: add EXPLAINME.adoc — prove-it file backing README claims

### CI

- build(deps): bump actions/deploy-pages from 4.0.5 to 5.0.0 (#74)
- build(deps): bump actions/checkout from 4.1.7 to 6.0.2 (#70)
- build(deps): bump actions/upload-pages-artifact from 4.0.0 to 5.0.0 (#73)
- build(deps): bump haskell-actions/setup from 2.10.3 to 2.11.0 (#72)
- build(deps): bump actions/configure-pages from 5.0.0 to 6.0.0 (#71)

## Pre-history

Prior commits to this file's introduction are recorded in git history but not formally classified into Keep-a-Changelog sections. To backfill, run `git cliff -o CHANGELOG.md` locally using the canonical [`cliff.toml`](https://github.com/hyperpolymath/standards/blob/main/templates/cliff.toml) — this is one-shot mechanical work.

---

<!-- This file was seeded by the 2026-05-26 estate tech-debt audit follow-up (Row-2 Phase 3); see [`hyperpolymath/standards/docs/audits/2026-05-26-estate-documentation-debt.md`](https://github.com/hyperpolymath/standards/blob/main/docs/audits/2026-05-26-estate-documentation-debt.md). -->
