#!/usr/bin/env python3
"""Require a cited source for literal entity ids a PR adds to Lua.

Usage: pr_id_literals.py <base-ref> <head-ref>   (PR body in $PR_BODY)

Scans added Lua lines for entity-id literals (>= 16777216, i.e. 0x1000000, the first zone's mob/npc
range) and lists them in the job summary. If any are added, the PR body must have a non-empty
"## ID sources" section (the PR template provides it). It cannot check that an id is real; it only
makes the worker state where each came from, so Claude knows what to verify against a fresh client pull.
"""
import os
import re
import subprocess
import sys

base, head = sys.argv[1], sys.argv[2]
diff = subprocess.run(
    ["git", "diff", "--unified=0", "--diff-filter=ACMR", f"{base}...{head}", "--", "*.lua"],
    capture_output=True, text=True, errors="replace").stdout

LIT = re.compile(r"(?<![\w.])(\d{8,9})(?![\w.])")
found, cur = [], None
for line in diff.splitlines():
    if line.startswith("+++ b/"):
        cur = line[6:]
    elif line.startswith("+") and not line.startswith("+++"):
        for m in LIT.finditer(line):
            if int(m.group(1)) >= 0x1000000:
                found.append((cur, m.group(1)))

if not found:
    print("OK: no new entity-id literals in Lua")
    sys.exit(0)

print(f"{len(found)} new entity-id literal(s) in Lua:")
for f, v in found[:40]:
    print(f"  {f}: {v}")

body = os.environ.get("PR_BODY", "") or ""
m = re.search(r"##\s*ID sources\s*\n(.*?)(?:\n##\s|\Z)", body, re.S | re.I)
section = re.sub(r"<!--.*?-->", "", m.group(1), flags=re.S).strip() if m else ""
if not section or section.lower() in ("n/a", "none"):
    print("FAIL: PR adds id literals but its '## ID sources' section is missing or empty. "
          "Cite the file/pull each id came from, or replace unsourced ones with TODO(ID needs Claude lookup).")
    sys.exit(1)
print("OK: '## ID sources' section present (content is verified locally by Claude, not here)")
