---------------------------------------------------
-- Scream
-- 15' Reduces MND of players in area of effect.
-- Pancimanci (Voidwatch) has a custom version [user]: Terror + MND Down. Every other mandragora: MND Down only.
---------------------------------------------------

require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    if (mob:getName() == "Pancimanci") then
        MobStatusEffectMove(mob, target, EFFECT_TERROR, 1, 0, 6); -- [D]
    end
    local typeEffect = EFFECT_MND_DOWN;
    skill:setMsg(MobStatusEffectMove(mob, target, typeEffect, 10, 3, 120));

    return typeEffect;
end;
