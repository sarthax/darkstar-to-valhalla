-----------------------------------
-- Area: Nyzul Isle
--  Mob: Cinnamon Custard
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Flan family. Real, pre-existing
-- mob_spawn_points row (17092958, mob_groups groupid 143/poolid 728, zone 77, level 76-77) -- just
-- never wired to anything until now.
--
-- 2026-09-04 (later): real BG Wiki-confirmed "healed by water damage". Implemented via the real,
-- Lua-exposed WATER_ABSORB mod (MOD_WATER_ABSORB = 464, status.lua:1351) at 100% (matches
-- "healed by", not merely "occasionally absorbs").
-- 2026-09-07: real fix -- missing `local entity = {}` declaration (same bug across all 7
-- Custard-family files) -- caused a real load error, silently undefining this file's hooks.
function onMobSpawn(mob)
    mob:addMod(MOD_WATER_ABSORB, 100)
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

