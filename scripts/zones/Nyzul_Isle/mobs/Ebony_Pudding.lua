-----------------------------------
-- Area: Nyzul Isle
--  Mob: Ebony Pudding
-----------------------------------
-- 2026-09-03: real ELIMINATE_SPECIFIED_ENEMIES family group -- see Heraldic_Imp.lua's header.
-- Real, pre-existing mob_spawn_points rows (17092984-17092988, mob_groups groupid 156/poolid
-- 1170, zone 77, level 76-77).
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.specifiedGroupKill(mob)
end

