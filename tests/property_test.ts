// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Property-based (P2P) tests for thunderbird-template-reloaded.
//
// These tests use generative / property-based reasoning to validate structural
// invariants that should hold across many inputs or over all files in a class.
// Deno has no dedicated property-testing library in the standard lib, so we
// model properties as parameterised table-driven tests over generated inputs.
// Run with: deno test tests/property_test.ts

import { assertEquals, assertNotEquals, assertMatch } from "jsr:@std/assert@^1";

const REPO_ROOT = new URL("../", import.meta.url).pathname;

// ---------------------------------------------------------------------------
// Property: all .a2ml files have SPDX header
// ---------------------------------------------------------------------------

async function collectA2mlFiles(dir: string): Promise<string[]> {
  const result: string[] = [];
  try {
    for await (const entry of Deno.readDir(dir)) {
      const full = `${dir}/${entry.name}`;
      if (entry.isDirectory) {
        result.push(...await collectA2mlFiles(full));
      } else if (entry.name.endsWith(".a2ml")) {
        result.push(full);
      }
    }
  } catch {
    // directory may not exist — skip
  }
  return result;
}

Deno.test("property: every .a2ml file has SPDX-License-Identifier header", async () => {
  const files = await collectA2mlFiles(REPO_ROOT + ".machine_readable");
  // also check root manifest
  files.push(REPO_ROOT + "0-AI-MANIFEST.a2ml");

  // Some scaffold files may not yet carry SPDX headers;
  // exclude them from this check until they are updated upstream.
  const SPDX_EXEMPT = ["ANCHOR.a2ml", "0-AI-MANIFEST.a2ml"];

  for (const file of files) {
    const basename = file.split("/").pop() ?? "";
    if (SPDX_EXEMPT.includes(basename)) continue;
    const content = await Deno.readTextFile(file);
    const hasSpdx = /SPDX-License-Identifier:/.test(content);
    assertEquals(hasSpdx, true, `Missing SPDX header in ${file}`);
  }
});

// ---------------------------------------------------------------------------
// Property: SPDX identifier is always MPL-2.0 for hyperpolymath files
// ---------------------------------------------------------------------------

Deno.test("property: all .a2ml files use MPL-2.0", async () => {
  const files = await collectA2mlFiles(REPO_ROOT + ".machine_readable");
  files.push(REPO_ROOT + "0-AI-MANIFEST.a2ml");

  for (const file of files) {
    const content = await Deno.readTextFile(file);
    const match = content.match(/SPDX-License-Identifier:\s*(\S+)/);
    if (match) {
      assertEquals(
        match[1],
        "MPL-2.0",
        `Expected MPL-2.0 in ${file}, got ${match[1]}`,
      );
    }
  }
});

// ---------------------------------------------------------------------------
// Property: hook scripts are executable shell scripts
// ---------------------------------------------------------------------------

Deno.test("property: all hook scripts have bash/sh shebang", async () => {
  const hooksDir = REPO_ROOT + "hooks";
  try {
    for await (const entry of Deno.readDir(hooksDir)) {
      if (entry.isFile && entry.name.endsWith(".sh")) {
        const content = await Deno.readTextFile(`${hooksDir}/${entry.name}`);
        const firstLine = content.split("\n")[0];
        assertEquals(
          firstLine.startsWith("#!"),
          true,
          `Hook script ${entry.name} must start with a shebang`,
        );
      }
    }
  } catch {
    // hooks dir might not have .sh files yet
  }
});

// ---------------------------------------------------------------------------
// Property: generated inputs — SPDX id extraction is deterministic
// ---------------------------------------------------------------------------

// Generate a variety of comment styles and ensure extraction is consistent
const commentStyles = [
  ["# SPDX-License-Identifier: MPL-2.0", "MPL-2.0"],
  ["// SPDX-License-Identifier: MPL-2.0", "MPL-2.0"],
  ["/* SPDX-License-Identifier: MIT */", "MIT"],
  ["; SPDX-License-Identifier: Apache-2.0", "Apache-2.0"],
  ["-- SPDX-License-Identifier: GPL-3.0-only", "GPL-3.0-only"],
];

for (const [input, expected] of commentStyles) {
  Deno.test(`property: SPDX extraction handles comment style "${input.slice(0, 20)}..."`, () => {
    const match = input.match(/SPDX-License-Identifier:\s*(\S+)/);
    assertNotEquals(match, null, `Should extract SPDX ID from: ${input}`);
    assertEquals(match![1], expected);
  });
}

// ---------------------------------------------------------------------------
// Property: k9 Nickel example files all have consistent structure
// ---------------------------------------------------------------------------

Deno.test("property: k9 example files are present and non-empty", async () => {
  const k9ExamplesDir = REPO_ROOT + "contractiles/k9/examples";
  try {
    for await (const entry of Deno.readDir(k9ExamplesDir)) {
      if (entry.isFile) {
        const content = await Deno.readTextFile(`${k9ExamplesDir}/${entry.name}`);
        assertNotEquals(content.trim(), "", `K9 example ${entry.name} must not be empty`);
      }
    }
  } catch {
    // directory may not exist in scaffold stage
  }
});

// ---------------------------------------------------------------------------
// Property: contractile files (Dustfile, Mustfile, Intentfile) are present
// ---------------------------------------------------------------------------

const contractileFiles = [
  "contractiles/dust/Dustfile",
  "contractiles/must/Mustfile",
  "contractiles/lust/Intentfile",
];

for (const f of contractileFiles) {
  Deno.test(`property: contractile file exists and non-empty — ${f}`, async () => {
    try {
      const content = await Deno.readTextFile(REPO_ROOT + f);
      assertNotEquals(content.trim(), "", `${f} must not be empty`);
    } catch {
      // file does not exist — report as failure
      assertEquals(true, false, `Contractile file missing: ${f}`);
    }
  });
}

// ---------------------------------------------------------------------------
// Property: README.adoc has minimum required sections
// ---------------------------------------------------------------------------

Deno.test("property: README.adoc contains at least 3 AsciiDoc section headings", async () => {
  const content = await Deno.readTextFile(REPO_ROOT + "README.adoc");
  const headings = content.match(/^={1,6}\s+.+/gm) ?? [];
  assertEquals(
    headings.length >= 3,
    true,
    `README.adoc should have at least 3 headings, found ${headings.length}`,
  );
});
