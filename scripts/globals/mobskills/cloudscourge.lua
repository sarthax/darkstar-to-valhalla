---------------------------------------------
--  Cloudscourge  (Smierc, Voidwatch)
--  [F] 10 yalm AoE damage + Terror. Damage/duration [D].
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
    local dmg = MobMagicalMove(mob, target, skill, mob:getWeaponDmg()*3, ELE_DARK, 1.5, TP_NO_EFFECT);
    local final = MobFinalAdjustments(dmg.dmg, mob, skill, target, MOBSKILL_MAGICAL, MOBPARAM_DARK, MOBPARAM_WIPE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_TERROR, 1, 0, 5);
    target:delHP(final);
    skill:setMsg(msgBasic.DAMAGE);
    return final;
end;
