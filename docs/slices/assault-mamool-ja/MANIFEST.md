# Mamool Ja Training Grounds Assault - Missions 1-4 (PSC/PFC/LC/C tier)

## Package layout (updated 2026-09-21)

This package targets DSP. `old-dsp-reference` is the source of truth. On 2026-09-21 `lua-dsp/` was compared byte-for-byte against it (known exceptions are listed in the sync review, e.g. `Shared.lua` in mercenary_rank_promotions and `warpassault.lua`); `sql-dsp/` has NOT been row-verified against the live `dspdb`.

- `lua-dsp/` -- 46 files: DSP-converted Lua scripts (deploy these)
- `sql-dsp/` -- 9 files: DSP database SQL for `dspdb` (assault rows and fixes; deploy these)
- `navmesh/` -- 1 files: navmesh files
- `archive-topaz/` -- 59 files: ARCHIVED Topaz-format copies (not deployed): `lua/` (20), `sql/` (9), `cpp-engine-reference/` (30)

The Topaz-format `lua/`, `sql/` and `cpp-engine-reference/` folders were moved into `archive-topaz/`. Anywhere the text below refers to `lua/`, `sql/` or `cpp-engine-reference/`, read `archive-topaz/lua/`, `archive-topaz/sql/`, `archive-topaz/cpp-engine-reference/` (historical; not for deployment) and use `lua-dsp/` / `sql-dsp/` for installation.


The first 4 of Mamool Ja Training Grounds' 10 real Assault missions: Imperial Agent Rescue (11), Preemptive Strike (12), Sagelord Elimination (13), Breaking Morale (14). Missions 5-10 are deliberately excluded (not yet ready to publish) -- their mob/npc ids were identified precisely from each target instance script's own real references and extracted by exact id, not by a contiguous range guess (this zone's own id numbering has real gaps between missions, confirmed by direct extraction rather than assumed). Depends on two shared packages that must be applied alongside this one: mercenary_rank_promotions (Isdebaaq/the Whitegate rank system) and assault_lockbox_appraisal (Drahbah/Chochoroon/Memeroon) -- neither is duplicated here.

## Contents
- `lua/` — 20 Lua scripts
- `sql/` — row-level extracts: npc_list (25), mob_spawn_points (67), mob_pools (15), mob_groups (15), mob_skills (22), mob_skill_lists (27), mob_pool_mods (4)
- `cpp-engine-reference/` — 28 engine files (reference only — see note below)
- `navmesh/` — Mamool_Ja_Training_Grounds
- `docs/` — 0 supporting doc(s)

## C++ engine reference note
The files under `cpp-engine-reference/` are **shared, global engine fixes**, not specific to this mission. They are required by any Assault mission to function correctly (allegiance-gated claim checks, incapacitate-immunity handling, etc.) and are duplicated into every mission package for self-containment. Apply them once to the target engine build, not once per package.

## Deployment notes
REQUIRES two shared packages applied first/alongside, neither duplicated here: mercenary_rank_promotions (Isdebaaq grants MAMOOL_JA_ASSAULT_ORDERS and opens this zone's mission menu) and assault_lockbox_appraisal (appraises the "???" item this zone's Ancient Lockbox hands out).
1. Apply the C++ engine reference changes to the target engine build and rebuild (one-time, shared across all mission packages).
2. Import sql/*.sql in this order: npc_list, mob_pools, mob_groups, mob_skill_lists, mob_skills, mob_droplist, mob_pets, mob_pool_mods.
3. Copy lua/ into the target scripts/ tree at matching relative paths.
4. Copy navmesh/Mamool_Ja_Training_Grounds.nav into the target navmeshes/ directory.
5. Restart/reimport per this codebase's own dbtool.py + map-server restart convention.
6. Missions 5-10 (Marids in the Mist, Azure Ailments, The Double Agent, Imperial Treasure Retrieval, Blitzkrieg, The Susanoo Shuffle) are intentionally excluded -- not ready to publish.

## Known open issues / TODOs
- Breaking Morale (mission 14): real objective text ("Steal the supplies") doesn't thematically match the mission's own name -- flagged as an unresolved mismatch in this zone's IDs.lua, not something this packaging pass investigated or fixed. Currently modeled as kill-all-18 (same shape as Preemptive Strike) pending further research.
- Preemptive Strike's door/wall prop family (_1u9 through _1uj) was found completely unregistered in sql/instance_entities.sql during earlier Topaz-side work -- revealed with each prop's own npc_list default animation value, but which value actually means "open" vs "closed" for this specific prop family has not been independently live-verified.

## 2026-09-20: instance SQL added to sql-dsp/
Found during the fresh-server rebuild: this package did not ship every instance row its missions need. Files added, generated from the tested live dspdb:
- `sql-dsp/instance_entities.sql`
- `sql-dsp/instance_gap_mob_spawn_points.sql`
- `sql-dsp/instance_gap_npc_list.sql`
- `sql-dsp/instance_list.sql`
Load order: after this package's npc_list / mob_spawn_points files: instance_gap_npc_list, instance_gap_mob_spawn_points, instance_list, instance_entities. None use INSERT IGNORE. Missions 5-10 are still excluded.
- `sql-dsp/overwrite_mob_pools_2026-09-20.sql`: pool 3437 skill_list_id overwrite (base row survived the package INSERT).
- 2026-09-20: added `sql-dsp/pool_mods_2026-09-20.sql` (roam mods for pool 2531). `dsp_inscope_fixes` corrected as noted in the Lebros manifest.

## 2026-09-21: SQL scope cleanup
- Removed stock full-table dumps (`DROP TABLE`) of npc_list/mob_skills/mob_skill_lists/mob_groups/mob_pools; remaining npc_list/mob_groups/mob_pools files hold only this package's in-scope rows as `REPLACE INTO` (no DROP/CREATE).
- Removed duplicate `dsp_inscope_fixes_2026-09-19.sql`; the single current copy is `dsp-fixes/dsp_inscope_fixes_2026-09-19.sql` (superset).
