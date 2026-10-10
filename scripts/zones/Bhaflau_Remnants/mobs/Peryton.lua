-----------------------------------
-- Area: Bhaflau Remnants
--  Mob: Peryton
-----------------------------------
-- 2026-09-09: real fix -- this file didn't exist at all. Real id (17084719) already exists in
-- sql/mob_spawn_points.sql -- BG Wiki (Floor 4): "Extremely rare spawn, drops Freya's Jerkin
-- (<100%) and Enlil's Brayettes (<100%)" -- Reactionary Rampart's own real "rarely" NM variant for
-- this floor, same pattern as Gate Widow (Floor 1). Not yet wired into Reactionary_Rampart.lua's
-- RARE_POOLS -- blocked on the same open item as Tragopan (REACTIONARY_RAMPART[4]/
-- DORMANT_RAMPART[4] still have no real confirmed position, and this id itself is still
-- placeholder (0,0,0), excluded from loading by instance_loader.cpp's own zero-position filter --
-- see the topaz_zero_pos_mob_load_exclusion memory note). No drop-chest-only mechanic beyond that
-- confirmed yet.
-----------------------------------
require("scripts/globals/salvage")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    salvageUtil.spawnTempChest(mob)
end

