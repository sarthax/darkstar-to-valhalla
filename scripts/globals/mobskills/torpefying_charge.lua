---------------------------------------------
-- Torpefying Charge: gaze paralysis, 2 min. Ushumgal (Voidwatch) skill.
-- [C] id/anim from Ushumgal capture; effect from LSB torpefying_charge.lua.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    if (mob:getLocalVar("VW_DEADLINE") == 0) then return 1; end -- Voidwatch-only: base mobs sharing this skill stay inert (no Lua existed before VW)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local typeEffect = EFFECT_PARALYSIS;
    skill:setMsg(MobGazeMove(mob, target, typeEffect, 15, 0, 120));
    return typeEffect;
end;
