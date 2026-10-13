-----------------------------------
-- Area: Nyzul Isle
--  Mob: Nukku (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Imp family -- BG Wiki: "Only TP move used
-- is Grating Tantara (amnesia/AoE damage)." sql/mob_skills.sql has two real entries sharing the
-- same animation id (1181): 1709 'abrasive_tantara' (enabled, already in the base Imp skill list
-- 165, already used by Investigation's Mokke.lua) and 2003 'grating_tantara' (commented out/
-- disabled in this codebase). Since both map to the same real animation, this uses the already-
-- enabled 1709 rather than enabling a new shared mob_skills row (same "avoid new shared-table
-- changes, older sibling DSP server may diverge" rule applied throughout this item) --
-- mechanically identical to the wiki's described move, same as Mokke's precedent.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
local ABRASIVE_TANTARA = 1709 -- shares animation 1181 with the disabled 'grating_tantara' (2003)

local function notBusy(mob)
    local action = mob:getCurrentAction()
    return action ~= ACTION_MOBABILITY_START and action ~= ACTION_MOBABILITY_USING and action ~= ACTION_MOBABILITY_FINISH
end

function onMobFight(mob, target)
    if mob:getTP() >= 1000 and notBusy(mob) then
        mob:useMobAbility(ABRASIVE_TANTARA)
    end
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

