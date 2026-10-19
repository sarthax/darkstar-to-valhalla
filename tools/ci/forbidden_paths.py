#!/usr/bin/env python3
"""Fail if a PR touches files workers must never commit. Usage: forbidden_paths.py changed.txt"""
import re
import sys

FORBIDDEN = [
    (r"^conf/.*\.conf$", "local server config (DB credentials, garden settings)"),
    (r"^version\.info$", "local version lock"),
    (r"^GIT_VER$", "generated"),
    (r"^data/", "local data"),
    (r"^navmeshes(/|$)", "navmeshes submodule"),
    (r"^\.gitmodules$", "submodule config"),
    (r"\.(exe|pdb|dll|lib|obj|ilk)$", "build artifact"),
    (r"^(log|tmp)/", "logs / scratch"),
    (r"(^|/)\.env$", "secrets"),
]

bad = 0
for path in (l.strip() for l in open(sys.argv[1]) if l.strip()):
    for rx, why in FORBIDDEN:
        if re.search(rx, path):
            print(f"FORBIDDEN: {path} ({why})")
            bad += 1
            break
print("OK: no forbidden paths" if not bad else f"{bad} forbidden path(s) in PR")
sys.exit(1 if bad else 0)
