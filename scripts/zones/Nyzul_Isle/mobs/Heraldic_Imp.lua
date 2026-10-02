-----------------------------------
-- Area: Nyzul Isle
--  Mob: Heraldic Imp
-----------------------------------
-- 2026-09-03: real ELIMINATE_SPECIFIED_ENEMIES family group (2-5 real ToAU-native enemies, per
-- BG Wiki). Real, pre-existing mob_spawn_points rows (17092969-17092973, mob_groups groupid
-- 154/poolid 1933, zone 77, level 76-77) -- just never wired to anything until now.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.specifiedGroupKill(mob)
end

