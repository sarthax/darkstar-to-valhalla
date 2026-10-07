# Phase 1 steps 7 & 9 — DSP Abyssea precedent + spawn mechanism (2026-10-06)
[V] = read directly in `D:\Claude\dsp-master` this session. Recommendation items are proposals for Phase 2, not decisions.

## Reusable precedent in DSP [V]
| Voidwatch need | DSP precedent | Notes |
|---|---|---|
| Voidstone stock (timed, capped, KI-backed) | `scripts/globals/abyssea.lua` `getMaxTravStones`/`getTravStonesTotal`/`spendTravStones` (Traverser Stone KI1-6, cap 3 + abyssites) | same shape as Voidstone KI1-6 (1539-1544), cap 3->6 via periapts; recharge timer 20h needs a char var + timestamp (check how Traverser recharge is done) |
| Open-world NM pop on player action | Abyssea `npcs/qm*.lua`: `SpawnMob(<mobid>):updateClaim(player)` | NM rows live in mob_spawn_points, spawned only by script. Template for Planar Rift -> NM |
| Per-player post-kill loot chest | `abyssea_pyxis.lua` `spawnPyxis(mob,player)` + `findFreePyxis(zoneid)` + `giveReward(npc,player)`; chest NPCs preexist in npc_list (`Sturdy_Pyxis`), claimed from a pool | direct template for **Riftworn_Pyxis** (DSP already has 3/zone rows). Pyxis spec: blue chest confirmed working in-game 2026-10-06 (memory), rest untested |
| Alliance iteration on kill | `abyssea_nm.lua` `DEATH` listener + `killer:getAlliance()` | for pyxis eligibility (only Voidwatcher-status members) |
| Weakness triggers (spells, WS) | mixin `abyssea_nm.lua`: `ENGAGE`, `MAGIC_TAKE`(spell id), `WEAPONSKILL_TAKE`(ws id), local vars for current weakness, `mob:weaknessTrigger(n)` (C++ `mobutils.cpp:1437`) | **mixin is buggy/unfinished** (`getLocalVar("x" + 1)` string+number; TODO messages; "discernment" stubs) — copy the idea, not the code |
| Cruor | Abyssea drop code (charutils) | cruor currency exists; Officer spend/earn path to confirm |
| Temp items | `addTempItem` used in Zone.lua hooks | restore-on-weakness needs per-player temp-item bookkeeping |
| Status 475 | `EFFECT_VOIDWATCHER` enum in status_effect.h + status.lua | enum only, **no behavior** — participation gating must be built (apply on start, remove on range-leave/despawn) |

## Engine listener events available [V] (`triggerListener` in src)
ENGAGE, DISENGAGE, DEATH, SPAWN, DESPAWN, TICK, ATTACK, ATTACKED, MAGIC_TAKE, MAGIC_USE, MAGIC_START, MAGIC_STATE_EXIT, WEAPONSKILL_TAKE, WEAPONSKILL_USE, ABILITY_USE/START/STATE_EXIT, RANGE_START, ITEM_*, EFFECT_GAIN/LOSE, WEATHER_CHANGE, EXPERIENCE_POINTS.
- **Gap to verify:** Voidwatch job-ability and pet/blood-pact/automaton weaknesses. `ABILITY_USE` fires on the *user*; there is no obvious `ABILITY_TAKE` on the mob. Likely solved by registering a player-side listener on Voidwatcher members at battle start, or an engine hook. Needs a quick test, not a guess.
- **Gap:** quest/"examine" Planar Rift menus and stagger (terror 5/20/30 s) / Synchronic Blitz damage tracking have no precedent — design item.
- TP-move timing windows (bonus when weakness hit during mob cast/TP ready) need `MAGIC_START` / mob skill-ready state hooks; check mob-side equivalents.

## Spawn mechanism recommendation (closes OPEN_QUESTIONS Q3, pending user ack)
Use the **Abyssea qm model**, not instances/BCNM:
1. NM mob_groups/mob_spawn_points rows exist (new group ids, see POOL-GROUP-ID-PLAN) with no auto-respawn; never zero-position rows.
2. Planar Rift `onTrade/onTrigger` validates initiator (abyssite tier >= NM tier, voidstone, level 75+), consumes voidstones for alliance, applies Voidwatcher (475) to participants, `SpawnMob(id):updateClaim(player)`, full HP/MP restore, 30-min `TICK`/timer cleanup.
3. NM `DEATH` listener computes alignment -> per-player rewards, spawns Riftworn Pyxis from the pre-placed pool, schedules despawn at 3 min and Rift restore; DESPAWN/ no-hate path clears 475 and refunds voidstones.
4. Use `onInstanceTimeUpdate`-style polling is not available outside instances -> prefer a TICK listener / mob `onMobFight` for the range check, **not** entity:timer closures (stale-capture risk, per memory).
Open: where does one-NM-per-zone concurrency get enforced (3 rifts, 3 pyxis); how existing Abyssea code handles NM already spawned.

## Risks added
- Engine C++ may be needed (mob-side ability-take hook). Rebuild requirement already exists for the Abyssea Lights/Pyxis C++ changes (not yet built) — bundle together.
- Abyssea Pyxis itself is only partially tested; treat it as a template, retest.
