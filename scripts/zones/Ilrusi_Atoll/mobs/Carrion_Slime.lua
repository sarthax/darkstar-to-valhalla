-----------------------------------
-- Area: Ilrusi Atoll (Extermination)
--  Mob: Carrion Slime
-----------------------------------

-----------------------------------
function onMobDeath(mob, player, isKiller)
end

function onMobDespawn(mob)
    local instance = mob:getInstance()
    local SLIME = GetMobByID(17002543, instance)
    local RAND = math.random(1, 5)
    local alreadySpawned = SLIME:getLocalVar("SlimeSpawned")

    if RAND == 1 and alreadySpawned == 0 then
        SpawnMob(17002543, instance)
        SLIME:setLocalVar("SlimeSpawned", 1)
        -- print(string.format("[EXTERMINATION DEBUG] Carrion_Slime %u despawned: RAND=%d, SlimeSpawned was %d -> TRIGGERED Undead Slime spawn, progress unchanged at %d",
            -- mob:getID(), RAND, alreadySpawned, instance:getProgress()))
    else
        instance:setProgress(instance:getProgress() + 1)
        -- print(string.format("[EXTERMINATION DEBUG] Carrion_Slime %u despawned: RAND=%d, SlimeSpawned was %d -> progress + 1 = %d",
            -- mob:getID(), RAND, alreadySpawned, instance:getProgress()))
    end
end

