-----------------------------------
-- Area: Ilrusi Atoll (Extermination)
--  Mob: Undead Crab
-----------------------------------
function onMobDeath(mob, player, isKiller)
end

function onMobDespawn(mob)
    local instance = mob:getInstance()

    instance:setProgress(instance:getProgress() + 1)
    -- print(string.format("[EXTERMINATION DEBUG] Undead_Crab %u despawned -> progress + 1 = %d", mob:getID(), instance:getProgress()))
end

