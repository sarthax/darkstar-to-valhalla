-----------------------------------
-- Area: Bhaflau Remnants
--  Mob: Black Pudding
-----------------------------------
-- 2026-09-07: real, pre-existing mob_spawn_points rows (groupid 16/poolid 437, zone 75) --
-- confirmed via BG Wiki's own per-floor roster (Floor 3, South Central area) but never wired
-- into IDs.lua or given a Lua file until now. Same drop-chest pattern as every other regular
-- Bhaflau Remnants mob (see Bifrons.lua/scripts/globals/salvage.lua).
-----------------------------------
require("scripts/globals/salvage")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    salvageUtil.spawnTempChest(mob)
end

