# master-dsp branch status (2026-10-02)

Base: backport-work e69acad3f4 + old-dsp-reference's uncommitted working tree (conf/, win32/, binaries excluded)
+ dsp-fresh items: search-server overflow fix, Nyzul excluded-point getters (floor_layouts/lamps/investigation), warpassault.

Kept as old (fresh is older/upstream): Rytaal.lua, Treasure_Coffer.lua, wamoura_farm_raid.lua, Shared.lua (old's global set{} covers it),
zone_instance.cpp, common.lua, utils.lua, TextIDs files.

NOT merged, needs a source-of-truth decision (compare against the live DB):
- sql/mob_groups.sql: fresh-only 462 groupids, master-only 228 (166 are Nyzul zone 77), 81 rows with differing fields (e.g. dropid, levels).
- sql/mob_spawn_points.sql: 1864 changed rows, fresh-only 203, master-only 358.
- sql/npc_list.sql, mob_pools.sql, mob_skill_lists.sql, mob_skills.sql, instance_list.sql: row-level merge pending.
- Whitegate TextIDs.lua: verify text ids against the client dialog first.

## Resolved 2026-10-02 (live DB audit)
- Live MariaDB `dspdb` (old) and `dspdb_fresh` (backport installed) have identical mob_spawn_points/mob_groups/pools apart from 1 group, 3 spawn rows and
  the Armoury Crate NPCs. dsp-fresh's sql/*.sql were never re-imported (pristine upstream), so old's repaired values ARE the tested state.
  Decision: master's sql/mob_groups.sql, mob_spawn_points.sql, npc_list.sql stay as-is; the groupid repair is documented in
  Topaz-Assault-Backport/dsp-fixes (base_cleanup, mob_spawn_points_groupid_repair).
- _20m.lua taken from the backport package (adds Assault 51/52 check).
- Still unmerged: the 3 Armoury Crate NPCs (17093609-11), mob_group 78, and the Reserve_Draugar z change that exist only in dspdb_fresh
  (their SQL is in the package: sql-dsp/armoury_crate_17093610_2026-09-20.sql).
