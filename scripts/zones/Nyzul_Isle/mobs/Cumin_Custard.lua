-----------------------------------
-- Area: Nyzul Isle
--  Mob: Cumin Custard
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Flan family. Real, pre-existing
-- mob_spawn_points row (17092955, mob_groups groupid 140/poolid 860, zone 77, level 76-77) -- just
-- never wired to anything until now.
--
-- 2026-09-04 (later): real BG Wiki-confirmed "healed by wind damage". Implemented via the real,
-- Lua-exposed WIND_ABSORB mod (MOD_WIND_ABSORB = 461, status.lua:1348) at 100% (matches
-- "healed by", not merely "occasionally absorbs").
-- 2026-09-07: real fix -- missing `local entity = {}` declaration (same bug across all 7
-- Custard-family files) -- caused a real load error, silently undefining this file's hooks.
function onMobSpawn(mob)
    mob:addMod(MOD_WIND_ABSORB, 100)
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

