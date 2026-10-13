---------------------------------------------
--  Testudo Tremor  (Akupara, Voidwatch)
--  Target-centred earth AoE; Stun + Heavy. HP<=50% only.
--  Numbers are design guesses [D]; behavior per wikiwiki.jp [J].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");

function onMobSkillCheck(target,mob,skill)
    return mob:getHPP() <= 50 and 0 or 1;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob, target, skill, mob:getWeaponDmg() * 6, ELE_EARTH, 1, TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_EARTH, MOBPARAM_IGNORE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_STUN, 1, 0, 6);
    MobStatusEffectMove(mob, target, EFFECT_WEIGHT, 50, 0, 60);
    target:delHP(dmg);
    skill:setMsg(msgBasic.DAMAGE);
    return dmg;
end;
