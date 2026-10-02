-----------------------------------
-- Area: Nyzul Isle
--  Mob: Uriri Samariri
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Poroggo family --
-- user-confirmed real roster ("Favors using Water Bomb TP move most of the time"). Real,
-- pre-existing mob_spawn_points row (17092950, mob_groups groupid 135/poolid 4108, zone 77, level
-- 76-77) -- just never wired to anything until now.
--
-- 2026-09-04 (later): implemented pure-Lua, no SQL changes -- real mob_skill_id 1959
-- ('water_bomb', sql/mob_skills.sql) is already in Uriri's base Poroggo skill list (196) alongside
-- magic_hammer/frog_cheer, unrestricted. Per user preference to keep changes Lua-only and avoid
-- new/reused shared mob_skill_lists rows (an older sibling DSP server may have its own divergent
-- content -- collision risk on port), this force-uses the one real move directly via
-- mob:useMobAbility(skillid) at the same notBusy()+TP-ready gate that would naturally trigger any
-- TP move. mob_pools.skill_list_id (196) is left untouched. No weighted/biased-selection
-- mechanism exists in this engine, so "favors...most of the time" is built as exclusive (100%) --
-- the closest honest, buildable approximation without inventing a fake split percentage.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
local WATER_BOMB = 1959

local function notBusy(mob)
    local action = mob:getCurrentAction()
    return action ~= ACTION_MOBABILITY_START and action ~= ACTION_MOBABILITY_USING and action ~= ACTION_MOBABILITY_FINISH
end

function onMobFight(mob, target)
    if mob:getTP() >= 1000 and notBusy(mob) then
        mob:useMobAbility(WATER_BOMB)
    end
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

