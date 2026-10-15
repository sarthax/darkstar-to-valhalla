# Lebros Cavern Assault - Missions 1-4 (PSC/PFC/LC/C tier)

## Package layout (updated 2026-09-21)

This package targets DSP. `old-dsp-reference` is the source of truth. On 2026-09-21 `lua-dsp/` was compared byte-for-byte against it (known exceptions are listed in the sync review, e.g. `Shared.lua` in mercenary_rank_promotions and `warpassault.lua`); `sql-dsp/` has NOT been row-verified against the live `dspdb`.

- `lua-dsp/` -- 30 files: DSP-converted Lua scripts (deploy these)
- `sql-dsp/` -- 12 files: DSP database SQL for `dspdb` (assault rows and fixes; deploy these)
- `navmesh/` -- 1 files: navmesh files
- `archive-topaz/` -- 54 files: ARCHIVED Topaz-format copies (not deployed): `lua/` (17), `sql/` (9), `cpp-engine-reference/` (28)

The Topaz-format `lua/`, `sql/` and `cpp-engine-reference/` folders were moved into `archive-topaz/`. Anywhere the text below refers to `lua/`, `sql/` or `cpp-engine-reference/`, read `archive-topaz/lua/`, `archive-topaz/sql/`, `archive-topaz/cpp-engine-reference/` (historical; not for deployment) and use `lua-dsp/` / `sql-dsp/` for installation.


The first 4 of Lebros Cavern's 10 real Assault missions: Excavation Duty (21), Lebros Supplies (22), Troll Fugitives (23), Evade and Escape (24). Missions 5-10 are deliberately excluded (not yet ready to publish) -- ids extracted precisely from each target instance script's own real references, not a contiguous range guess. Depends on two shared packages applied alongside this one: mercenary_rank_promotions (Famad/the Whitegate rank system) and assault_lockbox_appraisal (Drahbah/Chochoroon/Memeroon) -- neither is duplicated here.

