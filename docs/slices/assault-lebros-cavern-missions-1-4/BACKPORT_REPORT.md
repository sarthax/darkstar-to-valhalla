# Backport report -- lebros_cavern_missions_1-4

Target: `D:\Claude\old-dsp-reference` (detected flavor: `old_dsp_reference`)

## 2026-09-17 audit -- status: RESOLVED

The automated conversion pass below (Lua conversion / SQL conversion / binding audit / id-collision
sections) is preserved as a historical record of what the tooling originally produced. A full hand
audit on 2026-09-17 found the automated pass had left real, live-impacting gaps -- see
"Audit findings and fixes" below for what was actually wrong and how it was resolved. **The package is
now believed correct and internally consistent with `old-dsp-reference`'s live server state for
missions 21-24.** Missions 5-10 remain out of scope (see MANIFEST.md).

## Audit findings and fixes (2026-09-17)

### 1. `lua-dsp/` was a stale, unconverted copy -- REPLACED wholesale
`old-dsp-reference` turned out to already have its own independently-evolved, live-tested
Lebros_Cavern implementation -- architecturally different from the backport's `lua-dsp/` (a bare
global `Lebros` table split across `IDs.lua`/`TextIDs.lua`, vs. the backport's stale
`require(...)`-based conversion that was missing the `local ID = require(...)` assignment in
multiple files). The live copy also contained real bug fixes never propagated to the backport (e.g.
`excavation_duty.lua`'s hardcoded `MOB_GROUP_21` array working around a `SpawnMob` limitation;
`Dahak.lua`'s onMobDeath-vs-onMobDespawn progress-counting fix; real patrol/roam waypoint logic).
**Fix:** synced all 18 `lua-dsp/scripts/zones/Lebros_Cavern/` files from `old-dsp-reference`'s live
copies, added the previously-entirely-missing `TextIDs.lua`, and renamed `Rune_of_Release.lua` ->
`rune_of_release.lua` to match the real live filename (DSP's onTrigger dispatch is
filename-case-sensitive). This eliminated all 84 originally-flagged `DSP-PORT-TODO` lines.
**Toolkit gap:** the conversion pass has no way to detect "the target codebase already has a more
evolved version of this file" -- it only diffs against Topaz source. Worth a pre-flight check: if a
same-named file already exists in the target tree, flag it for a manual diff instead of silently
treating the mechanical conversion as authoritative.

### 2. `sql-dsp/instance_list.sql` was silently empty -- FIXED
The conversion skipped all 10 Topaz rows on a column-count mismatch (DSP's `instance_list` has no
`zoneid` column) and produced a file with zero INSERT statements, no error, no `SQL-PORT-TODO`
marker calling it out as incomplete -- it just looked like a normal, "done" empty-of-warnings file.
**Fix:** pulled the 4 real live rows for instances 21-24 directly from the running dspdb and wrote
them by hand.
**Toolkit gap:** a schema-shape mismatch that skips 100% of a table's rows should emit a loud warning
(ideally block the package from being marked "clean"), not just quietly produce an empty file.

### 3. `mob_groups.sql` / `mob_spawn_points.sql` -- fake-groupid duplication bug, real and confirmed -- FIXED
The conversion minted fresh, unused `groupid` values 1-10 for 10 `(poolid, zoneid=63)` pairs that
ALL already exist live under different real groupids. This is the exact bug class from the Nyzul
Isle incident (`reports/dsp_repair_2026-09-15/INCIDENT_REPORT.md`): a `mob_groups` row's real
identity is `(poolid, zoneid)`, not the storage-level `groupid` PK. The report's own
content-duplication check (section below) HAD already caught this and listed candidate real ids
`[2150, 2144, 2146, 2134, 2136, 14247, 14248, 14249, 2135, 2137]` -- but a live re-query on
2026-09-17 found the CURRENT real groupids are different again:
`[17019, 17026, 17024, 2134, 17027, 17018, 17025, 17023, 17020, 17022]` (poolid 534 -> groupid 2134
is the one pair that happens to match both snapshots). This means the target DB's own groupid
assignments for this content have shifted between when the automated report ran and 2026-09-17 --
confirmed by a second live query immediately before writing this report, matching the ids already
written into `mob_groups.sql`. **Fix:** rewrote `mob_groups.sql` to ship no INSERTs (documents the
real mapping as comments only, since all 10 pairs already exist live) and rewrote
`mob_spawn_points.sql` against the current real groupids, also recovering 5 previously-missing
Brittle_Rock rows and all 12 missing Imperial_Stormer rows.
**Toolkit gap (the important one):** a package's "already checked, ids verified" state can go stale
if the target live DB changes between the check and the actual import -- id-collision/content-dup
checks need a timestamp and should be treated as expired after N days, or re-run automatically
immediately before import rather than trusted from an earlier report.

### 4. `mob_skill_lists.sql` "1 item needs review" -- checked, confirmed a real (small) gap -- FIXED LIVE
Live cross-check of all 5 distinct `skill_list_id` values (56/87/107/199/246) against their real
`skill_list_name` found no name/id mismatches. Row-level check of all 23 `(skill_list_id,
mob_skill_id)` pairs found exactly one not yet present live: `(246, 1747)` -- Troll skill "zarraqa".
Verified this is a REAL skill (exists in Topaz's own `sql/mob_skills.sql` as id 1747, and was already
correctly staged in this package's own `sql-dsp/mob_skills.sql`) that was simply not yet in the live
DB -- not a fabricated id, not a naming collision.
**Fix applied directly to the live dspdb on 2026-09-17** (not via dbtool -- dbtool is currently being
updated, per user instruction; applied with a direct `mysql.connector` INSERT instead, matching the
package's own staged SQL exactly): inserted `mob_skills` id 1747 ('zarraqa') and the
`mob_skill_lists` row `('Troll', 246, 1747)`. Both verified present immediately after insert.

### 6. Full live-DB gap audit (2026-09-17) -- only one real gap found, now closed
Beyond the `mob_groups`/`mob_spawn_points` groupid drift (finding #3, already resolved by rewriting
the SQL files to match current live state, no live INSERTs needed there since the content already
existed) and the zarraqa gap (finding #4), every other `sql-dsp/*.sql` file in this package was
checked row-by-row against the live dspdb by primary key and found to be **already fully present
live**: `mob_pools` (10/10), `npc_list` (25/25), `mob_pool_mods` (1/1), `instance_list` (4/4),
`instance_entities` (165/165), `mob_spawn_points` (63/63). No further live INSERTs were needed or
made beyond the two rows in finding #4.
**Net result: the live dspdb and this package's `sql-dsp/` files are now in agreement for missions
21-24.** A map-server restart/zone reload may still be required for the new mob_skill/skill_list
row to take effect in a running server session, per this codebase's own reimport-vs-restart
convention (SQL changes to reference tables like `mob_skills`/`mob_skill_lists` are typically
cached at zone/mob-pool load time) -- not verified live this session (no server restart was
performed), flagged for the user to confirm before relying on zarraqa appearing in a live Troll's
moveset.

### 5. `npc_list.sql`'s 4 flagged "real conflicts" -- re-checked live, all 4 now match, but a process gap remains
The original report flagged 4 npcid collisions under different names (`AncientLockB` vs
`Ancient_Lockbox`, `Rune_Of_Release` vs `Rune_of_Release`, `_ir0` vs `_jr0`, `_ir1` vs `_jr1`). A
live re-query on 2026-09-17 found all 4 ids now carry the package's expected names exactly
(`Ancient_Lockbox`, `Rune_of_Release`, `_jr0`, `_jr1`) -- so these 4 are resolved/moot as of today.
**Toolkit gap:** `npc_list.sql` uses a plain `INSERT INTO` with no `IGNORE`/`ON DUPLICATE KEY UPDATE`.
Per the original report, 10 of this file's 25 npcids already exist live (now more, potentially, given
the drift seen in finding #3) -- running this file as-is against the live server will hard-fail on
the first duplicate primary key and abort the whole import, not just skip the pre-existing rows.
Every `sql-dsp/*.sql` file that inserts into a table with content that may already exist on
purpose (shared NPCs, shared mob pools) should be generated with `INSERT IGNORE` or an explicit
"already exists, skipping" split, not a bare `INSERT`.

## Original automated conversion pass (historical, superseded by the audit above)

### Lua conversion
17 file(s) converted, 84 line(s) flagged across 9 file(s) -- see finding #1, fully superseded by the
wholesale sync from `old-dsp-reference`.

### SQL conversion
9 file(s) converted, 14 warnings -- `instance_list.sql` schema-shape skip (finding #2),
`mob_groups.sql` groupid-collision note (finding #3), `mob_skill_lists.sql` skill_list_id note
(finding #4, this package's own instance of the warning was a false alarm; the warning text itself
documents a real cross-package incident from the Nyzul package and remains valid general guidance).

### Binding audit
49 confirmed, 1 missing: `:setSpeed(` in `Dahak.lua` -- resolved by the lua-dsp sync (live
`Dahak.lua` uses `mob:speed(N)`, the real old-dsp-reference binding; `:setSpeed(` never existed in
the synced file).

### Lua sanity check
Clean -- no syntax errors, no undeclared global references (still true post-sync).

### SQL id-collision / content-duplication checks (as originally run)
Preserved verbatim below for audit trail. Values are the automated pass's findings, since superseded
by the 2026-09-17 live re-checks in findings #3 and #5 above.

#### `instance_entities` -> `dsp_instance_entities`
26 of 129 distinct id(s) already exist in DSP's real dsp_instance_entities.id (not name-classified,
not re-checked live this session -- lower risk, `instance_entities` is keyed by `(instanceid, id)`
so a collision here would need the SAME instanceid to matter, and these are Lebros-only instanceids).

#### `mob_groups` -> `dsp_mob_groups`
10 of 10 distinct id(s) collided at scan time -- see finding #3 for the resolved, current state.

#### `mob_pools` -> `dsp_mob_pools`
10 of 10 distinct id(s) already exist under the SAME name (safe, confirmed by original scan).

#### `mob_skill_lists` -> `None`
No id-collision check defined for this table by the tooling -- see finding #4 for the manual check
performed this session instead.

#### `mob_skills` -> `dsp_mob_skills`
22 of 23 already exist under the SAME name (safe); the 23rd (id 1747, zarraqa) is the genuinely-new
row covered in finding #4.

#### `mob_spawn_points` -> `dsp_mob_spawn_points`
43 of 46 already exist under the SAME name (safe) -- superseded by finding #3's full rewrite, which
also added the previously-missing rows.

#### `npc_list` -> `dsp_npc_list`
10 of 25 collided (6 same-name/safe, 4 flagged different-name) -- see finding #5 for the live
re-check (all 4 now match) and the outstanding `INSERT IGNORE` toolkit gap.

### 7. Excavation Duty: Brittle Rocks missing/uninteractable -- ROOT CAUSED AND FIXED (2026-09-17)
User-reported live symptom: in Excavation Duty, the Brittle Rock walls were either missing or
present but couldn't be targeted/attacked/destroyed. Root cause: `excavation_duty.lua`'s
`MOB_GROUP_21` array (the list of mob ids `onInstanceCreated` passes to `SpawnMob`) deliberately
excluded the 5 real Brittle_Rock mob ids (17035282/284/286/288/290), based on a comment that
incorrectly assumed those ids were the rock-wall NPC *props* (`_1rx`/`_1ry`/`_1rz`/`_ir0`/`_ir1`,
separately revealed via `setStatus` in the same function) rather than the actual killable
Brittle_Rock *mob* entities (`mob_pools` poolid 534, driven by `Brittle_Rock.lua`). Every sibling
mission (22/23/24) spawns 100% of its target-kill mobs via this same `SpawnMob` loop; Excavation
Duty was the only one silently dropping its real kill-target mobs from the list. Net effect: the
wall prop rendered and blocked movement (correctly revealed), but nothing existed behind it to
attack — exactly the reported "missing / not interactable" symptom.
**Fix:** added the 5 real Brittle_Rock mob ids to `MOB_GROUP_21` in both this package's
`lua-dsp/scripts/zones/Lebros_Cavern/instances/excavation_duty.lua` AND
`D:\Claude\old-dsp-reference\scripts\zones\Lebros_Cavern\instances\excavation_duty.lua` (the live
file had the identical bug — this was never a backport-only issue, it's live on the actual running
DSP server). **A map-server restart/script reload is required for this Lua change to take effect**
-- not performed this session, flagged for the user.
**Related, cleaned up 2026-09-17:** `mob_spawn_points` had carried 5 orphaned duplicate Brittle_Rock
rows (ids 17035283/285/287/289/291, same coordinates as their paired real id) left over from a
previously-reverted "dup entity" experiment (see Brittle_Rock.lua's own 2026-08-20 revert note).
They were inert -- `instance_entities.sql` never referenced them, so they never loaded into the
instance -- but were dead rows in both this package's `sql-dsp/mob_spawn_points.sql` and the live
dspdb. Deleted from both.
**Toolkit gap:** this bug would have been caught by a simple cross-check the toolkit doesn't
currently do: "does every 'kill N of these' instance objective's target mob id appear in this
instance's `SpawnMob` call list?" A per-mission mob-id-usage audit (declared in `mob_spawn_points`/
`instance_entities` vs. actually passed to `SpawnMob` in the instance file) would have flagged
Excavation Duty as the outlier immediately, without needing a live bug report first.

### 8. Topaz-vs-DSP mob aggro divergence: all 4 missions were missing the MOBMOD_ALWAYS_AGGRO fix -- FIXED (2026-09-17)
User-reported: mob aggro doesn't work the same in DSP as it does in Topaz for Assault content, and
this had already been diagnosed and fixed once in Nyzul Isle -- Lebros Cavern (and Leujaoam Sanctum)
needed the same check. This is a genuine engine-level behavioral divergence, not a data/conversion
bug: DSP's `CZoneEntities::SpawnMOBs` (src/map/zone_entities.cpp) gates whether a mob is even
*allowed* to attempt `CanAggroTarget()` on `charutils::GetRealExp()` returning `expGain > 50`. Topaz
gates the same check on `charutils::CheckMob()` (a difficulty classification) instead. Assault-tier
mobs (level 66-85+) give ~0 exp against endgame-level characters under DSP's real-exp-table formula,
so `validAggro` is false for every one of them regardless of detects/aggro flags -- only direct-engage
melee combat worked; mobs never noticed/chased/sight-aggroed a player standing next to them. This was
root-caused live in Nyzul Isle on 2026-09-16 (see
`old-dsp-reference/scripts/zones/Nyzul_Isle/instances/nyzul_isle_investigation.lua`'s `forceAggro`/
`MOBMOD_ALWAYS_AGGRO` writeup) -- the one flag that bypasses DSP's exp-gap gate is
`MOBMOD_ALWAYS_AGGRO`, normally set automatically only for `MOBTYPE_EVENT` mobs
(`CInstanceLoader::LoadInstance`); regular Assault-instance mobs don't get it for free.

**Scope check (2026-09-17):** grepped every Assault-capable zone's `instances/*.lua` in
`old-dsp-reference` for the fix. Before this session, only Nyzul Isle (1 of 3 instance files) had
it -- Arrapago Remnants, Ilrusi Atoll, Lebros Cavern, Leujaoam Sanctum, Mamool Ja Training Grounds,
Periqia, and The Ashu Talif all had **zero** instance files with the fix. This is a systemic gap
across the entire DSP Assault backport, not specific to this package.

**Fix (this session, Lebros Cavern + Leujaoam Sanctum only):** added a local `forceAggro(mob)` helper
(`mob:setMobMod(MOBMOD_ALWAYS_AGGRO, 1)`) to each instance file's kill-target `SpawnMob` loop, applied
to both `old-dsp-reference`'s live files and this package's `lua-dsp/` copies (kept byte-identical, per
finding #1's convention) -- `evade_and_escape.lua`, `excavation_duty.lua`, `lebros_supplies.lua`,
`troll_fugitives.lua` (Lebros Cavern), and `escort_professor_chanoix.lua`, `leujaoam_cleansing.lua`,
`shanarha_grass_conservation.lua` (Leujaoam Sanctum). **Deliberately excluded:**
`orichalcum_survey.lua`'s Qiqirn Miners -- per that file's own header, they're intentionally
passive/non-hostile until `Mining_Point.lua` explicitly engages them once ore is found (a scripted
direct-engage, not autonomous aggro), so forcing always-aggro would change intended mission behavior.
**Not yet verified live** -- requires a map-server restart/script reload, not performed this session
(same caveat as finding #7).
**Toolkit gap:** the mission_toolkit backporter has no check for this at all -- it only converts
Lua/SQL, it doesn't know about DSP's stricter exp-gap aggro gate vs. Topaz's difficulty-based one. Any
new/re-audited Assault mission should get `forceAggro`-style `MOBMOD_ALWAYS_AGGRO` applied to every
`SpawnMob` call for a kill-target mob **by default**, with an explicit opt-out (like
`orichalcum_survey.lua`'s Qiqirn Miners) for mobs that are deliberately passive/scripted-engage by
design. Remaining zones (Arrapago Remnants, Ilrusi Atoll, Mamool Ja Training Grounds, Periqia, The
Ashu Talif) still need the same sweep -- out of scope for this package's audit, flagged for a future
session/package.

## Overall
**Resolved as of 2026-09-17.** `lua-dsp/` and `sql-dsp/` are now believed to match
`old-dsp-reference`'s live server state for missions 21-24, including the mob-aggro engine-divergence
fix (finding #8). Three toolkit-level process gaps remain open for a future hardening pass (see
findings #1, #2, #3, #5, #8): stale-check expiry, silent schema-shape row-skipping, missing
`INSERT IGNORE` on tables with legitimately shared content, and no default aggro-gate compensation for
newly-built/audited missions.
