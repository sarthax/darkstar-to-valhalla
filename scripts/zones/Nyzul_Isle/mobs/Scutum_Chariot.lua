-----------------------------------
-- Area: Nyzul Isle
--  Mob: Scutum Chariot (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Chariot family -- BG Wiki: "Uses standard
-- Chariot TP moves and Mortal Revolution." Same real mob_skill_id 2057 ('mortal_revolution') and
-- one-shot low-HP trigger pattern already used by Investigation's Shielded_Chariot.lua (its own
-- separate mob_pools row/leaderPool entry -- this is a distinct NM, not a duplicate).
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
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

