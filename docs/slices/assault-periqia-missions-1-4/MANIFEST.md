# Periqia Assault - Missions 1-4 (PSC/PFC/LC/C tier)

## Package layout (updated 2026-09-21)

This package targets DSP. `old-dsp-reference` is the source of truth. On 2026-09-21 `lua-dsp/` was compared byte-for-byte against it (known exceptions are listed in the sync review, e.g. `Shared.lua` in mercenary_rank_promotions and `warpassault.lua`); `sql-dsp/` has NOT been row-verified against the live `dspdb`.

- `lua-dsp/` -- 24 files: DSP-converted Lua scripts (deploy these)
- `sql-dsp/` -- 3 files: DSP database SQL for `dspdb` (assault rows and fixes; deploy these)
- `navmesh/` -- 1 files: navmesh files
- `archive-topaz/` -- 55 files: ARCHIVED Topaz-format copies (not deployed): `lua/` (19), `sql/` (8), `cpp-engine-reference/` (28)

The Topaz-format `lua/`, `sql/` and `cpp-engine-reference/` folders were moved into `archive-topaz/`. Anywhere the text below refers to `lua/`, `sql/` or `cpp-engine-reference/`, read `archive-topaz/lua/`, `archive-topaz/sql/`, `archive-topaz/cpp-engine-reference/` (historical; not for deployment) and use `lua-dsp/` / `sql-dsp/` for installation.


The first 4 of Periqia's 10 real Assault missions: Seagull Grounded (31), Requiem (32), Saving Private Ryaaf (33), Shooting Down the Baron (34). Missions 5-10 are deliberately excluded (not yet ready to publish) -- ids extracted precisely from each target instance script's own real references. Depends on two shared packages applied alongside this one: mercenary_rank_promotions (Lageegee/the Whitegate rank system) and assault_lockbox_appraisal (Drahbah/Chochoroon/Memeroon) -- neither is duplicated here.

## Contents
- `lua/` — 19 Lua scripts
- `sql/` — row-level extracts: npc_list (12), mob_spawn_points (65), mob_pools (13), mob_groups (13), mob_skills (35), mob_skill_lists (35)
- `cpp-engine-reference/` — 28 engine files (reference only — see note below)
- `navmesh/` — Periqia
- `docs/` — 0 supporting doc(s)

## C++ engine reference note
The files under `cpp-engine-reference/` are **shared, global engine fixes**, not specific to this mission. They are required by any Assault mission to function correctly (allegiance-gated claim checks, incapacitate-immunity handling, etc.) and are duplicated into every mission package for self-containment. Apply them once to the target engine build, not once per package.

## Deployment notes
REQUIRES two shared packages applied first/alongside, neither duplicated here: mercenary_rank_promotions (Lageegee grants PERIQIA_ASSAULT_ORDERS and opens this zone's mission menu) and assault_lockbox_appraisal (appraises the "???" item this zone's Ancient Lockbox hands out).
1. Apply the C++ engine reference changes to the target engine build and rebuild (one-time, shared across all mission packages).
2. Import sql/*.sql in this order: npc_list, mob_pools, mob_groups, mob_skill_lists, mob_skills, mob_droplist, mob_pets, mob_pool_mods.
3. Copy lua/ into the target scripts/ tree at matching relative paths.
4. Copy navmesh/Periqia.nav into the target navmeshes/ directory.
5. Restart/reimport per this codebase's own dbtool.py + map-server restart convention.
6. Missions 5-10 (Stop the Bloodshed, Defuse the Threat, Operation: Snake Eyes, Wake the Puppet, Shades of Vengeance, The Price Is Right) are intentionally excluded -- not ready to publish.
7. DSP-side conversion output lives in this package's lua-dsp/ tree (not lua/), including a full converted Excaliace.lua. DSP's own real scripts/zones/Periqia/mobs/Excaliace.lua is a small 21-line abandoned stub (different, non-overlapping localvar scaffolding, never read back anywhere) -- it is intentionally superseded/replaced by this package's Excaliace.lua, not merged. All files from this package's missions are included in lua-dsp/ regardless of what DSP already has; deployment/merge decisions for any other overlapping file are left to whoever applies the package.

## Known open issues / TODOs
- Saving Private Ryaaf: 2 of the 5 rooms' "which direction leads to which real survivor" pattern (S and C-facing rows in the ROOMS table) use engine-byte placeholder facings (192/254), not capture-confirmed values -- flagged inline in the instance script, not independently re-verified during this packaging pass.

## 2026-09-20: instance SQL added to sql-dsp/
Found during the fresh-server rebuild: this package did not ship every instance row its missions need. Files added, generated from the tested live dspdb:
- `sql-dsp/instance_entities.sql`
- `sql-dsp/instance_gap_mob_spawn_points.sql`
- `sql-dsp/instance_list.sql`
Load order: after this package's npc_list / mob_spawn_points files: instance_gap_npc_list, instance_gap_mob_spawn_points, instance_list, instance_entities. None use INSERT IGNORE. Missions 5-10 are still excluded.

## 2026-09-21: SQL scope cleanup
- Removed stock full-table dumps (`DROP TABLE`) of npc_list/mob_skills/mob_skill_lists/mob_groups/mob_pools; remaining npc_list/mob_groups/mob_pools files hold only this package's in-scope rows as `REPLACE INTO` (no DROP/CREATE).
- Removed duplicate `dsp_inscope_fixes_2026-09-19.sql`; the single current copy is `dsp-fixes/dsp_inscope_fixes_2026-09-19.sql` (superset).
