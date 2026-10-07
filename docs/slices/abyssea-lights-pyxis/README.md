# Abyssea Lights + Sturdy Pyxis

Ported from Topaz/LSB into DSP. Full design in the two specs at the repo root:
`ABYSSEA_LIGHTS_BACKPORT_SPEC.md`, `ABYSSEA_PYXIS_BACKPORT_SPEC.md`.

Adds: light accumulation (pearlescent/azure/ruby/amber/golden/silvery/ebon) from kills in Abyssea zones, Sturdy Pyxis chest spawn (blue/red/gold) with the
guessing game, cruor/augment/item drops, the Visitant + resting hooks, and GM commands `!addlights`, `!showlights`, `!resetlights`.

## Contents
- scripts/globals/abyssea_lights.lua, abyssea_pyxis.lua, abyssea_pyxis_augs.lua, abyssea_pyxis_drops.lua
- scripts/commands/{addlights,showlights,resetlights}.lua
- scripts/globals/effects/{visitant,healing}.lua (light hooks)
- scripts/zones/Abyssea-*/npcs/Sturdy_Pyxis.lua (9 zones)
- scripts/globals/mobs.lua: Abyssea hunk in onMobDeathEx (killer rolls lights, non-NM spawns Pyxis)
- Engine (REBUILD REQUIRED): CMobEntity::m_lastKillKind/m_lastKillId (set in magic_state.cpp / weaponskill_state.cpp), luautils onMobDeathEx now passes 6 args,
  CLuaBaseEntity::setNpcFlags.

## Status
Blue chest confirmed working in game 2026-10-06 (awards treasure, can be destroyed for cruor). Everything else is UNTESTED, see TEST_PLAN.md.
Known gaps: pet kills grant no lights/Pyxis; Abyssea TextIDs ids may be +2 off (see textids-sweep branch); no retail NM pop conditions (Valhalla keeps always-up NMs).
