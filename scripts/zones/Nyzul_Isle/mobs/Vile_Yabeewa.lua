-----------------------------------
-- Area: Nyzul Isle
--  Mob: Vile Yabeewa
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Soulflayer family --
-- user-confirmed real roster. Real, pre-existing mob_spawn_points row (17092949, mob_groups
-- groupid 134/poolid 4234, zone 77, level 76-77) -- just never wired to anything until now.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

