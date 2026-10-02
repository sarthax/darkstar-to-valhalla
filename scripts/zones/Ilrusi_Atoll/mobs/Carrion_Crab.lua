-----------------------------------
-- Area: Ilrusi Atoll (Extermination)
--  Mob: Carrion Crab
-----------------------------------

-----------------------------------
function onMobDeath(mob, player, isKiller)
end

function onMobDespawn(mob)
    local instance = mob:getInstance()
    -- 2026-08-30: Carrion_Crab is a shared real mobname -- Demolition Duty (mission 44) reuses the
    -- same 4 real spawn rows for its own Slapstick mechanic (mobs/Demolition_Automaton.lua), which
    -- has nothing to do with Extermination's UNDEAD_CRAB spawn-chain below. Without this guard,
    -- this despawn handler would fire for a Demolition Duty crab too and crash on the very next
    -- line -- GetMobByID(17002541, instance) returns nil in instance 44 (that mob is
    -- only ever registered to instance 43), and :getLocalVar() on nil errors.
    if not instance or instance:getID() ~= 43 then
        return
    end

    local CRAB = GetMobByID(17002541, instance)
    local RAND = math.random(1, 5)
    local alreadySpawned = CRAB:getLocalVar("CrabSpawned")

    if RAND == 1 and alreadySpawned == 0 then
        SpawnMob(17002541, instance)
        CRAB:setLocalVar("CrabSpawned", 1)
        -- print(string.format("[EXTERMINATION DEBUG] Carrion_Crab %u despawned: RAND=%d, CrabSpawned was %d -> TRIGGERED Undead Crab spawn, progress unchanged at %d",
            -- mob:getID(), RAND, alreadySpawned, instance:getProgress()))
    else
        instance:setProgress(instance:getProgress() + 1)
        -- print(string.format("[EXTERMINATION DEBUG] Carrion_Crab %u despawned: RAND=%d, CrabSpawned was %d -> progress + 1 = %d",
            -- mob:getID(), RAND, alreadySpawned, instance:getProgress()))
    end
end

