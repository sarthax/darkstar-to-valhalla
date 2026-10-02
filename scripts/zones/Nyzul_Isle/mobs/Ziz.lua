-----------------------------------
-- Area: Nyzul Isle
--  Mob: Ziz
-----------------------------------
-- 2026-09-03: real Layout 8 "Birds" enemy pool -- part of the ELIMINATE_ALL_ENEMIES
-- objective, see IDs.lua's mob[51].ENEMY_LAYOUTS. Real, pre-existing mob_spawn_points/mob_groups
-- rows (zone 77) -- just never wired to anything before.
-----------------------------------
-- 2026-09-14: `mixins = {...}` (Topaz's auto-apply table) is dead code in old-dsp-reference --
-- confirmed nothing in this codebase's C++ reads it. Wired to ZizMix via the real
-- onMobSpawn/onMobEngaged callbacks instead -- see scripts/mixins/families/ziz.lua's own header.
require("scripts/mixins/families/ziz")
require("scripts/globals/nyzul")
-----------------------------------
function onMobSpawn(mob)
    ZizMix.onSpawn(mob)
end

function onMobEngaged(mob, target)
    ZizMix.onEngage(mob)
end

function onMobDeath(mob, player, isKiller)
    Nyzul.eliminateAllKill(mob)
    Nyzul.specifiedEnemyKill(mob)
end

