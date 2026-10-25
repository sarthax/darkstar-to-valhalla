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
    if (mob:getName() ~= "Ushumgal") then -- Peistes/Kukulkan/Gukumatz: no Lua existed before, keep it a no-op
        skill:setMsg(msgBasic.NO_EFFECT);
        return 0;
    end
    skill:setMsg(MobStatusEffectMove(mob, target, EFFECT_TERROR, 1, 0, 8));
    return EFFECT_TERROR;
end;
