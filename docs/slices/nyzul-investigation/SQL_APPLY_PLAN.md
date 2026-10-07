# SQL Apply Plan — Handoff for a DBA/Admin

**What this is**: DSP_TRANSITION_PLAN.md task 10 — the actual step of loading `sql-dsp/`'s
converted content into a real DSP/Valhalla-target database. We don't have write access to that
database from this session; everything here is the ready-to-execute plan for whoever does.

## Real finding: DSP has no migration-tracking for content SQL like this

Task 10 was originally written assuming DSP might expect "whatever migration-tracking DSP expects
(`migrations/migrate.py`)" to stay consistent. Checked `old-dsp-reference/migrations/migrate.py`
directly: it only tracks **one** hardcoded, historical schema-shape migration
(`spell_blobs_to_spell_table` — moving a blob column on the `chars` table into its own table), with
no general mechanism for tracking content additions like npc/mob/instance data at all. There is no
`dbtool.py`-equivalent either (unlike Topaz, which needs `py -3 dbtool.py` after any `sql/*.sql`
edit — see `[[topaz_sql_reimport_required]]` memory; DSP has nothing like it in this snapshot).

**Conclusion: `migrate.py` does not need to be run for this package.** Loading this content is a
plain MySQL/MariaDB import, no DSP-specific tooling involved. If a future DSP version *does* add a
migration for one of these tables, re-check this section before assuming it's still safe to skip.

## Prerequisites (do not skip)

1. **Task 4's live-DB collision check must come back clear first.** Run
   `backport_sql_live_check.py --package <this folder>` (see `LIVE_DB_COLLISION_CHECK.md`) against
   the SAME database you're about to apply to. If it finds a real collision the snapshot-based
   check didn't, stop and re-derive a safe range (same method `ID_COLLISION_REPORT.md` used)
   before continuing — do not apply `sql-dsp/`'s current renumbered ranges over a live collision.
2. **Back up every table this touches before applying anything.** All 8 mob/npc tables
   (`npc_list`, `mob_pools`, `mob_groups`, `mob_droplist`, `mob_spawn_points`, `mob_pool_mods`,
   `mob_skills`, `mob_skill_lists`) are **MyISAM** — MyISAM has no transactions, so a partial
   failure mid-import cannot be rolled back the way an InnoDB transaction can. A restorable backup
   is the only real safety net:
   ```bash
   mysqldump -u <user> -p <database> npc_list mob_pools mob_groups mob_droplist \
       mob_spawn_points mob_pool_mods mob_skills mob_skill_lists instance_entities \
       instance_list > nyzul_pre_apply_backup.sql
   ```
   (`instance_entities`/`instance_list` are InnoDB and can use a transaction, but include them in
   the backup anyway for a single consistent restore point.)
3. **Deploy the Lua tree (`lua-dsp/`, from the earlier conversion pass) alongside this SQL, not
   separately.** The SQL data (npc names, mob names, instance entries) and the Lua scripts that
   implement their `onTrigger`/`onMobSpawn`/etc hooks are two halves of one deployment — applying
   one without the other leaves either dead data (SQL rows with no script) or dead scripts (no SQL
   row for the entity to ever spawn/exist). See `MERGE_DECISIONS.md` for what's already
   hand-merged into DSP's own existing files vs. new files.

## Apply order

