---------------------------------------------
-- Calcifying Mist (Ushumgal): AoE gradual petrification [W]
-- No capture; numbers/effects are [D] design guesses from wiki text. Tune in game.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    skill:setMsg(MobStatusEffectMove(mob, target, EFFECT_PETRIFICATION, 1, 0, 8));
    return EFFECT_PETRIFICATION;
end;
