# assault-periqia

Periqia Assault missions 1-4.

**Scope:** Missions 1-4 only. Missions beyond this level pack stay in Topaz until their pack is pulled and converted.

**Where the code is:** the DSP Lua for this slice is already in the base tree (scripts/zones and scripts/globals, first landed in snapshot commit aead3d5dc8). Checked 2026-10-15: the package's `lua-dsp/` files are byte-identical to `main`. This slice adds the package documentation and the install SQL as a tracked record; it does not change any script.

**SQL:** `sql/slices/assault-periqia/` holds the package's `sql-dsp` files (run by hand, not part of the base import). They have NOT been row-verified against the live `dspdb`.

**Source package:** `Topaz-Assault-Backport/mission-packages/periqia_missions_1-4`. Package MANIFEST.md, TEST_PLAN.md and any BACKPORT_REPORT.md are copied alongside this README; their references to `lua/`, `sql/` and `archive-topaz/` describe the package layout, not this repo.
