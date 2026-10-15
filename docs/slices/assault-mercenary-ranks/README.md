# assault-mercenary-ranks

Mercenary rank promotions (Yahsra and the Whitegate rank system) that opens each zone's mission menu.

**Scope:** Shared by every Assault zone pack. Missions beyond this level pack stay in Topaz until their pack is pulled and converted.

**Where the code is:** the DSP Lua for this slice is already in the base tree (scripts/zones and scripts/globals, first landed in snapshot commit aead3d5dc8). Checked 2026-10-15: the package's `lua-dsp/` files are byte-identical to `main`. This slice adds the package documentation and the install SQL as a tracked record; it does not change any script.

**SQL:** `sql/slices/assault-mercenary-ranks/` holds the package's `sql` files (run by hand, not part of the base import). They have NOT been row-verified against the live `dspdb`.

**Source package:** `Topaz-Assault-Backport/mission-packages/mercenary_rank_promotions`. Package MANIFEST.md, TEST_PLAN.md and any BACKPORT_REPORT.md are copied alongside this README; their references to `lua/`, `sql/` and `archive-topaz/` describe the package layout, not this repo.
