-----------------------------------
-- Area: Nyzul Isle
--   NM: Leaping Lizzy
-----------------------------------
-- 2026-09-03: real random floor NM (BG Wiki/FFXIclopedia: floor-section 1 pool, Notorious
-- Monsters "summoned by the archaic ramparts"). Real, pre-existing mob_spawn_points row (zone 77)
-- -- just never wired to anything before. Drops a real Armoury Crate 100% of the time and has a
-- real vigil-weapon drop chance (Nyzul.floorNMKill, globals/nyzul.lua) -- the wiki's real
-- unique-item/??? appraisal drop is NOT built (see nyzul.lua's dropArmouryCrate header -- Topaz's
-- own appraisal.lua is architecturally incompatible with LSB's auto-appraise model).
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.floorNMKill(mob, player)
end

