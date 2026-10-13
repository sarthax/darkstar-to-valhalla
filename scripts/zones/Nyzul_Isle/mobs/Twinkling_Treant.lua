-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Twinkling Treant (tier 2/Prishe-floor lamp trigger, paired with Gigantoad). See
--  Gigantoad.lua for the full random-key mechanic note. Confirmed killed live in the capture
--  (CapLog 23:36:16, HP 3687-5571, est 4665; look 00008501, lvl 99).
--  2026-09-29: real cause of "not in the level" was mob_groups 311 having poolid 0 / level 0 (no
--  mob_pools row = no model/stats). Fixed by mob_pools 7056 + mob_groups 311 update.
-----------------------------------
require("scripts/globals/heroines_holdfast")
-----------------------------------
local CANDIDATES = { 17093179, 17093180 } -- Gigantoad, Twinkling Treant

function onMobDeath(mob, player, isKiller)
    tpz.heroines.randomKeyDeath(mob, "Prishe_Key", CANDIDATES, 2)
end

