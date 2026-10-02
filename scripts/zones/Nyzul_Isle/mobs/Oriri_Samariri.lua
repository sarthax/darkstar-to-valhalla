-----------------------------------
-- Area: Nyzul Isle
--  Mob: Oriri Samariri
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Poroggo family --
-- user-confirmed real roster. Real, pre-existing mob_spawn_points row (17092952, mob_groups
-- groupid 137/poolid 3053, zone 77, level 76-77) -- just never wired to anything until now.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

