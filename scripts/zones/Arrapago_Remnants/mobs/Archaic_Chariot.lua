-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Archaic Chariot
-----------------------------------
-- 2026-09-04: real fix -- this file was missing entirely (real SQL row, no script -- "undefined
-- procedure" errors on death). Wired to the real temp-chest drop mechanic (scripts/globals/
-- salvage.lua's spawnTempChest), same as this zone's other real trash mobs.
-- 2026-09-07: reverted the manual Lua cell-drop/rare-armor logic added earlier today -- this mob
-- already has a real, non-zero dropid (151) in mob_groups pointing to a real mob_droplist entry,
-- which the native C++ DropItems()/GetDropList() path already rolls (with real Treasure Hunter
-- support). The Lua addTreasure() calls were stacking a second, TH-blind drop system on top of
-- that -- reverted pending a full mob_droplist audit/correction instead (see chat). Note: that
-- existing mob_droplist row (151) itself may have the same base-zone-vs-Remnants-II conflation
-- problem (it currently includes Piece of Alexandrite/Cotton Coin Purse) -- flagged for the same
-- audit, not fixed here.
-----------------------------------
require("scripts/globals/salvage")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    salvageUtil.spawnTempChest(mob)
end

