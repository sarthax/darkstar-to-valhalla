# Nyzul Isle Investigation (Assault 51) - Live Test Plan

Test with `nyzul_alzadaal_undersea_ruins`; `nyzul_isle_uncharted_survey` depends on this package. Docs: `DSP_TRANSITION_PLAN.md`, `SQL_APPLY_PLAN.md`, `ID_COLLISION_REPORT.md`, `LIVE_DB_COLLISION_CHECK.md`.

| # | Step | Expected | Result |
|---|------|----------|--------|
| 1 | Pre-check ID collisions per the collision reports against the target DB | None | |
| 2 | Install in manifest order (engine, SQL incl. instance_list/instance_entities, Lua, navmesh), restart | No errors | |
| 3 | Rytaal (Whitegate) with/without Imperial Army I.D. Tag | Grants tag; `NYZUL_ISLE_ASSAULT_ORDERS` recognized (DSP copy unchanged) | |
| 4 | Enter Assault 51 solo and party | Correct placement, mission text | |
| 5 | Floor 1 | Mobs/NMs spawn, floor clear/advance works | |
| 6 | Floor 2 teleporters | Direction-only; coordinates NOT captured, record behavior | |
| 7 | Floor NM scripts (85) | Each floorNMKillShared NM spawns, drops, counts toward floor | |
| 8 | Floor pools / boss floors | Correct pools, skills, drops | |
| 9 | Timer, party wipe, leave | Clean fail/eject | |
| 10 | Completion and rewards | Points/tokens awarded, exit works | |
| 11 | Lobby/Runic Disc menu, floor generator UI | Not included; confirm absent without errors | |
| 12 | Path of Darkness / Nashmeira Plea | Excluded; confirm unaffected | |
| 13 | Map log | No nil/missing-pool errors | |
| 14 | `!nyzuldebug`, `!nyzulnavsweep` | Use for navmesh/floor-layout diagnostics | |
