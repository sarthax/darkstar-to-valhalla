-----------------------------------
-- Lovely Miracle Waltz (Mumor, Heroines' Holdfast)
-- Skill id/animation from capture #237. Damage/effect below is a PLACEHOLDER: capture shows ~10-40 dmg (msg 185); plain AoE hit.
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
    -- 2026-09-27: wired the "...Waltz!" callout, see tpz.heroines.MUMOR_LINES (globals/heroines_holdfast.lua)
    tpz.heroines.mumorSay(mob, "lovely_miracle_waltz")
    MobPhysicalStatusEffectMove(mob, target, skill, EFFECT_TERROR, 1, 0, 5) -- wiki; knockback = mob_skills.knockback column
    local dmg = tpz.heroines.flatDamage(mob, target, skill, 35, 90, MOBSKILL_PHYSICAL, MOBPARAM_BLUNT)
    return dmg
end

-- Damage tuned 2026-09-26 from capture #237: Mumor Lovely Miracle Waltz mostly 35-90 (24 samples, outliers to 830 dropped). Additional effects are NOT captured.
