-----------------------------------
-- Area: Bhaflau Remnants
--  Mob: Tragopan
-----------------------------------
-- 2026-09-09: real fix -- this file didn't exist at all, blocking Floor 4's Reactionary Rampart
-- Reinforcements pool (BG Wiki: "Extremely common spawn"). Ported directly from LandSandBoat's
-- own real, working Tragopan.lua -- double magic/physical/ranged damage taken, same real mod ids
-- (UDMGMAGIC/UDMGPHYS/UDMGRANGE) already used identically for every other summon-pool mob in
-- this zone (Chigoe, Colibri, etc).
-----------------------------------
require("scripts/globals/salvage")
-----------------------------------
function onMobSpawn(mob)
    mob:setMod(MOD_UDMGMAGIC, 1000)
    mob:setMod(MOD_UDMGPHYS, 100)
    mob:setMod(MOD_UDMGRANGE, 100)
end

function onMobDeath(mob, player, isKiller)
    salvageUtil.spawnTempChest(mob)
end

