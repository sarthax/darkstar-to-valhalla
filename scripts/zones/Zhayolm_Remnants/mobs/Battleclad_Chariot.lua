-----------------------------------
-- Area: Zhayolm Remnants
--   NM: Battleclad Chariot
-----------------------------------
require("scripts/globals/titles")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    player:addTitle(STAR_CHARIOTEER)
end

