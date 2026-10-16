-----------------------------------
--  Area: Meriphataud Mountains [S]
--   NM:  Orcus (Voidwalker)
-----------------------------------

require("scripts/globals/voidwalker");
require("scripts/globals/titles");

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
    if (player ~= nil) then player:addTitle(ORCUS_TROPHY_HUNTER); end
    voidwalker.onMobDeath(mob, player, isKiller, BLACK_ABYSSITE);
end;
