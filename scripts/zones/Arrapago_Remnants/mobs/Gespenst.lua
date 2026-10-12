-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Gespenst
-----------------------------------
-- 2026-09-05: real fix -- this file was missing entirely (real SQL rows across floors 1/3,
-- "undefined procedure onMobDeath" confirmed live) -- no LSB reference either, same shared upstream
-- gap as the other trash mobs fixed earlier this session. Wired to the real temp-chest drop
-- mechanic (scripts/globals/salvage.lua's spawnTempChest), same as this zone's other trash mobs.
-- 2026-09-07: reverted the manual Lua cell-drop logic added earlier today -- pending a full
-- mob_droplist audit/correction instead of Lua-side addTreasure() calls, which bypass Treasure
-- Hunter and duplicate the native C++ drop-table system (see chat).
-----------------------------------
require("scripts/globals/salvage")
-----------------------------------
function onMobDeath(mob, player, isKiller)
    salvageUtil.spawnTempChest(mob)
end

