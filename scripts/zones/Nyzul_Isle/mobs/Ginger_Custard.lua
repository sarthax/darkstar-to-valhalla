-----------------------------------
-- Area: Nyzul Isle
--  Mob: Ginger Custard
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Flan family. Real, pre-existing
-- mob_spawn_points row (17092953, mob_groups groupid 138/poolid 1604, zone 77, level 76-77) --
-- just never wired to anything until now.
--
-- 2026-09-04 (later): real BG Wiki-confirmed "healed by light damage" -- corrects this file's
-- earlier "light and fire" guess (fire was never actually on the wiki page, an unverified
-- embellishment from before this pass's real lookup). Implemented via the real, Lua-exposed
-- LIGHT_ABSORB mod (MOD_LIGHT_ABSORB = 465, status.lua:1352) at 100% (matches "healed by",
-- not merely "occasionally absorbs") -- same real mechanism/pattern as
-- Wajaom_Woodlands/mobs/Vulpangue.lua's day-element absorb.
-- 2026-09-07: real fix -- missing `local entity = {}` declaration, same as the other 6
-- Custard-family files -- caused a real load error ("attempt to index global 'entity' (a nil
-- value)"), silently undefining onMobSpawn/onMobDeath for every one of them.
function onMobSpawn(mob)
    mob:addMod(MOD_LIGHT_ABSORB, 100)
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

