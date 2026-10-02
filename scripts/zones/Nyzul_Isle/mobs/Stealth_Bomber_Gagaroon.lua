-----------------------------------
-- Area: Nyzul Isle
--  Mob: Stealth Bomber Gagaroon
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Qiqirn family --
-- user-confirmed real roster ("Thief job, runs around dropping bombs" -- a real, but not yet
-- implemented, behavior). Real, pre-existing mob_spawn_points row (17092963, mob_groups groupid
-- 148/poolid 3762, zone 77) -- just never wired to anything until now.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

