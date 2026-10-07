-----------------------------------
-- Area: Ifrit's Cauldron (205)
--  MOB: Hraun Dragon (Ildebrann's pets, Voidwatch). Summoned/dismissed by Ildebrann.lua. [F]
-----------------------------------
require("scripts/globals/status");

function onMobSpawn(mob)
    mob:setMobMod(MOBMOD_NO_DESPAWN, 1);
end;

function onMobDeath(mob, player, isKiller)
end;
