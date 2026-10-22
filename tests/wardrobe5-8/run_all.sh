#!/usr/bin/env bash
# Runs every OFFLINE test for the wardrobe5-8 feature. No server, DB, client or retail binary needed.
# Requirements: g++ (C++17) and python3. Run from anywhere; the script cd's to the repo root.
# On Windows use Git Bash/MSYS2 with a g++ toolchain, or run the equivalent cl.exe /std:c++17 commands by hand.
set -u
cd "$(dirname "$0")/../.."
OUT="${TMPDIR:-/tmp}/w58_tests"; mkdir -p "$OUT"
CXX="${CXX:-g++}"; FLAGS="-std=c++17 -w -Isrc -Isrc/map -Isrc/common"
fail=0
run_cpp() { # name, sources...
  local name="$1"; shift
  if $CXX $FLAGS -o "$OUT/$name" "$@" 2>"$OUT/$name.log" && "$OUT/$name"; then echo "PASS  $name"; else echo "FAIL  $name (see $OUT/$name.log)"; fail=1; fi
}
run_cpp container_ids  tests/wardrobe5-8/container_ids_test.cpp
run_cpp inventory_guard tests/wardrobe5-8/inventory_guard_test.cpp src/map/packets/inventory_modify.cpp src/map/packets/char_equip.cpp
run_cpp handshake      tests/wardrobe5-8/handshake_test.cpp src/map/packets/w58_ack.cpp
for t in tools/client_patch/wardrobe5-8/test_*.py; do
  if python3 -W error "$t" >"$OUT/$(basename "$t").log" 2>&1; then echo "PASS  $(basename "$t")"; else echo "FAIL  $(basename "$t") (see $OUT/$(basename "$t").log)"; fail=1; fi
done
# SQL lint of the migration (needs python3 only)
if python3 tools/sqlcheck.py sql/slices/wardrobe5-8/up.sql >/dev/null 2>&1; then echo "PASS  sqlcheck up.sql"; else echo "FAIL  sqlcheck up.sql"; fail=1; fi
[ "$fail" = 0 ] && echo "ALL OFFLINE TESTS PASSED" || echo "SOME TESTS FAILED"
exit $fail