## Contents
- `lua/` — 17 Lua scripts (verbatim Topaz source, reference only — do not deploy directly)
- `sql/` — row-level extracts, verbatim Topaz source (reference only): npc_list (25), mob_spawn_points (46), mob_pools (10), mob_groups (10), mob_skills (23), mob_skill_lists (23), mob_pool_mods (1)
- `lua-dsp/` — 18 Lua scripts, DSP-ready (`scripts/zones/Lebros_Cavern/` — `IDs.lua`, `TextIDs.lua`, `Zone.lua`, `instances/` x4, `mobs/` x7, `npcs/` x4). **This is what actually gets deployed.** As of 2026-09-17 this is a byte-for-byte sync of `old-dsp-reference`'s own live, tested copies (see BACKPORT_REPORT.md finding #1) — old-dsp-reference had already independently fixed real bugs the mechanical Topaz→DSP conversion had missed.
- `sql-dsp/` — 9 SQL files, DSP-ready column shapes. **This is what actually gets deployed/verified against the live DB.** As of 2026-09-17, cross-checked row-by-row against the live dspdb: every row in every file already exists live except one (`mob_skills` id 1747 'zarraqa' + its `mob_skill_lists` membership), which was found missing and inserted directly into the live DB this session (see BACKPORT_REPORT.md findings #3/#4/#6). Running these files against the live server as a bulk import today would mostly hit duplicate-key errors, not because the data is wrong but because it's already there — see "Known open issues" below before doing a fresh import elsewhere.
- `cpp-engine-reference/` — 28 engine files (reference only — see note below)
- `navmesh/` — Lebros_Cavern
- `docs/` — 0 supporting doc(s)

## C++ engine reference note
The files under `cpp-engine-reference/` are **shared, global engine fixes**, not specific to this mission. They are required by any Assault mission to function correctly (allegiance-gated claim checks, incapacitate-immunity handling, etc.) and are duplicated into every mission package for self-containment. Apply them once to the target engine build, not once per package.

## Deployment notes
REQUIRES two shared packages applied first/alongside, neither duplicated here: mercenary_rank_promotions (Famad grants LEBROS_ASSAULT_ORDERS and opens this zone's mission menu) and assault_lockbox_appraisal (appraises the "???" item this zone's Ancient Lockbox hands out).
1. Apply the C++ engine reference changes to the target engine build and rebuild (one-time, shared across all mission packages).
2. Import `sql-dsp/*.sql` (NOT `sql/`, which is verbatim Topaz source kept for reference only) in this order: npc_list, mob_pools, mob_groups, mob_skills, mob_skill_lists, mob_pool_mods, mob_spawn_points, instance_list, instance_entities. **As of 2026-09-17 this has already been done against the live dspdb** — see the `sql-dsp/` contents note above. Importing again elsewhere (a fresh server, a different DB) should expect most rows to already exist only if that target is also a copy of the same live DB; against a genuinely fresh DSP install these files should import cleanly. None of the `sql-dsp/*.sql` files use `INSERT IGNORE`, so re-running any of them against a DB that already has the rows will hard-fail on the first duplicate key — strip already-applied rows first, or add `IGNORE` before reusing.
3. Copy `lua-dsp/` (NOT `lua/`) into the target scripts/ tree at matching relative paths.
4. Copy navmesh/Lebros_Cavern.nav into the target navmeshes/ directory.
5. Do NOT use dbtool.py for this package -- it is currently being updated (user instruction, 2026-09-17). Apply sql-dsp/*.sql directly (e.g. `mysql.connector` or the `mysql` CLI) against the target dspdb, then restart/reload the map-server. A map-server restart was NOT performed this session after inserting the one new live row (mob_skills 1747 'zarraqa') -- unconfirmed whether it's needed for a running server to pick up a new skill/skill-list row, flag for the user before relying on it live.
6. Missions 5-10 (Apkallu Breeding, Wamoura Farm Raid, Siegemaster Assassination, Egg Conservation, Operation Black Pearl, Better Than One) are intentionally excluded -- not ready to publish.

## Known open issues / TODOs
- Excavation Duty's dup-entity theory for Brittle Rock 1-5 (a second overlapping mob per rock, matching real capture-confirmed data) was tried and reverted -- made rocks 1-3 unreliable without fixing 4/5. See Brittle_Rock.lua for the full investigation trail; current behavior is the single-mob-per-rock baseline, not the dup theory.
- Map-server restart after the 2026-09-17 `mob_skills`/`mob_skill_lists` live insert has not been verified — confirm zarraqa actually appears in a live Troll's moveset before considering this fully closed.
- Map-server restart after the 2026-09-17 `MOBMOD_ALWAYS_AGGRO` fix (all 4 instance files, see BACKPORT_REPORT.md finding #8) has also not been verified live.

## Mob aggro fix (2026-09-17, see BACKPORT_REPORT.md finding #8)
All 4 missions' `lua-dsp/scripts/zones/Lebros_Cavern/instances/*.lua` now call
`mob:setMobMod(MOBMOD_ALWAYS_AGGRO, 1)` on every kill-target mob spawn. DSP's aggro gate
(`CZoneEntities::SpawnMOBs`, `expGain > 50`) silently blocks aggro for any Assault-tier mob without
this — Topaz doesn't have this gate, so the same Lua/SQL "worked" there but not on DSP. This is a
code-only fix (no new SQL rows), already applied to `lua-dsp/` and to `old-dsp-reference`'s own live
copies. Confirmed missing from every other Assault zone in `old-dsp-reference` as of 2026-09-17
(Arrapago Remnants, Ilrusi Atoll, Mamool Ja Training Grounds, Periqia, The Ashu Talif) — those are out
of scope for this package but should get the same treatment.

## Process/toolkit gaps identified during the 2026-09-17 audit (for mission_toolkit hardening)
Full detail in BACKPORT_REPORT.md's "Audit findings and fixes" section; summarized here so future
sessions don't have to re-derive them:
1. **No detection for "target codebase already has a more-evolved version of this file."** The
   conversion pass only diffs against Topaz source, so it silently overwrote/ignored a live,
   independently-fixed `old-dsp-reference` implementation instead of flagging it for a manual diff.
2. **Silent full-table row-skip on schema-shape mismatch.** `instance_list.sql` skipped all 10
   Topaz rows (no `zoneid` column in DSP) and produced an empty file with no loud warning — looked
   indistinguishable from a legitimately-empty/no-op file.
3. **Id-collision/content-duplication checks go stale.** The automated report's `mob_groups`
   content-dup check found real ids `[2150, 2144, ...]` at scan time; a live re-query on 2026-09-17
   found DIFFERENT real ids `[17019, 17026, ...]` for the same content — the target DB's own id
   assignments had shifted between the check and today. Checks need a timestamp/expiry or a
   mandatory re-run immediately before import, not a one-time trust.
4. **No `INSERT IGNORE` on tables with legitimately shared content.** `npc_list.sql` and others use
   plain `INSERT INTO`; since 10-25+ of their rows commonly already exist live (shared world content
   between mission packages), a bulk import hard-fails on the first duplicate key instead of
   skipping rows that are already correctly present.
5. **No default compensation for the Topaz-vs-DSP mob aggro engine divergence.** DSP gates autonomous
   mob aggro on `expGain > 50` (real level/job-based exp against the target); Topaz gates it on a
   difficulty classification instead. Assault-tier mobs give ~0 exp to endgame characters, so under
   DSP every ported Assault mission silently loses aggro (mobs never notice/chase/sight-aggro; only
   direct-engage combat works) unless `mob:setMobMod(MOBMOD_ALWAYS_AGGRO, 1)` is explicitly forced on
   each kill-target mob at spawn time. The mechanical conversion pass has no awareness of this at all
   — it should apply this by default to every `SpawnMob` call for a kill-target mob, with an opt-out
   for mobs that are deliberately passive/scripted-engage by mission design (see this package's own
   `orichalcum_survey.lua` Qiqirn Miners for a real example of a correct exception). Found live-wide:
   as of 2026-09-17, only Nyzul Isle (fixed 2026-09-16) had this compensation; Arrapago Remnants,
   Ilrusi Atoll, Lebros Cavern (fixed this session), Leujaoam Sanctum (fixed this session), Mamool Ja
   Training Grounds, Periqia, and The Ashu Talif did not.

## 2026-09-20: instance SQL added to sql-dsp/
Found during the fresh-server rebuild: this package did not ship every instance row its missions need. Files added, generated from the tested live dspdb:
- `sql-dsp/instance_entities.sql`
- `sql-dsp/instance_gap_npc_list.sql`
- `sql-dsp/instance_list.sql`
Load order: after this package's npc_list / mob_spawn_points files: instance_gap_npc_list, instance_gap_mob_spawn_points, instance_list, instance_entities. None use INSERT IGNORE. Missions 5-10 are still excluded.
- 2026-09-20 cleanup: removed the 12 Imperial Stormer `mob_spawn_points` rows (17035292-303) from `sql-dsp/mob_spawn_points.sql`. In the tested build the Stormers are NPCs (`npc_list`), not mobs. Added `sql-dsp/pool_mods_2026-09-20.sql` (roam mods for pool 4815). `dsp_inscope_fixes_2026-09-19.sql` corrected: dropped the wrong `MamoolJaMage 1149->1734` row and set pool 3437 to list 1151 (live value); the same edit is in every package copy and in `dsp-fixes/`.

## 2026-09-21: SQL scope cleanup
- Removed stock full-table dumps (`DROP TABLE`) of npc_list/mob_skills/mob_skill_lists/mob_groups/mob_pools; remaining npc_list/mob_groups/mob_pools files hold only this package's in-scope rows as `REPLACE INTO` (no DROP/CREATE).
- Removed duplicate `dsp_inscope_fixes_2026-09-19.sql`; the single current copy is `dsp-fixes/dsp_inscope_fixes_2026-09-19.sql` (superset).
- Removed instance 25-30 rows from instance_entities.sql (saved in archive-topaz/sql/instance_entities_out_of_scope_instances_25-30.sql).
