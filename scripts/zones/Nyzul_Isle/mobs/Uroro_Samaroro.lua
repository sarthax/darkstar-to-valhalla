-----------------------------------
-- Area: Nyzul Isle
--  Mob: Uroro Samaroro (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Poroggo family -- BG Wiki: "Casts Water and
-- Waterga for high damage. Frequently and exclusively uses TP move Water Bomb." Real mob_skill_id
-- 1959 ('water_bomb') is already enabled in the base Poroggo skill list (196), same real move and
-- exclusive-trigger pattern already used by Investigation's Uriri_Samariri.lua (its own separate
-- mob_pools row/leaderPool entry -- this is a distinct NM, not a duplicate). The Water/Waterga
-- spellcasting half of the kit is not built -- no established Lua pattern for scripted elemental
-- nuking exists anywhere in this family's scripts (Uriri/Eriri/Oriri all TP-move-only), flagged
-- here rather than invented.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
local WATER_BOMB = 1959

local function notBusy(mob)
    local action = mob:getCurrentAction()
    return action ~= ACTION_MOBABILITY_START and action ~= ACTION_MOBABILITY_USING and action ~= ACTION_MOBABILITY_FINISH
end

function onMobFight(mob, target)
    if mob:getTP() >= 1000 and notBusy(mob) then
        mob:useMobAbility(WATER_BOMB)
    end
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

