-----------------------------------
-- Area: Nyzul Isle
--  Mob: Greatclaw
-----------------------------------
-- 2026-09-03: real Layout 1 "Aquans" enemy pool (Greatclaw x6, Stygian Pugil x4, Kulshedra x2,
-- per BG Wiki's enemy layout table). Real, pre-existing mob_spawn_points rows (17092631-17092636,
-- mob_groups groupid 2/poolid 1799, zone 77, level 68-70) -- just never wired to anything.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.eliminateAllKill(mob)
    Nyzul.specifiedEnemyKill(mob)
end

