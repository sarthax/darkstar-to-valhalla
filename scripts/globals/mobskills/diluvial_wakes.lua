---------------------------------------------
--  Diluvial Wake  (Ig-Alima, Voidwatch)
--  [C] anim 1956; conal water physical, stat downs [F]. Amounts [D].
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
    local final = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_WATER, MOBPARAM_WIPE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_STR_DOWN, 20, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_DEX_DOWN, 20, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_VIT_DOWN, 20, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_AGI_DOWN, 20, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_INT_DOWN, 20, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_MND_DOWN, 20, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_CHR_DOWN, 20, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_DEFENSE_DOWN, 25, 0, 60);
    MobStatusEffectMove(mob, target, EFFECT_MAGIC_DEF_DOWN, 25, 0, 60);
    mob:setLocalVar("VW_MANTLE", 1);
    target:delHP(final);
    skill:setMsg(msgBasic.DAMAGE);
    return final;
end;
