-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Lion (tier 1)
-- Skills come from mob_skill_lists 1022 (Grapeshot, Pirate Pummel, Powder Keg, Walk the Plank);
-- capture #237 shows Powder Keg / Grapeshot / Walk the Plank in use.
-----------------------------------
require("scripts/globals/heroines_holdfast")
function onMobSpawn(mob)
    tpz.heroines.armSixNoDespawn(mob)
end

-- 2026-09-29 (user): "7572 is the dialog when players first engage Lion, not a call and response."
function onMobFight(mob, target)
    tpz.heroines.engageOnce(mob, 7572)
end

function onMobDeath(mob, player, isKiller)
    tpz.heroines.mobSay(mob, 7577)
    tpz.heroines.onHeroineDeath(mob)
end