None of these tables have real enforced foreign-key constraints (MyISAM doesn't support them, and
the InnoDB tables here don't declare any either) — so the database will accept any order. The order
below follows the real logical dependency chain anyway, so a partial-failure investigation (see
below) has a clear "what should already exist by this point" checkpoint at each step:

```bash
# 1. Independent lookup tables first -- mob_skill_lists references nothing, but mob_pools'
#    skill_list_id column references INTO mob_skill_lists, so it must land first
mysql -u <user> -p <database> < sql-dsp/mob_skills.sql
mysql -u <user> -p <database> < sql-dsp/mob_skill_lists.sql
mysql -u <user> -p <database> < sql-dsp/mob_droplist.sql

# 2. mob_pools references mob_skill_lists.skill_list_id (renumbered, see below)
mysql -u <user> -p <database> < sql-dsp/mob_pools.sql
mysql -u <user> -p <database> < sql-dsp/mob_pool_mods.sql

# 4. mob_groups references mob_pools.poolid and mob_droplist.dropid (both renumbered, see below)
mysql -u <user> -p <database> < sql-dsp/mob_groups.sql

# 5. mob_spawn_points references mob_groups.groupid (renumbered)
mysql -u <user> -p <database> < sql-dsp/mob_spawn_points.sql

# 6. npc_list and instance_list are independent of the above
mysql -u <user> -p <database> < sql-dsp/npc_list.sql
mysql -u <user> -p <database> < sql-dsp/instance_list.sql

# 7. instance_entities references BOTH npc_list.npcid and mob_spawn_points.mobid, plus
#    instance_list.instanceid -- apply last
mysql -u <user> -p <database> < sql-dsp/instance_entities.sql
```

## Known items to resolve before or during apply (from `ID_COLLISION_REPORT.md`)

- **`mob_groups.groupid`**, **`mob_droplist.dropId`**, and **`mob_skill_lists.skill_list_id`**
  were all renumbered (14632-14731, 4587-4645, and 999-1000 respectively, confirmed free against
  the `old-dsp-reference` snapshot — re-verify against the live DB per the prerequisite above).
  `mob_spawn_points.groupid`, `mob_groups.dropid`, and `mob_pools.skill_list_id` in `sql-dsp/`
  already reference the NEW numbers, not the original Topaz ones — this is already handled in the
  converted output, nothing to do here beyond the live re-check.
- **7 real name/value mismatches** need a decision before applying the affected row (or can be
  applied as-is if the mismatch is judged cosmetic — most look like capitalization/spelling
  variants of the same real entity, not a different entity; one is a real tuning difference):
  - `npc_list` id `17072271`: DSP has `21`, this package has `blank_transformations`
  - `mob_spawn_points` id `17093132`: DSP has `Amnaf_blu`, this package has `Amnaf_BLU`
  - `mob_spawn_points` id `17093133`: DSP has `Amnaf_psycheflayer`, this package has `Amnaf_Psycheflayer`
  - `mob_pools` id `1426`: DSP has `Friar_s_Lantern`, this package has `Friars_Lantern`
  - `mob_pools` id `3223`: DSP has `Puk`, this package has `Puk_WW`
  - `mob_skills` id `2045`: **real tuning difference, not just cosmetic** — DSP has
    `pl_rail_cannon` (mob_anim_id 1373, distance 15.0), this package has `rail_cannon_3`
    (mob_anim_id 1379, distance 20.0). Review which values are actually correct/live-tuned before
    picking a side — don't default to "keep DSP's" the way the cosmetic ones can.
  - `mob_skills` id `2058`: DSP has `pw_homing_missile`, this package has `homing_missile` —
    name-only.

  For each: either (a) skip that one row from `sql-dsp/<table>.sql` and leave DSP's existing row
  as-is (safe default if the entity is functionally the same), or (b) `UPDATE` DSP's existing row's
  `name` to match this package's version (if this package's spelling/capitalization is the one your
  scripts actually reference — check the corresponding `lua-dsp/` file's real name string before
  choosing this).
- **24 `npc_list` + 16 `mob_spawn_points` + 95 `mob_pools` + 280 `mob_skills` ids already exist as
  the SAME entity.** These rows are already present in DSP under the same name/data — re-applying
  `INSERT` for them will fail on the primary key (duplicate) unless you either skip them or use
  `INSERT ... ON DUPLICATE KEY UPDATE` / `REPLACE INTO`. Since these are confirmed the same real
  entity, the simplest safe approach is skipping the already-present rows entirely — check
  `ID_COLLISION_REPORT.md`'s `same_entity` lists (or re-run the checker with `--package` to get the
  current list) and filter `sql-dsp/`'s `INSERT` statements down to only the genuinely-new ids
  before running them, rather than letting a duplicate-key error abort the whole file partway
  through a MyISAM table with no transaction to roll back. `mob_skill_lists` has no indexed
  same-entity check (composite key, not indexed in `ffxi_zone_database.db`) — the 2 renumbered
  ids aside, treat its remaining rows as needing the same duplicate-key care as the others.

## Post-apply verification

1. Re-run `backport_sql_live_check.py --package <this folder>` against the now-updated database —
   every previously-"real collision" id should now show as `same_entity` (present, matching), and
   the renumbered `mob_groups`/`mob_droplist` ranges should show 100%/59 as `same_entity` too
   (they're now the same data you just inserted).
2. Spot-check row counts per table against what `sql-dsp/` actually contains (a partial MyISAM
   failure can succeed on early rows and silently stop partway through the file).
3. Confirm `lua-dsp/` is deployed and the map-server has picked it up (per DSP's own reimport/
   restart convention — not something this session has direct knowledge of for THIS DSP snapshot;
   check with whoever manages the target server).
4. Live-test per `DSP_TRANSITION_PLAN.md` task 12 (floor advance, all 6 objective types, boss
   floors, lamp order, pathos stacking, Runic Disc progress/token payout, Mercenary Rank tie-in
   from Whitegate).

## Reference

- `ID_COLLISION_REPORT.md` — full collision findings and the renumbering rationale.
- `LIVE_DB_COLLISION_CHECK.md` — task 4's live-DB re-verification, run this FIRST.
- `MERGE_DECISIONS.md` — what's hand-merged vs. new in the Lua tree this SQL pairs with.
- `sql-dsp/` — the actual converted SQL files this plan applies, in DSP's real column order.
