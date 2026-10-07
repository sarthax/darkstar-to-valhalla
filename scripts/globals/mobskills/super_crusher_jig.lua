-----------------------------------
-- Super Crusher Jig (Mumor, Heroines' Holdfast)
-- Skill id/animation from capture #237. Damage/effect below is a PLACEHOLDER: capture ~88 dmg (msg 185); plain AoE hit.
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
    tpz.heroines.mumorSay(mob, "super_crusher_jig")
    target:dispelAllStatusEffect() -- wiki: full dispel; knockback = mob_skills.knockback column
    local dmg = tpz.heroines.flatDamage(mob, target, skill, 44, 154, MOBSKILL_PHYSICAL, MOBPARAM_BLUNT)
    return dmg
end

-- Damage tuned 2026-09-26 from capture #237: Mumor Super Crusher Jig 44-154 (13 samples, 293 outlier dropped). Additional effects are NOT captured.
