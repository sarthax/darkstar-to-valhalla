-----------------------------------
-- Area: Nyzul Isle
--  Mob: Shielded Chariot
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Chariot family. Real,
-- pre-existing mob_spawn_points row (17092965, mob_groups groupid 150/poolid 3595, zone 77, level
-- 76-77) -- just never wired to anything until now.
--
-- 2026-09-04 (later): real user-supplied moveset (ffxiclopedia) -- normal TP attacks are Inertia
-- Stream and Discharge, both already real, unmodified members of the base 'Chariot' skill list
-- (63); "Also uses Mortal Revolution at low health: AoE damage + stun + knockback."
--
-- Implemented pure-Lua, no SQL changes -- real mob_skill_id 2057 ('mortal_revolution',
-- sql/mob_skills.sql) isn't in list 63 at all, but mob:useMobAbility(skillid) bypasses the
-- assigned list entirely. Per user preference to keep changes Lua-only and avoid new/modified
-- shared mob_skill_lists rows (an older sibling DSP server may have its own divergent content --
-- collision risk on port), this force-fires Mortal Revolution once at a low-HP threshold, same
-- real getHPP()/onMobFight one-shot-trigger pattern as Balgas_Dais/mobs/Wyrm.lua and
-- Boneyard_Gully/mobs/Tuchulcha.lua ("also uses", not "spams" -- one-shot matches that wording).
-- Normal moveset (list 63) is left untouched throughout. HP threshold (25%) is an undocumented
-- estimate, not a sourced number.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
local MORTAL_REVOLUTION = 2057
local LOW_HP_THRESHOLD  = 25

local function notBusy(mob)
    local action = mob:getCurrentAction()
    return action ~= ACTION_MOBABILITY_START and action ~= ACTION_MOBABILITY_USING and action ~= ACTION_MOBABILITY_FINISH
end

function onMobSpawn(mob)
    mob:setLocalVar("usedMortalRevolution", 0)
end

function onMobFight(mob, target)
    if mob:getLocalVar("usedMortalRevolution") == 0 and mob:getHPP() <= LOW_HP_THRESHOLD and notBusy(mob) then
        mob:useMobAbility(MORTAL_REVOLUTION)
        mob:setLocalVar("usedMortalRevolution", 1)
    end
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

