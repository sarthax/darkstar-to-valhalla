-----------------------------------
-- Area: Nyzul Isle
--  Mob: Mokku
-----------------------------------
-- 2026-09-03: real Enemy Leader (ELIMINATE_ENEMY_LEADER objective) -- BG Wiki: "Only uses
-- Frenetic Rip". Real, pre-existing mob_spawn_points row (17092946, mob_groups groupid 131/poolid
-- 2715, zone 77, level 76-77) -- just never wired to anything until now.
--
-- 2026-09-04: restriction implemented pure-Lua, no SQL changes -- real mob_skill_id 1711
-- ('frenetic_rip', sql/mob_skills.sql) is already in Mokku's base Imp skill list (165/166),
-- unrestricted. Per user preference (2026-09-04) to keep changes Lua-only and avoid new shared
-- mob_skill_lists rows (an older sibling DSP server may have its own divergent content at the same
-- numeric ids -- collision risk on port), this force-uses the one real move directly via
-- mob:useMobAbility(skillid) at the same notBusy()+TP-ready gate that would naturally trigger any
-- TP move. mob_pools.skill_list_id (165) is left untouched.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
local FRENETIC_RIP = 1711

local function notBusy(mob)
    local action = mob:getCurrentAction()
    return action ~= ACTION_MOBABILITY_START and action ~= ACTION_MOBABILITY_USING and action ~= ACTION_MOBABILITY_FINISH
end

function onMobFight(mob, target)
    if mob:getTP() >= 1000 and notBusy(mob) then
        mob:useMobAbility(FRENETIC_RIP)
    end
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

