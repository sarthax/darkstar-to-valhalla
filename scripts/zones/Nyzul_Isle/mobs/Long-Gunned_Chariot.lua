-----------------------------------
-- Area: Nyzul Isle
--  Mob: Long-Gunned Chariot
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Chariot family. Real,
-- pre-existing mob_spawn_points row (17092967, mob_groups groupid 152/poolid 2434, zone 77, level
-- 76-77) -- just never wired to anything until now.
--
-- 2026-09-04 (later): real user-supplied moveset (ffxiclopedia) -- normal TP attacks are Inertia
-- Stream and Discharge, both already real, unmodified members of the base 'Chariot' skill list
-- (63); "When it is close to dying, it will begin spamming Homing Missile" (90% max HP to one
-- target, 200-300 AoE around it).
--
-- Implemented pure-Lua, no SQL changes -- real mob_skill_id 2058 ('homing_missile',
-- sql/mob_skills.sql) isn't in list 63 at all, but mob:useMobAbility(skillid) bypasses the
-- assigned list entirely. Per user preference to keep changes Lua-only and avoid new/modified
-- shared mob_skill_lists rows (an older sibling DSP server may have its own divergent content --
-- collision risk on port), this force-fires Homing Missile repeatedly (matching "spamming",
-- unlike the other 3 chariots' one-shot additive low-HP move) once past a low-HP threshold, at the
-- same notBusy()+TP-ready gate used throughout. Normal moveset (list 63) is left untouched
-- throughout -- the engine's own AI can still pick Inertia Stream/Discharge/diffusion_ray between
-- Homing Missile casts whenever this check doesn't fire. HP threshold (15%) is an undocumented
-- estimate matching "close to dying".
--
-- NOT implemented: "Only uses Homing Missile while facing the target with hate... turns to face
-- target every 5-20% HP, begins to turn much more quickly around 10-20% HP" -- this needs
-- continuous real-time facing/hate-angle tracking against a specific target, a mechanic this
-- codebase has no established Lua hook for (confirmed via research pass, not found anywhere in
-- scripts/zones/*/mobs/). Flagged here rather than silently dropped or faked.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
local HOMING_MISSILE   = 2058
local LOW_HP_THRESHOLD = 15

local function notBusy(mob)
    local action = mob:getCurrentAction()
    return action ~= ACTION_MOBABILITY_START and action ~= ACTION_MOBABILITY_USING and action ~= ACTION_MOBABILITY_FINISH
end

function onMobFight(mob, target)
    if mob:getHPP() <= LOW_HP_THRESHOLD and mob:getTP() >= 1000 and notBusy(mob) then
        mob:useMobAbility(HOMING_MISSILE)
    end
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

