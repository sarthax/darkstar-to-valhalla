-----------------------------------
-- Area: Nyzul Isle
--  Mob: Nokko (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Imp family -- BG Wiki: "Frequently and
-- exclusively uses Stifling Tantara (silence/AoE damage) TP move." sql/mob_skills.sql has two real
-- entries sharing the same animation id (1182): 1710 'deafening_tantara' (enabled, already in the
-- base Imp skill list 165) and 2004 'stifling_tantara' (commented out/disabled in this codebase).
-- Same animation, so this uses the already-enabled 1710 rather than enabling a new shared
-- mob_skills row, mechanically identical to the wiki's described move. "Exclusively" is built as
-- the same 100%-on-ready-check pattern as Uriri_Samariri.lua's "favors... most of the time" --
-- the closest honest, buildable approximation.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
local DEAFENING_TANTARA = 1710 -- shares animation 1182 with the disabled 'stifling_tantara' (2004)

local function notBusy(mob)
    local action = mob:getCurrentAction()
    return action ~= ACTION_MOBABILITY_START and action ~= ACTION_MOBABILITY_USING and action ~= ACTION_MOBABILITY_FINISH
end

function onMobFight(mob, target)
    if mob:getTP() >= 1000 and notBusy(mob) then
        mob:useMobAbility(DEAFENING_TANTARA)
    end
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

