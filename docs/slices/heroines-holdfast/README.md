# Heroines' Holdfast (instance 80)

Nyzul_Isle instance, six battles, cheerleader NPCs, Mumor/Nashmeira/Mnejing/Ovjang fights.

Contents: `scripts/globals/heroines_holdfast.lua`, `Nyzul_Isle/instances/heroines_holdfast.lua`, Nyzul_Isle mobs/npcs
(identical to those on feature/nyzul-investigation), ~28 mobskills, spells fire_v/blizzard_v/aero_v,
engine: `sendEntityEmote` (char_emotion packet + lua binding), `OnPlayerEmote` hook (+ `player.lua onPlayerEmote`).
Requires `base/debug-print` (merged here). SQL: `sql/slices/heroines-holdfast/` — apply in the order listed in
BLOCKERS_FOR_REVIEW.md, then rebuild C++ and restart map-server. See TEST_PLAN.md. Emote C++ is syntax-checked only.
