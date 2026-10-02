-----------------------------------
-- Area: Nyzul Isle
--   NM: Steelfleece Baldarich
-----------------------------------
-- 2026-09-03: ALSO a real floor-section-4 random floor NM (BG Wiki/FFXIclopedia) -- added
-- Nyzul.floorNMKill alongside the pre-existing real title reward rather than replacing it.
require("scripts/globals/titles")
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    player:addTitle(THE_HORNSPLITTER)
    Nyzul.floorNMKill(mob, player)
end

