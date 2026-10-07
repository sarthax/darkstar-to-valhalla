# Nyzul Isle Investigation - Self-Contained Mission Package

## Package layout (updated 2026-09-21)

This package targets DSP. `old-dsp-reference` is the source of truth. On 2026-09-21 `lua-dsp/` was compared byte-for-byte against it (known exceptions are listed in the sync review, e.g. `Shared.lua` in mercenary_rank_promotions and `warpassault.lua`); `sql-dsp/` has NOT been row-verified against the live `dspdb`.

- `lua-dsp/` -- 232 files: DSP-converted Lua scripts (deploy these)
- `sql-dsp/` -- 12 files: DSP database SQL for `dspdb` (assault rows and fixes; deploy these)
- `cpp-engine-reference-dsp/` -- 9 files: DSP engine source reference
- `navmesh/` -- 2 files: navmesh files
- `docs/` -- 2 files: supporting docs
- `archive-topaz/` -- 242 files: ARCHIVED Topaz-format copies (not deployed): `lua/` (204), `sql/` (10), `cpp-engine-reference/` (28)

The Topaz-format `lua/`, `sql/` and `cpp-engine-reference/` folders were moved into `archive-topaz/`. Anywhere the text below refers to `lua/`, `sql/` or `cpp-engine-reference/`, read `archive-topaz/lua/`, `archive-topaz/sql/`, `archive-topaz/cpp-engine-reference/` (historical; not for deployment) and use `lua-dsp/` / `sql-dsp/` for installation.


Assault mission 51 (Nyzul Isle Investigation), packaged with every Lua script, row-level SQL data, engine reference file, and navmesh it depends on. Built to be reviewed and deployed on its own, with no other backport package as a prerequisite.

## Contents
- `lua/` — 204 Lua scripts
- `sql/` — row-level extracts: npc_list (25), mob_spawn_points (132), mob_pools (111), mob_groups (112), mob_skills (293), mob_skill_lists (302), mob_droplist (205), mob_pool_mods (6), npc_list (by name) (2), instance_list (by instance) (1), instance_entities (by instance) (363)
- `cpp-engine-reference/` — 28 engine files (reference only — see note below)
- `navmesh/` — Nyzul_Isle (Alzadaal_Undersea_Ruins moved to nyzul_alzadaal_undersea_ruins)
- `docs/` — 2 supporting doc(s)

## C++ engine reference note
The files under `cpp-engine-reference/` are **shared, global engine fixes**, not specific to this mission. They are required by any Assault mission to function correctly (allegiance-gated claim checks, incapacitate-immunity handling, etc.) and are duplicated into every mission package for self-containment. Apply them once to the target engine build, not once per package.

