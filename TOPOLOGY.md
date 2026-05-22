<!-- SPDX-License-Identifier: MPL-2.0 -->
<!-- TOPOLOGY.md — Project architecture map and completion dashboard -->
<!-- Last updated: 2026-02-19 -->

# Thunderbird Template Reloaded — Project Topology

## System Architecture

```
                        ┌─────────────────────────────────────────┐
                        │              THUNDERBIRD USER           │
                        │        (Email Compose / Drafts)         │
                        └───────────────────┬─────────────────────┘
                                            │
                                            ▼
                        ┌─────────────────────────────────────────┐
                        │           EXTENSION UI LAYER            │
                        │  ┌───────────┐  ┌───────────────────┐  │
                        │  │ Template  │  │  Insert / Manage  │  │
                        │  │ Picker    │  │  Dashboard        │  │
                        │  └─────┬─────┘  └────────┬──────────┘  │
                        └────────│─────────────────│──────────────┘
                                 │                 │
                                 ▼                 ▼
                        ┌─────────────────────────────────────────┐
                        │           CORE LOGIC (RESCRIPT)         │
                        │    (Variable Expansion, Organize)       │
                        └───────────────────┬─────────────────────┘
                                            │
                                            ▼
                        ┌─────────────────────────────────────────┐
                        │             DATA LAYER                  │
                        │  ┌───────────┐  ┌───────────────────┐  │
                        │  │ Drafts    │  │  Local Storage    │  │
                        │  │ (Templates)│ │  (IndexedDB)      │  │
                        │  └───────────┘  └───────────────────┘  │
                        └─────────────────────────────────────────┘

                        ┌─────────────────────────────────────────┐
                        │          REPO INFRASTRUCTURE            │
                        │  Justfile Automation  .machine_readable/  │
                        │  Deno Tooling         0-AI-MANIFEST.a2ml  │
                        └─────────────────────────────────────────┘
```

## Completion Dashboard

```
COMPONENT                          STATUS              NOTES
─────────────────────────────────  ──────────────────  ─────────────────────────────────
EXTENSION CORE
  Logic (ReScript)                  █░░░░░░░░░  10%    Architecture stubs
  UI Components                     █░░░░░░░░░  10%    Initial design stubs
  Variable Engine                   ░░░░░░░░░░   0%    Pending implementation

INFRASTRUCTURE
  Multi-Forge Mirroring             ██████████ 100%    GH/GL/BB/CB sync stable
  Language Policy (CCCP)            ██████████ 100%    RSR stack verified
  .machine_readable/                ██████████ 100%    STATE tracking active

REPO INFRASTRUCTURE
  Justfile Automation               ██████████ 100%    Standard build/lint tasks
  0-AI-MANIFEST.a2ml                ██████████ 100%    AI entry point verified
  GitHub Workflows                  ██████████ 100%    Quality/Security gates active

─────────────────────────────────────────────────────────────────────────────
OVERALL:                            ██░░░░░░░░  ~20%   Specification Phase
```

## Key Dependencies

```
Philosophy ──────► Extension Spec ──────► Implementation ─────► Artifact
     │                 │                      │                    │
     ▼                 ▼                      ▼                    ▼
CCCP Policy ─────► WebExtension API ────► Just Build ────────► .xpi
```

## Update Protocol

This file is maintained by both humans and AI agents. When updating:

1. **After completing a component**: Change its bar and percentage
2. **After adding a component**: Add a new row in the appropriate section
3. **After architectural changes**: Update the ASCII diagram
4. **Date**: Update the `Last updated` comment at the top of this file

Progress bars use: `█` (filled) and `░` (empty), 10 characters wide.
Percentages: 0%, 10%, 20%, ... 100% (in 10% increments).
