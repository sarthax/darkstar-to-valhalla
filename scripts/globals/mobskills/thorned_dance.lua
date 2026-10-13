-----------------------------------
-- Thorned Dance (Lilisette, Heroines' Holdfast)
-- Skill id/animation confirmed by capture #237; no LSB or Topaz script existed (the skill was
-- silently blocked). Effect/damage below is a PLACEHOLDER: capture msg 194; modelled as a self Defense boost.
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
    skill:setMsg(MobBuffMove(mob, EFFECT_DEFENSE_BOOST, 20, 0, 60))
    return EFFECT_DEFENSE_BOOST
end

-- VERIFIED capture #237: client name is "Thorned Stance" (id 2442), Lilisette self Defense Boost. Power/duration still guessed.
