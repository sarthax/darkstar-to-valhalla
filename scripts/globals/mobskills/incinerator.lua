---------------------------------------------
--  Incinerator  (Voidwrought, Voidwatch)
--  Frontal fire damage + Burn. Used all fight.
--  Numbers are design guesses [D]; behavior per wikiwiki.jp [J].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobMagicalMove(mob, target, skill, mob:getWeaponDmg() * 5, -1, 1, TP_NO_EFFECT);
    local dmg = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_FIRE, MOBPARAM_IGNORE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_BURN, 20, 3, 60);
    target:delHP(dmg);
    skill:setMsg(msgBasic.DAMAGE);
    return dmg;
end;
