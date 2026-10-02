-----------------------------------
-- Area: Nyzul Isle
--  Mob: Friars Lantern
-----------------------------------
-- 2026-09-03: real Layout 3 "Arcana" enemy pool -- part of the ELIMINATE_ALL_ENEMIES
-- objective, see IDs.lua's mob[51].ENEMY_LAYOUTS. Real, pre-existing mob_spawn_points/mob_groups
-- rows (zone 77) -- just never wired to anything before.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.eliminateAllKill(mob)
    Nyzul.specifiedEnemyKill(mob)
end

