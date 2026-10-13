-----------------------------------
-- Area: Silver Sea Remnants
--  Mob: Apkallu
-----------------------------------
-- 2026-09-06: real captured id/position (Mission Toolkit capture #113), no Lua script existed
-- for this mob type before -- see scripts/globals/salvage.lua's spawnTempChest comment for why
-- the drop-chest call belongs here rather than in a shared/centralized hook.
-----------------------------------
require("scripts/globals/salvage")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    salvageUtil.spawnTempChest(mob)
end

