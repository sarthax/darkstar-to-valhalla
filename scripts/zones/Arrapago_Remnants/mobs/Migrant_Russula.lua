-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Migrant Russula
-----------------------------------
-- 2026-09-05: real fix -- this file was missing entirely (real SQL rows 17080510/17080511, floor 4
-- north-branch rampart pets) -- confirmed via a full DB-side sweep of every real mobname actually
-- used in zone 74 (joined mob_groups/mob_spawn_points the same way the engine itself resolves zone
-- ownership: mg.zoneid = ((mobid >> 12) & 0xFFF), not a loose id-range grep). Wired to the real
-- temp-chest drop mechanic, same as this zone's other trash mobs.
-- 2026-09-07: reverted the manual Lua cell-drop logic added earlier today -- this mob already has
-- a real, non-zero dropid (1671) in mob_groups pointing to a real mob_droplist entry, which the
-- native C++ DropItems()/GetDropList() path already rolls (with real Treasure Hunter support).
-- The Lua addTreasure() calls were stacking a second, TH-blind drop system on top of that --
-- reverted pending a full mob_droplist audit/correction instead (see chat).
-----------------------------------
require("scripts/globals/salvage")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    salvageUtil.spawnTempChest(mob)
end

