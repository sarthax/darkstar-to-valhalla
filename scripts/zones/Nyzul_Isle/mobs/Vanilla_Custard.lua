-----------------------------------
-- Area: Nyzul Isle
--  Mob: Vanilla Custard
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Flan family. Real, pre-existing
-- mob_spawn_points row (17092960, mob_groups groupid 145/poolid 4200, zone 77, level 76-77) --
-- just never wired to anything until now.
--
-- 2026-09-04 (later): real BG Wiki text (user-supplied): "Absorbs all Dark elemental attacks,
-- including skillchain damage (eg. Darkness)." Implemented via the real, Lua-exposed DARK_ABSORB
-- mod (MOD_DARK_ABSORB = 466, status.lua:1353) at 100% -- the engine's MagicDmgTaken absorb
-- check (battleutils.cpp:4977-5003) applies to elemental-typed damage generally, which should
-- already cover elemental skillchain damage without any extra Lua.
-- 2026-09-07: real fix -- missing `local entity = {}` declaration (same bug across all
-- Custard-family files) -- caused a real load error, silently undefining this file's hooks.
function onMobSpawn(mob)
    mob:addMod(MOD_DARK_ABSORB, 100)
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

