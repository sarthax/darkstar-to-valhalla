---------------------------------------------
--  Searing Halitus  (Ig-Alima, Voidwatch)
--  [C] anim 1958; AoE fire physical [F]. Damage [D].
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
    local final = MobFinalAdjustments(info.dmg, mob, skill, target, MOBSKILL_PHYSICAL, MOBPARAM_FIRE, MOBPARAM_WIPE_SHADOWS);
    target:delHP(final);
    skill:setMsg(msgBasic.DAMAGE);
    return final;
end;
