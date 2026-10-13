---------------------------------------------
--  Crowning Flatus  (Botulus Rex, Voidwatch)
--  [C] radial; stun per [F]. Damage/duration [D].
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
    local dmg = MobMagicalMove(mob, target, skill, mob:getWeaponDmg()*2, ELE_WIND, 1.5, TP_NO_EFFECT);
    local final = MobFinalAdjustments(dmg.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_WIND, MOBPARAM_WIPE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_STUN, 1, 0, 5);
    target:delHP(final);
    skill:setMsg(msgBasic.DAMAGE);
    return final;
end;
