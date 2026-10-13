---------------------------------------------
--  Bubble Curtain
--
--  Description: Reduces magical damage received by 50%
--  Type: Enhancing
--  Utsusemi/Blink absorb: N/A
--  Range: Self
--  Notes:Nightmare Crabs use an enhanced version that applies a Magic Defense Boost that cannot be dispelled.
---------------------------------------------

require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");
require("scripts/globals/voidwatch");

---------------------------------------------

function onMobSkillCheck(target,mob,skill)
    if (vwBuffActive ~= nil and vwBuffActive(mob, EFFECT_SHELL)) then return 1; end -- Voidwatch NMs: no re-buff while active
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local typeEffect = EFFECT_SHELL;
    local power = 50;

    skill:setMsg(MobBuffMove(mob, typeEffect, power, 0, 180));

    return typeEffect;
end;
