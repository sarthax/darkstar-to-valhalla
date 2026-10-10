-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Qiqirn Mine
-- Note: Explosive mine from Qiqrin
-----------------------------------
require("scripts/zones/Arrapago_Remnants/IDs")
require("scripts/globals/status")
-----------------------------------
function onMobSpawn(mob)
    mob:setUnkillable(true)
    mob:hideName(true)
    mob:untargetable(true)
    mob:hideHP(true)
    mob:SetAutoAttackEnabled(false)
    mob:setStatus(STATUS_DISAPPEAR)
    mob:setMobMod(MOBMOD_ALWAYS_AGGRO, 1)
    mob:setMobMod(MOBMOD_NO_MOVE, 1)
    mob:setMobMod(MOBMOD_SIGHT_RANGE, 15)
    mob:setMobMod(MOBMOD_SOUND_RANGE, 15)
end

function onMobDeath(mob, player)
end

