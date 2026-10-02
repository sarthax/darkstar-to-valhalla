-----------------------------------
-- Area: Nyzul Isle
--  Mob: Battledressed Chariot
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Chariot family. Real,
-- pre-existing mob_spawn_points row (17092966, mob_groups groupid 151/poolid 365, zone 77, level
-- 76-77) -- just never wired to anything until now.
--
-- 2026-09-04 (later): real user-supplied moveset (ffxiclopedia) -- normal TP attacks are Inertia
-- Stream and Discharge, both already real, unmodified members of the base 'Chariot' skill list
-- (63, alongside diffusion_ray, which the user's description doesn't mention -- left alone rather
-- than excluded, since restricting the normal moveset would need an SQL change we're avoiding);
-- "Can also use the special TP move Discoid at low health."
--
-- Implemented pure-Lua, no SQL changes -- real mob_skill_id 2059 ('discoid', sql/mob_skills.sql)
-- isn't in list 63 at all, but mob:useMobAbility(skillid) bypasses the assigned list entirely, so
-- that doesn't matter. Per user preference to keep changes Lua-only and avoid new/modified shared
-- mob_skill_lists rows (an older sibling DSP server may have its own divergent content --
-- collision risk on port), this force-fires Discoid once at a low-HP threshold, same real
-- getHPP()/onMobFight one-shot-trigger pattern as Balgas_Dais/mobs/Wyrm.lua and
-- Boneyard_Gully/mobs/Tuchulcha.lua -- normal moveset (list 63) is left completely untouched
-- throughout, both before and after. HP threshold (25%) is an undocumented estimate, not a
-- sourced number.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
local DISCOID          = 2059
local LOW_HP_THRESHOLD = 25

local function notBusy(mob)
    local action = mob:getCurrentAction()
    return action ~= ACTION_MOBABILITY_START and action ~= ACTION_MOBABILITY_USING and action ~= ACTION_MOBABILITY_FINISH
end

function onMobSpawn(mob)
    mob:setLocalVar("usedDiscoid", 0)
end

function onMobFight(mob, target)
    if mob:getLocalVar("usedDiscoid") == 0 and mob:getHPP() <= LOW_HP_THRESHOLD and notBusy(mob) then
        mob:useMobAbility(DISCOID)
        mob:setLocalVar("usedDiscoid", 1)
    end
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

