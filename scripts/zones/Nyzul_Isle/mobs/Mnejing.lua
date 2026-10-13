-----------------------------------
-- Area: Nyzul Isle (Heroines' Holdfast)
--  Mob: Mnejing (tier 3 automaton; both must fall to remove Nashmeira's damage reduction)
-----------------------------------
require("scripts/globals/heroines_holdfast")
-- Real ids per Mnejing_HH/1151 (sql/mob_skill_lists.sql); Shield Bash/Provoke/Flashbulb/
-- Disruptor are her 4 dialog-bearing skills. String Clipper(1941)/String Shredder(2743)/
-- Chimera Ripper(1940) are also real/usable but have no confirmed elemental dialog line.
local SHIELD_BASH_ID = 1944
local PROVOKE_ID = 1945
local FLASHBULB_ID = 1947
local DISRUPTOR_ID = 2747

function onMobSpawn(mob)
    tpz.heroines.armSixNoDespawn(mob)
    -- 2026-09-29 (user): "Innate -37.5% Damage Taken trait." Always-on for her whole fight, unlike
    -- Nashmeira's -50% DMG-taken mod (MOD_DMG, -5000 in Nashmeira.lua), which is conditional
    -- and removed once 2 automatons die. -3750 on the same mod scale = -37.5%. Never removed.
    mob:addMod(MOD_DMG, -3750)
end

-- 2026-09-29 (user): 7597 fires as part of the linked tier-3 engage set (see t3Engage); 7624 +
-- the real PUP Overdrive stat block activates once at <=25% HP (see
-- tpz.heroines.activateOverdrive's header); 7605 fires once per player Mnejing kills (mob-side
-- isDead() check -- see sayOnPlayerKill's header).
function onMobFight(mob, target)
    tpz.heroines.t3Engage(mob, target)
    tpz.heroines.activateOverdrive(mob, 7624)
    tpz.heroines.sayOnPlayerKill(mob, target, 7605)
end

-- 2026-09-29 (user): Flashbulb(Light)/Provoke(Fire)/Shield Bash(Earth)/Disruptor(Dark) dialog --
-- moved here from the shared mobskill scripts (flashbulb.lua/provoke.lua/shield_bash.lua/
-- disruptor.lua), matching Nashmeira.lua's own onMobWeaponSkill precedent: the engine dispatches
-- this mob-local hook (luautils.cpp OnMobWeaponSkill, "Mob Script" block) BEFORE the shared
-- mobskill script, so per-skill dialog lives on the mob itself rather than editing scripts other
-- pools (e.g. the disabled Automaton_Harlequin/Stormwaker families) could someday also use.
-- String Clipper/String Shredder/Chimera Ripper get no dialog line here (no confirmed element).
function onMobWeaponSkill(target, mob, skill, action)
    local id = skill:getID()
    if id == PROVOKE_ID then
        tpz.heroines.mnejingSay(mob, 7607) -- Fire
    elseif id == SHIELD_BASH_ID then
        tpz.heroines.mnejingSay(mob, 7610) -- Earth
    elseif id == FLASHBULB_ID then
        tpz.heroines.mnejingSay(mob, 7613) -- Light
    elseif id == DISRUPTOR_ID then
        tpz.heroines.mnejingSay(mob, 7614) -- Dark
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
    tpz.heroines.mobSay(mob, 7603)
    local instance = mob:getInstance()
    if instance then
        local var = tpz.heroines.automatonVar(mob)
        instance:setLocalVar(var, instance:getLocalVar(var) + 1)
    end
    -- 2026-09-29: the 6th battle's Mnejing/Ovjang deaths never fed onHeroineDeath at all (tier-3
    -- only counted them toward the damage-reduction var above) -- gated on isSix so the tier-3
    -- pair (not part of the SIX_HEROINES_NEEDED count) is unaffected.
    if tpz.heroines.isSix(mob) then
        tpz.heroines.onHeroineDeath(mob)
    end
end

