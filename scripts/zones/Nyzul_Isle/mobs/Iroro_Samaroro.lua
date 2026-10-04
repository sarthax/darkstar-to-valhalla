-----------------------------------
-- Area: Nyzul Isle
--  Mob: Iroro Samaroro (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Poroggo family -- BG Wiki: "Frequently and
-- exclusively uses TP move Magic Hammer." Real mob_skill_id 1958 ('magic_hammer') is already
-- enabled in the base Poroggo skill list (196). "Exclusively" built as the same 100%-on-ready-check
-- pattern used throughout this item.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
local MAGIC_HAMMER = 1958

local function notBusy(mob)
    local action = mob:getCurrentAction()
    return action ~= ACTION_MOBABILITY_START and action ~= ACTION_MOBABILITY_USING and action ~= ACTION_MOBABILITY_FINISH
end

function onMobFight(mob, target)
    if mob:getTP() >= 1000 and notBusy(mob) then
        mob:useMobAbility(MAGIC_HAMMER)
    end
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

