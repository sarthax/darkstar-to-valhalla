-----------------------------------
-- Area: Nyzul Isle
--  Mob: Anise Custard
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Flan family. Real, pre-existing
-- mob_spawn_points row (17092954, mob_groups groupid 139/poolid 159, zone 77, level 76-77) -- just
-- never wired to anything until now.
--
-- 2026-09-04 (later): real BG Wiki-confirmed "healed by ice damage". Implemented via the real,
-- Lua-exposed ICE_ABSORB mod (MOD_ICE_ABSORB = 460, status.lua:1347) at 100% (matches "healed
-- by", not merely "occasionally absorbs").
-- 2026-09-07: real fix -- missing `local entity = {}` declaration (same bug across all 7
-- Custard-family files) -- caused a real load error, silently undefining this file's hooks.
function onMobSpawn(mob)
    mob:addMod(MOD_ICE_ABSORB, 100)
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

