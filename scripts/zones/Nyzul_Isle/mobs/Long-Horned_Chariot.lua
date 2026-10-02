-----------------------------------
-- Area: Nyzul Isle
--  Mob: Long-Horned Chariot
-----------------------------------
-- 2026-09-04: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Chariot family. Real,
-- pre-existing mob_spawn_points row (17092968, mob_groups groupid 153/poolid 2435, zone 77, level
-- 76-77) -- just never wired to anything until now.
--
-- 2026-09-04 (later): real user-supplied moveset (ffxiclopedia) -- normal TP attacks are Inertia
-- Stream and Discharge, both already real, unmodified members of the base 'Chariot' skill list
-- (63); "When it is close to dying, this one seems to use Brainjack often" (single-target Charm +
-- ~25 HP/tick DoT, 90s).
--
-- Implemented pure-Lua, no SQL changes -- real mob_skill_id 2060 ('brainjack', sql/mob_skills.sql)
-- isn't in list 63 at all, but mob:useMobAbility(skillid) bypasses the assigned list entirely. Per
-- user preference to keep changes Lua-only and avoid new/modified shared mob_skill_lists rows (an
-- older sibling DSP server may have its own divergent content -- collision risk on port), this
-- force-fires Brainjack on a 50% roll each ready-check once past a low-HP threshold ("often", a
-- middle ground between Long-Gunned's guaranteed spam and Battledressed/Shielded's one-shot --
-- the 50% figure is an undocumented estimate, not a sourced rate), at the same notBusy()+TP-ready
-- gate used throughout; the other 50% of ready-checks fall through to the engine's own normal AI.
-- Normal moveset (list 63) is left untouched throughout. HP threshold (15%) is an undocumented
-- estimate matching "close to dying".
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
local BRAINJACK         = 2060
local LOW_HP_THRESHOLD  = 15
local BRAINJACK_PERCENT = 50

local function notBusy(mob)
    local action = mob:getCurrentAction()
    return action ~= ACTION_MOBABILITY_START and action ~= ACTION_MOBABILITY_USING and action ~= ACTION_MOBABILITY_FINISH
end

function onMobFight(mob, target)
    if
        mob:getHPP() <= LOW_HP_THRESHOLD and
        mob:getTP() >= 1000 and
        notBusy(mob) and
        math.random(1, 100) <= BRAINJACK_PERCENT
    then
        mob:useMobAbility(BRAINJACK)
    end
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

