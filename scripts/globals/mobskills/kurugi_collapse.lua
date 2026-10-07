---------------------------------------------
--  Kurnugi Collapse  (Ig-Alima, Voidwatch)
--  [C] anim 1957; AoE earth physical, Magic Acc Down/Acc Down/Burn [F]. Amounts [D].
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/msg");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local info = MobPhysicalMove(mob, target, skill, 1, 1.0, 2.0, TP_NO_EFFECT);
    local final = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_EARTH, MOBPARAM_WIPE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_MAGIC_ACC_DOWN, 30, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_ACCURACY_DOWN, 30, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_BURN, 38, 3, 60);
    target:delHP(final);
    skill:setMsg(msgBasic.DAMAGE);
    return final;
end;
