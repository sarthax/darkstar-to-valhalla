-----------------------------------
-- Area: Nyzul Isle
--  Mob: Imp
-----------------------------------
-- 2026-09-03: wired into the real Layout 6 "Demons" enemy pool (Imp x10, Psycheflayer x2 --
-- BG Wiki's enemy layout table) -- these 10 real mob_spawn_points rows (17092691-17092700,
-- mob_groups groupid 22/poolid 2065, zone 77, real level 66-68) already existed in this
-- codebase's own SQL, just never wired to anything. onMobDeath now reports the kill to whichever
-- objective is active (currently only ELIMINATE_ALL_ENEMIES is wired in pickSetPoint).
-----------------------------------
-- 2026-09-14: `mixins = {...}` (Topaz's auto-apply table) is dead code in old-dsp-reference --
-- confirmed nothing in this codebase's C++ reads it. Wired to ImpMix.onCriticalHit via the real
-- onCriticalHit(mob) engine callback instead -- see scripts/mixins/families/imp.lua's own header.
require("scripts/mixins/families/imp")
require("scripts/globals/nyzul")
-----------------------------------
function onCriticalHit(mob)
    ImpMix.onCriticalHit(mob)
end

function onMobDeath(mob, player, isKiller)
    Nyzul.eliminateAllKill(mob)
    Nyzul.specifiedEnemyKill(mob)
end

