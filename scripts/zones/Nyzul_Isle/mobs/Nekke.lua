-----------------------------------
-- Area: Nyzul Isle
--  Mob: Nekke (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Imp family -- BG Wiki: "Frequently and
-- exclusively uses Bugle Call and Frenetic Rip." Only 'frenetic_rip' (1711) is enabled/present in
-- the base Imp skill list (165) in this codebase; 'bugle_call' (1712, sql/mob_skills.sql) is
-- commented out/disabled -- flagged rather than silently dropped or enabled via a new shared-table
-- change (same "avoid new shared mob_skills/mob_skill_lists rows" rule applied throughout this
-- item). This mob therefore force-fires only the real, already-enabled Frenetic Rip; Bugle Call is
-- unbuilt pending either a confirmed-safe shared SQL change or a per-mob alternative the engine
-- doesn't currently expose.
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
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

