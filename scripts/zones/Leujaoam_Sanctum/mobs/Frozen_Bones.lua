-----------------------------------
-- Area: Leujaoam Sanctum (Escort Professor Chanoix)
--  Mob: Frozen Bones
-----------------------------------
-- 2026-08-20: progress hook was on onMobDespawn (fires on ANY despawn, not just death), matching
-- the same bug already fixed for Sagelord Molaal Ja and Lamia No.13 -- moved to onMobDeath gated
-- on a real player kill, and NO_DESPAWN so this can't leash away and be missed instead.
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

