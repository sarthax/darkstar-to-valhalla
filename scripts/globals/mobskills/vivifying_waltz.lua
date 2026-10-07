-----------------------------------
-- Vivifying Waltz (Lilisette, Heroines' Holdfast)
-- Skill id/animation confirmed by capture #237; no LSB or Topaz script existed (the skill was
-- silently blocked). Effect/damage below is a PLACEHOLDER: capture msg 238; modelled as a self heal of 10% max HP.
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
    skill:setMsg(msgBasic.SELF_HEAL)
    return MobHealMove(mob, math.random(792, 836))
end

-- Heal tuned 2026-09-26 from capture #237: Lilisette recovered 792-836 HP per use (8 samples).
