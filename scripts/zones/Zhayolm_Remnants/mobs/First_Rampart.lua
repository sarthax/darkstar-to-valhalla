-----------------------------------
-- Area: Zhayolm Remnants
--  Mob: First Rampart
-----------------------------------
-- 2026-09-04: real trash mob (name confirmed exact-match against Topaz's own sql/mob_spawn_points.sql).
-- Calls the real temp-chest drop mechanic (scripts/globals/salvage.lua's spawnTempChest), same
-- pattern as Bhaflau/Silver Sea Remnants' own trash mobs.
-----------------------------------
require("scripts/globals/salvage")
local util = require("scripts/zones/Zhayolm_Remnants/zhayolm_util")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    -- fires once per alliance member; only the killer (or the no-owner call) drives progression
    if isKiller or not player then
        if not util.onMobDeath(mob) then
            salvageUtil.spawnTempChest(mob)
        end
    end
end

