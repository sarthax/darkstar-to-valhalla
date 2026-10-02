-----------------------------------
-- Area: Nyzul Isle
--  Mob: Stygian Pugil
-----------------------------------
-- 2026-09-03: real Layout 1 "Aquans" enemy pool -- see Greatclaw.lua's header. Real,
-- pre-existing mob_spawn_points rows (17092637-17092640, mob_groups groupid 3/poolid 3803,
-- zone 77, level 66-68).
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.eliminateAllKill(mob)
    Nyzul.specifiedEnemyKill(mob)
end

