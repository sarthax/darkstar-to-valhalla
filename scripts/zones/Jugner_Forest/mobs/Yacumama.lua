-----------------------------------
--  Area: Jugner Forest
--   NM:  Yacumama (Voidwalker)
-----------------------------------

require("scripts/globals/voidwalker");

function onMobSpawn(mob)
    voidwalker.onMobSpawn(mob);
end;

function onMobFight(mob, target)
    voidwalker.onMobFight(mob, target);
end;

function onMobDisengage(mob)
    voidwalker.onMobDisengage(mob);
end;

function onMobDespawn(mob)
    voidwalker.onMobDespawn(mob);
end;

function onMobDeath(mob, player, isKiller)
    voidwalker.onMobDeath(mob, player, isKiller, BLUE_ABYSSITE);
end;
