-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Miura (tier 3/Nashmeira-floor lamp trigger, paired with Toro). See Toro.lua for the full
--  random-key mechanic note and the floor 3/4 boss-name correction (2026-09-28).
-----------------------------------
require("scripts/globals/heroines_holdfast")
-----------------------------------
local CANDIDATES = { 17093212, 17093213 } -- Toro, Miura

function onMobDeath(mob, player, isKiller)
    tpz.heroines.randomKeyDeath(mob, "Nashmeira_Key", CANDIDATES, 3)
end

