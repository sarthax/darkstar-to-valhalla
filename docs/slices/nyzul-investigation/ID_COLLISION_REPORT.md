# Id Collision Report -- Nyzul Isle Investigation vs. DSP's Real Data

Generated via `mission_toolkit/backport_sql_convert.py`'s `check_id_collisions()`, checking every id this package uses against DSP's real, already-indexed data (`ffxi_zone_database.db`'s `dsp_*` tables, built by `build_dsp_index.py` from the real DSP checkout at `D:\Claude\old-dsp-reference`) -- not a hand-diff of two dump files. This resolves DSP_TRANSITION_PLAN.md tasks 8 (id collision check) and 9 (SQL reformatting); converted output lives in `sql-dsp/`, mirroring `sql/`.

## mob_groups -- renumbered (real, severe collision found)

DSP's `mob_groups` primary key is bare `groupid` (server-global), not Topaz's composite
`(zoneid, groupid)` -- confirmed in `dsp_sql_schema_map.json`. Checked all **100**
distinct groupids this package uses (Topaz's own low range, 1-292) against
DSP's real, already-indexed `dsp_mob_groups` (12,149 rows, real max groupid 14631):

**100 of 100 collided** -- every single one already belongs to an existing,
unrelated DSP zone (breakdown by the EXISTING row's zoneid): zone 1, 2, 3, 4, 5, and 9 -- none of
them Nyzul Isle (zone 77). This is a real, total collision, not a partial one -- Topaz's low
groupid numbers were only ever safe because Topaz's own PK scopes uniqueness per-zone.

**Fix applied**: renumbered every groupid in this package to a confirmed-free block starting right
after DSP's real current max (14631), i.e. **14632-14731**
(100 ids), preserving each original groupid's relative order. This range cannot collide
with anything that exists in this DSP snapshot today (it's entirely above the current max), but
**must be re-checked against the actual live target database before applying** -- a live server may
have grown its own groupid space further since this snapshot was taken (see
DSP_TRANSITION_PLAN.md task 4, `[NEEDS DBA/ADMIN]`, for the live-DB version of this same check).
Every `mob_spawn_points.groupid` reference in this package was updated to match.

Old -> new groupid map (first 10 of 100): {1: 14632, 2: 14633, 3: 14634, 4: 14635, 5: 14636, 6: 14637, 7: 14638, 8: 14639, 9: 14640, 10: 14641}

## mob_spawn_points -- groupid references updated to match mob_groups' renumbering

132 rows, `groupid` column rewritten using the same old->new map above
(0 row(s) referenced a groupid NOT in this package's own mob_groups.sql --
worth a manual check, likely a pre-existing DSP group these mobs intentionally share).

18 of 132 distinct id(s) already exist in DSP's real dsp_mob_spawn_points.mobid. 2 are REAL collisions (different entity already at that id). 16 are the same entity already present (safe).

**Real name mismatches (mobid already exists in DSP under a different name):**

- `17093132`: DSP has `Amnaf_blu`, this package has `Amnaf_BLU`
- `17093133`: DSP has `Amnaf_psycheflayer`, this package has `Amnaf_Psycheflayer`

## mob_droplist -- renumbered (real collision confirmed by comparing actual item rows)

Checked all **59** distinct dropIds this package uses against DSP's real, already-indexed
`dsp_mob_droplist` (dropId 4586 max): **all 59 collided**. Unlike a table
with a real per-row PK, a matching dropId number alone doesn't prove a conflict (one dropId
legitimately groups several item rows) -- confirmed by actually comparing the item rows: this
package's dropId 15 drops item 637, while DSP's EXISTING dropId 15 drops entirely different items
(2622, 11376, 16342) for an unrelated mob. Inserting our rows under the same number would corrupt
that unrelated mob's real drop table, not just "duplicate" data.

**Fix applied**: renumbered every dropId to a confirmed-free block starting after DSP's real
current max (4586), i.e. **4587-4645**
(59 ids). Every `mob_groups.dropid` reference in this package was updated to match.
Same live-DB re-check caveat as mob_groups' groupid renumbering applies here too.

## npc_list -- 27 rows, straight schema conversion

25 of 27 distinct id(s) already exist in DSP's real dsp_npc_list.npcid. 1 are REAL collisions (different entity already at that id). 24 are the same entity already present (safe).

**Real name mismatches:**

- `17072271`: DSP has `21`, this package has `blank_transformations`

## mob_pools -- 111 rows, straight schema conversion

97 of 111 distinct id(s) already exist in DSP's real dsp_mob_pools.poolid. 2 are REAL collisions (different entity already at that id). 95 are the same entity already present (safe).

**Real name mismatches:**

- `1426`: DSP has `Friar_s_Lantern`, this package has `Friars_Lantern`
- `3223`: DSP has `Puk`, this package has `Puk_WW`

## instance_entities -- 363 rows, straight schema conversion

None of the 363 distinct id(s) checked collide with DSP's real dsp_instance_entities.id.

## instance_list -- 1 rows, straight schema conversion
- **columns dropped (Topaz has them, DSP has no slot): ['instance_zone']**: Topaz has one extra column, 'instance_zone' (the zone the instance itself lives in, distinct from 'entrance_zone' which is where a player warps in FROM), sitting right after instance_name. DSP's CREATE TABLE has no slot for it at all -- silently dropped by this converter (flagged, not guessed at) since DSP apparently derives this some other way (not yet traced -- if a real DSP instance script needs to know its own zone, check how an existing one does it before assuming this data is simply unused).

None of the 1 distinct id(s) checked collide with DSP's real dsp_instance_list.instanceid.

## mob_pool_mods -- 6 rows, straight schema conversion

Identical schema (both `(poolid, modid)`), no id-collision check applicable (composite key, not a
single-column id space) -- a mod attached to a poolid we already control is inherently scoped to
that poolid, no cross-package collision risk. No warnings.

## mob_skills -- 293 rows, straight schema conversion (added 2026-09-13, task 9 follow-up)

282 of 293 distinct id(s) already exist in DSP's real dsp_mob_skills.mob_skill_id. 2 are REAL
collisions (different entity already at that id). 280 are the same entity already present (safe).

**Real value-level mismatches (same id, different data):**

- `2045`: DSP has `pl_rail_cannon` (mob_anim_id 1373, distance 15.0), this package has
  `rail_cannon_3` (mob_anim_id 1379, distance 20.0) -- same real skill, but real tuning values
  differ, not just cosmetic naming. Needs a human decision (keep DSP's live-tuned values, or
  apply this package's).
- `2058`: DSP has `pw_homing_missile`, this package has `homing_missile` -- name-only difference,
  all other fields match exactly.

## mob_skill_lists -- 302 rows, renumbered (real collision found, added 2026-09-13, task 9 follow-up)

DSP's `skill_list_id` is server-global (like `mob_groups.groupid`), referenced by
`mob_pools.skill_list_id` to select a mob's real moveset. Checked all distinct skill_list_id
values this package uses directly against DSP's real `sql/mob_skill_lists.sql` (not indexed in
`ffxi_zone_database.db` -- parsed directly): **2 real collisions found**, both genuinely
referenced by real Nyzul mob_pools rows:

- `234` ('Soulflayer_NM' in this package, 5 mobskill rows) already belongs to DSP's own
  'Spheroid' family -- referenced by `poolid 2834` (Nepionic_Soulflayer).
- `236` ('Spider' in this package, 3 mobskill rows) already belongs to DSP's own 'Structure'
  family -- referenced by `poolid 6337` (Spinner_NI).

**Fix applied**: renumbered to `999`/`1000` (DSP's real max `skill_list_id` was 998, confirmed via
direct parse of `old-dsp-reference/sql/mob_skill_lists.sql`), updated in both
`mob_skill_lists.sql` and the two referencing `mob_pools.sql` rows (`poolid 2834`:
`skill_list_id` 234->999; `poolid 6337`: `skill_list_id` 236->1000). Same live-DB re-check caveat
as the `mob_groups`/`mob_droplist` renumbering applies here too. `mob_pools.sql` itself was
re-checked after this change: still 97 of 111 collisions, same 2 pre-existing name mismatches
below -- the skill_list_id column update didn't introduce any new poolid-level collision.

## Summary -- items needing a human decision before applying

1. **`mob_groups`/`mob_droplist`/`mob_skill_lists` renumbering must all be re-verified against the
   actual live target database**, not just this DSP snapshot -- see task 4 (`[NEEDS DBA/ADMIN]`).
2. **7 real name/value mismatches** (same id, different data already in DSP) need a decision --
   keep DSP's existing values, overwrite with this package's, or confirm the difference is
   cosmetic and harmless:
   - `npc_list` 17072271: `21` vs `blank_transformations`
   - `mob_spawn_points` 17093132: `Amnaf_blu` vs `Amnaf_BLU`
   - `mob_spawn_points` 17093133: `Amnaf_psycheflayer` vs `Amnaf_Psycheflayer`
   - `mob_pools` 1426: `Friar_s_Lantern` vs `Friars_Lantern`
   - `mob_pools` 3223: `Puk` vs `Puk_WW`
   - `mob_skills` 2045: DSP's `pl_rail_cannon` (anim 1373, distance 15.0) vs this package's
     `rail_cannon_3` (anim 1379, distance 20.0) -- **a real tuning difference, not just cosmetic**,
     needs the most careful review of the 7.
   - `mob_skills` 2058: `pw_homing_missile` vs `homing_missile` -- name-only.
3. **`instance_list`'s dropped `instance_zone` column** -- not yet traced where/whether DSP needs
   this data some other way; check before assuming it's simply unused.
