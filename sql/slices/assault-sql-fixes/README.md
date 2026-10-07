# assault-sql-fixes
Import `assault_sql_fixes.sql` (REPLACE statements, safe to re-run). Fixes found by auditing packages against the dev base:
- Lebros Brittle_Rock mob_spawn_points rows are corrupt in base SQL.
- Troll skill list (246) missing mob skill 1747.
- Warhorse_Hoofprint npc_list rows 16986599-601 sit at 0,0,0 in base.
Not shipped (needs in-game decision): mob_pools 5872 (Qiqirn_Mine) differs between package and base.
