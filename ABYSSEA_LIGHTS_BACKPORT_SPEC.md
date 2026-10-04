# Abyssea Lights backport (LSB -> DSP)

Status: code written + Lua syntax-checked + drop logic simulated (lupa) 2026-10-02. NOT built or tested in-game.

## Needs a map-server REBUILD (small C++ change)
- `CMobEntity::m_lastKillKind` (0 melee/none, 1 spell, 2 weaponskill) + `m_lastKillId`: set in `magic_state.cpp` / `weaponskill_state.cpp` when the hit leaves the mob at hp<=0; reset in `Spawn()`.
- `luautils::OnMobDeath` passes both as args 5/6 to `onMobDeathEx` (pcall nargs 4 -> 6). Old 4-arg Lua still works.
- Why: DSP's `isWeaponSkillKill` was dead code (always false), and there is no global listener hook for unscripted mobs.

## Lua
- `scripts/globals/abyssea_lights.lua` - lightInfo tables (all 9 zones, generated from LSB, keyed by numeric zone id), add/reset/display/drop. `ABYSSEA_LIGHTS_DROP_RATE` = 80.
- `mobs.lua` `onMobDeathEx` -> `onAbysseaMobDeath` (killer only; shares to same-zone PC alliance).
- `visitant.lua` onEffectLose resets lights; `healing.lua` onEffectGain shows lights when Visitant.
- GM: `!addlights <type> <n> {player}`, `!resetlights {player}`, `!showlights`.
- Storage: 7 charvars `abysseaPearl/Golden/Silvery/Ebon/Azure/Ruby/Amber`.

## Message ids (client dialog.yml, verified; hardcoded in the module, TextIDs.lua untouched)
- Zones 15,45,132,216,217,218,254: msg 7314/7315, body-emits 7497..7503
- Zones 215,253: msg 7214/7215, body-emits 7397..7403
- Existing DSP Abyssea TextIDs are +2 vs client (e.g. Konschtat STAGGERED=7314 vs client 7316) - separate, untouched pre-existing issue.

## Known limits
- Pet kills never reach `onMobDeathEx` (OnMobDeath only handles a PC killer), so no pet-kill lights.
- Mob names must match DSP mob names (underscored) as in LSB.
- Lights are not yet consumed (NM pop / Atma) - next step.

## Test
1. Rebuild + restart map. `!zone` to an Abyssea zone with Visitant; `!showlights`.
2. `!addlights azure 16` -> body-emits line + totals via `/heal` or `!showlights`.
3. Kill a listed mob by melee/spell/WS; expect pearl/azure/ruby/amber respectively (set rate 100 to test).
4. Lose Visitant -> `!showlights` all 0.
