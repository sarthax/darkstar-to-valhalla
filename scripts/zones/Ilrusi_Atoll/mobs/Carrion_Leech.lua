-----------------------------------
-- Area: Ilrusi Atoll (Extermination)
--  Mob: Carrion Leech
-----------------------------------

-----------------------------------
function onMobDeath(mob, player, isKiller)
end

function onMobDespawn(mob)
    local instance = mob:getInstance()
    local LEECH = GetMobByID(17002542, instance)
    local RAND = math.random(1, 5)
    local alreadySpawned = LEECH:getLocalVar("LeechSpawned")

    if RAND == 1 and alreadySpawned == 0 then
        SpawnMob(17002542, instance)
        LEECH:setLocalVar("LeechSpawned", 1)
        -- print(string.format("[EXTERMINATION DEBUG] Carrion_Leech %u despawned: RAND=%d, LeechSpawned was %d -> TRIGGERED Undead Leech spawn, progress unchanged at %d",
            -- mob:getID(), RAND, alreadySpawned, instance:getProgress()))
    else
        instance:setProgress(instance:getProgress() + 1)
        -- print(string.format("[EXTERMINATION DEBUG] Carrion_Leech %u despawned: RAND=%d, LeechSpawned was %d -> progress + 1 = %d",
            -- mob:getID(), RAND, alreadySpawned, instance:getProgress()))
    end
end

