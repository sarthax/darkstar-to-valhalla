-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Seasonal Treant
-----------------------------------
-- 2026-09-04: real fix -- this file was missing entirely (real SQL row, no script -- "undefined
-- procedure" errors on death). Wired to the real temp-chest drop mechanic (scripts/globals/
-- salvage.lua's spawnTempChest), same as this zone's other real trash mobs.
-- 2026-09-07: real fix -- confirmed via a live BG Wiki fetch (6F Specific Cell Drops table): this
-- is one of the Rampart-summoned cell-dropping adds, not a temp-chest trash mob -- spawnTempChest's
-- own loot pool is drinks/potions only, no cells at all. Real drops: Pannus Cell, Fractus Cell,
-- Velum Cell.
-- 2026-09-07 (later): reverted the manual Lua cell-drop logic added earlier today -- this mob
-- already has a real, non-zero dropid (1203) in mob_groups pointing to a real mob_droplist entry
-- (shared with Goobbue_Wanderer's own groupid, worth a second look during the audit), which the
-- native C++ DropItems()/GetDropList() path already rolls (with real Treasure Hunter support).
-- The Lua addTreasure() calls were stacking a second, TH-blind drop system on top of that --
-- reverted pending a full mob_droplist audit/correction instead (see chat).
-----------------------------------
require("scripts/globals/salvage")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    salvageUtil.spawnTempChest(mob)
end

