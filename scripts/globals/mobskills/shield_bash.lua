-----------------------------------
--  Shield Bash
--
--  Description:  Delivers an attack that can stun the target. Shield required.
--  Type: Physical
--  Range: Melee
-----------------------------------
require("scripts/globals/settings")
require("scripts/globals/status")
require("scripts/globals/monstertpmoves")
require("scripts/globals/heroines_holdfast")
-----------------------------------
function onMobSkillCheck(target, mob, skill)
    return 0
end

function onMobWeaponSkill(target, mob, skill)

    -- 2026-09-29 (user): Mnejing's real Shield Bash dialog moved to Mnejing.lua's own
    -- entity.onMobWeaponSkill -- shared mobskill scripts like this one shouldn't carry HH-specific
    -- flavor text since other pools (e.g. the disabled Automaton_Harlequin/Stormwaker families)
    -- could reuse this same skill id. See Mnejing.lua for the real wiring.

    local numhits = 1
    local accmod = 1
    local dmgmod = 8

    local info = MobPhysicalMove(mob, target, skill, numhits, accmod, dmgmod, TP_DMG_VARIES, 2, 2, 2)
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_BLUNT, info.hitslanded)

    MobStatusEffectMove(mob, target, EFFECT_STUN, 1, 0, 7)

    target:delHP(dmg)
    return dmg

end

