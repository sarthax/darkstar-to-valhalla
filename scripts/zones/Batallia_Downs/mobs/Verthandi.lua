-----------------------------------
--  Area: Batallia Downs
--   NM:  Verthandi (Voidwalker)
-----------------------------------

require("scripts/globals/titles");
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
    player:addTitle(VERTHANDI_ENSNARER);
    voidwalker.onMobDeath(mob, player, isKiller, BLACK_ABYSSITE);
end;
