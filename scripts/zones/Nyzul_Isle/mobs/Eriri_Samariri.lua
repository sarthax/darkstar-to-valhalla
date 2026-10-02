-----------------------------------
-- Area: Nyzul Isle
--  Mob: Eriri Samariri
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Poroggo family --
-- user-confirmed real roster ("Favors using Frog Song TP move most of the time"). Real,
-- pre-existing mob_spawn_points row (17092951, mob_groups groupid 136/poolid 1254, zone 77, level
-- 76-77) -- just never wired to anything until now.
--
-- 2026-09-04 (later): implemented pure-Lua, no SQL changes -- real mob_skill_id 1957
-- ('frog_song', sql/mob_skills.sql) is a real, pre-existing skill that was never wired into ANY
-- skill list at all (the base Poroggo list 196 only has magic_hammer/water_bomb/frog_cheer). Since
-- this force-uses the move directly via mob:useMobAbility(skillid) (bypasses the assigned skill
-- list entirely), that gap doesn't matter -- the move doesn't need to be in Eriri's list to be
-- used this way. Per user preference to keep changes Lua-only and avoid new shared
-- mob_skill_lists rows, mob_pools.skill_list_id (196) is left untouched. No weighted/biased-
-- selection mechanism exists in this engine, so "favors...most of the time" is built as exclusive
-- (100%) -- the closest honest, buildable approximation without inventing a fake split percentage.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
local FROG_SONG = 1957

local function notBusy(mob)
    local action = mob:getCurrentAction()
    return action ~= ACTION_MOBABILITY_START and action ~= ACTION_MOBABILITY_USING and action ~= ACTION_MOBABILITY_FINISH
end

function onMobFight(mob, target)
    if mob:getTP() >= 1000 and notBusy(mob) then
        mob:useMobAbility(FROG_SONG)
    end
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

