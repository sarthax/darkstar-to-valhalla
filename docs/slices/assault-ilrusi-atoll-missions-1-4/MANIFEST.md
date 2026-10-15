# Ilrusi Atoll Assault - Missions 1-4 (PSC/PFC/LC/C tier)

## Package layout (updated 2026-09-21)

This package targets DSP. `old-dsp-reference` is the source of truth. On 2026-09-21 `lua-dsp/` was compared byte-for-byte against it (known exceptions are listed in the sync review, e.g. `Shared.lua` in mercenary_rank_promotions and `warpassault.lua`); `sql-dsp/` has NOT been row-verified against the live `dspdb`.

- `lua-dsp/` -- 40 files: DSP-converted Lua scripts (deploy these)
- `sql-dsp/` -- 5 files: DSP database SQL for `dspdb` (assault rows and fixes; deploy these)
- `navmesh/` -- 1 files: navmesh files
- `archive-topaz/` -- 64 files: ARCHIVED Topaz-format copies (not deployed): `lua/` (23), `sql/` (8), `cpp-engine-reference/` (33)

The Topaz-format `lua/`, `sql/` and `cpp-engine-reference/` folders were moved into `archive-topaz/`. Anywhere the text below refers to `lua/`, `sql/` or `cpp-engine-reference/`, read `archive-topaz/lua/`, `archive-topaz/sql/`, `archive-topaz/cpp-engine-reference/` (historical; not for deployment) and use `lua-dsp/` / `sql-dsp/` for installation.


The first 4 of Ilrusi Atoll's 10 real Assault missions: Golden Salvage (41), Lamia No.13 (42), Extermination (43), Demolition Duty (44). Missions 5-10 are deliberately excluded (not yet ready to publish) -- ids extracted precisely from each target instance script's own real references, including the Golden Salvage CURSED_CHEST_SLOTS mimic-chest system (18 real chest mob ids across 18 real spawn regions) and the ambient Percipient Fish set (internally numbered mob[1], a quirk of this zone's own IDs.lua, not mission 1). Depends on two shared packages applied alongside this one: mercenary_rank_promotions (Bhoy Yhupplo/the Whitegate rank system) and assault_lockbox_appraisal (Drahbah/Chochoroon/Memeroon) -- neither is duplicated here.

## Contents
- `lua/` — 23 Lua scripts
- `sql/` — row-level extracts: npc_list (22), mob_spawn_points (72), mob_pools (16), mob_groups (17), mob_skills (47), mob_skill_lists (47)
- `cpp-engine-reference/` — 28 engine files (reference only — see note below)
- `navmesh/` — Ilrusi_Atoll
- `docs/` — 0 supporting doc(s)

## C++ engine reference note
The files under `cpp-engine-reference/` are **shared, global engine fixes**, not specific to this mission. They are required by any Assault mission to function correctly (allegiance-gated claim checks, incapacitate-immunity handling, etc.) and are duplicated into every mission package for self-containment. Apply them once to the target engine build, not once per package.

## Deployment notes
REQUIRES two shared packages applied first/alongside, neither duplicated here: mercenary_rank_promotions (Bhoy Yhupplo grants ILRUSI_ASSAULT_ORDERS and opens this zone's mission menu) and assault_lockbox_appraisal (appraises the "???" item this zone's Ancient Lockbox hands out).
1. Apply the C++ engine reference changes to the target engine build and rebuild (one-time, shared across all mission packages).
2. Import sql/*.sql in this order: npc_list, mob_pools, mob_groups, mob_skill_lists, mob_skills, mob_droplist, mob_pets, mob_pool_mods.
3. Copy lua/ into the target scripts/ tree at matching relative paths.
4. Copy navmesh/Ilrusi_Atoll.nav into the target navmeshes/ directory.
5. Restart/reimport per this codebase's own dbtool.py + map-server restart convention.
6. Missions 5-10 (Apkallu Seizure, Lost and Found, Searat Salvation, Desperately Seeking Cephalopods, Bellerophon's Bliss, Deserter) are intentionally excluded -- not ready to publish.
7. Golden Salvage's Cursed_Chest.lua depends on a real, previously-applied engine fix (luautils::OnTrigger()'s folder-selection logic must be type-aware for a TYPE_MOB entity, not hardcoded to npcs/ -- see documentation/research/Golden_Salvage_Mimic_Architecture_Fix_Scope.md) -- confirm the target engine already has this fix or the chest's onTrigger will never resolve.

## Known open issues / TODOs
- Golden Salvage: only 18 of the real 20 possible chest spawn points are confirmed (18/20 across 4 independent captures) -- modeled with the confirmed 18, not padded to 20.

## 2026-09-19 Ilrusi audit (untested)
- Rune/Lockbox hidden at start (41-43); Uzhahn NPC + Demolition_Automaton + 3 mobskills added (44); pool 973 skill_list 363; !tp targets cursor mob; C++ (rebuild): applyCharm PC guard, OnInstanceCreated Zone.lua fallback, mob OnTrigger. Corpse despawn (43): pools behavior 0; likely caused by failed init, unconfirmed.

## 2026-09-20: instance SQL added to sql-dsp/
Found during the fresh-server rebuild: this package did not ship every instance row its missions need. Files added, generated from the tested live dspdb:
- `sql-dsp/instance_entities.sql`
- `sql-dsp/instance_gap_mob_spawn_points.sql`
- `sql-dsp/instance_gap_npc_list.sql`
- `sql-dsp/instance_list.sql`
Load order: after this package's npc_list / mob_spawn_points files: instance_gap_npc_list, instance_gap_mob_spawn_points, instance_list, instance_entities. None use INSERT IGNORE. Missions 5-10 are still excluded.

## 2026-09-21: SQL scope cleanup
- Removed stock full-table dumps (`DROP TABLE`) of npc_list/mob_skills/mob_skill_lists/mob_groups/mob_pools; remaining npc_list/mob_groups/mob_pools files hold only this package's in-scope rows as `REPLACE INTO` (no DROP/CREATE).
- Removed duplicate `dsp_inscope_fixes_2026-09-19.sql`; the single current copy is `dsp-fixes/dsp_inscope_fixes_2026-09-19.sql` (superset).
