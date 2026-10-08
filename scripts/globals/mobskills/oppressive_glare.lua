---------------------------------------------
-- Oppressive Glare: Ushumgal (Voidwatch) gaze skill. [C] id 2392 / anim 1665 seen in the Ushumgal capture.
-- EFFECT UNKNOWN: no source (LSB/wiki) describes it, so it is deliberately a no-effect stub.
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
