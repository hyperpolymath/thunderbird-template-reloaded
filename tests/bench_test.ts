// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Benchmarks for thunderbird-template-reloaded.
//
// Baselines performance of core operations so regressions can be detected.
// At scaffold stage these measure file I/O throughput and metadata parsing
// latency — the same operations the CI pipeline and AI agents perform on
// every repo visit.
//
// Run with: deno bench tests/bench_test.ts

const REPO_ROOT = new URL("../", import.meta.url).pathname;

// ---------------------------------------------------------------------------
// Bench: file reading throughput
// ---------------------------------------------------------------------------

Deno.bench({
  name: "bench: read LICENSE (cold-ish, real I/O)",
  group: "file-io",
  baseline: true,
  async fn() {
    await Deno.readTextFile(REPO_ROOT + "LICENSE");
  },
});

Deno.bench({
  name: "bench: read README.adoc",
  group: "file-io",
  async fn() {
    await Deno.readTextFile(REPO_ROOT + "README.adoc");
  },
});

Deno.bench({
  name: "bench: read STATE.a2ml",
  group: "file-io",
  async fn() {
    await Deno.readTextFile(REPO_ROOT + ".machine_readable/6a2/STATE.a2ml");
  },
});

// ---------------------------------------------------------------------------
// Bench: SPDX regex matching
// ---------------------------------------------------------------------------

const sampleContent = `# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell

[metadata]
project = "thunderbird-template-reloaded"
version = "0.1.0"
`.repeat(20); // ~1KB of repeated content to model realistic file size

Deno.bench({
  name: "bench: SPDX regex match on 1KB content",
  group: "regex",
  baseline: true,
  fn() {
    sampleContent.match(/SPDX-License-Identifier:\s*(\S+)/);
  },
});

Deno.bench({
  name: "bench: placeholder detection regex on 1KB content",
  group: "regex",
  fn() {
    /\{\{[A-Z_]+\}\}/.test(sampleContent);
  },
});

Deno.bench({
  name: "bench: AsciiDoc heading extraction on 1KB content",
  group: "regex",
  fn() {
    sampleContent.match(/^={1,6}\s+.+/gm);
  },
});

// ---------------------------------------------------------------------------
// Bench: directory stat
// ---------------------------------------------------------------------------

Deno.bench({
  name: "bench: stat .machine_readable/ directory",
  group: "stat",
  baseline: true,
  async fn() {
    await Deno.stat(REPO_ROOT + ".machine_readable");
  },
});

Deno.bench({
  name: "bench: stat non-existent path (expected miss)",
  group: "stat",
  async fn() {
    await Deno.stat(REPO_ROOT + "nonexistent-path-bench-probe").catch(() => {});
  },
});

// ---------------------------------------------------------------------------
// Bench: JSON parse (proxy for metadata parsing workload)
// ---------------------------------------------------------------------------

const jsonSample = JSON.stringify({
  project: "thunderbird-template-reloaded",
  version: "0.1.0",
  crg_grade: "C",
  files: Array.from({ length: 50 }, (_, i) => `file-${i}.adoc`),
});

Deno.bench({
  name: "bench: JSON.parse of metadata object",
  group: "parse",
  baseline: true,
  fn() {
    JSON.parse(jsonSample);
  },
});

Deno.bench({
  name: "bench: JSON.stringify of metadata object",
  group: "parse",
  fn() {
    JSON.stringify({
      project: "thunderbird-template-reloaded",
      crg_grade: "C",
      timestamp: Date.now(),
    });
  },
});
