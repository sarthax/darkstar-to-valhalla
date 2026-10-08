---------------------------------------------
--  Seismic Impact  (Voidwrought, Voidwatch)
--  HP<=75%. Magic damage + Slow.
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
    local info = MobMagicalMove(mob, target, skill, mob:getWeaponDmg() * 7, ELE_EARTH, 1, TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_EARTH, MOBPARAM_IGNORE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_SLOW, 3000, 0, 60);
    target:delHP(dmg);
    skill:setMsg(msgBasic.DAMAGE);
    return dmg;
end;
