-----------------------------------
-- Area: Leujaoam Sanctum (Orichalcum Survey)
--  Mob: Mineral Eater
-----------------------------------
-- Hazard mob spawned by Mining_Point.lua's resolveMining() on the "hazard roll" outcome -- not a
-- mission-progress kill target, just an interruption/aggro mechanic. Script was entirely missing,
-- causing "undefined procedure onMobDeath" whenever one was killed.
-----------------------------------
function onMobSpawn(mob)
end

function onMobDeath(mob, player, isKiller)
end

function onMobDespawn(mob)
end

