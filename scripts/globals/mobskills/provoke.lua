-----------------------------------
-- Provoke
-----------------------------------
require("scripts/globals/heroines_holdfast")
require("scripts/globals/msg")
require("scripts/globals/status")
-----------------------------------
function onMobSkillCheck(target,mob,skill)
    return 0
end

function onMobWeaponSkill(target, mob, skill)
    -- 2026-09-29 (user): Mnejing's real Provoke ("Automaton's Strobe version") dialog moved to
    -- Mnejing.lua's own entity.onMobWeaponSkill -- shared mobskill scripts like this one shouldn't
    -- carry HH-specific flavor text since other pools (e.g. the disabled Automaton_Harlequin/
    -- Stormwaker families) could reuse this same skill id. See Mnejing.lua for the real wiring.

    target:addEnmity(mob, 1, 1800)
    skill:setMsg(msgBasic.NONE)
    return 0 -- the engine requires a return value (luautils::OnMobWeaponSkill: "1 return expected")
end