## Deployment notes
1. Apply the C++ engine reference changes to the target engine build and rebuild (one-time, shared across all mission packages).
2. Import sql/*.sql in this order: npc_list, mob_pools, mob_groups, mob_skill_lists, mob_skills, mob_droplist, mob_pets, mob_pool_mods, instance_list, instance_entities.
3. Copy lua/ into the target scripts/ tree at matching relative paths.
4. Copy navmesh/*.nav into the target navmeshes/ directory.
5. Restart/reimport per this codebase own dbtool.py + map-server restart convention (a SQL reimport alone may not apply zone/entity data live).
6. Path of Darkness (mission 58/59) and Nashmeira Plea intentionally excluded - separate missions sharing this zone IDs.lua, not part of Investigation.
7. `Aht_Urhgan_Whitegate/npcs/Rytaal.lua` (the NPC that grants the Imperial Army I.D. Tag every Assault mission giver requires) is intentionally NOT included -- DSP's own existing copy already natively supports Nyzul Isle (checks for `NYZUL_ISLE_ASSAULT_ORDERS` by name) and needs no changes. See `lua-dsp/MERGE_DECISIONS.md` for the full verification.

## Known open issues / TODOs
- Lobby/Runic Disc menu and floor generator UI are follow-up work, not included in this slice (see nyzul_isle_investigation.lua header).
- Teleporter-to-next-floor coordinates for Floor 2 4-teleporter structure are not yet captured (direction-only fact, no coordinates).
- Runic Disc reset-on-floor-100-clear mechanic is unconfirmed and not implemented (see Nyzul_Isle/IDs.lua WARNING_RESET_DISC comment).

## 2026-09-20: spawn point gap
- `sql-dsp/mob_spawn_points_gap_2026-09-20.sql`: 240 zone-77 spawn points (REPLACE INTO) that were missing from mob_spawn_points.sql. Load after it.
- 2026-09-20: added `sql-dsp/armoury_crate_17093610_2026-09-20.sql` (the third Armoury Crate; only 609 and 611 were carried over). Removed 11 `mob_skills` and 36 `mob_skill_lists` rows from `sql-dsp/` that the tested build never had; they added Topaz skills to base skill lists used by ordinary mobs. Still shipped and not yet reviewed: 3 placeholder mobs at position (1,1,1) (17092630, 17092914, 17092999) and mob_groups row 78.

## 2026-09-21: SQL scope cleanup
- Zone 72 (Alzadaal Undersea Ruins) lua, navmesh and SQL rows moved to the new package `nyzul_alzadaal_undersea_ruins`.
- Removed zone 77 main-storyline (ToAU) npcs, mobs and their dependent pools/skills/drops (Nashmeira, Razfahd, Alexander, Raubahn, Naja, Amnaf, etc.): not used by Nyzul Isle Investigations and already present on the target server.
- Zone 50 (Aht Urhgan Whitegate) mission/reward NPC rows kept.
- Armoury Crate 17092609 restored to npc_list.sql: captures show retail crates spawn dynamically from the 17092609+ pool (20 stock rows, 17092609-17092628); the 3 instance crates 17093609-17093611 are separate.
- Armoury Crate pool 17092610-17092628 added to npc_list.sql (REPLACE INTO, stock rows). The 20 unreferenced mob_skills are intentionally kept (valid stock skills for other battles).
- Removed the 20 skills not referenced by any shipped skill list (399-401,403,472-477,810-812,922-924,926,2041,2045,2058); they exist in stock DSP.

## 2026-09-21: door prop _253 fix
- `sql-dsp/door_253_open_2026-09-21.sql` -- npcid 17093353 (door `_253`) was blocking level progress at animation 9 (closed); set to 8 (open/passable). Applied live to `dspdb` and `dspdb_fresh`, and to `dsp-fresh/sql/npc_list.sql`, `old-dsp-reference/sql/npc_list.sql`, and `Topaz-Assault-Backport/source/sql/npc_list.sql`.

## 2026-09-21: layout 17 re-enabled
- `lua-dsp/scripts/zones/Nyzul_Isle/instances/nyzul_isle_investigation.lua` `pickFloorLayout()`: layout 17 was excluded from normal floor selection (`math.random(1, 15)`); a live-data audit confirmed layout 17 is valid and non-blocking, so it's back in the pool (`{1..15, 17}`, still excluding boss-reserved 16). Applied identically to `dsp-fresh`, `old-dsp-reference`, and `Topaz-Assault-Backport/source`.
- This is a Lua change, not SQL -- the running map-server needs a script reload/restart to pick it up, same as any other Lua edit.

## Git branch notes
- SQL ships as import scripts in `sql/slices/nyzul-investigation/` (not merged into sql/*.sql) so this slice never conflicts with other slices' SQL. Load order is in SQL_APPLY_PLAN.md. Importing is required; editing files has no live effect.
- Navmesh (.nav) files are not in git; take them from the package `navmesh/` folder.
- Engine hunks included: IMPAIRMENT (job ability / weaponskill restriction bits) and OMERTA (per-magic-type) for Nyzul pathos. Rebuild required.
- Needs `scripts/globals/debug_print.lua` from the shared `base/debug-print` branch (also used by Heroines' Holdfast).
- Excluded: Heroines' Holdfast instance file, Uncharted Area Survey (own branch), Alzadaal zone files (own branch), GM tools wa/warpassault (own slice).
