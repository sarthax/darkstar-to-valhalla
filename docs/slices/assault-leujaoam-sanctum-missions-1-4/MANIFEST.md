# Leujaoam Sanctum Assault - Missions 1-4 (PSC/PFC/LC/C tier)

## Package layout (updated 2026-09-21)

This package targets DSP. `old-dsp-reference` is the source of truth. On 2026-09-21 `lua-dsp/` was compared byte-for-byte against it (known exceptions are listed in the sync review, e.g. `Shared.lua` in mercenary_rank_promotions and `warpassault.lua`); `sql-dsp/` has NOT been row-verified against the live `dspdb`.

- `lua-dsp/` -- 20 files: DSP-converted Lua scripts (deploy these)
- `sql-dsp/` -- 4 files: DSP database SQL for `dspdb` (assault rows and fixes; deploy these)
- `navmesh/` -- 1 files: navmesh files
- `archive-topaz/` -- 53 files: ARCHIVED Topaz-format copies (not deployed): `lua/` (17), `sql/` (8), `cpp-engine-reference/` (28)

The Topaz-format `lua/`, `sql/` and `cpp-engine-reference/` folders were moved into `archive-topaz/`. Anywhere the text below refers to `lua/`, `sql/` or `cpp-engine-reference/`, read `archive-topaz/lua/`, `archive-topaz/sql/`, `archive-topaz/cpp-engine-reference/` (historical; not for deployment) and use `lua-dsp/` / `sql-dsp/` for installation.


The first 4 of Leujaoam Sanctum's 10 real Assault missions: Leujaoam Cleansing (1), Orichalcum Survey (2), Escort Professor Chanoix (3), Shanarha Grass Conservation (4). Missions 5-10 are deliberately excluded from this package (not yet ready to publish) -- their mob/npc ids live at higher, non-overlapping ranges in this zone's own IDs.lua and were excluded from extraction at the source, not filtered after the fact. Depends on two shared packages that must be applied alongside this one: mercenary_rank_promotions (Yahsra/the Whitegate rank system) and assault_lockbox_appraisal (Drahbah/Chochoroon/Memeroon) -- neither is duplicated here.

## Contents
- `lua/` — 17 Lua scripts
- `sql/` — row-level extracts: npc_list (55), mob_spawn_points (70), mob_pools (7), mob_groups (7), mob_skills (23), mob_skill_lists (23)
- `cpp-engine-reference/` — 28 engine files (reference only — see note below)
- `navmesh/` — Leujaoam_Sanctum
- `docs/` — 0 supporting doc(s)

## C++ engine reference note
The files under `cpp-engine-reference/` are **shared, global engine fixes**, not specific to this mission. They are required by any Assault mission to function correctly (allegiance-gated claim checks, incapacitate-immunity handling, etc.) and are duplicated into every mission package for self-containment. Apply them once to the target engine build, not once per package.

## Deployment notes
REQUIRES two shared packages applied first/alongside, neither duplicated here: mercenary_rank_promotions (Yahsra grants LEUJAOAM_ASSAULT_ORDERS and opens this zone's mission menu) and assault_lockbox_appraisal (appraises the "???" item this zone's Ancient Lockbox hands out).
1. Apply the C++ engine reference changes to the target engine build and rebuild (one-time, shared across all mission packages).
2. Import sql/*.sql in this order: npc_list, mob_pools, mob_groups, mob_skill_lists, mob_skills, mob_droplist, mob_pets, mob_pool_mods.
3. Copy lua/ into the target scripts/ tree at matching relative paths.
4. Copy navmesh/Leujaoam_Sanctum.nav into the target navmeshes/ directory.
5. Restart/reimport per this codebase's own dbtool.py + map-server restart convention.
6. Missions 5-10 (Counting Sheep, Supplies Recovery, Azure Experiments, Imperial Code, Red versus Blue, Bloody Rondo) are intentionally excluded -- not ready to publish, see the project's own scoping decision.

## Known open issues / TODOs
- This MANIFEST predates the `lua-dsp/`/`sql-dsp/` split used by lebros_cavern_missions_1-4 -- `lua-dsp/` exists in this package's directory but isn't documented above; this package has not had the same full audit lebros_cavern_missions_1-4 received on 2026-09-17 (no BACKPORT_REPORT.md exists here). Treat this package as unaudited beyond the one targeted fix below.
- **2026-09-17: applied the Topaz-vs-DSP mob aggro fix** (see lebros_cavern_missions_1-4/BACKPORT_REPORT.md finding #8 for the full writeup) to `lua-dsp/scripts/zones/Leujaoam_Sanctum/instances/escort_professor_chanoix.lua`, `leujaoam_cleansing.lua`, and `shanarha_grass_conservation.lua` -- added `mob:setMobMod(MOBMOD_ALWAYS_AGGRO, 1)` on every kill-target mob spawn, since DSP's `expGain > 50` aggro gate silently blocks autonomous aggro for Assault-tier mobs against endgame characters (Topaz has no such gate). Also applied to `old-dsp-reference`'s own live copies of the same 3 files (this bug exists on the live server itself, not just in this package). Deliberately did NOT touch `orichalcum_survey.lua`'s Qiqirn Miners -- they're intentionally passive/non-hostile by mission design until `Mining_Point.lua` explicitly engages them. **Not verified live** -- requires a map-server restart, not performed this session.

## 2026-09-20: instance SQL added to sql-dsp/
Found during the fresh-server rebuild: this package did not ship every instance row its missions need. Files added, generated from the tested live dspdb:
- `sql-dsp/instance_entities.sql`
- `sql-dsp/instance_gap_mob_spawn_points.sql`
- `sql-dsp/instance_list.sql`
Load order: after this package's npc_list / mob_spawn_points files: instance_gap_npc_list, instance_gap_mob_spawn_points, instance_list, instance_entities. None use INSERT IGNORE. Missions 5-10 are still excluded.
- `sql-dsp/overwrite_item_usable_2026-09-20.sql`: item 5331 animation overwrite (qiqirn_mine).
