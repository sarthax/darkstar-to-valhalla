---------------------------------------------
-- Scream: AoE Terror + MND Down [W]
-- No capture; numbers/effects are [D] design guesses from wiki text. Tune in game.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    MobStatusEffectMove(mob, target, EFFECT_TERROR, 1, 0, 6);
    skill:setMsg(MobStatusEffectMove(mob, target, EFFECT_MND_DOWN, 10, 3, 120));
    return EFFECT_MND_DOWN;
end;
