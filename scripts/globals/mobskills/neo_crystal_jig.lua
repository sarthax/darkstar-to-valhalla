-----------------------------------
-- Neo Crystal Jig (Mumor, Heroines' Holdfast)
-- Skill id/animation from capture #237. Damage/effect below is a PLACEHOLDER: capture msg 185; plain AoE hit.
-----------------------------------
require("scripts/globals/monstertpmoves")
require("scripts/globals/heroines_holdfast")
require("scripts/globals/settings")
require("scripts/globals/status")
-----------------------------------
function onMobSkillCheck(target, mob, skill)
    return 0
end

function onMobWeaponSkill(target, mob, skill)
    -- 2026-09-27: wired the "...Jig!" callout, see tpz.heroines.MUMOR_LINES (globals/heroines_holdfast.lua)
    tpz.heroines.mumorSay(mob, "neo_crystal_jig")
    MobPhysicalStatusEffectMove(mob, target, skill, EFFECT_ATTACK_DOWN, 25, 0, 30) -- wiki
    MobPhysicalStatusEffectMove(mob, target, skill, EFFECT_MAGIC_ATK_DOWN, 25, 0, 30) -- wiki
    local dmg = tpz.heroines.flatDamage(mob, target, skill, 6, 60, MOBSKILL_PHYSICAL, MOBPARAM_BLUNT)
    return dmg
end

-- Damage tuned 2026-09-26 from capture #237: Mumor Neo Crystal Jig mostly 3-60 (28 samples, many 0, outliers dropped). Additional effects are NOT captured.
