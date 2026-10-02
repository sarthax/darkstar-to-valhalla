-----------------------------------
-- Area: Nyzul Isle
--  Mob: Qiqirn Archaeologist
-----------------------------------
-- 2026-09-03: real ELIMINATE_SPECIFIED_ENEMIES family group -- see Heraldic_Imp.lua's header.
-- Real, pre-existing mob_spawn_points rows (17092991-17092993, mob_groups groupid 158/poolid
-- 3245, zone 77, level 76-77).
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.specifiedGroupKill(mob)
end

