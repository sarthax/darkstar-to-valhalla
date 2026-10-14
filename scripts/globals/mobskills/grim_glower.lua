---------------------------------------------
-- Grim Glower (Ushumgal): gaze, Terror [W]. [D] duration, no capture.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    skill:setMsg(MobStatusEffectMove(mob, target, EFFECT_TERROR, 1, 0, 8));
    return EFFECT_TERROR;
end;
