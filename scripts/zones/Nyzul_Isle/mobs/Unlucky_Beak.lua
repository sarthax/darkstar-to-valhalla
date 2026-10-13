-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Unlucky Beak (tier 1: kill all 3, then speak to Aldo)
-----------------------------------
require("scripts/globals/heroines_holdfast")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    tpz.heroines.trashDrop(mob, player)
    local instance = mob:getInstance()
    if instance then
        instance:setLocalVar("HH_BeaksDead", instance:getLocalVar("HH_BeaksDead") + 1)
    end
end

