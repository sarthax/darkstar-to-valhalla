-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Warder Partisan, one of 6 Warder-class random-key candidates. See Warder_Liberator.lua
--  for the full mechanic note and zero-pos caveat.
-----------------------------------
require("scripts/globals/heroines_holdfast")
-----------------------------------
local CANDIDATES = { 17093250, 17093251, 17093252, 17093253, 17093254, 17093255 }

function onMobDeath(mob, player, isKiller)
    tpz.heroines.randomKeyDeath(mob, "Lilisette_Key", CANDIDATES, 4)
end

