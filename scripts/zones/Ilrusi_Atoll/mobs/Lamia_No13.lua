-----------------------------------
-- Area: Ilrusi Atoll (Lamia No.13)
--  Mob: Lamia No.13
-----------------------------------
-- Simple kill-target mission (per Solo Assault Guide by Korvana: "Kill Lamia No.13. Locate her
-- on Wide Scan.").
-- 2026-08-19, user-reported: she stays at a static location instead of wandering the whole map.
-- Root cause: MOBMOD_ROAM_DISTANCE (src/map/mob_modifier.h:62, stored in tenths of a yalm,
-- src/map/entities/mobentity.cpp:483) was never set anywhere -- mob_pools carries no such field,
-- it's Lua-only, and it defaults to 0 (zero roam radius) if unset, matching the reported symptom
-- exactly. Set to an estimated 500-yalm radius (5000 stored units) -- not measured against the
-- real zone/instance dimensions, worth tuning after a live test.
-- 2026-08-19 (later), user-reported: aggroing her, running away, then coming back found her
-- despawned and the mission already marked complete -- without ever killing her. Root cause: her
-- new 500-yalm roam radius (above) let her wander far enough from spawn to leash and despawn
-- (CMobController checks IsFarFromHome(), mob_controller.cpp:792) after losing aggro. Her death is
-- this mission's win condition, so per user direction the real fix is to stop her from despawning
-- at all -- same MOBMOD_NO_DESPAWN precedent already used for Imperial Agent Rescue's Warders
-- (Mamool_Ja_Warder.lua), rather than reworking the despawn mechanic itself (that's normal,
-- intended behavior for ordinary respawning mobs -- Assault objective mobs are the exception).
-- Also hardened the progress hook itself as a safety net: moved from onMobDespawn (fires on ANY
-- despawn per its own doc comment, "death not assured" -- luautils.h:241) to onMobDeath, gated on
-- a real killer being present.
-----------------------------------
function onMobSpawn(mob)
    mob:setMobMod(MOBMOD_ROAM_DISTANCE, 5000)
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

