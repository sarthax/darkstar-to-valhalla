-----------------------------------
-- Area: Nyzul Isle
--  Mob: Pistolium Chariot (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Chariot family -- BG Wiki: "Uses standard
-- Chariot TP moves and Homing Missile." Same real mob_skill_id 2058 ('homing_missile') and
-- repeated low-HP trigger pattern already used by Investigation's Long-Gunned_Chariot.lua (its own
-- separate mob_pools row/leaderPool entry -- this is a distinct NM, not a duplicate).
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
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

