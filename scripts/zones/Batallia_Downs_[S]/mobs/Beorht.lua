-----------------------------------
--  Area: Batallia Downs [S]
--   NM:  Beorht (Voidwalker)
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
    voidwalker.onMobDeath(mob, player, isKiller, COLORFUL_ABYSSITE);
end;
