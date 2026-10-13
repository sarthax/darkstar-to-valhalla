-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Warder Vindicator, one of 6 Warder-class random-key candidates. See
--  Warder_Liberator.lua for the full mechanic note. mob_spawn_points 17093253 is at (0,0,0) --
--  needs a real position before this mob will ever spawn (instance_loader.cpp zero-pos exclusion).
-----------------------------------
require("scripts/globals/heroines_holdfast")
-----------------------------------
local CANDIDATES = { 17093250, 17093251, 17093252, 17093253, 17093254, 17093255 }

function onMobDeath(mob, player, isKiller)
    tpz.heroines.randomKeyDeath(mob, "Lilisette_Key", CANDIDATES, 4)
end

