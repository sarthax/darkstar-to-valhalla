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
