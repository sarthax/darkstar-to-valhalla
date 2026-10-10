-----------------------------------
-- Area: Silver Sea Remnants
--   NM: Long-Armed Chariot
-----------------------------------
require("scripts/globals/titles")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    player:addTitle(MOON_CHARIOTEER)
end

