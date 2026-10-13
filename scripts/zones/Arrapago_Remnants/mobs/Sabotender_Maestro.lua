-----------------------------------
-- Area: Arrapago Remnants
--  Mob: Sabotender Maestro
-----------------------------------
-- 2026-09-04: real fix -- this file was missing entirely (mob_spawn_points.sql has a real row,
-- 17080322, but no script -- "undefined procedure" errors on death/fight). This is the real NM
-- summoned by Archaic_Rampart.lua's onMobFight.
-- 2026-09-07: reverted the manual Lua cell-drop logic added earlier today -- this mob already has
-- a real, non-zero dropid (2139) in mob_groups pointing to a real mob_droplist entry, which the
-- native C++ DropItems()/GetDropList() path already rolls (with real Treasure Hunter support).
-- The Lua addTreasure() calls were stacking a second, TH-blind drop system on top of that --
-- reverted pending a full mob_droplist audit/correction instead (see chat).
-----------------------------------
function onMobDeath(mob, player, isKiller)
end

