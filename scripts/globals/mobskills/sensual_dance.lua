-----------------------------------
-- Sensual Dance (Lilisette, Heroines' Holdfast)
-- Skill id/animation confirmed by capture #237; no LSB or Topaz script existed (the skill was
-- silently blocked). Effect/damage below is a PLACEHOLDER: capture shows only msg 0/189 (no clear effect); modelled as a short Stun.
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
    -- wiki: self attack bonus + Attack Down on targets
    MobBuffMove(mob, EFFECT_ATTACK_BOOST, 25, 0, 30)
    skill:setMsg(MobStatusEffectMove(mob, target, EFFECT_ATTACK_DOWN, 25, 0, 30))
    return EFFECT_ATTACK_DOWN
end

