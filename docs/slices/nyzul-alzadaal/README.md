# nyzul_alzadaal_undersea_ruins

Split out of `nyzul_isle_investigation` on 2026-09-21. Alzadaal Undersea Ruins (zone 72) is the zone that leads to Nyzul Isle (zone 77); the changes we made to it are Nyzul-related, so install this package together with `nyzul_isle_investigation`.

Target: DSP. `old-dsp-reference` is the source of truth. `sql-dsp/` has not been row-verified against the live `dspdb`.

## Layout
- `lua-dsp/scripts/zones/Alzadaal_Undersea_Ruins/` -- zone TextIDs and npcs (Shahayl, _20c, _20d, _20m) (moved from the Nyzul package; deploy)
- `sql-dsp/` -- zone 72 rows only (npc_list 3, mob_spawn_points 8, mob_groups 12, mob_pools 12, plus the skill lists, skills and drops used only by those pools). Row-level INSERTs, no DROP TABLE.
- `navmesh/Alzadaal_Undersea_Ruins.nav`
- `archive-topaz/lua/` -- Topaz-format zone scripts (historical, not for deployment)

`sql/*` edits have no live effect until imported into `dspdb`.

## Git branch notes
- Lua here is only the two changed npc scripts (Shahayl, _20m); _20c/_20d and the zone TextIDs in the package are unchanged vs the base or covered by textids-sweep.
- SQL is import scripts in sql/slices/nyzul-alzadaal/. Navmesh .nav is not in git (take from package).
