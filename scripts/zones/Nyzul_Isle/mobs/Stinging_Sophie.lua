-----------------------------------
-- Area: Nyzul Isle
--   NM: Stinging Sophie
-----------------------------------
-- 2026-09-03: real random floor NM (BG Wiki/FFXIclopedia: floor-section 2 pool, Notorious
-- Monsters "summoned by the archaic ramparts"). Real, pre-existing mob_spawn_points row (zone 77)
-- -- just never wired to anything before. Drops a real Armoury Crate 100% of the time and has a
-- real vigil-weapon drop chance in Investigation (assault 51). 2026-09-22: this same script now
-- calls Nyzul.floorNMKillShared, which gives Uncharted (assault 52) a DIFFERENT chance-item --
-- this NM's own real canonical drop from its native zone (see nyzul.lua's unchartedNMDrops table)
-- -- while leaving Investigation's own floorNMKill/vigilWeaponDrop output completely unchanged.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    Nyzul.floorNMKillShared(mob, player)
end

