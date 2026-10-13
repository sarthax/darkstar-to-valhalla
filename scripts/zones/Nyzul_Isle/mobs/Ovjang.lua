-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Ovjang (tier 3 automaton; both must fall to remove Nashmeira's damage reduction)
-----------------------------------
require("scripts/globals/heroines_holdfast")
-- Real ids per TRUST_Ovjang/1040 (sql/mob_skill_lists.sql)
local SLAPSTICK_ID = 1943
local KNOCKOUT_ID = 2067
local SIXTH_ELEMENT_ID = 3244

function onMobSpawn(mob)
    tpz.heroines.armSixNoDespawn(mob)
end

-- 2026-09-29 (user): 7598 fires as part of the linked tier-3 engage set (see t3Engage); 7615 +
-- the real PUP Overdrive stat block activates once at <=25% HP ("a normal Puppetmaster skill...
-- enumed and exposed in bindings" -- see tpz.heroines.activateOverdrive's header for the real
-- ability/effect ids this is sourced from); 7606 fires once per player Ovjang kills (mob-side
-- isDead() check, no engine hook exists for this -- see sayOnPlayerKill's header).
function onMobFight(mob, target)
    tpz.heroines.t3Engage(mob, target)
    tpz.heroines.activateOverdrive(mob, 7615)
    tpz.heroines.sayOnPlayerKill(mob, target, 7606)
end

-- 2026-09-29 (user): "Slapstick - Earth and Wind, Knockout - Earth and Wind, Sixth Element - Dark
-- and Earth" -- moved here from the shared mobskill scripts (slapstick.lua/knockout.lua/
-- sixth_element.lua), matching Nashmeira.lua's own onMobWeaponSkill precedent for Imperial
-- Authority's dialog: the engine dispatches this mob-local hook (luautils.cpp OnMobWeaponSkill,
-- "Mob Script" block) BEFORE the shared mobskill script, so per-skill dialog lives on the mob
-- itself rather than editing scripts other pools (e.g. the disabled Automaton_Harlequin/
-- Stormwaker families) could someday also use.
function onMobWeaponSkill(target, mob, skill, action)
    local id = skill:getID()
    if id == SLAPSTICK_ID or id == KNOCKOUT_ID then
        local LINES = { 7618, 7619 } -- Wind, Earth
        tpz.heroines.ovjangSpellSay(mob, LINES[math.random(#LINES)])
    elseif id == SIXTH_ELEMENT_ID then
        local LINES = { 7619, 7623 } -- Earth, Dark
        tpz.heroines.ovjangSpellSay(mob, LINES[math.random(#LINES)])
    end
end

function onMobDeath(mob, player, isKiller)
    if mob:getLocalVar("HH_Dismissed") == 1 then
        -- dismissed with Nashmeira, not a kill: no line/counter, but a six-battle death still counts
        if tpz.heroines.isSix(mob) then
            tpz.heroines.onHeroineDeath(mob)
        end
        return
    end
    tpz.heroines.mobSay(mob, 7602)
    local instance = mob:getInstance()
    if instance then
        local var = tpz.heroines.automatonVar(mob)
        instance:setLocalVar(var, instance:getLocalVar(var) + 1)
    end
    -- 2026-09-29: same fix as Mnejing.lua -- the 6th battle's Ovjang death never fed
    -- onHeroineDeath, gated on isSix so the tier-3 pair is unaffected.
    if tpz.heroines.isSix(mob) then
        tpz.heroines.onHeroineDeath(mob)
    end
end

