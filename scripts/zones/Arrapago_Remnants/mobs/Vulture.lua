-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Vulture
-----------------------------------
-- 2026-09-04: real fix -- this file was missing entirely (real SQL row, no script -- "undefined
-- procedure" errors on death). Wired to the real temp-chest drop mechanic (scripts/globals/
-- salvage.lua's spawnTempChest), same as this zone's other real trash mobs.
-----------------------------------
require("scripts/globals/salvage")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    salvageUtil.spawnTempChest(mob)
end

