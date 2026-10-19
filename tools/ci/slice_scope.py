#!/usr/bin/env python3
"""Warn (never fail) when a PR touches shared engine files or several slices. Usage: slice_scope.py changed.txt"""
import re
import sys

paths = [l.strip() for l in open(sys.argv[1]) if l.strip()]
engine = [p for p in paths if re.search(
    r"^src/map/(lua/lua_baseentity|luautils|packet_system|map\.|entities/(charentity|mobentity)|utils/charutils)|modifier\.h$", p)]
slices = sorted({m.group(1) for p in paths if (m := re.match(r"(?:sql|docs)/slices/([^/]+)/", p))})

if engine:
    print("::warning::Touches conflict-prone shared engine files: " + ", ".join(engine))
if len(slices) > 1:
    print("::warning::Touches multiple slices: " + ", ".join(slices) + " (one slice per PR is the convention)")
print("scope check done (warnings only)")
