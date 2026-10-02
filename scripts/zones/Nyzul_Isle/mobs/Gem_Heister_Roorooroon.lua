-----------------------------------
-- Area: Nyzul Isle
--  Mob: Gem Heister Roorooroon
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Qiqirn family --
-- user-confirmed real roster ("Thief job, runs around dropping bombs" -- a real, but not yet
-- implemented, behavior; drops the real Qiqirn_Mine prop, IDs.lua's mob[51].QIQIRN_MINE = not
-- wired here). Real, pre-existing mob_spawn_points row (17092961, mob_groups groupid 146/poolid
-- 1490, zone 77, level unset in mob_groups -- dropid 945 already present, not touched) -- just
-- never wired to anything until now.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

