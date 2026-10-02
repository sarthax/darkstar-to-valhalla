-----------------------------------
-- Area: Mamool Ja Training Grounds (Preemptive Strike)
--  Mob: Mamool Ja Executioner
-----------------------------------
-- 2026-08-19: his death is this mission's win condition, so he must not despawn before being
-- killed -- applied MOBMOD_NO_DESPAWN (same precedent as Imperial Agent Rescue's Warders,
-- Mamool_Ja_Warder.lua) as the real fix, per user direction, rather than reworking the despawn
-- mechanic (normal/intended for ordinary respawning mobs). Also hardened the progress hook as a
-- safety net: moved from onMobDespawn (fires on ANY despawn, not just death) to onMobDeath, gated
-- on a real killer. See Lamia_No13.lua for the full root-cause writeup (same bug, found there
-- first). No behavior change for a real kill.
-----------------------------------
function onMobSpawn(mob)
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1)
end

function onMobDeath(mob, player, isKiller)
    if player then
        local instance = mob:getInstance()
        instance:setProgress(instance:getProgress() + 1)
    end
end

function onMobDespawn(mob)
end

