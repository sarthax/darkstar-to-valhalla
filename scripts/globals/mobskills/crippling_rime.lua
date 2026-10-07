---------------------------------------------
--  Crippling Rime  (Ig-Alima, Voidwatch)
--  anim 1961 (DB); conal ice physical, hate reset [B]. Amounts [D].
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
    local final = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_ICE, MOBPARAM_WIPE_SHADOWS);
    MobStatusEffectMove(mob, target, EFFECT_SLOW, 3000, 0, 60);
    mob:resetEnmity(target); -- [B] hate reset
    target:delHP(final);
    skill:setMsg(msgBasic.DAMAGE);
    return final;
end;
