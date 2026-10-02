-----------------------------------
-- Area: Ilrusi Atoll (Extermination)
--  Mob: Carrion Toad
-----------------------------------

-----------------------------------
function onMobDeath(mob, player, isKiller)
end

function onMobDespawn(mob)
    local instance = mob:getInstance()
    local TOAD = GetMobByID(17002544, instance)
    local RAND = math.random(1, 5)
    local alreadySpawned = TOAD:getLocalVar("ToadSpawned")

    if RAND == 1 and alreadySpawned == 0 then
        SpawnMob(17002544, instance)
        TOAD:setLocalVar("ToadSpawned", 1)
        -- print(string.format("[EXTERMINATION DEBUG] Carrion_Toad %u despawned: RAND=%d, ToadSpawned was %d -> TRIGGERED Undead Toad spawn, progress unchanged at %d",
            -- mob:getID(), RAND, alreadySpawned, instance:getProgress()))
    else
        instance:setProgress(instance:getProgress() + 1)
        -- print(string.format("[EXTERMINATION DEBUG] Carrion_Toad %u despawned: RAND=%d, ToadSpawned was %d -> progress + 1 = %d",
            -- mob:getID(), RAND, alreadySpawned, instance:getProgress()))
    end
end

