# Nyzul Isle Uncharted Area Survey (Assault 52) - Delta Package

Assault mission 52. DELTA package: contains the 52-specific Lua/SQL (instance script, 5 boss-floor HNMs, 19 leader NMs, Rune of Transfer floor-cap menu, Whitegate reward NPCs, astraria, per-mission charvars/drops). The 85 per-NM scripts that call floorNMKillShared and the shared floor pools live in nyzul_isle_investigation (apply that package first).

## Contents
- `lua/` — 38 Lua scripts
- `sql/` — row-level extracts: mob_spawn_points (5), mob_groups (5), npc_list (by name) (8), instance_list (by instance) (1), instance_entities (by instance) (386)
- (no C++ reference included)
- `navmesh/` — none
- `docs/` — 0 supporting doc(s)

## Deployment notes
1. Apply the C++ engine reference changes to the target engine build and rebuild (one-time, shared across all mission packages).
2. Import sql/*.sql in this order: npc_list, mob_pools, mob_groups, mob_skill_lists, mob_skills, mob_droplist, mob_pets, mob_pool_mods, instance_list, instance_entities.
3. Copy lua/ into the target scripts/ tree at matching relative paths.
4. Copy navmesh/*.nav into the target navmeshes/ directory.
5. Restart/reimport per this codebase own dbtool.py + map-server restart convention (a SQL reimport alone may not apply zone/entity data live).
6. Path of Darkness (mission 58/59) and Nashmeira Plea intentionally excluded - separate missions sharing this zone IDs.lua, not part of Investigation.

## Known open issues / TODOs
- Prerequisite: nyzul_isle_investigation package (shared floor pools, NM scripts, nyzul.lua base).

## Git branch notes
- Built on top of feature/nyzul-investigation (shares nyzul globals, Zone.lua, IDs.lua); import that branch first.
- SQL ships as import scripts in sql/slices/nyzul-uncharted-survey/ (editing has no live effect; import required). Includes haraal_ja_skills_2026-10-03.sql.
