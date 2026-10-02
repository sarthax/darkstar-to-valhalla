-----------------------------------
-- Area: Nyzul Isle
--  Mob: Poroggo Gent
-----------------------------------
-- 2026-09-03: real ELIMINATE_SPECIFIED_ENEMIES family group -- see Heraldic_Imp.lua's header.
-- Real, pre-existing mob_spawn_points rows (17092979-17092983, mob_groups groupid 155/poolid
-- 3181, zone 77, level 76-77).
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.specifiedGroupKill(mob)
end

