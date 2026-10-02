-----------------------------------
-- Area: Nyzul Isle
--  Mob: Archaic Gear
-----------------------------------
-- 2026-09-03: real Archaic Gear secondary-objective pool -- see IDs.lua's mob[51].GEAR_OFFSET
-- header. Real, pre-existing mob_spawn_points rows (17092914-17092918, mob_groups groupid 127/
-- poolid 218, zone 77, level 66-68), of which only GEAR_OFFSET+2..+4 (17092916-17092918) are ever
-- spawned (per LSB's own pTableFloorRandomEntities[17] slice). Wired to the real
-- onGearEngage/onGearDeath hooks (globals/nyzul/pathos.lua) -- AVOID_AGRO penalizes first-hit
-- aggro, DO_NOT_DESTROY penalizes a kill, gated on instance:getLocalVar('gearObjective').
-----------------------------------
require("scripts/globals/nyzul")
require("scripts/globals/nyzul/pathos")
-----------------------------------
function onMobEngaged(mob, target)
    Nyzul.onGearEngage(mob, target)
end

function onMobDeath(mob, player, isKiller, noKiller)
    Nyzul.onGearDeath(mob, player, isKiller, noKiller)
end

