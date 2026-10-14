---------------------------------------------
-- Dream Flower: AoE deep sleep + hate reset [W]
-- No capture; numbers/effects are [D] design guesses from wiki text. Tune in game.
---------------------------------------------
require("scripts/globals/settings");
require("scripts/globals/status");
require("scripts/globals/monstertpmoves");

function onMobSkillCheck(target,mob,skill)
    return 0;
end;

function onMobWeaponSkill(target, mob, skill)
    local msg = MobStatusEffectMove(mob, target, EFFECT_SLEEP_I, 1, 0, math.random(20, 30));
    mob:resetEnmity(target);
    skill:setMsg(msg);
    return EFFECT_SLEEP_I;
end;
