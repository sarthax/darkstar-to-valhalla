-----------------------------------
-- Flashbulb
-- Real Automaton attachment skill, mob_skills.sql id 1947. No script existed here before
-- 2026-09-29 -- same class of bug as slapstick.lua/knockout.lua's own headers (luautils::
-- OnMobSkillCheck blocks any skill with no registered script). No real effect/damage data on
-- file for this skill; modelled as a plain enmity-reset move, mirroring provoke.lua's minimal
-- pattern (the only other real automaton attachment skill script in this codebase).
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/globals/msg")
require("scripts/globals/status")
-----------------------------------
function onMobSkillCheck(target, mob, skill)
    return 0
end

function onMobWeaponSkill(target, mob, skill)
    -- 2026-09-29 (user): Mnejing's real Flashbulb dialog moved to Mnejing.lua's own
    -- entity.onMobWeaponSkill -- shared mobskill scripts like this one shouldn't carry HH-specific
    -- flavor text since other pools (e.g. the disabled Automaton_Harlequin/Stormwaker families)
    -- could reuse this same skill id. See Mnejing.lua for the real wiring.

    target:addEnmity(mob, 1, 1800)
    skill:setMsg(msgBasic.NONE)
    return 0 -- the engine requires a return value (luautils::OnMobWeaponSkill: "1 return expected")
end

