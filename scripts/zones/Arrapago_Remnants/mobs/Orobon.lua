-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Orobon
-----------------------------------
-- 2026-09-04: real fix -- this file was missing entirely (real SQL row, no script -- "undefined
-- procedure" errors on death). Wired to the real temp-chest drop mechanic (scripts/globals/
-- salvage.lua's spawnTempChest), same as this zone's other real trash mobs.
-- 2026-09-07: reverted the manual Lua cell-drop logic added earlier today -- pending a full
-- mob_droplist audit/correction instead of Lua-side addTreasure() calls, which bypass Treasure
-- Hunter and duplicate the native C++ drop-table system this codebase already uses elsewhere in
-- this zone (see chat). This mob currently has NO real dropid wired in mob_groups (dropid=0) --
-- a real fix belongs in SQL, not Lua.
-----------------------------------
require("scripts/globals/salvage")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    salvageUtil.spawnTempChest(mob)
end

