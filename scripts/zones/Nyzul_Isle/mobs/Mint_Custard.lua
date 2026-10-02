-----------------------------------
-- Area: Nyzul Isle
--  Mob: Mint Custard
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Flan family. Real, pre-existing
-- mob_spawn_points row (17092957, mob_groups groupid 142/poolid 2676, zone 77, level 76-77) --
-- just never wired to anything until now.
--
-- 2026-09-04 (later): real BG Wiki-confirmed "healed by lightning damage". Implemented via the
-- real, Lua-exposed LTNG_ABSORB mod (MOD_LTNG_ABSORB = 463, status.lua:1350) at 100% (matches
-- "healed by", not merely "occasionally absorbs").
-- 2026-09-07: real fix -- missing `local entity = {}` declaration (same bug across all 7
-- Custard-family files) -- caused a real load error, silently undefining this file's hooks.
function onMobSpawn(mob)
    mob:addMod(MOD_LTNG_ABSORB, 100)
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

