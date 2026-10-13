---------------------------------------------
--  Turbine Hurricane  (Voidwrought, Voidwatch)
--  HP<=75%. Damage, removes buffs. (DSP row name turbine_cyclone, anim 1817.)
--  Numbers are design guesses [D]; behavior per wikiwiki.jp [J].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/magic");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");

function onMobSkillCheck(target,mob,skill)
    return mob:getHPP() <= 75 and 0 or 1;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob, target, skill, mob:getWeaponDmg() * 5, ELE_WIND, 1, TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_WIND, MOBPARAM_IGNORE_SHADOWS);
    target:dispelStatusEffect();
    target:dispelStatusEffect();
    target:delHP(dmg);
    skill:setMsg(msgBasic.DAMAGE);
    return dmg;
end;
