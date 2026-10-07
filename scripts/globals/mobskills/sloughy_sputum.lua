---------------------------------------------
--  Sloughy Sputum  (Botulus Rex, Voidwatch)
--  [C] conal; gravity + drown per [F]. Damage/durations [D].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");

---------------------------------------------
function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local dmg = MobMagicalMove(mob, target, skill, mob:getWeaponDmg()*3, ELE_WATER, 1.5, TP_NO_EFFECT);
    local final = MobFinalAdjustments(dmg.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_WATER, MOBPARAM_WIPE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_WEIGHT, 50, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_DROWN, 10, 3, 60);
    target:delHP(final);
    skill:setMsg(msgBasic.DAMAGE);
    return final;
end;
