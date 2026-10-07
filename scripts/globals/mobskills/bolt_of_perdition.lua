---------------------------------------------
--  Bolt of Perdition  (Ig-Alima, Voidwatch)
--  anim 1960 (DB); AoE lightning physical, knockback, Mute + Amnesia 30-40s [F]. Amounts [D].
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
    local final = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_THUNDER, MOBPARAM_WIPE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_MUTE, 1, 0, 35);
    MobStatusEffectMove(mob, target, EFFECT_AMNESIA, 1, 0, 35);
    target:delHP(final);
    skill:setMsg(msgBasic.DAMAGE);
    return final;
end;
