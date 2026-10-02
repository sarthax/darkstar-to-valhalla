-----------------------------------
-- Area: Nyzul Isle
--   NM: Dahak
-----------------------------------
-- 2026-09-03: real, separate from the floor-section NM pool -- LSB's own real 20% bonus spawn
-- tied specifically to the ELIMINATE_ALL_ENEMIES objective (prepareMobs()'s
-- "math.randomInt(1,100) <= 20 -- 20% chance that Dahank will spawn"), using its own real
-- mob_spawn_points row (17092823, NM_OFFSET-1, zone 77) -- not part of IDs.lua's NM_EVEN/NM_ODD
-- section tables. Still counts toward Eliminate and drops a real Armoury Crate/vigil-weapon chance
-- like any other floor NM (Nyzul.floorNMKill).
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.floorNMKill(mob, player)
end

