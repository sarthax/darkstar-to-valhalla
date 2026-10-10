-----------------------------------
-- Area: Arrapago Remnants
--   NM: Armored Chariot
-----------------------------------
require("scripts/globals/titles")
-----------------------------------
-- 2026-09-07: reverted the manual Lua item-drop logic added earlier today -- this mob already has
-- a real, non-zero dropid (171) in mob_groups pointing to a real mob_droplist entry (already
-- containing all 6 real Lv25 armor pieces plus Linen Coin Purse, at rates that look genuinely
-- TH-tiered), which the native C++ DropItems()/GetDropList() path already rolls (with real
-- Treasure Hunter support). The Lua addTreasure() calls were stacking a second, TH-blind drop
-- system on top of that -- reverted pending a full mob_droplist audit/correction instead (see
-- chat).
-----------------------------------
function onMobDeath(mob, player, isKiller)
    player:addTitle(SUN_CHARIOTEER)
end

