---------------------------------------------
--  Flame Armor
--
--  Description: Covers the user in fiery spikes. Enemies that hit it take fire damage.
--  Type: Enhancing
--  Utsusemi/Blink absorb: N/A
--  Range: Self
--  Notes:
---------------------------------------------

require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

---------------------------------------------

function onMobSkillCheck(target,mob,skill)
    if (mob:getLocalVar("FLAME_ARMOR_HPP") > 0 and mob:getHPP() < mob:getLocalVar("FLAME_ARMOR_HPP")) then return 1; end -- Voidwatch gate (Kholomodumo >=75% [J])
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local power = 50;
    local duration = 180;
    local typeEffect = EFFECT_BLAZE_SPIKES;

    skill:setMsg(MobBuffMove(mob, typeEffect, power, 0, duration));

    return typeEffect;
end;
