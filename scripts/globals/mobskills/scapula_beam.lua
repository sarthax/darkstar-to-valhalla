---------------------------------------------
--  Scapula Beam  (Voidwrought, Voidwatch)
--  HP<=50%. Magic damage, all-stat down, dispel.
--  Numbers are design guesses [D]; behavior per wikiwiki.jp [J].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");

function onMobSkillCheck(target,mob,skill)
    return mob:getHPP() <= 50 and 0 or 1;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob, target, skill, mob:getWeaponDmg() * 7, -1, 1, TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_LIGHT, MOBPARAM_IGNORE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_STR_DOWN, 20, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_VIT_DOWN, 20, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_AGI_DOWN, 20, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_INT_DOWN, 20, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_MND_DOWN, 20, 0, 60);
    target:dispelStatusEffect();
    target:delHP(dmg);
    skill:setMsg(msgBasic.DAMAGE);
    return dmg;
end;
