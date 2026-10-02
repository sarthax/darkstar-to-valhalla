-----------------------------------
-- Area: Nyzul Isle
--  Mob: Carmine Eruca
-----------------------------------
-- 2026-09-03: real Layout 5 "Vermin" enemy pool -- part of the ELIMINATE_ALL_ENEMIES
-- objective, see IDs.lua's mob[51].ENEMY_LAYOUTS. Real, pre-existing mob_spawn_points/mob_groups
-- rows (zone 77) -- just never wired to anything before.
-----------------------------------
-- 2026-09-14: `mixins = {...}` (Topaz's auto-apply table) is dead code in old-dsp-reference --
-- confirmed nothing in this codebase's C++ reads it. Wired to EruMix via the real
-- onMobSpawn/onMobEngaged/onMobDisengage callbacks instead -- see
-- scripts/mixins/families/eruca.lua's own header.
require("scripts/mixins/families/eruca")
require("scripts/globals/nyzul")
-----------------------------------
function onMobSpawn(mob)
    EruMix.onSpawn(mob)
end

function onMobEngaged(mob, target)
    EruMix.onEngage(mob)
end

function onMobDisengage(mob)
    EruMix.onDisengage(mob)
end

function onMobDeath(mob, player, isKiller)
    Nyzul.eliminateAllKill(mob)
    Nyzul.specifiedEnemyKill(mob)
end

