-----------------------------------
-- Area: Nyzul Isle
--  Mob: Kulshedra
-----------------------------------
-- 2026-09-03: real Layout 1 "Aquans" enemy pool -- see Greatclaw.lua's header. Real,
-- pre-existing mob_spawn_points rows (17092641-17092642, mob_groups groupid 4/poolid 2296,
-- zone 77, level 70-72).
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.eliminateAllKill(mob)
    Nyzul.specifiedEnemyKill(mob)
end

