-----------------------------------
-- Whirling Edge (Lilisette, Heroines' Holdfast)
-- Skill id/animation confirmed by capture #237; no LSB or Topaz script existed (the skill was
-- silently blocked). Effect/damage below is a PLACEHOLDER: plain single physical hit (msg 185/188).
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
    tpz.heroines.skillSay(mob, tpz.heroines.LILISETTE_LINES[math.random(#tpz.heroines.LILISETTE_LINES)])
    local dmg = tpz.heroines.flatDamage(mob, target, skill, 100, 276, MOBSKILL_PHYSICAL, MOBPARAM_SLASH)
    return dmg
end

-- Damage tuned 2026-09-26 from capture #237: Lilisette Whirling Edge 100-276 (3 samples). Additional effects are NOT captured.
