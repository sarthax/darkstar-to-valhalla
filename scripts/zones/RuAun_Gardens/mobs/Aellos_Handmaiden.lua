-----------------------------------
-- Area: Ru'Aun Gardens
--  MOB: Aello's Handmaiden (Voidwatch adds, 3 per Aello)
-- Spawned/resummoned by Aello's rift spawn and Shrieking Gale (see voidwatch.lua vwAelloResummon).
-----------------------------------

function onMobSpawn(mob)
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1);
end;

function onMobDeath(mob, player, isKiller)
end;
