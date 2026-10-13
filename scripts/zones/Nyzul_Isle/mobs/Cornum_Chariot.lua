-----------------------------------
-- Area: Nyzul Isle
--  Mob: Cornum Chariot (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Chariot family -- BG Wiki: "Uses standard
-- Chariot TP moves and Brainjack." Same real mob_skill_id 2060 ('brainjack') and 50%-roll low-HP
-- trigger pattern already used by Investigation's Long-Horned_Chariot.lua (its own separate
-- mob_pools row/leaderPool entry -- this is a distinct NM, not a duplicate).
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
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

