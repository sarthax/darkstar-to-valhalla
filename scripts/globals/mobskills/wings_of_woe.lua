---------------------------------------------
-- Wings of Woe: Celaeno (Voidwatch) skill. [C] id 2727 / anim 1914, used once in the Celaeno capture.
-- EFFECT UNKNOWN: no source describes it, so it is deliberately a no-effect stub.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    skill:setMsg(msgBasic.NO_EFFECT);
    return 0;
end;
