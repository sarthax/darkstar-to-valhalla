-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Qutrub
-----------------------------------
-- 2026-09-07: reverted the manual Lua cell-drop logic added earlier today -- pending a full
-- mob_droplist audit/correction instead of Lua-side addTreasure() calls, which bypass Treasure
-- Hunter and duplicate the native C++ drop-table system this codebase already uses elsewhere in
-- this zone (see chat).
-----------------------------------
-----------------------------------
function onMobDeath(mob, player, isKiller)
end

