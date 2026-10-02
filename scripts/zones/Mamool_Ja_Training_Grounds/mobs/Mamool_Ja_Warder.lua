-----------------------------------
-- Area: Mamool Ja Training Grounds (Azure Ailments)
--  Mob: Mamool Ja Warder
-----------------------------------
-- CORRECTED 2026-08-18: this mob type is shared between two missions -- Imperial Agent Rescue
-- (instance 11, real validated gates/Warders kill mechanic -- keep incrementing progress there)
-- and Azure Ailments (instance 19, a disease-vector ambient hazard, NOT a kill objective --
-- instance:getProgress() there now tracks Garjham's distinct-ailment count, see
-- npcs/Garjham.lua, so a stray kill-increment would corrupt it). Guarded by instance id so both
-- missions get the right behavior from the one shared file.
-----------------------------------
function onMobSpawn(mob)
    local instance = mob:getInstance()
    if instance and instance:getID() == 11 then
        -- Imperial Agent Rescue, 2026-08-18: user reported luring a Warder too far from its
        -- spawn point causes it to leash-despawn (engine behavior -- CMobController checks
        -- IsFarFromHome() and despawns unless MOBMOD_NO_DESPAWN is set, mob_controller.cpp:792).
        -- These Warders are now load-bearing for the gate-break mechanic (Firespit/Stave Toss
        -- splash damage, see scripts/globals/mobskills/firespit.lua and stave_toss.lua) -- losing
        -- one to a despawn could strand the mission if no other Warder is left near a gate.
        -- Scoped to instance 11 only; Azure Ailments' ambient-hazard use of this same mob type is
        -- unaffected.
        mob:setMobMod(MOBMOD_NO_DESPAWN, 1)
    end
end

function onMobDeath(mob, player, isKiller)
end

function onMobDespawn(mob)
    local instance = mob:getInstance()
    if instance and instance:getID() == 11 then
        instance:setProgress(instance:getProgress() + 1)
    end
end

