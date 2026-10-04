-----------------------------------
-- Area: Nyzul Isle
--  Mob: Bellum Chariot (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Chariot family -- BG Wiki: "Uses standard
-- Chariot TP moves and Discoid." Same real mob_skill_id 2059 ('discoid') and one-shot low-HP
-- trigger pattern already used by Investigation's Battledressed_Chariot.lua (its own separate
-- mob_pools row/leaderPool entry -- this is a distinct NM, not a duplicate).
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
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

