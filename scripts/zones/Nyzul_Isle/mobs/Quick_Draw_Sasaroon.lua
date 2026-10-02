-----------------------------------
-- Area: Nyzul Isle
--  Mob: Quick Draw Sasaroon
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Qiqirn family --
-- user-confirmed real roster ("Ranger job" -- a real, but not yet implemented, movepool
-- restriction). Real, pre-existing mob_spawn_points row (17092964, mob_groups groupid 149/poolid
-- 3288, zone 77) -- just never wired to anything until now.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

