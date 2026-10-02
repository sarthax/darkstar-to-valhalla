-----------------------------------
-- Area: Nyzul Isle
--  Mob: Archaic Gears
-----------------------------------
-- 2026-09-03: real Archaic Gear secondary-objective pool -- see Archaic_Gear.lua's header. Real,
-- pre-existing mob_spawn_points rows (17092919-17092923, mob_groups groupid 128/poolid 219,
-- zone 77, level 66-68), of which only GEAR_OFFSET+5..+7 (17092919-17092921) are ever spawned
-- (per LSB's own pTableFloorRandomEntities[17] slice). Same hooks as Archaic_Gear.lua.
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

