# Nyzul Alzadaal Undersea Ruins - Live Test Plan

Zone 72 leads to Nyzul Isle (zone 77). Install and test together with `nyzul_isle_investigation`.

| # | Step | Expected | Result |
|---|------|----------|--------|
| 1 | Import zone 72 SQL (npc_list 3, mob_spawn_points 8, mob_groups 12, mob_pools 12, skills, drops), copy Lua + navmesh, restart | No errors | |
| 2 | Zone in | TextIDs correct, no missing-text errors | |
| 3 | Shahayl NPC | Dialogue/menu works | |
| 4 | `_20c`, `_20d`, `_20m` props | Present, interactable as designed | |
| 5 | The 8 spawn points / 12 mob groups | Mobs spawn, correct pools, drops, skills | |
| 6 | Navmesh | Mobs path correctly | |
| 7 | Path to Nyzul Isle entry | Transition to zone 77 works | |
| 8 | Existing (non-Nyzul) zone behavior | Unchanged | |
