-----------------------------------
-- Area: Nyzul Isle
--  Mob: Cardamom Custard (Uncharted Area Survey, instance 52, non-boss leader NM)
-----------------------------------
-- Real Enemy Leader (ELIMINATE_ENEMY_LEADER objective), Flan family -- BG Wiki: "Only TP move used
-- is Amorphic Scythe. Has very high defense and reduction to physical damage, takes increased
-- magical damage." Real mob_skill_id 1825 ('amorphic_scythe', sql/mob_skill_lists.sql) is NOT a
-- member of the base Flan skill list (112 -- confirmed, only 1821/1822/1824/1826 are in it), so
-- mob:useMobAbility(skillid) is used to bypass the assigned list entirely, same pattern as
-- Investigation's Mokke.lua single-move-exclusive restriction. Distinct mob_pools row from
-- Investigation's own Custard-family leaders -- not a duplicate. High-def/increased-magic-dmg
-- trait already covered by the base Flan family's stat line, unmodified.
-----------------------------------
require("scripts/globals/nyzul")
-----------------------------------
local AMORPHIC_SCYTHE = 1825

local function notBusy(mob)
    local action = mob:getCurrentAction()
    return action ~= ACTION_MOBABILITY_START and action ~= ACTION_MOBABILITY_USING and action ~= ACTION_MOBABILITY_FINISH
end

function onMobFight(mob, target)
    if mob:getTP() >= 1000 and notBusy(mob) then
        mob:useMobAbility(AMORPHIC_SCYTHE)
    end
end

function onMobDeath(mob, player, isKiller)
    Nyzul.enemyLeaderKill(mob)
    Nyzul.unchartedAlexandriteDrop(player, mob)
    Nyzul.vigilWeaponDrop(player, mob)
end

