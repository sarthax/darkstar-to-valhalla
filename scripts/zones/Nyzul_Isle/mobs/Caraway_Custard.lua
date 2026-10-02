-----------------------------------
-- Area: Nyzul Isle
--  Mob: Caraway Custard
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Flan family. Real, pre-existing
-- mob_spawn_points row (17092959, mob_groups groupid 144/poolid 635, zone 77, level 76-77) -- just
-- never wired to anything until now.
--
-- 2026-09-04 (later): real BG Wiki text (user-supplied, page itself flags "Verification Needed" --
-- implemented anyway per user instruction, caveat noted): "Absorbs all Fire elemental attacks,
-- including skillchain damage (eg. Fusion)." Implemented via the real, Lua-exposed FIRE_ABSORB mod
-- (MOD_FIRE_ABSORB = 459, status.lua:1346) at 100% -- the engine's MagicDmgTaken absorb check
-- (battleutils.cpp:4977-5003) applies to elemental-typed damage generally, which should already
-- cover elemental skillchain damage without any extra Lua.
-- 2026-09-07: real fix -- missing `local entity = {}` declaration (same bug across all
-- Custard-family files) -- caused a real load error, silently undefining this file's hooks.
function onMobSpawn(mob)
    mob:addMod(MOD_FIRE_ABSORB, 100)
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

