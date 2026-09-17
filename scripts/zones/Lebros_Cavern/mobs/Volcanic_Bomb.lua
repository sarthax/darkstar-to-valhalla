-----------------------------------
-- Area: Lebros Cavern (Excavation Duty)
--  Mob: Volcanic Bomb
-----------------------------------
-- File was missing entirely -- the engine calls onMobDeath on every mob death regardless of
-- script content, so a missing file (not just an empty one) throws "undefined procedure onMobDeath".
-- No special on-death behavior is confirmed for this mob (unlike Qiqirn_Ceramist's Qiqirn Mine drop),
-- so this is a plain stub matching the other unscripted-behavior mobs in this zone.
-----------------------------------
function onMobSpawn(mob)
end

function onMobDeath(mob, player, isKiller)
end

function onMobDespawn(mob)
end

