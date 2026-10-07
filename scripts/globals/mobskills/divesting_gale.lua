---------------------------------------------
--  Divesting Gale  (Ig-Alima, Voidwatch)
--  anim 1959 (DB); AoE wind physical, Encumbrance + Muddle [F]. Amounts [D].
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
    local final = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_WIND, MOBPARAM_WIPE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_ENCUMBRANCE_I, 0xFFFF, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_MUDDLE, 20, 0, 60);
    target:delHP(final);
    skill:setMsg(msgBasic.DAMAGE);
    return final;
end;
