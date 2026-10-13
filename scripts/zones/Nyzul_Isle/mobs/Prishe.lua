-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Prishe (tier 2)
-- Skills: mob_skill_lists 1028 (Nullifying Dropkick, Auroral Uppercut, Knuckle Sandwich) + Banishga III
-- via mob_spell_lists 436. Capture #237 also shows one Hundred Fists mid-fight; trigger HPP is
-- borrowed from the CoP 8-4 Prishe script (real threshold not captured).
-----------------------------------
require("scripts/globals/status")
-----------------------------------
require("scripts/globals/heroines_holdfast")
function onMobSpawn(mob)
    tpz.heroines.armSixNoDespawn(mob)
end

-- 2026-09-29 (user): "7583 is the dialog when players first engage Prishe, not a call and response."
function onMobFight(mob, target)
    tpz.heroines.engageOnce(mob, 7583)
    if mob:getHPP() < 70 and mob:getLocalVar("HF") == 0 then
        mob:useMobAbility(1485)
        mob:setLocalVar("HF", 1)
    end
    -- 2026-09-29: BG Wiki confirms Prishe "can Counter, Hundred Fists and Benediction" -- real ability
    -- id 1486 (1486, status.lua) already exists as a matched pair alongside
    -- HUNDRED_FISTS_PRISHE (1485) and was unused. HP% trigger is NOT captured (same borrowed-threshold
    -- class as HF's 70% above) -- picked lower than HF so it can't preempt it in the same fight.
    if mob:getHPP() < 30 and mob:getLocalVar("BN") == 0 then
        mob:useMobAbility(1486)
        mob:setLocalVar("BN", 1)
    end
end

function onMobDeath(mob, player, isKiller)
    tpz.heroines.mobSay(mob, 7590) -- "Urggghhh! Is dinner...over...already...?" (dialog.yml, matched by text)
    tpz.heroines.onHeroineDeath(mob)
end

